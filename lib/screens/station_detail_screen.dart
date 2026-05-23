import 'dart:async';
import 'package:flutter/material.dart';
import 'package:metro_next_taipei/l10n/app_localizations.dart';
import 'package:metro_next_taipei/models/train_model.dart';
import 'package:metro_next_taipei/widgets/train_list.dart';
import 'package:metro_next_taipei/services/api_service.dart';
import 'package:metro_next_taipei/services/database_service.dart';
import 'package:metro_next_taipei/services/locale_service.dart';

class CommonStationDetailSheet extends StatefulWidget {
  final String stationKey;
  const CommonStationDetailSheet({super.key, required this.stationKey});

  @override
  State<CommonStationDetailSheet> createState() =>
      _CommonStationDetailSheetState();
}

class _CommonStationDetailSheetState extends State<CommonStationDetailSheet>
    with WidgetsBindingObserver {
  Map<String, Train> _allTrains = {};
  bool _loading = true;
  bool _isFromCache = false;
  bool _isRefreshing = false;
  bool _isResumed = true;
  Timer? _apiTimer;

  static final Map<String, Map<String, Train>> _cache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.stationKey.isNotEmpty && _cache.containsKey(widget.stationKey)) {
      _allTrains = _cache[widget.stationKey]!;
      _loading = false;
    }
    _fetchTrains();
    _startTimers();
  }

  void _startTimers() {
    _apiTimer?.cancel();
    _apiTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted && _isResumed) {
        _fetchTrains();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      setState(() => _isResumed = true);
      _fetchTrains();
    } else if (state == AppLifecycleState.paused) {
      setState(() => _isResumed = false);
    }
  }

  @override
  void didUpdateWidget(covariant CommonStationDetailSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stationKey != widget.stationKey) {
      _apiTimer?.cancel();
      if (widget.stationKey.isNotEmpty) {
        if (_cache.containsKey(widget.stationKey)) {
          setState(() {
            _allTrains = _cache[widget.stationKey]!;
            _loading = false;
          });
        } else {
          setState(() {
            _allTrains = {};
            _loading = true;
          });
        }
      }
      _fetchTrains();
      _startTimers();
    }
  }

  Future<void> _fetchTrains() async {
    if (!mounted) return;
    if (widget.stationKey.isNotEmpty && _cache.containsKey(widget.stationKey)) {
      setState(() {
        _allTrains = _cache[widget.stationKey]!;
        _loading = false;
      });
    }
    setState(() => _isRefreshing = true);

    try {
      final parts = widget.stationKey.split(' ');
      if (parts.length < 2) throw Exception("Invalid station key");

      final stationName = parts[1];
      final stationData = metroDb[stationName];

      if (stationData == null) throw Exception("No station data");

      final apiIds =
          (stationData['ApiStnIds'] as List?)
              ?.map((e) => e.toString())
              .where((s) => s.isNotEmpty)
              .toList() ??
          [];

      if (apiIds.isEmpty) throw Exception("No API IDs");

      final results = await Future.wait(
        apiIds.map((id) async {
          try {
            final data = await cd(id);
            return data ?? <String, Train>{};
          } catch (_) {
            return <String, Train>{};
          }
        }),
      );

      final Map<String, Train> combined = {};
      for (final res in results) {
        for (final entry in res.entries) {
          final dest = entry.key;
          final train = entry.value;
          if (!combined.containsKey(dest) ||
              train.baseRemainingSeconds <
                  combined[dest]!.baseRemainingSeconds) {
            combined[dest] = train;
          }
        }
      }

      if (combined.isNotEmpty) {
        _cache[widget.stationKey] = combined;
        if (mounted) {
          setState(() {
            _isFromCache = false;
            _allTrains = combined;
          });
        }
      } else {
        throw Exception("Empty data");
      }
    } catch (_) {
      if (mounted && _cache.containsKey(widget.stationKey)) {
        setState(() {
          _isFromCache = true;
          _allTrains = _cache[widget.stationKey]!;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _apiTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      (() {
                        final isEnglish = LocaleService.instance.currentLocale.languageCode == 'en';
                        final parts = widget.stationKey.split(' ');
                        if (parts.length >= 2) {
                          final id = parts[0];
                          final nameZh = parts[1];
                          final nameEn = metroDb[nameZh]?['StationEn'] ?? nameZh;
                          return isEnglish ? "$id $nameEn" : widget.stationKey;
                        }
                        return widget.stationKey;
                      }()),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: AppLocalizations.of(context)!.refreshStationTooltip,
                    onPressed: _isRefreshing ? null : _fetchTrains,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: _loading && _allTrains.isEmpty
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _allTrains.isEmpty
                      ? SizedBox(
                          height: 200,
                          child: Center(child: Text(AppLocalizations.of(context)!.noTrainsInfo)),
                        )
                      : ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(12),
                          children: [
                            if (_isFromCache)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
                                child: Text(
                                  AppLocalizations.of(context)!.offlineCacheWarning,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            TrainList(trains: _allTrains),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
