import 'package:flutter/material.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Bookings',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
