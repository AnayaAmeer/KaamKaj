import 'package:flutter/material.dart';
import 'app.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    Stripe.publishableKey = "pk_test_51TsZJC1aI2TOzsIin32zHtBT8CH6DBd4eR5TkXth5gUPXksx6MB03e9v08ohbr8g53uOYYRWjGIkCS3qN5M8gIRY00aInS8SiN"; // apni asal key
    await Stripe.instance.applySettings();
  } catch (e) {
    debugPrint("Stripe init failed: $e");
  }

  runApp(const MyApp());
}