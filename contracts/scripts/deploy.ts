import hre from "hardhat";

async function main() {
  //const env = await GsnTestEnvironment.startGsn("localhost", 8090);
  //const { contractsDeployment } = env;

  const forwarderAddress = "0xB2b5841DBeF766d4b521221732F9B618fCf34A87";

  //deploy test rly token
  const NFTContract = await hre.ethers.getContractFactory("TestNFT");
  const nftContract = await NFTContract.deploy(forwarderAddress);

  await nftContract.waitForDeployment();

  const nftContractAddress = await nftContract.getAddress();

  console.log("mumbai deployment successful!");

  console.log("nft contract deployed to", nftContractAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
