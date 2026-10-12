import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/app_user.dart';

/// URL du backend Payload CMS.
/// Surchargeable à la compilation : --dart-define=PAYLOAD_URL=https://mon-serveur.com
/// 10.0.2.2 = localhost de la machine hôte depuis l'émulateur Android.
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'PAYLOAD_URL',
    defaultValue: 'http://10.0.2.2:3001',
  );

  static String get apiUrl => '$baseUrl/api';
}

/// Client HTTP pour l'API Payload CMS.
/// Gère le JWT (connexion, persistance sécurisée, en-têtes auth).
class ApiService {
  ApiService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'payload_jwt';
  static const _userKey = 'payload_user';

  String? _token;
  AppUser? _user;

  String? get token => _token;
  AppUser? get currentUser => _user;
  bool get isAuthenticated => _token != null;

  /// Le stockage sécurisé peut être indisponible (tests, plateformes non
  /// supportées) : la session mémoire reste valide, seule la persistance
  /// est perdue. Jamais bloquant pour la connexion.
  Future<void> _safeWrite(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      // Persistance indisponible : on continue avec la session mémoire.
    }
  }

  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _safeDelete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {
      // Ignore.
    }
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'JWT $_token',
      };

  /// Connexion email + mot de passe. Retourne l'utilisateur ou null.
  Future<AppUser?> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode != 200) {
      final message = _errorMessage(res.body);
      throw Exception(message);
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    _token = data['token'] as String?;
    final userJson = data['user'] as Map<String, dynamic>?;
    if (_token == null || userJson == null) {
      throw Exception('Réponse de connexion invalide.');
    }

    _user = AppUser.fromJson(userJson);
    await _safeWrite(_tokenKey, _token!);
    await _safeWrite(_userKey, jsonEncode(_user!.toJson()));
    return _user;
  }

  /// Restaure la session depuis le stockage sécurisé.
  /// Retourne true si un token valide existe.
  Future<bool> tryRestoreSession() async {
    _token = await _safeRead(_tokenKey);
    if (_token == null) return false;
    try {
      _user = await me();
      await _safeWrite(_userKey, jsonEncode(_user!.toJson()));
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  /// Profil de l'utilisateur connecté.
  Future<AppUser> me() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/users/me'),
      headers: _headers,
    );
    if (res.statusCode != 200) throw Exception(_errorMessage(res.body));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final userJson = (data['user'] ?? data) as Map<String, dynamic>;
    _user = AppUser.fromJson(userJson);
    return _user!;
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('${ApiConfig.apiUrl}/users/logout'),
          headers: _headers,
        );
      }
    } catch (_) {
      // La déconnexion locale prime même si le serveur est injoignable.
    }
    _token = null;
    _user = null;
    await _safeDelete(_tokenKey);
    await _safeDelete(_userKey);
  }

  /// GET générique sur une collection. Ex : getMany('members', where: {...}).
  Future<Map<String, dynamic>> getMany(
    String collection, {
    Map<String, dynamic>? where,
    int limit = 100,
    int page = 1,
    String? sort,
  }) async {
    final query = <String, String>{'limit': '$limit', 'page': '$page'};
    if (sort != null) query['sort'] = sort;
    if (where != null) {
      where.forEach((key, value) {
        query['where[$key][equals]'] = '$value';
      });
    }
    final uri = Uri.parse('${ApiConfig.apiUrl}/$collection')
        .replace(queryParameters: query);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) throw Exception(_errorMessage(res.body));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// GET avec filtre "in" (champs hasMany). Ex : membres d'un groupe.
  Future<Map<String, dynamic>> getManyIn(
    String collection,
    String field,
    List<dynamic> values, {
    int limit = 1000,
    String? sort,
  }) async {
    final params = <String>['limit=$limit'];
    if (sort != null) {
      params.add('sort=${Uri.encodeQueryComponent(sort)}');
    }
    for (final v in values) {
      params.add('where[$field][in][]=$v');
    }
    final uri =
        Uri.parse('${ApiConfig.apiUrl}/$collection?${params.join('&')}');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) throw Exception(_errorMessage(res.body));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// GET d'un document par id.
  Future<Map<String, dynamic>> getById(String collection, dynamic id) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/$collection/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) throw Exception(_errorMessage(res.body));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// PATCH d'un document.
  Future<Map<String, dynamic>> update(
    String collection,
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    final res = await http.patch(
      Uri.parse('${ApiConfig.apiUrl}/$collection/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode != 200) throw Exception(_errorMessage(res.body));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// DELETE d'un document.
  Future<void> delete(String collection, dynamic id) async {
    final res = await http.delete(
      Uri.parse('${ApiConfig.apiUrl}/$collection/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) throw Exception(_errorMessage(res.body));
  }

  /// GET brut (endpoints personnalisés : org-stats, member-stats...).
  Future<Map<String, dynamic>> getRaw(
    String path, [
    Map<String, String>? query,
  ]) async {
    var uri = Uri.parse('${ApiConfig.apiUrl}/$path');
    if (query != null) uri = uri.replace(queryParameters: query);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) throw Exception(_errorMessage(res.body));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// POST générique sur une collection.
  Future<Map<String, dynamic>> create(
    String collection,
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/$collection'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(_errorMessage(res.body));
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Notifie les absents d'une séance (message WhatsApp personnalisé).
  /// Retourne le nombre de membres notifiés.
  Future<int> notifyAbsences(dynamic sessionId) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/notify-absence'),
      headers: _headers,
      body: jsonEncode({'sessionId': sessionId}),
    );
    if (res.statusCode != 200) throw Exception(_errorMessage(res.body));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['notified'] as num?)?.toInt() ?? 0;
  }

  String _errorMessage(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final errors = data['errors'] as List?;
      if (errors != null && errors.isNotEmpty) {
        return (errors.first as Map)['message']?.toString() ??
            'Erreur inconnue.';
      }
      return data['message']?.toString() ?? 'Erreur inconnue.';
    } catch (_) {
      return 'Erreur de connexion au serveur.';
    }
  }
}
