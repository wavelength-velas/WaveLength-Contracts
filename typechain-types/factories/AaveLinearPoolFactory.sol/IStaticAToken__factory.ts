/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  IStaticAToken,
  IStaticATokenInterface,
} from "../../AaveLinearPoolFactory.sol/IStaticAToken";

const _abi = [
  {
    inputs: [],
    name: "ASSET",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "LENDING_POOL",
    outputs: [
      {
        internalType: "contract ILendingPool",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "rate",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
];

export class IStaticAToken__factory {
  static readonly abi = _abi;
  static createInterface(): IStaticATokenInterface {
    return new utils.Interface(_abi) as IStaticATokenInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IStaticAToken {
    return new Contract(address, _abi, signerOrProvider) as IStaticAToken;
  }
}