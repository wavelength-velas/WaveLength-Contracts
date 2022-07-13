import {HardhatUserConfig} from 'hardhat/types';
import '@nomiclabs/hardhat-waffle';
import 'hardhat-deploy-fake-erc20';
import '@nomiclabs/hardhat-etherscan';
import "@nomiclabs/hardhat-ethers";
import * as dotenv from 'dotenv';
import * as fs from 'fs';
dotenv.config();

const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            {
                version: "0.8.7",
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
    etherscan: {
        apiKey: {
          velas: ""
        },
        customChains: [
          {
            network: "velas",
            chainId: 106,
            urls: {
              apiURL: "http://0.0.0.0/api/eth-rpc",
              browserURL: "https://evmexplorer.velas.com/"
            }
          }
        ]
      }
}

export default config;
