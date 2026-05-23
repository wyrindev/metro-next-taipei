import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metro_next_taipei/l10n/app_localizations.dart';
import 'package:metro_next_taipei/screens/station_detail_screen.dart';
import 'package:metro_next_taipei/screens/settings_screen.dart';
import 'package:metro_next_taipei/widgets/nearest_station_card.dart';
import 'package:metro_next_taipei/services/location_service.dart';
import 'package:metro_next_taipei/services/database_service.dart';
import 'package:metro_next_taipei/screens/stations_overview_screen.dart';
import 'package:metro_next_taipei/services/theme_service.dart';
import 'package:metro_next_taipei/services/locale_service.dart';

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
  LocationResult? _locationResult;
  String _nearbySetting = 'auto';
  double? _trainCardHeight;
  double _refreshInterval = 10.0;
  int _selectedIndex = 0;
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
      _initialLoading = false;
    });

    if (_nearbySetting == 'auto') {
      unawaited(_initNearbyStations());
    }
  }

  Future<void> _initNearbyStations() async {
    setState(() => _nearbyLoading = true);
    _locationResult = await getCurrentPosition(context);

    if (_locationResult?.position != null) {
      await _updateNearestStation();
      _setupTimers();
    }

    if (mounted) {
      setState(() => _nearbyLoading = false);
    }
  }

  Future<void> _loadSettings() async {
    _nearbySetting = prefs.getString('nearbyStations') ?? 'auto';
    _refreshInterval = prefs.getDouble('refreshInterval') ?? 10.0;
  }

  Future<void> _loadFavorites() async {
    final items = prefs.getStringList('commonStations') ?? [];
    setState(() {
      _favoriteMap = {for (var s in items) s: true};
    });
  }

  void _setupTimers() {
    _countdownTimer?.cancel();
    _nearestApiTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
    _nearestApiTimer = Timer.periodic(Duration(seconds: _refreshInterval.toInt()), (_) async {
      await _updateNearestStation();
    });
  }

  Future<void> _updateNearestStation() async {
    if (_nearbySetting == 'off') return;
    if (_locationResult?.position == null) return;

    final stations = await findNearestStations(
      'assets/taipei_metro_db.json',
      _locationResult!.position!.latitude,
      _locationResult!.position!.longitude,
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

  void _onTabChanged(int idx) {
    setState(() => _selectedIndex = idx);
    if (idx == 0) {
      _loadFavorites();
      _loadSettings().then((_) {
        if (_nearbySetting == 'off') {
          _countdownTimer?.cancel();
          _nearestApiTimer?.cancel();
          _countdownTimer = null;
          _nearestApiTimer = null;
          if (mounted) {
            setState(() => _nearestOne = []);
          }
        } else if (_nearbySetting == 'auto') {
          if (_countdownTimer == null) {
            if (mounted) {
              _setupTimers();
              unawaited(_initNearbyStations());
            }
          }
        }
      });
    }
  }

  Future<void> _confirmDeleteStation(String key) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteFavoriteStationTitle),
        content: Text(l10n.deleteFavoriteStationConfirm(key)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
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
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor = isDark
        ? (ThemeService.instance.oledEnabled ? Colors.black : colorScheme.surface)
        : colorScheme.surfaceContainerLowest;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    final Widget bodyContent = IndexedStack(
      index: _selectedIndex,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth >= 600;
            final hasFavorites = _favoriteMap.isNotEmpty;
            final hasNearby = _nearbySetting != 'off';

            final favoriteSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_favoriteMap.isNotEmpty) ...[
                  Text(
                    AppLocalizations.of(context)!.commonStations,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._favoriteMap.keys.map(
                    (key) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(() {
                          final isEnglish = LocaleService.instance.currentLocale.languageCode == 'en';
                          final parts = key.split(' ');
                          if (parts.length >= 2) {
                            final id = parts[0];
                            final nameZh = parts[1];
                            final nameEn = metroDb[nameZh]?['StationEn'] ?? nameZh;
                            return isEnglish ? "$id $nameEn" : key;
                          }
                          return key;
                        }()),
                        leading: const Icon(Icons.train),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            showDragHandle: false,
                            builder: (context) {
                              final destinationsCount =
                                  metroDb[key.split(' ')[1]]["unique_destinations_count"];
                              final screenHeight = MediaQuery.of(context).size.height;

                              final double initialSize = _trainCardHeight != null
                                  ? (_trainCardHeight! * (destinationsCount + 1.6)) / screenHeight
                                  : (double.tryParse(
                                          prefs.getString('trainCardHeight') ?? '0.4') ??
                                      0.4);

                              final safeInitialSize = initialSize.clamp(0.2, 1.0);

                              return DraggableScrollableSheet(
                                expand: false,
                                initialChildSize: safeInitialSize >= 0.9 ? 1.0 : safeInitialSize,
                                minChildSize: 0.2,
                                maxChildSize: 1.0,
                                builder: (context, scrollController) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
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
                  if (_nearestOne.isNotEmpty)
                    NearestStationCard(
                      stationName: LocaleService.instance.currentLocale.languageCode == 'en'
                          ? (_nearestOne[0]['raw']?['StationEn'] ?? _nearestOne[0]['station'])
                          : _nearestOne[0]['station'],
                      stnId: _nearestOne[0]['id'],
                      isLocating: _nearbyLoading,
                      onRefreshLocation: _initNearbyStations,
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
                    )
                  else if (_nearbyLoading)
                    NearestStationCard(
                      stationName: AppLocalizations.of(context)!.locatingLabel,
                      stnId: '',
                      isLocating: true,
                      onRefreshLocation: _initNearbyStations,
                    )
                  else if (_locationResult?.permissionDenied == true)
                    NearestStationCard(
                      stationName: AppLocalizations.of(context)!.locationPermissionDenied,
                      stnId: '',
                      onRefreshLocation: _initNearbyStations,
                      isPermissionDenied: true,
                    )
                  else
                    NearestStationCard(
                      stationName: AppLocalizations.of(context)!.notLocatedYetLabel,
                      stnId: '',
                      onRefreshLocation: _initNearbyStations,
                    ),
                ],
              ],
            );

            // Narrow Viewport: Stack vertically
            if (!isWideScreen) {
              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (hasFavorites) ...[
                    favoriteSection,
                    const SizedBox(height: 16),
                  ],
                  if (hasNearby) nearbySection,
                ],
              );
            }

            // Wide Viewport: Side-by-side if both sections exist, else centered column
            if (hasFavorites && hasNearby) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: favoriteSection,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: nearbySection,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (hasFavorites) favoriteSection,
                      if (hasNearby) nearbySection,
                    ],
                  ),
                ),
              );
            }
          },
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const StationsOverviewScreen(),
          ),
        ),
        const AppSettingsScreen(),
      ],
    );

    final Widget mainBody;
    final l10n = AppLocalizations.of(context)!;
    if (isWide) {
      mainBody = Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onTabChanged,
            labelType: NavigationRailLabelType.all,
            backgroundColor: scaffoldBgColor,
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: Text(l10n.home),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.map_outlined),
                selectedIcon: const Icon(Icons.map),
                label: Text(l10n.stations),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: Text(l10n.settings),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: bodyContent,
          ),
        ],
      );
    } else {
      mainBody = bodyContent;
    }

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        scrolledUnderElevation: 0,
        title: Text(
          _selectedIndex == 0
              ? 'MetroNext'
              : _selectedIndex == 1
                  ? l10n.stations
                  : l10n.settings,
        ),
      ),
      body: mainBody,
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onTabChanged,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: l10n.home,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.map_outlined),
                  selectedIcon: const Icon(Icons.map),
                  label: l10n.stations,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: l10n.settings,
                ),
              ],
            ),
    );
  }
}
