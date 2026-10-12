// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Presencia';

  @override
  String get dashboard => 'Home';

  @override
  String get members => 'Membres';

  @override
  String get attendance => 'Appel';

  @override
  String get stats => 'Statistiques';

  @override
  String get settings => 'Paramètres';

  @override
  String get theme => 'Thème de l\'application';

  @override
  String get language => 'Langue';

  @override
  String get warmCommunity => 'Warm Community (Chaud & Communal)';

  @override
  String get auraLuxury => 'Aura Luxury (Minimaliste & Luxe)';

  @override
  String get etherealSerenity => 'Ethereal Serenity (Glassmorphism & Calme)';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get present => 'Présent';

  @override
  String get absent => 'Absent';

  @override
  String get late => 'En retard';

  @override
  String get excused => 'Excusé';

  @override
  String get groups => 'Groupes';

  @override
  String get addMember => 'Ajouter un membre';

  @override
  String get noRecentSessions => 'Aucune séance récente';

  @override
  String get recentSessions => 'Dernières séances';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get search => 'Rechercher...';

  @override
  String get noMemberFound => 'Aucun membre trouvé';

  @override
  String get personalInfo => 'Informations personnelles';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get gender => 'Sexe';

  @override
  String get male => 'Masculin';

  @override
  String get female => 'Féminin';

  @override
  String get group => 'Groupe';

  @override
  String get phone => 'Téléphone';

  @override
  String get parentTutor => 'Parent / Tuteur';

  @override
  String get relation => 'Relation';

  @override
  String get save => 'Enregistrer';

  @override
  String get newSession => 'Nouvelle séance';

  @override
  String get start => 'Commencer';

  @override
  String get takeAttendance => 'Faire l\'appel';

  @override
  String get saveAttendance => 'Enregistrer l\'appel';

  @override
  String get attendanceSaved => 'Appel enregistré';

  @override
  String get deleteProfile => 'Supprimer le profil ?';

  @override
  String confirmDeleteMember(Object name) {
    return 'Voulez-vous vraiment supprimer le profil de $name ? Cette action est irréversible.';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get noParentInfo => 'Aucun parent renseigné';

  @override
  String get history => 'Historique';

  @override
  String get noHistory => 'Aucun historique disponible';

  @override
  String bornOn(Object date) {
    return 'Né(e) le $date';
  }

  @override
  String get noSessions => 'Aucune séance enregistrée';

  @override
  String get editAttendance => 'Modifier l\'appel';

  @override
  String get addNote => 'Ajouter une note...';

  @override
  String get add => 'Ajouter';

  @override
  String get deleteSessionQuestion => 'Supprimer la séance ?';

  @override
  String confirmDeleteSession(Object title) {
    return 'Voulez-vous vraiment supprimer \'$title\' ?';
  }

  @override
  String get sessionTitleLabel => 'Numéro ou titre de la séance';

  @override
  String get sessionTitleHint => 'Ex: 0001, Séance, Réunion...';

  @override
  String get chooseGroup => 'Choisir un groupe';

  @override
  String get noPhone => 'Pas de numéro';

  @override
  String noResultsFor(Object query) {
    return 'Aucun résultat pour \"$query\"';
  }

  @override
  String get inactivityAlerts => 'Alertes d\'inactivité';

  @override
  String get viewAll => 'Voir tout';

  @override
  String absences(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count absences',
      one: '1 absence',
      zero: 'aucune absence',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get toRelanch => 'À relancer';

  @override
  String get rate => 'Taux';

  @override
  String get presenceRate => 'Présence';

  @override
  String get hello => 'Bonjour,';

  @override
  String get noGroups => 'Aucun groupe créé';

  @override
  String get newGroup => 'Nouveau Groupe';

  @override
  String get groupName => 'Nom du groupe';

  @override
  String get groupNameHint => 'Ex: Groupe A';

  @override
  String get description => 'Description';

  @override
  String get deleteGroupQuestion => 'Supprimer le groupe ?';

  @override
  String confirmDeleteGroup(Object name) {
    return 'Voulez-vous vraiment supprimer le groupe \'$name\' ? Cette action est définitive.';
  }

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get profilePhoto => 'Photo de profil';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get firstNameHint => 'Prénom du membre';

  @override
  String get firstNameRequired => 'Veuillez entrer un prénom';

  @override
  String get lastNameHint => 'Nom du membre';

  @override
  String get lastNameRequired => 'Veuillez entrer un nom';

  @override
  String get phoneHint => 'Numéro de téléphone';

  @override
  String get address => 'Adresse';

  @override
  String get addressHint => 'Où habite-t-il ?';

  @override
  String get parentFirstName => 'Prénom du parent';

  @override
  String get parentFirstNameHint => 'Ex: Jean';

  @override
  String get parentLastName => 'Nom du parent';

  @override
  String get parentLastNameHint => 'Ex: Kouassi';

  @override
  String get parentPhone => 'Téléphone du parent';

  @override
  String get parentPhoneHint => 'Numéro à contacter';

  @override
  String get whatsappHint => 'Pour les messages de groupe';

  @override
  String get father => 'Père';

  @override
  String get mother => 'Mère';

  @override
  String get tutor => 'Tuteur';

  @override
  String get other => 'Autre';

  @override
  String get addSecondParent => 'Ajouter un second parent';

  @override
  String get secondParent => 'Second Parent';

  @override
  String get assignGroups => 'Assigner à des groupes';

  @override
  String get birthDate => 'Date de naissance';

  @override
  String get phonePrefix => 'Indicatif';

  @override
  String get participantsList => 'Liste des participants';

  @override
  String get periodReport => 'Bilan par période';

  @override
  String get noMemberInGroup => 'Aucun membre dans ce groupe';

  @override
  String get presentShort => 'P';

  @override
  String get lateShort => 'R';

  @override
  String get absentShort => 'A';

  @override
  String get excusedShort => 'E';

  @override
  String get total => 'Total';

  @override
  String get data => 'Données';

  @override
  String get exportAttendanceCsv => 'Exporter les présences (CSV)';

  @override
  String get exportAttendanceSubtitle =>
      'Générer un fichier CSV avec toutes les statistiques.';

  @override
  String get exportSuccess => 'Exportation réussie';

  @override
  String exportError(Object error) {
    return 'Erreur lors de l\'exportation : $error';
  }

  @override
  String get aboutApp => 'À propos de Presencia';

  @override
  String get appVersion => 'Version 1.0.0 (MVP)';

  @override
  String get appDescription =>
      'Application de gestion des présences pour les organisations et leurs groupes.';

  @override
  String get all => 'Tous';

  @override
  String get close => 'Fermer';

  @override
  String get copy => 'Copier';

  @override
  String get next => 'Suivant';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get joinPresencia => 'Rejoignez Presencia';

  @override
  String get welcomeToPresencia => 'Bienvenue sur Presencia';

  @override
  String get signInToSync => 'Connectez-vous pour accéder à votre espace';

  @override
  String get noAccountSignUp => 'Pas de compte ? Inscrivez-vous';

  @override
  String get accountCreatedByAdmin =>
      'Pas encore de compte ? Demandez à votre administrateur de vous en créer un.';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get signupFailed => 'Échec de l\'inscription';

  @override
  String get googleSignInFailed => 'Échec de la connexion avec Google';

  @override
  String get todayHeroLabel => 'AUJOURD\'HUI';

  @override
  String get defaultEventTitle => 'Séance du jour';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur Presencia';

  @override
  String get onboardingWelcomeDescription =>
      'L\'outil simple pour gérer les présences des membres de votre organisation.';

  @override
  String get onboardingAttendanceTitle => 'Suivez l\'assiduité';

  @override
  String get onboardingAttendanceDescription =>
      'Visualisez rapidement qui est présent, absent ou en retard.';

  @override
  String get onboardingContactTitle => 'Restez en contact';

  @override
  String get onboardingContactDescription =>
      'Accédez aux coordonnées des parents en un clic pour les informer.';

  @override
  String get groupMessage => 'Message au groupe';

  @override
  String parentNumbersFound(Object count) {
    return 'Il y a $count contacts parents identifiés. Souhaitez-vous copier tous les numéros ?';
  }

  @override
  String get numbersCopied => 'Numéros copiés dans le presse-papier';

  @override
  String get noParentNumbersFound =>
      'Aucun numéro de parent trouvé pour ce groupe.';

  @override
  String get manageMembers => 'Gérer les membres';

  @override
  String get contactParents => 'Contacter les parents';

  @override
  String get groupMembers => 'Membres du groupe';

  @override
  String memberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
      zero: '0 membre',
    );
    return '$_temp0';
  }

  @override
  String get noPhoneNumber => 'Pas de téléphone';

  @override
  String allWithCount(Object count) {
    return 'Tous ($count)';
  }

  @override
  String get noAbsent => 'Aucun absent';

  @override
  String get emptyList => 'Liste vide';

  @override
  String get attendanceBreakdown => 'Répartition des présences';

  @override
  String get topMostAttentive => 'Top 5 les plus assidus';

  @override
  String get topMostAbsent => 'Top 5 les plus absents';

  @override
  String get sessions => 'Séances';

  @override
  String get notEnoughData => 'Pas assez de données';

  @override
  String timesCount(Object count) {
    return '$count fois';
  }

  @override
  String get splashTagline => 'Gestionnaire de présences';

  @override
  String groupNameExists(Object name) {
    return 'Un groupe nommé « $name » existe déjà. Veuillez choisir un autre nom.';
  }

  @override
  String memberNameExists(Object name) {
    return 'Un membre nommé « $name » existe déjà. Veuillez choisir un autre nom.';
  }

  @override
  String sessionTitleExists(Object title) {
    return 'Une séance « $title » existe déjà. Veuillez choisir un autre titre.';
  }

  @override
  String get copyInviteLink => 'Copier le lien d\'inscription';

  @override
  String get shareInviteLink => 'Partager le lien d\'inscription';

  @override
  String get inviteLinkCopied => 'Lien d\'inscription copié';

  @override
  String get noInviteLink => 'Lien indisponible pour ce groupe';

  @override
  String get editMemberGroups => 'Modifier les groupes du membre';

  @override
  String get sendViaWhatsApp => 'Envoyer sur WhatsApp';

  @override
  String get chooseRecipient => 'Envoyer le message à :';
}
