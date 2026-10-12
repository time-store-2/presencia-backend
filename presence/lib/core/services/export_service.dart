import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'payload_mappers.dart';
import '../../models/adolescent.dart';
import '../../models/attendance_session.dart';
import '../../models/group.dart';

/// Export CSV construit depuis l'API Payload (sessions, membres, présences).
class ExportService {
  ExportService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<void> exportAttendanceToCSV() async {
    // Get current year
    final currentYear = DateTime.now().year;

    // Get all sessions for the current year
    final sessionsRes = await _api.getMany(
      'attendance-sessions',
      limit: 1000,
      sort: 'date',
    );
    final allSessions = (sessionsRes['docs'] as List)
        .map((d) => sessionFromPayload(d as Map<String, dynamic>))
        .toList();
    final yearSessions =
        allSessions.where((s) => s.date.year == currentYear).toList();
    // Sort by date ascending for the columns
    yearSessions.sort((a, b) => a.date.compareTo(b.date));

    // Get all members
    final membersRes = await _api.getMany('members', limit: 5000);
    final youths = (membersRes['docs'] as List)
        .map((d) => memberToAdolescent(d as Map<String, dynamic>))
        .toList();

    // Get groups mapping (member -> group name via API group field)
    final groupsRes = await _api.getMany('groups', limit: 500);
    final groupMap = {
      for (final d in groupsRes['docs'] as List)
        toIntId((d as Map<String, dynamic>)['id']):
            (d['name']?.toString() ?? '')
    };
    final memberDocs = {
      for (final d in membersRes['docs'] as List)
        toIntId((d as Map<String, dynamic>)['id']): d as Map<String, dynamic>
    };

    // All attendance records (one call, mapped by session then member)
    final recordsRes = await _api.getMany('attendance-records', limit: 10000);
    // recordKey: "sessionId:memberId" -> status
    final recordBySessionMember = <String, String>{};
    for (final d in recordsRes['docs'] as List) {
      final doc = d as Map<String, dynamic>;
      recordBySessionMember['${toIntId(doc['session'])}:${toIntId(doc['member'])}'] =
          doc['status']?.toString() ?? '';
    }

    StringBuffer csvContent = StringBuffer();
    // Add UTF-8 BOM for Excel to recognize accents
    csvContent.write('\uFEFF');

    // Header: Nom, Prenom, Groupes, [Sessions...]
    List<String> header = ['Nom', 'Prénom', 'Groupes'];
    for (var session in yearSessions) {
      final dateStr = DateFormat('dd/MM/yy').format(session.date);
      header.add('$dateStr - ${session.title}');
    }

    // Use semicolon as separator for better compatibility with French Excel
    String escapeCsv(String text) => '"${text.replaceAll('"', '""')}"';

    csvContent.write(header.map(escapeCsv).join(';'));
    csvContent.write('\r\n');

    for (Adolescent youth in youths) {
      final groupIds = memberGroupIds(
        memberDocs[youth.id] ?? const <String, dynamic>{},
      );
      final groupName = groupIds
          .map((id) => groupMap[id] ?? '')
          .where((name) => name.isNotEmpty)
          .join(', ');

      List<String> row = [youth.lastName, youth.firstName, groupName];

      for (AttendanceSession session in yearSessions) {
        final status = recordBySessionMember['${session.id}:${youth.id}'];
        String statusLabel = '';
        if (status != null && status.isNotEmpty) {
          switch (status) {
            case 'present':
              statusLabel = 'P';
              break;
            case 'absent':
              statusLabel = 'A';
              break;
            case 'late':
              statusLabel = 'R';
              break;
            case 'excused':
              statusLabel = 'E';
              break;
            default:
              statusLabel = '?';
          }
        } else {
          statusLabel = '-';
        }
        row.add(statusLabel);
      }

      csvContent.write(row.map(escapeCsv).join(';'));
      csvContent.write('\r\n');
    }

    final directory = await getTemporaryDirectory();
    final fileName = 'presences_$currentYear.csv';
    final file = File('${directory.path}/$fileName');

    // Explicitly write as UTF-8 bytes to ensure BOM is correctly preserved
    final bytes = utf8.encode(csvContent.toString());
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)],
        text: 'Export des présences Presencia $currentYear');
  }
}
