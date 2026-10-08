import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/theme/anchor_theme.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load SUPABASE_URL, SUPABASE_ANON_KEY etc. from the bundled .env file
  await dotenv.load(fileName: '.env');

  // Initialize Supabase Backend Client
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: AnchorApp(),
    ),
  );
}

class AnchorApp extends StatelessWidget {
  const AnchorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anchor — Your Family. Secured.',
      debugShowCheckedModeBanner: false,
      theme: AnchorTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
