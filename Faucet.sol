// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Smart contract for a multi-network faucet
contract HackerBoostFaucet {
    address public owner; // Address of the contract owner

    // Mapping to track last request timestamps
    mapping(address => uint256) public addressLastRequest;
    mapping(uint256 => uint256) public userLastRequest;

    // Mapping to track total tokens claimed
    mapping(address => uint256) public addressClaimedTokens;
    mapping(uint256 => uint256) public userClaimedTokens;

    uint256 public cooldownTime = 1 days; // Time required between requests
    uint256 public faucetAmount = 0.01 ether; // Amount of ETH dispensed per request

    event TokensClaimed(address indexed userAddress, uint256 amount);

    // Modifier to restrict function access to the contract owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Constructor sets the deployer as the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function to receive ETH deposits into the faucet contract
    receive() external payable {}

    // Function for users to request test tokens
    function requestTokens(address payable _req, uint256 _userId) external {
        require(addressLastRequest[_req] + cooldownTime < block.timestamp, "Cooldown active");
        require(userLastRequest[_userId] + cooldownTime < block.timestamp, "Cooldown active");
        require(address(this).balance >= faucetAmount, "Faucet empty");

        // Update last request timestamps
        addressLastRequest[_req] = block.timestamp;
        userLastRequest[_userId] = block.timestamp;

        // Ensure unique tracking (to avoid duplicates)
        if (addressClaimedTokens[_req] == 0) {
            addressClaimedTokens[_req] = faucetAmount;
        } else {
            addressClaimedTokens[_req] += faucetAmount;
        }

        if (userClaimedTokens[_userId] == 0) {
            userClaimedTokens[_userId] = faucetAmount;
        } else {
            userClaimedTokens[_userId] += faucetAmount;
        }

        // Transfer tokens
        _req.transfer(faucetAmount);

        emit TokensClaimed(_req, faucetAmount);
    }

    // Refill function by hackerboost
    function refillFaucet() external payable {}

    // Function to set a custom cooldown time
    function setCooldown(uint256 _time) external onlyOwner {
        cooldownTime = _time;
    }

    // Function to set the amount of ETH dispensed per request
    function setFaucetAmount(uint256 _amount) external onlyOwner {
        faucetAmount = _amount;
    }
}
