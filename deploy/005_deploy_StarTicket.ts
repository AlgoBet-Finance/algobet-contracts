import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";


const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  let { deployer } = await getNamedAccounts();
  console.log('deployer :>> ', deployer);
  console.log('balance :>> ', (await (await hre.ethers.getSigners())[0].getBalance()).toString());

  await deploy("StarTicket", {
    contract: "StarTicket",
    skipIfAlreadyDeployed: true,
    from: deployer,
    args: [],
    log: true,
  });

  await hre.run("runVerify", {
    deploymentName: "StarTicket"
  })
};

export default func;
func.tags = ["star-ticket"];
