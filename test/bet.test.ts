import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { assert, expect } from 'chai'
import { ethers } from 'hardhat'
import { AGBToken, Bet, StarTicket } from 'types'
import {
  A_WIN,
  B_WIN,
  FIRST_HALF,
  MAX_UINT256,
  NO_TICKET,
  NOT_END,
  parseEther,
  TICKET_1,
  TICKET_2
} from './constant'

describe('Bet contract', async function () {
  let [owner, alice, bob]: SignerWithAddress[] = []
  let agbToken: AGBToken
  let starTicket: StarTicket
  let bet: Bet
  beforeEach(async () => {
    ;[owner, alice, bob] = await ethers.getSigners()
    const AGBToken = await ethers.getContractFactory('AGBToken')
    agbToken = await AGBToken.connect(owner).deploy()
    const StarTicket = await ethers.getContractFactory('StarTicket')
    starTicket = await StarTicket.connect(owner).deploy('uri')
    const Bet = await ethers.getContractFactory('Bet')
    bet = await Bet.connect(owner).deploy(
      owner.address,
      agbToken.address,
      starTicket.address
    )
    // alice, bob 100
    await (await agbToken.mint(alice.address, parseEther('100'))).wait()
    await (await agbToken.mint(bob.address, parseEther('100'))).wait()
    await (await agbToken.mint(owner.address, parseEther('10000'))).wait()
  })
  describe('Create match', async function () {
    beforeEach(async () => {})
    it('Successful', async () => {
      await (await bet.createMatch('QATAR-GERMANY')).wait()
      const matchInfo = await bet.idToMatchInfo(0)
      assert.equal(matchInfo['matchCode'], 'QATAR-GERMANY')
      assert.equal(matchInfo['firstHalfResult'].toString(), NOT_END)
      assert.equal(matchInfo['secondHalfResult'].toString(), NOT_END)
      assert.equal(matchInfo['fulltimeResult'].toString(), NOT_END)
    })
  })
  describe('Update FirstHalf', async function () {
    beforeEach(async () => {
      await (await bet.createMatch('QATAR-GERMANY')).wait()
    })
    it('Successful', async () => {
      await (await bet.updateFirstHalf(0, A_WIN)).wait()
      const matchInfo = await bet.idToMatchInfo(0)
      assert.equal(matchInfo['matchCode'], 'QATAR-GERMANY')
      assert.equal(matchInfo['firstHalfResult'].toString(), A_WIN)
      assert.equal(matchInfo['secondHalfResult'].toString(), NOT_END)
      assert.equal(matchInfo['fulltimeResult'].toString(), NOT_END)
    })
    it('Revert because updated', async () => {
      await (await bet.updateFirstHalf(0, A_WIN)).wait()
      await expect(bet.updateFirstHalf(0, A_WIN)).to.be.revertedWith(
        'First half was updated'
      )
    })
  })
  describe('Update SecondHalf', async function () {
    beforeEach(async () => {
      await (await bet.createMatch('QATAR-GERMANY')).wait()
    })
    it('Successful', async () => {
      await (await bet.updateFirstHalf(0, A_WIN)).wait()
      await (await bet.updateSecondHalf(0, A_WIN)).wait()
      const matchInfo = await bet.idToMatchInfo(0)
      assert.equal(matchInfo['matchCode'], 'QATAR-GERMANY')
      assert.equal(matchInfo['firstHalfResult'].toString(), A_WIN)
      assert.equal(matchInfo['secondHalfResult'].toString(), A_WIN)
      assert.equal(matchInfo['fulltimeResult'].toString(), NOT_END)
    })
    it('Revert because not update first half', async () => {
      await expect(bet.updateSecondHalf(0, A_WIN)).to.be.revertedWith(
        'First half was not updated'
      )
    })
    it('Revert because updated', async () => {
      await (await bet.updateFirstHalf(0, A_WIN)).wait()
      await (await bet.updateSecondHalf(0, A_WIN)).wait()
      await expect(bet.updateSecondHalf(0, A_WIN)).to.be.revertedWith(
        'Second half was updated'
      )
    })
  })
  describe('Update fulltime', async function () {
    beforeEach(async () => {
      await (await bet.createMatch('QATAR-GERMANY')).wait()
    })
    it('Successful', async () => {
      await (await bet.updateFirstHalf(0, A_WIN)).wait()
      await (await bet.updateSecondHalf(0, A_WIN)).wait()
      await (await bet.updateFulltime(0, A_WIN)).wait()
      const matchInfo = await bet.idToMatchInfo(0)
      assert.equal(matchInfo['matchCode'], 'QATAR-GERMANY')
      assert.equal(matchInfo['firstHalfResult'].toString(), A_WIN)
      assert.equal(matchInfo['secondHalfResult'].toString(), A_WIN)
      assert.equal(matchInfo['fulltimeResult'].toString(), A_WIN)
    })
    it('Revert because not update first half', async () => {
      await expect(bet.updateFulltime(0, A_WIN)).to.be.revertedWith(
        'First half was not updated'
      )
    })
    it('Revert because updated', async () => {
      await (await bet.updateFirstHalf(0, A_WIN)).wait()
      await (await bet.updateSecondHalf(0, A_WIN)).wait()
      await (await bet.updateFulltime(0, A_WIN)).wait()
      await expect(bet.updateFulltime(0, A_WIN)).to.be.revertedWith(
        'Fulltime was updated'
      )
    })
  })
  describe('User Bet', async function () {
    beforeEach(async () => {
      await (await bet.createMatch('QATAR-GERMANY')).wait()
      await (await agbToken.connect(alice).approve(bet.address, MAX_UINT256)).wait()
      await (await agbToken.connect(bob).approve(bet.address, MAX_UINT256)).wait()
    })
    it('Successful', async () => {
      const messageHashBytes = await bet.getMessageHash('0', FIRST_HALF, parseEther('1'), 200)
      //
      // let wallet = new ethers.Wallet("private_key");
      // const signature = await wallet.signMessage(ethers.utils.arrayify(messageHashBytes));
      //
      const signature = await owner.signMessage(ethers.utils.arrayify(messageHashBytes));

      await (await bet.connect(alice).userBet(
        0,
        FIRST_HALF,
        parseEther('1'),
        200,
        A_WIN,
        NO_TICKET,
        signature
      )).wait()

      const betInfo = await bet.idToBetInfo(0)
      assert.equal(betInfo['betType'].toString(), FIRST_HALF)
      assert.equal(betInfo['amount'].toString(), parseEther('1').toString())
      assert.equal(betInfo['oddsBet'].toString(), '200')
      assert.equal(betInfo['betResult'].toString(), A_WIN)
      assert.equal(betInfo['starTicketId'].toString(), '0')
    })
    it('This bet information is invalid', async () => {
      await (await bet.updateFirstHalf(0, A_WIN)).wait()
      const messageHashBytes = await bet.getMessageHash('0', FIRST_HALF, parseEther('1'), 200)
      const signature = await owner.signMessage(ethers.utils.arrayify(messageHashBytes));
      await expect(bet.connect(alice).userBet(
          0,
          FIRST_HALF,
          parseEther('1'),
          200,
          A_WIN,
          NO_TICKET,
          signature
      )).to.be.revertedWith(
          'This bet information is invalid'
      )
    })
    it('This bet signature is invalid', async () => {
      const messageHashBytes = await bet.getMessageHash('0', FIRST_HALF, parseEther('1'), 200)
      const signature = await alice.signMessage(ethers.utils.arrayify(messageHashBytes));
      await expect(bet.connect(alice).userBet(
          0,
          FIRST_HALF,
          parseEther('1'),
          200,
          A_WIN,
          NO_TICKET,
          signature
      )).to.be.revertedWith(
          'This bet signature is invalid'
      )
    })
    it('Star ticket is invalid', async () => {
      const messageHashBytes = await bet.getMessageHash('0', FIRST_HALF, parseEther('1'), 200)
      const signature = await owner.signMessage(ethers.utils.arrayify(messageHashBytes));
      await expect(bet.connect(alice).userBet(
          0,
          FIRST_HALF,
          parseEther('1'),
          200,
          A_WIN,
          TICKET_1,
          signature
      )).to.be.revertedWith(
          'Star ticket is invalid'
      )
    })
  })
  describe.only('User Claim', async function () {
    beforeEach(async () => {
      await (await bet.createMatch('QATAR-GERMANY')).wait()
      await (await agbToken.connect(alice).approve(bet.address, MAX_UINT256)).wait()
      await (await agbToken.connect(bob).approve(bet.address, MAX_UINT256)).wait()
      await (await agbToken.connect(owner).approve(bet.address, MAX_UINT256)).wait()
      const messageHashBytes = await bet.getMessageHash('0', FIRST_HALF, parseEther('1'), 200)
      const signature = await owner.signMessage(ethers.utils.arrayify(messageHashBytes));
      await (await bet.connect(alice).userBet(
          0,
          FIRST_HALF,
          parseEther('1'),
          200,
          A_WIN,
          NO_TICKET,
          signature
      )).wait()
    })
    it('Successful', async () => {
      await (await bet.updateFirstHalf(0, A_WIN)).wait()
      await (await bet.connect(bob).userClaim(0)).wait()
      const aliceBalance = await agbToken.balanceOf(alice.address)
      assert.equal(aliceBalance.toString(), parseEther('101').toString())
    })
    it('This claim information is invalid', async () => {
      await expect(bet.connect(alice).userClaim(0)).to.be.revertedWith(
          'This claim information is invalid'
      )
    })
    it('User claimed', async () => {
      await (await bet.updateFirstHalf(0, A_WIN)).wait()
      await (await bet.connect(alice).userClaim(0)).wait()
      await expect(bet.connect(alice).userClaim(0)).to.be.revertedWith(
          'User claimed'
      )
    })
    it('You lose', async () => {
      await (await bet.updateFirstHalf(0, B_WIN)).wait()
      await expect(bet.connect(alice).userClaim(0)).to.be.revertedWith(
          'You lose'
      )
    })
    it.only('Ticket used', async () => {
      await (
          await starTicket
              .connect(alice)
              .setApprovalForAll(bet.address, true)
      ).wait()
      await (await starTicket.mint(alice.address, TICKET_2, 1)).wait()
      const messageHashBytes = await bet.getMessageHash('0', FIRST_HALF, parseEther('1'), 200)
      const signature = await owner.signMessage(ethers.utils.arrayify(messageHashBytes));
      await (await bet.connect(alice).userBet(
          0,
          FIRST_HALF,
          parseEther('1'),
          200,
          A_WIN,
          TICKET_2,
          signature
      )).wait()
      await (await bet.updateFirstHalf(0, A_WIN)).wait()
      await (await bet.connect(alice).userClaim(1)).wait()
      const balanceTicket2Owner = await starTicket.balanceOf(owner.address, TICKET_2)
      const balanceTicket2Alice = await starTicket.balanceOf(alice.address, TICKET_2)
      assert.equal(balanceTicket2Owner.toString(), '1')
      assert.equal(balanceTicket2Alice.toString(), '0')
      const aliceBalance = await agbToken.balanceOf(alice.address)
      console.log('aliceBalance :>>', aliceBalance.toString())
    })
  })
})
