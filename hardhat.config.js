import '@typechain/hardhat'
import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-waffle'
import { HardhatUserConfig } from 'hardhat/config'
import '@openzeppelin/hardhat-upgrades'
import dotenv from 'dotenv'
import 'tsconfig-paths/register' // This adds support for typescript paths mappings

import './src/tasks'

dotenv.config()

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
const config: HardhatUserConfig = {
  // Your type-safe config goes here
  defaultNetwork: 'bsc_testnet',
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
    },
    localhost: {
      url: `http://localhost:8545`,
      allowUnlimitedContractSize: false,
    },
    
    bsc_testnet: {
      url: `https://data-seed-prebsc-1-s3.binance.org:8545`,
      chainId: 97,
      accounts: {
        mnemonic: process.env.MNEMONIC as string
      }
    },
    bsc: {
      url: `https://bsc-dataseed.binance.org/`,
      chainId: 56,
      accounts: {
        mnemonic: process.env.MNEMONIC as string
      },
      gasPrice: Number.parseInt(process.env.GAS_PRICE as string)
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.8.4',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  typechain: {
    outDir: 'src/types',
    target: 'ethers-v5',
    alwaysGenerateOverloads: true, // should overloads with full signatures like deposit(uint256) be generated always, even if there are no overloads?
    // externalArtifacts: ['externalArtifacts/*.json'], // optional array of glob patterns with external artifacts to process (for example external libs from node_modules)
  },
  paths: {
    root: './src',
    cache: '../cache',
    artifacts: '../artifacts',
  },
}

export default config
