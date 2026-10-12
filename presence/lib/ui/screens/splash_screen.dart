import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presencia/l10n/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/themes/app_themes.dart';
import 'onboarding_screen.dart';
import 'auth/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Restaure la session Payload (JWT) en parallèle du splash.
    final restore = context.read<AuthProvider>().tryRestoreSession();
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      restore,
    ]);
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool showOnboarding = prefs.getBool('show_onboarding') ?? true;

    if (showOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final design = Theme.of(context).extension<AppDesignSystem>();
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(design?.radiusMd ?? 20),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Presencia",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.splashTagline,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
