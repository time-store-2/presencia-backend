# Presencia — Description du projet (admin + app)

> Document de référence pour poser des questions à un assistant IA.
> Projet : système de gestion de présence multi-organisations
> (églises, écoles, entreprises). Français + anglais.

## 1. Vue d'ensemble

Deux projets dans ce dépôt :

| Projet | Techno | Rôle | Dossier |
|--------|--------|------|---------|
| **Backend / Admin** | Payload CMS 3.90 + Next.js + SQLite | API REST, dashboard web admin, formulaire public d'inscription, envoi WhatsApp | `presencia-backend/` |
| **App mobile** | Flutter (Dart) | Utilisée par les admins et responsables : listes, appel de présence, statistiques | `presence/` |

**Principe central : Payload est la seule source de vérité.**
Il n'y a pas de Firebase, pas de base séparée : l'app Flutter lit et écrit
directement dans l'API Payload via HTTP + JWT.

## 2. L'admin (Payload CMS)

### 2.1 Comment c'est fait

- Généré depuis le template officiel `blank` de Payload 3.90 (`pnpm dlx create-payload-app`),
  puis adapté : fichier de config unique `presencia-backend/src/payload.config.ts`.
- Base de données : **SQLite** (`@payloadcms/db-sqlite`), fichier `presencia-backend/presencia.db`.
  Choix fait pour le développement local simple (zéro serveur Mongo/Postgres).
  Config : `DATABASE_URL=file:./presencia.db` dans `presencia-backend/.env`.
- Dashboard web : `http://localhost:3002/admin` (port 3002, `pnpm dev` dans `presencia-backend/`).
- API REST : `http://localhost:3002/api/<collection>` (ex : `/api/members`, `/api/groups`).
- Premier compte créé par script : `presencia-backend/src/seed.ts` (commande `pnpm seed`),
  qui crée une organisation + un super admin. Refuse de tourner si des utilisateurs existent déjà.

### 2.2 Collections (= tables), dans `src/collections/`

| Collection | Champs importants | Fichier |
|------------|-------------------|---------|
| `Organizations` | `name`, `type` (eglise/ecole/entreprise/ong/autre), `code` unique (ex `ORG-ABJ-001`), `absenceMessage` (template WhatsApp), `admins` | `Organizations.ts` |
| `Users` | `email`, `password`, `role` (super_admin/org_admin/group_leader), `organization`, `assignedGroup`, `displayName`, `phone` | `Users.ts` |
| `Groups` | `name`, `organization`, `leader` (relation Users), `meetingDay`, `meetingTime` | `Groups.ts` |
| `Members` | `firstName`, `lastName`, `birthDate`, `gender`, `phone`, `email`, `address`, `registrationNumber`, `position`, `groups` (hasMany → plusieurs groupes possibles), `parent1`/`parent2` (groupe : firstName, lastName, phone, relation father/mother/guardian/other), `organization` | `Members.ts` |
| `AttendanceSessions` | `group`, `date`, `status` (open/closed), `markedCount`, `totalCount`, `presentCount`, `absentCount` (compteurs mis à jour par hooks) | `AttendanceSessions.ts` |
| `AttendanceRecords` | `session`, `member`, `present` (bool), `late` (bool), `note` | `AttendanceRecords.ts` |
| `Media` | uploads d'images (logos, photos) | `Media.ts` |

- Tous les IDs sont **numériques** (comportement par défaut de Payload + SQLite).
- Règles de suppression en cascade via hooks : supprimer une session supprime ses
  pointages ; supprimer un membre supprime ses pointages ; supprimer un groupe
  supprime ses sessions et détache ses membres.

### 2.3 Rôles et isolation des données (`src/access/roles.ts`)

Trois rôles :

| Rôle | Voit |
|------|------|
| `super_admin` | Tout (toutes les organisations) |
| `org_admin` | Tous les groupes et membres de son organisation |
| `group_leader` | Uniquement son groupe assigné |

