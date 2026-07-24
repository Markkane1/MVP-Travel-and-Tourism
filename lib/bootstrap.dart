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
    if (Env.isProd && !kIsWeb && Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  // Run app in an error-boundary zone
  unawaited(
    runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();

        // Safely initialize Firebase across platforms.
        // Android can auto-create the default app via FirebaseInitProvider.
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(options: Env.firebaseOptions);
        }

        if (!kIsWeb) {
          await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
            Env.isProd,
          );
        }

        if (Env.isProd && !kIsWeb) {
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

        if (kIsWeb && Env.isProd && !Env.hasProductionAppCheckWebSiteKey) {
          runApp(
            const _FatalConfigApp(
              message:
                  'A real FIREBASE_APP_CHECK_WEB_KEY is required for production web builds.',
            ),
          );
          return;
        }

        if (!kIsWeb || Env.isProd) {
          await FirebaseAppCheck.instance.activate(
            providerAndroid: Env.isProd
                ? const AndroidPlayIntegrityProvider()
                : const AndroidDebugProvider(),
            providerApple: Env.isProd
                ? const AppleDeviceCheckProvider()
                : const AppleDebugProvider(),
            providerWeb: kIsWeb
                ? ReCaptchaV3Provider(Env.appCheckWebSiteKey)
                : null,
          );
        } else if (kDebugMode) {
          debugPrint('Local debug mode: AppCheck bypassed for web.');
        }

        final appWidget = await builder();

        runApp(ProviderScope(child: appWidget));
      },
      (error, stackTrace) {
        if (Env.isProd && !kIsWeb && Firebase.apps.isNotEmpty) {
          FirebaseCrashlytics.instance.recordError(
            error,
            stackTrace,
            fatal: true,
          );
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

class _FatalConfigApp extends StatelessWidget {
  final String message;

  const _FatalConfigApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
