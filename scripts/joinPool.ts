import '@nomiclabs/hardhat-ethers';
import {ethers} from "hardhat";
import * as tokens from '../tokenAddresses.json';
import * as methods from '../inputs.json';

const abi = [
    "function joinPool(bytes32 poolId, address sender, address recipient, JoinPoolRequest memory request) external payable"
];

let input: string[];
input = ["BUSD-USDC", "BUSD-USDC", "1000", "600000000000000"];
let tokenAddresses : string[];
tokenAddresses = [tokens.network.Velas.BUSD, tokens.network.Velas.USDC];
const poolId = "0x58e78e2cc0107895d11f4f57e3a866409dcc4af6000200000000000000000000";
const request = "([0x142503B2CD35cfcE54f0F2455df57ce5B97Ee2cF, 0x0000000000000000000000000000000000000000], [228810703496123368, 678429387670248317], 0x0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000007caa324a05d59cb0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000032ce61f5eb193e8000000000000000000000000000000000000000000000000096a43ef01455b7d, false)";
let poolAddress = "0x58e78e2cC0107895D11F4F57e3a866409DcC4AF6";


async function deployStableLiquidityPool(factory: string, inputs:string[], tokenAddresses: string[]) { 
    const [signer] = await ethers.getSigners();
    const factoryContract = await ethers.getContractFactory("StablePoolFactory");
    console.log(methods.Contracts.StablePoolFactory);
    const contract = new ethers.Contract(methods.Contracts.StablePoolFactory, abi, signer);
    
    //const contract = await factoryContract.attach(methods.Contracts.StablePoolFactory);
    console.log(contract.interface);
    const output = await contract.create(inputs[0], inputs[1], tokenAddresses, inputs[2], inputs[3]);
    
    console.log("Pool deployed: " + output);

}

async function joinPool(poolId:string, sender: string, recipient: string) {
    const [signer] = await ethers.getSigners();
    const factoryContract = await ethers.getContractFactory("contracts/WeightedPool2TokensFactory.sol:WeightedPool2Tokens");
    console.log(factoryContract);
    const contract = new ethers.Contract(poolAddress, abi, signer);
    console.log(contract.interface);
    const output = await contract.joinPool(poolId, sender)

}

joinPool(methods.Contracts.StablePoolFactory, poolId, poolId);