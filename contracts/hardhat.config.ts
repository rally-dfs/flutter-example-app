import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";

require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  namedAccounts: {
    deployer: 0,
  },
  networks: {
    hardhat: {
      chainId: 1337,
    },
    polygon_amoy: {
      url: `${process.env.RPC_URL_AMOY}`,
      accounts: [`0x${process.env.PRIVATE_KEY_AMOY}`],
    },
  },
};

export default config;
