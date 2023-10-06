# Rally Protocol Flutter SDK Example App

this is an example of using the Rally Protocol Flutter SDK in a flutter App. This app allows you to create a new EOA for a user, the EOA is encrypted, saved to device and optionally backed up from the cloud. From there you can gaslessly claim an ERC20 token and use it to purchase an NFT (also gaslessly 🙌 )

- `/app` contains the mobile app code
  - `/lib/main.dart` UI
  - `/lib/services/nft.dart` shows an example of how to relay an arbitrary contract through our gasless tx relayer
- `contracts` contains the simple NFT contract used for demo app

[Rally Protocol Flutter SDK] [https://github.com/rally-dfs/rly-network-flutter-sdk]

[Rally Protocol Developer Docs] [https://docs.rallyprotocol.com/]
