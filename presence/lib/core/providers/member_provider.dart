import 'package:flutter/material.dart';
import '../../models/member.dart';
import '../../models/parent.dart';
import '../services/api_service.dart';
import '../services/payload_mappers.dart';
import '../services/already_exists_exception.dart';

/// Membres chargés depuis l'API Payload (filtrés par rôle côté serveur).
/// L'API stocke un seul contact parent par membre (parentName + parentPhone).
class MemberProvider with ChangeNotifier {
  MemberProvider({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  List<Member> _allMembers = [];
  List<Member> _filteredMembers = [];
  bool _isLoading = false;

  List<Member> get members => _allMembers;
  List<Member> get filteredMembers => _filteredMembers;
  bool get isLoading => _isLoading;

  Future<void> loadMembers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.getMany('members', limit: 2000, sort: 'lastName');
      _allMembers = (res['docs'] as List)
          .map((d) => memberFromPayload(d as Map<String, dynamic>))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMembersByGroup(int groupId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.getManyIn(
        'members',
        'groups',
        [groupId],
        sort: 'lastName',
      );
      _filteredMembers = (res['docs'] as List)
          .map((d) => memberFromPayload(d as Map<String, dynamic>))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _existsByFullName(String firstName, String lastName, [int? excludeId]) {
    final f = firstName.toLowerCase();
    final l = lastName.toLowerCase();
    return _allMembers.any(
      (a) =>
          a.firstName.toLowerCase() == f &&
          a.lastName.toLowerCase() == l &&
          a.id != excludeId,
    );
  }

  Future<int> insertRaw(Member member, List<Parent> parents) async {
    if (_existsByFullName(member.firstName, member.lastName)) {
      throw AlreadyExistsException(member.fullName);
    }
    if (_api.currentUser == null) throw Exception('Non connecté.');
    final created = await _api.create(
      'members',
      memberToPayload(
        member,
        parents: parents,
      ),
    );
    await loadMembers();
    return toIntId((created['doc'] as Map<String, dynamic>)['id']);
  }

  Future<void> addMember(Member member, List<Parent> parents) async {
    await insertRaw(member, parents);
  }

  Future<void> updateMember(
      Member member, List<Parent> parents) async {
    if (_existsByFullName(
        member.firstName, member.lastName, member.id)) {
      throw AlreadyExistsException(member.fullName);
    }
    final data = memberToPayload(
      member,
      parents: parents,
    );
    data.remove('groups');
    await _api.update('members', member.id, data);
    await loadMembers();
  }

  Future<void> deleteMember(int id) async {
    await _api.delete('members', id);
    await loadMembers();
  }

  Future<List<Parent>> getParents(int memberId) async {
    final doc = await _api.getById('members', memberId);
    final member = (doc is Map && doc.containsKey('doc'))
        ? doc['doc'] as Map<String, dynamic>
        : doc as Map<String, dynamic>;
    return parentsFromMember(member, memberId);
  }
}
