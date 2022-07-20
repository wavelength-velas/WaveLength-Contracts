import {ethers} from 'hardhat';
import 'dotenv/config';
import * as inputs from "../inputs.json"
import * as dotenv from 'dotenv';
import * as fs from 'fs';
import { open, close, appendFile } from 'node:fs';
import { ContractFactory } from 'ethers';
dotenv.config();


function printToInput (data: any){
  const fs = require('fs');
  fs.appendFileSync('Deployment_Information','/n' + data.toString);
}




async function deploy() {
  //1. Get the contract factory
  let deployedContract : string;
  deployedContract = "Authorizer"
  const MyContract = await ethers.getContractFactory(deployedContract);
  let authorizerInput : string;
  
  //2. It will create a json request, json-rpc request over to eth network, and the network will call a process to begin a transaction
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);
  authorizerInput = deployer.address;
  
  const contract = await MyContract.deploy(authorizerInput);
  
  //3. When the process before done, we will deployed the contract
  await contract.deployed();
  
  //4. All of the respnose will be returned. And named to contract variable
  console.log(contract);
  return contract;
}

async function deployVault() {
  //1. Get the contract factory
  let deployedContract : string;
  deployedContract = "Vault"
  const MyContract = await ethers.getContractFactory(deployedContract);
  //2. It will create a json request, json-rpc request over to eth network, and the network will call a process to begin a transaction
  const [deployer] = await ethers.getSigners();
  
  console.log(`Deploying contracts with the account: ${deployer.address}`);

  const contract = await MyContract.deploy(inputs.Contracts.Authorizer, inputs.WETH.WVLX, inputs.VaultInputs.bwd, inputs.VaultInputs.pwd);
   
  
  //3. When the process before done, we will deployed the contract
  await contract.deployed();
  
  //4. All of the respnose will be returned. And named to contract variable
  console.log(contract);
  return contract;
}

async function deployFactories() {
  //1. Get the contract factory
  let i : number;
  let deployedContract: string[];
  deployedContract = ["StablePoolFactory", "StablePhantomPoolFactory", "WeightedPoolFactory", "WeightedPool2TokensFactory", "CompoundLinearPoolFactory"]
  let deployedFactories : any[];
  deployedFactories = [];

  for(i = 0; i<= deployedContract.length; i++) {

    const MyContract = await ethers.getContractFactory(deployedContract[i]);

    //2. It will create a json request, json-rpc request over to eth network, and the network will call a process to begin a transaction
    const [deployer] = await ethers.getSigners();
    console.log(`Deploying contracts with the account: ${deployer.address}`);
    
    const contract = await MyContract.deploy(inputs.Contracts.Vault, inputs.Admins.WaveLengthDeployer);
     
    console.log("Deploying: " + deployedContract[i]);
    //3. When the process before done, we will deployed the contract
    await contract.deployed();
    
    //4. All of the respnose will be returned. And named to contract variable
    console.log(contract);
    printToInput(contract);
    deployedFactories.push(contract);
  }
  console.log(deployedFactories);
  return deployedFactories;
}

async function deploySingleFactory(factoryType:string) {
  const MyContract = await ethers.getContractFactory(factoryType);
  let Input : string;
  //2. It will create a json request, json-rpc request over to eth network, and the network will call a process to begin a transaction
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);
  Input = deployer.address;
  const contract = await MyContract.deploy(inputs.Contracts.Vault, inputs.Admins.WaveLengthDeployer);
  //3. When the process before done, we will deployed the contract
  await contract.deployed();
  
  //4. All of the respnose will be returned. And named to contract variable
  console.log(contract);
  return contract;
}

async function deployToken(ContractFactory: string) {
  const token = await ethers.getContractFactory(ContractFactory);
  let Input : string;
  //2. It will create a json request, json-rpc request over to eth network, and the network will call a process to begin a transaction
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);
  Input = deployer.address;
  const contract = await token.deploy();
  //3. When the process before done, we will deployed the contract
  await contract.deployed();
  //4. All of the respnose will be returned. And named to contract variable
  console.log(contract);
  return contract;
}

async function deployTokenomics(tokenFactory:string) {
deployToken(tokenFactory);



  
}

async (patrams:type) => {
  
}

deploySingleFactory("AaveLinearPoolFactory");