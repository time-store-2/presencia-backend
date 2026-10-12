# Presencia Backend — Payload CMS + SQLite

Backend multi-organisations (églises, écoles, entreprises) : API, dashboard
admin, formulaire public d'inscription, notifications d'absence WhatsApp.
Base de données : fichier SQLite local (`presencia.db`), rien à installer.

## 1. Démarrer l'API

```bash
cd presencia-backend
pnpm install   # une seule fois
pnpm dev       # démarre sur http://localhost:3002
```

- API : `http://localhost:3002/api`
- Dashboard : `http://localhost:3002/admin`
- Arrêter : `Ctrl + C`

## 2. Créer le premier compte

Sur une base vide, crée l'organisation + le super admin en une commande :

```bash
pnpm seed
```

Personnaliser (optionnel) :

```bash
SEED_ORG_NAME="Mon Église" SEED_ORG_TYPE=eglise SEED_ORG_CODE=ORG-ABJ-001 \
SEED_EMAIL="pasteur@moneglise.ci" SEED_PASSWORD="MotDePasseSolide!" \
pnpm seed
```

Puis connecte-toi sur `http://localhost:3002/admin` et change le mot de passe
(Users → ton compte → nouveau mot de passe).

## 3. Créer les comptes dans le dashboard

Connecté en **super admin** ou **admin d'organisation** :

1. **Organizations** → vérifie ton organisation (nom, type, code unique).
   Le code sert pour le lien d'inscription (ex : `ORG-ABJ-001`).
2. **Groups** → `Create New` pour chaque groupe (JAD, 6ème A, Équipe Compta…),
   rattaché à ton organisation.
3. **Users** → `Create New` pour chaque responsable :
   - email + mot de passe (à lui transmettre),
   - **Role** = `Responsable de groupe`,
   - **Organisation** = la tienne,
   - **Groupe assigné** = son groupe.
4. Le responsable se connecte avec cet email/mot de passe dans **l'app mobile**
   ou dans le dashboard : il ne voit que son groupe.

Rôles :

| Rôle | Voit |
|------|------|
| Super Admin | Toutes les organisations |
| Admin d'organisation | Tous les groupes et membres de son organisation |
| Responsable de groupe | Uniquement son groupe |

## 4. Lien d'inscription des membres

```
http://localhost:3002/inscription?org=TON-CODE-ORG
```

Envoie ce lien (WhatsApp, affiche, QR code) : la personne remplit le
formulaire et apparaît directement dans les membres de son groupe.

## 5. WhatsApp (optionnel)

Sans configuration, les messages d'absence sont journalisés dans la console.
Pour envoyer vraiment, ajoute dans `.env` :

```
WHATSAPP_WEBHOOK_URL=https://ton-evolution-api/message/sendText/ton-instance
WHATSAPP_API_KEY=ta-cle-api
```

Le texte envoyé est le modèle **absenceMessage** de chaque organisation
(modifiable dans Organizations). L'app mobile déclenche l'envoi via
`POST /api/notify-absence` après chaque appel.

## Production

```bash
pnpm build && pnpm start
```

Pense à changer `PAYLOAD_SECRET`, utiliser une base Postgres pour du
multi-serveur, et servir derrière HTTPS.
