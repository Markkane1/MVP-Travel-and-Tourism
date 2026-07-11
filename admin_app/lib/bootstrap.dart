import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/env.dart';

/// Bootstraps the application, runs configuration setups, and handles errors.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Capture Flutter framework errors
  FlutterError.onError = (details) {
    if (Env.isProd) {
      // Add Firebase Crashlytics if needed later
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  // Run app in an error-boundary zone
  unawaited(
    runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();

        // Initialize Firebase for Web
        await Firebase.initializeApp(options: Env.firebaseOptions);

        if (Env.isProd) {
          PlatformDispatcher.instance.onError = (error, stack) {
            // Log to crashlytics later if configured
            return true;
          };
        } else {
          PlatformDispatcher.instance.onError = (error, stack) {
            if (kDebugMode) {
              print('Uncaught async error in debug mode: $error');
              print(stack);
            }
            return true;
          };
        }

        final appWidget = await builder();

        runApp(ProviderScope(child: appWidget));
      },
      (error, stackTrace) {
        if (Env.isProd) {
          // Log to crashlytics
        } else {
          if (kDebugMode) {
            print('Caught unhandled error in zone: $error');
            print(stackTrace);
          }
        }
      },
    ),
  );
}
