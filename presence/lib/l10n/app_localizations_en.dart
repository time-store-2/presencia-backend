// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Presencia';

  @override
  String get dashboard => 'Home';

  @override
  String get youth => 'Members';

  @override
  String get attendance => 'Attendance';

  @override
  String get stats => 'Stats';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'App Theme';

  @override
  String get language => 'Language';

  @override
  String get warmCommunity => 'Warm Community';

  @override
  String get auraLuxury => 'Aura Luxury';

  @override
  String get etherealSerenity => 'Ethereal Serenity';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String get late => 'Late';

  @override
  String get excused => 'Excused';

  @override
  String get groups => 'Groups';

  @override
  String get addYouth => 'Add Member';

  @override
  String get noRecentSessions => 'No recent sessions';

  @override
  String get recentSessions => 'Recent Sessions';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get search => 'Search...';

  @override
  String get noYouthFound => 'No member found';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get group => 'Group';

  @override
  String get phone => 'Phone';

  @override
  String get parentTutor => 'Parent / Tutor';

  @override
  String get relation => 'Relation';

  @override
  String get save => 'Save';

  @override
  String get newSession => 'New Session';

  @override
  String get start => 'Start';

  @override
  String get takeAttendance => 'Take Attendance';

  @override
  String get saveAttendance => 'Save Attendance';

  @override
  String get attendanceSaved => 'Attendance saved';

  @override
  String get deleteProfile => 'Delete Profile?';

  @override
  String confirmDeleteYouth(Object name) {
    return 'Do you really want to delete $name\'s profile? This action is irreversible.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get noParentInfo => 'No parent information';

  @override
  String get history => 'History';

  @override
  String get noHistory => 'No history available';

  @override
  String bornOn(Object date) {
    return 'Born on $date';
  }

  @override
  String get noSessions => 'No sessions recorded';

  @override
  String get editAttendance => 'Edit Attendance';

  @override
  String get addNote => 'Add a note...';

  @override
  String get add => 'Add';

  @override
  String get deleteSessionQuestion => 'Delete session?';

  @override
  String confirmDeleteSession(Object title) {
    return 'Do you really want to delete \'$title\'?';
  }

  @override
  String get sessionTitleLabel => 'Session number or title';

  @override
  String get sessionTitleHint => 'Ex: 0001, Session, Meeting...';

  @override
  String get chooseGroup => 'Choose a group';

  @override
  String get noPhone => 'No phone number';

  @override
  String noResultsFor(Object query) {
    return 'No results for \"$query\"';
  }

  @override
  String get inactivityAlerts => 'Inactivity Alerts';

  @override
  String get viewAll => 'View all';

  @override
  String absences(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count absences',
      one: '1 absence',
      zero: 'no absence',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Today';

  @override
  String get members => 'Members';

  @override
  String get toRelanch => 'To follow up';

  @override
  String get rate => 'Rate';

  @override
  String get presenceRate => 'Presence';

  @override
  String get hello => 'Hello,';

  @override
  String get noGroups => 'No groups created';

  @override
  String get newGroup => 'New Group';

  @override
  String get groupName => 'Group Name';

  @override
  String get groupNameHint => 'Ex: Group A';

  @override
  String get description => 'Description';

  @override
  String get deleteGroupQuestion => 'Delete Group?';

  @override
  String confirmDeleteGroup(Object name) {
    return 'Do you really want to delete the group \'$name\'? This action is definitive.';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get firstNameHint => 'Member\'s first name';

  @override
  String get firstNameRequired => 'Please enter a first name';

  @override
  String get lastNameHint => 'Member\'s last name';

  @override
  String get lastNameRequired => 'Please enter a last name';

  @override
  String get phoneHint => 'Phone number';

  @override
  String get address => 'Address';

  @override
  String get addressHint => 'Where does he/she live?';

  @override
  String get parentFirstName => 'Parent\'s first name';

  @override
  String get parentFirstNameHint => 'Ex: John';

  @override
  String get parentLastName => 'Parent\'s last name';

  @override
  String get parentLastNameHint => 'Ex: Doe';

  @override
  String get parentPhone => 'Parent\'s phone';

  @override
  String get parentPhoneHint => 'Number to contact';

  @override
  String get whatsappHint => 'For group messages';

  @override
  String get father => 'Father';

  @override
  String get mother => 'Mother';

  @override
  String get tutor => 'Tutor';

  @override
  String get other => 'Other';

  @override
  String get addSecondParent => 'Add a second parent';

  @override
  String get secondParent => 'Second Parent';

  @override
  String get assignGroups => 'Assign to groups';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get phonePrefix => 'Prefix';

  @override
  String get participantsList => 'Participants List';

  @override
  String get periodReport => 'Period Report';

  @override
  String get noYouthInGroup => 'No member in this group';

  @override
  String get presentShort => 'P';

  @override
  String get lateShort => 'L';

  @override
  String get absentShort => 'A';

  @override
  String get excusedShort => 'E';

  @override
  String get total => 'Total';

  @override
  String get data => 'Data';

  @override
  String get exportAttendanceCsv => 'Export attendance (CSV)';

  @override
  String get exportAttendanceSubtitle =>
      'Generate a CSV file with all statistics.';

  @override
  String get exportSuccess => 'Export successful';

  @override
  String exportError(Object error) {
    return 'Error during export: $error';
  }

  @override
  String get aboutApp => 'About Presencia';

  @override
  String get appVersion => 'Version 1.0.0 (MVP)';

  @override
  String get appDescription =>
      'Attendance management app for organizations and their groups.';

  @override
  String get all => 'All';

  @override
  String get close => 'Close';

  @override
  String get copy => 'Copy';

  @override
  String get next => 'Next';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinPresencia => 'Join Presencia';

  @override
  String get welcomeToPresencia => 'Welcome to Presencia';

  @override
  String get signInToSync => 'Sign in to access your space';

  @override
  String get noAccountSignUp => 'Don\'t have an account? Sign Up';

  @override
  String get accountCreatedByAdmin =>
      'No account yet? Ask your administrator to create one for you.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get signupFailed => 'Signup failed';

  @override
  String get googleSignInFailed => 'Google Sign-in failed';

  @override
  String get todayHeroLabel => 'TODAY';

  @override
  String get defaultEventTitle => 'Today\'s session';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Presencia';

  @override
  String get onboardingWelcomeDescription =>
      'The simple tool to track attendance for your organization\'s members.';

  @override
  String get onboardingAttendanceTitle => 'Track attendance';

  @override
  String get onboardingAttendanceDescription =>
      'Quickly see who is present, absent or late.';

  @override
  String get onboardingContactTitle => 'Stay in touch';

  @override
  String get onboardingContactDescription =>
      'Access parent contacts in one tap to keep them informed.';

  @override
  String get groupMessage => 'Group message';

  @override
  String parentNumbersFound(Object count) {
    return '$count parent contacts found. Do you want to copy all the numbers?';
  }

  @override
  String get numbersCopied => 'Numbers copied to clipboard';

  @override
  String get noParentNumbersFound =>
      'No parent phone numbers found for this group.';

  @override
  String get manageMembers => 'Manage members';

  @override
  String get contactParents => 'Contact parents';

  @override
  String get groupMembers => 'Group members';

  @override
  String memberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
      zero: '0 members',
    );
    return '$_temp0';
  }

  @override
  String get noPhoneNumber => 'No phone number';

  @override
  String allWithCount(Object count) {
    return 'All ($count)';
  }

  @override
  String get noAbsent => 'No absences';

  @override
  String get emptyList => 'Empty list';

  @override
  String get attendanceBreakdown => 'Attendance breakdown';

  @override
  String get topMostAttentive => 'Top 5 most attentive';

  @override
  String get topMostAbsent => 'Top 5 most absent';

  @override
  String get sessions => 'Sessions';

  @override
  String get notEnoughData => 'Not enough data';

  @override
  String timesCount(Object count) {
    return '$count times';
  }

  @override
  String get splashTagline => 'Attendance manager';

  @override
  String groupNameExists(Object name) {
    return 'A group named \"$name\" already exists. Please choose another name.';
  }

  @override
  String youthNameExists(Object name) {
    return 'A member named \"$name\" already exists. Please choose another name.';
  }

  @override
  String sessionTitleExists(Object title) {
    return 'A session titled \"$title\" already exists. Please choose another title.';
  }

  @override
  String get copyInviteLink => 'Copy registration link';

  @override
  String get shareInviteLink => 'Share registration link';

  @override
  String get inviteLinkCopied => 'Registration link copied';

  @override
  String get noInviteLink => 'No link available for this group';

  @override
  String get editMemberGroups => 'Edit member groups';

  @override
  String get sendViaWhatsApp => 'Send via WhatsApp';

  @override
  String get chooseRecipient => 'Send the message to:';
}
