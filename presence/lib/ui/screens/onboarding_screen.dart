import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presencia/l10n/app_localizations.dart';
import '../../core/themes/app_themes.dart';
import 'auth/auth_wrapper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingData> _buildPages(AppLocalizations l10n) {
    return [
      OnboardingData(
        title: l10n.onboardingWelcomeTitle,
        description: l10n.onboardingWelcomeDescription,
        icon: Icons.groups_rounded,
      ),
      OnboardingData(
        title: l10n.onboardingAttendanceTitle,
        description: l10n.onboardingAttendanceDescription,
        icon: Icons.check_circle_outline,
      ),
      OnboardingData(
        title: l10n.onboardingContactTitle,
        description: l10n.onboardingContactDescription,
        icon: Icons.contact_phone_outlined,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final design = Theme.of(context).extension<AppDesignSystem>()!;
    final l10n = AppLocalizations.of(context)!;
    final pages = _buildPages(l10n);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(data: pages[index]);
                },
              ),
            ),
            Padding(
              padding: kPagePadding,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => _buildDot(index, context),
                    ),
                  ),
                  SizedBox(height: design.spacingUnit * 4),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () async {
                        if (_currentPage == pages.length - 1) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('show_onboarding', false);
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const AuthWrapper()),
                            );
                          }
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      child: Text(_currentPage == pages.length - 1 ? l10n.start : l10n.next),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: _currentPage == index ? 20 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: _currentPage == index
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withOpacity(0.2),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;

  OnboardingData({required this.title, required this.description, required this.icon});
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final design = Theme.of(context).extension<AppDesignSystem>()!;
    
    return Padding(
      padding: kPagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            data.icon,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: design.spacingUnit * 6),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: design.spacingUnit * 2),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
