/** @type import('hardhat/config').HardhatUserConfig */
require("@nomiclabs/hardhat-waffle");

const privateKey = process.env.PRIVATE_KEY || "";
const infuraApiKey = process.env.INFURA_API_KEY || "";

module.exports = {
  solidity: "0.8.19",

  networks: {
    goerli:{
      url:infuraApiKey,
      accounts: [privateKey]
    }
  },


};
