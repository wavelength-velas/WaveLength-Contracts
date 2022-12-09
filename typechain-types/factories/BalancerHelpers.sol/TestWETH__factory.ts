/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../../common";
import type {
  TestWETH,
  TestWETHInterface,
} from "../../BalancerHelpers.sol/TestWETH";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "minter",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "Approval",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "dst",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "wad",
        type: "uint256",
      },
    ],
    name: "Deposit",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "bytes32",
        name: "previousAdminRole",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "bytes32",
        name: "newAdminRole",
        type: "bytes32",
      },
    ],
    name: "RoleAdminChanged",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "where",
        type: "address",
      },
    ],
    name: "RoleGranted",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "sender",
        type: "address",
      },
    ],
    name: "RoleGrantedGlobally",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "where",
        type: "address",
      },
    ],
    name: "RoleRevoked",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "sender",
        type: "address",
      },
    ],
    name: "RoleRevokedGlobally",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "Transfer",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "src",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "wad",
        type: "uint256",
      },
    ],
    name: "Withdrawal",
    type: "event",
  },
  {
    inputs: [],
    name: "DEFAULT_ADMIN_ROLE",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "GLOBAL_ROLE_ADMIN",
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
    name: "MINTER_ROLE",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "allowance",
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
  {
    inputs: [
      {
        internalType: "address",
        name: "guy",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "wad",
        type: "uint256",
      },
    ],
    name: "approve",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "balanceOf",
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
  {
    inputs: [],
    name: "decimals",
    outputs: [
      {
        internalType: "uint8",
        name: "",
        type: "uint8",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "deposit",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
    ],
    name: "getRoleAdmin",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "uint256",
        name: "index",
        type: "uint256",
      },
    ],
    name: "getRoleGlobalMember",
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
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
    ],
    name: "getRoleGlobalMemberCount",
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
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "uint256",
        name: "index",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "where",
        type: "address",
      },
    ],
    name: "getRoleMemberByContract",
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
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "where",
        type: "address",
      },
    ],
    name: "getRoleMemberCountByContract",
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
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "address[]",
        name: "where",
        type: "address[]",
      },
    ],
    name: "grantRole",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "grantRoleGlobally",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "address",
        name: "where",
        type: "address",
      },
    ],
    name: "hasRole",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "destinatary",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "mint",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "name",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "address[]",
        name: "where",
        type: "address[]",
      },
    ],
    name: "renounceRole",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "renounceRoleGlobally",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "address[]",
        name: "where",
        type: "address[]",
      },
    ],
    name: "revokeRole",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "revokeRoleGlobally",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "symbol",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "totalSupply",
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
  {
    inputs: [
      {
        internalType: "address",
        name: "dst",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "wad",
        type: "uint256",
      },
    ],
    name: "transfer",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "src",
        type: "address",
      },
      {
        internalType: "address",
        name: "dst",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "wad",
        type: "uint256",
      },
    ],
    name: "transferFrom",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "wad",
        type: "uint256",
      },
    ],
    name: "withdraw",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    stateMutability: "payable",
    type: "receive",
  },
];

