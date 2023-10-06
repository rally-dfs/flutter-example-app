import 'package:flutter/material.dart';
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
  bool _walletLoaded = false;
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
      _walletLoaded = true;
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
          Center(
            child: Text(heroText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                )),
          ),
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
