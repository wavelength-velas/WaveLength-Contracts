import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';

import { ERC20Mock } from '../typechain-types/contracts/mocks/ERC20Mock.sol';
import { WAVEToken } from '../typechain-types/contracts/WAVEToken';
import { WAVEMasterChef } from '../typechain-types/contracts/WAVEMasterChef.sol/WAVEMasterChef';
import { RewarderMock } from '../typechain-types/contracts/mocks/RewarderMock.sol/RewarderMock';
import { Ve } from '../typechain-types/contracts/veWAVE.sol/Ve';
import { WaveEmissionDistributor } from '../typechain-types/contracts/EmissionDistributor.sol/WaveEmissionDistributor';
import {
  initEmissionDistributor,
  initRewarder,
  duration,
  advanceBlocks,
  deployERC20Mock,
  advanceTime,
} from './utilities';

describe('Rewarder Test', () => {
  let testToken1: ERC20Mock;
  let testToken2: ERC20Mock;
  let rewardToken: ERC20Mock;
  let waveToken: WAVEToken;
  let masterChef: WAVEMasterChef;
  let rewarder: RewarderMock;
  let veWave: Ve;
  let emissionDistributor: WaveEmissionDistributor;
  let owner: SignerWithAddress;
  let treasury: SignerWithAddress;
  let user1: SignerWithAddress;
  let user2: SignerWithAddress;

  beforeEach(async () => {
    [owner, treasury, user1, user2] = await ethers.getSigners();

    testToken1 = await deployERC20Mock('Test1', 'T1', 1000);
    testToken2 = await deployERC20Mock('Test2', 'T2', 1000);

    [waveToken, masterChef, veWave, , emissionDistributor] = await initEmissionDistributor(owner, treasury);

    [rewardToken, rewarder] = await initRewarder(masterChef.address);

    await testToken1.transfer(user1.address, ethers.utils.parseEther('5'));
    await testToken2.transfer(user1.address, ethers.utils.parseEther('5'));

    await waveToken.transfer(user1.address, ethers.utils.parseEther('5'));
    await waveToken.transfer(user2.address, ethers.utils.parseEther('5'));

    await emissionDistributor.add(ethers.utils.parseEther('1'));
    await emissionDistributor.addAnotherToken(
      rewardToken.address,
      ethers.utils.parseEther('1'),
      false,
      ethers.utils.parseEther('1'),
    );
    await emissionDistributor.updateEmissionRate(ethers.utils.parseEther('1'));

    await masterChef.add(200, emissionDistributor.address, rewarder.address);
    await masterChef.add(300, testToken1.address, rewarder.address);
    await masterChef.add(400, testToken2.address, rewarder.address);

    await testToken1.connect(user1).approve(masterChef.address, ethers.utils.parseEther('1'));
    await testToken2.connect(user1).approve(masterChef.address, ethers.utils.parseEther('1'));
    await masterChef.connect(user1).deposit(1, ethers.utils.parseEther('1'), user1.address);
    await masterChef.connect(user1).deposit(2, ethers.utils.parseEther('1'), user1.address);
  });

  describe('Confirm rewards with amount', () => {
    const user1TokenId = 1;
    const user2TokenId = 2;

    beforeEach(async () => {
      const lockTime = duration.weeks('2');
      // User1 staking
      const user1Staking = ethers.utils.parseEther('2');
      await waveToken.connect(user1).approve(veWave.address, user1Staking);
      await veWave.connect(user1).create_lock(user1Staking, lockTime);
      await veWave.connect(user1).approve(emissionDistributor.address, user1TokenId);
      await emissionDistributor.connect(user1).depositToChef(0, user1TokenId);
      // User2 staking
      const user2Staking = ethers.utils.parseEther('1');
      await waveToken.connect(user2).approve(veWave.address, user2Staking);
      await veWave.connect(user2).create_lock(user2Staking, lockTime);
      await veWave.connect(user2).approve(emissionDistributor.address, user2TokenId);
      await emissionDistributor.connect(user2).depositToChef(0, user2TokenId);
    });

    it("User1's staking amount is bigger than User2's", async () => {
      await advanceBlocks(10);
      const beforeUser1 = await waveToken.balanceOf(user1.address);
      const beforeUser2 = await waveToken.balanceOf(user2.address);
      await emissionDistributor.connect(user1).harvestAndDistribute(0, user1TokenId);
      const user1Reward = (await waveToken.balanceOf(user1.address)).sub(beforeUser1);
      await emissionDistributor.connect(user2).harvestAndDistribute(0, user2TokenId);
      const user2Reward = (await waveToken.balanceOf(user2.address)).sub(beforeUser2);
      expect(user1Reward).to.gt(user2Reward); // 5 > 1
    });
  });

  describe('Confirm rewards with time', () => {
    const user1TokenId = 1;
    const user2TokenId = 2;

    beforeEach(async () => {
      const stakingAmount = ethers.utils.parseEther('1');
      // User1 staking
      const user1LockTime = duration.weeks('4');
      await waveToken.connect(user1).approve(veWave.address, stakingAmount);
      await veWave.connect(user1).create_lock(stakingAmount, user1LockTime);
      await veWave.connect(user1).approve(emissionDistributor.address, user1TokenId);
      await emissionDistributor.connect(user1).depositToChef(0, user1TokenId);
      // // User2 staking
      const user2LockTime = duration.weeks('2');
      await waveToken.connect(user2).approve(veWave.address, stakingAmount);
      await veWave.connect(user2).create_lock(stakingAmount, user2LockTime);
      await veWave.connect(user2).approve(emissionDistributor.address, user2TokenId);
      await emissionDistributor.connect(user2).depositToChef(0, user2TokenId);
    });

    it("User1's lock time is longer than User2's", async () => {
      await advanceTime(duration.weeks('6').toNumber());
      const beforeUser1 = await waveToken.balanceOf(user1.address);
      const beforeUser2 = await waveToken.balanceOf(user2.address);
      await emissionDistributor.connect(user1).harvestAndDistribute(0, user1TokenId);
      const user1Reward = (await waveToken.balanceOf(user1.address)).sub(beforeUser1);
      await emissionDistributor.connect(user2).harvestAndDistribute(0, user2TokenId);
      const user2Reward = (await waveToken.balanceOf(user2.address)).sub(beforeUser2);
      expect(user1Reward).to.gt(user2Reward); // 5 > 1
    });
  });
});
