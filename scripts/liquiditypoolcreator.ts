import '@nomiclabs/hardhat-ethers';
import {ethers} from "hardhat";
import * as tokens from '../tokenAddresses.json';


let input: string[];
input = ["BUSD-USDC", "BUSD-USDC", "1000", "600000000000000"];
let tokenAddresses : string[];
tokenAddresses = [tokens.network.Velas.BUSD, tokens.network.Velas.USDC];
let StablePoolFactory: string;
StablePoolFactory = "0x22D9Dfb080cDfa733f7e9B61c15E50eB52E1fd92";

async function deployStableLiquidityPool(factory: string, inputs:string[], tokenAddresses: string[]) {
    const factoryContract = await ethers.getContractFactory('StablePoolFactory');
    const contract = await factoryContract.attach(factory);
    const output = await contract.create(inputs[0], inputs[1], tokenAddresses, inputs[2], inputs[3]);
    
    console.log("Pool deployed: " + output);

}
deployStableLiquidityPool(StablePoolFactory, input, tokenAddresses);