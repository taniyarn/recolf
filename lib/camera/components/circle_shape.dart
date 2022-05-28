import 'dart:math';

import 'package:flutter/material.dart';

const _kRadius = 16.0;
const _kTapRadius = 32.0;
const _kStrokeWidth = 4.0;
const primary = Color(0xff6750A4);
const secondary = Color(0xffEADDFF);

class CircleShape extends StatelessWidget {
  const CircleShape({
    Key? key,
    required this.topLeft,
    required this.bottomRight,
    required this.active,
    required this.translation,
    required this.updateTopLeft,
    required this.updateBottomRight,
    this.onTap,
  }) : super(key: key);
  final Offset topLeft;
  final Offset bottomRight;
  final bool active;
  final Function(Offset) translation;
  final Function(Offset) updateTopLeft;
  final Function(Offset) updateBottomRight;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      GestureDetector(
        onPanUpdate: (details) {
          if (!active) return;

          translation(details.delta);
        },
        onTap: active ? null : onTap,
        child: CustomPaint(
          painter: ExampleCircle(
            topLeft: topLeft,
            bottomRight: bottomRight,
            active: active,
          ),
          child: Container(),
        ),
      ),
    ];
    if (active) {
      children.addAll(
        [
          Positioned(
            left: topLeft.dx - _kTapRadius / 2,
            top: topLeft.dy - _kTapRadius / 2,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                var d = 0.0;
                if ((bottomRight - details.globalPosition).dx >
                    (bottomRight - details.globalPosition).dy) {
                  d = (bottomRight - details.globalPosition).dx;
                } else {
                  d = (bottomRight - details.globalPosition).dy;
                }

                if (d < 0) {
                  return;
                }
                updateTopLeft(bottomRight - Offset(d, d));
              },
              child: Container(
                alignment: Alignment.center,
                width: _kTapRadius,
                height: _kTapRadius,
                child: Container(
                  width: _kRadius,
                  height: _kRadius,
                  decoration: const BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: topLeft.dx - _kTapRadius / 2,
            top: bottomRight.dy - _kTapRadius / 2,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                var d = 0.0;
                if ((bottomRight - details.globalPosition).dx >
                    (details.globalPosition - topLeft).dy) {
                  d = (bottomRight - details.globalPosition).dx;
                } else {
                  d = (details.globalPosition - topLeft).dy;
                }

                if (d < 0) {
                  return;
                }
                updateTopLeft(Offset(bottomRight.dx - d, topLeft.dy));
                updateBottomRight(Offset(bottomRight.dx, topLeft.dy + d));
              },
              child: Container(
                alignment: Alignment.center,
                width: _kTapRadius,
                height: _kTapRadius,
                child: Container(
                  width: _kRadius,
                  height: _kRadius,
                  decoration: const BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: bottomRight.dx - _kTapRadius / 2,
            top: topLeft.dy - _kTapRadius / 2,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                var d = 0.0;
                if ((details.globalPosition - topLeft).dx >
                    (bottomRight - details.globalPosition).dy) {
                  d = (details.globalPosition - topLeft).dx;
                } else {
                  d = (bottomRight - details.globalPosition).dy;
                }

                if (d < 0) {
                  return;
                }
                updateTopLeft(Offset(topLeft.dx, bottomRight.dy - d));
                updateBottomRight(Offset(topLeft.dx + d, bottomRight.dy));
              },
              child: Container(
                alignment: Alignment.center,
                width: _kTapRadius,
                height: _kTapRadius,
                child: Container(
                  width: _kRadius,
                  height: _kRadius,
                  decoration: const BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: bottomRight.dx - _kTapRadius / 2,
            top: bottomRight.dy - _kTapRadius / 2,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                var d = 0.0;
                if ((details.globalPosition - topLeft).dx >
                    (details.globalPosition - topLeft).dy) {
                  d = (details.globalPosition - topLeft).dx;
                } else {
                  d = (details.globalPosition - topLeft).dy;
                }

                if (d < 0) {
                  return;
                }

                updateBottomRight(topLeft + Offset(d, d));
              },
              child: Container(
                alignment: Alignment.center,
                width: _kTapRadius,
                height: _kTapRadius,
                child: Container(
                  width: _kRadius,
                  height: _kRadius,
                  decoration: const BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Stack(
      children: children,
    );
  }
}

class ExampleCircle extends CustomPainter {
  const ExampleCircle({
    required this.topLeft,
    required this.bottomRight,
    required this.active,
  });
  final Offset topLeft;
  final Offset bottomRight;
  final bool active;

  Offset get center => (topLeft + bottomRight) / 2;
  double get radius => (bottomRight - topLeft).distance / 2 / sqrt2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = active ? primary : secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStrokeWidth;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  @override
  bool? hitTest(Offset position) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final path = Path()..addOval(rect);

    return path.contains(position);
  }
}
