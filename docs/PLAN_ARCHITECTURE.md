# Plan d'Architecture - Système de Gestion d'Église Presencia

## Vue d'ensemble

Ce document décrit l'architecture complète du système de gestion de présence pour église avec :
- **Payload CMS** : Backend, API, Admin Panel, Formulaire d'inscription
- **Flutter Mobile** : App mobile pour Admin, Pasteur et Dirigeants de groupes

---

## PARTIE 1 : PAYLOAD CMS (Backend + Web)

### 1.1 Structure du projet

```
payload-church/
├── src/
│   ├── collections/
│   │   ├── Users.ts
│   │   ├── Churches.ts
│   │   ├── Groups.ts
│   │   ├── Members.ts
│   │   ├── AttendanceSessions.ts
│   │   └── AttendanceRecords.ts
│   ├── access/
│   │   ├── isAdmin.ts
│   │   ├── isLeader.ts
│   │   └── isChurchMember.ts
│   ├── endpoints/
│   │   ├── whatsapp.ts
│   │   └── stats.ts
│   └── payload.config.ts
├── admin/
│   └── (Panel admin intégré par Payload)
├── formulaire/
│   └── inscription.html
├── package.json
└── .env
```

### 1.2 Collections (Modèles de données)

#### Collection: Churches (Église)
```typescript
{
  slug: 'churches',
  fields: [
    { name: 'name', type: 'text', required: true },           // "Église de la Grâce"
    { name: 'code', type: 'text', required: true, unique: true }, // "EGLISE-ABIDJAN-001"
    { name: 'address', type: 'text' },
    { name: 'phone', type: 'text' },
    { name: 'email', type: 'email' },
    { name: 'logo', type: 'upload' },
    { name: 'admin', type: 'relationship', relationTo: 'users', required: true }
  ]
}
```

#### Collection: Users (Utilisateurs)
```typescript
{
  slug: 'users',
  auth: true,  // Payload gère l'auth automatiquement
  fields: [
    { name: 'firstName', type: 'text', required: true },
    { name: 'lastName', type: 'text', required: true },
    { name: 'email', type: 'email', required: true, unique: true },
    { name: 'phone', type: 'text' },
    { name: 'role', type: 'select', options: [
      { label: 'Admin', value: 'admin' },
      { label: 'Pasteur', value: 'pasteur' },
      { label: 'Président de groupe', value: 'president_group' },
      { label: 'Membre', value: 'membre' }
    ], required: true, defaultValue: 'membre' },
    { name: 'church', type: 'relationship', relationTo: 'churches', required: true },
    { name: 'group', type: 'relationship', relationTo: 'groups' },  // Si président
    { name: 'photo', type: 'upload' }
  ],
  access: {
    read: isAdminOrSelf,      // Admin voit tout, chaque user voit son profil
    create: isAdmin,          // Seul admin peut créer
    update: isAdminOrSelf,    // Admin ou soi-même
    delete: isAdmin           // Seul admin peut supprimer
  }
}
```

#### Collection: Groups (Groupes)
```typescript
{
  slug: 'groups',
  fields: [
    { name: 'name', type: 'text', required: true },           // "JAD", "Maths"
    { name: 'description', type: 'textarea' },
    { name: 'color', type: 'text' },                          // Hex color pour l'UI
    { name: 'church', type: 'relationship', relationTo: 'churches', required: true },
    { name: 'leader', type: 'relationship', relationTo: 'users' },  // Président du groupe
    { name: 'meetingDay', type: 'text' },                     // "Dimanche", "Mercredi"
    { name: 'meetingTime', type: 'text' }                     // "14h00"
  ],
  access: {
    read: true,              // Tous les membres de l'église peuvent voir les groupes
    create: isAdminOrPasteur,
    update: isAdminOrLeader, // Admin, Pasteur ou Leader du groupe
    delete: isAdminOrPasteur
  }
}
```

