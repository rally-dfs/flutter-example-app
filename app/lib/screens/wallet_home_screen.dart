import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_example/constants.dart';
import 'package:flutter_example/main.dart';
import 'package:flutter_example/services/nft.dart';
import 'package:flutter_example/widgets/wallet/token_tab.dart';
import 'package:http/http.dart';
import 'package:rly_network_flutter_sdk/account.dart';
import 'package:web3dart/web3dart.dart';

class WalletHomeScreen extends StatefulWidget {
  final void Function(String?) setWalletAddress;
  final String walletAddress;
  const WalletHomeScreen(
      {super.key, required this.walletAddress, required this.setWalletAddress});
  @override
  WalletHomeScreenState createState() => WalletHomeScreenState();
}

class WalletHomeScreenState extends State<WalletHomeScreen> {
  Future<void> clearWallet() async {
    AccountsUtil.getInstance().permanentlyDeleteAccount();
    widget.setWalletAddress(null);
  }

  Future<void> mintNFT() async {
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
      _nftUri = json['image'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 200),
              child: const Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(
                        text: "Tokens",
                      ),
                      Tab(
                        text: "NFTs",
                      )
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [TokenTab(), Text("NFTs")],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
