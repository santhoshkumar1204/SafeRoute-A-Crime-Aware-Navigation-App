// File generated manually based on Firebase Console credentials.
// Project: MTC-Commuter-App (mtc-commuter-app)
//
// To regenerate, run:
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=mtc-commuter-app

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAjRA-TZKevyp8sIbbQJPvsEJuK14V1gxo",
    authDomain: "mtc-commuter-app.firebaseapp.com",
    projectId: "mtc-commuter-app",
    storageBucket: "mtc-commuter-app.firebasestorage.app",
    messagingSenderId: "995301002773",
    appId: "1:995301002773:web:c615bf48d6bc79f610881c",
    measurementId: "G-T7210SBV7N"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'BIC5LSAuJRI59Gid7fbWXfSRA0xAghEKFq5F1rqXiZEAZW3oVQ4LftcRuw_dwdJ-4xAQLHiJJTvPUy4OawKTuNM',
    appId: '1:995301002773:android:692eb07a67358b9d10881c',
    messagingSenderId: '995301002773',
    projectId: 'mtc-commuter-app',
    storageBucket: 'mtc-commuter-app.firebasestorage.app',
  );
}
