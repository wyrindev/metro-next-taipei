import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metro_next_taipei/l10n/app_localizations.dart';
import 'package:metro_next_taipei/services/database_service.dart';
import 'package:metro_next_taipei/utils/line_data.dart';
import 'package:metro_next_taipei/screens/station_detail_screen.dart';
import 'package:metro_next_taipei/services/locale_service.dart';

class StationsOverviewScreen extends StatefulWidget {
  const StationsOverviewScreen({super.key});

  @override
  State<StationsOverviewScreen> createState() => _StationsOverviewScreenState();
}

class _StationsOverviewScreenState extends State<StationsOverviewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _search = TextEditingController();
  String _searchQuery = '';
  Set<String> _favoriteStations = {};
  
  // Pre-computed lists to prevent lag during tab switching
  late Map<String, List<Map<String, String>>> _stationsByLine;
  late List<Map<String, String>> _allStations;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: taipeiMetroLines.length, vsync: this);
    _search.addListener(() {
      setState(() {
        _searchQuery = _search.text.trim();
      });
    });
    _precomputeStations();
    _loadFavorites();
  }

  void _precomputeStations() {
    _stationsByLine = {};
    _allStations = [];
    
    for (var line in taipeiMetroLines) {
      _stationsByLine[line.id] = [];
    }

    metroDb.forEach((key, info) {
      final ids = (info['Services']?['StationIDs'] as List?)?.join('/') ?? '';
      final stationNameZh = info['Station']?.toString() ?? key;
      final stationNameEn = info['StationEn']?.toString() ?? stationNameZh;
      final idDisplay = ids.isNotEmpty ? ids : '';
      
      final stationObj = {
        'id': idDisplay,
        'nameZh': stationNameZh,
        'nameEn': stationNameEn,
        'key': key,
      };
      _allStations.add(stationObj);
      
      for (var line in taipeiMetroLines) {
        if (ids.split('/').any((id) => id.startsWith(line.id))) {
          _stationsByLine[line.id]!.add(stationObj);
        }
      }
    });

    for (var line in taipeiMetroLines) {
      _stationsByLine[line.id]!.sort((a, b) => a['id']!.compareTo(b['id']!));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('commonStations') ?? [];
    setState(() {
      _favoriteStations = items.toSet();
    });
  }

  Future<void> _toggleFavorite(String stationKey) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteStations.contains(stationKey)) {
        _favoriteStations.remove(stationKey);
      } else {
        _favoriteStations.add(stationKey);
      }
    });
    await prefs.setStringList('commonStations', _favoriteStations.toList());
  }

  void _openStationDetail(String stationKey) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.2,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: CommonStationDetailSheet(stationKey: stationKey),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnglish = LocaleService.instance.currentLocale.languageCode == 'en';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: AppLocalizations.of(context)!.searchStationHint,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: taipeiMetroLines.map((line) {
            return Tab(
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: line.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEnglish ? line.id : line.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: taipeiMetroLines.map((line) {
              var filtered = _stationsByLine[line.id]!;
              
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                filtered = filtered.where((s) {
                  return s['id']!.toLowerCase().contains(query) ||
                      s['nameZh']!.toLowerCase().contains(query) ||
                      s['nameEn']!.toLowerCase().contains(query);
                }).toList();
              }

              List<Map<String, String>> otherMatches = [];
              if (_searchQuery.isNotEmpty && filtered.length < 6) {
                final Set<String> filteredKeys = filtered.map((s) => s['key']!).toSet();
                final query = _searchQuery.toLowerCase();
                otherMatches = _allStations.where((s) {
                  final matches = s['id']!.toLowerCase().contains(query) ||
                      s['nameZh']!.toLowerCase().contains(query) ||
                      s['nameEn']!.toLowerCase().contains(query);
                  if (!matches) return false;
                  return !filteredKeys.contains(s['key']!);
                }).toList();
                
                final Set<String> seenKeys = {};
                otherMatches = otherMatches.where((s) => seenKeys.add(s['key']!)).toList();
              }

              final bool hasOtherMatches = otherMatches.isNotEmpty;
              final int mainCount = filtered.length;
              final int totalCount = mainCount + (hasOtherMatches ? 1 + otherMatches.length : 0);

              if (totalCount == 0) {
                return Center(child: Text(AppLocalizations.of(context)!.noData));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                itemCount: totalCount,
                itemBuilder: (context, index) {
                  if (hasOtherMatches && index == mainCount) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              AppLocalizations.of(context)!.resultsFromOtherLines,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
                        ],
                      ),
                    );
                  }

                  final bool isOther = hasOtherMatches && index > mainCount;
                  final s = isOther ? otherMatches[index - mainCount - 1] : filtered[index];
                  final idDisplay = s['id'] ?? '';
                  final nameZh = s['nameZh'] ?? '';
                  final nameEn = s['nameEn'] ?? nameZh;
                  final name = isEnglish ? nameEn : nameZh;
                  final stationKey = (idDisplay.isNotEmpty ? '$idDisplay $nameZh' : nameZh);
                  final isFavorite = _favoriteStations.contains(stationKey);

                  final String badgeId;
                  final Color badgeColor;

                  if (!isOther) {
                    badgeColor = line.color;
                    badgeId = idDisplay.split('/').firstWhere(
                      (id) => id.startsWith(line.id),
                      orElse: () => idDisplay.split('/').first,
                    );
                  } else {
                    final String firstId = idDisplay.split('/').first;
                    final match = RegExp(r'^[A-Za-z]+').firstMatch(firstId);
                    final otherLineId = match?.group(0) ?? '';
                    badgeColor = getLineColor(otherLineId);
                    badgeId = firstId;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    color: colorScheme.surfaceContainer,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeId,
                          style: TextStyle(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? Colors.amber : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        onPressed: () => _toggleFavorite(stationKey),
                        tooltip: isFavorite ? AppLocalizations.of(context)!.removeFromFavorites : AppLocalizations.of(context)!.addToFavorites,
                      ),
                      onTap: () => _openStationDetail(stationKey),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
