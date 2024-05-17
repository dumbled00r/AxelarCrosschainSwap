import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();
const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: "https://rpc-sepolia.rockx.com",
      accounts: [process.env.PRIVATE_KEY as string],
    },
    base: {
      url: "https://base-sepolia.blockpi.network/v1/rpc/public",
      accounts: [process.env.PRIVATE_KEY as string],
    },
    celo: {
      url: "https://alfajores-forno.celo-testnet.org",
      accounts: [process.env.PRIVATE_KEY as string],
    },
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY ?? "",
      baseSepolia: process.env.ETHERSCAN_API_KEY ?? "",
    },
  },
};

export default config;
