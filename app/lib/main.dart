import 'package:flutter/material.dart';
import 'package:flutter_example/app_content.dart';
import 'package:flutter_example/screens/app_loading_screen.dart';
import 'package:rly_network_flutter_sdk/account.dart';
import 'package:rly_network_flutter_sdk/network.dart';
import 'package:flutter_example/services/nft.dart';
import "package:flutter_example/constants.dart" as constants;
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

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
      title: 'EOA Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 72, 114, 197)),
        useMaterial3: true,
      ),
      home: const AppContainer(title: 'EOA Demo'),
    );
  }
}

class AppContainer extends StatefulWidget {
  const AppContainer({super.key, required this.title});

  final String title;

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  bool _appFinishedLoading = false;
  String? _walletAddress;
  double? _balance;

  @override
  void initState() {
    super.initState();
    attemptToLoadExistingWallet();
    getBalance();
    rlyNetwork.setApiKey(constants.rlyApiKey);
  }

  Future<void> attemptToLoadExistingWallet() async {
    String? existingWallet =
        await AccountsUtil.getInstance().getAccountAddress();
    setState(() {
      _appFinishedLoading = true;
      _walletAddress = existingWallet;
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

    setWalletAddress(walletAddress);
  }

  Future<void> clearWallet() async {
    AccountsUtil.getInstance().permanentlyDeleteAccount();
    setWalletAddress(null);
  }

  void setWalletAddress(String? walletAddress) {
    setState(() {
      _walletAddress = walletAddress;
    });
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
      body: _appFinishedLoading
          ? AppContent(
              walletAddress: _walletAddress,
              createWallet: createWallet,
              clearWallet: clearWallet,
              balance: _balance,
              mintNFT: mintNFT,
            )
          : const AppLoadingScreen(),
    );
  }
}
