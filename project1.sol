// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BrainTrainingRewards {
    // Token variables
    string public constant name = "BrainTrainToken";
    string public constant symbol = "BTT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    
    // Token balances
    mapping(address => uint256) public balances;

    // Game tracking
    mapping(address => uint256) public gameCompletions;

    // Admin address
    address public owner;

    // Events
    event TokensMinted(address indexed player, uint256 amount);
    event GameCompleted(address indexed player, uint256 count);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier validAddress(address _addr) {
        require(_addr != address(0), "Invalid address");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to change the contract owner
    function changeOwner(address newOwner) external onlyOwner validAddress(newOwner) {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnerChanged(oldOwner, newOwner);
    }

    // Function to complete a game and mint tokens as a reward
    function completeGame() external {
        uint256 rewardAmount = calculateReward(msg.sender);
        
        // Update game completion count
        gameCompletions[msg.sender] += 1;
        
        // Mint tokens as reward
        mintTokens(msg.sender, rewardAmount);
        
        emit GameCompleted(msg.sender, gameCompletions[msg.sender]);
    }

    // Internal function to mint tokens
    function mintTokens(address to, uint256 amount) internal {
        totalSupply += amount;
        balances[to] += amount;
        emit TokensMinted(to, amount);
    }

    // Function to calculate rewards based on game completions
    function calculateReward(address player) public view returns (uint256) {
        uint256 baseReward = 10 * (10 ** uint256(decimals)); // 10 tokens per game
        uint256 bonusMultiplier = gameCompletions[player] / 5; // Bonus every 5 games
        return baseReward + (bonusMultiplier * baseReward / 2);
    }

    // Function to check token balance
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    // Function to transfer tokens (optional for in-game use)
    function transfer(address to, uint256 amount) external validAddress(to) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}
