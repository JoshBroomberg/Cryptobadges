# Cryptobadges

Badge game for students in iX Blockchain &amp; Crypto 2018

## The Game

CryptoBadges is designed to use the wisdom of the crowd to reward positive behavior amongst iX students. There are three badges: *Genius*, *Doer* and *Helper*.

In order to get a badge, a student must be nominated by another student through the creation of a proposal. Then, at least 3 students - including the nominator and the recipient - must vote on the proposal. To be accepted, there must be more yes than no votes (a simple majority). After at least 30 minutes have passed, the result can be calculated and the badge can be given by 'executing' the proposal (if there are enough yes votes).

These awards could and should be given for small actions, like someone helping you debug your code. Because you will often be working in groups, we expect the other 'voters' to see the good action take place. But you may need to ask for help getting your proposal passed. Building consensus is a crucial part of blockchain systems on every scale.

## Using the Smart Contract

1. First, you need to download the Metamask chrome plugin from [here](https://metamask.io/#how-it-works). This plugin allows websites in your browser to connect to the ethereum network and interact with it using your local keys (don't worry about understanding what this means for now).
2. Once you have Metamask install, it should look something like it does [in this screenshot](https://drive.google.com/open?id=1rY6EtcyDPOM1iROjwfNp6WAzNd7GYFdV).
   - Use the network selector at the top to change to the  "Kovan Test Network" (click where it says Kovan in the screenshot).
   - Click the three dots next to where it says "iX Account" in the screenshot (although yours will say something else). Click "copy address".
   - Go to [this Google form](https://goo.gl/forms/R9ZwwhgP4B3qxy553) and submit your address and a nickname so that I can register you on the smart contract. Message me when you do this so that I know you've submitted. You can see all the submissions for your class [here](https://docs.google.com/spreadsheets/d/11GcOZAa8st3Vcn-ePtDMnQjmR46mPKJGaWI8Uy5FTwI/edit?usp=sharing). You will need peoples' addresses later so keep this sheet handy.
   - Then, go to [this gitter channel](https://gitter.im/kovan-testnet/faucet) (you may need to sign up) and paste your address into the chat. This will send you some test ether to use to interact with the contract. Even on the test network, all transactions cost a little bit of 'test ether'. Wait for a reply to your chat message to confirm it worked. Your message and reply should look like [this](https://drive.google.com/open?id=1ZJypgpgRoW-ReIgc70Wa8fTRgSkDaT6_).

3. Next, go to [Remix](http://remix.ethereum.org/) which is an online Ethereum IDE. This is where you will go to interact with the smart contract in order to play the game.
   -  In the right column, go to the "run" tab. This is what it will look like: [screenshot](https://drive.google.com/file/d/12R3Y0Bx6Qhb4M5QFEr6--OFo4wSyR_Xk/view?usp=sharing).
   - Use the Environment selection box to select "Injected Web3". You should see your public address appear in the Account.
   - In the "load contract from address" field paste this value `0xD8aa7B97Bd1EB36eDa41BB2050C6f467A27F42D6` and click the button "At Address".
   - After you click the button, something that looks like this should appear at the bottom of the column: [screenshot](https://drive.google.com/open?id=1thTqSSi7Ue58Uo7L70Bcaf5YDKGjbguy).

4. The red boxes represent functions you can 'execute' with certain inputs. This will require a 'transaction' on the chain. The blue boxes are constants that you can always access even without a transaction - they are stored in the 'state' of the chain. Examples of all the inputs described below can be seen [here](https://drive.google.com/open?id=1lWjX2Eqn6PJdiy-qr0t1uf4dibB83a54).
   - To propose a badge for someone, you should fill the field next to "newProposal". You should fill it like this `0x.... (recipient address), "reason for nomination", "badge name (Genius, Helper, Doer)"`. Notice the double quotes around the last 2 values but not the first. These are required. When you are satisfied, click the red square which says "newProposal" to submit the transaction and confirm it in the Metamask popup.
   - To vote on a proposal, you will need the proposal ID. You can either get this from the output of the previous function (which will appear under the row) or by using the blue "proposals" button to explore the proposals. You can type any number into the box to see the proposal. This number is the ID. To vote, type `ID, true/false` into the box next to "vote". Obviously, choose either true or false and click the button then confirm on Metamask.
   - If a proposal is ready to be executed (it has enough votes and 30 mins have passed) then you can use "executeProposal" to give the badge to the recipient. You will need to supply the proposal ID and the badge name like `0, "Genius"`. You have to supply the name again to prevent the need to store it in the proposal (which costs money).
   - You can check the badges you have received by typing your own public address into the "checkBadges" blue box. You will see a list of numbers which are badge IDs. You can check which ID corresponds to which badge using the "badges" blue box. For [example](https://drive.google.com/open?id=1iJjCbfcv-PgmizWZ4J_5rK675T6bP5kX).
5. When you're ready. Place a yes vote for proposal with `ID=0`. It's a *Genius* reward for me for creating this contract (but only because I don't win any awards for *Creativity*).
