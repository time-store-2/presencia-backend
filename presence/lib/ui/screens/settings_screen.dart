import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/themes/app_themes.dart';
import '../../core/services/export_service.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: AppBackground(
        child: ListView(
          padding: kPagePadding,
          children: [
            _SectionHeader(title: l10n.theme),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  RadioListTile<AppThemeType>(
                    title: Text(l10n.warmCommunity),
                    value: AppThemeType.warmCommunity,
                    groupValue: settings.themeType,
                    onChanged: (value) => settings.setTheme(value!),
                  ),
                  RadioListTile<AppThemeType>(
                    title: Text(l10n.auraLuxury),
                    value: AppThemeType.auraLuxury,
                    groupValue: settings.themeType,
                    onChanged: (value) => settings.setTheme(value!),
                  ),
                  RadioListTile<AppThemeType>(
                    title: Text(l10n.etherealSerenity),
                    value: AppThemeType.etherealSerenity,
                    groupValue: settings.themeType,
                    onChanged: (value) => settings.setTheme(value!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionHeader(title: l10n.language),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  RadioListTile<Locale>(
                    title: Text(l10n.french),
                    value: const Locale('fr'),
                    groupValue: settings.locale,
                    onChanged: (value) => settings.setLocale(value!),
                  ),
                  RadioListTile<Locale>(
                    title: Text(l10n.english),
                    value: const Locale('en'),
                    groupValue: settings.locale,
                    onChanged: (value) => settings.setLocale(value!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionHeader(title: l10n.data),
            GlassCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.download),
                title: Text(l10n.exportAttendanceCsv),
                subtitle: Text(l10n.exportAttendanceSubtitle),
                onTap: () async {
                  try {
                    final api =
                        context.read<AuthProvider>().apiService;
                    await ExportService(apiService: api)
                        .exportAttendanceToCSV();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.exportSuccess)),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.exportError(e.toString()))),
                      );
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            // GlassCard(
            //   padding: EdgeInsets.zero,
            //   child: ListTile(
            //     leading: const Icon(Icons.info_outline),
            //     title: Text(l10n.aboutApp),
            //     subtitle: Text(l10n.appVersion),
            //     onTap: () {
            //       showAboutDialog(
            //         context: context,
            //         applicationName: "Presencia",
            //         applicationVersion: "1.0.0",
            //         applicationIcon: const Icon(Icons.check_circle, size: 48, color: Colors.green),
            //         children: [
            //           Text(l10n.appDescription),
            //         ],
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
