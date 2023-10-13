import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_example/constants.dart';
import 'package:flutter_example/main.dart';
import 'package:flutter_example/services/nft.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';

class NftTab extends StatefulWidget {
  final String walletAddress;
  const NftTab({super.key, required this.walletAddress});

  @override
  State<StatefulWidget> createState() => NftTabState();
}

class NftTabState extends State<NftTab> {
  bool _hasLoaded = false;
  bool _hasMinted = false;
  bool _minting = false;
  String? _nftUri;
  String? _txnHash;

  @override
  void initState() {
    super.initState();

    _loadExistingStateFromStorage();
  }

  Future<void> _loadExistingStateFromStorage() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    final storedData = sharedPrefs.getStringList('nft_txn_hash');

    if (storedData == null || storedData.length < 2) {
      setState(() {
        _hasLoaded = true;
      });
      return;
    }

    final existingHash = storedData[0];
    final existingUri = storedData[1];

    setState(() {
      _txnHash = existingHash;
      _nftUri = existingUri;
      _hasMinted = true;
      _hasLoaded = true;
    });
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
    final String imageUri = json['image'];

    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setStringList('nft_txn_hash', [txHash, imageUri]);

    setState(() {
      _hasMinted = true;
      _minting = false;
      _nftUri = imageUri;
      _txnHash = txHash;
    });
  }

  Future<void> _showTransactionOnExplorer() async {
    final Uri explorerUrl = Uri.parse("${Constants.explorerUrl}/tx/$_txnHash");
    if (!await launchUrl(explorerUrl)) {
      throw Exception('Could not launch ${explorerUrl.toString()}');
    }
  }

  Widget _nftWidget() {
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
                    _showTransactionOnExplorer();
                  },
                  child: const Text("view on chain"),
                )))
      ],
    );
  }

  Widget _mintNftWidget() {
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
              child: const Text("Mint NFT")),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 30),
            child: Center(
              child: Text(
                  "This will mint an NFT without user needing any native tokens to pay for gas.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12.0,
                  )),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLoaded) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: _hasMinted ? _nftWidget() : _mintNftWidget());
  }
}
