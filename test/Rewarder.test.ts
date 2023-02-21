import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { BigNumber } from 'ethers';
import { expect } from 'chai';

import { deployContract, duration, advanceTimeAndBlock, getBlockTime, advanceBlocks } from './utilities';
import { ERC20Mock } from '../typechain-types/mocks/ERC20Mock.sol';
import { WAVEToken } from '../typechain-types/WAVEToken.sol/WAVEToken';
import { WAVEMasterChef } from '../typechain-types/WAVEMasterChef.sol/WAVEMasterChef';
import { RewarderMock } from '../typechain-types/mocks/RewarderMock.sol/RewarderMock';
import { Ve } from '../typechain-types/veWAVE.sol/Ve';
import { VeWAVEReceipt } from '../typechain-types/veWAVEReceipt.sol/VeWAVEReceipt';
import { WaveEmissionDistributor } from '../typechain-types/EmissionDistributor.sol/WaveEmissionDistributor';

describe('Rewarder Test', () => {
  let testToken1: ERC20Mock;
  let testToken2: ERC20Mock;
  let rewardToken: ERC20Mock;
  let waveToken: WAVEToken;
  let masterChef: WAVEMasterChef;
  let rewarder: RewarderMock;
  let veWave: Ve;
  let waveReceipt: VeWAVEReceipt;
  let emissionDistributor: WaveEmissionDistributor;
  let owner: SignerWithAddress;
  let treasury: SignerWithAddress;
  let user1: SignerWithAddress;
  let user2: SignerWithAddress;

  before(async () => {
    [owner, treasury, user1, user2] = await ethers.getSigners();

    testToken1 = await deployContract('contracts/mocks/ERC20Mock.sol:ERC20Mock', [
      'Test1',
      'T1',
      ethers.utils.parseEther('20'),
    ]);
    testToken2 = await deployContract('contracts/mocks/ERC20Mock.sol:ERC20Mock', [
      'Test2',
      'T2',
      ethers.utils.parseEther('10'),
    ]);
    rewardToken = await deployContract('contracts/mocks/ERC20Mock.sol:ERC20Mock', [
      'Reward Token',
      'RewardT',
      ethers.utils.parseEther('0'),
    ]);

    await testToken1.transfer(user1.address, ethers.utils.parseEther('5'));
    await testToken2.transfer(user1.address, ethers.utils.parseEther('5'));

    waveToken = await deployContract('contracts/EmissionDistributor.sol:WAVEToken', []);
    await waveToken.mint(owner.address, ethers.utils.parseEther('10'));
    await waveToken.transfer(user1.address, ethers.utils.parseEther('5'));
    await waveToken.transfer(user2.address, ethers.utils.parseEther('5'));

    masterChef = await deployContract('contracts/WAVEMasterChef.sol:WAVEMasterChef', [
      waveToken.address,
      treasury.address,
      ethers.utils.parseEther('1'),
      1,
    ]);
    await waveToken.transferOwnership(masterChef.address);

    rewarder = await deployContract('contracts/mocks/RewarderMock.sol:RewarderMock', [
      ethers.utils.parseEther('1'),
      rewardToken.address,
      masterChef.address,
    ]);

    veWave = await deployContract('contracts/veWAVE.sol:ve', [waveToken.address]);

    waveReceipt = await deployContract('contracts/veWAVEReceipt.sol:veWAVEReceipt', []);

    emissionDistributor = await deployContract('contracts/EmissionDistributor.sol:WaveEmissionDistributor', [
      veWave.address,
      waveToken.address,
      masterChef.address,
      0,
      waveReceipt.address,
    ]);
    await waveReceipt.transferOwnership(emissionDistributor.address);

    await emissionDistributor.add(ethers.utils.parseEther('1'));
    await emissionDistributor.addAnotherToken(
      rewardToken.address,
      ethers.utils.parseEther('1'),
      false,
      ethers.utils.parseEther('1'),
    );
    await emissionDistributor.updateEmissionRate(ethers.utils.parseEther('1'));
  });

  it('Add 3 pools', async () => {
    await masterChef.add(200, emissionDistributor.address, rewarder.address);
    await masterChef.add(300, testToken1.address, rewarder.address);
    await masterChef.add(400, testToken2.address, rewarder.address);
  });

  it('User1 deposits to pools on WAVEMasterChef', async () => {
    await testToken1.connect(user1).approve(masterChef.address, ethers.utils.parseEther('1'));
    await testToken2.connect(user1).approve(masterChef.address, ethers.utils.parseEther('1'));
    await masterChef.connect(user1).deposit(1, ethers.utils.parseEther('1'), user1.address);
    await masterChef.connect(user1).deposit(2, ethers.utils.parseEther('1'), user1.address);
  });

  it('User1 and User2 stake on emissiondistributor', async () => {
    // User1 staking
    await waveToken.connect(user1).approve(veWave.address, ethers.utils.parseEther('5'));
    await veWave.connect(user1).create_lock(ethers.utils.parseEther('5'), duration.weeks('2'));
    await veWave.connect(user1).approve(emissionDistributor.address, 1);
    await emissionDistributor.connect(user1).depositToChef(0, 1);
    // User2 staking
    await waveToken.connect(user2).approve(veWave.address, ethers.utils.parseEther('1'));
    await veWave.connect(user2).create_lock(ethers.utils.parseEther('1'), duration.weeks('2'));
    await veWave.connect(user2).approve(emissionDistributor.address, 2);
    await emissionDistributor.connect(user2).depositToChef(0, 2);
  });

  it('Confirm rewards', async () => {
    await advanceBlocks(10);
    const beforeUser1 = await waveToken.balanceOf(user1.address);
    const beforeUser2 = await waveToken.balanceOf(user2.address);
    await emissionDistributor.connect(user1).harvestAndDistribute(0, 1);
    const user1Reward = (await waveToken.balanceOf(user1.address)).sub(beforeUser1);
    await emissionDistributor.connect(user2).harvestAndDistribute(0, 2);
    const user2Reward = (await waveToken.balanceOf(user2.address)).sub(beforeUser2);
    expect(user1Reward).to.gt(user2Reward); // 5 > 1
  })
});
