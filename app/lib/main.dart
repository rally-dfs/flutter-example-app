import 'package:flutter/material.dart';
import 'package:rly_network_flutter_sdk/account.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Rally Protocol Secure Wallet Demo'),
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

  @override
  void initState() {
    super.initState();
    loadExistingWallet();
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

  Future<void> createWallet() async {
    print("start create wallet");
    String walletAddress = await AccountsUtil.getInstance().createAccount();

    cacheWalletAddress(walletAddress);
    print("end create wallet");
  }

  Future<void> clearWallet() async {
    AccountsUtil.getInstance().permanentlyDeleteAccount();
    cacheWalletAddress(null);
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
              clearWallet: clearWallet)
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
      required this.clearWallet});

  final String? walletAddress;
  final VoidCallback createWallet;
  final VoidCallback clearWallet;

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
          if (walletAddress != null)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: clearWallet,
                child: const Text('Delete Existing Wallet'),
              ),
            )
        ],
      ),
    );
  }
}
