import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @about.
  ///
  /// In zh_TW, this message translates to:
  /// **'關於'**
  String get about;

  /// No description provided for @addToFavorites.
  ///
  /// In zh_TW, this message translates to:
  /// **'加入常用'**
  String get addToFavorites;

  /// No description provided for @appearance.
  ///
  /// In zh_TW, this message translates to:
  /// **'外觀'**
  String get appearance;

  /// No description provided for @approaching.
  ///
  /// In zh_TW, this message translates to:
  /// **'即將進站'**
  String get approaching;

  /// No description provided for @arrived.
  ///
  /// In zh_TW, this message translates to:
  /// **'已進站'**
  String get arrived;

  /// No description provided for @auto.
  ///
  /// In zh_TW, this message translates to:
  /// **'自動'**
  String get auto;

  /// No description provided for @boundFor.
  ///
  /// In zh_TW, this message translates to:
  /// **'往 {destination}'**
  String boundFor(String destination);

  /// No description provided for @cancel.
  ///
  /// In zh_TW, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @checkUpdate.
  ///
  /// In zh_TW, this message translates to:
  /// **'檢查更新'**
  String get checkUpdate;

  /// No description provided for @clearSettingsAndFavorites.
  ///
  /// In zh_TW, this message translates to:
  /// **'清除設定與常用'**
  String get clearSettingsAndFavorites;

  /// No description provided for @commonStations.
  ///
  /// In zh_TW, this message translates to:
  /// **'常用站點'**
  String get commonStations;

  /// No description provided for @confirm.
  ///
  /// In zh_TW, this message translates to:
  /// **'確認'**
  String get confirm;

  /// No description provided for @dark.
  ///
  /// In zh_TW, this message translates to:
  /// **'深色'**
  String get dark;

  /// No description provided for @dataResetSuccess.
  ///
  /// In zh_TW, this message translates to:
  /// **'資料已重設'**
  String get dataResetSuccess;

  /// No description provided for @dataSourceStatement.
  ///
  /// In zh_TW, this message translates to:
  /// **'資料來源聲明'**
  String get dataSourceStatement;

  /// No description provided for @dataSourceStatementContent.
  ///
  /// In zh_TW, this message translates to:
  /// **'本應用程式之列車動態資訊介接自台北捷運非公開 API，相關資料僅供程式開發學習與個人參考使用，不保證其即時性與準確度，亦不得用於商業用途。'**
  String get dataSourceStatementContent;

  /// No description provided for @dataSourceStatementTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'資料來源聲明'**
  String get dataSourceStatementTitle;

  /// No description provided for @delete.
  ///
  /// In zh_TW, this message translates to:
  /// **'刪除'**
  String get delete;

  /// No description provided for @deleteFavoriteStationConfirm.
  ///
  /// In zh_TW, this message translates to:
  /// **'確定要刪除「{key}」嗎？'**
  String deleteFavoriteStationConfirm(String key);

  /// No description provided for @deleteFavoriteStationTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'刪除常用站點'**
  String get deleteFavoriteStationTitle;

  /// No description provided for @departing.
  ///
  /// In zh_TW, this message translates to:
  /// **'列車駛離'**
  String get departing;

  /// No description provided for @developer.
  ///
  /// In zh_TW, this message translates to:
  /// **'開發者'**
  String get developer;

  /// No description provided for @downloadNow.
  ///
  /// In zh_TW, this message translates to:
  /// **'立即下載'**
  String get downloadNow;

  /// No description provided for @dynamicColorAndroidDesc.
  ///
  /// In zh_TW, this message translates to:
  /// **'使用 Android 系統的主題色彩'**
  String get dynamicColorAndroidDesc;

  /// No description provided for @dynamicColorDefaultDesc.
  ///
  /// In zh_TW, this message translates to:
  /// **'使用系統的主題色彩'**
  String get dynamicColorDefaultDesc;

  /// No description provided for @dynamicColorWebDesc.
  ///
  /// In zh_TW, this message translates to:
  /// **'使用系統的主題色彩'**
  String get dynamicColorWebDesc;

  /// No description provided for @dynamicColorWindowsDesc.
  ///
  /// In zh_TW, this message translates to:
  /// **'使用 Windows 系統的主題色彩'**
  String get dynamicColorWindowsDesc;

  /// No description provided for @feedback.
  ///
  /// In zh_TW, this message translates to:
  /// **'意見反映'**
  String get feedback;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'GitHub Issues'**
  String get feedbackSubtitle;

  /// No description provided for @findNearestStation.
  ///
  /// In zh_TW, this message translates to:
  /// **'尋找最近車站'**
  String get findNearestStation;

  /// No description provided for @general.
  ///
  /// In zh_TW, this message translates to:
  /// **'一般'**
  String get general;

  /// No description provided for @home.
  ///
  /// In zh_TW, this message translates to:
  /// **'首頁'**
  String get home;

  /// No description provided for @language.
  ///
  /// In zh_TW, this message translates to:
  /// **'語言'**
  String get language;

  /// No description provided for @later.
  ///
  /// In zh_TW, this message translates to:
  /// **'稍後'**
  String get later;

  /// No description provided for @latestVersionInstalled.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前已是最新版本'**
  String get latestVersionInstalled;

  /// No description provided for @light.
  ///
  /// In zh_TW, this message translates to:
  /// **'淺色'**
  String get light;

  /// No description provided for @loading.
  ///
  /// In zh_TW, this message translates to:
  /// **'載入中...'**
  String get loading;

  /// No description provided for @locatingAuto.
  ///
  /// In zh_TW, this message translates to:
  /// **'啟動時自動定位'**
  String get locatingAuto;

  /// No description provided for @locatingLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'定位中...'**
  String get locatingLabel;

  /// No description provided for @locatingManual.
  ///
  /// In zh_TW, this message translates to:
  /// **'手動按下圖示更新定位'**
  String get locatingManual;

  /// No description provided for @locatingOff.
  ///
  /// In zh_TW, this message translates to:
  /// **'不顯示附近車站'**
  String get locatingOff;

  /// No description provided for @locatingProgress.
  ///
  /// In zh_TW, this message translates to:
  /// **'正在取得您的位置...'**
  String get locatingProgress;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In zh_TW, this message translates to:
  /// **'位置權限未授予'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionRequiredPrompt.
  ///
  /// In zh_TW, this message translates to:
  /// **'需要位置權限才能尋找附近捷運站'**
  String get locationPermissionRequiredPrompt;

  /// No description provided for @manual.
  ///
  /// In zh_TW, this message translates to:
  /// **'手動'**
  String get manual;

  /// No description provided for @nearestStationTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'距離最近的車站'**
  String get nearestStationTitle;

  /// No description provided for @networkError.
  ///
  /// In zh_TW, this message translates to:
  /// **'網路連線異常，請檢查您的網路連線'**
  String get networkError;

  /// No description provided for @nextTrain.
  ///
  /// In zh_TW, this message translates to:
  /// **'下班車'**
  String get nextTrain;

  /// No description provided for @noData.
  ///
  /// In zh_TW, this message translates to:
  /// **'無資料'**
  String get noData;

  /// No description provided for @noTrainsInfo.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前無列車資訊'**
  String get noTrainsInfo;

  /// No description provided for @noTrainsInfoManualPrompt.
  ///
  /// In zh_TW, this message translates to:
  /// **'（若為手動更新，請點擊上方重新整理按鈕）'**
  String get noTrainsInfoManualPrompt;

  /// No description provided for @notLocatedYetLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'尚未定位'**
  String get notLocatedYetLabel;

  /// No description provided for @notLocatingYetPromptEnd.
  ///
  /// In zh_TW, this message translates to:
  /// **' 重新定位'**
  String get notLocatingYetPromptEnd;

  /// No description provided for @notLocatingYetPromptStart.
  ///
  /// In zh_TW, this message translates to:
  /// **'輕觸左上角 '**
  String get notLocatingYetPromptStart;

  /// No description provided for @off.
  ///
  /// In zh_TW, this message translates to:
  /// **'關閉'**
  String get off;

  /// No description provided for @offlineCacheWarning.
  ///
  /// In zh_TW, this message translates to:
  /// **'無法連線，目前顯示快取資訊'**
  String get offlineCacheWarning;

  /// No description provided for @openSettingsButton.
  ///
  /// In zh_TW, this message translates to:
  /// **'打開設定'**
  String get openSettingsButton;

  /// No description provided for @openSourceLicenses.
  ///
  /// In zh_TW, this message translates to:
  /// **'開放原始碼授權'**
  String get openSourceLicenses;

  /// No description provided for @pureBlackDesc.
  ///
  /// In zh_TW, this message translates to:
  /// **'使用純黑色底色，減少 OLED 螢幕耗電'**
  String get pureBlackDesc;

  /// No description provided for @pureBlackMode.
  ///
  /// In zh_TW, this message translates to:
  /// **'純黑模式'**
  String get pureBlackMode;

  /// No description provided for @refreshInterval.
  ///
  /// In zh_TW, this message translates to:
  /// **'自動刷新速率'**
  String get refreshInterval;

  /// No description provided for @refreshStationTooltip.
  ///
  /// In zh_TW, this message translates to:
  /// **'刷新此站'**
  String get refreshStationTooltip;

  /// No description provided for @removeFromFavorites.
  ///
  /// In zh_TW, this message translates to:
  /// **'移除常用'**
  String get removeFromFavorites;

  /// No description provided for @resetData.
  ///
  /// In zh_TW, this message translates to:
  /// **'重設資料'**
  String get resetData;

  /// No description provided for @resetFavorites.
  ///
  /// In zh_TW, this message translates to:
  /// **'常用站點'**
  String get resetFavorites;

  /// No description provided for @resetSettings.
  ///
  /// In zh_TW, this message translates to:
  /// **'設定'**
  String get resetSettings;

  /// No description provided for @resultsFromOtherLines.
  ///
  /// In zh_TW, this message translates to:
  /// **'來自其他路線的搜尋結果'**
  String get resultsFromOtherLines;

  /// No description provided for @searchStationHint.
  ///
  /// In zh_TW, this message translates to:
  /// **'搜尋站名或代碼'**
  String get searchStationHint;

  /// No description provided for @seconds.
  ///
  /// In zh_TW, this message translates to:
  /// **'{count} 秒'**
  String seconds(int count);

  /// No description provided for @selectThemeColor.
  ///
  /// In zh_TW, this message translates to:
  /// **'選擇主題色彩'**
  String get selectThemeColor;

  /// No description provided for @settings.
  ///
  /// In zh_TW, this message translates to:
  /// **'設定'**
  String get settings;

  /// No description provided for @stationDetailTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'列車動態'**
  String get stationDetailTitle;

  /// No description provided for @stations.
  ///
  /// In zh_TW, this message translates to:
  /// **'車站總覽'**
  String get stations;

  /// No description provided for @subsequentTrain.
  ///
  /// In zh_TW, this message translates to:
  /// **'後續車'**
  String get subsequentTrain;

  /// No description provided for @system.
  ///
  /// In zh_TW, this message translates to:
  /// **'系統'**
  String get system;

  /// No description provided for @systemDynamicColor.
  ///
  /// In zh_TW, this message translates to:
  /// **'系統動態配色'**
  String get systemDynamicColor;

  /// No description provided for @themeDarkMode.
  ///
  /// In zh_TW, this message translates to:
  /// **'深色模式'**
  String get themeDarkMode;

  /// No description provided for @themeFollowSystem.
  ///
  /// In zh_TW, this message translates to:
  /// **'跟隨系統'**
  String get themeFollowSystem;

  /// No description provided for @themeLightMode.
  ///
  /// In zh_TW, this message translates to:
  /// **'淺色模式'**
  String get themeLightMode;

  /// No description provided for @themeMode.
  ///
  /// In zh_TW, this message translates to:
  /// **'主題模式'**
  String get themeMode;

  /// No description provided for @themePureBlackDesc.
  ///
  /// In zh_TW, this message translates to:
  /// **'純黑模式 (減少OLED螢幕耗電)'**
  String get themePureBlackDesc;

  /// No description provided for @understand.
  ///
  /// In zh_TW, this message translates to:
  /// **'了解'**
  String get understand;

  /// No description provided for @updateAvailableDesc.
  ///
  /// In zh_TW, this message translates to:
  /// **'發現新版本 {latestVersion}\n目前版本 {currentVersion}\n\n是否前往下載？'**
  String updateAvailableDesc(String latestVersion, String currentVersion);

  /// No description provided for @updateAvailableTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'有新版本可用'**
  String get updateAvailableTitle;

  /// No description provided for @updateCheckFailed.
  ///
  /// In zh_TW, this message translates to:
  /// **'檢查更新失敗: {error}'**
  String updateCheckFailed(String error);

  /// No description provided for @webPermissionInstructionEnd.
  ///
  /// In zh_TW, this message translates to:
  /// **' 重新定位。'**
  String get webPermissionInstructionEnd;

  /// No description provided for @webPermissionInstructionMiddle.
  ///
  /// In zh_TW, this message translates to:
  /// **' 或到網站資訊卡設定允許此網站存取「位置資訊」後，點擊 '**
  String get webPermissionInstructionMiddle;

  /// No description provided for @webPermissionInstructionStart.
  ///
  /// In zh_TW, this message translates to:
  /// **'請在瀏覽器網址列點擊 '**
  String get webPermissionInstructionStart;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