#### Collection: Members (Membres inscrits)
```typescript
{
  slug: 'members',
  fields: [
    { name: 'firstName', type: 'text', required: true },
    { name: 'lastName', type: 'text', required: true },
    { name: 'phone', type: 'text', required: true },
    { name: 'email', type: 'email' },
    { name: 'gender', type: 'select', options: [
      { label: 'Homme', value: 'male' },
      { label: 'Femme', value: 'female' }
    ]},
    { name: 'birthDate', type: 'date' },
    { name: 'address', type: 'text' },
    { name: 'group', type: 'relationship', relationTo: 'groups', required: true },
    { name: 'church', type: 'relationship', relationTo: 'churches', required: true },
    { name: 'parentName', type: 'text' },                     // Nom du parent (si mineur)
    { name: 'parentPhone', type: 'text' },                    // Téléphone du parent
    { name: 'registrationDate', type: 'date', defaultValue: new Date() },
    { name: 'status', type: 'select', options: [
      { label: 'Actif', value: 'active' },
      { label: 'Inactif', value: 'inactive' }
    ], defaultValue: 'active' }
  ],
  access: {
    read: isAdminOrLeaderOfGroup,  // Admin voit tout, Leader voit son groupe
    create: true,                   // anyone via formulaire public
    update: isAdminOrLeaderOfGroup,
    delete: isAdmin
  }
}
```

#### Collection: AttendanceSessions (Séances d'appel)
```typescript
{
  slug: 'attendance-sessions',
  fields: [
    { name: 'date', type: 'date', required: true },
    { name: 'group', type: 'relationship', relationTo: 'groups', required: true },
    { name: 'leader', type: 'relationship', relationTo: 'users', required: true },
    { name: 'church', type: 'relationship', relationTo: 'churches', required: true },
    { name: 'notes', type: 'textarea' },
    { name: 'isClosed', type: 'checkbox', defaultValue: false }
  ],
  access: {
    read: isAdminOrLeader,
    create: isAdminOrLeader,
    update: isAdminOrLeader
  }
}
```

#### Collection: AttendanceRecords (Présences)
```typescript
{
  slug: 'attendance-records',
  fields: [
    { name: 'session', type: 'relationship', relationTo: 'attendance-sessions', required: true },
    { name: 'member', type: 'relationship', relationTo: 'members', required: true },
    { name: 'status', type: 'select', options: [
      { label: 'Présent', value: 'present' },
      { label: 'Absent', value: 'absent' },
      { label: 'Retard', value: 'late' },
      { label: 'Excusé', value: 'excused' }
    ], required: true },
    { name: 'timestamp', type: 'date', defaultValue: new Date() },
    { name: 'note', type: 'text' }                            // "Absence justifiée"
  ],
  access: {
    read: isAdminOrLeader,
    create: isAdminOrLeader,
    update: isAdminOrLeader
  }
}
```

### 1.3 Système d'Accès (Access Control)

```typescript
// isAdmin.ts
export const isAdmin = ({ req }) => {
  return req.user?.role === 'admin';
};

// isLeader.ts
export const isLeader = ({ req }) => {
  return req.user?.role === 'president_group';
};

// isAdminOrLeader.ts
export const isAdminOrLeader = ({ req }) => {
  if (req.user?.role === 'admin' || req.user?.role === 'pasteur') return true;
  if (req.user?.role === 'president_group') {
    // Ne peut voir que les données de son groupe
    return {
      'group': { equals: req.user.group }
    };
  }
  return false;
};

// isAdminOrLeaderOfGroup.ts (pour Members)
export const isAdminOrLeaderOfGroup = ({ req }) => {
  if (req.user?.role === 'admin' || req.user?.role === 'pasteur') return true;
  if (req.user?.role === 'president_group') {
    return {
      'group': { equals: req.user.group }
    };
  }
  return false;
};
```

### 1.4 Formulaire d'Inscription Web

