import 'package:rly_network_flutter_sdk/gsnClient/utils.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:convert';
import 'package:flutter_example/contracts/TestNFT.dart';

class NFT {
  final EthereumAddress contractAddress;
  final EthereumAddress accountAddress;
  final Web3Client provider;

  NFT(this.contractAddress, this.accountAddress, this.provider);

  Future<BigInt> getCurrentNFTId() async {
    final abi = getTestNFTJson()['abi'];

    final token = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abi), 'TestNFT'),
      contractAddress,
    );

    final tx = await provider.call(
        contract: token, function: token.function("tokenIds"), params: []);

    return tx[0];
  }

  Future<String> getTokenURI(tokenId) async {
    final abi = getTestNFTJson()['abi'];

    final token = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abi), 'TestNFT'),
      contractAddress,
    );

    final tx = await provider.call(
        contract: token,
        function: token.function("getTokenURI"),
        params: [tokenId]);

    return tx[0];
  }

  Future<GsnTransactionDetails> getMintNFTTx() async {
    final abi = getTestNFTJson()['abi'];

    final token = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abi), 'TestNFT'),
      contractAddress,
    );

    final tx = token.function("mint").encodeCall([]);

    final gas = await provider.estimateGas(
      sender: accountAddress,
      data: tx,
      to: contractAddress,
    );

    final info = await provider.getBlockInformation();

    final BigInt maxPriorityFeePerGas = BigInt.parse("1500000000");
    final maxFeePerGas =
        info.baseFeePerGas!.getInWei * BigInt.from(2) + (maxPriorityFeePerGas);

    final gsnTx = GsnTransactionDetails(
      from: accountAddress.hex,
      data: '0x${bytesToHex(tx)}',
      value: "0",
      to: contractAddress.hex,
      gas: "0x${gas.toRadixString(16)}",
      maxFeePerGas: maxFeePerGas.toString(),
      maxPriorityFeePerGas: maxPriorityFeePerGas.toString(),
    );

    return gsnTx;
  }
}
