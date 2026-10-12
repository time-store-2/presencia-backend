# Presencia — Mise en route, dans l'ordre

Cocher au fur et à mesure. Détails dans `GUIDE_DEMARRAGE.md`.

## 1. Mettre le code sur GitHub

- [ ] `git push` de la branche `simplification` (puis merge vers `main` si tu veux)
- [ ] Vérifie que le dépôt est à jour sur github.com

## 2. Créer la base Neon (gratuit)

- [ ] https://neon.tech → compte → **New Project** nommé `presencia`
- [ ] Région : **Paris (`eu-west-3`)** (la plus proche de l'Afrique de l'Ouest)
- [ ] Copier la **Connection String** (`postgresql://...?sslmode=require`)

## 3. Déployer sur Vercel (gratuit)

- [ ] https://vercel.com → **Add New → Project** → importe ton dépôt
- [ ] **Root Directory** : `presencia-backend`
- [ ] Variables d'environnement (**Production**), noms exacts :
  - `DATABASE_URL` = la chaîne Neon
  - `PAYLOAD_SECRET` = chaîne aléatoire (`openssl rand -base64 32` sur ton PC)
  - `NEXT_PUBLIC_SERVER_URL` = `https://<ton-projet>.vercel.app`
- [ ] **Deploy** (les tables se créent toutes seules pendant le build)

## 4. Créer ton compte admin

- [ ] Ouvre `https://<ton-projet>.vercel.app/admin`
- [ ] Payload propose de **créer le premier utilisateur** → rôle `admin`
- [ ] Si l'URL Vercel a changé après déploiement : mets à jour
  `NEXT_PUBLIC_SERVER_URL` dans Vercel → **Redeploy**

## 5. Configurer dans le dashboard

- [ ] **Groupes** → crée un groupe par classe (`CE2 B`…) ; note chaque **slug** (`ce2-b`)
- [ ] **Réglages** → personnalise le message d'absence WhatsApp
- [ ] **Utilisateurs** → crée des comptes `assistant` si quelqu'un t'aide (+ groupes assignés)

## 6. Inscrire les élèves

- [ ] Envoie à chaque classe son lien :
  `https://<ton-projet>.vercel.app/inscription?groupe=<slug>`
- [ ] Vérifie dans **Membres** que les inscrits arrivent (téléphones normalisés en chiffres)

## 7. Installer l'app sur le(s) téléphone(s)

- [ ] `cd presence && flutter build apk --release --dart-define=PAYLOAD_URL=https://<ton-projet>.vercel.app`
- [ ] Transfère `build/app/outputs/flutter-apk/app-release.apk` sur le téléphone → installe
- [ ] Connecte-toi avec ton compte admin (ou assistant)

## 8. Utilisation quotidienne

- [ ] Crée la séance du jour dans l'app → fais l'appel
- [ ] Pour chaque absent : bouton 💬 → message pré-rempli dans **ton** WhatsApp → envoyer
- [ ] Consulte les stats (taux du jour, tops, alertes) et l'export CSV si besoin
