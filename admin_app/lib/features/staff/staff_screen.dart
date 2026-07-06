import 'package:flutter/material.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Staff',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
