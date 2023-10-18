import 'package:flutter/material.dart';
import 'package:rly_network_flutter_sdk/wallet.dart';
import 'package:rly_network_flutter_sdk/wallet_manager.dart';

class WalletCreationScreen extends StatelessWidget {
  final void Function(String?) setWalletAddress;
  const WalletCreationScreen({super.key, required this.setWalletAddress});

  Future<void> createWallet() async {
    Wallet newWallet = await WalletManager.getInstance().createWallet();

    setWalletAddress(newWallet.address.hex);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: (Column(children: <Widget>[
        const Center(
          child: Text("Welcome!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
              )),
        ),
        const Center(
          child: Text("To get started let's create an EOA",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: ElevatedButton(
            onPressed: createWallet,
            child: const Text('Generate a wallet'),
          ),
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
                "This will generate an EOA, encrypt it, store it locally and back up to cloud",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12.0,
                )),
          ),
        )
      ])),
    );
  }
}
