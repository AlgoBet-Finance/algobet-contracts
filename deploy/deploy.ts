import { ethers } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'

async function main() {
  console.log('Deploy start!!!')
  const [owner]: SignerWithAddress[] = await ethers.getSigners()

  // AGB token
  // const AGBToken = await ethers.getContractFactory('AGBToken')
  // const agbToken = await AGBToken.deploy()
  // await agbToken.deployed()
  // console.log('agbToken deployed to:', agbToken.address)

  // Country NFT
  // const USDT = await ethers.getContractFactory('USDT')
  // const usdt = await USDT.deploy()
  // await usdt.deployed()
  // console.log('usdt deployed to:', usdt.address)

  // const CountryNFT = await ethers.getContractFactory('CountryNFT')
  // const countryNFT = await CountryNFT.deploy(
  //   "",
  //   usdt.address,
  //   owner.address
  // )
  // await countryNFT.deployed()
  // console.log('countryNFT deployed to:', countryNFT.address)

  // Market place
  // const MarketPlace = await ethers.getContractFactory('MarketPlace')
  // const marketPlace = await MarketPlace.deploy(
  //   '0xaf9412eFD48F534ecc06cA42391a7D3c49F92B66'
  // )
  // await marketPlace.deployed()
  // console.log('marketPlace deployed to:', marketPlace.address)

  // Star ticket
  // const StarTicket = await ethers.getContractFactory('StarTicket')
  // const starTicket = await StarTicket.deploy(
  //   ''
  // )
  // await starTicket.deployed()
  // console.log('starTicket deployed to:', starTicket.address)

  // Bet
  const Bet = await ethers.getContractFactory('Bet')
  const bet = await Bet.deploy(
      owner.address,
      '0xaf9412eFD48F534ecc06cA42391a7D3c49F92B66',
      '0x9666Cfb212590A2E1ea5f9609cACD279D3357256'
  )
  await bet.deployed()
  console.log('bet deployed to:', bet.address)

  console.log('Deploy end!!!')
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
