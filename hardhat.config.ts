import {config as dotEnvConfig} from 'dotenv';

dotEnvConfig();
import {HardhatUserConfig} from 'hardhat/types';
import 'hardhat-typechain';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import 'hardhat-contract-sizer';
import 'hardhat-gas-reporter';
import '@nomiclabs/hardhat-etherscan';

import './tasks';

const mnemonicAccounts = {
  mnemonic: process.env.MNEMONIC ?? 'test test test test test test test test test test test junk',
};

const accounts = process.env.PRIVATE_KEY
  ? [process.env.PRIVATE_KEY ?? '']
  : mnemonicAccounts;

const config: HardhatUserConfig = {
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      tags: process.env.DEFAULT_TAG ? process.env.DEFAULT_TAG.split(',') : ['local'],
      live: false,
      saveDeployments: false,
      allowUnlimitedContractSize: true,
      chainId: 1,
      accounts: mnemonicAccounts,
    },
    bnb: {
      tags: ['production'],
      live: true,
      saveDeployments: true,
      accounts: accounts,
      loggingEnabled: true,
      url: `https://rpc.ankr.com/bsc`,
    },
    bnb_testnet: {
      tags: ['development'],
      live: true,
      saveDeployments: true,
      accounts: accounts,
      loggingEnabled: true,
      url: `https://rpc.ankr.com/bsc_testnet_chapel`,
    },
    polygon: {
      tags: ['production'],
      live: true,
      saveDeployments: true,
      accounts: accounts,
      loggingEnabled: true,
      url: `https://rpc.ankr.com/polygon`,
    },
    polygon_testnet: {
      tags: ['development'],
      live: true,
      saveDeployments: true,
      accounts: accounts,
      loggingEnabled: true,
      url: `https://rpc.ankr.com/polygon_mumbai`,
    },
    avalanche: {
      tags: ['production'],
      live: true,
      saveDeployments: true,
      accounts: accounts,
      loggingEnabled: true,
      url: `https://rpc.ankr.com/avalanche`,
    },
    avalanche_testnet: {
      tags: ['development'],
      live: true,
      saveDeployments: true,
      accounts: accounts,
      loggingEnabled: true,
      url: `https://rpc.ankr.com/avalanche_fuji`,
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  namedAccounts: {
    deployer: 0
  },
  solidity: {
    compilers: [
      {
        version: '0.8.9',
        settings: {
          optimizer: {
            enabled: true,
            runs: 999999,
          },
        },
      },
    ],
  },
  typechain: {
    outDir: 'typechain',
    target: 'ethers-v5',
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
  mocha: {
    timeout: 200000,
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
};

export default config;
