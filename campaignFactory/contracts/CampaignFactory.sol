// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint256 minimum) public {
        address newCampaign = address(new Campaign(minimum, msg.sender));
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description; // describes why the request is being created
        uint256 value; // amount of money that the manager wants to send to the vendor
        address recipient; // address that the money will be sent to
        bool complete; // true if the request has already been processed (money sent)
        uint256 approvalCount; // number of yes votes
        mapping(address => bool) approvals; // approval entries hash table
    }

    address public manager;
    uint256 public minimumContribution;
    mapping(address => bool) public approvers;
    Request[] public requests;
    uint256 public approversCount;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    constructor(uint256 minimum, address creator) {
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution);

        if (!approvers[msg.sender]) {
            approversCount++;
        }

        approvers[msg.sender] = true;
    }

    function createRequest(
        string memory description,
        uint256 value,
        address recipient
    ) public restricted {
        // forbidden push with nested map in map workaround
        uint256 id = requests.length;
        requests.push();
        Request storage newRequest = requests[id];

        newRequest.description = description;
        newRequest.value = value;
        newRequest.recipient = recipient;
        newRequest.approvalCount = 0;
    }

    function approveRequest(uint256 id) public {
        Request storage request = requests[id];

        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint256 id) public restricted {
        Request storage request = requests[id];

        require(!request.complete);
        require(request.approvalCount > (approversCount / 2));

        payable(request.recipient).transfer(request.value);
        request.complete = true;
    }
}
