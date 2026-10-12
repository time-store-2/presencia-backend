import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Presencia'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashboard;

  /// No description provided for @youth.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get youth;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @warmCommunity.
  ///
  /// In en, this message translates to:
  /// **'Warm Community'**
  String get warmCommunity;

  /// No description provided for @auraLuxury.
  ///
  /// In en, this message translates to:
  /// **'Aura Luxury'**
  String get auraLuxury;

  /// No description provided for @etherealSerenity.
  ///
  /// In en, this message translates to:
  /// **'Ethereal Serenity'**
  String get etherealSerenity;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @excused.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get excused;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @addYouth.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addYouth;

  /// No description provided for @noRecentSessions.
  ///
  /// In en, this message translates to:
  /// **'No recent sessions'**
  String get noRecentSessions;

  /// No description provided for @recentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent Sessions'**
  String get recentSessions;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @noYouthFound.
  ///
  /// In en, this message translates to:
  /// **'No member found'**
  String get noYouthFound;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @parentTutor.
  ///
  /// In en, this message translates to:
  /// **'Parent / Tutor'**
  String get parentTutor;

  /// No description provided for @relation.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get relation;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @newSession.
  ///
  /// In en, this message translates to:
  /// **'New Session'**
  String get newSession;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @takeAttendance.
  ///
  /// In en, this message translates to:
  /// **'Take Attendance'**
  String get takeAttendance;

  /// No description provided for @saveAttendance.
  ///
  /// In en, this message translates to:
  /// **'Save Attendance'**
  String get saveAttendance;

  /// No description provided for @attendanceSaved.
  ///
  /// In en, this message translates to:
  /// **'Attendance saved'**
  String get attendanceSaved;

  /// No description provided for @deleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile?'**
  String get deleteProfile;

  /// No description provided for @confirmDeleteYouth.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete {name}\'s profile? This action is irreversible.'**
  String confirmDeleteYouth(Object name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noParentInfo.
  ///
  /// In en, this message translates to:
  /// **'No parent information'**
  String get noParentInfo;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history available'**
  String get noHistory;

  /// No description provided for @bornOn.
  ///
  /// In en, this message translates to:
  /// **'Born on {date}'**
  String bornOn(Object date);

  /// No description provided for @noSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions recorded'**
  String get noSessions;

  /// No description provided for @editAttendance.
  ///
  /// In en, this message translates to:
  /// **'Edit Attendance'**
  String get editAttendance;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note...'**
  String get addNote;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @deleteSessionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete session?'**
  String get deleteSessionQuestion;

  /// No description provided for @confirmDeleteSession.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete \'{title}\'?'**
  String confirmDeleteSession(Object title);

  /// No description provided for @sessionTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Session number or title'**
  String get sessionTitleLabel;

  /// No description provided for @sessionTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: 0001, Session, Meeting...'**
  String get sessionTitleHint;

  /// No description provided for @chooseGroup.
  ///
  /// In en, this message translates to:
  /// **'Choose a group'**
  String get chooseGroup;

  /// No description provided for @noPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone number'**
  String get noPhone;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(Object query);

  /// No description provided for @inactivityAlerts.
  ///
  /// In en, this message translates to:
  /// **'Inactivity Alerts'**
  String get inactivityAlerts;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @absences.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no absence} =1{1 absence} other{{count} absences}}'**
  String absences(num count);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @toRelanch.
  ///
  /// In en, this message translates to:
  /// **'To follow up'**
  String get toRelanch;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @presenceRate.
  ///
  /// In en, this message translates to:
  /// **'Presence'**
  String get presenceRate;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get hello;

  /// No description provided for @noGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups created'**
  String get noGroups;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get newGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Group A'**
  String get groupNameHint;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @deleteGroupQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Group?'**
  String get deleteGroupQuestion;

  /// No description provided for @confirmDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete the group \'{name}\'? This action is definitive.'**
  String confirmDeleteGroup(Object name);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Member\'s first name'**
  String get firstNameHint;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a first name'**
  String get firstNameRequired;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Member\'s last name'**
  String get lastNameHint;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a last name'**
  String get lastNameRequired;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneHint;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Where does he/she live?'**
  String get addressHint;

  /// No description provided for @parentFirstName.
  ///
  /// In en, this message translates to:
  /// **'Parent\'s first name'**
  String get parentFirstName;

  /// No description provided for @parentFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: John'**
  String get parentFirstNameHint;

  /// No description provided for @parentLastName.
  ///
  /// In en, this message translates to:
  /// **'Parent\'s last name'**
  String get parentLastName;

  /// No description provided for @parentLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Doe'**
  String get parentLastNameHint;

  /// No description provided for @parentPhone.
  ///
  /// In en, this message translates to:
  /// **'Parent\'s phone'**
  String get parentPhone;

  /// No description provided for @parentPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Number to contact'**
  String get parentPhoneHint;

  /// No description provided for @whatsappHint.
  ///
  /// In en, this message translates to:
  /// **'For group messages'**
  String get whatsappHint;

  /// No description provided for @father.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get father;

  /// No description provided for @mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get mother;

  /// No description provided for @tutor.
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get tutor;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @addSecondParent.
  ///
  /// In en, this message translates to:
  /// **'Add a second parent'**
  String get addSecondParent;

  /// No description provided for @secondParent.
  ///
  /// In en, this message translates to:
  /// **'Second Parent'**
  String get secondParent;

  /// No description provided for @assignGroups.
  ///
  /// In en, this message translates to:
  /// **'Assign to groups'**
  String get assignGroups;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @phonePrefix.
  ///
  /// In en, this message translates to:
  /// **'Prefix'**
  String get phonePrefix;

  /// No description provided for @participantsList.
  ///
  /// In en, this message translates to:
  /// **'Participants List'**
  String get participantsList;

  /// No description provided for @periodReport.
  ///
  /// In en, this message translates to:
  /// **'Period Report'**
  String get periodReport;

  /// No description provided for @noYouthInGroup.
  ///
  /// In en, this message translates to:
  /// **'No member in this group'**
  String get noYouthInGroup;

  /// No description provided for @presentShort.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get presentShort;

  /// No description provided for @lateShort.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get lateShort;

  /// No description provided for @absentShort.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get absentShort;

  /// No description provided for @excusedShort.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get excusedShort;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @exportAttendanceCsv.
  ///
  /// In en, this message translates to:
  /// **'Export attendance (CSV)'**
  String get exportAttendanceCsv;

  /// No description provided for @exportAttendanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a CSV file with all statistics.'**
  String get exportAttendanceSubtitle;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get exportSuccess;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Error during export: {error}'**
  String exportError(Object error);

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Presencia'**
  String get aboutApp;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 (MVP)'**
  String get appVersion;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Attendance management app for organizations and their groups.'**
  String get appDescription;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinPresencia.
  ///
  /// In en, this message translates to:
  /// **'Join Presencia'**
  String get joinPresencia;

  /// No description provided for @welcomeToPresencia.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Presencia'**
  String get welcomeToPresencia;

  /// No description provided for @signInToSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your space'**
  String get signInToSync;

  /// No description provided for @noAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get noAccountSignUp;

  /// No description provided for @accountCreatedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'No account yet? Ask your administrator to create one for you.'**
  String get accountCreatedByAdmin;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Signup failed'**
  String get signupFailed;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-in failed'**
  String get googleSignInFailed;

  /// No description provided for @todayHeroLabel.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayHeroLabel;

  /// No description provided for @defaultEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s session'**
  String get defaultEventTitle;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Presencia'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'The simple tool to track attendance for your organization\'s members.'**
  String get onboardingWelcomeDescription;

  /// No description provided for @onboardingAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Track attendance'**
  String get onboardingAttendanceTitle;

  /// No description provided for @onboardingAttendanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Quickly see who is present, absent or late.'**
  String get onboardingAttendanceDescription;

  /// No description provided for @onboardingContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay in touch'**
  String get onboardingContactTitle;

  /// No description provided for @onboardingContactDescription.
  ///
  /// In en, this message translates to:
  /// **'Access parent contacts in one tap to keep them informed.'**
  String get onboardingContactDescription;

  /// No description provided for @groupMessage.
  ///
  /// In en, this message translates to:
  /// **'Group message'**
  String get groupMessage;

  /// No description provided for @parentNumbersFound.
  ///
  /// In en, this message translates to:
  /// **'{count} parent contacts found. Do you want to copy all the numbers?'**
  String parentNumbersFound(Object count);

  /// No description provided for @numbersCopied.
  ///
  /// In en, this message translates to:
  /// **'Numbers copied to clipboard'**
  String get numbersCopied;

  /// No description provided for @noParentNumbersFound.
  ///
  /// In en, this message translates to:
  /// **'No parent phone numbers found for this group.'**
  String get noParentNumbersFound;

  /// No description provided for @manageMembers.
  ///
  /// In en, this message translates to:
  /// **'Manage members'**
  String get manageMembers;

  /// No description provided for @contactParents.
  ///
  /// In en, this message translates to:
  /// **'Contact parents'**
  String get contactParents;

  /// No description provided for @groupMembers.
  ///
  /// In en, this message translates to:
  /// **'Group members'**
  String get groupMembers;

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 members} =1{1 member} other{{count} members}}'**
  String memberCount(num count);

  /// No description provided for @noPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'No phone number'**
  String get noPhoneNumber;

  /// No description provided for @allWithCount.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String allWithCount(Object count);

  /// No description provided for @noAbsent.
  ///
  /// In en, this message translates to:
  /// **'No absences'**
  String get noAbsent;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'Empty list'**
  String get emptyList;

  /// No description provided for @attendanceBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Attendance breakdown'**
  String get attendanceBreakdown;

  /// No description provided for @topMostAttentive.
  ///
  /// In en, this message translates to:
  /// **'Top 5 most attentive'**
  String get topMostAttentive;

  /// No description provided for @topMostAbsent.
  ///
  /// In en, this message translates to:
  /// **'Top 5 most absent'**
  String get topMostAbsent;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @notEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get notEnoughData;

  /// No description provided for @timesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String timesCount(Object count);

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Attendance manager'**
  String get splashTagline;

  /// No description provided for @groupNameExists.
  ///
  /// In en, this message translates to:
  /// **'A group named \"{name}\" already exists. Please choose another name.'**
  String groupNameExists(Object name);

  /// No description provided for @youthNameExists.
  ///
  /// In en, this message translates to:
  /// **'A member named \"{name}\" already exists. Please choose another name.'**
  String youthNameExists(Object name);

  /// No description provided for @sessionTitleExists.
  ///
  /// In en, this message translates to:
  /// **'A session titled \"{title}\" already exists. Please choose another title.'**
  String sessionTitleExists(Object title);

  /// No description provided for @copyInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Copy registration link'**
  String get copyInviteLink;

  /// No description provided for @shareInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Share registration link'**
  String get shareInviteLink;

  /// No description provided for @inviteLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Registration link copied'**
  String get inviteLinkCopied;

  /// No description provided for @noInviteLink.
  ///
  /// In en, this message translates to:
  /// **'No link available for this group'**
  String get noInviteLink;

  /// No description provided for @editMemberGroups.
  ///
  /// In en, this message translates to:
  /// **'Edit member groups'**
  String get editMemberGroups;

  /// No description provided for @sendViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Send via WhatsApp'**
  String get sendViaWhatsApp;

  /// No description provided for @chooseRecipient.
  ///
  /// In en, this message translates to:
  /// **'Send the message to:'**
  String get chooseRecipient;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
