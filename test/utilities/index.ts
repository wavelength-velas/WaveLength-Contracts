import { ethers } from 'hardhat';
import { BigNumber } from 'ethers';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

import { WAVEMasterChef } from '../../typechain-types/WAVEMasterChef.sol/WAVEMasterChef';
import { WAVEToken } from '../../typechain-types/WAVEToken.sol/WAVEToken';
import { Ve } from '../../typechain-types/veWAVE.sol/Ve';
import { VeWAVEReceipt } from '../../typechain-types/veWAVEReceipt.sol/VeWAVEReceipt';
import { WaveEmissionDistributor } from '../../typechain-types/EmissionDistributor.sol/WaveEmissionDistributor';
import { RewarderMock } from '../../typechain-types/mocks/RewarderMock.sol/RewarderMock';
import { ERC20Mock } from '../../typechain-types/mocks/ERC20Mock.sol/ERC20Mock';
import { REWARDReceiptMasterChef } from '../../typechain-types/WaveReceiptMasterChef.sol/REWARDReceiptMasterChef';

export * from './time';

export const BASE_TEN = 10;
export const ADDRESS_ZERO = '0x0000000000000000000000000000000000000000';

export function encodeParameters(types: any, values: any) {
  const abi = new ethers.utils.AbiCoder();
  return abi.encode(types, values);
}

export function bn(amount: number, decimals = 18) {
  return BigNumber.from(amount).mul(BigNumber.from(BASE_TEN).pow(decimals));
}

export async function deployContract<T>(contractName: string, constructorArgs: any[]): Promise<T> {
  return ethers
    .getContractFactory(contractName)
    .then(contract => contract.deploy(...constructorArgs))
    .then(contract => contract.deployed()) as Promise<T>;
}

export async function deployChef(
  beetsAddress: string,
  treasuryAddress: string,
  beetsPerBlock = bn(1),
  startBlock = 0,
): Promise<WAVEMasterChef> {
  return deployContract('contracts/WAVEMasterChef.sol:WAVEMasterChef', [
    beetsAddress,
    treasuryAddress,
    beetsPerBlock,
    startBlock,
  ]);
}

export async function deployERC20Mock(name: string, symbol: string, supply: number, decimals = 18): Promise<WAVEToken> {
  return deployContract('contracts/mocks/ERC20Mock.sol:ERC20Mock', [name, symbol, decimals, bn(supply)]);
}

export async function deployRewardReceiptChef(
  rewardToken: string,
  rewaderPerBlock = bn(1),
  startBlock = 0,
): Promise<REWARDReceiptMasterChef> {
  return deployContract('contracts/WaveReceiptMasterChef.sol:REWARDReceiptMasterChef', [
    rewardToken,
    rewaderPerBlock,
    startBlock,
  ]);
}

export const initEmissionDistributor = async (
  owner: SignerWithAddress,
  treasury: SignerWithAddress,
): Promise<[WAVEToken, WAVEMasterChef, Ve, VeWAVEReceipt, WaveEmissionDistributor]> => {
  const waveToken: WAVEToken = await deployContract('contracts/EmissionDistributor.sol:WAVEToken', []);
  const waveTokenAmount = bn(10);
  await waveToken.mint(owner.address, waveTokenAmount);

  const masterChef: WAVEMasterChef = await deployChef(waveToken.address, treasury.address);
  await waveToken.transferOwnership(masterChef.address);

  const veWave: Ve = await deployContract('contracts/veWAVE.sol:ve', [waveToken.address]);

  const waveReceipt: VeWAVEReceipt = await deployContract('contracts/veWAVEReceipt.sol:veWAVEReceipt', []);

  const farmPid = 0;
  const emissionDistributor: WaveEmissionDistributor = await deployContract(
    'contracts/EmissionDistributor.sol:WaveEmissionDistributor',
    [veWave.address, waveToken.address, masterChef.address, farmPid, waveReceipt.address],
  );
  await waveReceipt.transferOwnership(emissionDistributor.address);

  return [waveToken, masterChef, veWave, waveReceipt, emissionDistributor];
};

export const initRewarder = async (masterChef: string): Promise<[ERC20Mock, RewarderMock]> => {
  const rewardToken: ERC20Mock = await deployERC20Mock('Reward', 'RewardT', 1000);

  const rewardMultiplier = ethers.utils.parseEther('1');
  const rewarder: RewarderMock = await deployContract('contracts/mocks/RewarderMock.sol:RewarderMock', [
    rewardMultiplier,
    rewardToken.address,
    masterChef,
  ]);

  return [rewardToken, rewarder];
};
