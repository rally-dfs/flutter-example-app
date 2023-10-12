import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_example/constants.dart';
import 'package:flutter_example/main.dart';
import 'package:flutter_example/services/nft.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class NftTab extends StatefulWidget {
  final String walletAddress;
  const NftTab({super.key, required this.walletAddress});

  @override
  State<StatefulWidget> createState() => NftTabState();
}

class NftTabState extends State<NftTab> {
  bool _hasMinted = false;
  bool _minting = false;
  String? _nftUri;

  @override
  void initState() {
    super.initState();
  }

  Future<void> mintNFT() async {
    setState(() {
      _minting = true;
    });
    var httpClient = Client();

    final provider = Web3Client(Constants.rpcURL, httpClient);

    final NFT nft = NFT(EthereumAddress.fromHex(Constants.nftContractAddress),
        EthereumAddress.fromHex(widget.walletAddress), provider);

    final nextNFTId = await nft.getCurrentNFTId();

    final gsnTx = await nft.getMintNFTTx();

    final String txHash = await rlyNetwork.relay(gsnTx);

    final String tokenURI = await nft.getTokenURI(nextNFTId);

    final parts = tokenURI.split(",");

    final base64Data = utf8.decode(base64.decode(parts[1]));

    final Map<String, dynamic> json = jsonDecode(base64Data);

    setState(() {
      _hasMinted = true;
      _minting = false;
      _nftUri = json['image'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: _hasMinted ? nftWidget() : mintNftWidget());
  }

  Widget nftWidget() {
    if (_nftUri == null) {
      return const Center(
        child: Text("Something went wrong. Please try again.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
            )),
      );
    }
    return Column(
      children: [
        const Center(
            child: Padding(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: Text("Gasless NFT Minted!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
              )),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Center(
            child: Image(
              image: NetworkImage(_nftUri!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
            child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: TextButton(
                  onPressed: () {
                    print("Will open browser");
                  },
                  child: const Text("view on chain"),
                )))
      ],
    );
  }

  Widget mintNftWidget() {
    if (_minting) {
      return (const Column(
        children: [
          Text("Minting your NFT..."),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: CircularProgressIndicator(),
          )
        ],
      ));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          const Center(
            child: Text("You don't have an NFT yet.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                )),
          ),
          ElevatedButton(
              onPressed: _minting
                  ? null
                  : () {
                      mintNFT();
                    },
              child: const Text("Mint NFT"))
        ],
      ),
    );
  }
}
