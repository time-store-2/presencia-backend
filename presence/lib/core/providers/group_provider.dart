import 'package:flutter/material.dart';
import '../../models/group.dart';
import '../../models/adolescent.dart';
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
  List<Adolescent> _currentGroupMembers = [];
  Map<int, Set<int>> _adolescentGroupsMap = {}; // adolescentId -> Set of groupIds
  bool _isLoading = false;

  List<Group> get groups => _groups;
  List<Adolescent> get currentGroupMembers => _currentGroupMembers;
  bool get isLoading => _isLoading;

  Future<void> loadGroups() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.getMany('groups', limit: 200, sort: 'name');
      _groups = (res['docs'] as List)
          .map((d) => groupFromPayload(d as Map<String, dynamic>))
          .toList();
      await _loadAllAdolescentGroups();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAllAdolescentGroups() async {
    final res = await _api.getMany('members', limit: 2000);
    _adolescentGroupsMap = {};
    for (final d in res['docs'] as List) {
      final doc = d as Map<String, dynamic>;
      final ids = memberGroupIds(doc);
      if (ids.isEmpty) continue;
      _adolescentGroupsMap[toIntId(doc['id'])] = ids;
    }
  }

  bool isYouthInGroup(int adolescentId, int groupId) {
    return _adolescentGroupsMap[adolescentId]?.contains(groupId) ?? false;
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
          .map((d) => memberToAdolescent(d as Map<String, dynamic>))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAdolescentToGroup(int adolescentId, int groupId) async {
    final ids = {...?_adolescentGroupsMap[adolescentId], groupId};
    await _api.update('members', adolescentId, {'groups': ids.toList()});
    await _loadAllAdolescentGroups();
    await loadGroupMembers(groupId);
  }

  Future<void> removeAdolescentFromGroup(int adolescentId, int groupId) async {
    final ids = {...?_adolescentGroupsMap[adolescentId]}..remove(groupId);
    await _api.update('members', adolescentId, {'groups': ids.toList()});
    await _loadAllAdolescentGroups();
    await loadGroupMembers(groupId);
  }

  Future<List<int>> getAdolescentGroupIds(int adolescentId) async {
    return _adolescentGroupsMap[adolescentId]?.toList() ?? [];
  }

  Future<void> syncAdolescentGroups(int adolescentId, Set<int> groupIds) async {
    await _api.update(
      'members',
      adolescentId,
      {'groups': groupIds.toList()},
    );
    await _loadAllAdolescentGroups();
    notifyListeners();
  }
}
