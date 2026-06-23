import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Winnie\'s Cat Diary'**
  String get appTitle;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addCat.
  ///
  /// In en, this message translates to:
  /// **'Add Cat'**
  String get addCat;

  /// No description provided for @noCatsYet.
  ///
  /// In en, this message translates to:
  /// **'No cats yet'**
  String get noCatsYet;

  /// No description provided for @noCatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start building your cat album.'**
  String get noCatsSubtitle;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @place.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get place;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeen;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @fedToday.
  ///
  /// In en, this message translates to:
  /// **'Fed today'**
  String get fedToday;

  /// No description provided for @pickPhoto.
  ///
  /// In en, this message translates to:
  /// **'Pick Photo'**
  String get pickPhoto;

  /// No description provided for @catDetails.
  ///
  /// In en, this message translates to:
  /// **'Cat Details'**
  String get catDetails;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @placeRequired.
  ///
  /// In en, this message translates to:
  /// **'Place is required'**
  String get placeRequired;

  /// No description provided for @addedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cat added successfully'**
  String get addedSuccessfully;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @markSeenToday.
  ///
  /// In en, this message translates to:
  /// **'Mark seen today'**
  String get markSeenToday;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data'**
  String get privacyTitle;

  /// No description provided for @privacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your cat album is saved locally on this device. Winnie\'s Cat Diary does not require an account or GPS location.'**
  String get privacyDescription;

  /// No description provided for @photoPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Photos stay on your device unless you choose to share them.'**
  String get photoPrivacy;

  /// No description provided for @manualPlacePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Places are typed manually. The app does not request location permission.'**
  String get manualPlacePrivacy;

  /// No description provided for @sharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get sharingTitle;

  /// No description provided for @sharingDescription.
  ///
  /// In en, this message translates to:
  /// **'The share button opens the iOS share sheet. Apps such as WhatsApp or Instagram may appear if they are installed and support the shared content.'**
  String get sharingDescription;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Winnie\'s Cat Diary'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a personal album for cats you meet, add notes, update the last seen date, and feed them virtually.'**
  String get aboutDescription;

  /// No description provided for @futurePixelTitle.
  ///
  /// In en, this message translates to:
  /// **'Future Pixel Charms'**
  String get futurePixelTitle;

  /// No description provided for @futurePixelDescription.
  ///
  /// In en, this message translates to:
  /// **'Real cat photo to pixel art conversion will be added later as an optional paid feature.'**
  String get futurePixelDescription;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteCat.
  ///
  /// In en, this message translates to:
  /// **'Delete Cat'**
  String get deleteCat;

  /// No description provided for @deleteCatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this cat from your album?'**
  String get deleteCatConfirm;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cat deleted successfully'**
  String get deletedSuccessfully;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used in the app.'**
  String get chooseLanguage;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current language'**
  String get currentLanguage;

  /// No description provided for @photoSource.
  ///
  /// In en, this message translates to:
  /// **'Photo Source'**
  String get photoSource;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera could not be opened'**
  String get cameraError;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
