/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { Ve, VeInterface } from "../../EmissionDistributor.sol/Ve";

const _abi = [
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_amount",
        type: "uint256",
      },
    ],
    name: "shareRevenue",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

export class Ve__factory {
  static readonly abi = _abi;
  static createInterface(): VeInterface {
    return new utils.Interface(_abi) as VeInterface;
  }
  static connect(address: string, signerOrProvider: Signer | Provider): Ve {
    return new Contract(address, _abi, signerOrProvider) as Ve;
  }
}