import '@nomiclabs/hardhat-ethers';
import {ethers} from 'hardhat';
import * as tokens from '../tokenAddresses.json';
import * as methods from '../inputs.json'

const abi = [
    "function getVault() public view returns(address)",
    "function getDefaultPoolOwner() public view returns(address)" 
]



async function factoryReader(factoryName:string, functionid: string) {
    const [deployer] = await ethers.getSigners();
    const factoryContract = await ethers.getContractFactory(factoryName);
    const contract = await factoryContract.attach(methods.Contracts.StablePoolFactory);
  
    let vault = await contract.getVault();
    console.log("Vault Address: " + vault.toString());
    let owner = await contract.getDefaultPoolOwner();
     console.log("Default Pool Owner Address"+ owner.toString());


}

factoryReader("StablePoolFactory", "0");