# Architecture Détaillée - Système Presencia (Multi-Organisations)

## 1. Vue d'ensemble

Presencia est un système de gestion de présence générique. Il fonctionne pour
les églises, les écoles, les entreprises, les associations — tout groupe qui
fait l'appel.

Le système se compose de deux parties :
- **Payload CMS** : Backend unique, API, panel admin, formulaire d'inscription web
- **Flutter Mobile** : Application mobile pour les admins et les responsables de groupe

Firebase est abandonné. Payload est la seule source de vérité.

---

## 2. Les acteurs du système

| Rôle | Qui est-ce | Ce qu'il fait |
|------|-----------|---------------|
| **Super Admin** | Toi, côté SaaS (plus tard) | Gère toutes les organisations |
| **Org Admin** | Pasteur, directeur d'école, manager | Crée son organisation, gère les comptes, voit tout de SON organisation |
| **Responsable de groupe** | Président JAD, enseignant, chef d'équipe | Gère SON groupe, fait l'appel, envoie des messages |
| **Membre** | Fidèle, élève, employé | S'inscrit via le lien web, reçoit des messages |

---

## 3. Flux de création des comptes

```
ÉTAPE 1 : L'org admin crée son organisation
    → Il choisit un code unique (ex: ORG-ABIDJAN-001)
    → Ce code isole toutes les données de cette organisation

ÉTAPE 2 : L'org admin crée les groupes
    → Église : "JAD", "Chorale" / École : "6ème A" / Entreprise : "Équipe Compta"
    → Pour chaque groupe, il assigne un responsable

ÉTAPE 3 : L'org admin crée le compte du responsable
    → Nom, email, téléphone + rôle "group_leader" + groupe assigné
    → Le responsable reçoit ses identifiants de connexion

ÉTAPE 4 : L'org admin génère un lien d'inscription
    → Le lien contient le code de l'organisation
    → Envoyé par WhatsApp, email, ou affiché en QR code

ÉTAPE 5 : La personne clique sur le lien
    → Elle remplit le formulaire (nom, téléphone, groupe choisi)
    → Elle est enregistrée avec organizationId + groupId
    → Elle apparaît dans la liste du groupe côté admin/responsable
```

---

## 4. Structure des données

### 4.1 Organisation (Organizations)
- Nom de l'organisation
- Type : eglise, ecole, entreprise, association, autre
- Code unique (ex: ORG-ABIDJAN-001) — isole les données
- Logo, adresse, téléphone, email de contact
- Référence vers l'org admin

### 4.2 Utilisateur (Users)
- Prénom, Nom, email (connexion), téléphone, photo
- Rôle : super_admin, org_admin, group_leader
- Référence vers l'organisation
- Référence vers le groupe (uniquement si group_leader)

