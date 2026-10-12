import 'package:flutter/material.dart';
import '../../models/adolescent.dart';
import '../../models/parent.dart';
import '../services/api_service.dart';
import '../services/payload_mappers.dart';
import '../services/already_exists_exception.dart';

/// Membres chargés depuis l'API Payload (filtrés par rôle côté serveur).
/// L'API stocke un seul contact parent par membre (parentName + parentPhone).
class AdolescentProvider with ChangeNotifier {
  AdolescentProvider({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  List<Adolescent> _allAdolescents = [];
  List<Adolescent> _filteredAdolescents = [];
  bool _isLoading = false;

  List<Adolescent> get adolescents => _allAdolescents;
  List<Adolescent> get filteredAdolescents => _filteredAdolescents;
  bool get isLoading => _isLoading;

  Future<void> loadAdolescents() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.getMany('members', limit: 2000, sort: 'lastName');
      _allAdolescents = (res['docs'] as List)
          .map((d) => memberToAdolescent(d as Map<String, dynamic>))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAdolescentsByGroup(int groupId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.getManyIn(
        'members',
        'groups',
        [groupId],
        sort: 'lastName',
      );
      _filteredAdolescents = (res['docs'] as List)
          .map((d) => memberToAdolescent(d as Map<String, dynamic>))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _existsByFullName(String firstName, String lastName, [int? excludeId]) {
    final f = firstName.toLowerCase();
    final l = lastName.toLowerCase();
    return _allAdolescents.any(
      (a) =>
          a.firstName.toLowerCase() == f &&
          a.lastName.toLowerCase() == l &&
          a.id != excludeId,
    );
  }

  Future<int> insertRaw(Adolescent adolescent, List<Parent> parents) async {
    if (_existsByFullName(adolescent.firstName, adolescent.lastName)) {
      throw AlreadyExistsException(adolescent.fullName);
    }
    final orgId = _api.currentUser?.organizationId;
    if (orgId == null) throw Exception('Non connecté.');
    final created = await _api.create(
      'members',
      adolescentToMember(
        adolescent,
        organizationId: orgId,
        parents: parents,
      ),
    );
    await loadAdolescents();
    return toIntId((created['doc'] as Map<String, dynamic>)['id']);
  }

  Future<void> addAdolescent(Adolescent adolescent, List<Parent> parents) async {
    await insertRaw(adolescent, parents);
  }

  Future<void> updateAdolescent(
      Adolescent adolescent, List<Parent> parents) async {
    if (_existsByFullName(
        adolescent.firstName, adolescent.lastName, adolescent.id)) {
      throw AlreadyExistsException(adolescent.fullName);
    }
    final data = adolescentToMember(
      adolescent,
      parents: parents,
    );
    data.remove('organization');
    data.remove('groups');
    await _api.update('members', adolescent.id, data);
    await loadAdolescents();
  }

  Future<void> deleteAdolescent(int id) async {
    await _api.delete('members', id);
    await loadAdolescents();
  }

  Future<List<Parent>> getParents(int adolescentId) async {
    final doc = await _api.getById('members', adolescentId);
    final member = (doc is Map && doc.containsKey('doc'))
        ? doc['doc'] as Map<String, dynamic>
        : doc as Map<String, dynamic>;
    return parentsFromMember(member, adolescentId);
  }
}
