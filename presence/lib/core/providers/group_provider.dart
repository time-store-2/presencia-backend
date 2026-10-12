import 'package:flutter/material.dart';
import '../../models/group.dart';
import '../../models/member.dart';
import '../services/api_service.dart';
import '../services/payload_mappers.dart';
import '../services/already_exists_exception.dart';

/// Groupes chargés depuis l'API Payload (filtrés par rôle côté serveur).
/// Un membre n'a qu'un seul groupe côté API : les helpers multi-groupes
/// sont conservés pour l'interface mais mappés sur ce groupe unique.
class GroupProvider with ChangeNotifier {
  GroupProvider({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;
  List<Group> _groups = [];
  List<Member> _currentGroupMembers = [];
  Map<int, Set<int>> _memberGroupsMap = {}; // memberId -> Set of groupIds
  bool _isLoading = false;

  List<Group> get groups => _groups;
  List<Member> get currentGroupMembers => _currentGroupMembers;
  bool get isLoading => _isLoading;

  Future<void> loadGroups() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.getMany('groups', limit: 200, sort: 'name');
      _groups = (res['docs'] as List)
          .map((d) => groupFromPayload(d as Map<String, dynamic>))
          .toList();
      await _loadAllMemberGroups();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAllMemberGroups() async {
    final res = await _api.getMany('members', limit: 2000);
    _memberGroupsMap = {};
    for (final d in res['docs'] as List) {
      final doc = d as Map<String, dynamic>;
      final ids = memberGroupIds(doc);
      if (ids.isEmpty) continue;
      _memberGroupsMap[toIntId(doc['id'])] = ids;
    }
  }

  bool isMemberInGroup(int memberId, int groupId) {
    return _memberGroupsMap[memberId]?.contains(groupId) ?? false;
  }

  Future<void> addGroup(Group group) async {
    final exists = _groups.any(
      (g) => g.name.toLowerCase() == group.name.toLowerCase(),
    );
    if (exists) throw AlreadyExistsException(group.name);
    if (_api.currentUser == null) throw Exception('Non connecté.');
    await _api.create('groups', groupToPayload(group));
    await loadGroups();
  }

  Future<void> deleteGroup(int id) async {
    await _api.delete('groups', id);
    await loadGroups();
  }

  /// Nom d'un groupe (liste chargée, sinon requête directe).
  Future<String> getGroupName(int groupId) async {
    for (final g in _groups) {
      if (g.id == groupId) return g.name;
    }
    try {
      final doc = await _api.getById('groups', groupId);
      return doc['name']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> loadGroupMembers(int groupId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.getManyIn(
        'members',
        'groups',
        [groupId],
        sort: 'lastName',
      );
      _currentGroupMembers = (res['docs'] as List)
          .map((d) => memberFromPayload(d as Map<String, dynamic>))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMemberToGroup(int memberId, int groupId) async {
    final ids = {...?_memberGroupsMap[memberId], groupId};
    await _api.update('members', memberId, {'groups': ids.toList()});
    await _loadAllMemberGroups();
    await loadGroupMembers(groupId);
  }

  Future<void> removeMemberFromGroup(int memberId, int groupId) async {
    final ids = {...?_memberGroupsMap[memberId]}..remove(groupId);
    await _api.update('members', memberId, {'groups': ids.toList()});
    await _loadAllMemberGroups();
    await loadGroupMembers(groupId);
  }

  Future<List<int>> getMemberGroupIds(int memberId) async {
    return _memberGroupsMap[memberId]?.toList() ?? [];
  }

  Future<void> syncMemberGroups(int memberId, Set<int> groupIds) async {
    await _api.update(
      'members',
      memberId,
      {'groups': groupIds.toList()},
    );
    await _loadAllMemberGroups();
    notifyListeners();
  }
}
