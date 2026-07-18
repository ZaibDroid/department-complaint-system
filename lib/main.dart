import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Since you set up Android manually via google-services.json, 
  // calling initializeApp without options works for Android!
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding = prefs.getBool('dcms_onboarding_complete') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        isFirstLaunchProvider.overrideWithValue(!hasCompletedOnboarding),
      ],
      child: const DCMSApp(),
    ),
  );
}

class DCMSApp extends ConsumerWidget {
  const DCMSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'DCMS',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
