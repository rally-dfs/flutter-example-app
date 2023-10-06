import 'package:flutter/material.dart';

class AppContent extends StatelessWidget {
  const AppContent(
      {super.key,
      required this.walletAddress,
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
