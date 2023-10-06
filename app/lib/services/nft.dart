import 'package:web3dart/web3dart.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_example/contracts/TestNFT.dart';

class NFT {
  NFT();

  Future<void> getCreateNFT(
      EthereumAddress contractAddress, Web3Client provider) async {
    final abi = getTestNFTJson()['abi'];

    final token = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abi), 'TestNFT'),
      contractAddress,
    );

    final nameCallResult = await provider
        .call(contract: token, function: token.function('name'), params: []);

    print(nameCallResult[0]);
  }
}
