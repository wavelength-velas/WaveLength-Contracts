import {ethers} from 'hardhat';
import 'dotenv/config';
import * as dotenv from 'dotenv';
import { Contract, ContractFactory } from 'ethers';
import * as tokens from "../tokenAddresses.json"

dotenv.config();

const abi = [
    "  function transferOwnership(address newOwner) public virtual"
]
const abiRead = [
    "function owner() public view "
]

async function initializeSigner() {
    const [deployer] = await ethers.getSigners();
    console.log(`Deploying contracts with the account: ${deployer.address}`);
    return deployer;
  }
  
  let deployer = initializeSigner();

async function transferOwnership(veWAVEReceiptAddress:string, EmissionsDistributor: string) {

    const contract = new ethers.Contract(veWAVEReceiptAddress, abi, await(deployer));
    const output = await contract.transferOwnership(EmissionsDistributor);
    console.log(output);
}

async function owner(veWAVEReceiptAddress:string) {
    const contract = new ethers.Contract(veWAVEReceiptAddress, abiRead, await(deployer));
    const output = await contract.owner();
    console.log(output);
}

//transferOwnership( "0xB309966bF41Af9779ff9dbe46aFf41064A79693d", "0xD6BEe1686A4A876CFD0b066d1c1C73ADCdFfc160" );
owner("0x8b3a6fa1eB9BEC2c07974122Fa4E5f7eBb195514");