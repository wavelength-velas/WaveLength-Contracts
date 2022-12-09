/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  IRateProvider,
  IRateProviderInterface,
} from "../../AaveLinearPoolFactory.sol/IRateProvider";

const _abi = [
  {
    inputs: [],
    name: "getRate",
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

export class IRateProvider__factory {
  static readonly abi = _abi;
  static createInterface(): IRateProviderInterface {
    return new utils.Interface(_abi) as IRateProviderInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IRateProvider {
    return new Contract(address, _abi, signerOrProvider) as IRateProvider;
  }
}