import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/env.dart';

/// Bootstraps the application, runs configuration setups, and handles errors.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Capture Flutter framework errors
  FlutterError.onError = (details) {
    if (Env.isProd) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  // Run app in an error-boundary zone
  unawaited(runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Android can auto-create the default app via FirebaseInitProvider.
    try {
      Firebase.app();
    } on FirebaseException catch (error) {
      if (error.code != 'no-app') {
        rethrow;
      }
      try {
        await Firebase.initializeApp(options: Env.firebaseOptions);
      } on FirebaseException catch (initializeError) {
        if (initializeError.code != 'duplicate-app') {
          rethrow;
        }
        Firebase.app();
      }
    }

    // Initialize Firebase Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(Env.isProd);

    if (Env.isProd) {
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
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

    // Initialize Firebase App Check
    await FirebaseAppCheck.instance.activate(
      providerAndroid: Env.isProd
          ? const AndroidPlayIntegrityProvider()
          : const AndroidDebugProvider(),
      providerApple: Env.isProd
          ? const AppleDeviceCheckProvider()
          : const AppleDebugProvider(),
    );

    final appWidget = await builder();

    runApp(
      ProviderScope(
        child: appWidget,
      ),
    );
  }, (error, stackTrace) {
    if (Env.isProd) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    } else {
      if (kDebugMode) {
        print('Caught unhandled error in zone: $error');
        print(stackTrace);
      }
    }
  }));
}
