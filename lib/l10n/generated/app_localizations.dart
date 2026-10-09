import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Salah'**
  String get appTitle;

  /// No description provided for @hijriDate.
  ///
  /// In en, this message translates to:
  /// **'Hijri date'**
  String get hijriDate;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get navPrayer;

  /// No description provided for @navQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get navQuran;

  /// No description provided for @navQibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get navQibla;

  /// No description provided for @quranTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quranTitle;

  /// No description provided for @quranComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Your Quran reading space is being prepared.'**
  String get quranComingSoon;

  /// No description provided for @quranLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading Quran content'**
  String get quranLoading;

  /// No description provided for @quranLoadError.
  ///
  /// In en, this message translates to:
  /// **'Quran content could not be loaded. Check your connection and try again.'**
  String get quranLoadError;

  /// No description provided for @quranLibraryHeading.
  ///
  /// In en, this message translates to:
  /// **'Read the Quran'**
  String get quranLibraryHeading;

  /// No description provided for @quranLibraryDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse the surahs and open a chapter to read its Arabic text.'**
  String get quranLibraryDescription;

  /// No description provided for @quranSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search surah name or number'**
  String get quranSearchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @quranSurahCount.
  ///
  /// In en, this message translates to:
  /// **'{count} surahs'**
  String quranSurahCount(int count);

  /// No description provided for @quranNoResults.
  ///
  /// In en, this message translates to:
  /// **'No surahs match your search.'**
  String get quranNoResults;

  /// No description provided for @quranAyahs.
  ///
  /// In en, this message translates to:
  /// **'ayahs'**
  String get quranAyahs;

  /// No description provided for @quranReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran reading'**
  String get quranReadingTitle;

  /// No description provided for @quranPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get quranPage;

  /// No description provided for @quranBySurah.
  ///
  /// In en, this message translates to:
  /// **'Quran by Surah'**
  String get quranBySurah;

  /// No description provided for @quranByJuz.
  ///
  /// In en, this message translates to:
  /// **'Quran by Juz'**
  String get quranByJuz;

  /// No description provided for @quranFull.
  ///
  /// In en, this message translates to:
  /// **'Full Quran'**
  String get quranFull;

  /// No description provided for @quranJuzNumber.
  ///
  /// In en, this message translates to:
  /// **'Juz {number}'**
  String quranJuzNumber(int number);

  /// No description provided for @quranPageCount.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String quranPageCount(int page, int total);

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// No description provided for @qiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qiblaTitle;

  /// No description provided for @qiblaComingSoon.
  ///
  /// In en, this message translates to:
  /// **'The Qibla compass will be available in a later phase.'**
  String get qiblaComingSoon;

  /// No description provided for @qiblaLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a location to calculate the direction to the Kaaba.'**
  String get qiblaLocationRequired;

  /// No description provided for @qiblaBearing.
  ///
  /// In en, this message translates to:
  /// **'Bearing from north'**
  String get qiblaBearing;

  /// No description provided for @kaabaDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance to Kaaba'**
  String get kaabaDistance;

  /// No description provided for @compassUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Compass signal unavailable. The arrow shows the bearing from north.'**
  String get compassUnavailable;

  /// No description provided for @compassNorth.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get compassNorth;

  /// No description provided for @compassEast.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get compassEast;

  /// No description provided for @compassSouth.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get compassSouth;

  /// No description provided for @compassWest.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get compassWest;

  /// No description provided for @compassAlignHint.
  ///
  /// In en, this message translates to:
  /// **'Turn your device until the arrow points to the top of the compass.'**
  String get compassAlignHint;

  /// No description provided for @compassSearching.
  ///
  /// In en, this message translates to:
  /// **'Looking for a compass signal…'**
  String get compassSearching;

  /// No description provided for @compassCalibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibrate your compass'**
  String get compassCalibrationTitle;

  /// No description provided for @compassCalibrationDescription.
  ///
  /// In en, this message translates to:
  /// **'Move your phone in a figure-eight a few times, then keep it away from magnets, metal objects, and electronic equipment. Nearby interference and local magnetic variation can affect compass readings.'**
  String get compassCalibrationDescription;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer alerts'**
  String get notificationSettingsTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPrayerSection.
  ///
  /// In en, this message translates to:
  /// **'Prayer and location'**
  String get settingsPrayerSection;

  /// No description provided for @prayerAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer notifications'**
  String get prayerAlertsTitle;

  /// No description provided for @notificationPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose which prayers can send an alert. Your device may ask for notification permission the first time you turn one on.'**
  String get notificationPermissionDescription;

  /// No description provided for @prayerTimeNotification.
  ///
  /// In en, this message translates to:
  /// **'Alert at prayer time'**
  String get prayerTimeNotification;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Design system preview'**
  String get homeTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Salah'**
  String get welcomeTitle;

  /// No description provided for @viewAllPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'All prayer times'**
  String get viewAllPrayerTimes;

  /// No description provided for @homeDescription.
  ///
  /// In en, this message translates to:
  /// **'A shared visual foundation for every Salah feature.'**
  String get homeDescription;

  /// No description provided for @navSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get navSystem;

  /// No description provided for @navStates.
  ///
  /// In en, this message translates to:
  /// **'States'**
  String get navStates;

  /// No description provided for @navAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get navAppearance;

  /// No description provided for @sectionTypography.
  ///
  /// In en, this message translates to:
  /// **'Typography'**
  String get sectionTypography;

  /// No description provided for @typeDisplay.
  ///
  /// In en, this message translates to:
  /// **'Clear guidance, every day'**
  String get typeDisplay;

  /// No description provided for @typeHeadline.
  ///
  /// In en, this message translates to:
  /// **'A thoughtful reading experience'**
  String get typeHeadline;

  /// No description provided for @typeBody.
  ///
  /// In en, this message translates to:
  /// **'Use a consistent type scale to keep content comfortable and easy to scan.'**
  String get typeBody;

  /// No description provided for @sectionButtons.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get sectionButtons;

  /// No description provided for @buttonPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary action'**
  String get buttonPrimary;

  /// No description provided for @buttonSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary action'**
  String get buttonSecondary;

  /// No description provided for @buttonText.
  ///
  /// In en, this message translates to:
  /// **'Text action'**
  String get buttonText;

  /// No description provided for @buttonPressed.
  ///
  /// In en, this message translates to:
  /// **'Button example selected'**
  String get buttonPressed;

  /// No description provided for @sectionCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get sectionCards;

  /// No description provided for @cardTitle.
  ///
  /// In en, this message translates to:
  /// **'A shared surface'**
  String get cardTitle;

  /// No description provided for @cardDescription.
  ///
  /// In en, this message translates to:
  /// **'Cards use the active color scheme, rounded shape, and shared spacing.'**
  String get cardDescription;

  /// No description provided for @sectionStates.
  ///
  /// In en, this message translates to:
  /// **'Shared states'**
  String get sectionStates;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading content'**
  String get loadingLabel;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get emptyTitle;

  /// No description provided for @emptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Saved items will appear here when they are available.'**
  String get emptyDescription;

  /// No description provided for @emptyAction.
  ///
  /// In en, this message translates to:
  /// **'Show example action'**
  String get emptyAction;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Content could not load'**
  String get errorTitle;

  /// No description provided for @errorDescription.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get errorDescription;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @retryPressed.
  ///
  /// In en, this message translates to:
  /// **'Retry example selected'**
  String get retryPressed;

  /// No description provided for @sectionColors.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get sectionColors;

  /// No description provided for @sectionThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get sectionThemeMode;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance settings'**
  String get appearanceTitle;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Choose an accent color'**
  String get accentColor;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Choose how the app looks'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @colorForest.
  ///
  /// In en, this message translates to:
  /// **'Forest green'**
  String get colorForest;

  /// No description provided for @colorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// No description provided for @colorIndigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get colorIndigo;

  /// No description provided for @colorAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get colorAmber;

  /// No description provided for @colorRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorRose;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get locationTitle;

  /// No description provided for @locationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a city for local prayer times.'**
  String get locationSubtitle;

  /// No description provided for @activeLocation.
  ///
  /// In en, this message translates to:
  /// **'Active location'**
  String get activeLocation;

  /// No description provided for @noActiveLocation.
  ///
  /// In en, this message translates to:
  /// **'No active location selected'**
  String get noActiveLocation;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @currentLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Use your device location while the app is open.'**
  String get currentLocationDescription;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @saveCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Save this location'**
  String get saveCurrentLocation;

  /// No description provided for @searchCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a city'**
  String get searchCityTitle;

  /// No description provided for @searchCityHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a city or address'**
  String get searchCityHint;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResults;

  /// No description provided for @savedLocations.
  ///
  /// In en, this message translates to:
  /// **'Saved locations'**
  String get savedLocations;

  /// No description provided for @noSavedLocations.
  ///
  /// In en, this message translates to:
  /// **'No saved locations yet'**
  String get noSavedLocations;

  /// No description provided for @noSavedLocationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Search for a city and save it to switch locations quickly.'**
  String get noSavedLocationsDescription;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save location'**
  String get saveLocation;

  /// No description provided for @removeLocation.
  ///
  /// In en, this message translates to:
  /// **'Remove location'**
  String get removeLocation;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Use this location'**
  String get selectLocation;

  /// No description provided for @privacyLocationNote.
  ///
  /// In en, this message translates to:
  /// **'Device GPS is accessed only while the app is open. The selected city and saved places are stored on this device.'**
  String get privacyLocationNote;

  /// No description provided for @alreadySaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get alreadySaved;

  /// No description provided for @unknownCity.
  ///
  /// In en, this message translates to:
  /// **'Unnamed place'**
  String get unknownCity;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. You can search for a city instead.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is turned off for Salah. Enable it in device settings, or search for a city.'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Device location services are turned off. Enable them in settings, or search for a city.'**
  String get locationServicesDisabled;

  /// No description provided for @currentLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not determine your current location. Try again or search for a city.'**
  String get currentLocationUnavailable;

  /// No description provided for @locationNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching city was found. Try a more specific search.'**
  String get locationNoResults;

  /// No description provided for @locationSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'City search is temporarily unavailable. Try again later.'**
  String get locationSearchFailed;

  /// No description provided for @locationStorageFailed.
  ///
  /// In en, this message translates to:
  /// **'Saved locations could not be read or updated on this device.'**
  String get locationStorageFailed;

  /// No description provided for @locationUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong with locations. Please try again.'**
  String get locationUnknownError;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @searchingCities.
  ///
  /// In en, this message translates to:
  /// **'Searching cities'**
  String get searchingCities;

  /// No description provided for @loadingLocations.
  ///
  /// In en, this message translates to:
  /// **'Loading saved locations'**
  String get loadingLocations;

  /// No description provided for @locationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Active location updated'**
  String get locationUpdated;

  /// No description provided for @locationSaved.
  ///
  /// In en, this message translates to:
  /// **'Location saved'**
  String get locationSaved;

  /// No description provided for @locationRemoved.
  ///
  /// In en, this message translates to:
  /// **'Location removed'**
  String get locationRemoved;

  /// No description provided for @prayerTimesTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get prayerTimesTitle;

  /// No description provided for @prayerTimesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A peaceful view of today’s prayer rhythm.'**
  String get prayerTimesSubtitle;

  /// No description provided for @prayerNoLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose a location to see accurate local prayer times.'**
  String get prayerNoLocation;

  /// No description provided for @openLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose location'**
  String get openLocation;

  /// No description provided for @prayerSettings.
  ///
  /// In en, this message translates to:
  /// **'Calculation settings'**
  String get prayerSettings;

  /// No description provided for @todaySchedule.
  ///
  /// In en, this message translates to:
  /// **'Today’s schedule'**
  String get todaySchedule;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @monthlySchedule.
  ///
  /// In en, this message translates to:
  /// **'Monthly timetable'**
  String get monthlySchedule;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get nextPrayer;

  /// No description provided for @currentPrayer.
  ///
  /// In en, this message translates to:
  /// **'Current prayer'**
  String get currentPrayer;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get timeRemaining;

  /// No description provided for @prayerStarted.
  ///
  /// In en, this message translates to:
  /// **'It’s time for'**
  String get prayerStarted;

  /// No description provided for @sunriseSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunlight'**
  String get sunriseSunset;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation method'**
  String get calculationMethod;

  /// No description provided for @madhab.
  ///
  /// In en, this message translates to:
  /// **'Asr calculation'**
  String get madhab;

  /// No description provided for @madhabStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get madhabStandard;

  /// No description provided for @madhabHanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get madhabHanafi;

  /// No description provided for @manualAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Minute adjustments'**
  String get manualAdjustments;

  /// No description provided for @timeFormat.
  ///
  /// In en, this message translates to:
  /// **'24-hour time'**
  String get timeFormat;

  /// No description provided for @highLatitudeNote.
  ///
  /// In en, this message translates to:
  /// **'High-latitude adjustment is selected automatically for this location.'**
  String get highLatitudeNote;

  /// No description provided for @prayerAccuracyNote.
  ///
  /// In en, this message translates to:
  /// **'AlAdhan timings are cached on this device. Follow your local mosque if its timetable differs.'**
  String get prayerAccuracyNote;

  /// No description provided for @prayerNoLocationError.
  ///
  /// In en, this message translates to:
  /// **'Select a location before viewing prayer times.'**
  String get prayerNoLocationError;

  /// No description provided for @prayerTimezoneError.
  ///
  /// In en, this message translates to:
  /// **'Could not determine this location’s time zone.'**
  String get prayerTimezoneError;

  /// No description provided for @prayerCalculationError.
  ///
  /// In en, this message translates to:
  /// **'Prayer times could not be calculated. Check your location and settings.'**
  String get prayerCalculationError;

  /// No description provided for @prayerStorageError.
  ///
  /// In en, this message translates to:
  /// **'Prayer preferences could not be saved on this device.'**
  String get prayerStorageError;

  /// No description provided for @adjustmentMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String adjustmentMinutes(int minutes);

  /// No description provided for @monthDayCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String monthDayCount(int count);

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @decreaseAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Decrease {prayer} adjustment'**
  String decreaseAdjustment(String prayer);

  /// No description provided for @increaseAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Increase {prayer} adjustment'**
  String increaseAdjustment(String prayer);

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get prayerSunset;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @methodMuslimWorldLeague.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get methodMuslimWorldLeague;

  /// No description provided for @methodEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian General Authority'**
  String get methodEgyptian;

  /// No description provided for @methodKarachi.
  ///
  /// In en, this message translates to:
  /// **'University of Islamic Sciences, Karachi'**
  String get methodKarachi;

  /// No description provided for @methodUmmAlQura.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura'**
  String get methodUmmAlQura;

  /// No description provided for @methodDubai.
  ///
  /// In en, this message translates to:
  /// **'Dubai'**
  String get methodDubai;

  /// No description provided for @methodQatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get methodQatar;

  /// No description provided for @methodKuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get methodKuwait;

  /// No description provided for @methodMoonsightingCommittee.
  ///
  /// In en, this message translates to:
  /// **'Moonsighting Committee'**
  String get methodMoonsightingCommittee;

  /// No description provided for @methodSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get methodSingapore;

  /// No description provided for @methodTurkiye.
  ///
  /// In en, this message translates to:
  /// **'Türkiye (Diyanet)'**
  String get methodTurkiye;

  /// No description provided for @methodTehran.
  ///
  /// In en, this message translates to:
  /// **'Tehran'**
  String get methodTehran;

  /// No description provided for @methodNorthAmerica.
  ///
  /// In en, this message translates to:
  /// **'North America (ISNA)'**
  String get methodNorthAmerica;

  /// No description provided for @methodMorocco.
  ///
  /// In en, this message translates to:
  /// **'Morocco'**
  String get methodMorocco;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
