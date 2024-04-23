import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deploy } = hre.deployments;
  const { deployer } = await hre.getNamedAccounts();
  const forwarderAddress = "0x0ae8FC9867CB4a124d7114B8bd15C4c78C4D40E5";
  await deploy("TestNFT", {
    from: deployer,
    args: [forwarderAddress],
  });
};
export default func;

func.tags = ["DeployAll"];
