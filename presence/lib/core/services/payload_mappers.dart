import 'package:flutter/material.dart';
import '../../models/adolescent.dart';
import '../../models/attendance.dart';
import '../../models/attendance_session.dart';
import '../../models/group.dart';
import '../../models/parent.dart';

/// Conversions entre les documents Payload CMS et les modèles locaux.
/// Les ids Payload sont numériques (SQLite) : on les normalise en int.

int toIntId(dynamic value) {
  if (value is Map) return (value['id'] as num).toInt();
  return (value as num).toInt();
}

dynamic extractId(dynamic value) {
  if (value is Map) return value['id'];
  return value;
}

// --- Genres : local 'M'/'F' <-> API 'male'/'female' ---

String? genderToApi(String? gender) {
  if (gender == 'M') return 'male';
  if (gender == 'F') return 'female';
  return null;
}

String? genderFromApi(dynamic gender) {
  if (gender == 'male') return 'M';
  if (gender == 'female') return 'F';
  return null;
}

// --- Couleurs : local int (0xFF...) <-> API hex '#RRGGBB' ---

String colorToHex(int? color) {
  final c = color ?? 0xFF2196F3;
  return '#${(c & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

int colorFromHex(dynamic hex) {
  if (hex is String) {
    final cleaned = hex.replaceFirst('#', '');
    final parsed = int.tryParse(cleaned, radix: 16);
    if (parsed != null) return 0xFF000000 | parsed;
  }
  return 0xFF2196F3;
}

// --- Membres <-> Adolescent ---

Adolescent memberToAdolescent(Map<String, dynamic> json) {
  return Adolescent(
    id: toIntId(json['id']),
    firstName: json['firstName']?.toString() ?? '',
    lastName: json['lastName']?.toString() ?? '',
    gender: genderFromApi(json['gender']),
    birthDate: json['birthDate'] != null
        ? DateTime.tryParse(json['birthDate'].toString())
        : null,
    phone: json['phone']?.toString(),
    address: json['address']?.toString(),
    isActive: (json['status']?.toString() ?? 'active') == 'active',
  );
}

Map<String, dynamic>? _parentToApi(Parent p) {
  final firstName = p.firstName ?? '';
  final lastName = p.lastName ?? '';
  final phone = (p.whatsapp?.isNotEmpty ?? false)
      ? p.whatsapp
      : (p.phone?.isNotEmpty ?? false ? p.phone : null);
  if (firstName.isEmpty && lastName.isEmpty && phone == null) return null;
  return {
    'firstName': firstName,
    'lastName': lastName,
    if (phone != null) 'phone': phone,
    if (p.relation != null) 'relation': p.relation,
  };
}

Map<String, dynamic> adolescentToMember(
  Adolescent a, {
  Set<int>? groupIds,
  List<Parent>? parents,
}) {
  Map<String, dynamic>? parent1;
  Map<String, dynamic>? parent2;
  if (parents != null && parents.isNotEmpty) {
    parent1 = _parentToApi(parents[0]);
    if (parents.length > 1) parent2 = _parentToApi(parents[1]);
  }
  return {
    'firstName': a.firstName,
    'lastName': a.lastName,
    'gender': genderToApi(a.gender),
    'birthDate': a.birthDate?.toIso8601String(),
    'phone': a.phone,
    'address': a.address,
    'status': a.isActive ? 'active' : 'inactive',
    if (groupIds != null) 'groups': groupIds.toList(),
    if (parent1 != null) 'parent1': parent1,
    if (parent2 != null) 'parent2': parent2,
  };
}

/// Groupes d'un document membre (ids ou objets peuplés).
Set<int> memberGroupIds(Map<String, dynamic> memberJson) {
  final groups = memberJson['groups'];
  if (groups is! List) return {};
  return groups.map((g) => toIntId(g)).toSet();
}

/// Reconstitue les parents (jusqu'à 2) depuis le membre.
List<Parent> parentsFromMember(
    Map<String, dynamic> memberJson, int adolescentId) {
  final result = <Parent>[];
  for (final key in ['parent1', 'parent2']) {
    final p = memberJson[key];
    if (p is! Map) continue;
    final phone = (p['phone'] as String?)?.isNotEmpty ?? false
        ? p['phone'] as String
        : null;
    final firstName = (p['firstName'] as String?) ?? '';
    final lastName = (p['lastName'] as String?) ?? '';
    if (firstName.isEmpty && lastName.isEmpty && phone == null) continue;
    result.add(Parent(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      whatsapp: phone,
      relation: p['relation'] as String?,
      adolescentId: adolescentId,
    ));
  }
  return result;
}

// --- Groupes ---

Group groupFromPayload(Map<String, dynamic> json) {
  DateTime createdAt;
  try {
    createdAt = DateTime.parse(json['createdAt'].toString());
  } catch (_) {
    createdAt = DateTime.now();
  }
  return Group(
    id: toIntId(json['id']),
    name: json['name']?.toString() ?? '',
    slug: json['slug']?.toString(),
    description: json['description']?.toString(),
    color: colorFromHex(json['color']),
    createdAt: createdAt,
  );
}

Map<String, dynamic> groupToPayload(Group group) {
  return {
    'name': group.name,
    if (group.description != null) 'description': group.description,
    'color': colorToHex(group.color),
  };
}

// --- Séances : titre local <-> notes API ---

AttendanceSession sessionFromPayload(Map<String, dynamic> json) {
  final date = DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now();
  final notes = json['notes']?.toString() ?? '';
  final title = notes.isNotEmpty
      ? notes
      : 'Séance du ${date.day}/${date.month}/${date.year}';
  return AttendanceSession(
    id: toIntId(json['id']),
    title: title,
    date: date,
    groupId: json['group'] == null ? null : toIntId(json['group']),
  );
}

Map<String, dynamic> sessionToPayload(
  AttendanceSession session, {
  dynamic leaderId,
}) {
  return {
    'date': session.date.toIso8601String(),
    'group': session.groupId,
    'notes': session.title,
    if (leaderId != null) 'leader': leaderId,
  };
}

// --- Présences ---

Attendance recordToAttendance(Map<String, dynamic> json) {
  final statusName = json['status']?.toString() ?? 'absent';
  final status = AttendanceStatus.values.firstWhere(
    (e) => e.name == statusName,
    orElse: () => AttendanceStatus.absent,
  );
  DateTime timestamp;
  try {
    timestamp = DateTime.parse(
      (json['updatedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  } catch (_) {
    timestamp = DateTime.now();
  }
  return Attendance(
    id: toIntId(json['id']),
    adolescentId: toIntId(json['member']),
    sessionId: toIntId(json['session']),
    status: status,
    timestamp: timestamp,
    comment: json['note']?.toString(),
  );
}

Map<String, dynamic> attendanceToRecord(Attendance a) {
  return {
    'member': a.adolescentId,
    'session': a.sessionId,
    'status': a.status.name,
    if (a.comment != null) 'note': a.comment,
  };
}

/// Couleur par défaut affichée quand un groupe n'en a pas.
Color defaultGroupColor() => const Color(0xFF2196F3);
