pragma solidity ^0.4.16;

// Code adapted from the DAO template here:
// https://www.ethereum.org/dao

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract IXBadges is owned {

    // Contract Variables
    uint public debatingPeriodInMinutes;
    int public minimumThreshold;
    Proposal[] public proposals;
    uint public numProposals;

    mapping (address => uint) public studentId;
    Student[] public students;

    mapping (string => uint) badgeId;
    string[] public badges;

    struct Proposal {
        address recipient;
        string description;
        uint minExecutionDate;
        bool executed;
        bool proposalPassed;
        uint numberOfVotes;
        int currentResult;
        bytes32 proposalHash;
        Vote[] votes;
        mapping (address => bool) voted;
    }

    struct Student {
        address student;
        string name;
        uint studentSince;
        uint[] badges;
    }

    struct Vote {
        bool inSupport;
        address voter;
    }

    // Modifier that allows only shareholders to vote and create new proposals
    modifier onlyStudents {
        require(studentId[msg.sender] != 0);
        _;
    }

    /**
     * Constructor function
     */
    constructor (
        uint minutesForDebate,
        int minimumThresholdForAward
    )  payable public {
        changeVotingRules(minutesForDebate, minimumThresholdForAward);

        // It’s necessary to add an empty first student
        addStudent(0, "");

        // It’s necessary to add an empty first badge
        addBadge("");

        // and let's add the founder, to save a step later
        addStudent(owner, 'JMB'); // me :)
    }

    function addBadge(string badgeName) public {
        // Check existence of badge.
        uint id = badgeId[badgeName];
        if (id == 0) {
            badgeId[badgeName] = badges.length;
            id = badges.length++;
            badges[id] = badgeName;
        }
    }

    /**
     * Add student
     *
     * Make `targetStudent` a student named `studentName`
     *
     * @param targetStudent ethereum address to be added
     * @param studentName public name for that student
     */
    function addStudent(address targetStudent, string studentName) onlyOwner public {
        // Check existence of student.
        uint id = studentId[targetStudent];
        if (id == 0) {
            studentId[targetStudent] = students.length;
            id = students.length++;
        }

        Student storage s = students[id];
        s.student = targetStudent;
        s.studentSince = now;
        s.name = studentName;
    }

    /**
     * Remove student
     *
     * @notice Remove studentship from `targetStudent`
     *
     * @param targetStudent ethereum address to be removed
     */
    function removeStudent(address targetStudent) onlyOwner public {
        require(studentId[targetStudent] != 0);

        for (uint i = studentId[targetStudent]; i<students.length-1; i++){
            students[i] = students[i+1];
        }
        delete students[students.length-1];
        students.length--;
    }

    /**
     * Change voting rules
     *
     * Make so that proposals need to be discussed for at least `minutesForDebate/60` hours,
     * have at least minimumThresholdForAward votes to be executed.
     *
     * @param minutesForDebate the minimum amount of delay between when a proposal is made and when it can be executed
     * @param minimumThresholdForAward the proposal needs to have this number
     */
    function changeVotingRules(
        uint minutesForDebate,
        int minimumThresholdForAward
    ) onlyOwner public {
        debatingPeriodInMinutes = minutesForDebate;
        minimumThreshold = minimumThresholdForAward;
    }

    /**
     * Add Proposal
     *
     * Propose to send a badge `badgeName to `targetStudent` for `reason`.
     *
     * @param targetStudent who to send the badge to
     * @param badgeName which badge to send
     * @param reason is the reason for the badge
     */
    function newProposal(
        address targetStudent,
        string reason,
        string badgeName
    )
        onlyStudents public
        returns (uint proposalID)
    {
        proposalID = proposals.length++;
        Proposal storage p = proposals[proposalID];
        p.recipient = targetStudent;
        p.description = reason;
        p.proposalHash = keccak256(abi.encodePacked(targetStudent, badgeName));
        p.minExecutionDate = now + debatingPeriodInMinutes * 1 minutes;
        p.executed = false;
        p.proposalPassed = false;
        p.numberOfVotes = 0;

        numProposals = proposalID+1;

        return proposalID;
    }

    /**
     * Check if a proposal hashed code matches supplied target and badge
     *
     * @param proposalNumber ID number of the proposal to query
     * @param targetStudent who to send the badge to
     * @param badgeName which badge to send
     */
    function checkProposalCode(
        uint proposalNumber,
        address targetStudent,
        string badgeName
    )
        constant public
        returns (bool codeChecksOut)
    {
        Proposal storage p = proposals[proposalNumber];
        return p.proposalHash == keccak256(
            abi.encodePacked(targetStudent, badgeName));
    }

    /**
     * Log a vote for a proposal
     *
     * Vote `supportsProposal? in support of : against` proposal #`proposalNumber`
     *
     * @param proposalNumber number of proposal
     * @param supportsProposal either in favor or against it
     */
    function vote(
        uint proposalNumber,
        bool supportsProposal
    )
        onlyStudents public
        returns (uint voteID)
    {
        Proposal storage p = proposals[proposalNumber]; // Get the proposal
        require(!p.voted[msg.sender]);                  // If has already voted, cancel
        p.voted[msg.sender] = true;                     // Set this voter as having voted
        p.numberOfVotes++;                              // Increase the number of votes
        if (supportsProposal) {                         // If they support the proposal
            p.currentResult++;                          // Increase score
        } else {                                        // If they don't
            p.currentResult--;                          // Decrease the score
        }

        return p.numberOfVotes;
    }

    /**
     * Finish vote
     *
     * Count the votes proposal #`proposalNumber` and execute it if approved
     *
     * @param proposalNumber proposal number
     * @param badgeName the name of the badge to be given
     */
    function executeProposal(uint proposalNumber, string badgeName) public {
        Proposal storage p = proposals[proposalNumber];

        require(now > p.minExecutionDate                                            // If it is past the voting deadline
            && !p.executed                                                         // and it has not already been executed
            && p.proposalHash == keccak256(
                abi.encodePacked(p.recipient, badgeName)));  // and the supplied code matches the proposal                               // and a minimum quorum has been reached...

        // ...then execute result

        if (p.currentResult >= minimumThreshold) {
            // Proposal passed; execute the transaction

            p.proposalPassed = true;
            p.executed = true; // Avoid recursive calling (reentrancy) by setting this first.

            // Begin execution
            uint id  = studentId[p.recipient];
            Student storage student = students[id];

            uint badge_id = badgeId[badgeName];
            require(badge_id != 0);

            uint badge_index = student.badges.length;
            student.badges.length++;

            student.badges[badge_index] = badge_id;


        } else {
            // Proposal failed
            p.proposalPassed = false;
        }

    }

     function checkBadges(
        address student
    )
        onlyStudents constant public
        returns (uint[] studentBadges)
    {
        uint id = studentId[student];
        Student storage s = students[id];
        return(s.badges);
    }

    function kill()
      onlyOwner public
    {
      selfdestruct(owner);
    }
}
