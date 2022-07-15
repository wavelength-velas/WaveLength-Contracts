import '@nomiclabs/hardhat-ethers';
import {ethers} from "hardhat";
import * as tokens from '../tokenAddresses.json';
import * as methods from '../inputs.json';

const abi = [
    "function create(string memory name, string memory symbol, address[] memory tokens, uint256 amplificationParameter, uint256 swapFeePercentage) external returns (address)"
];

let input: string[];
input = ["BUSD-USDC", "BUSD-USDC", "1000", "600000000000000"];
let tokenAddresses : string[];
tokenAddresses = [tokens.network.Velas.BUSD, tokens.network.Velas.USDC];


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


deployStableLiquidityPool(methods.Contracts.StablePoolFactory, input, tokenAddresses);