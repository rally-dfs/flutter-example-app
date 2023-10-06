import 'package:flutter/material.dart';
import 'package:rly_network_flutter_sdk/account.dart';
import 'package:rly_network_flutter_sdk/network.dart';
import 'package:flutter_example/services/nft.dart';
import "package:flutter_example/constants.dart" as constants;
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:developer';

final rlyNetwork = rlyMumbaiNetwork;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 72, 114, 197)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'EOA Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _walletLoaded = false;
  String? _walletAddress;
  double? _balance;

  @override
  void initState() {
    super.initState();
    loadExistingWallet();
    getBalance();
    rlyNetwork.setApiKey(
        "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOjQ3fQ.AmObzvqJBFddxgBcLgM-yHb5hPT90sai3SyS_V2ieM1UgHkfroybK-Hc9gpGhUtG1wPBTak6EPSVBJzyl2Z97g");
  }

  Future<void> loadExistingWallet() async {
    String? existingWallet =
        await AccountsUtil.getInstance().getAccountAddress();
    print("App: Attempted to load existing wallet and got = $existingWallet");
    cacheWalletAddress(existingWallet);
  }

  void cacheWalletAddress(String? walletAddress) {
    setState(() {
      _walletLoaded = true;
      _walletAddress = walletAddress;
    });
  }

  Future<void> getBalance() async {
    print("getting balance");
    if (_walletAddress != null) {
      rlyNetwork.getBalance().then((balance) {
        setState(() {
          _balance = balance;
        });
      });
    }
  }

  Future<void> createWallet() async {
    String walletAddress = await AccountsUtil.getInstance().createAccount();

    cacheWalletAddress(walletAddress);
  }

  Future<void> clearWallet() async {
    AccountsUtil.getInstance().permanentlyDeleteAccount();
    cacheWalletAddress(null);
  }

  Future<void> mintNFT() async {
    var httpClient = Client();

    final provider = Web3Client(constants.rpcURL, httpClient);

    final NFT nft = NFT(EthereumAddress.fromHex(constants.nftContractAddress),
        EthereumAddress.fromHex(_walletAddress!), provider);

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _walletLoaded
          ? _WalletView(
              walletAddress: _walletAddress,
              createWallet: createWallet,
              clearWallet: clearWallet,
              balance: _balance,
              mintNFT: mintNFT,
            )
          : const _LoadingView(),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(children: <Widget>[
        Text('Attempting to load existing wallet...'),
        CircularProgressIndicator()
      ]),
    );
  }
}

class _WalletView extends StatelessWidget {
  const _WalletView(
      {required this.walletAddress,
      required this.createWallet,
      required this.clearWallet,
      required this.balance,
      this.mintNFT});

  final String? walletAddress;
  final VoidCallback createWallet;
  final VoidCallback clearWallet;
  final VoidCallback? mintNFT;
  final double? balance;

  @override
  Widget build(BuildContext context) {
    final String heroText = walletAddress == null
        ? "Welcome, you don't appear to have a wallet"
        : "Welcome\n $walletAddress";
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: Column(
        children: <Widget>[
          Text(heroText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18.0,
              )),
          if (walletAddress == null)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: createWallet,
                child: const Text('Generate a wallet'),
              ),
            ),
          if (walletAddress != null && balance == null)
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
          if (walletAddress != null)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: clearWallet,
                child: const Text('Delete Existing Wallet'),
              ),
            ),
        ],
      ),
    );
  }
}
