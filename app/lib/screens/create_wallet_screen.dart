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
        child: Padding(
          padding: EdgeInsets.only(top: 50.0, left: 10, right: 10),
          child: Text("Welcome!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
              )),
        ),
      ),
      const Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Text("To get started let's create an EOA",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
              )),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: ElevatedButton(
          onPressed: createWallet,
          child: const Text('Generate EOA'),
        ),
      ),
      const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Text(
              "This will generate an EOA, encrypt it, store it locally and back up to cloud",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12.0,
              )),
        ),
      ),
    ]));
  }
}
