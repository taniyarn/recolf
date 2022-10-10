import 'dart:math';

import 'package:flutter/material.dart';
import 'package:recolf/camera/camera_const.dart';
import 'package:recolf/video/widgets/corner_point.dart';

class CircleShape extends StatelessWidget {
  const CircleShape({
    Key? key,
    required this.topLeft,
    required this.bottomRight,
    required this.active,
    required this.disable,
    required this.translation,
    required this.updateTopLeft,
    required this.updateBottomRight,
    this.onTap,
  }) : super(key: key);
  final Offset topLeft;
  final Offset bottomRight;
  final bool active;
  final bool disable;
  final Function(Offset) translation;
  final Function(Offset) updateTopLeft;
  final Function(Offset) updateBottomRight;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      IgnorePointer(
        ignoring: disable,
        child: GestureDetector(
          onPanUpdate: (details) {
            if (!active) return;

            translation(details.delta);
          },
          onTap: active ? null : onTap,
          child: CustomPaint(
            painter: CirclePainter(
              context: context,
              topLeft: topLeft,
              bottomRight: bottomRight,
              active: active,
            ),
            child: Container(),
          ),
        ),
      ),
    ];
    if (active) {
      children.addAll(
        [
          Positioned(
            left: topLeft.dx - kTapRadius / 2,
            top: topLeft.dy - kTapRadius / 2,
            child: IgnorePointer(
              ignoring: disable,
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
                child: const CornerPoint(),
              ),
            ),
          ),
          Positioned(
            left: topLeft.dx - kTapRadius / 2,
            top: bottomRight.dy - kTapRadius / 2,
            child: IgnorePointer(
              ignoring: disable,
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
                child: const CornerPoint(),
              ),
            ),
          ),
          Positioned(
            left: bottomRight.dx - kTapRadius / 2,
            top: topLeft.dy - kTapRadius / 2,
            child: IgnorePointer(
              ignoring: disable,
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
                child: const CornerPoint(),
              ),
            ),
          ),
          Positioned(
            left: bottomRight.dx - kTapRadius / 2,
            top: bottomRight.dy - kTapRadius / 2,
            child: IgnorePointer(
              ignoring: disable,
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
                child: const CornerPoint(),
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

class CirclePainter extends CustomPainter {
  const CirclePainter({
    required this.context,
    required this.topLeft,
    required this.bottomRight,
    required this.active,
  });
  final BuildContext context;
  final Offset topLeft;
  final Offset bottomRight;
  final bool active;

  Offset get center => (topLeft + bottomRight) / 2;
  double get radius => (bottomRight - topLeft).distance / 2 / sqrt2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = active
          ? Theme.of(context).primaryColor
          : Theme.of(context).primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = kStrokeWidth;

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
