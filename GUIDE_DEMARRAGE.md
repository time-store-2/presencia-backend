# Presencia — Guide de démarrage (Neon + Vercel, gratuit)

Deux projets :

| Projet | Rôle | Dossier |
|--------|------|---------|
| **Backend** (Payload CMS + Postgres) | API, dashboard admin, inscription web | `presencia-backend/` |
| **App mobile** (Flutter) | Listes, appel, stats, WhatsApp | `presence/` |

L'app lit/écrit directement dans l'API Payload (JWT).
Pas de Firebase, pas de serveur WhatsApp.

---

## A. Créer la base Neon (5 min, plan gratuit)

1. Va sur **https://neon.tech** → crée un compte → **New Project**.
2. Nom : `presencia`. **Région : choisis la plus proche de toi**
   (si tu es en Afrique de l'Ouest : `EU West - Paris (eu-west-3)` —
   c'est la plus proche disponible).
3. Version Postgres par défaut (17 ou 18) → **Create Project**.
4. Sur le tableau de bord du projet, section **Connection String** :
   - active **Pooled** si proposé (mieux pour Vercel),
   - copie la chaîne : `postgresql://presencia_owner:xxxx@ep-xxxx.eu-west-3.aws.neon.tech/presencia?sslmode=require`.
5. Garde-la précieusement : c'est ta variable `DATABASE_URL`.

> Limites du gratuit : ~0,5 Go de données + suspension après inactivité
> (la base se réveille seule en ~1 s à la première requête).
> Largement suffisant pour des classes.

## B. Déployer le backend sur Vercel (plan Hobby gratuit)

1. Pousse le dépôt sur GitHub (`main` ou ta branche).
2. Va sur **https://vercel.com** → **Add New → Project** → importe le dépôt.
3. **Configure Project** :
   - **Framework Preset** : Next.js (détecté automatiquement),
   - **Root Directory** : clique **Edit** → sélectionne **`presencia-backend`**,
   - **Build Command** : laisse celle du projet (`pnpm build`,
     qui applique les migrations Postgres avant de compiler).
4. **Environment Variables** (cocher **Production**) :

   | Name | Value |
   |------|-------|
   | `DATABASE_URL` | la chaîne Neon copiée en A (avec `?sslmode=require`) |
   | `PAYLOAD_SECRET` | une longue chaîne aléatoire (génère avec `openssl rand -base64 32` sur ton PC) |
   | `NEXT_PUBLIC_SERVER_URL` | `https://<ton-projet>.vercel.app` (tu auras l'URL exacte après le 1er déploiement → reviens l'ajuster) |

5. **Deploy**. Le build applique les migrations tout seul
   (`payload migrate && next build`).
6. Ouvre `https://<ton-projet>.vercel.app/admin` :
   si aucun compte n'existe, Payload propose de **créer le premier
   utilisateur** → rôle `admin`.

## C. Prise en main (dashboard)

1. **Groupes** → crée un groupe par classe (`CE2 B`, `CM1`…).
   Le **slug** se génère seul (`ce2-b`) ; le lien d'inscription du groupe :
   `https://<ton-projet>.vercel.app/inscription?groupe=ce2-b`
   (bouton « Copier/Partager » aussi dans l'app).
2. **Réglages** → texte du message d'absence WhatsApp
   (`{prenom}`, `{nom}`, `{groupe}`, `{date}`).
3. Envoie le lien aux élèves (WhatsApp) : chacun remplit le formulaire,
   les doublons (même téléphone) sont fusionnés automatiquement.
4. **Utilisateurs** → crée un compte `assistant` si quelqu'un t'aide
   (il ne verra que ses groupes assignés).
5. Fais l'appel dans l'app → bouton 💬 sur chaque absent pour envoyer
   le message via **ton** WhatsApp (rien n'est envoyé automatiquement).

## D. Lancer l'app mobile

```bash
cd presence
flutter pub get
# Dev : backend local (pnpm dev dans presencia-backend)
flutter run --dart-define=PAYLOAD_URL=http://10.0.2.2:3002
```

Connecte-toi avec ton compte admin. Le téléphone doit voir le backend :
émulateur → `10.0.2.2`, téléphone physique (même WiFi) → IP locale du PC.

## E. Construire l'APK release (production)

```bash
cd presence
flutter build apk --release --dart-define=PAYLOAD_URL=https://<ton-projet>.vercel.app
```

Le fichier est dans `build/app/outputs/flutter-apk/app-release.apk` :
transfère-le sur le téléphone et installe-le (autoriser l'installation
depuis le navigateur/fichiers). L'URL de production est compilée dans
l'app : aucune URL n'est codée en dur, tout passe par `PAYLOAD_URL`.

## F. Développement local du backend (optionnel)

```bash
cd presencia-backend
pnpm install
cp .env.example .env   # DATABASE_URL = ta chaîne Neon
pnpm payload migrate    # une seule fois (crée les tables)
pnpm dev                # http://localhost:3002
```

> Tu peux développer directement contre la base Neon (c'est le plus
> simple). Pour une base locale, installe Postgres et mets son URL
> dans `.env` — jamais committé (`.env` est ignoré par git).
