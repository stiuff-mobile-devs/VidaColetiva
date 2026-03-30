import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:vidacoletiva/app.dart';
import 'package:vidacoletiva/firebase_options.dart';
import 'package:vidacoletiva/injection_setup.dart';

Future<void> _initializeFirebaseSafely() async {
  try {
    Firebase.app();
    return;
  } on FirebaseException catch (error) {
    if (error.code != 'no-app') {
      rethrow;
    }
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (error) {
    if (error.code != 'duplicate-app') {
      rethrow;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeFirebaseSafely();

  // Initialize Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Enable debug view - opcional, o Firebase já habilita por padrão se configurado no console
  await analytics.setAnalyticsCollectionEnabled(true);

  await initilizeDependencies();

  runApp(const VidaColetiva());
}
