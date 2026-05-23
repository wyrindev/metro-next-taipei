import 'package:flutter/material.dart';
import 'package:metro_next_taipei/l10n/app_localizations.dart';
import 'package:metro_next_taipei/models/train_model.dart';
import 'package:metro_next_taipei/widgets/animated_gradient_border.dart';

class TrainCard extends StatelessWidget {
  final Train train;
  final AnimationController controller;

  const TrainCard({super.key, required this.train, required this.controller});

  bool get _isHighlight => train.remainingTime <= 35;

  @override
  Widget build(BuildContext context) {
    final baseSurface = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8);
    final l10n = AppLocalizations.of(context)!;

    final card = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _isHighlight ? Colors.transparent : train.lineColor.withValues(alpha: 0.3),
          width: 2.5,
        ),
      ),
      color: baseSurface,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(l10n.boundFor(train.getLocalizedDestination(context)))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedOpacity(
                  opacity: _isHighlight ? 1 : 0.6,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    constraints: const BoxConstraints(minWidth: 96),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isHighlight
                          ? train.lineColor.withValues(alpha: 0.15)
                          : baseSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      train.getLocalizedCountdown(context),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isHighlight
                            ? train.lineColor
                            : Theme.of(context).brightness ==
                                  Brightness.dark
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: AnimatedGradientBorder(
        color: train.lineColor,
        borderRadius: 12.0,
        thickness: 2.5,
        animate: _isHighlight,
        child: card,
      ),
    );
  }
}