### 4.3 Groupe (Groups)
- Nom (JAD, 6ème A, Équipe Compta — selon le type d'org)
- Description, couleur, jour et heure de réunion
- Référence vers l'organisation
- Référence vers le responsable

### 4.4 Membre (Members)
- Champs communs : prénom, nom, téléphone, email, sexe,
  date de naissance, adresse, date d'inscription, statut actif/inactif
- Champs selon le type d'organisation :
  - 2 contacts parents/tuteurs complets (prénom, nom, téléphone, lien)
  - École : matricule, nom du tuteur
  - Entreprise : matricule, poste
- Liste de groupes (multi-groupes) + référence vers l'organisation

### 4.5 Séance d'appel (AttendanceSessions)
- Date, notes, statut ouverte/fermée
- Référence vers le groupe, le responsable, l'organisation

### 4.6 Présence (AttendanceRecords)
- Statut : présent, absent, retard, excusé
- Horodatage, note
- Référence vers la séance + vers le membre

---

## 5. Système de visibilité (Qui voit quoi)

### Org Admin
- Voit TOUS les groupes de SON organisation uniquement
- Voit TOUS les membres de SON organisation uniquement
- Voit les statistiques globales de SON organisation
- Peut créer/supprimer groupes et responsables
- Peut envoyer des messages à n'importe qui de son organisation

### Responsable de groupe
- Voit UNIQUEMENT son groupe
- Voit UNIQUEMENT les membres de son groupe
- Voit les statistiques de SON groupe uniquement
- Peut faire l'appel pour SON groupe
- Peut envoyer des messages aux membres de SON groupe

### Membre
- Accès au formulaire web uniquement pour s'inscrire
- Reçoit des messages WhatsApp

Isolation garantie par le champ organizationId présent partout
+ contrôle d'accès Payload qui filtre sur ce champ.

---

## 6. L'application Flutter (Mobile)

### 6.1 Écran de connexion
- Email + mot de passe, vérifiés par l'API Payload (JWT)
- Redirection selon le rôle : dashboard org admin ou dashboard responsable

### 6.2 Dashboard Org Admin
- Statistiques de l'organisation : total membres, groupes, présence du jour
- Liste des groupes avec effectif et responsable
- Liste de tous les membres avec recherche
- Actions : créer un groupe, créer un responsable, générer le lien d'inscription

### 6.3 Dashboard Responsable
- Son groupe : nom, effectif, taux de présence
- Bouton "Faire l'appel"
- Liste des membres de son groupe avec téléphone
- Action : envoyer un message WhatsApp à un membre

### 6.4 Écran d'appel
- Liste des membres avec 4 choix chacun : Présent, Absent, Retard, Excusé
- Bouton Enregistrer → crée la séance + les présences
- Tout membre marqué absent déclenche le message WhatsApp automatique

### 6.5 Historique et statistiques
- Séances passées avec résumé (présents, absents, retards, excusés)
- Détail d'une séance : chaque membre et son statut
- Stats par groupe, évolution dans le temps, alertes d'absences répétées

---

## 7. Le formulaire web (Payload)

### 7.1 Page d'inscription publique
- Accessible via le lien avec le code org : /inscription?org=ORG-XXX
- Affiche le logo et le nom de l'organisation
- Liste déroulante des groupes chargée depuis l'API (filtrée par org)
- Champs : prénom, nom, téléphone (obligatoire), email, sexe,
  date de naissance, adresse + champs spécifiques au type d'org
- Après envoi : message de confirmation, le membre apparaît dans l'admin

### 7.2 Panel admin Payload
- Réservé aux admins, permet de gérer les collections directement
- Utile pour maintenance et vérifications

---

## 8. Messagerie WhatsApp

### 8.1 Déclencheurs
- Manuel : le responsable clique l'icône WhatsApp d'un membre
- Automatique : membre marqué absent lors de l'appel

### 8.2 Message d'absence personnalisé
- Variables : prénom du membre, nom du groupe, nom du responsable, date
- Exemple : "Bonjour Jean, comment vas-tu ? Pourquoi n'étais-tu pas
  à la séance de JAD d'aujourd'hui ? Tu nous as manqué ! - Pasteur Pierre"
- Le template est configurable par organisation

### 8.3 Technique
- WhatsApp Business API (officiel, payant) ou Evolution API / Baileys (self-hosted)
- Numéro WhatsApp dédié par organisation (ou un numéro mutualisé au début)

---

## 9. Flux complet de présence

```
1. Le responsable ouvre l'app → voit son groupe
2. Il clique "Faire l'appel" → liste des membres
3. Il marque chaque membre (P/A/R/E)
4. Il clique "Enregistrer" → séance + présences créées
5. Chaque absent reçoit le WhatsApp automatique
6. L'org admin voit le résultat dans son dashboard
```

---

## 10. Sécurité

- Code organisation unique, toutes les données filtrées par organizationId
- Permissions Payload vérifiées avant chaque action
- Authentification JWT, déconnexion après inactivité
- Lien d'inscription public en création seule (pas de lecture des données)

---

## 11. Déploiement

- Payload + base Postgres hébergés (Railway, Render ou VPS)
- Formulaire web servi par Payload
- App Flutter : Play Store / APK + TestFlight / App Store
- Serveur WhatsApp : VPS + numéro Business dédié

---

## 12. Schéma global

```
  Org Admin         Responsable          Membre
  (Flutter)         (Flutter)            (Formulaire web)
      │                 │                      │
      └─────────────────┼──────────────────────┘
                        ▼
                   PAYLOAD CMS
        API + Admin Panel + Inscription + WhatsApp
                        ▼
                  BASE DE DONNÉES
   organizations | users | groups | members | sessions | records
```

---

## 13. Phases de développement

| Phase | Description | Livrable |
|-------|-------------|----------|
| 1 | Projet Payload + Postgres | Backend qui démarre |
| 2 | Collections + rôles + accès par org | API sécurisée |
| 3 | Formulaire d'inscription public | Lien d'inscription fonctionnel |
| 4 | Flutter branché sur l'API Payload | Connexion JWT, suppression Firebase |
| 5 | Écrans org admin | Dashboard complet |
| 6 | Écrans responsable | Appel + historique |
| 7 | WhatsApp automatique | Messages aux absents |
| 8 | Tests + déploiement | Mise en production |
