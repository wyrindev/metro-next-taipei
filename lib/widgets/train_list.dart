import 'package:flutter/material.dart';
import 'package:metro_next_taipei/models/train.dart';
import 'package:metro_next_taipei/widgets/train_card.dart';

class TrainList extends StatefulWidget {
  final Map<String, Train> trains;
  final void Function(double)? onTrainCardHeight;

  const TrainList({super.key, required this.trains, this.onTrainCardHeight});

  @override
  State<TrainList> createState() => _TrainListState();
}

class _TrainListState extends State<TrainList>
    with SingleTickerProviderStateMixin {
  late AnimationController _sharedController;

  @override
  void initState() {
    super.initState();
    _sharedController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sharedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trains = widget.trains.values.toList();

    return Column(
      children: [
        for (int i = 0; i < trains.length; i++)
          MeasureSize(
            onChange: (size) {
              if (i == 0 && widget.onTrainCardHeight != null) {
                widget.onTrainCardHeight!(size.height);
              }
            },
            child: TrainCard(train: trains[i], controller: _sharedController),
          ),
      ],
    );
  }
}

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSize extends StatefulWidget {
  final Widget child;
  final OnWidgetSizeChange onChange;

  const MeasureSize({super.key, required this.onChange, required this.child});

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  final _widgetKey = GlobalKey();
  Size? oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return Container(key: _widgetKey, child: widget.child);
  }

  void _notifySize() {
    final context = _widgetKey.currentContext;
    if (context == null) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Size newSize = box.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    widget.onChange(newSize);
  }
}
