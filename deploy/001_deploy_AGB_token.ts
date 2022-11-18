import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";


const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  let { deployer } = await getNamedAccounts();

  await deploy("AGBToken", {
    contract: "AGBToken",
    skipIfAlreadyDeployed: true,
    from: deployer,
    args: [],
    log: true,
  });

  await hre.run("runVerify", {
    deploymentName: "AGBToken"
  })
};

export default func;
func.tags = ["agb-token"];
