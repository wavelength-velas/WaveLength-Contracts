import { ethers } from "hardhat"
import { Contract } from "@ethersproject/contracts"
import { WAVEMasterChef } from "../../typechain-types/WAVEMasterChef.sol/WAVEMasterChef"
import { WAVEToken } from "../../typechain-types/WAVEToken.sol/WAVEToken"

const { BigNumber } = require("ethers")

export const BASE_TEN = 10
export const ADDRESS_ZERO = "0x0000000000000000000000000000000000000000"

export function encodeParameters(types: any, values: any) {
  const abi = new ethers.utils.AbiCoder()
  return abi.encode(types, values)
}

export function bn(amount: number, decimals: number = 18) {
  return BigNumber.from(amount).mul(BigNumber.from(BASE_TEN).pow(decimals))
}

export * from "./time"

export async function deployContract<T>(contractName: string, constructorArgs: any[]): Promise<T> {
  return ethers
    .getContractFactory(contractName)
    .then((contract) => contract.deploy(...constructorArgs))
    .then((contract) => contract.deployed()) as Promise<T>
}

export async function deployChef(
  beetsAddress: string,
  treasuryAddress: string,
  beetsPerBlock = bn(100),
  startBlock: number = 0
): Promise<WAVEMasterChef> {
  return deployContract("WAVEMasterChef", [beetsAddress, treasuryAddress, beetsPerBlock, startBlock])
}

export async function deployERC20Mock(name: string, symbol: string, supply: number, decimals: number = 18): Promise<WAVEToken> {
  return deployContract("ERC20Mock", [name, symbol, decimals, bn(supply)])
}