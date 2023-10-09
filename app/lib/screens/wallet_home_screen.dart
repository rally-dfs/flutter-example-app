import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example/constants.dart';
import 'package:flutter_example/main.dart';
import 'package:flutter_example/services/nft.dart';
import 'package:http/http.dart';
import 'package:rly_network_flutter_sdk/account.dart';
import 'package:web3dart/web3dart.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String? _nftUri;
  String? _nftTxHash;
  String? _tokensClaimedTxHash;
  bool _tokensClaimed = false;

  @override
  void initState() {
    getBalance();
    super.initState();
  }

  Future<void> clearWallet() async {
    AccountsUtil.getInstance().permanentlyDeleteAccount();
    widget.setWalletAddress(null);
  }

  Future<void> getBalance() async {
    print("getting balance");
    double balance = await rlyNetwork.getBalance();
    print("balance is ${balance}");
    setState(() {
      _balance = balance;
    });
  }

  Future<void> claimERC20() async {
    print("start claiming");
    final txHash = await rlyNetwork.claimRly();
    print("claiming erc20 ${txHash}");
    await getBalance();
    setState(() {
      _tokensClaimed = true;
      _tokensClaimedTxHash = txHash;
    });
  }

  Future<void> mintNFT() async {
    print("start minting");
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

    print("end minting: tx hash $txHash");

    setState(() {
      _nftUri = json['image'];
      _nftTxHash = txHash;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_nftUri != null) {
      return Column(children: <Widget>[
        const Center(
            child: Padding(
          padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
          child: Text("You did it! Demo Complete!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
              )),
        )),
        Image(
          image: NetworkImage(_nftUri!),
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 20, 10, 10),
          child: InkWell(
              child: const Text(
                'View NFT on Explorer',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () async {
                await launchUrl(
                    Uri.parse("${Constants.explorerUrl}/tx/$_nftTxHash"));
              }),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: InkWell(
              child: const Text(
                'View Rally Protocol Docs',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () async {
                await launchUrl(Uri.parse(Constants.docsUrl));
              }),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: clearWallet,
            child: const Text('Reset Demo'),
          ),
        ),
      ]);
    } else if ((_tokensClaimed || (_balance != null && _balance! > 0)) &&
        _nftUri == null) {
      return Column(children: <Widget>[
        const Center(
            child: Padding(
          padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
          child: Text("ERC20 tokens claimed successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
              )),
        )),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 10),
          child: InkWell(
              child: const Text(
                'View tokens on Explorer',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () async {
                await launchUrl(Uri.parse(
                    "${Constants.explorerUrl}/tx/$_tokensClaimedTxHash"));
              }),
        ),
        const Center(
            child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Now let's mint and NFT. Click below to claim your Rally Protocol Flutter SDK demo NFT!",
                  textAlign: TextAlign.center,
                ))),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: mintNFT,
            child: const Text('Mint NFT'),
          ),
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: Text(
                "This will mint an NFT without the user needing native tokens in their wallet",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12.0,
                )),
          ),
        ),
      ]);
    } else if (!_tokensClaimed) {
      return Column(children: <Widget>[
        const Center(
            child: Padding(
          padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
          child: Text("Success!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
              )),
        )),
        Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  const TextSpan(
                      text: "Your wallet address is:",
                      style: TextStyle(fontSize: 16.0, color: Colors.black)),
                  TextSpan(
                      text: "\n${widget.walletAddress}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await launchUrl(Uri.parse(
                              "${Constants.explorerUrl}/address/${widget.walletAddress}"));
                        }),
                ]),
              )),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 30.0, left: 10, right: 10),
          child: Text("Now let's claim some ERC20 tokens gasslessly!"),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: claimERC20,
            child: const Text('Claim ERC20'),
          ),
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: Text(
                "This will claim 10 units of an ERC20 contract without the user needing native tokens in their wallet",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12.0,
                )),
          ),
        ),
      ]);
    } else {
      return const Text('nothing to see here');
    }
  }
}
