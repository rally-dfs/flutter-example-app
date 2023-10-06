import 'package:flutter/material.dart';
import 'package:flutter_example/app_content.dart';
import 'package:flutter_example/constants.dart';
import 'package:flutter_example/screens/app_loading_screen.dart';
import 'package:rly_network_flutter_sdk/account.dart';
import 'package:rly_network_flutter_sdk/network.dart';

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

  @override
  void initState() {
    super.initState();
    attemptToLoadExistingWallet();
    rlyNetwork.setApiKey(Constants.rlyApiKey);
  }

  Future<void> attemptToLoadExistingWallet() async {
    String? existingWallet =
        await AccountsUtil.getInstance().getAccountAddress();
    setState(() {
      _appFinishedLoading = true;
      _walletAddress = existingWallet;
    });
  }

  void setWalletAddress(String? walletAddress) {
    setState(() {
      _walletAddress = walletAddress;
    });
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
              setWalletAddress: setWalletAddress,
            )
          : const AppLoadingScreen(),
    );
  }
}
