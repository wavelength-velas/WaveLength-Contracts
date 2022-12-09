/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
  BytesLike,
  CallOverrides,
  PopulatedTransaction,
  Signer,
  utils,
} from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type {
  TypedEventFilter,
  TypedEvent,
  TypedListener,
  OnEvent,
  PromiseOrValue,
} from "../common";

export interface IBaseRelayerLibraryInterface extends utils.Interface {
  functions: {
    "getVault()": FunctionFragment;
  };

  getFunction(nameOrSignatureOrTopic: "getVault"): FunctionFragment;

  encodeFunctionData(functionFragment: "getVault", values?: undefined): string;

  decodeFunctionResult(functionFragment: "getVault", data: BytesLike): Result;

  events: {};
}

export interface IBaseRelayerLibrary extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IBaseRelayerLibraryInterface;

  queryFilter<TEvent extends TypedEvent>(
    event: TypedEventFilter<TEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TEvent>>;

  listeners<TEvent extends TypedEvent>(
    eventFilter?: TypedEventFilter<TEvent>
  ): Array<TypedListener<TEvent>>;
  listeners(eventName?: string): Array<Listener>;
  removeAllListeners<TEvent extends TypedEvent>(
    eventFilter: TypedEventFilter<TEvent>
  ): this;
  removeAllListeners(eventName?: string): this;
  off: OnEvent<this>;
  on: OnEvent<this>;
  once: OnEvent<this>;
  removeListener: OnEvent<this>;

  functions: {
    getVault(overrides?: CallOverrides): Promise<[string]>;
  };

  getVault(overrides?: CallOverrides): Promise<string>;

  callStatic: {
    getVault(overrides?: CallOverrides): Promise<string>;
  };

  filters: {};

  estimateGas: {
    getVault(overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    getVault(overrides?: CallOverrides): Promise<PopulatedTransaction>;
  };
}