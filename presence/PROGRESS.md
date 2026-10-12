# Suivi du Projet Presencia (MVP)

Ce fichier permet de suivre l'évolution du développement de l'application de gestion des présences.

## 1. Infrastructure & Core
- [x] Initialisation du projet (pubspec, architecture)
- [x] Internationalisation (i18n) : fr, en
- [x] Système de thèmes dynamiques (Aura, Ethereal, Warm)
- [x] Base de données SQLite et Repositories
- [x] Gestion d'état avec Provider

## 2. Gestion des Groupes
- [x] Liste des groupes
- [x] Ajout et suppression de groupes
- [x] Détail d'un groupe (liste des membres)
- [x] Message groupé aux parents

## 3. Gestion des Jeunes (Adolescents)
- [x] Liste des jeunes avec recherche
- [x] Ajout/Modification d'un jeune (Nom, Prénom, Sexe, Groupe)
- [x] **Nouveau** : Gestion de la photo de profil (Appareil photo / Galerie)
- [x] **Nouveau** : Date de naissance et Adresse
- [x] Gestion multi-parents (jusqu'à 2 parents avec relation)
- [x] Profil détaillé (Stats, Parents, Historique complet)

## 4. Système d'Appel
- [x] Création de séances par groupe
- [x] Interface d'appel ergonomique (P, A, R, E)
- [x] Enregistrement et mise à jour des présences
- [x] Historique chronologique par jeune
- [x] Détail d'une séance passée (Résumé et participants)
- [x] Suppression d'une séance

## 5. Statistiques & Analyse
- [x] Tableau de bord global dynamique
- [x] Répartition globale par statut (Graphiques simplifiés)
- [x] Classements d'assiduité (Top 5 assidus / absents)
- [x] Alertes d'inactivité sur le Dashboard

## 6. Expérience Utilisateur (UX/UI)
- [x] Écran de Splash
- [x] Onboarding interactif
- [x] Navigation par onglets (Material 3)
- [x] Paramètres (Langue & Thème)
- [x] Export des données (CSV / Partage)
- [x] **Design** : Implémentation du Glassmorphism (Thème Ethereal)
- [x] **Design** : Typographies spécifiques (Playfair, Manrope, Plus Jakarta, Inter)

## 7. Communication
- [x] Message de groupe (Copie des numéros des parents)
- [x] Contact individuel rapide (WhatsApp/Appel)

## 8. Tests
- [x] Tests unitaires des modèles
- [ ] Tests d'intégration UI de base (Widget testing)
