import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { assert, expect } from 'chai'
import { ethers } from 'hardhat'
import { AGBToken, CountryNFT, USDT, MarketPlace } from 'types'
import { MAX_UINT256, parseEther } from './constant'

describe('Market place', async function () {
  let [owner, alice, bob]: SignerWithAddress[] = []
  let agbToken: AGBToken
  let usdt: USDT
  let marketPlace: MarketPlace
  let countryNFT: CountryNFT

  beforeEach(async () => {
    ;[owner, alice, bob] = await ethers.getSigners()
    const AGBToken = await ethers.getContractFactory('AGBToken')
    agbToken = await AGBToken.connect(owner).deploy()
    const MarketPlace = await ethers.getContractFactory('MarketPlace')
    marketPlace = await MarketPlace.connect(owner).deploy(agbToken.address)
    const USDTContract = await ethers.getContractFactory('USDT')
    usdt = await USDTContract.connect(owner).deploy()
    const CountryNFTContract = await ethers.getContractFactory('CountryNFT')
    countryNFT = await CountryNFTContract.connect(owner).deploy(
      'uri',
      usdt.address,
      owner.address
    )
    // alice, bob 100
    await (await agbToken.mint(alice.address, parseEther('100'))).wait()
    await (await agbToken.mint(bob.address, parseEther('100'))).wait()
    // alice, bob 100
    await (await usdt.mint(alice.address, parseEther('100'))).wait()
    await (await usdt.mint(bob.address, parseEther('100'))).wait()
    // approve
    await (
      await agbToken.connect(alice).approve(marketPlace.address, MAX_UINT256)
    ).wait()
    await (
      await agbToken.connect(bob).approve(marketPlace.address, MAX_UINT256)
    ).wait()
    await (
      await usdt.connect(alice).approve(countryNFT.address, MAX_UINT256)
    ).wait()
    await (
      await usdt.connect(bob).approve(countryNFT.address, MAX_UINT256)
    ).wait()
    await (
      await countryNFT
        .connect(alice)
        .setApprovalForAll(marketPlace.address, true)
    ).wait()
    await (
      await countryNFT.connect(alice).mintCountryNft(0, parseEther('1'))
    ).wait()
  })
  describe('Sell item', async function () {
    beforeEach(async () => {
      
    })
    it('Successful', async () => {
      await (
        await marketPlace
          .connect(alice)
          .sell(countryNFT.address, 0, 1, parseEther('1'))
      ).wait()
      const item = await marketPlace.idToMarketItem(0)
      assert.equal(item['nftContract'], countryNFT.address)
      assert.equal(item['tokenId'].toString(), '0')
      assert.equal(item['seller'], alice.address)
      assert.equal(item['price'].toString(), parseEther('1').toString())
    })
  })

  describe('Buy item', async function () {
    beforeEach(async () => {
      await (
        await marketPlace
          .connect(alice)
          .sell(countryNFT.address, 0, 1, parseEther('1'))
      ).wait()
    })
    it('Successful', async () => {
      await (
        await marketPlace
          .connect(bob)
          .buy(0)
      ).wait()
      const item = await marketPlace.idToMarketItem(0)
      assert.equal(item['buyer'], bob.address)
      assert.equal(item['isSold'], true)
      const aliceBalance = await agbToken.balanceOf(alice.address)
      assert.equal(aliceBalance.toString(), parseEther('101').toString())
    })
  })
  describe('Cancel item', async function () {
    beforeEach(async () => {
      await (
        await marketPlace
          .connect(alice)
          .sell(countryNFT.address, 0, 1, parseEther('1'))
      ).wait()
    })
    it('Successful', async () => {
      await (
        await marketPlace
          .connect(alice)
          .cancelMarketItem(0)
      ).wait()
      const item = await marketPlace.idToMarketItem(0)
      assert.equal(item['isCanceled'], true)
      const aliceBalance = await agbToken.balanceOf(alice.address)
      assert.equal(aliceBalance.toString(), parseEther('100').toString())
    })
  })
})
