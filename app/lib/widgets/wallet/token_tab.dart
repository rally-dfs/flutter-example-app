import 'package:flutter/material.dart';
import 'package:flutter_example/main.dart';

class TokenTab extends StatefulWidget {
  const TokenTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TokenTabState();
}

class TokenTabState extends State<TokenTab> {
  double? _balance;
  bool _loading = false;
  bool _claimingRly = false;

  @override
  void initState() {
    super.initState();
    getBalance();
  }

  Future<void> getBalance() async {
    setState(() {
      _loading = true;
    });

    double balance = await rlyNetwork.getBalance();

    setState(() {
      _balance = balance;
      _loading = false;
    });
  }

  Future<void> claimRly() async {
    setState(() {
      _claimingRly = true;
    });
    await rlyNetwork.claimRly();
    await getBalance();
    setState(() {
      _claimingRly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: _balance == 0 ? claimRlyWidget() : alreadyClaimedUser(),
    );
  }

  Widget alreadyClaimedUser() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Center(
            child: Text('Congrats you\'ve claimed your gassless erc20 tokens',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        const Text("\$RLY balance", style: TextStyle(fontSize: 18)),
        Text(
          "$_balance",
          style: const TextStyle(fontSize: 24),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: TextButton(
              onPressed: () {
                print('will open browser');
              },
              child: const Text('view on chain')),
        )
      ],
    );
  }

  Widget claimRlyWidget() {
    if (_claimingRly) {
      return (const Column(
        children: [
          Text("Claiming RLY...", style: TextStyle(fontSize: 18)),
          Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: CircularProgressIndicator(),
          )
        ],
      ));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          const Center(
            child: Text("Welcome New User to Rally Protocol!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ElevatedButton(
                onPressed: _loading
                    ? null
                    : () {
                        claimRly();
                      },
                child: const Text("Claim ERC20")),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Center(
              child: Text(
                  "This will claim 10 units of an ERC20 contract without the user needing native tokens in their wallet",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12.0,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