```html
<!-- formulaire/inscription.html -->
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Inscription - Église</title>
</head>
<body>
  <h1>Formulaire d'Inscription</h1>
  <form id="registrationForm">
    <input name="firstName" placeholder="Prénom" required />
    <input name="lastName" placeholder="Nom" required />
    <input name="phone" placeholder="Téléphone" required />
    <input name="email" placeholder="Email" type="email" />
    <select name="gender" required>
      <option value="">-- Sexe --</option>
      <option value="male">Homme</option>
      <option value="female">Femme</option>
    </select>
    <input name="birthDate" type="date" />
    <input name="address" placeholder="Adresse" />
    <select name="group" required>
      <!-- Rempli dynamiquement depuis l'API -->
    </select>
    <input name="parentName" placeholder="Nom du parent (si mineur)" />
    <input name="parentPhone" placeholder="Téléphone du parent" />
    <button type="submit">S'inscrire</button>
  </form>
  <script>
    // Récupérer les groupes de l'église via l'API
    fetch('/api/groups?where[church][equals]=EGLISE-ID')
      .then(res => res.json())
      .then(data => {
        const select = document.querySelector('[name="group"]');
        data.docs.forEach(group => {
          select.innerHTML += `<option value="${group.id}">${group.name}</option>`;
        });
      });

    // Soumettre le formulaire
    document.getElementById('registrationForm').addEventListener('submit', async (e) => {
      e.preventDefault();
      const formData = new FormData(e.target);
      const data = Object.fromEntries(formData);

      // Ajouter l'ID de l'église (depuis l'URL ou variable)
      data.church = new URLSearchParams(window.location.search).get('church');

      await fetch('/api/members', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      });

      alert('Inscription réussie !');
    });
  </script>
</body>
</html>
```

### 1.5 Endpoint WhatsApp (Cloud Function)

```typescript
// src/endpoints/whatsapp.ts
import { Endpoint } from 'payload';

const sendWhatsAppMessage: Endpoint = {
  path: '/send-whatsapp',
  method: 'post',
  handler: async (req, res) => {
    const { memberId, message, groupName, leaderName } = req.body;

    // Récupérer le membre
    const member = await req.payload.findByID({
      collection: 'members',
      id: memberId
    });

    if (!member) {
      return res.status(404).json({ error: 'Membre non trouvé' });
    }

    // Personnaliser le message
    const personalizedMessage = message
      .replace('{prenom}', member.firstName)
      .replace('{nom}', member.lastName)
      .replace('{groupe}', groupName)
      .replace('{directeur}', leaderName);

    // Envoyer via WhatsApp Business API
    // (ou utiliser Baileys pour WhatsApp Web)
    try {
      const response = await fetch('https://graph.facebook.com/v17.0/YOUR_PHONE_ID/messages', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${process.env.WHATSAPP_TOKEN}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          messaging_product: 'whatsapp',
          to: member.phone,
          type: 'text',
          text: { body: personalizedMessage }
        })
      });

      const result = await response.json();
      return res.json({ success: true, result });
    } catch (error) {
      return res.status(500).json({ error: 'Erreur envoi WhatsApp' });
    }
  }
};

export default sendWhatsAppMessage;
```

---

## PARTIE 2 : APP FLUTTER MOBILE

### 2.1 Modifications du projet existant

#### Nouveaux fichiers à créer
```
lib/
├── config/
│   └── api_config.dart          // URL de l'API Payload
├── services/
│   ├── api_service.dart         // Client HTTP pour Payload API
│   └── auth_service.dart        // Auth via Payload (remplace Firebase)
├── models/
│   ├── user_model.dart          // Modèle utilisateur avec rôles
│   ├── church_model.dart        // Modèle église
│   └── member_model.dart        // Modèle membre
├── screens/
│   ├── auth/
│   │   └── login_screen.dart    // Connexion via Payload
│   ├── admin/
│   │   ├── admin_dashboard.dart
│   │   ├── manage_groups.dart
│   │   ├── manage_leaders.dart
│   │   └── all_members.dart
│   └── leader/
│       ├── leader_dashboard.dart
│       ├── my_group.dart
│       ├── take_attendance.dart
│       └── group_stats.dart
```

