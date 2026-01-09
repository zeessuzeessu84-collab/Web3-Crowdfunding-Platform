// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        bool claimed;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public numberOfCampaigns = 0;

    // Naya Campaign shuru karne ke liye
    function createCampaign(
        address _owner, 
        string memory _title, 
        string memory _description, 
        uint256 _target, 
        uint256 _deadline
    ) public returns (uint256) {
        require(_deadline > block.timestamp, "Deadline should be in future.");

        Campaign storage campaign = campaigns[numberOfCampaigns];
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.claimed = false;

        numberOfCampaigns++;
        return numberOfCampaigns - 1;
    }

    // Donate karne ke liye
    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value;
        Campaign storage campaign = campaigns[_id];

        require(block.timestamp < campaign.deadline, "Campaign ended.");
        
        campaign.amountCollected += amount;
    }

    // CEI pattern added on withdraw function
 function withdraw(uint256 _id) public {
    require(_id < numberOfCampaigns, "Campaign does not exist");
    
    Campaign storage campaign = campaigns[_id];
    
    // CHECKS
    require(msg.sender == campaign.owner, "Only owner can withdraw");
    require(block.timestamp >= campaign.deadline, "Campaign not ended");
    require(campaign.amountCollected >= campaign.target, "Goal not reached");
    require(!campaign.claimed, "Already claimed");
    require(campaign.amountCollected > 0, "No funds to withdraw");
    
    // EFFECTS (update state BEFORE external calls)
    uint256 amount = campaign.amountCollected;
    campaign.claimed = true;
    campaign.amountCollected = 0;  // Prevent reentrancy via multiple withdrawals
    
    // INTERACTIONS (external call LAST)
    (bool success, ) = payable(campaign.owner).call{value: amount}("");
    require(success, "Transfer failed");
}

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);
        for(uint i = 0; i < numberOfCampaigns; i++) {
            allCampaigns[i] = campaigns[i];
        }
        return allCampaigns;
    }
}
