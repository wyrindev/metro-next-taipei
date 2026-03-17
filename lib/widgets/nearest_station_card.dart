import 'package:flutter/material.dart';
import 'dart:async';
import 'package:metro_next_taipei/models/train.dart';
import 'package:metro_next_taipei/widgets/train_list.dart';
import 'package:metro_next_taipei/services/get_countdown.dart';

class NearestStationCard extends StatefulWidget {
  final String stationName;
  final String stnId;
  final void Function(double)? onTrainCardHeight;

  const NearestStationCard({
    super.key,
    required this.stationName,
    required this.stnId,
    this.onTrainCardHeight,
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
  void didUpdateWidget(covariant NearestStationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stnId != widget.stnId) {
      _apiTimer?.cancel();
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.stationName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isRefreshing ? null : _fetchTrains,
                  tooltip: '刷新此站',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading && _bestTrains.isEmpty)
              const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_bestTrains.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('目前無列車資訊'),
              )
            else ...[
              if (_isFromCache)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '無法取得即時資訊，目前顯示快取資料。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
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
    );
  }
}
