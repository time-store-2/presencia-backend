import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../core/providers/attendance_provider.dart';
import '../../core/providers/group_provider.dart';
import '../../core/services/already_exists_exception.dart';
import '../../models/attendance_session.dart';
import '../../core/themes/app_themes.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_background.dart';
import 'take_attendance_screen.dart';
import 'session_detail_screen.dart';
import 'attendance_report_screen.dart';

class AttendanceSessionsScreen extends StatefulWidget {
  const AttendanceSessionsScreen({super.key});

  @override
  State<AttendanceSessionsScreen> createState() => _AttendanceSessionsScreenState();
}

class _AttendanceSessionsScreenState extends State<AttendanceSessionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadSessions();
      context.read<GroupProvider>().loadGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AttendanceProvider>();
    final design = Theme.of(context).extension<AppDesignSystem>()!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.attendance),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AttendanceReportScreen()),
            ),
            tooltip: l10n.periodReport,
          ),
        ],
      ),
      body: AppBackground(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.sessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        Text(l10n.noSessions),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: kPagePadding,
                    itemCount: provider.sessions.length,
                    itemBuilder: (context, index) {
                      final session = provider.sessions[index];
                      return GlassCard(
                        margin: EdgeInsets.only(bottom: design.spacingUnit * 4),
                        padding: EdgeInsets.zero,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SessionDetailScreen(session: session),
                            ),
                          ).then((_) => context.read<AttendanceProvider>().loadSessions());
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.calendar_today_rounded, color: theme.colorScheme.primary),
                          ),
                          title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(session.date)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit_note_rounded, color: theme.colorScheme.primary),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TakeAttendanceScreen(
                                        sessionId: session.id!,
                                        groupId: session.groupId!,
                                      ),
                                    ),
                                  ).then((_) => context.read<AttendanceProvider>().loadSessions());
                                },
                                tooltip: l10n.editAttendance,
                              ),
                              // const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                          onLongPress: () => _confirmDelete(context, session),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'sessions_fab',
        onPressed: () => _showCreateSessionDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.newSession),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AttendanceSession session) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSessionQuestion),
        content: Text(l10n.confirmDeleteSession(session.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              await context.read<AttendanceProvider>().deleteSession(session.id!);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context) async {
    final groupProvider = context.read<GroupProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    final l10n = AppLocalizations.of(context)!;
    
    // Get next number like 0001, 0002... and prepend current date
    final nextNumber = await attendanceProvider.getNextSessionNumber();
    final now = DateTime.now();
    final dateStr = DateFormat.yMMMMd(Localizations.localeOf(context).languageCode).format(now);
    final defaultTitle = "$dateStr $nextNumber";
    
    final titleController = TextEditingController(text: defaultTitle);
    int? selectedGroupId;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.newSession),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.sessionTitleLabel,
                  hintText: l10n.sessionTitleHint,
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<int>(
                value: selectedGroupId,
                hint: Text(l10n.chooseGroup),
                items: groupProvider.groups.map((g) {
                  return DropdownMenuItem(value: g.id, child: Text(g.name));
                }).toList(),
                onChanged: (v) => setState(() => selectedGroupId = v),
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: selectedGroupId == null ? null : () async {
                final session = AttendanceSession(
                  title: titleController.text.isEmpty ? defaultTitle : titleController.text,
                  date: DateTime.now(),
                  groupId: selectedGroupId,
                );
                try {
                  final id = await attendanceProvider.createSession(session);
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TakeAttendanceScreen(sessionId: id, groupId: selectedGroupId!),
                      ),
                    ).then((_) => context.read<AttendanceProvider>().loadSessions());
                  }
                } on AlreadyExistsException catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.sessionTitleExists(e.value))),
                    );
                  }
                }
              },
              child: Text(l10n.start),
            ),
          ],
        ),
      ),
    );
  }
}
