/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  ITemporarilyPausable,
  ITemporarilyPausableInterface,
} from "../../BalancerHelpers.sol/ITemporarilyPausable";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "bool",
        name: "paused",
        type: "bool",
      },
    ],
    name: "PausedStateChanged",
    type: "event",
  },
  {
    inputs: [],
    name: "getPausedState",
    outputs: [
      {
        internalType: "bool",
        name: "paused",
        type: "bool",
      },
      {
        internalType: "uint256",
        name: "pauseWindowEndTime",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "bufferPeriodEndTime",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
];

export class ITemporarilyPausable__factory {
  static readonly abi = _abi;
  static createInterface(): ITemporarilyPausableInterface {
    return new utils.Interface(_abi) as ITemporarilyPausableInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): ITemporarilyPausable {
    return new Contract(
      address,
      _abi,
      signerOrProvider
    ) as ITemporarilyPausable;
  }
}