import 'package:flutter/material.dart';
import 'package:flutter_example/constants.dart';
import 'package:flutter_example/main.dart';
import 'package:flutter_example/services/nft.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class NftTab extends StatefulWidget {
  final String walletAddress;
  const NftTab({super.key, required this.walletAddress});

  @override
  State<StatefulWidget> createState() => NftTabState();
}

class NftTabState extends State<NftTab> {
  bool _hasMinted = false;
  bool _minting = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> mintNFT() async {
    setState(() {
      _minting = true;
    });
    var httpClient = Client();

    final provider = Web3Client(Constants.rpcURL, httpClient);

    final NFT nft = NFT(EthereumAddress.fromHex(Constants.nftContractAddress),
        EthereumAddress.fromHex(widget.walletAddress), provider);

    final nextNFTId = await nft.getCurrentNFTId();

    final gsnTx = await nft.getMintNFTTx();

    final String txHash = await rlyNetwork.relay(gsnTx);

    final String tokenURI = await nft.getTokenURI(nextNFTId);

    setState(() {
      _hasMinted = true;
      _minting = false;
    });

    print("current nft: $nextNFTId");
    print("tokenURI: $tokenURI");
    print("txHash: $txHash");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: _minting
          ? const Column(
              children: [
                CircularProgressIndicator(),
              ],
            )
          : Column(
              children: [if (!_hasMinted) mintNftWidget()],
            ),
    );
  }

  Widget mintNftWidget() {
    if (_minting) {
      return (const Column(
        children: [Text("Claiming RLY..."), CircularProgressIndicator()],
      ));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          const Center(
            child: Text("You don't have an NFT yet.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                )),
          ),
          ElevatedButton(
              onPressed: _minting
                  ? null
                  : () {
                      mintNFT();
                    },
              child: const Text("Mint NFT"))
        ],
      ),
    );
  }
}
