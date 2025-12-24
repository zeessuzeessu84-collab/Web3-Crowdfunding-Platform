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

    // Pese nikalne ke liye (Sirf Owner)
    function withdraw(uint256 _id) public {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.owner, "Only owner can withdraw.");
        require(campaign.amountCollected >= campaign.target, "Goal not reached.");
        require(!campaign.claimed, "Already claimed.");

        campaign.claimed = true;
        payable(campaign.owner).transfer(campaign.amountCollected);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);
        for(uint i = 0; i < numberOfCampaigns; i++) {
            allCampaigns[i] = campaigns[i];
        }
        return allCampaigns;
    }
}
