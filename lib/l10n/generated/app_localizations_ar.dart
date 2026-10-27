// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'صلاح';

  @override
  String get hijriDate => 'التاريخ الهجري';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navPrayer => 'الصلاة';

  @override
  String get navQuran => 'القرآن';

  @override
  String get navQibla => 'القبلة';

  @override
  String get quranTitle => 'القرآن الكريم';

  @override
  String get quranComingSoon => 'يجري إعداد مساحة قراءة القرآن.';

  @override
  String get quranLoading => 'جارٍ تحميل القرآن';

  @override
  String get quranLoadError =>
      'تعذر تحميل القرآن. تحقق من الاتصال وحاول مجددًا.';

  @override
  String get quranLibraryHeading => 'اقرأ القرآن الكريم';

  @override
  String get quranLibraryDescription =>
      'تصفح السور وافتح سورة لقراءة نصها العربي.';

  @override
  String get quranSearchHint => 'ابحث باسم السورة أو رقمها';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String quranSurahCount(int count) {
    return '$count سورة';
  }

  @override
  String get quranNoResults => 'لا توجد سور تطابق بحثك.';

  @override
  String get quranAyahs => 'آية';

  @override
  String get quranReadingTitle => 'قراءة القرآن';

  @override
  String get quranPage => 'الصفحة';

  @override
  String quranPartNumber(int number) {
    return 'الجزء $number';
  }

  @override
  String quranAyahNumber(int number) {
    return 'الآية $number';
  }

  @override
  String get quranBySurah => 'القرآن حسب السورة';

  @override
  String get quranByJuz => 'القرآن حسب الجزء';

  @override
  String get quranFull => 'القرآن كاملًا';

  @override
  String quranJuzNumber(int number) {
    return 'الجزء $number';
  }

  @override
  String quranPageCount(int page, int total) {
    return 'الصفحة $page من $total';
  }

  @override
  String get previousPage => 'الصفحة السابقة';

  @override
  String get nextPage => 'الصفحة التالية';

  @override
  String get qiblaTitle => 'القبلة';

  @override
  String get qiblaComingSoon => 'ستتوفر بوصلة القبلة في مرحلة لاحقة.';

  @override
  String get qiblaLocationRequired => 'اختر موقعًا لحساب اتجاه الكعبة.';

  @override
  String get qiblaBearing => 'الاتجاه من الشمال';

  @override
  String get kaabaDistance => 'المسافة إلى الكعبة';

  @override
  String get compassUnavailable =>
      'إشارة البوصلة غير متاحة. تُظهر علامة الكعبة الاتجاه من الشمال.';

  @override
  String get compassNorth => 'ش';

  @override
  String get compassEast => 'ق';

  @override
  String get compassSouth => 'ج';

  @override
  String get compassWest => 'غ';

  @override
  String get compassAlignHint =>
      'أدر جهازك حتى تصبح علامة الكعبة في أعلى البوصلة.';

  @override
  String get compassSearching => 'جارٍ البحث عن إشارة البوصلة…';

  @override
  String get compassCalibrationTitle => 'معايرة البوصلة';

  @override
  String get compassCalibrationDescription =>
      'حرّك الهاتف بشكل الرقم ثمانية عدة مرات وأبعده عن المغناطيس والمعادن والأجهزة الإلكترونية. قد يؤثر التداخل والانحراف المغناطيسي المحلي في القراءة.';

  @override
  String get notificationSettingsTitle => 'تنبيهات الصلاة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsPrayerSection => 'الصلاة والموقع';

  @override
  String get prayerAlertsTitle => 'إشعارات الصلاة';

  @override
  String get notificationPermissionDescription =>
      'اختر الصلوات التي تريد تنبيهًا لها. قد يطلب الجهاز إذن الإشعارات عند التفعيل لأول مرة.';

  @override
  String get prayerTimeNotification => 'تنبيه عند دخول وقت الصلاة';

  @override
  String get homeTitle => 'معاينة نظام التصميم';

  @override
  String get welcomeTitle => 'مرحبًا بك في صلاح';

  @override
  String get viewAllPrayerTimes => 'جميع أوقات الصلاة';

  @override
  String get homeDescription => 'أساس بصري مشترك لكل ميزات صلاح.';

  @override
  String get navSystem => 'النظام';

  @override
  String get navStates => 'الحالات';

  @override
  String get navAppearance => 'المظهر';

  @override
  String get sectionTypography => 'الخطوط';

  @override
  String get typeDisplay => 'إرشاد واضح كل يوم';

  @override
  String get typeHeadline => 'تجربة قراءة مريحة';

  @override
  String get typeBody => 'استخدم أحجام خطوط متسقة لتكون القراءة سهلة ومريحة.';

  @override
  String get sectionButtons => 'الأزرار';

  @override
  String get buttonPrimary => 'الإجراء الأساسي';

  @override
  String get buttonSecondary => 'الإجراء الثانوي';

  @override
  String get buttonText => 'إجراء نصي';

  @override
  String get buttonPressed => 'تم اختيار الزر التجريبي';

  @override
  String get sectionCards => 'البطاقات';

  @override
  String get cardTitle => 'مساحة مشتركة';

  @override
  String get cardDescription =>
      'تستخدم البطاقات ألوان المظهر النشط وحواف مستديرة وتباعدًا متناسقًا.';

  @override
  String get sectionStates => 'الحالات المشتركة';

  @override
  String get loadingLabel => 'جارٍ التحميل';

  @override
  String get emptyTitle => 'لا توجد عناصر محفوظة';

  @override
  String get emptyDescription => 'ستظهر العناصر المحفوظة هنا عند توفرها.';

  @override
  String get emptyAction => 'عرض إجراء تجريبي';

  @override
  String get errorTitle => 'تعذر تحميل المحتوى';

  @override
  String get errorDescription => 'تحقق من اتصالك وحاول مجددًا.';

  @override
  String get retry => 'حاول مجددًا';

  @override
  String get retryPressed => 'تم اختيار إعادة المحاولة';

  @override
  String get sectionColors => 'لون التمييز';

  @override
  String get sectionThemeMode => 'نمط المظهر';

  @override
  String get appearanceTitle => 'إعدادات المظهر';

  @override
  String get accentColor => 'اختر لون التمييز';

  @override
  String get themeMode => 'اختر مظهر التطبيق';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get close => 'إغلاق';

  @override
  String get colorForest => 'أخضر غابي';

  @override
  String get colorTeal => 'فيروزي';

  @override
  String get colorIndigo => 'نيلي';

  @override
  String get colorAmber => 'كهرماني';

  @override
  String get colorRose => 'وردي';

  @override
  String get locationTitle => 'موقعك';

  @override
  String get locationSubtitle => 'اختر مدينة لأوقات الصلاة المحلية.';

  @override
  String get activeLocation => 'الموقع النشط';

  @override
  String get noActiveLocation => 'لم يتم اختيار موقع نشط';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String get currentLocationDescription =>
      'استخدم موقع جهازك أثناء فتح التطبيق.';

  @override
  String get useCurrentLocation => 'استخدام الموقع الحالي';

  @override
  String get saveCurrentLocation => 'حفظ هذا الموقع';

  @override
  String get searchCityTitle => 'البحث عن مدينة';

  @override
  String get searchCityHint => 'ابحث عن مدينة أو عنوان';

  @override
  String get search => 'بحث';

  @override
  String get searchResults => 'نتائج البحث';

  @override
  String get savedLocations => 'المواقع المحفوظة';

  @override
  String get noSavedLocations => 'لا توجد مواقع محفوظة';

  @override
  String get noSavedLocationsDescription =>
      'ابحث عن مدينة واحفظها للتبديل بين المواقع بسهولة.';

  @override
  String get saveLocation => 'حفظ الموقع';

  @override
  String get removeLocation => 'حذف الموقع';

  @override
  String get activeLabel => 'نشط';

  @override
  String get selectLocation => 'استخدام هذا الموقع';

  @override
  String get privacyLocationNote =>
      'يُستخدم موقع الجهاز أثناء فتح التطبيق فقط. تُحفظ المدينة المختارة والأماكن على هذا الجهاز.';

  @override
  String get alreadySaved => 'محفوظ';

  @override
  String get unknownCity => 'مكان بلا اسم';

  @override
  String get locationPermissionDenied =>
      'لم يُمنح إذن الموقع. يمكنك البحث عن مدينة بدلًا من ذلك.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'إذن الموقع لتطبيق صلاح متوقف. فعّله من إعدادات الجهاز أو ابحث عن مدينة.';

  @override
  String get locationServicesDisabled =>
      'خدمات الموقع متوقفة. فعّلها من الإعدادات أو ابحث عن مدينة.';

  @override
  String get currentLocationUnavailable =>
      'تعذر تحديد موقعك الحالي. حاول مجددًا أو ابحث عن مدينة.';

  @override
  String get locationNoResults =>
      'لم يتم العثور على مدينة مطابقة. جرّب بحثًا أكثر تحديدًا.';

  @override
  String get locationSearchFailed =>
      'البحث عن المدن غير متاح مؤقتًا. حاول لاحقًا.';

  @override
  String get locationStorageFailed =>
      'تعذرت قراءة المواقع المحفوظة أو تحديثها.';

  @override
  String get locationUnknownError => 'حدث خطأ في الموقع. حاول مجددًا.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get searchingCities => 'جارٍ البحث عن المدن';

  @override
  String get loadingLocations => 'جارٍ تحميل المواقع المحفوظة';

  @override
  String get locationUpdated => 'تم تحديث الموقع النشط';

  @override
  String get locationSaved => 'تم حفظ الموقع';

  @override
  String get locationRemoved => 'تم حذف الموقع';

  @override
  String get prayerTimesTitle => 'أوقات الصلاة';

  @override
  String get prayerTimesSubtitle => 'عرض هادئ لأوقات صلوات اليوم.';

  @override
  String get prayerNoLocation => 'اختر موقعًا لعرض أوقات الصلاة المحلية.';

  @override
  String get openLocation => 'اختيار الموقع';

  @override
  String get prayerSettings => 'إعدادات الحساب';

  @override
  String get todaySchedule => 'أوقات اليوم';

  @override
  String get todayLabel => 'اليوم';

  @override
  String get monthlySchedule => 'الجدول الشهري';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String get currentPrayer => 'الصلاة الحالية';

  @override
  String get timeRemaining => 'الوقت المتبقي';

  @override
  String get prayerStarted => 'حان وقت';

  @override
  String get sunriseSunset => 'الشمس';

  @override
  String get calculationMethod => 'طريقة الحساب';

  @override
  String get madhab => 'حساب العصر';

  @override
  String get madhabStandard => 'الجمهور';

  @override
  String get madhabHanafi => 'حنفي';

  @override
  String get manualAdjustments => 'تعديل الدقائق';

  @override
  String get timeFormat => 'صيغة ٢٤ ساعة';

  @override
  String get highLatitudeNote =>
      'يُختار تعديل خطوط العرض العليا تلقائيًا لهذا الموقع.';

  @override
  String get prayerAccuracyNote =>
      'تُحفظ أوقات AlAdhan على الجهاز. اتبع جدول مسجدك المحلي إذا اختلفت الأوقات.';

  @override
  String get prayerNoLocationError => 'اختر موقعًا قبل عرض أوقات الصلاة.';

  @override
  String get prayerTimezoneError => 'تعذر تحديد المنطقة الزمنية لهذا الموقع.';

  @override
  String get prayerCalculationError =>
      'تعذر حساب أوقات الصلاة. تحقق من موقعك والإعدادات.';

  @override
  String get prayerStorageError => 'تعذر حفظ إعدادات الصلاة على الجهاز.';

  @override
  String adjustmentMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String monthDayCount(int count) {
    return '$count يومًا';
  }

  @override
  String get previousMonth => 'الشهر السابق';

  @override
  String get nextMonth => 'الشهر التالي';

  @override
  String decreaseAdjustment(String prayer) {
    return 'تقليل تعديل $prayer';
  }

  @override
  String increaseAdjustment(String prayer) {
    return 'زيادة تعديل $prayer';
  }

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerSunset => 'الغروب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get methodMuslimWorldLeague => 'رابطة العالم الإسلامي';

  @override
  String get methodEgyptian => 'الهيئة المصرية العامة للمساحة';

  @override
  String get methodKarachi => 'جامعة العلوم الإسلامية، كراتشي';

  @override
  String get methodUmmAlQura => 'أم القرى';

  @override
  String get methodDubai => 'دبي';

  @override
  String get methodQatar => 'قطر';

  @override
  String get methodKuwait => 'الكويت';

  @override
  String get methodMoonsightingCommittee => 'لجنة رؤية الهلال';

  @override
  String get methodSingapore => 'سنغافورة';

  @override
  String get methodTurkiye => 'تركيا (ديانت)';

  @override
  String get methodTehran => 'طهران';

  @override
  String get methodNorthAmerica => 'أمريكا الشمالية (ISNA)';

  @override
  String get methodMorocco => 'المغرب';

  @override
  String get quranTimeout =>
      'استغرق الطلب وقتًا طويلًا. حاول مجددًا أو نزّل القرآن للقراءة دون اتصال.';

  @override
  String get quranFontSize => 'حجم خط القرآن';

  @override
  String get jumpToAyah => 'الانتقال إلى آية';

  @override
  String get jumpToPage => 'الانتقال إلى صفحة';

  @override
  String get pageRange => 'الصفحة (١–٦٠٤)';

  @override
  String get openPage => 'فتح الصفحة';

  @override
  String get bookmarkAyah => 'حفظ الآية';

  @override
  String get removeBookmark => 'حذف العلامة';

  @override
  String get copyAyah => 'نسخ الآية';

  @override
  String get copied => 'تم نسخ الآية';

  @override
  String get showTranslation => 'الترجمة الإنجليزية';

  @override
  String get translationAttribution => 'صحيح إنترناشيونال · AlQuran Cloud';

  @override
  String get playRecitation => 'تشغيل التلاوة';

  @override
  String get stopRecitation => 'إيقاف التلاوة';

  @override
  String get recitationAttribution =>
      'مشاري العفاسي · AlQuran Cloud · تتطلب التلاوة اتصالًا بالإنترنت';

  @override
  String get saveFailed => 'تعذر حفظ التغييرات. حاول مجددًا.';

  @override
  String get quranDownload => 'تنزيل القرآن العربي';

  @override
  String get quranDownloadHint =>
      'احفظ جميع الصفحات العربية على الجهاز للقراءة دون اتصال.';

  @override
  String get quranDownloaded => 'القرآن العربي جاهز دون اتصال';

  @override
  String get quranDownloading => 'جارٍ تنزيل القرآن…';

  @override
  String get downloadFailed =>
      'تعذر التنزيل. حاول مجددًا؛ المحتوى المحفوظ ما زال متاحًا.';

  @override
  String get continueReading => 'متابعة القراءة';

  @override
  String get bookmarks => 'العلامات المرجعية';

  @override
  String get noBookmarks => 'اضغط على آية أثناء القراءة لحفظ علامة مرجعية.';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'لغة الجهاز';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get setupTitle => 'إعداد أوقات الصلاة';

  @override
  String get setupDescription =>
      'اختر موقعك ثم راجع طريقة الحساب المعتمدة في مسجدك المحلي.';

  @override
  String get setupLocation => '١. اختر موقعك';

  @override
  String get setupCalculation => '٢. راجع إعدادات الحساب';

  @override
  String get finishSetup => 'ابدأ استخدام صلاح';

  @override
  String get reviewSetup => 'مراجعة الإعداد';

  @override
  String get sourceAladhan => 'المصدر: AlAdhan';

  @override
  String get sourceLocal => 'المصدر: حساب على الجهاز';

  @override
  String get alertsDenied =>
      'الإشعارات متوقفة. فعّلها في إعدادات الجهاز ثم حاول مجددًا.';

  @override
  String get alertsFailed => 'تعذر تحديث تنبيهات الصلاة. حاول مجددًا.';

  @override
  String get alertsLocation => 'اختر موقعًا لجدولة تنبيهات الصلاة.';

  @override
  String get alertsOff => 'لا توجد تنبيهات صلاة مفعّلة.';

  @override
  String alertsSchedule(int count) {
    return 'تمت جدولة $count تنبيهًا. افتح صلاح بانتظام لتجديد جدول الأيام الـ١٢ القادمة.';
  }

  @override
  String get alertsApproximate =>
      'قد يؤخر أندرويد التنبيهات. اسمح بالمنبهات الدقيقة للتنبيه في الوقت المحسوب.';

  @override
  String get allowExactAlerts => 'السماح بالمنبهات الدقيقة';

  @override
  String get alertsPermissionDenied => 'لم يُمنح إذن الإشعارات.';

  @override
  String get alertsRollingNote =>
      'تتبع التنبيهات المدينة المختارة وإعدادات الحساب. يتبع الصوت إعدادات الجهاز. يتجدد الجدول عند فتح صلاح؛ صوت الأذان الكامل غير مضمّن.';

  @override
  String get hijriCalendarTitle => 'التقويم الهجري';

  @override
  String get calendarMethodNote =>
      'تقويم أم القرى · يعمل دون اتصال. قد تختلف التواريخ والمناسبات بحسب رؤية الهلال محليًا.';

  @override
  String get calendarRange => 'يدعم التقويم السنوات الهجرية من ١٣٥٦ إلى ١٥٠٠.';

  @override
  String get chooseHijriMonth => 'اختر الشهر والسنة';

  @override
  String get calendarMonth => 'الشهر الهجري';

  @override
  String get calendarYear => 'السنة الهجرية';

  @override
  String get showCalendar => 'عرض الشهر';

  @override
  String get calendarToday => 'اليوم';

  @override
  String get calendarNumberLegend =>
      'الرقم الكبير: اليوم الهجري · الرقم الصغير: اليوم الميلادي · النقطة: مناسبة إسلامية';

  @override
  String get monthOccasions => 'مناسبات هذا الشهر';

  @override
  String get noMonthOccasions => 'لا توجد مناسبات مدرجة لهذا الشهر.';

  @override
  String get islamicNewYear => 'رأس السنة الهجرية';

  @override
  String get dayOfAshura => 'يوم عاشوراء';

  @override
  String get ramadanBegins => 'بداية رمضان';

  @override
  String get eidAlFitr => 'عيد الفطر';

  @override
  String get dayOfArafah => 'يوم عرفة';

  @override
  String get eidAlAdha => 'عيد الأضحى';

  @override
  String get daysOfTashriq => 'أيام التشريق';

  @override
  String get kaabaDirection => 'اتجاه الكعبة';

  @override
  String get ayahOfTheDay => 'آية اليوم';

  @override
  String get dailyAyahUnavailable =>
      'تعذر تحميل آية اليوم. اتصل بالإنترنت أو نزّل القرآن العربي.';

  @override
  String get dailyTranslationUnavailable => 'الترجمة غير متاحة · حاول مجددًا';

  @override
  String get readThisSurah => 'قراءة السورة';

  @override
  String get hijriEra => 'هـ';
}
