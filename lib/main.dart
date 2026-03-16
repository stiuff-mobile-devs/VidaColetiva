import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:vidacoletiva/app.dart';
import 'package:vidacoletiva/firebase_options.dart';
import 'package:vidacoletiva/injection_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Proteção contra erro de duplicidade no iOS
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Initialize Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Enable debug view - opcional, o Firebase já habilita por padrão se configurado no console
  await analytics.setAnalyticsCollectionEnabled(true);

  await initilizeDependencies();

  runApp(const VidaColetiva());
}
