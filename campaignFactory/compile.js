const path = require("path");
const fs = require("fs");
const solc = require("solc");

const campaignFactoryPath = path.resolve(
  __dirname,
  "contracts",
  "CampaignFactory.sol"
);
const source = fs.readFileSync(campaignFactoryPath, "utf8");

const input = {
  language: "Solidity",
  sources: {
    "CampaignFactory.sol": {
      content: source,
    },
  },
  settings: {
    outputSelection: {
      "*": {
        "*": ["*"],
      },
    },
  },
};

module.exports = JSON.parse(solc.compile(JSON.stringify(input))).contracts[
  "CampaignFactory.sol"
].CampaignFactory;
