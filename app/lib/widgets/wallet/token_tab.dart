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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: _loading
          ? const Column(
              children: [
                CircularProgressIndicator(),
              ],
            )
          : Column(
              children: [
                const Text("\$RLY balance", style: TextStyle(fontSize: 18)),
                Text(
                  "$_balance",
                  style: const TextStyle(fontSize: 24),
                ),
                ElevatedButton(
                    onPressed: getBalance, child: const Text("Refresh")),
                if (_balance == 0) claimRlyWidget()
              ],
            ),
    );
  }

  Widget claimRlyWidget() {
    if (_claimingRly) {
      return (const Column(
        children: [Text("Claiming RLY..."), CircularProgressIndicator()],
      ));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          const Center(
            child: Text("Welcome New User to Rally Protocol!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                )),
          ),
          ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() {
                        _claimingRly = true;
                      });
                      await rlyNetwork.claimRly();
                      getBalance();
                    },
              child: const Text("Claim Your RLY"))
        ],
      ),
    );
  }
}
