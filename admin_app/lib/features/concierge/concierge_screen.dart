import 'package:flutter/material.dart';

class ConciergeScreen extends StatelessWidget {
  const ConciergeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Concierge',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
