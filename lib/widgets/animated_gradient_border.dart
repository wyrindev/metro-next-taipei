import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final Color color;
  final double thickness;
  final double borderRadius;
  final bool animate;
  final Duration duration;
  final AnimationController? controller;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    required this.color,
    this.thickness = 2.5,
    this.borderRadius = 12.0,
    this.animate = true,
    this.duration = const Duration(milliseconds: 2000),
    this.controller,
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  AnimationController? _internalController;
  late Animation<double> _animation;

  AnimationController get _effectiveController => widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.controller == null) {
      _internalController = AnimationController(
        vsync: this,
        duration: widget.duration,
      );
    }
    _animation = CurvedAnimation(
      parent: _effectiveController,
      curve: Curves.fastOutSlowIn,
    );
    if (widget.animate && widget.controller == null) {
      _internalController!.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedGradientBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _internalController?.dispose();
        _internalController = null;
      }
      _initController();
    } else if (widget.controller == null) {
      if (widget.animate != oldWidget.animate) {
        if (widget.animate) {
          _internalController!.repeat();
        } else {
          _internalController!.stop();
          _internalController!.reset();
        }
      }
      if (widget.duration != oldWidget.duration) {
        _internalController!.duration = widget.duration;
        if (widget.animate) {
          _internalController!.repeat();
        }
      }
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                final rotationValue = _animation.value;
                return ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (Rect bounds) {
                    return SweepGradient(
                      center: Alignment.center,
                      colors: [
                        Colors.transparent,
                        widget.color.withValues(alpha: 0.1),
                        widget.color.withValues(alpha: 0.8),
                        widget.color,
                        widget.color.withValues(alpha: 0.8),
                        widget.color.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.1, 0.2, 0.25, 0.3, 0.4, 0.5],
                      transform: GradientRotation(rotationValue * 2 * math.pi),
                    ).createShader(bounds);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: Border.all(
                        color: Colors.white,
                        width: widget.thickness,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
