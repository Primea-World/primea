// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Bounty {
    address public primeToken;
    uint256 public bountyCounter;

    struct BountyInfo {
        address creator;
        address targetUser;
        uint256 amount;
        bool claimed;
        address challenger;
        bool validated;
    }

    mapping(uint256 => BountyInfo) public bounties;

    event BountyCreated(uint256 bountyId, address creator, address targetUser, uint256 amount);
    event BountyClaimed(uint256 bountyId, address challenger);
    event BountyValidated(uint256 bountyId, address challenger);

    constructor(address _primeToken) {
        primeToken = _primeToken;
    }

    modifier onlyTargetUser(uint256 _bountyId) {
        require(msg.sender == bounties[_bountyId].targetUser, "Only target user can validate this bounty.");
        _;
    }

    modifier onlyCreator(uint256 _bountyId) {
        require(msg.sender == bounties[_bountyId].creator, "Only creator can access this bounty.");
        _;
    }

    function createBounty(address _targetUser, uint256 _amount) external returns (uint256) {
        require(_amount > 0, "Bounty amount must be greater than 0.");

        bountyCounter++;
        uint256 bountyId = bountyCounter;

        // Transfer Prime tokens from the creator to this contract
        require(IERC20(primeToken).transferFrom(msg.sender, address(this), _amount), "Token transfer failed.");

        bounties[bountyId] = BountyInfo({
            creator: msg.sender,
            targetUser: _targetUser,
            amount: _amount,
            claimed: false,
            challenger: address(0),
            validated: false
        });

        emit BountyCreated(bountyId, msg.sender, _targetUser, _amount);
        return bountyId;
    }

    function claimBounty(uint256 _bountyId) external {
        BountyInfo storage bounty = bounties[_bountyId];
        require(bounty.amount > 0, "Bounty does not exist.");
        require(!bounty.claimed, "Bounty already claimed.");

        bounty.claimed = true;
        bounty.challenger = msg.sender;

        emit BountyClaimed(_bountyId, msg.sender);
    }

    function validateClaim(uint256 _bountyId) external onlyTargetUser(_bountyId) {
        BountyInfo storage bounty = bounties[_bountyId];
        require(bounty.claimed, "Bounty has not been claimed.");
        require(!bounty.validated, "Bounty already validated.");

        bounty.validated = true;

        // Transfer the bounty amount to the challenger
        require(IERC20(primeToken).transfer(bounty.challenger, bounty.amount), "Token transfer to challenger failed.");

        emit BountyValidated(_bountyId, bounty.challenger);
    }

    function withdrawUnclaimed(uint256 _bountyId) external onlyCreator(_bountyId) {
        BountyInfo storage bounty = bounties[_bountyId];
        require(!bounty.claimed, "Bounty already claimed.");

        uint256 amount = bounty.amount;
        bounty.amount = 0;

        // Refund the bounty to the creator
        require(IERC20(primeToken).transfer(bounty.creator, amount), "Token refund failed.");
    }
}