Appliqué à deux niveaux : filtres de lecture (`filterOwnOrganization`, `filterGroups`,
`filterMembers`, `filterSessions`) + règles de création (`canCreateUser`, `canCreateOrganization`,
avec bootstrap : le tout premier utilisateur/organisation est créable sans être connecté,
ensuite seul le super_admin crée les organisations).

### 2.4 Endpoints personnalisés (branchés dans `payload.config.ts`)

| Endpoint | Fichier | Rôle |
|----------|---------|------|
| `POST /api/notify-absence {sessionId}` | `src/endpoints/notifyAbsence.ts` | Après un appel avec des absents : envoie à chaque absent le message WhatsApp (template `absenceMessage` de l'org, variables `{prenom},{nom},{groupe},{responsable},{date}`). Sans `WHATSAPP_WEBHOOK_URL` configuré, journalise en console (`[whatsapp:dev]`) au lieu d'envoyer |
| `GET /api/org-stats` | `src/endpoints/stats.ts` | Stats globales de l'organisation du jour |
| `GET /api/member-stats?memberId=` | `src/endpoints/stats.ts` | Historique de présence d'un membre |
| `GET /api/period-stats?groupId=&start=&end=` | `src/endpoints/stats.ts` | Stats d'un groupe sur une période |

### 2.5 WhatsApp (`src/lib/whatsapp.ts`)

- `sendWhatsApp(phone, message)` : POST vers un webhook compatible Evolution API
  (`WHATSAPP_WEBHOOK_URL` + `WHATSAPP_API_KEY` dans `.env`), sinon log console.
- `renderTemplate(template, vars)` : remplace les `{variables}` du message.
- Chaque organisation a son propre texte `absenceMessage`, modifiable dans le dashboard.

### 2.6 Formulaire public d'inscription

- Page Next.js dans le backend : `src/app/(frontend)/inscription/page.tsx` + `form.tsx`.
- URL : `http://localhost:3002/inscription?org=CODE-ORG` (le `code` unique de l'organisation).
- Le visiteur choisit son/ses groupes (cases à cocher), remplit ses infos + 0, 1 ou 2 parents,
  ça crée un `Member` via `POST /api/members` (création publique autorisée uniquement sur Members).
- Champs du formulaire adaptés selon `organizationType` (ex : `position` demandée pour une église).

### 2.7 Comptes de test actuels (base de développement)

| Email | Mot de passe | Rôle |
|-------|--------------|------|
| `dir@test.com` | `test1234` | Admin de « Ecole Test » (`ORG-ECOLE-001`) |
| `prof@test.com` | `test1234` | Responsable du groupe « 6ème A » |

## 3. L'app mobile (Flutter)

### 3.1 Comment c'est fait

- Projet Flutter classique (`presence/`, `lib/main.dart`).
- **Authentification JWT Payload** : `POST /api/users/login` avec email + mot de passe,
  token stocké dans `flutter_secure_storage`, envoyé dans le header
  `Authorization: JWT <token>` à chaque requête. **Pas d'inscription dans l'app** :
  les comptes sont créés par l'admin dans le dashboard.
- Couche réseau unique : `lib/core/services/api_service.dart`
  (`login`, `get`, `getManyIn`, `getById`, `post`, `update`, `delete`, `getRaw`, `notifyAbsences`).
- Conversion Payload → modèles Dart : `lib/core/services/payload_mappers.dart`
  (gère les relations peuplées `{id, ...}` ou brutes `id`, les dates ISO, les champs absents).
- Historique : l'app utilisait Firebase + SQLite local (`firebase_*`, `sync_service.dart`) —
  **tout ça a été supprimé**. Restent quelques fichiers SQLite locaux hérités
  (`core/database/`) mais les providers passent par l'API Payload.
- URL du backend compilée via `--dart-define=PAYLOAD_URL=...` :
  `http://10.0.2.2:3002` sur émulateur Android, IP locale du PC (ex `http://192.168.1.126:3002`)
  sur téléphone physique (même WiFi que le PC).

### 3.2 State management : Provider (`lib/core/providers/`)

| Provider | Responsabilité |
|----------|----------------|
| `auth_provider.dart` | Login/logout, utilisateur courant (`AppUser` : id, role, organizationId, assignedGroupId, `isOrgAdmin`, `isGroupLeader`) |
| `group_provider.dart` | Groupes visibles selon le rôle (requête filtrée par `organizationId` ou `assignedGroupId`) |
| `adolescent_provider.dart` | Membres (nom hérité de l'ancien vocabulaire « jeunes ») |
| `attendance_provider.dart` | Sessions d'appel + pointages, déclenche `notifyAbsences` après enregistrement |
| `settings_provider.dart` | Langue FR/EN, thème |

### 3.3 Écrans (`lib/ui/screens/`)

| Écran | Rôle |
|-------|------|
| `splash_screen.dart` | Démarrage, restaure la session si token valide |
| `auth/login_screen.dart` → `auth_wrapper.dart` | Connexion email + mot de passe |
| `onboarding_screen.dart` | Première ouverture |
| `dashboard_screen.dart` | Accueil : taux du jour = **présents + retards du jour ÷ membres marqués (présents + retards + absents) du jour**. ⚠️ Ancien bug connu : le taux divisait par le total des membres au lieu des marqués — corrigé |
| `groups_screen.dart` → `group_detail_screen.dart` | Liste des groupes → détail d'un groupe |
| `attendance_sessions_screen.dart` → `take_attendance_screen.dart` → `session_detail_screen.dart` | Sessions d'appel → faire l'appel (présent/absent/retard) → détail + envoi WhatsApp aux absents |
| `youth_list_screen.dart` → `youth_detail_screen.dart` | Liste des membres → fiche membre (infos + parents + historique via `/api/member-stats`) |
| `add_adolescent_screen.dart` | Ajouter un membre manuellement |
| `stats_screen.dart` → `attendance_report_screen.dart` | Statistiques (période, groupe) via `/api/period-stats` |
| `settings_screen.dart` | Langue, thème, déconnexion |

- Modèles : `models/app_user.dart`, `group.dart`, `adolescent.dart` (membre),
  `attendance_session.dart`, `attendance.dart` (pointage), `parent.dart`.
- Internationalisation : `lib/l10n/app_fr.arb` + `app_en.arb`
  (vocabulaire générique : « Membres », pas « Jeunes »).
- Export CSV : `core/services/export_service.dart` (données via API).
- Design : `ui/widgets/glass_card.dart`, `app_background.dart`, `core/themes/app_themes.dart`.

## 4. Comment on a travaillé (choix et étapes)

1. Architecture d'abord (`docs/ARCHITECTURE_DETAILLEE.md`) : modèle générique
   multi-organisations plutôt que spécifique à une église.
2. Backend Payload initialisé depuis le template `blank`, collections créées une par une,
   rôles et filtres d'accès ajoutés (`src/access/roles.ts`).
3. Base passée de MongoDB à **SQLite** (`@payloadcms/db-sqlite`) pour le dev local simple.
4. Formulaire `/inscription` + endpoint WhatsApp + endpoints stats, testés en direct
   avec `curl` (création membre, session, pointages, notification).
5. App Flutter : suppression de Firebase, réécriture des providers sur `ApiService`,
   labels génériques FR/EN, correction du calcul du taux du dashboard.
6. Extensions : membres multi-groupes (`groups` hasMany) + 2 parents (`parent1`/`parent2`),
   vérifiées en direct puis données temporaires supprimées.
7. `src/seed.ts` + `pnpm seed` pour le premier compte, `README.md` backend réécrit,
   `GUIDE_DEMARRAGE.md` à la racine (démarrage pas-à-pas).

## 5. Commandes utiles

```bash
# Backend (http://localhost:3002, dashboard /admin)
cd presencia-backend && pnpm install && pnpm dev
pnpm seed   # premier compte sur base vide

# App (émulateur Android)
cd presence && flutter pub get
flutter run --dart-define=PAYLOAD_URL=http://10.0.2.2:3002
# App (téléphone physique, même WiFi que le PC)
flutter run --dart-define=PAYLOAD_URL=http://<IP-PC>:3002

# Repartir d'une base propre
rm presencia-backend/presencia.db* && cd presencia-backend && pnpm dev
```
