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
  
  let deployer = initializeSigner();

async function DeployveNFT(tokenAddress:string) {
    const veNFT = await ethers.getContractFactory("contracts/veWAVE.sol:ve");
    //2. It will create a json request, json-rpc request over to eth network, and the network will call a process to begin a transaction
  
    const contract = await veNFT.deploy(tokenAddress);
    console.log("Contract in Deployment");
  
    //3. When the process before done, we will deployed the contract
    await contract.deployed();
    let contractAddress = await contract.address;
  
    //4. All of the respnose will be returned. And named to contract variable
  
    console.log("veNFT Deployed At: " + contractAddress);
    return contract;
    
}

async function DeployveWAVEReceipt() {
    const veNFT = await ethers.getContractFactory("contracts/veWAVEReceipt.sol:veWAVEReceipt");
    const contract = await veNFT.deploy();
    await contract.deployed();  
    console.log("veWAVEReceipt Deployed At: " + await contract.address);
    return contract;
    
}

async function DeployEmissionsDistributor(WAVEToken:string, veWAVE:string, MasterChef:string, farmPID: string, veWAVEReceipt: string ) {
    const veNFT = await ethers.getContractFactory("contracts/EmissionDistributor.sol:WaveEmissionDistributor");
    const contract = await veNFT.deploy(WAVEToken, veWAVE, MasterChef, farmPID, veWAVEReceipt);
    await contract.deployed();
    
    console.log("Emissions Distributor Deployed At: " + await contract.address);
    return contract;
    
}
async function DeployVeModel(WAVEToken:string, MasterChef:string, farmPID: string) {
    
    const veNFT = DeployveNFT(WAVEToken);
    let veNFTAddress = (await veNFT).address;

    const veWAVEReceipt = DeployveWAVEReceipt();
    let veWAVEReceiptAddress = (await veWAVEReceipt).address;

    const EmissionsDistributor = DeployEmissionsDistributor(WAVEToken, veNFTAddress, MasterChef, farmPID, veWAVEReceiptAddress);
    let EmissionsDistributorAddress = (await EmissionsDistributor).address;

    console.log("veNFT Address: " + veNFTAddress + " veWAVEReceiptAddress: " + veWAVEReceiptAddress + " EmissionsDistributor Address: " + EmissionsDistributorAddress);
}

//DeployVeModel("0xC401daBB12e964B81853AbCDd48196224646F949", "0xb552fce0d50e300b67e90Fd29b28aC761207891B", "0");
//DeployveNFT("0xC401daBB12e964B81853AbCDd48196224646F949");
DeployveWAVEReceipt();