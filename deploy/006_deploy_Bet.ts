import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";


const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  let { deployer } = await getNamedAccounts();
  console.log('deployer :>> ', deployer);
  console.log('balance :>> ', (await (await hre.ethers.getSigners())[0].getBalance()).toString());

  await deploy("Bet", {
    contract: "Bet",
    skipIfAlreadyDeployed: true,
    from: deployer,
    args: [
      deployer,
      '0xaf9412eFD48F534ecc06cA42391a7D3c49F92B66',
      '0x9666Cfb212590A2E1ea5f9609cACD279D3357256'
    ],
    log: true,
  });

  await hre.run("runVerify", {
    deploymentName: "Bet"
  })
};

export default func;
func.tags = ["bet"];
