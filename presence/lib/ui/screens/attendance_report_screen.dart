import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../core/providers/member_provider.dart';
import '../../core/providers/attendance_provider.dart';
import '../../core/providers/group_provider.dart';
import '../../core/themes/app_themes.dart';
import '../../models/member.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  int? _selectedGroupId;
  Map<int, Map<String, int>> _reportData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final groups = context.read<GroupProvider>().groups;
    if (groups.isNotEmpty) {
      _selectedGroupId = groups.first.id;
      _loadReport();
    }
  }

  Future<void> _loadReport() async {
    if (_selectedGroupId == null) return;
    
    setState(() => _isLoading = true);
    final data = await context.read<AttendanceProvider>().getStatsByPeriod(
          _startDate,
          _endDate,
          _selectedGroupId!,
        );
    
    if (mounted) {
      setState(() {
        _reportData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupProvider = context.watch<GroupProvider>();
    final adProvider = context.watch<MemberProvider>();
    final statusColors = theme.extension<StatusColors>()!;

    // Filter members by group
    final members = adProvider.members.where((m) {
      return groupProvider.isMemberInGroup(m.id!, _selectedGroupId ?? -1);
    }).toList();

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.periodReport),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_rounded),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: AppBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GlassCard(
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedGroupId,
                      decoration: InputDecoration(labelText: l10n.group),
                      items: groupProvider.groups.map((g) {
                        return DropdownMenuItem(value: g.id, child: Text(g.name));
                      }).toList(),
                      onChanged: (v) {
                        setState(() => _selectedGroupId = v);
                        _loadReport();
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _selectDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_month, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "${DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(_startDate)} - ${DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(_endDate)}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : members.isEmpty
                      ? Center(child: Text(l10n.noMemberInGroup))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            final member = members[index];
                            final stats = _reportData[member.id] ?? {'present': 0, 'absent': 0, 'late': 0, 'excused': 0};
                            
                            final p = stats['present'] ?? 0;
                            final a = stats['absent'] ?? 0;
                            final l = stats['late'] ?? 0;
                            final e = stats['excused'] ?? 0;
                            final total = p + a + l + e;
                            final presenceRate = total > 0 ? (p + l) / total : 0.0;

                            return GlassCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundImage: member.photoPath != null ? FileImage(File(member.photoPath!)) : null,
                                        child: member.photoPath == null ? Text(member.firstName[0]) : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          member.fullName,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        "${(presenceRate * 100).toStringAsFixed(0)}%",
                                        style: TextStyle(
                                          color: presenceRate < 0.5 ? Colors.red : Colors.green,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: presenceRate,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                    color: presenceRate < 0.5 ? Colors.red : Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _SmallStat(label: l10n.presentShort, value: p, color: statusColors.presentText),
                                      _SmallStat(label: l10n.lateShort, value: l, color: statusColors.lateText),
                                      _SmallStat(label: l10n.absentShort, value: a, color: statusColors.absentText),
                                      _SmallStat(label: l10n.excusedShort, value: e, color: statusColors.excusedText),
                                      _SmallStat(label: l10n.total, value: total, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _SmallStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
      ],
    );
  }
}
