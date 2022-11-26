import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";


const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  let { deployer } = await getNamedAccounts();
  console.log('deployer :>> ', deployer);
  console.log('balance :>> ', (await (await hre.ethers.getSigners())[0].getBalance()).toString());

  await deploy("MarketPlace", {
    contract: "MarketPlace",
    skipIfAlreadyDeployed: true,
    from: deployer,
    args: ["0xaf9412eFD48F534ecc06cA42391a7D3c49F92B66"],
    log: true,
  });

  await hre.run("runVerify", {
    deploymentName: "MarketPlace"
  })
};

export default func;
func.tags = ["market-place"];
