import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("TestNFT", function () {
  async function deployNFTContract() {
    const [owner, otherAccount] = await ethers.getSigners();

    const Nft = await ethers.getContractFactory("TestNFT");
    const nft = await Nft.deploy();

    return { nft, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should deploy the contract", async function () {
      const { nft } = await loadFixture(deployNFTContract);
      const name = await nft.name();
      const symbol = await nft.symbol();

      expect(name).to.equal("Test NFT");
      expect(symbol).to.equal("TNFT");
    });
    it("Should mint 1 nft", async function () {
      const { nft } = await loadFixture(deployNFTContract);
      await nft.mint();
      const metadataURI = await nft.tokenURI(0);
      const metadata = await fetch(metadataURI).then((res) => res.json());
      expect(metadata.name).to.equal("Rally Protocol Test #0");
      expect(metadata.description).to.equal("The Amazing Rally Protocol NFTs");
    });
  });
});
