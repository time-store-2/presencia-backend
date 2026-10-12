import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:presencia/l10n/app_localizations.dart';
import '../../models/attendance.dart';
import '../../models/adolescent.dart';
import '../../core/providers/adolescent_provider.dart';
import '../../core/providers/attendance_provider.dart';
import '../../core/themes/app_themes.dart';
import '../widgets/app_background.dart';

class TakeAttendanceScreen extends StatefulWidget {
  final int sessionId;
  final int groupId;

  const TakeAttendanceScreen({
    super.key,
    required this.sessionId,
    required this.groupId,
  });

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  final Map<int, AttendanceStatus> _attendanceMap = {};
  final Map<int, TextEditingController> _commentControllers = {};
  List<Adolescent> _youths = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    final ap = context.read<AdolescentProvider>();
    final atp = context.read<AttendanceProvider>();

    await ap.loadAdolescentsByGroup(widget.groupId);
    final existingAttendance = await atp.getAttendanceForSession(widget.sessionId);
    
    if (mounted) {
      setState(() {
        _youths = ap.filteredAdolescents;
        for (var y in _youths) {
          _attendanceMap[y.id!] = AttendanceStatus.present;
          _commentControllers[y.id!] = TextEditingController();
        }
        // Écrase avec les données existantes si on modifie un appel déjà fait
        for (var a in existingAttendance) {
          _attendanceMap[a.adolescentId] = a.status;
          _commentControllers[a.adolescentId]?.text = a.comment ?? "";
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.takeAttendance),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, size: 28),
            onPressed: _save,
            tooltip: l10n.saveAttendance,
          )
        ],
      ),
      body: AppBackground(
        useSafeArea: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 116),
                itemCount: _youths.length,
                itemBuilder: (context, index) {
                  final youth = _youths[index];
                  final status = _attendanceMap[youth.id]!;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            youth.fullName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStatusSelector(youth.id!, status, l10n),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _commentControllers[youth.id],
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: l10n.addNote,
                              filled: true,
                              fillColor: theme.colorScheme.surfaceContainerLow.withOpacity(0.5),
                              prefixIcon: Icon(Icons.notes_rounded, size: 18, color: theme.colorScheme.primary.withOpacity(0.5)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: Container(
        padding: kPagePadding,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(l10n.saveAttendance, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSelector(int youthId, AttendanceStatus currentStatus, AppLocalizations l10n) {
    return Row(
      children: AttendanceStatus.values.map((status) {
        final isSelected = currentStatus == status;
        Color color;
        String label;
        
        switch (status) {
          case AttendanceStatus.present: color = const Color(0xFF2D7A56); label = "P"; break;
          case AttendanceStatus.absent: color = const Color(0xFFC0392B); label = "A"; break;
          case AttendanceStatus.late: color = const Color(0xFFD97706); label = "R"; break;
          case AttendanceStatus.excused: color = const Color(0xFF6B4CAE); label = "E"; break;
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: () => setState(() => _attendanceMap[youthId] = status),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Theme.of(context).colorScheme.outlineVariant,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _save() async {
    final attendances = _attendanceMap.entries.map((e) {
      return Attendance(
        adolescentId: e.key,
        sessionId: widget.sessionId,
        status: e.value,
        timestamp: DateTime.now(),
        comment: _commentControllers[e.key]?.text,
      );
    }).toList();

    await context.read<AttendanceProvider>().saveAttendance(attendances);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.attendanceSaved),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }
}
