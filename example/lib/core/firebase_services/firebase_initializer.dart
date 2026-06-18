import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AppBootstrapper {
  static Future<void> run({
    required Widget app,
    required FirebaseOptions firebaseOptions,
  }) async {
    await Firebase.initializeApp(
      options: firebaseOptions,
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        fatal: false,
      );
      return true;
    };

    runApp(app);
  }
}
