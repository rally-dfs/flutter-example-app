import 'package:flutter/material.dart';

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(children: <Widget>[
        Text('Attempting to load existing wallet...'),
        CircularProgressIndicator()
      ]),
    );
  }
}
