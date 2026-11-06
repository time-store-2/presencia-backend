# Presencia — Backend (Payload CMS + Postgres)

Suivi des présences pour un enseignant : groupes, appel, statistiques,
inscription des élèves par lien, message WhatsApp aux absents (via l'app).

- **Stack** : Payload CMS 3.90 + Next.js 15 + Postgres (Neon en production)
- **Dashboard admin** : `/admin`
- **API** : `/api/<collection>` + endpoints personnalisés (voir ci-dessous)

## Démarrage local

Prérequis : Node 24+, pnpm 9/10/11, une base Postgres
(le plus simple : utiliser directement la base Neon de production).

```bash
cd presencia-backend
pnpm install
cp .env.example .env   # puis renseigne DATABASE_URL, PAYLOAD_SECRET
pnpm payload migrate    # crée les tables (une seule fois par base)
pnpm dev                # http://localhost:3002
```

## Variables d'environnement

| Variable | Exemple |
|----------|---------|
| `DATABASE_URL` | `postgresql://user:password@host/presencia?sslmode=require` (Neon) |
| `PAYLOAD_SECRET` | chaîne aléatoire longue (`openssl rand -base64 32`) |
| `NEXT_PUBLIC_SERVER_URL` | `http://localhost:3002` en local, `https://ton-projet.vercel.app` en prod |

## Build / production

```bash
pnpm build    # = payload migrate && next build
pnpm start
```

Le script `build` applique les migrations avant de compiler :
sur Vercel, chaque déploiement met donc la base à jour automatiquement.

Après chaque modification des collections/globals :

```bash
pnpm payload migrate:create   # génère src/migrations/XXXX.ts (à committer)
```

## Premier compte et prise en main

1. Ouvre `/admin` : si aucun utilisateur n'existe, Payload propose
   **« créer le premier utilisateur »** (rôle `admin`).
2. **Groupes** → crée un groupe par classe (ex : `CE2 B`).
   Le **slug** est généré automatiquement (`ce2-b`) ; il sert aux liens.
3. **Réglages** → personnalise le modèle de message d'absence WhatsApp
   (variables `{prenom}`, `{nom}`, `{groupe}`, `{date}`).
4. Partage le lien d'inscription (bouton dans l'app, ou manuellement) :
   `https://ton-domaine/inscription?groupe=<slug>`
   Sans paramètre, l'élève choisit ses groupes lui-même.
5. **Utilisateurs** → crée un compte `assistant` si besoin
   (ne voit que ses groupes assignés, peut faire l'appel).

Rôles : `admin` (tout voir, tout modifier) et `assistant`
(groupes assignés uniquement : appel + membres de ces groupes).

## Page d'inscription publique

- `/inscription?groupe=<slug>` : formulaire déjà lié au groupe
- `/inscription` : l'élève coche ses groupes
- `?lang=en` : version anglaise
- Les inscriptions passent par `POST /api/register` :
  téléphone normalisé (chiffres), anti-doublon par téléphone
  (un réinscrit est ajouté aux nouveaux groupes), honeypot anti-robot.

## Endpoints personnalisés

| Endpoint | Accès | Rôle |
|----------|-------|------|
| `GET /api/public-groups` | public | `{name, slug}` des groupes |
| `POST /api/register` | public | inscription (voir ci-dessus) |
| `GET /api/org-stats` | connecté | stats globales / périmètre assistant |
| `GET /api/member-stats?memberId=` | connecté | compteurs + historique d'un membre |
| `GET /api/period-stats?groupId=&start=&end=` | connecté | compteurs par membre sur période |

## Déploiement Vercel (résumé)

1. Base Neon créée (région proche, ex `eu-west-3` Paris) → copier la
   chaîne `postgresql://...?sslmode=require`.
2. Vercel → nouveau projet → importe le dépôt → **Root Directory :
   `presencia-backend`**.
3. Variables d'environnement (Production) : `DATABASE_URL`, `PAYLOAD_SECRET`,
   `NEXT_PUBLIC_SERVER_URL=https://<ton-projet>.vercel.app`.
4. Deploy : le build applique les migrations tout seul.
5. Ouvre `https://<ton-projet>.vercel.app/admin` → crée le premier compte.

Détail pas-à-pas : `../GUIDE_DEMARRAGE.md`.

## App mobile (Flutter, dossier `presence/`)

L'app se connecte au backend via l'URL compilée :

```bash
# Dev (émulateur Android)
flutter run --dart-define=PAYLOAD_URL=http://10.0.2.2:3002
# Release (APK avec l'URL de production)
flutter build apk --release --dart-define=PAYLOAD_URL=https://<ton-projet>.vercel.app
```

