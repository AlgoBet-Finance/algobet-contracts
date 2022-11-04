import { ethers } from 'hardhat'

export const MAX_UINT256 =
  '115792089237316195423570985008687907853269984665640564039457584007913129639935'

export const parseEther = (amount: string) => {
  return ethers.utils.parseUnits(amount, 'ether')
}
