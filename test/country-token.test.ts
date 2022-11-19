import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { assert, expect } from 'chai'
import { ethers } from 'hardhat'
import { CountryNFT, USDT } from 'types'
import { MAX_UINT256, parseEther } from './constant'

describe('NftContract', async function () {
  let [owner, alice, bob]: SignerWithAddress[] = []
  let usdt: USDT
  let countryNFT: CountryNFT
  beforeEach(async () => {
    ;[owner, alice, bob] = await ethers.getSigners()
    const USDTContract = await ethers.getContractFactory('USDT')
    usdt = await USDTContract.connect(owner).deploy()
    const CountryNFTContract = await ethers.getContractFactory('CountryNFT')
    countryNFT = await CountryNFTContract.connect(owner).deploy(
      'uri',
      usdt.address,
      owner.address
    )
    // alice, bob 100
    await (await usdt.mint(alice.address, parseEther('100'))).wait()
    await (await usdt.mint(bob.address, parseEther('100'))).wait()
  })
  describe('Covert usdt to country token QATAR (id: 0)', async function () {
    beforeEach(async () => {
      await (
        await usdt.connect(alice).approve(countryNFT.address, MAX_UINT256)
      ).wait()
      await (
        await usdt.connect(bob).approve(countryNFT.address, MAX_UINT256)
      ).wait()
    })
    it('Successful', async () => {
      await (
        await countryNFT.connect(alice).mintCountryNft(0, parseEther('1'))
      ).wait()
      const countryQatarAmount = await countryNFT.balanceOf(alice.address, 0)
      assert.equal(countryQatarAmount.toString(), '1')
    })
    it('Covert amount < 1 USDT', async () => {
      await expect(
        countryNFT.connect(alice).mintCountryNft(0, '100')
      ).to.be.revertedWith('USDT amount is invalid')
    })
    it('Revert with not enough token', async () => {
      await expect(
        countryNFT.connect(alice).mintCountryNft(0, parseEther('101'))
      ).to.be.revertedWith('ERC20: transfer amount exceeds balance')
    })
  })

  describe('Covert country token QATAR (id: 0) to usdt', async function () {
    beforeEach(async () => {
      await (
        await usdt.connect(alice).approve(countryNFT.address, MAX_UINT256)
      ).wait()
      await (
        await usdt.connect(bob).approve(countryNFT.address, MAX_UINT256)
      ).wait()
      await (
        await usdt.connect(owner).approve(countryNFT.address, MAX_UINT256)
      ).wait()
      await (
        await countryNFT.connect(alice).mintCountryNft(0, parseEther('1'))
      ).wait()
    })
    it('Successful', async () => {
      await (await countryNFT.connect(alice).burnCountryNft(0, 1)).wait()
      const countryQatarAmount = await countryNFT.balanceOf(alice.address, 0)
      assert.equal(countryQatarAmount.toString(), '0')
    })
    it('Invalid country Id', async () => {
      await expect(
        countryNFT.connect(alice).burnCountryNft(1, 1)
      ).to.be.revertedWith('You do not have enough nft')
    })
  })
})
