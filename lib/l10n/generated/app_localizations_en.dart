// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Salah';

  @override
  String get hijriDate => 'Hijri date';

  @override
  String get navHome => 'Home';

  @override
  String get navPrayer => 'Prayer';

  @override
  String get navQuran => 'Quran';

  @override
  String get navQibla => 'Qibla';

  @override
  String get quranTitle => 'Quran';

  @override
  String get quranComingSoon => 'Your Quran reading space is being prepared.';

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String get qiblaComingSoon =>
      'The Qibla compass will be available in a later phase.';

  @override
  String get qiblaLocationRequired =>
      'Choose a location to calculate the direction to the Kaaba.';

  @override
  String get qiblaBearing => 'Bearing from north';

  @override
  String get kaabaDistance => 'Distance to Kaaba';

  @override
  String get compassUnavailable =>
      'Compass signal unavailable. The arrow shows the bearing from north.';

  @override
  String get compassNorth => 'N';

  @override
  String get compassEast => 'E';

  @override
  String get compassSouth => 'S';

  @override
  String get compassWest => 'W';

  @override
  String get compassAlignHint =>
      'Turn your device until the arrow points to the top of the compass.';

  @override
  String get compassSearching => 'Looking for a compass signal…';

  @override
  String get compassCalibrationTitle => 'Calibrate your compass';

  @override
  String get compassCalibrationDescription =>
      'Move your phone in a figure-eight a few times, then keep it away from magnets, metal objects, and electronic equipment. Nearby interference and local magnetic variation can affect compass readings.';

  @override
  String get notificationSettingsTitle => 'Prayer alerts';

  @override
  String get prayerAlertsTitle => 'Prayer notifications';

  @override
  String get notificationPermissionDescription =>
      'Choose which prayers can send an alert. Your device may ask for notification permission the first time you turn one on.';

  @override
  String get prayerTimeNotification => 'Alert at prayer time';

  @override
  String get homeTitle => 'Design system preview';

  @override
  String get welcomeTitle => 'Welcome to Salah';

  @override
  String get viewAllPrayerTimes => 'All prayer times';

  @override
  String get homeDescription =>
      'A shared visual foundation for every Salah feature.';

  @override
  String get navSystem => 'System';

  @override
  String get navStates => 'States';

  @override
  String get navAppearance => 'Appearance';

  @override
  String get sectionTypography => 'Typography';

  @override
  String get typeDisplay => 'Clear guidance, every day';

  @override
  String get typeHeadline => 'A thoughtful reading experience';

  @override
  String get typeBody =>
      'Use a consistent type scale to keep content comfortable and easy to scan.';

  @override
  String get sectionButtons => 'Buttons';

  @override
  String get buttonPrimary => 'Primary action';

  @override
  String get buttonSecondary => 'Secondary action';

  @override
  String get buttonText => 'Text action';

  @override
  String get buttonPressed => 'Button example selected';

  @override
  String get sectionCards => 'Cards';

  @override
  String get cardTitle => 'A shared surface';

  @override
  String get cardDescription =>
      'Cards use the active color scheme, rounded shape, and shared spacing.';

  @override
  String get sectionStates => 'Shared states';

  @override
  String get loadingLabel => 'Loading content';

  @override
  String get emptyTitle => 'Nothing saved yet';

  @override
  String get emptyDescription =>
      'Saved items will appear here when they are available.';

  @override
  String get emptyAction => 'Show example action';

  @override
  String get errorTitle => 'Content could not load';

  @override
  String get errorDescription => 'Check your connection and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get retryPressed => 'Retry example selected';

  @override
  String get sectionColors => 'Accent color';

  @override
  String get sectionThemeMode => 'Theme mode';

  @override
  String get appearanceTitle => 'Appearance settings';

  @override
  String get accentColor => 'Choose an accent color';

  @override
  String get themeMode => 'Choose how the app looks';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get close => 'Close';

  @override
  String get colorForest => 'Forest green';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorAmber => 'Amber';

  @override
  String get colorRose => 'Rose';

  @override
  String get locationTitle => 'Your location';

  @override
  String get locationSubtitle => 'Choose a city for local prayer times.';

  @override
  String get activeLocation => 'Active location';

  @override
  String get noActiveLocation => 'No active location selected';

  @override
  String get currentLocation => 'Current location';

  @override
  String get currentLocationDescription =>
      'Use your device location while the app is open.';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get saveCurrentLocation => 'Save this location';

  @override
  String get searchCityTitle => 'Find a city';

  @override
  String get searchCityHint => 'Search for a city or address';

  @override
  String get search => 'Search';

  @override
  String get searchResults => 'Search results';

  @override
  String get savedLocations => 'Saved locations';

  @override
  String get noSavedLocations => 'No saved locations yet';

  @override
  String get noSavedLocationsDescription =>
      'Search for a city and save it to switch locations quickly.';

  @override
  String get saveLocation => 'Save location';

  @override
  String get removeLocation => 'Remove location';

  @override
  String get activeLabel => 'Active';

  @override
  String get selectLocation => 'Use this location';

  @override
  String get privacyLocationNote =>
      'Device GPS is accessed only while the app is open. The selected city and saved places are stored on this device.';

  @override
  String get alreadySaved => 'Saved';

  @override
  String get unknownCity => 'Unnamed place';

  @override
  String get locationPermissionDenied =>
      'Location permission was denied. You can search for a city instead.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location permission is turned off for Salah. Enable it in device settings, or search for a city.';

  @override
  String get locationServicesDisabled =>
      'Device location services are turned off. Enable them in settings, or search for a city.';

  @override
  String get currentLocationUnavailable =>
      'Could not determine your current location. Try again or search for a city.';

  @override
  String get locationNoResults =>
      'No matching city was found. Try a more specific search.';

  @override
  String get locationSearchFailed =>
      'City search is temporarily unavailable. Try again later.';

  @override
  String get locationStorageFailed =>
      'Saved locations could not be read or updated on this device.';

  @override
  String get locationUnknownError =>
      'Something went wrong with locations. Please try again.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get searchingCities => 'Searching cities';

  @override
  String get loadingLocations => 'Loading saved locations';

  @override
  String get locationUpdated => 'Active location updated';

  @override
  String get locationSaved => 'Location saved';

  @override
  String get locationRemoved => 'Location removed';

  @override
  String get prayerTimesTitle => 'Prayer times';

  @override
  String get prayerTimesSubtitle => 'A peaceful view of today’s prayer rhythm.';

  @override
  String get prayerNoLocation =>
      'Choose a location to see accurate local prayer times.';

  @override
  String get openLocation => 'Choose location';

  @override
  String get prayerSettings => 'Calculation settings';

  @override
  String get todaySchedule => 'Today’s schedule';

  @override
  String get monthlySchedule => 'Monthly timetable';

  @override
  String get nextPrayer => 'Next prayer';

  @override
  String get currentPrayer => 'Current prayer';

  @override
  String get timeRemaining => 'Time remaining';

  @override
  String get prayerStarted => 'It’s time for';

  @override
  String get sunriseSunset => 'Sunlight';

  @override
  String get calculationMethod => 'Calculation method';

  @override
  String get madhab => 'Asr calculation';

  @override
  String get madhabStandard => 'Standard';

  @override
  String get madhabHanafi => 'Hanafi';

  @override
  String get manualAdjustments => 'Minute adjustments';

  @override
  String get timeFormat => '24-hour time';

  @override
  String get highLatitudeNote =>
      'High-latitude adjustment is selected automatically for this location.';

  @override
  String get prayerAccuracyNote =>
      'AlAdhan timings are cached on this device. Follow your local mosque if its timetable differs.';

  @override
  String get prayerNoLocationError =>
      'Select a location before viewing prayer times.';

  @override
  String get prayerTimezoneError =>
      'Could not determine this location’s time zone.';

  @override
  String get prayerCalculationError =>
      'Prayer times could not be calculated. Check your location and settings.';

  @override
  String get prayerStorageError =>
      'Prayer preferences could not be saved on this device.';

  @override
  String adjustmentMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String monthDayCount(int count) {
    return '$count days';
  }

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String decreaseAdjustment(String prayer) {
    return 'Decrease $prayer adjustment';
  }

  @override
  String increaseAdjustment(String prayer) {
    return 'Increase $prayer adjustment';
  }

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerSunset => 'Sunset';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get methodMuslimWorldLeague => 'Muslim World League';

  @override
  String get methodEgyptian => 'Egyptian General Authority';

  @override
  String get methodKarachi => 'University of Islamic Sciences, Karachi';

  @override
  String get methodUmmAlQura => 'Umm al-Qura';

  @override
  String get methodDubai => 'Dubai';

  @override
  String get methodQatar => 'Qatar';

  @override
  String get methodKuwait => 'Kuwait';

  @override
  String get methodMoonsightingCommittee => 'Moonsighting Committee';

  @override
  String get methodSingapore => 'Singapore';

  @override
  String get methodTurkiye => 'Türkiye (Diyanet)';

  @override
  String get methodTehran => 'Tehran';

  @override
  String get methodNorthAmerica => 'North America (ISNA)';

  @override
  String get methodMorocco => 'Morocco';
}
