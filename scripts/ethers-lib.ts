import { ethers } from 'ethers'
import Web3 from 'web3'
export const config = {
    chainId: 250,
    networkName: 'Fantom Opera Mainnet',
    ftmscanUrl: 'https://ftmscan.com',
    defaultProvider: 'https://rpc.ftm.tools/'
  };
  
  export type EthereumConfig = {
    testing: boolean;
    autoGasMultiplier: number;
    defaultConfirmations: number;
    defaultGas: string;
    defaultGasPrice: string;
    ethereumNodeTimeout: number;
  };
  
  export const defaultEthereumConfig = {
    testing: false,
    autoGasMultiplier: 1.5,
    defaultConfirmations: 1,
    defaultGas: '6000000',
    defaultGasPrice: '1000000000000',
    ethereumNodeTimeout: 10000,
  };
  export function web3ProviderFrom(endpoint: string, config?: EthereumConfig): any {
    const ethConfig = Object.assign(defaultEthereumConfig, config || {});
  
    const providerClass = endpoint.includes('wss') ? Web3.providers.WebsocketProvider : Web3.providers.HttpProvider;
  
    return new providerClass(endpoint, {
      timeout: ethConfig.ethereumNodeTimeout,
    });
  }
  
  let provider: ethers.providers.Web3Provider;
  
  export function getDefaultProvider(): ethers.providers.Web3Provider {
    if (!provider) {
      provider = new ethers.providers.Web3Provider(web3ProviderFrom(config.defaultProvider), config.chainId);
    }
  
    return provider;
  }
  
  export function sortTokens(tokenA: string, tokenB: string) {
    const token0 = tokenA < tokenB ? tokenA : tokenB
    const token1 = tokenA > tokenB ? tokenA : tokenB
    return { token0, token1 }
  }

/**
 * Deploy the given contract
 * @param {string} contractName name of the contract to deploy
 * @param {Array<any>} args list of constructor' parameters
 * @param {Number} accountIndex account index from the exposed account
 * @return {Contract} deployed contract
 */
export const deploy = async (contractName: string, args: Array<any>, accountIndex?: number): Promise<ethers.Contract> => {    

    console.log(`deploying ${contractName}`)
    // Note that the script needs the ABI which is generated from the compilation artifact.
    // Make sure contract is compiled and artifacts are generated
    const artifactsPath = `browser/contracts/artifacts/${contractName}.json` // Change this for different path

    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))
    // 'web3Provider' is a remix global variable object

    const web3Provider = getDefaultProvider()
    
    const signer = (web3Provider).getSigner(accountIndex)

    const factory = new ethers.ContractFactory(metadata.abi, metadata.data.bytecode.object, signer)

    const contract = await factory.deploy(...args)   

    // The contract is NOT deployed yet; we must wait until it is mined
    await contract.deployed()
    return contract
}