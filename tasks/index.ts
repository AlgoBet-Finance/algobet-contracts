import {Deployment} from 'hardhat-deploy/types';
import {task} from 'hardhat/config';

// verify a contract from deployment if specifying:
// 1. deployment name                   => eg : `npx hardhat runVerify --deployment-name AGBToken --network bsc`
// 2. contract address AND tx hash      => eg : `npx hardhat runVerify --address 0x6F82A3C19dc0f8D745b72AA263D8B37a1fF18946 --tx-hash 0xdae0fc676588837b6bd45b4aa7602133992f8167eb8c3d2f796429d2b54282df --network bsc`
task('runVerify')
  .addOptionalParam('deploymentName', 'deployment name')
  .addOptionalParam('address', 'contract address to verify')
  .addOptionalParam('txHash', 'hash of contract creation transaction in case use param address')
  .setDescription('verify contract that already existed in /deployments')
  .setAction(async ({deploymentName, address, txHash}, hre) => {
    if (['hardhat', 'localhost'].includes(hre.network.name)) return;
    const {getOrNull, all} = hre.deployments;
    let deployment: Deployment | null = null;
    let getAddress = hre.ethers.utils.getAddress;
    if (deploymentName) {
      deployment = await getOrNull(deploymentName);
    } else if (address && txHash) {
      let deployments = await all();

      let filtered = Object.entries(deployments)
        .filter(([, v]) => {
          return (
            getAddress(v.address) == getAddress(v.address) && v.transactionHash?.toLowerCase() == txHash.toLowerCase()
          );
        })
        .map(([, v]) => {
          return v;
        });

      if (filtered.length > 0) deployment = filtered[0];
    }

    if (deployment == null) {
      return console.log('deployment not existed');
    }

    try {
      await hre.run('verify:verify', {
        address: deployment.address,
        constructorArguments: deployment.args,
      });
    } catch (error) {
      return console.log(error);
    }
  });
