import { ethers } from "hardhat";

// Provider will be on Celo Testnet
const provider = new ethers.JsonRpcProvider(
  "https://alfajores-forno.celo-testnet.org"
);

// setup my wallet
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY as string, provider);

async function main() {
  try {
    // Deploying the contract on Celo Testnet
    const contractFactory = await ethers.getContractFactory("CrosschainSwap");

    // constructor require 2 params --> deployment needs 2 params too!
    /*
            constructor(
        address _gateway,
        address _gasService
            ) AxelarExecutable(_gateway) {
                gasService = IAxelarGasService(_gasService);
            }
        */
    const contract = await contractFactory.deploy("", "");
  } catch (error) {
    console.error("Error deploying contract", error);
  }
}

main();
