import 'package:flutter/material.dart';
import 'package:flutter_example/constants.dart';
import 'package:flutter_example/main.dart';
import 'package:flutter_example/services/nft.dart';
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
  double? _balance;

  @override
  void initState() {
    super.initState();
    getBalance();
  }

  Future<void> clearWallet() async {
    AccountsUtil.getInstance().permanentlyDeleteAccount();
    widget.setWalletAddress(null);
  }

  Future<void> getBalance() async {
    print("getting balance");
    double balance = await rlyNetwork.getBalance();
    setState(() {
      _balance = balance;
    });
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

    print("current nft: $nextNFTId");
    print("tokenURI: $tokenURI");
    print("txHash: $txHash");
  }

  @override
  Widget build(BuildContext context) {
    return (Column(
      children: <Widget>[
        Center(
          child: Text("Welcome\n${widget.walletAddress}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18.0,
              )),
        ),
        if (_balance == null)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: mintNFT,
              child: const Text('mint nft'),
            ),
          ),
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text("No Balance"),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: clearWallet,
            child: const Text('Delete Existing Wallet'),
          ),
        ),
      ],
    ));
  }
}
