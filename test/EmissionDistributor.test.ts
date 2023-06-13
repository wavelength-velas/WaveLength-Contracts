import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { BigNumber } from 'ethers';
import { expect } from 'chai';

import { WAVEToken } from '../typechain-types/contracts/WAVEToken';
import { WAVEMasterChef } from '../typechain-types/contracts/WAVEMasterChef.sol/WAVEMasterChef';
import { Ve } from '../typechain-types/contracts/veWAVE.sol/Ve';
import { WaveEmissionDistributor } from '../typechain-types/contracts/WaveEmissionDistributor';
import { RewarderMock } from '../typechain-types/contracts/mocks/RewarderMock.sol/RewarderMock';
import { ERC20Mock } from '../typechain-types/contracts/mocks/ERC20Mock.sol/ERC20Mock';
import { initEmissionDistributor, initRewarder, duration, advanceTime } from './utilities';
// import { VeWAVEReceipt } from '../typechain-types/contracts/VeWAVEReceipt';

describe('EmissionDistributor Test', () => {
  let waveToken: WAVEToken;
  let masterChef: WAVEMasterChef;
  let veWave: Ve;
  let emissionDistributor: WaveEmissionDistributor;
  let rewarder: RewarderMock;
  // let waveReceipt: VeWAVEReceipt;
  let rewardToken: ERC20Mock;
  let owner: SignerWithAddress;
  let treasury: SignerWithAddress;

  before(async () => {
    [owner, treasury] = await ethers.getSigners();

    [waveToken, masterChef, veWave, , emissionDistributor] = await initEmissionDistributor(owner, treasury);

    [rewardToken, rewarder] = await initRewarder(masterChef.address);

    await emissionDistributor.updateEmissionRate(ethers.utils.parseEther('0.001'));
    await waveToken.transfer(emissionDistributor.address, ethers.utils.parseEther('1'));
    // await rewardToken.transfer(emissionDistributor.address, ethers.utils.parseEther('1'));
  });

  it('create lock on veWave', async () => {
    const waveTokenAmount = ethers.utils.parseEther('1');

    await waveToken.approve(veWave.address, waveTokenAmount);
    await veWave.create_lock(waveTokenAmount, duration.weeks('2'));
  });

  it('add pool with lp address(emissiondistributor) and rewarder address(zero)', async () => {
    const allocPoint = ethers.utils.parseEther('1');
    await expect(
      masterChef.connect(treasury).add(allocPoint, emissionDistributor.address, rewarder.address),
    ).to.be.revertedWith('Ownable: caller is not the owner');
    await expect(masterChef.add(allocPoint, treasury.address, rewarder.address)).to.be.revertedWith(
      'add: LP token must be a valid contract',
    );
    await expect(masterChef.add(allocPoint, emissionDistributor.address, treasury.address)).to.be.revertedWith(
      'add: rewarder must be contract or zero',
    );

    await masterChef.add(allocPoint, emissionDistributor.address, rewarder.address);
    expect(await masterChef.rewarder(0)).to.equal(rewarder.address);
    expect(await masterChef.lpTokens(0)).to.equal(emissionDistributor.address);
    const poolInfo = await masterChef.poolInfo(0);
    expect(poolInfo.allocPoint).to.equal(allocPoint);

    await expect(masterChef.add(allocPoint, emissionDistributor.address, rewarder.address)).to.be.revertedWith(
      'add: LP already added',
    );
  });

  it('set farmId on emissiondistributor', async () => {
    await expect(emissionDistributor.connect(treasury).setFarmId(0)).to.be.revertedWith(
      'Ownable: caller is not the owner',
    );
    const farmId = BigNumber.from(0);
    await emissionDistributor.setFarmId(farmId);
    expect(await emissionDistributor.farmPid()).to.equal(farmId);
  });

  it('add main pool to emissiondistributor', async () => {
    const anotherTokenPerBlock = ethers.utils.parseEther('1');
    const allocPoint = ethers.utils.parseEther('1');
    await expect(
      emissionDistributor
        .connect(treasury)
        .add(allocPoint, rewardToken.address, ethers.utils.parseEther('1'), false, ethers.utils.parseEther('1')),
    ).to.be.revertedWith('Ownable: caller is not the owner');

    await emissionDistributor.add(
      allocPoint,
      rewardToken.address,
      ethers.utils.parseEther('1'),
      false,
      ethers.utils.parseEther('1'),
    );
    const poolInfo = await emissionDistributor.poolInfo(0);
    expect(poolInfo.allocPoint).to.equal(allocPoint);
    expect(await emissionDistributor.totalPidsAnotherToken()).to.equal(1);
    const poolInfoAnotherToken = await emissionDistributor.poolInfoAnotherToken(0);
    expect(poolInfoAnotherToken.tokenReward).to.equal(rewardToken.address);
    expect(poolInfoAnotherToken.anotherTokenPerBlock).to.equal(anotherTokenPerBlock);
    expect(poolInfoAnotherToken.isClosed).to.false;
    expect(poolInfoAnotherToken.allocPoint).to.equal(allocPoint);
    expect(poolInfoAnotherToken.accAnotherTokenPerShare).to.equal(0);
  });

  it('approve vewave token', async () => {
    await veWave.approve(emissionDistributor.address, 1);
    expect(await veWave.isApprovedOrOwner(emissionDistributor.address, 1)).to.true;
  });

  it('depositToChef on EmissionDistributor', async () => {
    await rewardToken.approve(emissionDistributor.address, ethers.utils.parseEther('1'));
    expect(await emissionDistributor.depositToChef(0, 1))
      .to.emit(emissionDistributor, 'Deposit')
      .withArgs(owner.address, 0, 1, owner.address);
    expect(await veWave.balanceOf(emissionDistributor.address)).to.equal(1);
    const tokenInfo = await emissionDistributor.tokenInfo(0);
    expect(tokenInfo.user).to.equal(owner.address);
    expect(tokenInfo.numberNFT).to.equal(1);
  });

  it('harvestAndDistribute on EmissionDistributor', async () => {
    await advanceTime(duration.weeks('3').toNumber());
    const before = await waveToken.balanceOf(owner.address);
    expect(await emissionDistributor.harvestAndDistribute(0, 1)).to.emit(emissionDistributor, 'Harvest');
    expect(await waveToken.balanceOf(owner.address)).to.gt(before);
  });

  it('harvestAndDistributeAnotherToken on EmissionDistributor', async () => {
    await advanceTime(duration.weeks('3').toNumber());
    const before = await rewardToken.balanceOf(owner.address);
    expect(await emissionDistributor.harvestAndDistributeAnotherToken(0, 1)).to.emit(
      emissionDistributor,
      'HarvestAnotherToken',
    );
    expect(await rewardToken.balanceOf(owner.address)).to.gt(before);
  });

  it('emergencyWithdraw on EmissionDistributor', async () => {
    await expect(emissionDistributor.connect(treasury).emergencyWithdraw(0, 1)).to.be.revertedWith('BAL#706');
  });

  it('withdrawAndHarvest on EmissionDistributor', async () => {
    expect(await veWave.balanceOf(owner.address)).to.be.equal(0);
    expect(await veWave.balanceOf(emissionDistributor.address)).to.be.equal(1);
    await expect(emissionDistributor.withdrawAndDistribute(1, 1)).to.be.revertedWith('BAL#706');
    expect(await emissionDistributor.withdrawAndDistribute(0, 1)).to.emit(emissionDistributor, 'Withdraw');
    expect(await veWave.balanceOf(owner.address)).to.be.equal(1);
    expect(await veWave.balanceOf(emissionDistributor.address)).to.be.equal(0);
  });

  it('check reward when the poolAnotherToken is disabled', async () => {
    await emissionDistributor.setAnotherToken(
      0,
      rewardToken.address,
      ethers.utils.parseEther('1'),
      ethers.utils.parseEther('1'),
      true,
    );

    const waveTokenAmount = ethers.utils.parseEther('1');

    await waveToken.approve(veWave.address, waveTokenAmount);
    await veWave.create_lock(waveTokenAmount, duration.weeks('2'));
    await veWave.approve(emissionDistributor.address, 2);
    await emissionDistributor.depositToChef(0, 2);
    await advanceTime(duration.weeks('3').toNumber());
    const before = await rewardToken.balanceOf(owner.address);
    await emissionDistributor.harvestAndDistributeAnotherToken(0, 2);
    expect(await rewardToken.balanceOf(owner.address)).to.be.equal(before);
  });
});
