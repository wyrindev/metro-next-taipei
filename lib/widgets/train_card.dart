import 'package:flutter/material.dart';
import 'package:metro_next_taipei/models/train.dart';

class TrainCard extends StatelessWidget {
  final Train train;
  final AnimationController controller;

  const TrainCard({
    super.key,
    required this.train,
    required this.controller,
  });

  bool get _isHighlight =>
      train.displayCountdown == "即將進站" ||
      train.displayCountdown == "已到站";
  // TODO: 檢查站點對應路線是否為終點站讓其顯示"即將發車"與"已離站"

  @override
  Widget build(BuildContext context) {
    final colorTween = ColorTween(
      begin: train.lineColor.withValues(alpha: .3),
      end: train.lineColor,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    final baseSurface = Theme.of(context)
        .colorScheme
        .surfaceContainerHighest
        .withValues(alpha: 0.8);

    return AnimatedBuilder(
      animation: colorTween,
      builder: (context, _) {
        final borderClr =
            _isHighlight ? colorTween.value ?? train.lineColor : train.lineColor.withValues(alpha: 0.3);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderClr, width: 2.5),
          ),
          color: baseSurface,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('往 ${train.destination}')),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedOpacity(
                      opacity: _isHighlight ? 1 : 0.6,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 80,
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _isHighlight
                              ? train.lineColor.withValues(alpha: 0.15)
                              : baseSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          train.displayCountdown,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isHighlight
                                ? train.lineColor
                                : Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
