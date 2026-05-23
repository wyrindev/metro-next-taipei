// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'MetroNext';

  @override
  String get home => '首頁';

  @override
  String get stations => '車站總覽';

  @override
  String get settings => '設定';

  @override
  String get general => '一般';

  @override
  String get language => '語言';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get findNearestStation => '尋找最近車站';

  @override
  String get locatingAuto => '啟動時自動定位';

  @override
  String get locatingManual => '手動按下圖示更新定位';

  @override
  String get locatingOff => '不顯示附近車站';

  @override
  String get auto => '自動';

  @override
  String get manual => '手動';

  @override
  String get off => '關閉';

  @override
  String get refreshInterval => '自動刷新速率';

  @override
  String seconds(int count) {
    return '$count 秒';
  }

  @override
  String get resetData => '重設資料';

  @override
  String get clearSettingsAndFavorites => '清除設定與常用';

  @override
  String get appearance => '外觀';

  @override
  String get themeMode => '主題模式';

  @override
  String get themeFollowSystem => '跟隨系統';

  @override
  String get themeLightMode => '淺色模式';

  @override
  String get themeDarkMode => '深色模式';

  @override
  String get themePureBlackDesc => '純黑模式 (減少OLED螢幕耗電)';

  @override
  String get system => '系統';

  @override
  String get light => '淺色';

  @override
  String get dark => '深色';

  @override
  String get pureBlackMode => '純黑模式';

  @override
  String get pureBlackDesc => '使用純黑色底色，減少 OLED 螢幕耗電';

  @override
  String get systemDynamicColor => '系統動態配色';

  @override
  String get dynamicColorWebDesc => '使用系統的主題色彩';

  @override
  String get dynamicColorAndroidDesc => '使用 Android 系統的主題色彩';

  @override
  String get dynamicColorWindowsDesc => '使用 Windows 系統的主題色彩';

  @override
  String get dynamicColorDefaultDesc => '使用系統的主題色彩';

  @override
  String get selectThemeColor => '選擇主題色彩';

  @override
  String get about => '關於';

  @override
  String get checkUpdate => '檢查更新';

  @override
  String get latestVersionInstalled => '目前已是最新版本';

  @override
  String get updateAvailableTitle => '有新版本可用';

  @override
  String updateAvailableDesc(String latestVersion, String currentVersion) {
    return '發現新版本 $latestVersion\n目前版本 $currentVersion\n\n是否前往下載？';
  }

  @override
  String get later => '稍後';

  @override
  String get downloadNow => '立即下載';

  @override
  String updateCheckFailed(String error) {
    return '檢查更新失敗: $error';
  }

  @override
  String get feedback => '意見反映';

  @override
  String get feedbackSubtitle => 'GitHub Issues';

  @override
  String get openSourceLicenses => '開放原始碼授權';

  @override
  String get developer => '開發者';

  @override
  String get dataSourceStatement => '資料來源聲明';

  @override
  String get dataSourceStatementTitle => '資料來源聲明';

  @override
  String get dataSourceStatementContent =>
      '本應用程式之列車動態資訊介接自台北捷運非公開 API，相關資料僅供程式開發學習與個人參考使用，不保證其即時性與準確度，亦不得用於商業用途。';

  @override
  String get understand => '了解';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確認';

  @override
  String get resetFavorites => '常用站點';

  @override
  String get resetSettings => '設定';

  @override
  String get dataResetSuccess => '資料已重設';

  @override
  String get commonStations => '常用站點';

  @override
  String get deleteFavoriteStationTitle => '刪除常用站點';

  @override
  String deleteFavoriteStationConfirm(String key) {
    return '確定要刪除「$key」嗎？';
  }

  @override
  String get delete => '刪除';

  @override
  String get searchStationHint => '搜尋站名或代碼';

  @override
  String get noData => '無資料';

  @override
  String get resultsFromOtherLines => '來自其他路線的搜尋結果';

  @override
  String get addToFavorites => '加入常用';

  @override
  String get removeFromFavorites => '移除常用';

  @override
  String get nearestStationTitle => '距離最近的車站';

  @override
  String get locatingProgress => '正在取得您的位置...';

  @override
  String get locationPermissionDenied => '位置權限未授予';

  @override
  String get locationPermissionRequiredPrompt => '需要位置權限才能尋找附近捷運站';

  @override
  String get webPermissionInstructionStart => '請在瀏覽器網址列點擊 ';

  @override
  String get webPermissionInstructionMiddle => ' 或到網站資訊卡設定允許此網站存取「位置資訊」後，點擊 ';

  @override
  String get webPermissionInstructionEnd => ' 重新定位。';

  @override
  String get openSettingsButton => '打開設定';

  @override
  String get notLocatingYetPromptStart => '輕觸左上角 ';

  @override
  String get notLocatingYetPromptEnd => ' 重新定位';

  @override
  String get locatingLabel => '定位中...';

  @override
  String get notLocatedYetLabel => '尚未定位';

  @override
  String get noTrainsInfo => '目前無列車資訊';

  @override
  String get noTrainsInfoManualPrompt => '（若為手動更新，請點擊上方重新整理按鈕）';

  @override
  String get refreshStationTooltip => '刷新此站';

  @override
  String get offlineCacheWarning => '無法連線，目前顯示快取資訊';

  @override
  String get stationDetailTitle => '列車動態';

  @override
  String boundFor(String destination) {
    return '往 $destination';
  }

  @override
  String get nextTrain => '下班車';

  @override
  String get subsequentTrain => '後續車';

  @override
  String get approaching => '即將進站';

  @override
  String get arrived => '已進站';

  @override
  String get departing => '列車駛離';

  @override
  String get loading => '載入中...';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'MetroNext';

  @override
  String get home => '首頁';

  @override
  String get stations => '車站總覽';

  @override
  String get settings => '設定';

  @override
  String get general => '一般';

  @override
  String get language => '語言';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get findNearestStation => '尋找最近車站';

  @override
  String get locatingAuto => '啟動時自動定位';

  @override
  String get locatingManual => '手動按下圖示更新定位';

  @override
  String get locatingOff => '不顯示附近車站';

  @override
  String get auto => '自動';

  @override
  String get manual => '手動';

  @override
  String get off => '關閉';

  @override
  String get refreshInterval => '自動刷新速率';

  @override
  String seconds(int count) {
    return '$count 秒';
  }

  @override
  String get resetData => '重設資料';

  @override
  String get clearSettingsAndFavorites => '清除設定與常用';

  @override
  String get appearance => '外觀';

  @override
  String get themeMode => '主題模式';

  @override
  String get themeFollowSystem => '跟隨系統';

  @override
  String get themeLightMode => '淺色模式';

  @override
  String get themeDarkMode => '深色模式';

  @override
  String get themePureBlackDesc => '純黑模式 (減少OLED螢幕耗電)';

  @override
  String get system => '系統';

  @override
  String get light => '淺色';

  @override
  String get dark => '深色';

  @override
  String get pureBlackMode => '純黑模式';

  @override
  String get pureBlackDesc => '使用純黑色底色，減少 OLED 螢幕耗電';

  @override
  String get systemDynamicColor => '系統動態配色';

  @override
  String get dynamicColorWebDesc => '使用系統的主題色彩';

  @override
  String get dynamicColorAndroidDesc => '使用 Android 系統的主題色彩';

  @override
  String get dynamicColorWindowsDesc => '使用 Windows 系統的主題色彩';

  @override
  String get dynamicColorDefaultDesc => '使用系統的主題色彩';

  @override
  String get selectThemeColor => '選擇主題色彩';

  @override
  String get about => '關於';

  @override
  String get checkUpdate => '檢查更新';

  @override
  String get latestVersionInstalled => '目前已是最新版本';

  @override
  String get updateAvailableTitle => '有新版本可用';

  @override
  String updateAvailableDesc(String latestVersion, String currentVersion) {
    return '發現新版本 $latestVersion\n目前版本 $currentVersion\n\n是否前往下載？';
  }

  @override
  String get later => '稍後';

  @override
  String get downloadNow => '立即下載';

  @override
  String updateCheckFailed(String error) {
    return '檢查更新失敗: $error';
  }

  @override
  String get feedback => '意見反映';

  @override
  String get feedbackSubtitle => 'GitHub Issues';

  @override
  String get openSourceLicenses => '開放原始碼授權';

  @override
  String get developer => '開發者';

  @override
  String get dataSourceStatement => '資料來源聲明';

  @override
  String get dataSourceStatementTitle => '資料來源聲明';

  @override
  String get dataSourceStatementContent =>
      '本應用程式之列車動態資訊介接自台北捷運非公開 API，相關資料僅供程式開發學習與個人參考使用，不保證其即時性與準確度，亦不得用於商業用途。';

  @override
  String get understand => '了解';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確認';

  @override
  String get resetFavorites => '常用站點';

  @override
  String get resetSettings => '設定';

  @override
  String get dataResetSuccess => '資料已重設';

  @override
  String get commonStations => '常用站點';

  @override
  String get deleteFavoriteStationTitle => '刪除常用站點';

  @override
  String deleteFavoriteStationConfirm(String key) {
    return '確定要刪除「$key」嗎？';
  }

  @override
  String get delete => '刪除';

  @override
  String get searchStationHint => '搜尋站名或代碼';

  @override
  String get noData => '無資料';

  @override
  String get resultsFromOtherLines => '來自其他路線的搜尋結果';

  @override
  String get addToFavorites => '加入常用';

  @override
  String get removeFromFavorites => '移除常用';

  @override
  String get nearestStationTitle => '距離最近的車站';

  @override
  String get locatingProgress => '正在取得您的位置...';

  @override
  String get locationPermissionDenied => '位置權限未授予';

  @override
  String get locationPermissionRequiredPrompt => '需要位置權限才能尋找附近捷運站';

  @override
  String get webPermissionInstructionStart => '請在瀏覽器網址列點擊 ';

  @override
  String get webPermissionInstructionMiddle => ' 或到網站資訊卡設定允許此網站存取「位置資訊」後，點擊 ';

  @override
  String get webPermissionInstructionEnd => ' 重新定位。';

  @override
  String get openSettingsButton => '打開設定';

  @override
  String get notLocatingYetPromptStart => '輕觸左上角 ';

  @override
  String get notLocatingYetPromptEnd => ' 重新定位';

  @override
  String get locatingLabel => '定位中...';

  @override
  String get notLocatedYetLabel => '尚未定位';

  @override
  String get noTrainsInfo => '目前無列車資訊';

  @override
  String get noTrainsInfoManualPrompt => '（若為手動更新，請點擊上方重新整理按鈕）';

  @override
  String get refreshStationTooltip => '刷新此站';

  @override
  String get offlineCacheWarning => '無法連線，目前顯示快取資訊';

  @override
  String get stationDetailTitle => '列車動態';

  @override
  String boundFor(String destination) {
    return '往 $destination';
  }

  @override
  String get nextTrain => '下班車';

  @override
  String get subsequentTrain => '後續車';

  @override
  String get approaching => '即將進站';

  @override
  String get arrived => '已進站';

  @override
  String get departing => '列車駛離';

  @override
  String get loading => '載入中...';
}
