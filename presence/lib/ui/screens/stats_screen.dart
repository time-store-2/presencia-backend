import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/providers/attendance_provider.dart';
import '../../core/providers/member_provider.dart';
import '../../core/themes/app_themes.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_background.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadSessions();
      context.read<MemberProvider>().loadMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final design = Theme.of(context).extension<AppDesignSystem>()!;
    final memberProvider = context.watch<MemberProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final stats = attendanceProvider.globalStats;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stats),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () => attendanceProvider.loadSessions(),
          child: ListView(
            padding: kPagePadding,
            children: [
              _buildGlobalStats(context, memberProvider, attendanceProvider, l10n, design),
              SizedBox(height: design.spacingUnit * 3),
              Text(
                l10n.attendanceBreakdown,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: design.spacingUnit),
              if (stats.isNotEmpty) _buildStatusBreakdown(context, stats['globalCounts'], design, l10n),
              SizedBox(height: design.spacingUnit * 3),
              Text(
                l10n.topMostAttentive,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: design.spacingUnit),
              _buildRanking(context, attendanceProvider.topPresent, Colors.green, design, l10n),
              SizedBox(height: design.spacingUnit * 3),
              Text(
                l10n.topMostAbsent,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: design.spacingUnit),
              _buildRanking(context, attendanceProvider.topAbsent, Colors.red, design, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalStats(
    BuildContext context,
    MemberProvider memberProvider,
    AttendanceProvider attendanceProvider,
    AppLocalizations l10n,
    AppDesignSystem design,
  ) {
    final stats = attendanceProvider.globalStats;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: l10n.members,
                value: memberProvider.members.length.toString(),
                icon: Icons.people_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: design.spacingUnit * 2),
            Expanded(
              child: _StatTile(
                label: l10n.sessions,
                value: (stats['totalSessions'] ?? 0).toString(),
                icon: Icons.event_note_outlined,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBreakdown(BuildContext context, Map<String, dynamic> counts, AppDesignSystem design, AppLocalizations l10n) {
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    return GlassCard(
      child: Column(
        children: [
          _StatusRow(label: l10n.present, value: counts['present'] ?? 0, color: statusColors.presentText),
          const Divider(height: 0.1),
          _StatusRow(label: l10n.late, value: counts['late'] ?? 0, color: statusColors.lateText),
          const Divider(height: 0.1),
          _StatusRow(label: l10n.absent, value: counts['absent'] ?? 0, color: statusColors.absentText),
          const Divider(height: 0.1),
          _StatusRow(label: l10n.excused, value: counts['excused'] ?? 0, color: statusColors.excusedText),
        ],
      ),
    );
  }

  Widget _buildRanking(BuildContext context, List<Map<String, dynamic>> ranking, Color color, AppDesignSystem design, AppLocalizations l10n) {
    if (ranking.isEmpty) {
      return GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text(l10n.notEnoughData)),
        ),
      );
    }    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(ranking.length, (index) {
          final item = ranking[index];
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  radius: 16,
                  child: Text("${index + 1}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                title: Text("${item['first_name']} ${item['last_name']}", style: const TextStyle(fontSize: 14)),
                trailing: Text(
                  l10n.timesCount(item['count']),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
                ),
              ),
              if (index < ranking.length - 1) const Divider(height: 1, indent: 56, thickness: 0.1,),
            ],
          );
        }),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatusRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Text(value.toString(), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final design = Theme.of(context).extension<AppDesignSystem>()!;
    return GlassCard(
      padding: EdgeInsets.all(design.spacingUnit * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        ],
      ),
    );
  }
}
