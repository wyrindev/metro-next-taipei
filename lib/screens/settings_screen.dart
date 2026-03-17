import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  static const String appVersion = 'v0.1.0-beta';
  String _language = 'zh';
  String _nearbyStations = 'auto'; // auto, manual, off
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'zh';
      _nearbyStations = prefs.getString('nearbyStations') ?? 'auto';
    });
  }

  Future<void> _savePrefs(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Widget _buildDialogTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Dialog _buildDialog({required String title, required List<Widget> children}) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTitle(title),
            const Divider(height: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    String tempLanguage = _language;
    showDialog(
      context: context,
      builder: (_) => _buildDialog(
        title: '語言',
        children: [
          StatefulBuilder(
            builder: (context, setStateDialog) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioGroup<String>(
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
                        title: const Text('中文'),
                      ),
                      // RadioListTile<String>(
                      //   value: 'en',
                      //   title: const Text('English'),
                      // ),
                      // TODO: 支援英語
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _language = tempLanguage);
                        _savePrefs('language', tempLanguage);
                        Navigator.pop(context);
                      },
                      child: const Text('確認'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNearbyStationsDialog() {
    String tempNearby = _nearbyStations;
    showDialog(
      context: context,
      builder: (_) => _buildDialog(
        title: '附近車站',
        children: [
          StatefulBuilder(
            builder: (context, setStateDialog) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioGroup<String>(
                  groupValue: tempNearby,
                  onChanged: (v) {
                    if (v != null) {
                      setStateDialog(() => tempNearby = v);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        value: 'auto',
                        title: const Text('開啟（自動）'),
                      ),
                      RadioListTile<String>(
                        value: 'manual',
                        title: const Text('手動執行'),
                      ),
                      RadioListTile<String>(
                        value: 'off',
                        title: const Text('關閉'),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _nearbyStations = tempNearby);
                        _savePrefs('nearbyStations', tempNearby);
                        Navigator.pop(context);
                      },
                      child: const Text('確認'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    bool resetFavorites = false;
    bool resetSettings = false;

    showDialog(
      context: context,
      builder: (_) => _buildDialog(
        title: '重設資料',
        children: [
          StatefulBuilder(
            builder: (context, setStateDialog) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('常用站點'),
                  value: resetFavorites,
                  onChanged: (v) => setStateDialog(() => resetFavorites = v!),
                ),
                CheckboxListTile(
                  title: const Text('設定'),
                  value: resetSettings,
                  onChanged: (v) => setStateDialog(() => resetSettings = v!),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  if (resetFavorites) await prefs.remove('favorites');
                  if (resetSettings) await prefs.clear();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('資料已重設')));
                    await _loadPrefs();
                  }
                },
                child: const Text('確認'),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _checkUpdate() async {
    setState(() => _isCheckingUpdate = true);
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/docker/compose/releases/latest'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String latestVersion = data['tag_name'];

        if (mounted) {
          if (latestVersion != appVersion) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('有新版本可用'),
                content: Text('發現新版本 $latestVersion\n目前版本 $appVersion\n\n是否前往下載？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('稍後'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final url = Uri.parse(
                        'https://github.com/wyrindev/metro-next-taipei/releases',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: const Text('立即下載'),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('目前已是最新版本')),
            );
          }
        }
      } else {
        throw Exception('無法取得版本資訊');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('檢查更新失敗: $e')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('一般', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('語言'),
            // subtitle: Text(_language == 'zh' ? '中文' : 'English'),
            subtitle: Text('中文'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLanguageDialog,
          ),
          ListTile(
            title: const Text('附近車站'),
            subtitle: Text(
              {
                'auto': '開啟（自動）',
                'manual': '手動執行',
                'off': '關閉',
              }[_nearbyStations]!,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showNearbyStationsDialog,
          ),
          ListTile(
            title: const Text('重設資料'),
            trailing: const Icon(Icons.refresh),
            onTap: _showResetDialog,
          ),
          const Divider(),
          const ListTile(
            title: Text('關於', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('檢查更新'),
            subtitle: _isCheckingUpdate ? const Text('正在檢查更新...') : null,
            trailing: _isCheckingUpdate
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.system_update),
            onTap: _isCheckingUpdate ? null : _checkUpdate,
          ),
          ListTile(
            title: const Text('意見反映'),
            trailing: const Icon(Icons.feedback),
            onTap: _sendFeedback,
          ),
          ListTile(
            title: const Text('開放原始碼授權'),
            trailing: const Icon(Icons.article),
            onTap: _showLicenses,
          ),
        ],
      ),
    );
  }
}
