import {HardhatUserConfig} from 'hardhat/types';
import '@typechain/hardhat';
import "@nomiclabs/hardhat-ethers";
import '@nomiclabs/hardhat-waffle';
import 'hardhat-deploy-fake-erc20';
import '@nomiclabs/hardhat-etherscan';
import * as dotenv from 'dotenv';
import "hardhat-deploy-ethers";
import * as fs from 'fs';

dotenv.config();

const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            {
                version: "0.8.7",
            },
            {
                version: "0.8.11",
            },
            {
                version: "0.8.0",
            },
            {
                version: '0.7.6',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 50,
                    },
                },
                
            },
        ],
    },

    networks: {
        fantom: {
            url: 'https://rpc.ftm.tools/',
            accounts: [`${process.env.PRIVATE_KEY}`],
                        // gasMultiplier: 2,

        },

        velas: {
            url: 'https://evmexplorer.velas.com/rpc',
            chainId: 106,
            accounts: [`${process.env.PRIVATE_KEY1}`],
            // gasMultiplier: 2,
        },
    },
}

export default config;
