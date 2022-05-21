import 'package:flutter/material.dart';

import '../components/line_shape.dart';

class Line {
  Line({
    required this.p1,
    required this.p2,
    required this.active,
  });
  Offset p1;
  Offset p2;
  bool active;
}

class DrawPage extends StatefulWidget {
  const DrawPage({Key? key}) : super(key: key);

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  final lines = <Line>[];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) {
              setState(
                () {
                  lines
                    ..deactivate()
                    ..add(
                      Line(
                        p1: Offset(
                          details.globalPosition.dx,
                          details.globalPosition.dy,
                        ),
                        p2: Offset(
                          details.globalPosition.dx,
                          details.globalPosition.dy,
                        ),
                        active: true,
                      ),
                    );
                },
              );
            },
            onPanUpdate: (details) {
              final line = lines.firstWhere(
                (e) => e.active == true,
              );
              setState(
                () {
                  line.p2 = Offset(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                  );
                },
              );
            },
            child: Container(
              color: const Color(0xffFFFFFF),
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          ...lines
              .map(
                (line) => LineShape(
                  p1: line.p1,
                  p2: line.p2,
                  active: line.active,
                  updateP1: (delta) {
                    setState(
                      () {
                        line.p1 += delta;
                      },
                    );
                  },
                  updateP2: (delta) {
                    setState(
                      () {
                        line.p2 += delta;
                      },
                    );
                  },
                  onTap: () {
                    setState(
                      () {
                        if (!line.active) {
                          lines.deactivate();
                        }
                        line.active = !line.active;
                        lines.sortByActivate();
                      },
                    );
                  },
                ),
              )
              .toList()
        ],
      ),
    );
  }
}

extension Ex on List<Line> {
  void deactivate() {
    forEach((e) => e.active = false);
  }

  void sortByActivate() {
    sort(
      (a, b) {
        if (a.active) {
          return 1;
        } else if (b.active) {
          return -1;
        }
        return 0;
      },
    );
  }
}
