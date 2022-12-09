/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../../common";
import type {
  BalancerHelpers,
  BalancerHelpersInterface,
} from "../../BalancerHelpers.sol/BalancerHelpers";

const _abi = [
  {
    inputs: [
      {
        internalType: "contract IVault",
        name: "_vault",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "poolId",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        internalType: "address",
        name: "recipient",
        type: "address",
      },
      {
        components: [
          {
            internalType: "contract IAsset[]",
            name: "assets",
            type: "address[]",
          },
          {
            internalType: "uint256[]",
            name: "minAmountsOut",
            type: "uint256[]",
          },
          {
            internalType: "bytes",
            name: "userData",
            type: "bytes",
          },
          {
            internalType: "bool",
            name: "toInternalBalance",
            type: "bool",
          },
        ],
        internalType: "struct IVault.ExitPoolRequest",
        name: "request",
        type: "tuple",
      },
    ],
    name: "queryExit",
    outputs: [
      {
        internalType: "uint256",
        name: "bptIn",
        type: "uint256",
      },
      {
        internalType: "uint256[]",
        name: "amountsOut",
        type: "uint256[]",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "poolId",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        internalType: "address",
        name: "recipient",
        type: "address",
      },
      {
        components: [
          {
            internalType: "contract IAsset[]",
            name: "assets",
            type: "address[]",
          },
          {
            internalType: "uint256[]",
            name: "maxAmountsIn",
            type: "uint256[]",
          },
          {
            internalType: "bytes",
            name: "userData",
            type: "bytes",
          },
          {
            internalType: "bool",
            name: "fromInternalBalance",
            type: "bool",
          },
        ],
        internalType: "struct IVault.JoinPoolRequest",
        name: "request",
        type: "tuple",
      },
    ],
    name: "queryJoin",
    outputs: [
      {
        internalType: "uint256",
        name: "bptOut",
        type: "uint256",
      },
      {
        internalType: "uint256[]",
        name: "amountsIn",
        type: "uint256[]",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "vault",
    outputs: [
      {
        internalType: "contract IVault",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
];

const _bytecode =
  "0x60c060405234801561001057600080fd5b50604051610e64380380610e6483398101604081905261002f916100bf565b806001600160a01b031663ad5c46486040518163ffffffff1660e01b815260040160206040518083038186803b15801561006857600080fd5b505afa15801561007c573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906100a091906100bf565b6001600160601b0319606091821b811660805291901b1660a0526100fa565b6000602082840312156100d0578081fd5b81516100db816100e2565b9392505050565b6001600160a01b03811681146100f757600080fd5b50565b60805160601c60a05160601c610d2961013b6000398060a05280610155528061030152806103b6528061049652806104e35250806107415250610d296000f3fe608060405234801561001057600080fd5b50600436106100415760003560e01c80639ebbf05d14610046578063c7b2c52c14610070578063fbfa77cf14610083575b600080fd5b610059610054366004610aac565b610098565b604051610067929190610c7a565b60405180910390f35b61005961007e366004610aac565b6102f9565b61008b610494565b6040516100679190610c66565b6000606060007f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663f6c00927886040518263ffffffff1660e01b81526004016100ea9190610bce565b604080518083038186803b15801561010157600080fd5b505afa158015610115573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061013991906109a5565b50905060008061014d8987600001516104b8565b9150915060007f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663d2946c2b6040518163ffffffff1660e01b815260040160206040518083038186803b1580156101ac57600080fd5b505afa1580156101c0573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906101e49190610b15565b9050836001600160a01b03166387ec68178b8b8b8787876001600160a01b03166355c676286040518163ffffffff1660e01b815260040160206040518083038186803b15801561023357600080fd5b505afa158015610247573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061026b9190610b38565b8e604001516040518863ffffffff1660e01b81526004016102929796959493929190610bd7565b600060405180830381600087803b1580156102ac57600080fd5b505af11580156102c0573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f191682016040526102e89190810190610b50565b909b909a5098505050505050505050565b6000606060007f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663f6c00927886040518263ffffffff1660e01b815260040161034b9190610bce565b604080518083038186803b15801561036257600080fd5b505afa158015610376573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061039a91906109a5565b5090506000806103ae8987600001516104b8565b9150915060007f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663d2946c2b6040518163ffffffff1660e01b815260040160206040518083038186803b15801561040d57600080fd5b505afa158015610421573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906104459190610b15565b9050836001600160a01b0316636028bfd48b8b8b8787876001600160a01b03166355c676286040518163ffffffff1660e01b815260040160206040518083038186803b15801561023357600080fd5b7f000000000000000000000000000000000000000000000000000000000000000081565b60606000606060006104c9856105ed565b604051631f29a8cd60e31b81529091506001600160a01b037f0000000000000000000000000000000000000000000000000000000000000000169063f94d466890610518908990600401610bce565b60006040518083038186803b15801561053057600080fd5b505afa158015610544573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f1916820160405261056c91908101906109e1565b825184519297509095509193506105839190610692565b60005b82518110156105e357600083828151811061059d57fe5b602002602001015190506105da8383815181106105b657fe5b60200260200101516001600160a01b0316826001600160a01b0316146102086106a3565b50600101610586565b5050509250929050565b6060600082516001600160401b038111801561060857600080fd5b50604051908082528060200260200182016040528015610632578160200160208202803683370190505b50905060005b83518110156106895761065d84828151811061065057fe5b60200260200101516106b1565b82828151811061066957fe5b6001600160a01b0390921660209283029190910190910152600101610638565b5090505b919050565b61069f81831460676106a3565b5050565b8161069f5761069f816106dc565b60006106bc8261072f565b6106ce576106c98261073c565b6106d6565b6106d661073f565b92915050565b62461bcd60e51b6000908152602060045260076024526642414c23000030600a808404818106603090810160081b95839006959095019082900491820690940160101b939093010160c81b604452606490fd5b6001600160a01b03161590565b90565b7f000000000000000000000000000000000000000000000000000000000000000090565b600082601f830112610773578081fd5b8135602061078861078383610cbe565b610c9b565b82815281810190858301838502870184018810156107a4578586fd5b855b858110156107cb5781356107b981610cdb565b845292840192908401906001016107a6565b5090979650505050505050565b600082601f8301126107e8578081fd5b813560206107f861078383610cbe565b8281528181019085830183850287018401881015610814578586fd5b855b858110156107cb57813584529284019290840190600101610816565b600082601f830112610842578081fd5b8151602061085261078383610cbe565b828152818101908583018385028701840188101561086e578586fd5b855b858110156107cb57815184529284019290840190600101610870565b8035801515811461068d57600080fd5b600082601f8301126108ac578081fd5b81356001600160401b038111156108bf57fe5b6108d2601f8201601f1916602001610c9b565b8181528460208386010111156108e6578283fd5b816020850160208301379081016020019190915292915050565b600060808284031215610911578081fd5b61091b6080610c9b565b905081356001600160401b038082111561093457600080fd5b61094085838601610763565b8352602084013591508082111561095657600080fd5b610962858386016107d8565b6020840152604084013591508082111561097b57600080fd5b506109888482850161089c565b60408301525061099a6060830161088c565b606082015292915050565b600080604083850312156109b7578182fd5b82516109c281610cdb565b6020840151909250600381106109d6578182fd5b809150509250929050565b6000806000606084860312156109f5578081fd5b83516001600160401b0380821115610a0b578283fd5b818601915086601f830112610a1e578283fd5b81516020610a2e61078383610cbe565b82815281810190858301838502870184018c1015610a4a578788fd5b8796505b84871015610a75578051610a6181610cdb565b835260019690960195918301918301610a4e565b5091890151919750909350505080821115610a8e578283fd5b50610a9b86828701610832565b925050604084015190509250925092565b60008060008060808587031215610ac1578182fd5b843593506020850135610ad381610cdb565b92506040850135610ae381610cdb565b915060608501356001600160401b03811115610afd578182fd5b610b0987828801610900565b91505092959194509250565b600060208284031215610b26578081fd5b8151610b3181610cdb565b9392505050565b600060208284031215610b49578081fd5b5051919050565b60008060408385031215610b62578182fd5b8251915060208301516001600160401b03811115610b7e578182fd5b610b8a85828601610832565b9150509250929050565b6000815180845260208085019450808401835b83811015610bc357815187529582019590820190600101610ba7565b509495945050505050565b90815260200190565b6000888252602060018060a01b03808a168285015280891660408501525060e06060840152610c0960e0840188610b94565b8660808501528560a085015283810360c08501528451808252835b81811015610c3f578681018401518382018501528301610c24565b81811115610c4f57848483850101525b50601f01601f191601019998505050505050505050565b6001600160a01b0391909116815260200190565b600083825260406020830152610c936040830184610b94565b949350505050565b6040518181016001600160401b0381118282101715610cb657fe5b604052919050565b60006001600160401b03821115610cd157fe5b5060209081020190565b6001600160a01b0381168114610cf057600080fd5b5056fea26469706673582212200abce643d9537e37d358799f277ef75eea5cbb05790d9a6bf4031209cb7ad07f64736f6c63430007060033";

type BalancerHelpersConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: BalancerHelpersConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class BalancerHelpers__factory extends ContractFactory {
  constructor(...args: BalancerHelpersConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    _vault: PromiseOrValue<string>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<BalancerHelpers> {
    return super.deploy(_vault, overrides || {}) as Promise<BalancerHelpers>;
  }
  override getDeployTransaction(
    _vault: PromiseOrValue<string>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(_vault, overrides || {});
  }
  override attach(address: string): BalancerHelpers {
    return super.attach(address) as BalancerHelpers;
  }
  override connect(signer: Signer): BalancerHelpers__factory {
    return super.connect(signer) as BalancerHelpers__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): BalancerHelpersInterface {
    return new utils.Interface(_abi) as BalancerHelpersInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): BalancerHelpers {
    return new Contract(address, _abi, signerOrProvider) as BalancerHelpers;
  }
}