import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/src/app.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await GoogleSignIn.instance.initialize(
    clientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
  );
  runApp(const ProviderScope(child: MyApp()));
}
