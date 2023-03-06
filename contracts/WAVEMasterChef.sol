// SPDX-License-Identifier: MIT
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./WAVEToken.sol";

interface IRewarder {
    function onWAVEReward(
        uint256 pid,
        address user,
        address recipient,
        uint256 waveAmount,
        uint256 newLpAmount
    ) external;

    function pendingTokens(
        uint256 pid,
        address user,
        uint256 waveAmount
    ) external view returns (IERC20[] memory, uint256[] memory);
}

/*
    This master chef is based on SUSHI's version with some adjustments:
     - Upgrade to pragma 0.8.7
     - therefore remove usage of SafeMath (built in overflow check for solidity > 8)
     - Merge sushi's master chef V1 & V2 (no usage of dummy pool)
     - remove withdraw function (without harvest) => requires the rewardDebt to be an signed int instead of uint which requires a lot of casting and has no real usecase for us
     - no dev emissions, but treasury emissions instead
     - treasury percentage is subtracted from emissions instead of added on top
     - update of emission rate with upper limit of 6 WAVE/block
     - more require checks in general
*/
contract WAVEMasterChef is Ownable {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of WAVE
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accWAVEPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accWAVEPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }
    // Info of each pool.
    struct PoolInfo {
        // we have a fixed number of WAVE tokens released per block, each pool gets his fraction based on the allocPoint
        uint256 allocPoint; // How many allocation points assigned to this pool. the fraction WAVE to distribute per block.
        uint256 lastRewardBlock; // Last block number that WAVE distribution occurs.
        uint256 accWAVEPerShare; // Accumulated WAVE per LP share. this is multiplied by ACC_WAVE_PRECISION for more exact results (rounding errors)
    }
    // The WAVE TOKEN!
    WAVEToken public wave;

    // Treasury address.
    address public treasuryAddress;

    // WAVE tokens created per block.
    uint256 public wavePerBlock;

    uint256 private constant ACC_WAVE_PRECISION = 1e12;

    // distribution percentages: a value of 1000 = 100%
    // 12.8% percentage of pool rewards that goes to the treasury.
    uint256 public constant TREASURY_PERCENTAGE = 124;

    // 87.2% percentage of pool rewards that goes to LP holders.
    uint256 public constant POOL_PERCENTAGE = 876;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens per pool. poolId => address => userInfo
    /// @notice Address of the LP token for each MCV pool.
    IERC20[] public lpTokens;

    EnumerableSet.AddressSet private lpTokenAddresses;

    /// @notice Address of each `IRewarder` contract in MCV.
    IRewarder[] public rewarder;

    mapping(uint256 => mapping(address => UserInfo)) public userInfo; // mapping form poolId => user Address => User Info
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when WAVE mining starts.
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event LogPoolAddition(uint256 indexed pid, uint256 allocPoint, IERC20 indexed lpToken, IRewarder indexed rewarder);
    event LogSetPool(uint256 indexed pid, uint256 allocPoint, IRewarder indexed rewarder, bool overwrite);
    event LogUpdatePool(uint256 indexed pid, uint256 lastRewardBlock, uint256 lpSupply, uint256 accWAVEPerShare);
    event SetTreasuryAddress(address indexed oldAddress, address indexed newAddress);
    event UpdateEmissionRate(address indexed user, uint256 _wavePerSec);

    constructor(
        WAVEToken _wave,
        address _treasuryAddress,
        uint256 _wavePerBlock,
        uint256 _startBlock
    ) {
        require(_wavePerBlock <= 6e18, "maximum emission rate of 6 wave per block exceeded");
        wave = _wave;
        treasuryAddress = _treasuryAddress;
        wavePerBlock = _wavePerBlock;
        startBlock = _startBlock;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        IRewarder _rewarder
    ) public onlyOwner {
        require(Address.isContract(address(_lpToken)), "add: LP token must be a valid contract");
        require(
            Address.isContract(address(_rewarder)) || address(_rewarder) == address(0),
            "add: rewarder must be contract or zero"
        );
        // we make sure the same LP cannot be added twice which would cause trouble
        require(!lpTokenAddresses.contains(address(_lpToken)), "add: LP already added");

        // respect startBlock!
        uint256 lastRewardBlock = block.timestamp > startBlock ? block.timestamp : startBlock;
        totalAllocPoint = totalAllocPoint + _allocPoint;

        // LP tokens, rewarders & pools are always on the same index which translates into the pid
        lpTokens.push(_lpToken);
        lpTokenAddresses.add(address(_lpToken));
        rewarder.push(_rewarder);

        poolInfo.push(PoolInfo({ allocPoint: _allocPoint, lastRewardBlock: lastRewardBlock, accWAVEPerShare: 0 }));
        emit LogPoolAddition(lpTokens.length - 1, _allocPoint, _lpToken, _rewarder);
    }

    // Update the given pool's WAVE allocation point. Can only be called by the owner.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _allocPoint New AP of the pool.
    /// @param _rewarder Address of the rewarder delegate.
    /// @param overwrite True if _rewarder should be `set`. Otherwise `_rewarder` is ignored.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        IRewarder _rewarder,
        bool overwrite
    ) public onlyOwner {
        require(
            Address.isContract(address(_rewarder)) || address(_rewarder) == address(0),
            "set: rewarder must be contract or zero"
        );

        // we re-adjust the total allocation points
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;

        poolInfo[_pid].allocPoint = _allocPoint;

        if (overwrite) {
            rewarder[_pid] = _rewarder;
        }
        emit LogSetPool(_pid, _allocPoint, overwrite ? _rewarder : rewarder[_pid], overwrite);
    }

    // View function to see pending WAVE on frontend.
    function pendingWAVE(uint256 _pid, address _user) external view returns (uint256 pending) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        // how many WAVE per lp token
        uint256 accWAVEPerShare = pool.accWAVEPerShare;
        // total staked lp tokens in this pool
        uint256 lpSupply = lpTokens[_pid].balanceOf(address(this));

        if (block.timestamp > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blocksSinceLastReward = block.timestamp - pool.lastRewardBlock;
            // based on the pool weight (allocation points) we calculate the wave rewarded for this specific pool
            uint256 waveRewards = (blocksSinceLastReward * wavePerBlock * pool.allocPoint) / totalAllocPoint;

            // we take parts of the rewards for treasury, these can be subject to change, so we recalculate it
            // a value of 1000 = 100%
            uint256 waveRewardsForPool = (waveRewards * POOL_PERCENTAGE) / 1000;

            // we calculate the new amount of accumulated wave per LP token
            accWAVEPerShare = accWAVEPerShare + ((waveRewardsForPool * ACC_WAVE_PRECISION) / lpSupply);
        }
        // based on the number of LP tokens the user owns, we calculate the pending amount by subtracting the amount
        // which he is not eligible for (joined the pool later) or has already harvested
        pending = (user.amount * accWAVEPerShare) / ACC_WAVE_PRECISION - user.rewardDebt;
    }

    /// @notice Update reward variables for all pools. Be careful of gas spending!
    /// @param pids Pool IDs of all to be updated. Make sure to update all active pools.
    function massUpdatePools(uint256[] calldata pids) external {
        uint256 len = pids.length;
        for (uint256 i = 0; i < len; ++i) {
            updatePool(pids[i]);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public returns (PoolInfo memory pool) {
        pool = poolInfo[_pid];

        if (block.timestamp > pool.lastRewardBlock) {
            // total lp tokens staked for this pool
            uint256 lpSupply = lpTokens[_pid].balanceOf(address(this));
            if (lpSupply > 0) {
                uint256 blocksSinceLastReward = block.timestamp - pool.lastRewardBlock;

                // rewards for this pool based on his allocation points
                uint256 waveRewards = (blocksSinceLastReward * wavePerBlock * pool.allocPoint) / totalAllocPoint;

                uint256 waveRewardsForPool = (waveRewards * POOL_PERCENTAGE) / 1000;

                wave.mint(treasuryAddress, (waveRewards * TREASURY_PERCENTAGE) / 1000);

                wave.mint(address(this), waveRewardsForPool);

                pool.accWAVEPerShare = pool.accWAVEPerShare + ((waveRewardsForPool * ACC_WAVE_PRECISION) / lpSupply);
            }
            pool.lastRewardBlock = block.timestamp;
            poolInfo[_pid] = pool;

            emit LogUpdatePool(_pid, pool.lastRewardBlock, lpSupply, pool.accWAVEPerShare);
        }
    }

    // Deposit LP tokens to MasterChef for WAVE allocation.
    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) public {
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][_to];

        user.amount = user.amount + _amount;
        // since we add more LP tokens, we have to keep track of the rewards he is not eligible for
        // if we would not do that, he would get rewards like he added them since the beginning of this pool
        // note that only the accWAVEPerShare have the precision applied
        user.rewardDebt = user.rewardDebt + (_amount * pool.accWAVEPerShare) / ACC_WAVE_PRECISION;

        IRewarder _rewarder = rewarder[_pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onWAVEReward(_pid, _to, _to, 0, user.amount);
        }

        lpTokens[_pid].safeTransferFrom(msg.sender, address(this), _amount);

        emit Deposit(msg.sender, _pid, _amount, _to);
    }

    function harvestAll(uint256[] calldata _pids, address _to) external {
        for (uint256 i = 0; i < _pids.length; i++) {
            if (userInfo[_pids[i]][msg.sender].amount > 0) {
                harvest(_pids[i], _to);
            }
        }
    }

    /// @notice Harvest proceeds for transaction sender to `_to`.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _to Receiver of WAVE rewards.
    function harvest(uint256 _pid, address _to) public {
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];

        // this would  be the amount if the user joined right from the start of the farm
        uint256 accumulatedWAVE = (user.amount * pool.accWAVEPerShare) / ACC_WAVE_PRECISION;
        // subtracting the rewards the user is not eligible for
        uint256 eligibleWAVE = accumulatedWAVE - user.rewardDebt;

        // we set the new rewardDebt to the current accumulated amount of rewards for his amount of LP token
        user.rewardDebt = accumulatedWAVE;

        if (eligibleWAVE > 0) {
            safeWAVETransfer(_to, eligibleWAVE);
        }

        IRewarder _rewarder = rewarder[_pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onWAVEReward(_pid, msg.sender, _to, eligibleWAVE, user.amount);
        }

        emit Harvest(msg.sender, _pid, eligibleWAVE);
    }

    /// @notice Withdraw LP tokens from MCV and harvest proceeds for transaction sender to `_to`.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _amount LP token amount to withdraw.
    /// @param _to Receiver of the LP tokens and WAVE rewards.
    function withdrawAndHarvest(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) public {
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(_amount <= user.amount, "cannot withdraw more than deposited");

        // this would  be the amount if the user joined right from the start of the farm
        uint256 accumulatedWAVE = (user.amount * pool.accWAVEPerShare) / ACC_WAVE_PRECISION;
        // subtracting the rewards the user is not eligible for
        uint256 eligibleWAVE = accumulatedWAVE - user.rewardDebt;

        /*
            after harvest & withdraw, he should be eligible for exactly 0 tokens
            => userInfo.amount * pool.accWAVEPerShare / ACC_WAVE_PRECISION == userInfo.rewardDebt
            since we are removing some LP's from userInfo.amount, we also have to remove
            the equivalent amount of reward debt
        */

        user.rewardDebt = accumulatedWAVE - (_amount * pool.accWAVEPerShare) / ACC_WAVE_PRECISION;
        user.amount = user.amount - _amount;

        safeWAVETransfer(_to, eligibleWAVE);

        IRewarder _rewarder = rewarder[_pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onWAVEReward(_pid, msg.sender, _to, eligibleWAVE, user.amount);
        }

        lpTokens[_pid].safeTransfer(_to, _amount);

        emit Withdraw(msg.sender, _pid, _amount, _to);
        emit Harvest(msg.sender, _pid, eligibleWAVE);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid, address _to) public {
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        IRewarder _rewarder = rewarder[_pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onWAVEReward(_pid, msg.sender, _to, 0, 0);
        }

        // Note: transfer can fail or succeed if `amount` is zero.
        lpTokens[_pid].safeTransfer(_to, amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount, _to);
    }

    // Safe WAVE transfer function, just in case if rounding error causes pool to not have enough WAVE.
    function safeWAVETransfer(address _to, uint256 _amount) internal {
        uint256 waveBalance = wave.balanceOf(address(this));
        if (_amount > waveBalance) {
            wave.transfer(_to, waveBalance);
        } else {
            wave.transfer(_to, _amount);
        }
    }

    // Update treasury address by the owner.
    function treasury(address _treasuryAddress) public onlyOwner {
        treasuryAddress = _treasuryAddress;
        emit SetTreasuryAddress(treasuryAddress, _treasuryAddress);
    }

    function updateEmissionRate(uint256 _wavePerBlock) public onlyOwner {
        require(_wavePerBlock <= 6e18, "maximum emission rate of 6 wave per block exceeded");
        wavePerBlock = _wavePerBlock;
        emit UpdateEmissionRate(msg.sender, _wavePerBlock);
    }
}
