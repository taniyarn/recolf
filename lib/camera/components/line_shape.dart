import 'package:flutter/material.dart';

const _kRadius = 16.0;
const _kTapRadius = 32.0;
const _kStrokeWidth = 4.0;
const _kTapStrokeWidth = 32.0;
const primary = Color(0xff6750A4);
const secondary = Color(0xffEADDFF);

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
            left: p1.dx - _kTapRadius / 2,
            top: p1.dy - _kTapRadius / 2,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                updateP1(details.delta);
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
            left: p2.dx - _kTapRadius / 2,
            top: p2.dy - _kTapRadius / 2,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                updateP2(details.delta);
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
      ..strokeWidth = _kStrokeWidth;

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
        Offset(-dp.dy / dp.distance, dp.dx / dp.distance) * _kTapStrokeWidth;

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
