// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./WAVEMasterChef.sol";
import "./veWAVE.sol";
import "./veWAVEReceipt.sol";

contract WaveEmissionDistributor is ERC20("VEWAVE EMISSION DISTRIBUTOR", "edveWAVE"), AccessControl, Ownable {
    using SafeERC20 for IERC20;

    // TokenInfo Struct
    struct TokenInfo {
        address user; // address from the owner of this veWave
        uint256 numberNFT; // TokenId veWave
        uint256 numberVeWaveReceiptTokens; // Number of dummy tokens owned by the user on this numberNFT
    }

    /******************** AnotherToken Structs ********************/
    struct UserInfo {
        uint256 amount; // How many WAVE locked by the user on veWAVE.
        uint256 rewardDebt; // WAVE Reward debt.
    }

    // Info of each pool.
    struct PoolInfo {
        uint256 allocPoint; // How many allocation points assigned to this pool. the fraction WAVE to distribute per block.
        uint256 lastRewardBlock; // Last block number that WAVE distribution occurs.
        uint256 accWAVEPerShare; // Accumulated WAVE per LP share. this is multiplied by ACC_WAVE_PRECISION for more exact results (rounding errors)
    }
    /****************************************************************/

    /******************** AnotherToken Structs **********************/
    struct PoolInfoAnotherToken {
        address tokenReward; // address from the Reward of this each Pool
        uint256 anotherTokenPerBlock; // How much AnotherTokens Per Block
        bool isClosed; // If this pool reward isClosed or not
        uint256 allocPoint; // How many allocation points assigned to this pool. the fraction AnotherToken to distribute per block.
        uint256 lastRewardBlock; // Last block number that AnotherToken distribution occurs.
        uint256 accAnotherTokenPerShare; // Accumulated WAVE per veWave. this is multiplied by ACC_ANOTHERTOKEN_PRECISION for more exact results (rounding errors)
    }

    struct UserInfoAnotherToken {
        uint256 amount; // How many WAVE locked by the user on veWAVE.
        uint256 rewardDebt; // AnotherToken Reward debt.
    }
    /****************************************************************/

    PoolInfoAnotherToken[] public poolInfoAnotherToken; // an array to store information of all pools of another token
    uint256 public totalPidsAnotherToken = 0; // total number of another token pools
    mapping(uint256 => mapping(address => mapping(uint256 => UserInfoAnotherToken))) public userInfoAnotherToken; // mapping form poolId => user Address => User Info

    PoolInfo[] public poolInfo; // an array to store information of all pools of WAVE
    TokenInfo[] public tokenInfo; // mapping form poolId => user Address => User Info
    mapping(address => mapping(uint256 => uint256)) public tokenInfoCheck; // mapping form poolId => user Address => User Info
    mapping(uint256 => mapping(address => mapping(uint256 => UserInfo))) public userInfo; // mapping form poolId => user Address => User Info

    uint256 public totalAmountLockedWave = 0; // total WAVE locked in pools
    uint256 public wavePerBlock; // WAVE distributed per block

    mapping(address => uint256[]) public tokenIdsByUser;

    mapping(address => uint256) public totalNftsByUser;

    uint256 private constant ACC_ANOTHERTOKEN_PRECISION = 1e12; // precision used for calculations involving another token
    uint256 private constant ACC_WAVE_PRECISION = 1e12; // Precision for accumulating WAVE
    uint256 public constant POOL_PERCENTAGE = 0.876e3; // Percentage of WAVE allocated to pools

    WAVEMasterChef public chef; // MasterChef contract for controlling distribution
    uint256 public farmPid; // ID for the farming pool
    uint256 public constant DENOMINATOR = 1e3; // Constant denominator for calculating allocation points

    IERC721 public veWave; // veWave ERC721 token
    IERC20 public wave; // WAVE ERC20 token
    IERC20 public veWaveReceipt; // veWave receipt token

    /* WAVE Rewards Events*/
    event LogSetPool(uint256 allocPoint);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event LogPoolAddition(uint256 indexed pid, uint256 allocPoint);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);

    /* AnotherToken Rewards Events*/
    event LogSetPoolAnotherToken(
        uint256 indexed pid,
        address indexed tokenReward,
        bool indexed isClosed,
        uint256 allocPoint
    );
    event LogPoolAnotherTokenAddition(
        uint256 indexed pid,
        address indexed tokenReward,
        bool indexed isClosed,
        uint256 allocPoint
    );
    event DepositAnotherToken(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event WithdrawAnotherToken(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event HarvestAnotherToken(address indexed user, uint256 indexed pid, uint256 amount);
    event LogUpdatePoolAnotherToken(
        uint256 indexed pid,
        uint256 lastRewardBlock,
        uint256 totalAmountLockedWave,
        uint256 accWAVEPerShare
    );

    /* General Events */
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        IERC721 _veWave, // veWave ERC721 token
        IERC20 _wave, // WAVE ERC20 token
        WAVEMasterChef _chef, // MasterChef contract for controlling distribution
        uint256 _farmPid, // ID for the farming pool
        IERC20 _veWaveReceipt // veWave receipt token
    ) {
        require(address(_veWave) != address(0), "invalid veWave's address");
        require(address(_wave) != address(0), "invalid wave's address");
        require(address(_chef) != address(0), "invalid master chef's address");
        veWave = _veWave;
        wave = _wave;
        chef = _chef;
        farmPid = _farmPid;
        veWaveReceipt = _veWaveReceipt;
    }

    function setFarmId(uint256 id) external onlyOwner {
        (uint256 amount, ) = chef.userInfo(farmPid, address(this));
        require(amount == 0, "In the now supported pool, the funds is still remaining");
        farmPid = id;
    }

    // Function to deposit veWAVE token to the contract and receive rewards
    function depositToChef(uint256 _pid, uint256 _tokenId) external {
        // Check if msg.sender is the owner of the veWAVE
        address ownerOfTokenId = IERC721(veWave).ownerOf(_tokenId);
        require(ownerOfTokenId == msg.sender, "You are not the owner of this veWAVE");

        // AnotherToken Rewards attributes
        PoolInfoAnotherToken memory poolAnotherToken = updatePoolAnotherToken(_pid);
        UserInfoAnotherToken storage userAnotherToken = userInfoAnotherToken[_pid][msg.sender][_tokenId];

        // Wave Rewards attributes
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender][_tokenId];

        totalNftsByUser[msg.sender] = totalNftsByUser[msg.sender] + 1;
        tokenIdsByUser[msg.sender].push(_tokenId);

        // Transfer the veWAVE token from the user to the contract
        ve(address(veWave)).transferFrom(msg.sender, address(this), _tokenId);
        uint256 amount = uint256(ve(address(veWave)).locking(_tokenId));

        /******************** AnotherToken Rewards Code ********************/
        // AnotherToken Rewards Code
        if (!poolAnotherToken.isClosed) {
            userAnotherToken.amount = userAnotherToken.amount + amount;
            userAnotherToken.rewardDebt =
                userAnotherToken.rewardDebt +
                (amount * poolAnotherToken.accAnotherTokenPerShare) /
                ACC_ANOTHERTOKEN_PRECISION;
        }
        /*******************************************************************/

        /******************** WAVE Rewards Code ********************/
        totalAmountLockedWave = totalAmountLockedWave + amount;
        _mint(address(this), amount); // mint
        _approve(address(this), address(chef), amount);
        chef.deposit(farmPid, amount, address(this));
        user.amount = user.amount + amount;
        user.rewardDebt = user.rewardDebt + (amount * pool.accWAVEPerShare) / ACC_WAVE_PRECISION;
        /*************************************************************/

        /******************** veWAVEReceipt Code ********************/
        // Mint the veWAVEReceipt token for the user based on the locked time of the veWAVE token
        uint256 timeDays = ve(address(veWave)).locked__end(_tokenId) - block.timestamp;
        uint256 mediumMint = timeDays + 86400;
        uint256 finalMint = (mediumMint * 10**18) / 31_556_926;

        veWAVEReceipt(address(veWaveReceipt)).mint(msg.sender, finalMint);

        // Take and write info about tokenInfo (user address & _numberNFT/tokenId
        tokenInfoCheck[msg.sender][_tokenId] = finalMint;

        /*************************************************************/
        // Push the tokenInfo to the tokenInfo array
        tokenInfo.push(TokenInfo({ user: msg.sender, numberNFT: _tokenId, numberVeWaveReceiptTokens: finalMint }));

        // Events
        // Emit events for deposit
        emit Deposit(msg.sender, 0, amount, msg.sender);
        emit DepositAnotherToken(msg.sender, _pid, amount, msg.sender);
    }

    function depositAnotherToken(uint256 _pid, uint256 _amount) external onlyOwner {
        require(_pid < totalPidsAnotherToken, "invalid pool id");
        PoolInfoAnotherToken storage poolAnotherToken = poolInfoAnotherToken[_pid];
        if (poolAnotherToken.isClosed == false) {
            IERC20(poolAnotherToken.tokenReward).transferFrom(msg.sender, address(this), _amount);
        }
    }

    function withdrawAndDistribute(uint256 _pid, uint256 _tokenId) external {
        uint256 numberVeWaveReceiptTokens = tokenInfoCheck[msg.sender][_tokenId];
        // Check if msg.sender have at least 1 veWAVEReceipt
        require(veWaveReceipt.balanceOf(msg.sender) >= numberVeWaveReceiptTokens, "You don't have any veWAVEReceipt");

        // AnotherToken Rewards attributes
        PoolInfoAnotherToken memory poolAnotherToken = updatePoolAnotherToken(_pid);
        UserInfoAnotherToken storage userAnotherToken = userInfoAnotherToken[_pid][msg.sender][_tokenId];

        // Wave Rewards attributes
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender][_tokenId];

        /******************** WAVE Rewards Code ********************/
        uint256 amount = uint256(ve(address(veWave)).locking(_tokenId)); // amount of locked WAVE on that veWAVE
        chef.withdrawAndHarvest(farmPid, amount, address(this)); // withdraw edveWAVE of MasterChef and harvest WAVE
        totalAmountLockedWave = totalAmountLockedWave - amount; // amount of lockedWave on the contract - amount of locked Wave of that veWAVE
        _burn(address(this), amount); // burn edveWAVE
        // this would  be the amount if the user joined right from the start of the farm
        uint256 accumulatedWAVE = (user.amount * pool.accWAVEPerShare) / ACC_WAVE_PRECISION;
        // subtracting the rewards the user is not eligible for
        uint256 eligibleWAVE = accumulatedWAVE - user.rewardDebt;
        user.amount = user.amount - amount; // put user amount of UserInfo a zero
        user.rewardDebt = (user.amount * pool.accWAVEPerShare) / ACC_WAVE_PRECISION; // update WAVE Reward Debt
        safeWAVETransfer(msg.sender, eligibleWAVE);
        /************************************************************/

        /******************** AnotherToken Rewards Code ********************/
        if (!poolAnotherToken.isClosed) {
            // this would  be the amount if the user joined right from the start of the farm
            uint256 accumulatedWAnotherToken = (userAnotherToken.amount * poolAnotherToken.accAnotherTokenPerShare) /
                ACC_ANOTHERTOKEN_PRECISION;
            // subtracting the rewards the user is not eligible for
            uint256 eligibleAnotherToken = accumulatedWAnotherToken - userAnotherToken.rewardDebt;
            userAnotherToken.amount = userAnotherToken.amount - amount; // put user amount of UserInfo a zero
            userAnotherToken.rewardDebt =
                (userAnotherToken.amount * poolAnotherToken.accAnotherTokenPerShare) /
                ACC_ANOTHERTOKEN_PRECISION; // update AnotherToken Reward Debt
            safeAnotherTokenTransfer(_pid, msg.sender, eligibleAnotherToken);
        }
        /********************************************************************/

        /******************** veWAVEReceipt Code ********************/
        veWAVEReceipt(address(veWaveReceipt)).burn(msg.sender, numberVeWaveReceiptTokens);
        /*************************************************************/

        /* Token Info delete data */
        tokenInfoCheck[msg.sender][_tokenId] = 0;
        /***********************/

        IERC721(veWave).safeTransferFrom(address(this), msg.sender, _tokenId); // transfer veWAVE to his owner

        uint256[] storage tokenIdsByCaller = tokenIdsByUser[msg.sender];
        for (uint256 i = 0; i < tokenIdsByCaller.length; ) {
            if (tokenIdsByCaller[i] == _tokenId) {
                delete tokenIdsByCaller[i];
                break;
            }
            unchecked {
                ++i;
            }
        }

        totalNftsByUser[msg.sender] = totalNftsByUser[msg.sender] - 1;

        // Events
        emit Withdraw(msg.sender, 0, amount, msg.sender);
        emit WithdrawAnotherToken(msg.sender, _pid, amount, msg.sender);
    }

    function harvestAndDistribute(uint256 _pid, uint256 _tokenId) public {
        uint256 numberVeWaveReceiptTokens = tokenInfoCheck[msg.sender][_tokenId];
        // Check if msg.sender have at least 1 veWAVEReceipt
        require(veWaveReceipt.balanceOf(msg.sender) >= numberVeWaveReceiptTokens, "You don't have any veWAVEReceipt");
        // Get the current pool information
        PoolInfo memory pool = updatePool(_pid);
        // Get the current user's information based on the tokenId
        UserInfo storage user = userInfo[_pid][msg.sender][_tokenId];

        // Call the harvest function on the chef contract with the farmPid and this contract's address
        chef.harvest(farmPid, address(this));

        // this would  be the amount if the user joined right from the start of the farm
        uint256 accumulatedWAVE = (user.amount * pool.accWAVEPerShare) / ACC_WAVE_PRECISION;
        // subtracting the rewards the user is not eligible for
        uint256 eligibleWAVE = accumulatedWAVE - user.rewardDebt;

        // we set the new rewardDebt to the current accumulated amount of rewards for his amount of LP token
        user.rewardDebt = accumulatedWAVE;

        // If there are any eligible WAVE rewards, transfer them to the user
        if (eligibleWAVE > 0) {
            safeWAVETransfer(msg.sender, eligibleWAVE);
        }

        // Emit an event to log the harvest
        emit Harvest(msg.sender, _pid, eligibleWAVE);
    }

    function harvestAndDistributeAnotherToken(uint256 _pid, uint256 _tokenId) public {
        // Get the current pool information for the specified pid
        PoolInfoAnotherToken memory poolAnotherToken = updatePoolAnotherToken(_pid);
        // Get the current user's information for the specified pid and tokenId
        UserInfoAnotherToken storage userAnotherToken = userInfoAnotherToken[_pid][msg.sender][_tokenId];

        if (poolAnotherToken.isClosed == false) {
            // Calculate the total accumulated AnotherToken rewards for the user based on their LP token amount
            uint256 accumulatedAnotherToken = (userAnotherToken.amount * poolAnotherToken.accAnotherTokenPerShare) /
                ACC_ANOTHERTOKEN_PRECISION;
            // Subtract any rewards the user is not eligible for
            uint256 eligibleAnotherToken = accumulatedAnotherToken - userAnotherToken.rewardDebt;

            // Update the user's reward debt to the current accumulated AnotherToken rewards
            userAnotherToken.rewardDebt = accumulatedAnotherToken;

            // If there are any eligible AnotherToken rewards, transfer them to the user
            if (eligibleAnotherToken > 0) {
                safeAnotherTokenTransfer(_pid, msg.sender, eligibleAnotherToken);
            }

            // Emit an event to log the harvest
            emit HarvestAnotherToken(msg.sender, _pid, eligibleAnotherToken);
        }
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid, uint256 _tokenId) public {
        // Get the current user's information for the specified tokenId
        UserInfo storage user = userInfo[_pid][msg.sender][_tokenId];
        require(user.amount > 0, "caller didn't deposit any token");
        // Get the current user's information for the specified pid and tokenId
        UserInfoAnotherToken storage userAnotherToken = userInfoAnotherToken[_pid][msg.sender][_tokenId];
        // Get the current user's LP token amount
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        userAnotherToken.amount = 0;
        userAnotherToken.rewardDebt = 0;
        // Transfer the user's LP token back to them using the IERC721 contract
        IERC721(veWave).safeTransferFrom(address(this), msg.sender, _tokenId);

        uint256[] memory tokenIdsByCaller = tokenIdsByUser[msg.sender];
        for (uint256 i = 0; i < tokenIdsByCaller.length; ) {
            if (tokenIdsByCaller[i] == _tokenId) {
                delete tokenIdsByCaller[i];
                break;
            }
            unchecked {
                ++i;
            }
        }

        totalNftsByUser[msg.sender] = totalNftsByUser[msg.sender] - 1;

        // Emit an event to log the emergency withdraw
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Add a new pool to the pool. Can only be called by the owner.
    function add(
        // Add a new pool with the specified allocation point and current timestamp to the poolInfo array
        uint256 _allocPoint
    ) public onlyOwner {
        poolInfo.push(PoolInfo({ allocPoint: _allocPoint, lastRewardBlock: block.number, accWAVEPerShare: 0 }));
        // Emit an event to log the pool addition
        emit LogPoolAddition(0, _allocPoint);
    }

    // Add a new AnotherToken to the pool. Can only be called by the owner.
    function addAnotherToken(
        address _tokenReward,
        uint256 _anotherTokenPerBlock,
        bool _isClosed,
        uint256 _allocPoint
    ) public onlyOwner {
        // Add a new pool with the specified token reward, block reward, closed status, allocation point and current timestamp to the poolInfoAnotherToken array
        poolInfoAnotherToken.push(
            PoolInfoAnotherToken({
                tokenReward: _tokenReward,
                anotherTokenPerBlock: _anotherTokenPerBlock,
                isClosed: _isClosed,
                allocPoint: _allocPoint,
                lastRewardBlock: block.number,
                accAnotherTokenPerShare: 0
            })
        );

        totalPidsAnotherToken++;
        // Emit an event to log the pool addition
        emit LogPoolAnotherTokenAddition(totalPidsAnotherToken - 1, _tokenReward, _isClosed, _allocPoint);
    }

    function set(uint256 _allocPoint, bool _isClosed) public onlyOwner {
        // we re-adjust the total allocation points
        poolInfo[0].allocPoint = _allocPoint;
        emit LogSetPool(_allocPoint);
    }

    // Update the given Another Token pool's. Can only be called by the owner.
    function setAnotherToken(
        uint256 _pid,
        address _tokenReward,
        uint256 _allocPoint,
        uint256 _anotherTokenPerBlock,
        bool _isClosed
    ) public onlyOwner {
        // Update the allocation point, token reward, block reward and closed status of the specified AnotherToken pool
        PoolInfoAnotherToken storage poolAnotherToken = poolInfoAnotherToken[_pid];
        poolAnotherToken.allocPoint = _allocPoint;
        poolAnotherToken.tokenReward = _tokenReward;
        poolAnotherToken.anotherTokenPerBlock = _anotherTokenPerBlock;
        poolAnotherToken.isClosed = _isClosed;
        // Emit an event to log the pool update
        emit LogSetPoolAnotherToken(_pid, _tokenReward, _isClosed, _allocPoint);
    }

    // Update reward variables of the given WAVE pool to be up-to-date.
    function updatePool(uint256 _pid) public returns (PoolInfo memory pool) {
        pool = poolInfo[_pid];
        // Check if it's time to update the rewards based on the current
        if (block.number > pool.lastRewardBlock) {
            // Only update if there are any LP tokens staked in the pool
            if (totalAmountLockedWave > 0) {
                // Calculate the number of blocks since the last reward update
                uint256 blocksSinceLastReward = block.number - pool.lastRewardBlock;

                // Calculate the total WAVE rewards for the pool based on the number of blocks, WAVE per block, and pool allocation points
                uint256 waveRewards = (blocksSinceLastReward * wavePerBlock) / DENOMINATOR;
                // Calculate the WAVE rewards for the pool after taking a percentage for the treasury
                uint256 waveRewardsForPool = (waveRewards * POOL_PERCENTAGE) / DENOMINATOR;
                // Update the accumulated WAVE per LP token based on the new rewards and total staked LP tokens
                pool.accWAVEPerShare =
                    pool.accWAVEPerShare +
                    ((waveRewardsForPool * ACC_WAVE_PRECISION) / totalAmountLockedWave);
            }
            // Update the last reward block timestamp
            pool.lastRewardBlock = block.number;
            poolInfo[_pid] = pool;

            /*  emit LogUpdatePool(
                0,
                pool.lastRewardBlock,
                totalAmountLockedWave,
                pool.accWAVEPerShare
            ); */
        }
    }

    // View function to see the pending WAVE rewards for a user
    function pendingWave(
        uint256 _pid,
        address _user,
        uint256 _tokenId
    ) external view returns (uint256 pending) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user][_tokenId];
        // Get the accumulated WAVE per LP token
        uint256 accWAVEPerShare = pool.accWAVEPerShare;
        // Only update the rewards if it's time to do so and there are LP tokens staked in the pool

        if (block.timestamp > pool.lastRewardBlock && totalAmountLockedWave > 0) {
            uint256 blocksSinceLastReward = block.timestamp - pool.lastRewardBlock;
            // Calculate the WAVE rewards for the pool based on the number of blocks, WAVE per block, and pool allocation points
            uint256 waveRewards = (blocksSinceLastReward * wavePerBlock) / DENOMINATOR;

            // Calculate the WAVE rewards for the pool after taking a percentage for the treasury
            uint256 waveRewardsForPool = (waveRewards * POOL_PERCENTAGE) / DENOMINATOR;

            // Update the accumulated WAVE per LP token based on the new rewards and total staked LP tokens
            accWAVEPerShare = accWAVEPerShare + ((waveRewardsForPool * ACC_WAVE_PRECISION) / totalAmountLockedWave);
        }
        // Calculate the pending WAVE rewards for the user based on their staked LP tokens and subtracting any rewards they are not eligible for or have already claimed
        pending = (user.amount * accWAVEPerShare) / ACC_WAVE_PRECISION - user.rewardDebt;
    }

    // View function to see the pending AnotherToken rewards for a user
    function pendingAnotherToken(
        uint256 _pid,
        uint256 _tokenId,
        address _user
    ) external view returns (uint256 pending) {
        PoolInfoAnotherToken storage poolAnotherToken = poolInfoAnotherToken[_pid];
        UserInfoAnotherToken storage userAnotherToken = userInfoAnotherToken[_pid][_user][_tokenId];
        // Get the accumulated AnotherToken per LP token
        uint256 accAnotherTokenPerShare = poolAnotherToken.accAnotherTokenPerShare;
        // Calculate the pending AnotherToken rewards for the user based on their staked LP tokens and subtracting any rewards they are not eligible for or have already claimed
        uint256 anotherTokenSupply = IERC20(poolInfoAnotherToken[_pid].tokenReward).balanceOf(address(this));

        if (block.timestamp > poolAnotherToken.lastRewardBlock && anotherTokenSupply > 0) {
            uint256 blocksSinceLastReward = block.timestamp - poolAnotherToken.lastRewardBlock;
            // based on the pool weight (allocation points) we calculate the anotherToken rewarded for this specific pool
            uint256 anotherTokenRewards = (blocksSinceLastReward +
                poolAnotherToken.anotherTokenPerBlock *
                poolAnotherToken.allocPoint) / DENOMINATOR;
            // we take parts of the rewards for treasury, these can be subject to change, so we recalculate it
            // a value of 1000 = 100%
            uint256 anotherTokenRewardsForPool = (anotherTokenRewards * DENOMINATOR) / DENOMINATOR;

            // we calculate the new amount of accumulated anotherToken per veWAVE
            accAnotherTokenPerShare =
                accAnotherTokenPerShare +
                ((anotherTokenRewardsForPool * ACC_ANOTHERTOKEN_PRECISION) / anotherTokenSupply);
        }
        // Calculate the pending AnotherToken rewards for the user based on their staked LP tokens and subtracting any rewards they are not eligible for or have already claimed
        pending =
            (userAnotherToken.amount * accAnotherTokenPerShare) /
            ACC_ANOTHERTOKEN_PRECISION -
            userAnotherToken.rewardDebt;
    }

    // Update reward variables of the given anotherToken pool to be up-to-date.
    function updatePoolAnotherToken(uint256 _pid) public returns (PoolInfoAnotherToken memory poolAnotherToken) {
        poolAnotherToken = poolInfoAnotherToken[_pid];

        if (block.number > poolAnotherToken.lastRewardBlock) {
            // total of AnotherTokens staked for this pool
            uint256 anotherTokenSupply = IERC20(poolInfoAnotherToken[_pid].tokenReward).balanceOf(address(this));
            if (anotherTokenSupply > 0) {
                uint256 blocksSinceLastReward = block.number - poolAnotherToken.lastRewardBlock;

                // rewards for this pool based on his allocation points
                uint256 anotherTokenRewards = (blocksSinceLastReward *
                    poolInfoAnotherToken[_pid].anotherTokenPerBlock *
                    DENOMINATOR) / DENOMINATOR;

                uint256 anotherTokenRewardsForPool = (anotherTokenRewards * DENOMINATOR) / DENOMINATOR;

                poolAnotherToken.accAnotherTokenPerShare =
                    poolAnotherToken.accAnotherTokenPerShare +
                    ((anotherTokenRewardsForPool * ACC_ANOTHERTOKEN_PRECISION) / anotherTokenSupply);
            }
            poolAnotherToken.lastRewardBlock = block.number;
            poolInfoAnotherToken[_pid] = poolAnotherToken;

            /*emit LogUpdatePool(_pid, poolAnotherToken.lastRewardBlock, anotherTokenSupply, poolAnotherToken.accAnotherTokenPerShare);*/
        }
    }

    // Safe WAVE transfer function, just in case if rounding error causes pool to not have enough WAVE.
    function safeWAVETransfer(address _to, uint256 _amount) internal {
        // Check the balance of WAVE in the pool
        uint256 waveBalance = wave.balanceOf(address(this));
        // If the requested amount is more than the balance, transfer the entire balance
        if (_amount > waveBalance) {
            wave.transfer(_to, waveBalance);
        } else {
            // Otherwise, transfer the requested amount
            wave.transfer(_to, _amount);
        }
    }

    // Safe anotherToken transfer function, just in case if rounding error causes pool to not have enough anotherToken.
    function safeAnotherTokenTransfer(
        uint256 _pid,
        address _to,
        uint256 _amount
    ) internal {
        // Get the specified anotherToken pool
        PoolInfoAnotherToken memory pool = poolInfoAnotherToken[_pid];
        // Check the balance of anotherToken in the pool
        uint256 anotherTokenBalance = IERC20(pool.tokenReward).balanceOf(address(this));
        // If the requested amount is more than the balance, transfer the entire balance
        if (_amount > anotherTokenBalance) {
            IERC20(pool.tokenReward).transfer(_to, anotherTokenBalance);
        } else {
            // Otherwise, transfer the requested amount
            IERC20(pool.tokenReward).transfer(_to, _amount);
        }
    }

    // Update the emission rate of the WAVE token
    function updateEmissionRate(uint256 _wavePerBlock) public onlyOwner {
        // Ensure the emission rate does not exceed the maximum of 6 anothertoken per block
        require(_wavePerBlock <= 6e18, "maximum emission rate of 6 anothertoken per block exceeded");
        // Update the emission rate
        wavePerBlock = _wavePerBlock;
    }
}
