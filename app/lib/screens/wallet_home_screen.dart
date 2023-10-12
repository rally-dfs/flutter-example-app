import 'package:flutter/material.dart';
import 'package:flutter_example/widgets/wallet/nft_tab.dart';
import 'package:flutter_example/widgets/wallet/token_tab.dart';
import 'package:rly_network_flutter_sdk/account.dart';

class WalletHomeScreen extends StatefulWidget {
  final void Function(String?) setWalletAddress;
  final String walletAddress;
  const WalletHomeScreen(
      {super.key, required this.walletAddress, required this.setWalletAddress});
  @override
  WalletHomeScreenState createState() => WalletHomeScreenState();
}

class WalletHomeScreenState extends State<WalletHomeScreen> {
  Future<void> clearWallet() async {
    AccountsUtil.getInstance().permanentlyDeleteAccount();
    widget.setWalletAddress(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 200),
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(
                        text: "Tokens",
                      ),
                      Tab(
                        text: "NFTs",
                      )
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        TokenTab(walletAddress: widget.walletAddress),
                        NftTab(walletAddress: widget.walletAddress)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
