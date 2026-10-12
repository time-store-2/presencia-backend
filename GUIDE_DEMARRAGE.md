# Presencia — Guide de démarrage

Système de gestion de présence multi-organisations (églises, écoles,
entreprises). Deux projets :

| Projet | Rôle | Dossier |
|--------|------|---------|
| **Backend** (Payload CMS + SQLite) | API, dashboard admin, inscription web, WhatsApp | `presencia-backend/` |
| **App mobile** (Flutter) | Admins et responsables : listes, appel, stats | `presence/` |

## 1. Démarrer l'API

```bash
cd presencia-backend
pnpm install   # une seule fois
pnpm dev       # http://localhost:3002
```

- **Dashboard : http://localhost:3002/admin**
- API : http://localhost:3002/api
- Arrêter : `Ctrl + C`

## 2. Se connecter au dashboard

### Base de test actuelle (données de démonstration)

| Email | Mot de passe | Rôle |
|-------|--------------|------|
| `dir@test.com` | `test1234` | Admin d'organisation (École Test) |
| `prof@test.com` | `test1234` | Responsable du groupe 6ème A |

⚠️ Ce sont des comptes **de test**. Pour une vraie utilisation, repars
d'une base propre (voir § 5) et crée de vrais comptes.

### Première connexion sur une base vide

```bash
pnpm seed
```

Crée l'organisation + un super admin (`admin@presencia.local` /
`ChangeMe123!` par défaut). Personnaliser :

```bash
SEED_ORG_NAME="Mon Église" SEED_ORG_TYPE=eglise SEED_ORG_CODE=ORG-ABJ-001 \
SEED_EMAIL="pasteur@moneglise.ci" SEED_PASSWORD="MotDePasseSolide!" \
pnpm seed
```

## 3. Ordre de création dans l'admin (à suivre dans cet ordre)

> **Important : il y a 2 choses différentes.**
>
> | | Compte avec mot de passe ? | Se connecte ? |
> |---|---|---|
> | **Utilisateur** (admin, responsable) | ✅ Oui, c'est toi qui le crées | ✅ App mobile + dashboard |
> | **Membre** (fidèle, élève, employé) | ❌ Non, jamais | ❌ Il remplit juste le formulaire, puis il apparaît dans les listes |
>
> Donc on ne met **jamais** de mot de passe aux membres : ils s'inscrivent
> via le lien, et toi tu les retrouves dans **Members**.

Connecté en super admin ou admin d'organisation, dans cet ordre :

1. **Organizations** → vérifie ton organisation et son **code unique**
   (ex : `ORG-ABJ-001`). Le code sert pour le lien d'inscription.
2. **Groups** → `Create New` pour chaque groupe (JAD, 6ème A, Équipe Compta…).
   C'est toi qui crées les groupes, pas les membres.
3. **Users** → `Create New` pour chaque responsable :
   - email + mot de passe (à lui transmettre),
   - **Role** = `Responsable de groupe`,
   - **Organisation** = la tienne,
   - **Groupe assigné** = son groupe.
4. **Lien d'inscription** → envoie `http://localhost:3002/inscription?org=TON-CODE`
   à tout le monde (WhatsApp, affiche). Chacun remplit le formulaire en
   choisissant son groupe.
5. **Members** → vérifie que les inscrits apparaissent bien dans leurs groupes.
6. Le responsable se connecte avec ses identifiants dans **l'app mobile**
   et fait l'appel : il ne voit que son groupe. Les absents reçoivent le
   message WhatsApp automatiquement.

| Rôle | Voit |
|------|------|
| Super Admin | Toutes les organisations |
| Admin d'organisation | Tous les groupes et membres de son organisation |
| Responsable de groupe | Uniquement son groupe |

## 4. Inscrire les membres

Envoie ce lien (WhatsApp, affiche, QR code) :

```
http://localhost:3002/inscription?org=TON-CODE-ORG
```

La personne remplit le formulaire (multi-groupes, 2 parents possibles) et
apparaît directement chez le responsable de son groupe.

## 5. Repartir d'une base propre

```bash
# arrêter le serveur (Ctrl + C), puis :
rm presencia-backend/presencia.db*
# relancer :
cd presencia-backend && pnpm dev
# dans un autre terminal :
pnpm seed
```

## 6. Lancer l'app mobile (Flutter)

```bash
cd presence
flutter pub get
# émulateur Android (backend sur la machine hôte) :
flutter run --dart-define=PAYLOAD_URL=http://10.0.2.2:3002
# appareil physique : remplace par l'IP locale du PC, ex :
# flutter run --dart-define=PAYLOAD_URL=http://192.168.1.50:3002
```

Connecte-toi avec un compte créé à l'étape 3.

## 7. WhatsApp (optionnel)

Sans configuration, les messages d'absence sont journalisés dans la console
du serveur. Pour envoyer vraiment, ajoute dans `presencia-backend/.env` :

```
WHATSAPP_WEBHOOK_URL=https://ton-evolution-api/message/sendText/ton-instance
WHATSAPP_API_KEY=ta-cle-api
```

Le texte envoyé = le champ **absenceMessage** de chaque organisation
(modifiable dans le dashboard). L'envoi se déclenche automatiquement quand
le responsable enregistre un appel avec des absents.
