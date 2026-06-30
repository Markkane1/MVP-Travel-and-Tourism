import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bootstraps the application, runs configuration setups, and handles errors.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Capture Flutter framework errors
  FlutterError.onError = (details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      // Stub for Crashlytics in production (Prompt 3)
    }
  };

  // Run app in an error-boundary zone
  unawaited(runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Stub: Additional service initializations (Firebase, AppCheck, etc.)

    final appWidget = await builder();

    runApp(
      ProviderScope(
        child: appWidget,
      ),
    );
  }, (error, stackTrace) {
    if (kDebugMode) {
      print('Caught unhandled error in zone: $error');
      print(stackTrace);
    } else {
      // Stub for Crashlytics in production (Prompt 3)
    }
  }));
}
