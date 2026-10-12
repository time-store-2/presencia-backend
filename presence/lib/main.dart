import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'l10n/app_localizations.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/group_provider.dart';
import 'core/providers/adolescent_provider.dart';
import 'core/providers/attendance_provider.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/youth_list_screen.dart';
import 'ui/screens/attendance_sessions_screen.dart';
import 'ui/screens/groups_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsProvider = SettingsProvider();
  // Une seule instance ApiService partagée : le token JWT de l'auth
  // est automatiquement réutilisé par tous les providers.
  final apiService = ApiService();
  final groupProvider = GroupProvider(apiService: apiService);
  final adolescentProvider = AdolescentProvider(apiService: apiService);
  final attendanceProvider = AttendanceProvider(apiService: apiService);
  final authProvider = AuthProvider(apiService: apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: groupProvider),
        ChangeNotifierProvider.value(value: adolescentProvider),
        ChangeNotifierProvider.value(value: attendanceProvider),
      ],
      child: const PresenciaApp(),
    ),
  );
}

class PresenciaApp extends StatelessWidget {
  const PresenciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Presencia',
      debugShowCheckedModeBanner: false,
      theme: settings.currentTheme,
      locale: settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      home: const SplashScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    final List<Widget> screens = [
      const DashboardScreen(),
      const YouthListScreen(),
      const AttendanceSessionsScreen(),
      const GroupsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AnimatedBottomNavigationBar.builder(
          itemCount: 5,
          activeIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          height: 68,
          elevation: 0,
          splashColor: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
          leftCornerRadius: 24,
          rightCornerRadius: 24,
          scaleFactor: 0,
          gapLocation: GapLocation.none,
          tabBuilder: (index, isActive) => _buildTab(index, isActive, theme, l10n),
        ),
      ),
    );
  }

  Widget _buildTab(int index, bool isActive, ThemeData theme, AppLocalizations l10n) {
    const icons = [
      Icons.home_outlined,
      Icons.people_outline_rounded,
      Icons.check_circle_outline_rounded,
      Icons.hub_outlined,
      Icons.settings_outlined,
    ];
    final labels = [l10n.dashboard, l10n.youth, l10n.attendance, l10n.groups, l10n.settings];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icons[index],
          size: 24,
          color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 14,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isActive
                ? Text(
                    labels[index],
                    key: ValueKey('label_$index'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                : SizedBox.shrink(key: ValueKey('empty_$index')),
          ),
        ),
      ],
    );
  }
}
