import { ethers } from 'hardhat'

export const MAX_UINT256 =
  '115792089237316195423570985008687907853269984665640564039457584007913129639935'

export const parseEther = (amount: string) => {
  return ethers.utils.parseUnits(amount, 'ether')
}

export const NOT_END = '0';
export const A_WIN = '1';
export const DRAW = '2';
export const B_WIN = '3';

export const FIRST_HALF = '0';
export const SECOND_HALF = '1';
export const FULLTIME = '2';

export const NO_TICKET = '0';
export const TICKET_1 = '1';
export const TICKET_2 = '2';
export const TICKET_3 = '3';
export const TICKET_4 = '4';
export const TICKET_5 = '5';
export const TICKET_6 = '6';