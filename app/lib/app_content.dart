import 'package:flutter/material.dart';
import 'package:flutter_example/screens/create_wallet_screen.dart';
import 'package:flutter_example/screens/wallet_home_screen.dart';

class AppContent extends StatelessWidget {
  const AppContent({
    super.key,
    required this.walletAddress,
    required this.setWalletAddress,
  });

  final String? walletAddress;
  final void Function(String?) setWalletAddress;

  @override
  Widget build(BuildContext context) {
    return (Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: walletAddress == null
          ? WalletCreationScreen(
              setWalletAddress: setWalletAddress,
            )
          : WalletHomeScreen(
              setWalletAddress: setWalletAddress,
              walletAddress: walletAddress!),
    ));
  }
}
