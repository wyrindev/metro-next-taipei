import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:metro_next_taipei/l10n/app_localizations.dart';
import 'package:metro_next_taipei/services/theme_service.dart';
import 'package:metro_next_taipei/services/locale_service.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  static const String appVersion = 'v1.0.0-beta';
  String _nearbyStations = 'auto'; // auto, manual, off
  double _refreshInterval = 10.0;
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nearbyStations = prefs.getString('nearbyStations') ?? 'auto';
      _refreshInterval = prefs.getDouble('refreshInterval') ?? 10.0;
    });
  }

  Future<void> _savePrefs(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  void _showLanguageDialog() {
    String tempLanguage = LocaleService.instance.currentLocale.languageCode;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final l10n = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(l10n.language),
              content: RadioGroup<String>(
                groupValue: tempLanguage,
                onChanged: (v) {
                  if (v != null) {
                    setStateDialog(() => tempLanguage = v);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      value: 'zh',
                      title: Text(l10n.chinese),
                    ),
                    RadioListTile<String>(
                      value: 'en',
                      title: Text(l10n.english),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    await LocaleService.instance.setLocale(
                      Locale(tempLanguage),
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showResetDialog() {
    bool resetFavorites = false;
    bool resetSettings = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final l10n = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(l10n.resetData),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text(l10n.resetFavorites),
                    value: resetFavorites,
                    onChanged: (v) => setStateDialog(() => resetFavorites = v!),
                  ),
                  CheckboxListTile(
                    title: Text(l10n.resetSettings),
                    value: resetSettings,
                    onChanged: (v) => setStateDialog(() => resetSettings = v!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    if (resetFavorites) await prefs.remove('favorites');
                    if (resetSettings) await prefs.clear();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.dataResetSuccess)),
                      );
                      await _loadPrefs();
                    }
                  },
                  child: Text(l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _checkUpdate() async {
    setState(() => _isCheckingUpdate = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/wyrindev/metro-next-taipei/releases/latest',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String latestVersion = data['tag_name'];

        if (mounted) {
          if (latestVersion != appVersion) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.updateAvailableTitle),
                content: Text(
                  l10n.updateAvailableDesc(latestVersion, appVersion),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.later),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final url = Uri.parse(
                        'https://github.com/wyrindev/metro-next-taipei/releases',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: Text(l10n.downloadNow),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.latestVersionInstalled)),
            );
          }
        }
      } else {
        throw Exception('Failed to load version');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.updateCheckFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingUpdate = false);
      }
    }
  }

  void _sendFeedback() async {
    const url = 'https://github.com/wyrindev/metro-next-taipei/issues';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'MetroNext',
      applicationVersion: appVersion,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // 保證對比度的顏色設定
    final scaffoldBgColor = isDark
        ? (ThemeService.instance.oledEnabled
              ? Colors.black
              : colorScheme.surface)
        : colorScheme.surfaceContainerLowest;
    final itemBgColor = isDark
        ? (ThemeService.instance.oledEnabled
              ? const Color(0xFF1C1C1E)
              : colorScheme.surfaceContainer)
        : Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.06),
            colorScheme.surfaceContainerLowest,
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
                child: Text(
                  l10n.general,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Material(
                color: itemBgColor,
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      title: Text(l10n.language),
                      trailing: Text(
                        LocaleService.instance.currentLocale.languageCode ==
                                'en'
                            ? 'English'
                            : '中文',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: _showLanguageDialog,
                    ),
                    Divider(height: 2, thickness: 2, color: scaffoldBgColor),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.findNearestStation,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _nearbyStations == 'auto'
                                  ? l10n.locatingAuto
                                  : _nearbyStations == 'manual'
                                  ? l10n.locatingManual
                                  : l10n.locatingOff,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(value: 'auto', label: Text(l10n.auto)),
                          ButtonSegment(
                            value: 'manual',
                            label: Text(l10n.manual),
                          ),
                          ButtonSegment(value: 'off', label: Text(l10n.off)),
                        ],
                        selected: {_nearbyStations},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() => _nearbyStations = newSelection.first);
                          _savePrefs('nearbyStations', newSelection.first);
                        },
                        style: SegmentedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                    Divider(height: 2, thickness: 2, color: scaffoldBgColor),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.refreshInterval),
                            Text(
                              l10n.seconds(_refreshInterval.toInt()),
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Slider(
                        // ignore: deprecated_member_use
                        year2023: false,
                        value: _refreshInterval,
                        min: 10,
                        max: 30,
                        divisions: 4,
                        onChanged: (value) {
                          setState(() => _refreshInterval = value);
                          _savePrefs('refreshInterval', value);
                        },
                      ),
                    ),
                    Divider(height: 2, thickness: 2, color: scaffoldBgColor),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      title: Text(l10n.resetData),
                      trailing: Text(
                        l10n.clearSettingsAndFavorites,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: _showResetDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  l10n.appearance,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: ThemeService.instance,
                builder: (context, _) {
                  final themeService = ThemeService.instance;

                  final bool dynamicSupported =
                      !kIsWeb && (Platform.isAndroid || Platform.isWindows);

                  return Material(
                    color: itemBgColor,
                    borderRadius: BorderRadius.circular(24),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(l10n.themeMode),
                                Text(
                                  themeService.themeMode == 'system'
                                      ? l10n.themeFollowSystem
                                      : themeService.themeMode == 'light'
                                      ? l10n.themeLightMode
                                      : themeService.themeMode == 'dark'
                                      ? l10n.themeDarkMode
                                      : l10n.themePureBlackDesc,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          subtitle: SegmentedButton<String>(
                            showSelectedIcon: false,
                            segments: [
                              ButtonSegment(
                                value: 'system',
                                label: Text(l10n.system),
                              ),
                              ButtonSegment(
                                value: 'light',
                                label: Text(l10n.light),
                              ),
                              ButtonSegment(
                                value: 'dark',
                                label: Text(l10n.dark),
                              ),
                            ],
                            selected: {themeService.themeMode},
                            onSelectionChanged: (Set<String> newSelection) {
                              themeService.setThemeMode(newSelection.first);
                            },
                            style: SegmentedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          child:
                              (themeService.themeMode == 'system' ||
                                  themeService.themeMode == 'dark')
                              ? Column(
                                  children: [
                                    Divider(
                                      height: 2,
                                      thickness: 2,
                                      color: scaffoldBgColor,
                                    ),
                                    SwitchListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 4,
                                          ),
                                      title: Text(l10n.pureBlackMode),
                                      subtitle: Text(l10n.pureBlackDesc),
                                      value: themeService.oledEnabled,
                                      onChanged: (bool value) {
                                        themeService.setOledEnabled(value);
                                      },
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                        if (dynamicSupported) ...[
                          Divider(
                            height: 2,
                            thickness: 2,
                            color: scaffoldBgColor,
                          ),
                          SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 4,
                            ),
                            title: Text(l10n.systemDynamicColor),
                            subtitle: Text(
                              kIsWeb
                                  ? l10n.dynamicColorWebDesc
                                  : Platform.isAndroid
                                  ? l10n.dynamicColorAndroidDesc
                                  : Platform.isWindows
                                  ? l10n.dynamicColorWindowsDesc
                                  : l10n.dynamicColorDefaultDesc,
                            ),
                            value: themeService.dynamicColorEnabled,
                            onChanged: (bool value) {
                              themeService.setDynamicColorEnabled(value);
                            },
                          ),
                        ],
                        if (!dynamicSupported ||
                            !themeService.dynamicColorEnabled) ...[
                          Divider(
                            height: 2,
                            thickness: 2,
                            color: scaffoldBgColor,
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(l10n.selectThemeColor),
                            ),
                            subtitle: SizedBox(
                              height: 48,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: ThemeService.presetColors.entries.map((
                                  entry,
                                ) {
                                  final colorName = entry.key;
                                  final color = entry.value;
                                  final isSelected =
                                      themeService.themeColorKey == colorName;

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: InkWell(
                                      onTap: () {
                                        themeService.setThemeColorKey(
                                          colorName,
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? (isDark
                                                      ? Colors.white
                                                      : Colors.black)
                                                : Colors.transparent,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.withValues(
                                                alpha: 0.4,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: isSelected
                                            ? Icon(
                                                Icons.check,
                                                color:
                                                    ThemeData.estimateBrightnessForColor(
                                                          color,
                                                        ) ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                                size: 20,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  l10n.about,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Material(
                color: itemBgColor,
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      title: Text(l10n.checkUpdate),
                      trailing: _isCheckingUpdate
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              appVersion,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                      onTap: _isCheckingUpdate ? null : _checkUpdate,
                    ),
                    Divider(height: 2, thickness: 2, color: scaffoldBgColor),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      title: Text(l10n.feedback),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.feedbackSubtitle,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.open_in_new,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      onTap: _sendFeedback,
                    ),
                    Divider(height: 2, thickness: 2, color: scaffoldBgColor),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      title: Text(l10n.openSourceLicenses),
                      trailing: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onTap: _showLicenses,
                    ),
                    Divider(height: 2, thickness: 2, color: scaffoldBgColor),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      title: Text(l10n.developer),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'wyrindev',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.open_in_new,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      onTap: () async {
                        final url = Uri.parse('https://github.com/wyrindev');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                    Divider(height: 2, thickness: 2, color: scaffoldBgColor),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      title: Text(l10n.dataSourceStatement),
                      trailing: Icon(
                        Icons.info_outline,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.dataSourceStatementTitle),
                            content: Text(l10n.dataSourceStatementContent),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.understand),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
