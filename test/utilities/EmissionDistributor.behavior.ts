import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { ethers } from 'hardhat';

import { WAVEToken } from '../../typechain-types/WAVEToken.sol/WAVEToken';
import { WAVEMasterChef } from '../../typechain-types/WAVEMasterChef.sol/WAVEMasterChef';
import { Ve } from '../../typechain-types/veWAVE.sol/Ve';
import { VeWAVEReceipt } from '../../typechain-types/veWAVEReceipt.sol/VeWAVEReceipt';
import { WaveEmissionDistributor } from '../../typechain-types/EmissionDistributor.sol/WaveEmissionDistributor';
import { RewarderMock } from '../../typechain-types/mocks/RewarderMock.sol/RewarderMock';
import { ERC20Mock } from '../../typechain-types/mocks/ERC20Mock.sol/ERC20Mock';
import { deployContract } from './index';

export const deployEmissionDistributor = async (
  owner: SignerWithAddress,
  treasury: SignerWithAddress,
): Promise<[WAVEToken, WAVEMasterChef, Ve, VeWAVEReceipt, WaveEmissionDistributor]> => {
  const waveToken: WAVEToken = await deployContract('contracts/EmissionDistributor.sol:WAVEToken', []);
  const waveTokenAmount = ethers.utils.parseEther('10');
  await waveToken.mint(owner.address, waveTokenAmount);

  const wavePerBlock = ethers.utils.parseEther('1');
  const startBlock = 0;
  const masterChef: WAVEMasterChef = await deployContract('contracts/WAVEMasterChef.sol:WAVEMasterChef', [
    waveToken.address,
    treasury.address,
    wavePerBlock,
    startBlock,
  ]);
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

export const deployRewarder = async (masterChef: string): Promise<[ERC20Mock, RewarderMock]> => {
  const tokenName = 'Reward';
  const tokenSymbol = 'RewardT';
  const initSupply = ethers.utils.parseEther('1000');
  const rewardToken: ERC20Mock = await deployContract('contracts/mocks/ERC20Mock.sol:ERC20Mock', [
    tokenName,
    tokenSymbol,
    initSupply,
  ]);

  const rewardMultiplier = ethers.utils.parseEther('1');
  const rewarder: RewarderMock = await deployContract('contracts/mocks/RewarderMock.sol:RewarderMock', [
    rewardMultiplier,
    rewardToken.address,
    masterChef,
  ]);

  return [rewardToken, rewarder];
};
