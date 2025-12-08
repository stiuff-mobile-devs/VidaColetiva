import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:vidacoletiva/app.dart';
import 'package:vidacoletiva/firebase_options.dart';
import 'package:vidacoletiva/injection_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Enable debug view - remove this line in production!
  await analytics.setAnalyticsCollectionEnabled(true);

  await initilizeDependencies();

  runApp(const VidaColetiva());
}
