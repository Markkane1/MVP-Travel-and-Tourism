import 'package:flutter/material.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Audit',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
