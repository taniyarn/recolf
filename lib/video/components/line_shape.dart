import 'package:flutter/material.dart';
import 'package:recolf/camera/camera_const.dart';
import 'package:recolf/video/components/corner_point.dart';

class LineShape extends StatelessWidget {
  const LineShape({
    Key? key,
    required this.p1,
    required this.p2,
    required this.active,
    required this.updateP1,
    required this.updateP2,
    this.onTap,
  }) : super(key: key);
  final Offset p1;
  final Offset p2;
  final bool active;
  final Function(Offset) updateP1;
  final Function(Offset) updateP2;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      GestureDetector(
        onPanUpdate: (details) {
          if (!active) return;

          updateP1(details.delta);
          updateP2(details.delta);
        },
        onTap: active ? null : onTap,
        child: CustomPaint(
          painter: ExampleLine(p1: p1, p2: p2, active: active),
          child: Container(),
        ),
      ),
    ];
    if (active) {
      children.addAll(
        [
          Positioned(
            left: p1.dx - kTapRadius / 2,
            top: p1.dy - kTapRadius / 2,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                updateP1(details.delta);
              },
              child: const CornerPoint(),
            ),
          ),
          Positioned(
            left: p2.dx - kTapRadius / 2,
            top: p2.dy - kTapRadius / 2,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                updateP2(details.delta);
              },
              child: const CornerPoint(),
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

class ExampleLine extends CustomPainter {
  const ExampleLine({
    required this.p1,
    required this.p2,
    required this.active,
  });
  final Offset p1;
  final Offset p2;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = active ? primary : secondary
      ..strokeWidth = kStrokeWidth;

    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  @override
  bool? hitTest(Offset position) {
    final dp = p2 - p1;
    final dn =
        Offset(-dp.dy / dp.distance, dp.dx / dp.distance) * kTapStrokeWidth;

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..relativeLineTo(dn.dx / 2, dn.dy / 2)
      ..relativeLineTo(dp.dx, dp.dy)
      ..relativeLineTo(-dn.dx, -dn.dy)
      ..relativeLineTo(-dp.dx, -dp.dy)
      ..close();
    return path.contains(position);
  }
}
