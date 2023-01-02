import {ethers} from 'hardhat';
import 'dotenv/config';
import * as dotenv from 'dotenv';
import { Contract, ContractFactory } from 'ethers';
import * as tokens from "../tokenAddresses.json"

dotenv.config();

const abi = [
    " function add(uint256 _allocPoint, address _lpToken, address _rewarder) public"
]
async function initializeSigner() {
    const [deployer] = await ethers.getSigners();
    console.log(`Deploying contracts with the account: ${deployer.address}`);
    return deployer;
  }
  
  let deployer = initializeSigner();

async function set(masterChefAddress:string, allocPoint: string, lpAddress: string, rewarderAddress: string) {

    const contract = new ethers.Contract(masterChefAddress, abi, await(deployer));
    const output = await contract.add(allocPoint, lpAddress, rewarderAddress);
    console.log(output.toString);
}

set("0xb552fce0d50e300b67e90Fd29b28aC761207891B", "1", "0xC401daBB12e964B81853AbCDd48196224646F949", "0x0000000000000000000000000000000000000000" );