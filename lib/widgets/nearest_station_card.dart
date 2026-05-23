import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metro_next_taipei/l10n/app_localizations.dart';
import 'package:metro_next_taipei/models/train_model.dart';
import 'package:metro_next_taipei/services/api_service.dart';
import 'package:metro_next_taipei/widgets/train_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NearestStationCard extends StatefulWidget {
  final String stationName;
  final String stnId; // Can be empty if loading location
  final void Function(double)? onTrainCardHeight;
  final VoidCallback? onRefreshLocation;
  final bool isPermissionDenied;
  final bool isLocating;

  const NearestStationCard({
    super.key,
    required this.stationName,
    required this.stnId,
    this.onTrainCardHeight,
    this.onRefreshLocation,
    this.isPermissionDenied = false,
    this.isLocating = false,
  });

  @override
  State<NearestStationCard> createState() => _NearestStationCardState();
}

class _NearestStationCardState extends State<NearestStationCard>
    with WidgetsBindingObserver {
  Map<String, Train> _bestTrains = {};
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
    if (widget.stnId.isNotEmpty && _cache.containsKey(widget.stnId)) {
      _bestTrains = _cache[widget.stnId]!;
      _loading = false;
    }
    _fetchTrains();
    _startTimers();
  }

  void _startTimers() async {
    _apiTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    final interval = prefs.getDouble('refreshInterval') ?? 10.0;
    _apiTimer = Timer.periodic(Duration(seconds: interval.toInt()), (_) {
      if (mounted && _isResumed) {
        _fetchTrains();
      }
    });
  }

  @override
  void didUpdateWidget(covariant NearestStationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stnId != widget.stnId) {
      _apiTimer?.cancel();
      if (widget.stnId.isNotEmpty) {
        if (_cache.containsKey(widget.stnId)) {
          setState(() {
            _bestTrains = _cache[widget.stnId]!;
            _loading = false;
          });
        } else {
          setState(() {
            _bestTrains = {};
            _loading = true;
          });
        }
      }
      _fetchTrains();
      _startTimers();
    }
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

  Future<void> _fetchTrains() async {
    if (!mounted) return;
    if (widget.stnId.isEmpty) return;

    if (_cache.containsKey(widget.stnId)) {
      setState(() {
        _bestTrains = _cache[widget.stnId]!;
        _loading = false;
      });
    }

    setState(() => _isRefreshing = true);

    try {
      final fresh = await cd(widget.stnId);
      if (fresh != null && fresh.isNotEmpty) {
        _cache[widget.stnId] = fresh;
        if (mounted) {
          setState(() {
            _isFromCache = false;
            _bestTrains = fresh;
          });
        }
      } else {
        throw Exception("Empty data");
      }
    } catch (_) {
      if (mounted && _cache.containsKey(widget.stnId)) {
        setState(() {
          _isFromCache = true;
          _bestTrains = _cache[widget.stnId]!;
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                LocatingPulseIcon(
                  isLocating: widget.isLocating,
                  onTap: widget.onRefreshLocation,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.nearestStationTitle,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.stationName,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.stnId.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    color: colorScheme.primary,
                    onPressed: _isRefreshing ? null : _fetchTrains,
                    tooltip: l10n.refreshStationTooltip,
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.stnId.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            if (widget.isPermissionDenied) ...[
                              if (kIsWeb)
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: l10n.webPermissionInstructionStart),
                                      WidgetSpan(
                                        child: Icon(
                                          Icons.location_off,
                                          size: 18,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        alignment: PlaceholderAlignment.middle,
                                      ),
                                      TextSpan(
                                        text: l10n.webPermissionInstructionMiddle,
                                      ),
                                      WidgetSpan(
                                        child: Icon(
                                          Icons.near_me,
                                          size: 18,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        alignment: PlaceholderAlignment.middle,
                                      ),
                                      TextSpan(text: l10n.webPermissionInstructionEnd),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                )
                              else
                                Text(
                                  l10n.locationPermissionRequiredPrompt,
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              if (!kIsWeb) ...[
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: () => openAppSettings(),
                                  icon: const Icon(Icons.settings, size: 18),
                                  label: Text(l10n.openSettingsButton),
                                ),
                              ],
                            ] else if (widget.isLocating) ...[
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.locatingProgress,
                                textAlign: TextAlign.center,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                              ),
                            ] else ...[
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(text: l10n.notLocatingYetPromptStart),
                                    WidgetSpan(
                                      child: Icon(
                                        Icons.near_me,
                                        size: 18,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      alignment: PlaceholderAlignment.middle,
                                    ),
                                    TextSpan(text: l10n.notLocatingYetPromptEnd),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else if (_loading && _bestTrains.isEmpty)
                      const SizedBox(
                        height: 56,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_bestTrains.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Text(
                              l10n.noTrainsInfo,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.noTrainsInfoManualPrompt,
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      if (_isFromCache)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.cloud_off,
                                size: 16,
                                color: Colors.orange[800],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.offlineCacheWarning,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.orange[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      TrainList(
                        trains: _bestTrains,
                        onTrainCardHeight: (height) {
                          widget.onTrainCardHeight?.call(height);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LocatingPulseIcon extends StatefulWidget {
  final bool isLocating;
  final VoidCallback? onTap;
  const LocatingPulseIcon({super.key, required this.isLocating, this.onTap});

  @override
  State<LocatingPulseIcon> createState() => _LocatingPulseIconState();
}

class _LocatingPulseIconState extends State<LocatingPulseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isLocating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LocatingPulseIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLocating != oldWidget.isLocating) {
      if (widget.isLocating) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.animateTo(0, duration: const Duration(milliseconds: 300));
      }
    }
  }

  double _getHeartbeatScale(double t) {
    if (t < 0.15) {
      return 1.0 + (t / 0.15) * 0.18; // First thump (up to 1.18)
    }
    if (t < 0.30) {
      return 1.18 - ((t - 0.15) / 0.15) * 0.10; // First fall (down to 1.08)
    }
    if (t < 0.45) {
      return 1.08 + ((t - 0.30) / 0.15) * 0.17; // Second thump (up to 1.25)
    }
    if (t < 0.70) {
      return 1.25 - ((t - 0.45) / 0.25) * 0.25; // Second fall (down to 1.00)
    }
    return 1.0; // Rest phase
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: '重新定位',
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 44,
          height: 44,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final pulseValue = _controller.value;

              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (_controller.value > 0.01) ...[
                    Opacity(
                      opacity: (0.4 * (1.0 - pulseValue) * _controller.value)
                          .clamp(0.0, 1.0),
                      child: Container(
                        width: 44 + (pulseValue * 28),
                        height: 44 + (pulseValue * 28),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity:
                          (0.2 *
                                  (1.0 - ((pulseValue + 0.5) % 1.0)) *
                                  _controller.value)
                              .clamp(0.0, 1.0),
                      child: Container(
                        width: 44 + (((pulseValue + 0.5) % 1.0) * 28),
                        height: 44 + (((pulseValue + 0.5) % 1.0) * 28),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                  Transform.scale(
                    scale: _getHeartbeatScale(pulseValue),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.near_me,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
