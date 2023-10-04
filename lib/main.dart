import 'package:flutter/material.dart';
import 'package:flutter_sdk/account.dart';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
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
    print("I got here");
    loadExistingWallet();
  }

  Future<void> loadExistingWallet() async {
    print("GOing to load existing wallet");
    String? existingWallet =
        await AccountsUtil.getInstance().getAccountAddress();
    print("Attempted to load existing wallet and got = $existingWallet");
    if (existingWallet != null) {
      cacheWalletAddress(existingWallet);
    }
  }

  void cacheWalletAddress(String walletAddress) {
    setState(() {
      _walletLoaded = true;
      _walletAddress = walletAddress;
    });
  }

  Future<void> createWallet() async {
    String walletAddress = await AccountsUtil.getInstance().createAccount();

    cacheWalletAddress(walletAddress);
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
              walletAddress: _walletAddress, createWallet: createWallet)
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
  const _WalletView({required this.walletAddress, required this.createWallet});

  final String? walletAddress;
  final VoidCallback createWallet;

  @override
  Widget build(BuildContext context) {
    final String heroText = walletAddress == null
        ? "Welcome, you don't appear to have a wallet"
        : 'Welcome: $walletAddress';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(heroText),
          if (walletAddress == null)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: createWallet,
                child: const Text('Generate a wallet'),
              ),
            )
        ],
      ),
    );
  }
}
