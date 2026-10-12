import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:presencia/l10n/app_localizations.dart';
import '../../models/attendance.dart';
import '../../models/attendance_session.dart';
import '../../models/adolescent.dart';
import '../../core/providers/attendance_provider.dart';
import '../../core/providers/adolescent_provider.dart';
import '../../core/themes/app_themes.dart';
import '../widgets/app_background.dart';
import 'take_attendance_screen.dart';

class SessionDetailScreen extends StatefulWidget {
  final AttendanceSession session;
  const SessionDetailScreen({super.key, required this.session});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  List<Attendance> _attendances = [];
  List<Adolescent> _youths = [];
  bool _isLoading = true;
  int _selectedFilterIndex = 0; // 0: All, 1: Present, 2: Absent

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final atp = context.read<AttendanceProvider>();
    final adp = context.read<AdolescentProvider>();
    
    await adp.loadAdolescentsByGroup(widget.session.groupId!);
    final atts = await atp.getAttendanceForSession(widget.session.id!);
    
    if (mounted) {
      setState(() {
        _attendances = atts;
        _youths = adp.filteredAdolescents;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final design = Theme.of(context).extension<AppDesignSystem>()!;
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    final theme = Theme.of(context);

    int presentCount = _attendances.where((a) => a.status == AttendanceStatus.present || a.status == AttendanceStatus.late).length;
    int recordedAbsent = _attendances.where((a) => a.status == AttendanceStatus.absent).length;
    int excusedCount = _attendances.where((a) => a.status == AttendanceStatus.excused).length;
    // Les membres sans enregistrement sont affichés comme absents :
    // on les compte pour rester cohérent avec la liste.
    final recordedIds = _attendances.map((a) => a.adolescentId).toSet();
    final unmarkedCount = _youths.where((y) => !recordedIds.contains(y.id)).length;
    int absentCount = recordedAbsent + unmarkedCount;
    final markedTotal = presentCount + absentCount + excusedCount;
    final sessionRate = markedTotal > 0 ? presentCount / markedTotal : 0.0;

    List<Adolescent> filteredYouths = _youths.where((youth) {
      final att = _attendances.firstWhere(
        (a) => a.adolescentId == youth.id,
        orElse: () => Attendance(
          adolescentId: youth.id!,
          sessionId: widget.session.id!,
          status: AttendanceStatus.absent,
          timestamp: DateTime.now(),
        ),
      );
      
      if (_selectedFilterIndex == 1) return att.status == AttendanceStatus.present || att.status == AttendanceStatus.late;
      if (_selectedFilterIndex == 2) return att.status == AttendanceStatus.absent;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TakeAttendanceScreen(
                  sessionId: widget.session.id!,
                  groupId: widget.session.groupId!,
                ),
              ),
            ).then((_) => _loadData()),
          ),
        ],
      ),
      body: AppBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: kPagePadding,
                children: [
                  _buildSummaryCard(context, presentCount, absentCount, sessionRate, l10n, design),
                  const SizedBox(height: 24),
                  _buildFilterBar(theme, l10n, presentCount, absentCount),
                  const SizedBox(height: 16),
                  if (filteredYouths.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          _selectedFilterIndex == 2 ? l10n.noAbsent : l10n.emptyList,
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                        ),
                      ),
                    )
                  else
                    ...filteredYouths.map((youth) {
                      final att = _attendances.firstWhere(
                        (a) => a.adolescentId == youth.id,
                        orElse: () => Attendance(
                          adolescentId: youth.id!,
                          sessionId: widget.session.id!,
                          status: AttendanceStatus.absent,
                          timestamp: DateTime.now(),
                        ),
                      );
                      return _ParticipantTile(youth: youth, attendance: att, statusColors: statusColors, l10n: l10n);
                    }),
                ],
              ),
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme, AppLocalizations l10n, int present, int absent) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(0, l10n.allWithCount(_youths.length), theme),
          const SizedBox(width: 8),
          _filterChip(1, "${l10n.present} ($present)", theme),
          const SizedBox(width: 8),
          _filterChip(2, "${l10n.absent} ($absent)", theme),
        ],
      ),
    );
  }

  Widget _filterChip(int index, String label, ThemeData theme) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilterIndex = index);
      },
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }

  Widget _buildSummaryCard(BuildContext context, int present, int absent, double rate, AppLocalizations l10n, AppDesignSystem design) {
    final theme = Theme.of(context);
    return Container(
      padding: kPagePadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: l10n.present, value: present.toString(), color: Colors.white),
          Container(width: 1, height: 40, color: Colors.white24),
          _StatItem(label: l10n.absent, value: absent.toString(), color: Colors.white),
          Container(width: 1, height: 40, color: Colors.white24),
          _StatItem(
            label: l10n.rate,
            value: "${(rate * 100).toStringAsFixed(0)}%",
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.7), fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final Adolescent youth;
  final Attendance attendance;
  final StatusColors statusColors;
  final AppLocalizations l10n;

  const _ParticipantTile({
    required this.youth,
    required this.attendance,
    required this.statusColors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (attendance.status) {
      case AttendanceStatus.present:
        color = const Color(0xFF2D7A56);
        label = l10n.present;
        break;
      case AttendanceStatus.absent:
        color = const Color(0xFFC0392B);
        label = l10n.absent;
        break;
      case AttendanceStatus.late:
        color = const Color(0xFFD97706);
        label = l10n.late;
        break;
      case AttendanceStatus.excused:
        color = const Color(0xFF6B4CAE);
        label = l10n.excused;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(youth.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: attendance.comment != null && attendance.comment!.isNotEmpty
            ? Text(attendance.comment!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11),
          ),
        ),
      ),
    );
  }
}
