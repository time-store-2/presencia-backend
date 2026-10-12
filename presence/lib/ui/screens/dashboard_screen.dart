import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presencia/l10n/app_localizations.dart';
import '../../core/providers/adolescent_provider.dart';
import '../../core/providers/attendance_provider.dart';
import '../../core/providers/group_provider.dart';
import '../../core/themes/app_themes.dart';
import '../widgets/app_background.dart';
import 'add_adolescent_screen.dart';
import 'attendance_sessions_screen.dart';
import 'stats_screen.dart';
import 'take_attendance_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _coverImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCoverImage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdolescentProvider>().loadAdolescents();
      context.read<GroupProvider>().loadGroups();
      context.read<AttendanceProvider>().loadSessions();
    });
  }

  Future<void> _loadCoverImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _coverImagePath = prefs.getString('dashboard_cover_image');
    });
  }

  Future<void> _pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dashboard_cover_image', image.path);
      setState(() {
        _coverImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final adolescentProvider = context.watch<AdolescentProvider>();
    final sessionProvider = context.watch<AttendanceProvider>();
    final theme = Theme.of(context);
    final stats = sessionProvider.globalStats;

    int totalYouth = adolescentProvider.adolescents.length;
    int presentToday = 0;
    int absentToday = 0;
    double presenceRateToday = 0.0;

    if (stats.isNotEmpty && stats['todayCounts'] != null) {
      final today = stats['todayCounts'] as Map<String, int>;
      final p = today['present'] ?? 0;
      final l = today['late'] ?? 0;
      final a = today['absent'] ?? 0;
      final e = today['excused'] ?? 0;
      presentToday = p + l;
      absentToday = a;
      // Le taux se calcule sur les membres marqués aujourd'hui,
      // pas sur le total des membres (sinon il est sous-évalué
      // dès qu'un seul groupe a fait l'appel).
      final markedToday = p + l + a + e;
      presenceRateToday = markedToday > 0 ? (p + l) / markedToday : 0.0;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AppBackground(
        useSafeArea: true,
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<AdolescentProvider>().loadAdolescents();
            await context.read<AttendanceProvider>().loadSessions();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: kPagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, l10n, theme),
                const SizedBox(height: 24),
                _buildHeroCard(context),
                const SizedBox(height: 32),
                _buildQuickActions(context, l10n, theme),
                const SizedBox(height: 32),
                _buildStatsGrid(context, totalYouth, presentToday, absentToday, presenceRateToday, l10n),
                
                if (sessionProvider.inactivityAlerts.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    l10n.inactivityAlerts,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInactivityAlerts(context, sessionProvider.inactivityAlerts, l10n),
                ],

                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.recentSessions,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AttendanceSessionsScreen()),
                      ),
                      child: Text(l10n.viewAll, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (sessionProvider.sessions.isEmpty)
                  _buildEmptySessions(context, l10n)
                else
                  ...sessionProvider.sessions.take(2).map((session) => _buildSessionCard(context, session)),
                const SizedBox(height: 100), // Espace pour la barre de navigation
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.hello,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            Text(
              l10n.dashboard,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        Row(
          children: [
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              ),
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.insights_outlined, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: _pickCoverImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _coverImagePath != null
                  ? Image.file(
                      File(_coverImagePath!),
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      "https://images.unsplash.com/photo-1523580494863-6f3031224c94?q=80&w=2070&auto=format&fit=crop",
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Theme.of(context).colorScheme.primaryContainer),
                    ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.todayHeroLabel,
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   l10n.defaultEventTitle,
                    //   style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            label: l10n.takeAttendance,
            icon: Icons.how_to_reg_rounded,
            color: theme.colorScheme.primary,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceSessionsScreen())),
            filled: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            label: l10n.addYouth,
            icon: Icons.person_add_rounded,
            color: theme.colorScheme.primary,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAdolescentScreen())),
            filled: false,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, int total, int present, int absent, double rate, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<StatusColors>()!;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.25,
      children: [
        _StatBox(title: l10n.total, subtitle: l10n.members, value: total.toString(), icon: Icons.group_rounded, color: theme.colorScheme.primary),
        _StatBox(title: l10n.present, subtitle: l10n.today, value: present.toString(), icon: Icons.check_circle_rounded, color: statusColors.presentText, bgColor: statusColors.presentBg),
        _StatBox(title: l10n.absent, subtitle: l10n.toRelanch, value: absent.toString(), icon: Icons.cancel_rounded, color: statusColors.absentText, bgColor: statusColors.absentBg),
        _StatBox(title: l10n.rate, subtitle: l10n.presenceRate, value: "${(rate * 100).toStringAsFixed(0)}%", icon: Icons.analytics_rounded, color: statusColors.lateText, bgColor: statusColors.lateBg),
      ],
    );
  }

  Widget _buildSessionCard(BuildContext context, dynamic session) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.calendar_today_rounded, color: theme.colorScheme.primary),
        ),
        title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        subtitle: Text(session.date.toString().split(' ')[0], style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
        trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.primary.withOpacity(0.5)),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TakeAttendanceScreen(sessionId: session.id!, groupId: session.groupId!))),
      ),
    );
  }

  Widget _buildInactivityAlerts(BuildContext context, List<Map<String, dynamic>> alerts, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 28),
                const SizedBox(height: 8),
                Text("${alert['first_name']} ${alert['last_name']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(l10n.absences(alert['missing_count'] as int), style: TextStyle(color: theme.colorScheme.error, fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptySessions(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text(l10n.noRecentSessions, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  const _ActionCard({required this.label, required this.icon, required this.color, required this.onTap, required this.filled});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = filled ? theme.colorScheme.onPrimary : color;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: filled ? color : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: filled ? null : Border.all(color: color.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: filled ? color.withOpacity(0.3) : Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;
  final Color? bgColor;

  const _StatBox({required this.title, required this.subtitle, required this.value, required this.icon, required this.color, this.bgColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 8), Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900))]),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: color)),
          Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
