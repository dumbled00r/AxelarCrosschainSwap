import { ethers } from "hardhat";
import hre from "hardhat";
// Provider will be on Celo Testnet
const provider = new ethers.JsonRpcProvider("https://rpc-sepolia.rockx.com");

// setup my wallet
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY as string, provider);

async function main() {
  try {
    // Deploying the contract on Celo Testnet
    const contractFactory = await ethers.getContractFactory("CrosschainSwap");

    // constructor requires 2 params --> deployment needs 2 params too!
    /*
            constructor(
        address _gateway,
        address _gasService
            ) AxelarExecutable(_gateway) {
                gasService = IAxelarGasService(_gasService);
            }
        */

    const contract = await contractFactory.deploy(
      "0xe432150cce91c13a887f7D836923d5597adD8E31",
      "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6"
    );

    await contract.waitForDeployment();
    const deployedAddress = await contract.getAddress();
    console.log(`Contract deployed to: ${deployedAddress}`);

    // Wait for a few confirmations before verification
    // Verify the contract
    await hre.run("verify:verify", {
      address: deployedAddress,
      constructorArguments: [
        "0xe432150cce91c13a887f7D836923d5597adD8E31",
        "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6",
      ],
    });

    console.log("Contract verified successfully");
  } catch (error) {
    console.error("Error deploying and verifying contract", error);
  }
}

main();
