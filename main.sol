// SPDX-Licence-Identifier : MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Lottery is VRFConsumerBaseV2 {
    // Getting Random Number Configs
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
    bytes32 keyHash =
        0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint256[] public s_randomWords;
    uint256 public s_requestId;
    // Getting Live Price Configs
    AggregatorV3Interface priceFeed;
    address chainlink_fee = 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e;
    // Lottery Configs
    address payable public winner;
    address s_owner;
    enum STATE {
        CLOSED,
        PENDING,
        CALCULATING
    }
    STATE public state;
    address payable[] People;
    mapping(address => string) peopleNames;
    event Success(string indexed _name, address indexed _address);
    event Winner(string indexed _name, address indexed _address);

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        priceFeed = AggregatorV3Interface(chainlink_fee);
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }

    function getLatestPrice() private view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    function NeededPrice() public view returns (uint256) {
        uint256 usd_price = 50 * 10**18;
        uint256 price = getLatestPrice() / 10**8;
        price = usd_price / price;
        return price;
    }

    function StartLottery() public onlyOwner {
        require(state == STATE.CLOSED, "Its Already Running");
        state = STATE.PENDING;
    }

    function EnterPeople(string memory _name) public payable {
        require(state == STATE.PENDING, "Its Not The Time To Invest!");
        require(msg.value >= NeededPrice(), "Not Enough ETH!");
        People.push(payable(msg.sender));
        peopleNames[msg.sender] = _name;
        emit Success(_name, msg.sender);
    }

    function TotalUsers() public view returns (uint256) {
        return People.length;
    }

    function requestRandomWords() external onlyOwner {
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
    }

    function EndLottery() public onlyOwner returns (string memory, address) {
        require(s_randomWords[0] > 0, "Random Number Has Not Deployed!");
        require(state == STATE.PENDING, "Its Not The Time To End Lottey!");
        state = STATE.CALCULATING;
        uint256 randomDigit = s_randomWords[0];
        uint256 winnerDigit = randomDigit % TotalUsers();
        winner = People[winnerDigit];
        winner.transfer(address(this).balance);
        emit Winner(peopleNames[winner], winner);
        state = STATE.CLOSED;
        People = new address payable[](0);
        s_randomWords = new uint256[](0);
        return (peopleNames[winner], winner);
    }
}
