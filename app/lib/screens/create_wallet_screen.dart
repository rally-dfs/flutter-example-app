import 'package:flutter/material.dart';
import 'package:rly_network_flutter_sdk/account.dart';

class WalletCreationScreen extends StatelessWidget {
  final void Function(String?) setWalletAddress;
  const WalletCreationScreen({super.key, required this.setWalletAddress});

  Future<void> createWallet() async {
    String walletAddress = await AccountsUtil.getInstance().createAccount();

    setWalletAddress(walletAddress);
  }

  @override
  Widget build(BuildContext context) {
    return (Column(children: <Widget>[
      const Center(
        child: Text("Welcome, you don't appear to have a wallet",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
            )),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: ElevatedButton(
          onPressed: createWallet,
          child: const Text('Generate a wallet'),
        ),
      ),
    ]));
  }
}