### 2.2 Service API (api_service.dart)

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://ton-domaine-payload.com/api';
  String? _token;

  // Headers d'authentification
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'JWT $_token',
  };

  // Connexion
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['token'];
      return true;
    }
    return false;
  }

  // Déconnexion
  Future<void> logout() async {
    await http.post(
      Uri.parse('$baseUrl/users/logout'),
      headers: _headers,
    );
    _token = null;
  }

  // Récupérer les membres
  Future<List<dynamic>> getMembers({String? groupId}) async {
    String url = '$baseUrl/members?limit=100';
    if (groupId != null) url += '&where[group][equals]=$groupId';

    final response = await http.get(Uri.parse(url), headers: _headers);
    return json.decode(response.body)['docs'];
  }

  // Récupérer les groupes
  Future<List<dynamic>> getGroups() async {
    final response = await http.get(
      Uri.parse('$baseUrl/groups?limit=100'),
      headers: _headers,
    );
    return json.decode(response.body)['docs'];
  }

  // Créer une séance d'appel
  Future<Map<String, dynamic>> createSession(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/attendance-sessions'),
      headers: _headers,
      body: json.encode(data),
    );
    return json.decode(response.body);
  }

  // Enregistrer les présences
  Future<void> saveAttendance(String sessionId, List<Map<String, dynamic>> records) async {
    for (final record in records) {
      record['session'] = sessionId;
      await http.post(
        Uri.parse('$baseUrl/attendance-records'),
        headers: _headers,
        body: json.encode(record),
      );
    }
  }

  // Envoyer message WhatsApp
  Future<void> sendWhatsApp(String memberId, String message, String groupName, String leaderName) async {
    await http.post(
      Uri.parse('$baseUrl/send-whatsapp'),
      headers: _headers,
      body: json.encode({
        'memberId': memberId,
        'message': message,
        'groupName': groupName,
        'leaderName': leaderName,
      }),
    );
  }

  // Statistiques
  Future<Map<String, dynamic>> getStats(String churchId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stats?church=$churchId'),
      headers: _headers,
    );
    return json.decode(response.body);
  }
}
```

### 2.3 Modèle User avec rôles

```dart
// lib/models/user_model.dart
class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;  // 'admin', 'pasteur', 'president_group', 'membre'
  final String churchId;
  final String? groupId;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.churchId,
    this.groupId,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'] ?? '',
      role: json['role'],
      churchId: json['church']['id'] ?? json['church'],
      groupId: json['group']?['id'] ?? json['group'],
      photoUrl: json['photo']?['url'],
    );
  }

  String get fullName => '$firstName $lastName';

  bool get isAdmin => role == 'admin' || role == 'pasteur';
  bool get isLeader => role == 'president_group';
  bool get isMember => role == 'membre';
}
```

### 2.4 Écran de connexion

```dart
// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de l'église
            Image.asset('assets/church_logo.png', height: 120),
            SizedBox(height: 48),

            Text('Presencia', style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 32),

            // Champ email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),

            // Champ mot de passe
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 8),

            // Message d'erreur
            if (_error != null)
              Text(_error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 24),

            // Bouton connexion
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Se connecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    final success = await api.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success) {
      // Navigation selon le rôle
      final user = await api.getCurrentUser();
      if (user.isAdmin) {
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
      } else if (user.isLeader) {
        Navigator.pushReplacementNamed(context, '/leader/dashboard');
      }
    } else {
      setState(() {
        _error = 'Email ou mot de passe incorrect';
        _isLoading = false;
      });
    }
  }
}
```

### 2.5 Dashboard Admin

```dart
// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _stats;
  List<dynamic> _groups = [];
  List<dynamic> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final api = context.read<ApiService>();
    final stats = await api.getStats('current-church-id');
    final groups = await api.getGroups();
    final members = await api.getMembers();

    setState(() {
      _stats = stats;
      _groups = groups;
      _members = members;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord Admin'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => context.read<ApiService>().logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Stats globales
            _buildStatsCard(),
            SizedBox(height: 16),

            // Groupes
            _buildGroupsSection(),
            SizedBox(height: 16),

            // Membres récents
            _buildRecentMembers(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/admin/add-group'),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistiques', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Groupes', _stats?['totalGroups'] ?? 0, Colors.blue),
                _buildStatItem('Membres', _stats?['totalMembers'] ?? 0, Colors.green),
                _buildStatItem("Aujourd'hui", _stats?['todayPresent'] ?? 0, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        Text(label),
      ],
    );
  }

  Widget _buildGroupsSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Groupes', style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/admin/manage-groups'),
                  child: Text('Voir tout'),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _groups.length,
            itemBuilder: (context, index) {
              final group = _groups[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(int.parse(group['color'] ?? '0xFF2196F3')),
                ),
                title: Text(group['name']),
                subtitle: Text('${group['memberCount'] ?? 0} membres'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/admin/group-detail', arguments: group);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMembers() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Membres récents', style: Theme.of(context).textTheme.titleLarge),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _members.take(5).length,
            itemBuilder: (context, index) {
              final member = _members[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(member['firstName'][0] + member['lastName'][0]),
                ),
                title: Text('${member['firstName']} ${member['lastName']}'),
                subtitle: Text(member['phone'] ?? ''),
                trailing: Icon(Icons.chevron_right),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### 2.6 Dashboard Dirigeant

```dart
// lib/screens/leader/leader_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';

class LeaderDashboard extends StatefulWidget {
  @override
  _LeaderDashboardState createState() => _LeaderDashboardState();
}

class _LeaderDashboardState extends State<LeaderDashboard> {
  List<dynamic> _members = [];
  Map<String, dynamic>? _groupStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final api = context.read<ApiService>();
    final user = await api.getCurrentUser();

    // Charger uniquement les membres de son groupe
    final members = await api.getMembers(groupId: user.groupId);
    final stats = await api.getGroupStats(user.groupId!);

    setState(() {
      _members = members;
      _groupStats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Groupe'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Stats du groupe
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statistiques du groupe', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(_members.length.toString(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                          Text('Membres'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(_groupStats?['attendanceRate'] ?? '0%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
                          Text("Taux de présence"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Bouton appel
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/leader/take-attendance');
              },
              icon: Icon(Icons.how_to_reg),
              label: Text('Faire l\'appel'),
            ),
          ),
          SizedBox(height: 16),

          // Liste des membres
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Membres du groupe', style: Theme.of(context).textTheme.titleLarge),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(member['firstName'][0] + member['lastName'][0]),
                      ),
                      title: Text('${member['firstName']} ${member['lastName']}'),
                      subtitle: Text(member['phone'] ?? ''),
                      trailing: IconButton(
                        icon: Icon(Icons.message, color: Colors.green),
                        onPressed: () {
                          // Envoyer message WhatsApp
                          _sendWhatsApp(member);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendWhatsApp(dynamic member) {
    // Ouvrir WhatsApp avec message pré-rempli
    final phone = member['phone']?.replaceAll(' ', '');
    final message = Uri.encodeComponent(
      'Bonjour ${member['firstName']}, comment vas-tu ?'
    );
    // Ouvrir WhatsApp
  }
}
```

### 2.7 Écran d'appel

```dart
// lib/screens/leader/take_attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';

class TakeAttendanceScreen extends StatefulWidget {
  @override
  _TakeAttendanceScreenState createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  List<dynamic> _members = [];
  Map<String, String> _attendance = {}; // memberId -> status
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final api = context.read<ApiService>();
    final user = await api.getCurrentUser();
    final members = await api.getMembers(groupId: user.groupId);

    setState(() {
      _members = members;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Appel du jour'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAttendance,
            child: _isSaving
              ? CircularProgressIndicator(color: Colors.white)
              : Text('Enregistrer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          final memberId = member['id'];
          final currentStatus = _attendance[memberId] ?? 'present';

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text('${member['firstName']} ${member['lastName']}'),
              subtitle: Row(
                children: [
                  _buildStatusChip('Présent', 'present', currentStatus, memberId),
                  _buildStatusChip('Absent', 'absent', currentStatus, memberId),
                  _buildStatusChip('Retard', 'late', currentStatus, memberId),
                  _buildStatusChip('Excusé', 'excused', currentStatus, memberId),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String label, String status, String currentStatus, String memberId) {
    final isSelected = currentStatus == status;
    final color = status == 'present'
      ? Colors.green
      : status == 'absent'
        ? Colors.red
        : status == 'late'
          ? Colors.orange
          : Colors.grey;

    return Padding(
      padding: EdgeInsets.only(right: 4),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 10)),
        selected: isSelected,
        selectedColor: color.withOpacity(0.3),
        onSelected: (selected) {
          setState(() {
            _attendance[memberId] = status;
          });
        },
      ),
    );
  }

  Future<void> _saveAttendance() async {
    setState(() => _isSaving = true);

    final api = context.read<ApiService>();

    // Créer la séance
    final user = await api.getCurrentUser();
    final session = await api.createSession({
      'date': DateTime.now().toIso8601String(),
      'group': user.groupId,
      'leader': user.id,
      'church': user.churchId,
    });

    // Enregistrer chaque présence
    final records = _attendance.entries.map((e) => {
      'member': e.key,
      'status': e.value,
    }).toList();

    await api.saveAttendance(session['id'], records);

    // Envoyer messages aux absents
    for (final entry in _attendance.entries) {
      if (entry.value == 'absent') {
        await _sendAbsentMessage(entry.key);
      }
    }

    setState(() => _isSaving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appel enregistré avec succès !')),
    );
  }

  Future<void> _sendAbsentMessage(String memberId) async {
    final api = context.read<ApiService>();
    final user = await api.getCurrentUser();
    final group = await api.getGroup(user.groupId!);

    // Message personnalisé
    final message = 'Bonjour {prenom}, comment vas-tu ? '
        'Pourquoi n\'étais-tu pas à la séance de {groupe} d\'aujourd\'hui ? '
        'Tu nous as manqué !';

    await api.sendWhatsApp(memberId, message, group['name'], user.fullName);
  }
}
```

---

## PARTIE 3 : INTÉGRATION WHATSAPP

### 3.1 Options d'intégration

| Option | Description | Coût |
|--------|-------------|------|
| **WhatsApp Business API** | Officiel, fiable, nécessite un numéroBusiness | Payant |
| **Baileys** | Open source, utilise WhatsApp Web | Gratuit |
| **Evolution API** | Self-hosted, facile à utiliser | Gratuit (self-hosted) |

### 3.2 Configuration recommandée

```
1. Créer un compte WhatsApp Business
2. Obtenir un numéro dédié à l'église
3. Configurer l'API (Baileys ou Evolution)
4. Déployer sur un VPS (DigitalOcean, Hetzner)
```

### 3.3 Message personnalisé

```typescript
// Variables disponibles dans le message
{
  "{prenom}": "Jean",
  "{nom}": "Dupont",
  "{groupe}": "JAD",
  "{directeur}": "Pasteur Pierre",
  "{date}": "2024-01-15",
  "{heure}": "14h00",
  "{lieu}": "Salle 3"
}

// Message par défaut
"Bonjour {prenom}, comment vas-tu ? 
Pourquoi n'étais-tu pas à la séance de {groupe} d'aujourd'hui ? 
Tu nous as manqué ! 
- {directeur}"
```

---

## PARTIE 4 : DÉPLOIEMENT

### 4.1 Payload CMS

```bash
# 1. Créer le projet
npx create-payload-app payload-church

# 2. Configurer MongoDB
# (MongoDB Atlas gratuit ou自hosté)

# 3. Déployer sur Vercel/Render
vercel deploy
```

### 4.2 App Flutter

```bash
# 1. Build Android
flutter build apk --release

# 2. Build iOS
flutter build ios --release

# 3. Distribuer via Play Store / TestFlight
```

### 4.3 Coût estimé

| Service | Coût mensuel |
|---------|--------------|
| MongoDB Atlas (M0) | Gratuit |
| Vercel (Hobby) | Gratuit |
| VPS pour WhatsApp | ~5€ |
| Numéro WhatsApp Business | ~10€ |
| **Total** | **~15€/mois** |

---

## PROCHAINES ÉTAPES

| # | Tâche | Durée estimée |
|---|-------|---------------|
| 1 | Créer le projet Payload CMS | 1 jour |
| 2 | Configurer les collections | 1 jour |
| 3 | Créer le formulaire web | 0.5 jour |
| 4 | Modifier l'app Flutter pour appeler l'API | 2 jours |
| 5 | Implémenter l'auth avec Payload | 1 jour |
| 6 | Créer les écrans Admin | 2 jours |
| 7 | Créer les écrans Dirigeant | 2 jours |
| 8 | Intégrer WhatsApp | 1 jour |
| 9 | Tests et déploiement | 1 jour |
| **Total** | **~11 jours** |

---

Ce plan te convient-il ? Si oui, je commence par créer le projet Payload CMS.
