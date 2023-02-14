import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { BigNumber } from 'ethers';
import { expect } from 'chai';

import { WAVEToken } from '../typechain-types/WAVEToken.sol/WAVEToken';
import { WAVEMasterChef } from '../typechain-types/WAVEMasterChef.sol/WAVEMasterChef';
import { Ve } from '../typechain-types/veWAVE.sol/Ve';
import { VeWAVEReceipt } from '../typechain-types/veWAVEReceipt.sol/VeWAVEReceipt';
import { WaveEmissionDistributor } from '../typechain-types/EmissionDistributor.sol/WaveEmissionDistributor';
import { RewarderMock } from '../typechain-types/mocks/RewarderMock.sol/RewarderMock';
import { ERC20Mock } from '../typechain-types/mocks/ERC20Mock.sol/ERC20Mock';
import { deployContract, duration } from './utilities';

describe('EmissionDistributor Test', () => {
  let waveToken: WAVEToken;
  let masterChef: WAVEMasterChef;
  let veWave: Ve;
  let waveReceipt: VeWAVEReceipt;
  let emissionDistributor: WaveEmissionDistributor;
  let rewarder: RewarderMock;
  let rewardToken: ERC20Mock;
  let owner: SignerWithAddress;
  let treasury: SignerWithAddress;

  before(async () => {
    [owner, treasury] = await ethers.getSigners();

    waveToken = await deployContract('contracts/EmissionDistributor.sol:WAVEToken', []);
    await waveToken.mint(owner.address, ethers.utils.parseEther('10'));

    masterChef = await deployContract('contracts/WAVEMasterChef.sol:WAVEMasterChef', [
      waveToken.address,
      treasury.address,
      ethers.utils.parseEther('1'),
      1,
    ]);
    await waveToken.transferOwnership(masterChef.address);

    veWave = await deployContract('contracts/veWAVE.sol:ve', [waveToken.address]);
    await waveToken.approve(veWave.address, ethers.utils.parseEther('5'));
    await veWave.create_lock(ethers.utils.parseEther('5'), duration.weeks('2'));

    waveReceipt = await deployContract('contracts/veWAVEReceipt.sol:veWAVEReceipt', []);

    emissionDistributor = await deployContract('contracts/EmissionDistributor.sol:WaveEmissionDistributor', [
      veWave.address,
      waveToken.address,
      masterChef.address,
      0,
      waveReceipt.address,
    ]);
    await waveReceipt.transferOwnership(emissionDistributor.address);

    rewardToken = await deployContract('contracts/mocks/ERC20Mock.sol:ERC20Mock', [
      'Reward',
      'RewardT',
      ethers.utils.parseEther('1000'),
    ]);

    rewarder = await deployContract('contracts/mocks/RewarderMock.sol:RewarderMock', [
      ethers.utils.parseEther('1'),
      rewardToken.address,
      masterChef.address,
    ]);
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
    const allocPoint = ethers.utils.parseEther('1');
    await expect(emissionDistributor.connect(treasury).add(allocPoint)).to.be.revertedWith(
      'Ownable: caller is not the owner',
    );

    expect(await emissionDistributor.add(allocPoint))
      .to.be.emit(emissionDistributor, 'LogPoolAddition')
      .withArgs(0, allocPoint);
    const poolInfo = await emissionDistributor.poolInfo(0);
    expect(poolInfo.allocPoint).to.equal(allocPoint);
  });

  it('add another pool to emissiondistributor', async () => {
    const anotherTokenPerBlock = ethers.utils.parseEther('1');
    const allocPoint = ethers.utils.parseEther('1');
    await expect(
      emissionDistributor
        .connect(treasury)
        .addAnotherToken(rewardToken.address, anotherTokenPerBlock, false, allocPoint),
    ).to.be.revertedWith('Ownable: caller is not the owner');

    expect(
      await emissionDistributor.addAnotherToken(
        rewardToken.address,
        ethers.utils.parseEther('1'),
        false,
        ethers.utils.parseEther('1'),
      ),
    )
      .to.be.emit(emissionDistributor, 'LogPoolAnotherTokenAddition')
      .withArgs(0, rewardToken.address, false, allocPoint);
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
    expect(await emissionDistributor.depositToChef(0, 1))
      .to.emit(emissionDistributor, 'Deposit')
      .withArgs(owner.address, 0, 1, owner.address);
    expect(await veWave.balanceOf(emissionDistributor.address)).to.equal(1);
    const tokenInfo = await emissionDistributor.tokenInfo(0);
    expect(tokenInfo.user).to.equal(owner.address);
    expect(tokenInfo.numberNFT).to.equal(1);
  });

  it('harvestAndDistribute on EmissionDistributor', async () => {
    expect(await emissionDistributor.harvestAndDistribute(1)).to.emit(emissionDistributor, 'Harvest');
  });

  it('harvestAndDistributeAnotherToken on EmissionDistributor', async () => {
    expect(await emissionDistributor.harvestAndDistributeAnotherToken(0, 1)).to.emit(
      emissionDistributor,
      'HarvestAnotherToken',
    );
  });

  it('withdrawAndHarvest on EmissionDistributor', async () => {
    expect(await emissionDistributor.withdrawAndDistribute(0, 1)).to.emit(emissionDistributor, 'Withdraw');
  });
});
