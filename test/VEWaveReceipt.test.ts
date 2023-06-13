import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';

import { REWARDReceiptMasterChef } from '../typechain-types/contracts/WaveReceiptMasterChef.sol/REWARDReceiptMasterChef';
import { WAVEToken } from '../typechain-types/contracts/WAVEToken';
import { WAVEMasterChef } from '../typechain-types/contracts/WAVEMasterChef.sol/WAVEMasterChef';
import { Ve } from '../typechain-types/contracts/veWAVE.sol/Ve';
import { WaveEmissionDistributor } from '../typechain-types/contracts/WaveEmissionDistributor';
import { RewarderMock } from '../typechain-types/contracts/mocks/RewarderMock.sol/RewarderMock';
import { ERC20Mock } from '../typechain-types/contracts/mocks/ERC20Mock.sol/ERC20Mock';
import { VeWAVEReceipt } from '../typechain-types/contracts/VeWAVEReceipt';
import {
  deployRewardReceiptChef,
  initEmissionDistributor,
  initRewarder,
  duration,
  // deployContract,
  advanceTime,
} from './utilities';

describe('veWaveReceipt Test', () => {
  let waveToken: WAVEToken;
  let masterChef: WAVEMasterChef;
  let veWave: Ve;
  let emissionDistributor: WaveEmissionDistributor;
  let rewarder: RewarderMock;
  let rewardToken: ERC20Mock;
  let veWaveReceiptMasterChef: REWARDReceiptMasterChef;
  let waveReceipt: VeWAVEReceipt;
  let owner: SignerWithAddress;
  let treasury: SignerWithAddress;

  before(async () => {
    [owner, treasury] = await ethers.getSigners();

    [waveToken, masterChef, veWave, waveReceipt, emissionDistributor] = await initEmissionDistributor(owner, treasury);

    [rewardToken, rewarder] = await initRewarder(masterChef.address);

    veWaveReceiptMasterChef = await deployRewardReceiptChef(rewardToken.address);
    await rewardToken.transfer(veWaveReceiptMasterChef.address, ethers.utils.parseEther('100'));
  });

  it('deposit VeWave on emissionDistributor', async () => {
    const waveTokenAmount = ethers.utils.parseEther('5');
    await waveToken.approve(veWave.address, waveTokenAmount);
    await veWave.create_lock(waveTokenAmount, duration.weeks('2'));

    await masterChef.add(200, emissionDistributor.address, rewarder.address);

    const allocPoint = ethers.utils.parseEther('1');
    const anotherPerBlock = ethers.utils.parseEther('1');
    await emissionDistributor.add(allocPoint, rewardToken.address, anotherPerBlock, false, allocPoint);

    await emissionDistributor.updateEmissionRate(ethers.utils.parseEther('1'));

    await veWave.approve(emissionDistributor.address, 1);
    await rewardToken.approve(emissionDistributor.address, ethers.utils.parseEther('5'));
    await emissionDistributor.depositToChef(0, 1);
  });

  it('stake waveReceipt token on WaveReceiptMasterChef', async () => {
    await veWaveReceiptMasterChef.add(200, waveReceipt.address);
    const depositAmount = await waveReceipt.balanceOf(owner.address);
    await waveReceipt.approve(veWaveReceiptMasterChef.address, depositAmount);
    await veWaveReceiptMasterChef.deposit(depositAmount, owner.address);
  });

  it('check reward', async () => {
    const before = await rewardToken.balanceOf(owner.address);
    await advanceTime(duration.weeks('4').toNumber());
    await veWaveReceiptMasterChef.harvest(0, owner.address);
    expect(await rewardToken.balanceOf(owner.address)).to.gt(before);
  });
});