const _bytecode =
  "0x60c0604052600d60808190526c2bb930b83832b21022ba3432b960991b60a0908152620000309160019190620001dd565b50604080518082019091526004808252630ae8aa8960e31b60209092019182526200005e91600291620001dd565b506003805460ff191660121790553480156200007957600080fd5b5060405162001680380380620016808339810160408190526200009c9162000289565b620000a9600082620000dc565b620000d57f9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a682620000dc565b50620002b9565b620000e88282620000ec565b5050565b6000828152602081815260409091206200011191839062000bc562000153821b17901c565b15620000e85760405133906001600160a01b0383169084907f287e752593aea8255aeaa7ea93d3e06807273ef2426cde02d5572ee69f16e96990600090a45050565b6000620001618383620001bc565b620001b257508154600180820184556000848152602080822090930180546001600160a01b0319166001600160a01b03861690811790915585549082528286019093526040902091909155620001b6565b5060005b92915050565b6001600160a01b031660009081526001919091016020526040902054151590565b828054600181600116156101000203166002900490600052602060002090601f01602090048101928262000215576000855562000260565b82601f106200023057805160ff191683800117855562000260565b8280016001018555821562000260579182015b828111156200026057825182559160200191906001019062000243565b506200026e92915062000272565b5090565b5b808211156200026e576000815560010162000273565b6000602082840312156200029b578081fd5b81516001600160a01b0381168114620002b2578182fd5b9392505050565b6113b780620002c96000396000f3fe6080604052600436106101505760003560e01c80638f109636116100bc5780638f1096361461032d57806395d89b411461034d5780639aa167a2146103625780639dfea6a014610377578063a217fddf14610397578063a9059cbb146103ac578063abbb9592146103cc578063b5061e7a146103ec578063b52b585d1461040c578063b559c89d1461042c578063c7f042031461044c578063d0e30db01461046c578063d539139314610474578063dd62ed3e146104895761015f565b806306fdde0314610164578063095ea7b31461018f57806314f82b0d146101bc57806318160ddd146101e957806323b872dd1461020b578063248a9ca31461022b5780632e1a7d4d1461024b578063313ce5671461026b57806340c10f191461028d57806343744f95146102ad578063583b7497146102cd5780635b852f82146102ed57806370a082311461030d5761015f565b3661015f5761015d6104a9565b005b600080fd5b34801561017057600080fd5b506101796104fa565b6040516101869190611269565b60405180910390f35b34801561019b57600080fd5b506101af6101aa3660046110d3565b610587565b6040516101869190611255565b3480156101c857600080fd5b506101dc6101d7366004611216565b6105f2565b6040516101869190611241565b3480156101f557600080fd5b506101fe610627565b6040516101869190611260565b34801561021757600080fd5b506101af610226366004611098565b61062b565b34801561023757600080fd5b506101fe6102463660046110fc565b61078f565b34801561025757600080fd5b5061015d6102663660046110fc565b6107a7565b34801561027757600080fd5b5061028061085a565b6040516101869190611373565b34801561029957600080fd5b5061015d6102a83660046110d3565b610863565b3480156102b957600080fd5b506101fe6102c83660046110fc565b610904565b3480156102d957600080fd5b5061015d6102e8366004611171565b61091b565b3480156102f957600080fd5b5061015d610308366004611114565b610999565b34801561031957600080fd5b506101fe61032836600461104c565b6109d3565b34801561033957600080fd5b506101af610348366004611136565b6109e5565b34801561035957600080fd5b50610179610a30565b34801561036e57600080fd5b506101dc610a88565b34801561038357600080fd5b506101dc6103923660046111f5565b610a8d565b3480156103a357600080fd5b506101fe610a88565b3480156103b857600080fd5b506101af6103c73660046110d3565b610aac565b3480156103d857600080fd5b5061015d6103e7366004611171565b610ab9565b3480156103f857600080fd5b5061015d610407366004611114565b610ae2565b34801561041857600080fd5b5061015d610427366004611171565b610b10565b34801561043857600080fd5b506101fe610447366004611114565b610b41565b34801561045857600080fd5b5061015d610467366004611114565b610b6d565b61015d6104a9565b34801561048057600080fd5b506101fe610b84565b34801561049557600080fd5b506101fe6104a4366004611066565b610ba8565b336000818152600460205260409081902080543490810190915590517fe1fffcc4923d04b559f4d29a8bfc6cda04eb5b0d3c460751c2402c5c5cc9109c916104f091611260565b60405180910390a2565b60018054604080516020600284861615610100026000190190941693909304601f8101849004840282018401909252818152929183018282801561057f5780601f106105545761010080835404028352916020019161057f565b820191906000526020600020905b81548152906001019060200180831161056257829003601f168201915b505050505081565b3360008181526005602090815260408083206001600160a01b038716808552925280832085905551919290917f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925906105e0908690611260565b60405180910390a35060015b92915050565b6000838152602081815260408083206001600160a01b0385168452600201909152812061061f9084610c28565b949350505050565b4790565b6001600160a01b03831660009081526004602052604081205482111561066c5760405162461bcd60e51b8152600401610663906112bc565b60405180910390fd5b6001600160a01b03841633148015906106aa57506001600160a01b038416600090815260056020908152604080832033845290915290205460001914155b1561071d576001600160a01b03841660009081526005602090815260408083203384529091529020548211156106f25760405162461bcd60e51b815260040161066390611343565b6001600160a01b03841660009081526005602090815260408083203384529091529020805483900390555b6001600160a01b03808516600081815260046020526040808220805487900390559286168082529083902080548601905591517fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef9061077d908690611260565b60405180910390a35060019392505050565b6000818152602081905260409020600301545b919050565b336000908152600460205260409020548111156107d65760405162461bcd60e51b8152600401610663906112bc565b33600081815260046020526040808220805485900390555183156108fc0291849190818181858888f19350505050158015610815573d6000803e3d6000fd5b50336001600160a01b03167f7fcf532c15f0a6db0bd6d0e038bea71d30d808c7d98cb3bf7268a95bf5081b658260405161084f9190611260565b60405180910390a250565b60035460ff1681565b61088e7f9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a633306109e5565b6108aa5760405162461bcd60e51b8152600401610663906112ea565b6001600160a01b03821660008181526004602052604090819020805484019055517fe1fffcc4923d04b559f4d29a8bfc6cda04eb5b0d3c460751c2402c5c5cc9109c906108f8908490611260565b60405180910390a25050565b60008181526020819052604081206105ec90610c44565b6109288115156067610c48565b61095461094c600080878152602001908152602001600020600301543360006109e5565b6101a6610c48565b60005b818110156109925761098a858585858581811061097057fe5b9050602002016020810190610985919061104c565b610c56565b600101610957565b5050505050565b6109c56109bd600080858152602001908152602001600020600301543360006109e5565b6101a7610c48565b6109cf8282610d00565b5050565b60046020526000908152604090205481565b60008381526020819052604081206109fd9084610d59565b8061061f57506000848152602081815260408083206001600160a01b0386168452600201909152902061061f9084610d59565b6002805460408051602060018416156101000260001901909316849004601f8101849004840282018401909252818152929183018282801561057f5780601f106105545761010080835404028352916020019161057f565b600081565b6000828152602081905260408120610aa59083610c28565b9392505050565b6000610aa533848461062b565b610ad06001600160a01b03841633146101a8610c48565b610adc84848484610d7a565b50505050565b610b0661094c600080858152602001908152602001600020600301543360006109e5565b6109cf8282610e4e565b610b346109bd600080878152602001908152602001600020600301543360006109e5565b610ad08115156067610c48565b6000828152602081815260408083206001600160a01b03851684526002019091528120610aa590610c44565b6109c56001600160a01b03821633146101a8610c48565b7f9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a681565b600560209081526000928352604080842090915290825290205481565b6000610bd18383610d59565b610c2057508154600180820184556000848152602080822090930180546001600160a01b0319166001600160a01b038616908117909155855490825282860190935260409020919091556105ec565b5060006105ec565b8154600090610c3a9083106064610c48565b610aa58383610ea7565b5490565b816109cf576109cf81610ed4565b6001600160a01b038116610c7c5760405162461bcd60e51b81526004016106639061130e565b6000838152602081815260408083206001600160a01b03851684526002019091529020610ca99083610bc5565b15610cfb57336001600160a01b0316826001600160a01b0316847fcaba87d53b293d545d69ab305284377793434c6fb5428e6244bfadcd4342237084604051610cf29190611241565b60405180910390a45b505050565b6000828152602081905260409020610d189082610f27565b156109cf5760405133906001600160a01b0383169084907fd8476cf9ac7354675e06297f0a3b1f57e056db7e4cefe100071b4ade0983641590600090a45050565b6001600160a01b031660009081526001919091016020526040902054151590565b60005b81811015610992576000858152602081905260408120610ddd91869160020190868686818110610da957fe5b9050602002016020810190610dbe919061104c565b6001600160a01b03168152602081019190915260400160002090610f27565b15610e4657336001600160a01b038516867f473272920ac74dc08931f0d6687401dcb6dd700032e3935fc34aa5ab72459527868686818110610e1b57fe5b9050602002016020810190610e30919061104c565b604051610e3d9190611241565b60405180910390a45b600101610d7d565b6000828152602081905260409020610e669082610bc5565b156109cf5760405133906001600160a01b0383169084907f287e752593aea8255aeaa7ea93d3e06807273ef2426cde02d5572ee69f16e96990600090a45050565b6000826000018281548110610eb857fe5b6000918252602090912001546001600160a01b03169392505050565b62461bcd60e51b6000908152602060045260076024526642414c23000030600a808404818106603090810160081b95839006959095019082900491820690940160101b939093010160c81b604452606490fd5b6001600160a01b0381166000908152600183016020526040812054801561102b5783546000198083019101808214610fd3576000866000018281548110610f6a57fe5b60009182526020909120015487546001600160a01b0390911691508190889085908110610f9357fe5b600091825260208083209190910180546001600160a01b0319166001600160a01b0394851617905592909116815260018881019092526040902090830190555b8554869080610fde57fe5b60008281526020808220830160001990810180546001600160a01b03191690559092019092556001600160a01b03871682526001888101909152604082209190915593506105ec92505050565b60009150506105ec565b80356001600160a01b03811681146107a257600080fd5b60006020828403121561105d578081fd5b610aa582611035565b60008060408385031215611078578081fd5b61108183611035565b915061108f60208401611035565b90509250929050565b6000806000606084860312156110ac578081fd5b6110b584611035565b92506110c360208501611035565b9150604084013590509250925092565b600080604083850312156110e5578182fd5b6110ee83611035565b946020939093013593505050565b60006020828403121561110d578081fd5b5035919050565b60008060408385031215611126578182fd5b8235915061108f60208401611035565b60008060006060848603121561114a578283fd5b8335925061115a60208501611035565b915061116860408501611035565b90509250925092565b60008060008060608587031215611186578081fd5b8435935061119660208601611035565b9250604085013567ffffffffffffffff808211156111b2578283fd5b818701915087601f8301126111c5578283fd5b8135818111156111d3578384fd5b88602080830285010111156111e6578384fd5b95989497505060200194505050565b60008060408385031215611207578182fd5b50508035926020909101359150565b60008060006060848603121561122a578283fd5b833592506020840135915061116860408501611035565b6001600160a01b0391909116815260200190565b901515815260200190565b90815260200190565b6000602080835283518082850152825b8181101561129557858101830151858201604001528201611279565b818111156112a65783604083870101525b50601f01601f1916929092016040019392505050565b602080825260149082015273494e53554646494349454e545f42414c414e434560601b604082015260600190565b6020808252600a90820152692727aa2fa6a4a72a22a960b11b604082015260600190565b6020808252818101527f57686572652063616e277420626520474c4f42414c5f524f4c455f41444d494e604082015260600190565b602080825260169082015275494e53554646494349454e545f414c4c4f57414e434560501b604082015260600190565b60ff9190911681526020019056fea2646970667358221220e16bdf53ad81f31ff1ede0b77cf104ab7c18668cbc91e47b513cdaab7f111dfd64736f6c63430007060033";

type TestWETHConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: TestWETHConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class TestWETH__factory extends ContractFactory {
  constructor(...args: TestWETHConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    minter: PromiseOrValue<string>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<TestWETH> {
    return super.deploy(minter, overrides || {}) as Promise<TestWETH>;
  }
  override getDeployTransaction(
    minter: PromiseOrValue<string>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(minter, overrides || {});
  }
  override attach(address: string): TestWETH {
    return super.attach(address) as TestWETH;
  }
  override connect(signer: Signer): TestWETH__factory {
    return super.connect(signer) as TestWETH__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): TestWETHInterface {
    return new utils.Interface(_abi) as TestWETHInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): TestWETH {
    return new Contract(address, _abi, signerOrProvider) as TestWETH;
  }
}