import {ethers} from 'hardhat';
import 'dotenv/config';
import * as dotenv from 'dotenv';
import { Contract, ContractFactory } from 'ethers';
import * as tokens from "../tokenAddresses.json"

dotenv.config();



async function initializeSigner() {
    const [deployer] = await ethers.getSigners();
    console.log(`Deploying contracts with the account: ${deployer.address}`);
    return deployer;
  }
  


/*async function deployToken()  {
    const token = await ethers.getContractFactory("contracts/WAVEToken.sol:WAVEToken");
  ~
    //2. It will create a json request, json-rpc request over to eth network, and the network will call a process to begin a transaction
  
    const contract = await token.deploy();
  
    //3. When the process before done, we will deployed the contract
    await contract.deployed();
  
    //4. All of the respnose will be returned. And named to contract variable
    console.log(contract);
    return contract;
  }*/
  
  async function deployMasterChef(tokenAddress:string, treasuryAddress: string ,tokenPerBlock: string, startBlock: string) {
    const token = await ethers.getContractFactory("WAVEMasterChef");
    //2. It will create a json request, json-rpc request over to eth network, and the network will call a process to begin a transaction
    
    const contract = await token.deploy(tokenAddress, treasuryAddress,tokenPerBlock, startBlock);
    //3. When the process before done, we will deployed the contract
    await contract.deployed();
    //4. All of the respnose will be returned. And named to contract variable
    console.log(contract);
    return contract;
  }
  
  
  async function deployTimeLock(adminAddress: string, delayTime: string) {
    const contractFactory = await ethers.getContractFactory("contracts/Timelock.sol:Timelock");
    //2. It will create a json request, json-rpc request over to eth network, and the network will call a process to begin a transaction
    
    const contract = await contractFactory.deploy(adminAddress, delayTime);
    //3. When the process before done, we will deployed the contract
    await contract.deployed();
    //4. All of the respnose will be returned. And named to contract variable
    console.log(contract);
    return contract;
  }
  
  async function deployMasterChefOperator(timelock:string, masterChef: string, admin: string, stagingAdmin: string) {
    
    const contractFactory = await ethers.getContractFactory("MasterChefOperator");
    //2. It will create a json request, json-rpc request over to eth network, and the network will call a process to begin a transaction
    const contract = await contractFactory.deploy(timelock, masterChef, admin, stagingAdmin);
    //3. When the process before done, we will deployed the contract
    await contract.deployed();
    //4. All of the respnose will be returned. And named to contract variable
    console.log(contract);
    return contract;
  }
  
  
  
  async function deployTokenomics(tokenPerSecond: string) {
    let deployer = initializeSigner();
    let deployerAddress = (await deployer).address;
   // const tokenContract = deployToken();
   // let addressInput = (await tokenContract).address;
  
    let latestBlock = await ethers.provider.getBlock("latest");
  
    console.log("LatestBlock: " + latestBlock.timestamp);

   // let masterChef = deployMasterChef(addressInput, deployerAddress , tokenPerSecond, (latestBlock.timestamp + 100).toString());
    
    let timelock = deployTimeLock(deployerAddress, "0");
    console.log("Timelock Deployed at the Following Address: " + (await timelock).address)

    // let masterChefOperator = deployMasterChefOperator((await timelock).address, (await masterChef).address, deployerAddress, deployerAddress );

    // console.log("WAVE Token Address: " + addressInput + '/n' + "MasterChef Address: " + (await masterChef).address + '/n' +  "Timelock Address: " + (await timelock).address + '/n' + (await masterChefOperator).address);
    return;
  }

  async function deployWaveBar() {
    let deployer = initializeSigner();
    const waveBarFactory = await ethers.getContractFactory("WaveBar");
    const waveBar = await waveBarFactory.deploy(tokens.network.Velas.WAVE);
    await waveBar.deployed();
    console.log(waveBar);
    return waveBar;
  }
  
  
  deployWaveBar();
  