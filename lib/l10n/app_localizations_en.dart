// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get appearance => 'Appearance';

  @override
  String get approaching => 'Approaching';

  @override
  String get arrived => 'Arrived';

  @override
  String get auto => 'Auto';

  @override
  String boundFor(String destination) {
    return 'Bound for $destination';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get checkUpdate => 'Check for Updates';

  @override
  String get clearSettingsAndFavorites => 'Clear settings and favorites';

  @override
  String get commonStations => 'Favorite Stations';

  @override
  String get confirm => 'Confirm';

  @override
  String get dark => 'Dark';

  @override
  String get dataResetSuccess => 'Data reset successfully';

  @override
  String get dataSourceStatement => 'Data Source Statement';

  @override
  String get dataSourceStatementContent =>
      'The real-time train dynamics in this application are retrieved from Taipei Metro\'s unofficial APIs. The data is provided for personal reference and programming learning purposes only. Accuracy and timeliness are not guaranteed, and it shall not be used for commercial purposes.';

  @override
  String get dataSourceStatementTitle => 'Data Source Statement';

  @override
  String get delete => 'Delete';

  @override
  String deleteFavoriteStationConfirm(String key) {
    return 'Are you sure you want to delete \"$key\"?';
  }

  @override
  String get deleteFavoriteStationTitle => 'Delete Favorite Station';

  @override
  String get departing => 'Departing';

  @override
  String get developer => 'Developer';

  @override
  String get downloadNow => 'Download Now';

  @override
  String get dynamicColorAndroidDesc => 'Use Android system theme colors';

  @override
  String get dynamicColorDefaultDesc => 'Use system theme colors';

  @override
  String get dynamicColorWebDesc => 'Use system theme colors';

  @override
  String get dynamicColorWindowsDesc => 'Use Windows system theme colors';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackSubtitle => 'GitHub Issues';

  @override
  String get findNearestStation => 'Find Nearest Station';

  @override
  String get general => 'General';

  @override
  String get home => 'Home';

  @override
  String get language => 'Language';

  @override
  String get later => 'Later';

  @override
  String get latestVersionInstalled => 'Already the latest version';

  @override
  String get light => 'Light';

  @override
  String get loading => 'Loading...';

  @override
  String get locatingAuto => 'Auto locate on startup';

  @override
  String get locatingLabel => 'Locating...';

  @override
  String get locatingManual => 'Manual locate on tap';

  @override
  String get locatingOff => 'Do not show nearest station';

  @override
  String get locatingProgress => 'Getting your location...';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationPermissionRequiredPrompt =>
      'Location permission is required to find nearby metro stations';

  @override
  String get manual => 'Manual';

  @override
  String get nearestStationTitle => 'Nearest Station';

  @override
  String get networkError =>
      'Network connection error. Please check your internet connection.';

  @override
  String get nextTrain => 'Next Train';

  @override
  String get noData => 'No Data';

  @override
  String get noTrainsInfo => 'No train information currently';

  @override
  String get noTrainsInfoManualPrompt =>
      '(If manual refresh is enabled, please click refresh button above)';

  @override
  String get notLocatedYetLabel => 'Not Located';

  @override
  String get notLocatingYetPromptEnd => ' in the top-left to locate';

  @override
  String get notLocatingYetPromptStart => 'Tap ';

  @override
  String get off => 'Off';

  @override
  String get offlineCacheWarning =>
      'Connection failed, showing cached information';

  @override
  String get openSettingsButton => 'Open Settings';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get pureBlackDesc =>
      'Use pure black background to reduce OLED power usage';

  @override
  String get pureBlackMode => 'Pure Black Mode';

  @override
  String get refreshInterval => 'Auto Refresh Rate';

  @override
  String get refreshStationTooltip => 'Refresh this station';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get resetData => 'Reset Data';

  @override
  String get resetFavorites => 'Favorite Stations';

  @override
  String get resetSettings => 'Settings';

  @override
  String get resultsFromOtherLines => 'Search results from other lines';

  @override
  String get searchStationHint => 'Search station name or code';

  @override
  String seconds(int count) {
    return '${count}s';
  }

  @override
  String get selectThemeColor => 'Select Theme Color';

  @override
  String get settings => 'Settings';

  @override
  String get stationDetailTitle => 'Train Dynamics';

  @override
  String get stations => 'Stations';

  @override
  String get subsequentTrain => 'Following Train';

  @override
  String get system => 'System';

  @override
  String get systemDynamicColor => 'System Dynamic Theme';

  @override
  String get themeDarkMode => 'Dark mode';

  @override
  String get themeFollowSystem => 'Follow system settings';

  @override
  String get themeLightMode => 'Light mode';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themePureBlackDesc =>
      'Pure black mode (reduce OLED battery drain)';

  @override
  String get understand => 'OK';

  @override
  String updateAvailableDesc(String latestVersion, String currentVersion) {
    return 'New version $latestVersion found\nCurrent version $currentVersion\n\nWould you like to download it now?';
  }

  @override
  String get updateAvailableTitle => 'New Version Available';

  @override
  String updateCheckFailed(String error) {
    return 'Failed to check update: $error';
  }

  @override
  String get webPermissionInstructionEnd => ' to relocate.';

  @override
  String get webPermissionInstructionMiddle =>
      ' in the browser address bar or allow the site to access \"Location\" in the website settings card, then click ';

  @override
  String get webPermissionInstructionStart => 'Please click ';
}
