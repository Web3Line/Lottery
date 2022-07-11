# Lottery
A Simple Lottery On Rinkeby Testnet Using ChainLink!<br>
In this smart contract we use VRFCoordinatorV2 to get fairly random number and AggregatorV3 to get live prices.<br>
For Further Informations Go To The: <a href="https://docs.chain.link/docs/get-a-random-number/">VRFCoordinatorV2</a> & <a href="https://docs.chain.link/docs/get-the-latest-price/">AggregatorV3</a>.
<br>The main functions are:
  1. StartLottery => Changes the state of contract from CLOSED to PENDING and allow users to invest in lottery
  2. NeededPrice => Shows the 50 USD in ETH amount to invest the exact amount of ETH
  3. EnterPeople => With this function users can enter the lottery, There are two inputs:<br>
    1. ETH value<br>
    2. Name
  4. TotalUsers => Shows the number of users invested
  5. requestRandomWords => With calling this function, You send a request to ChainLink to give you a random number and keeps it in "s_randomWords" varieble
  6. EndLottery => Ends the lottery and calculates the winner and return the state of lottery to CLOSED state
