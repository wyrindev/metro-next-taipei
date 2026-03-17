import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:metro_next_taipei/screens/common_station_detail.dart';
import 'package:metro_next_taipei/screens/settings_screen.dart';
import 'package:metro_next_taipei/widgets/nearest_station_card.dart';
import 'package:metro_next_taipei/services/location.dart';
import 'package:metro_next_taipei/services/database.dart';
import 'package:metro_next_taipei/screens/common_station_editor.dart';

class MetroDashboard extends StatefulWidget {
  const MetroDashboard({super.key});

  @override
  State<MetroDashboard> createState() => _MetroDashboardState();
}

class _MetroDashboardState extends State<MetroDashboard> {
  bool _initialLoading = true;
  bool _nearbyLoading = false;
  Map<String, bool> _favoriteMap = {};
  List<Map<String, dynamic>> _nearestOne = [];
  Timer? _countdownTimer;
  Timer? _nearestApiTimer;
  Position? _currentPosition;
  String _nearbySetting = 'auto';
  double? _trainCardHeight;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    await _loadFavorites();
    setState(() {
      _trainCardHeight = double.tryParse(
        prefs.getString('trainCardHeight').toString(),
      );
    });

    setState(() {
      _initialLoading = false;
    });

    if (_nearbySetting == 'auto') {
      unawaited(_initNearbyStations());
    }
  }

  Future<void> _initNearbyStations() async {
    setState(() => _nearbyLoading = true);
    _currentPosition = await getCurrentPosition(context);

    if (_currentPosition != null) {
      await _updateNearestStation();
      _setupTimers();
    }

    if (mounted) {
      setState(() => _nearbyLoading = false);
    }
  }

  Future<void> _loadSettings() async {
    _nearbySetting = prefs.getString('nearbyStations') ?? 'auto';
  }

  Future<void> _loadFavorites() async {
    final items = prefs.getStringList('commonStations') ?? [];
    setState(() {
      _favoriteMap = {for (var s in items) s: true};
    });
  }

  void _setupTimers() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
    _nearestApiTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _updateNearestStation();
    });
  }

  Future<void> _updateNearestStation() async {
    if (_nearbySetting == 'off') return;
    if (_currentPosition == null) return;

    final stations = await findNearestStations(
      'assets/taipei_metro_db.json',
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      count: 1,
    );

    if (mounted) {
      setState(() {
        _nearestOne = stations;
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _nearestApiTimer?.cancel();
    super.dispose();
  }

  void _openCommonEditor() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CommonStationsEditor()),
    );
    await _loadFavorites();
  }

  void _openAppSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AppSettingsScreen()),
    );

    await _loadSettings();

    if (_nearbySetting == 'auto' && mounted) {
      _setupTimers();
      _currentPosition ??= await getCurrentPosition(context);
      await _updateNearestStation();
    } else {
      _countdownTimer?.cancel();
      _nearestApiTimer?.cancel();
      if (_nearbySetting == 'off') {
        setState(() => _nearestOne = []);
      }
    }
  }

  Future<void> _confirmDeleteStation(String key) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除常用站點'),
        content: Text('確定要刪除「$key」嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('刪除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _favoriteMap.remove(key);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('commonStations', _favoriteMap.keys.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('MetroNext'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _openCommonEditor,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _openAppSettings,
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MetroNext'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openCommonEditor,
            tooltip: '編輯常用車站',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openAppSettings,
            tooltip: '開啟設定',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_nearbySetting == 'manual') {
            _currentPosition = await getCurrentPosition(context);
            await _updateNearestStation();
          }
          return Future.value();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            final favoriteSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_favoriteMap.isNotEmpty) ...[
                  const Text(
                    '常用站點',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._favoriteMap.keys.map(
                    (key) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(key),
                        leading: const Icon(Icons.train),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            showDragHandle: false,
                            builder: (context) {
                              final destinationsCount =
                                  metroDb[key.split(
                                    ' ',
                                  )[1]]["unique_destinations_count"];
                              final screenHeight = MediaQuery.of(
                                context,
                              ).size.height;

                              final double initialSize =
                                  _trainCardHeight != null
                                  ? (_trainCardHeight! *
                                            (destinationsCount + 1.6)) /
                                        screenHeight
                                  : (double.tryParse(
                                          prefs.getString('trainCardHeight') ??
                                              '0.4',
                                        ) ??
                                        0.4);

                              final safeInitialSize = initialSize.clamp(
                                0.2,
                                1.0,
                              );

                              return DraggableScrollableSheet(
                                expand: false,
                                initialChildSize: safeInitialSize >= 0.9
                                    ? 1.0
                                    : safeInitialSize,
                                minChildSize: 0.2,
                                maxChildSize: 1.0,
                                builder: (context, scrollController) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: safeInitialSize >= 0.9
                                          ? BorderRadius.zero
                                          : const BorderRadius.vertical(
                                              top: Radius.circular(25),
                                            ),
                                    ),
                                    child: CommonStationDetailSheet(
                                      stationKey: key,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        onLongPress: () => _confirmDeleteStation(key),
                      ),
                    ),
                  ),
                ],
              ],
            );
            final nearbySection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_nearbySetting != 'off') ...[
                  const Text(
                    '附近車站',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_nearbyLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_nearestOne.isEmpty)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('目前無列車資訊'),
                      ),
                    )
                  else
                    NearestStationCard(
                      stationName: _nearestOne[0]['station'],
                      stnId: _nearestOne[0]['id'],
                      onTrainCardHeight: (height) async {
                        if (_trainCardHeight != height) {
                          setState(() => _trainCardHeight = height);
                        }
                        if (_trainCardHeight! > 0) {
                          await prefs.setString(
                            'trainCardHeight',
                            _trainCardHeight.toString(),
                          );
                        }
                      },
                    ),
                ],
              ],
            );

            if (!isWide) {
              return ListView(
                padding: const EdgeInsets.all(12),
                children: [favoriteSection, const Divider(), nearbySection],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: favoriteSection,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: nearbySection,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
