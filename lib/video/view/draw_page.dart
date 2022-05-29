import 'package:flutter/material.dart';
import 'package:recolf/models/shape.dart';
import 'package:recolf/video/components/circle_shape.dart';
import 'package:recolf/video/components/line_shape.dart';

const _isLineMode = false;

class DrawPage extends StatefulWidget {
  const DrawPage({Key? key}) : super(key: key);

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  final shapes = <Shape>[];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (details) {
            setState(
              () {
                if (_isLineMode) {
                  shapes
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
                } else {
                  shapes
                    ..deactivate()
                    ..add(
                      Circle(
                        topLeft: Offset(
                          details.globalPosition.dx,
                          details.globalPosition.dy,
                        ),
                        bottomRight: Offset(
                          details.globalPosition.dx,
                          details.globalPosition.dy,
                        ),
                        active: true,
                      ),
                    );
                }
              },
            );
          },
          onPanUpdate: (details) {
            final shape = shapes.firstWhere(
              (e) => e.active == true,
            );

            if (shape is Line) {
              setState(
                () {
                  shape.p2 = Offset(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                  );
                },
              );
            } else if (shape is Circle) {
              var d = 0.0;
              if ((details.globalPosition - shape.topLeft).dx >
                  (details.globalPosition - shape.topLeft).dy) {
                d = (details.globalPosition - shape.topLeft).dx;
              } else {
                d = (details.globalPosition - shape.topLeft).dy;
              }

              if (d < 0) {
                return;
              }

              setState(
                () {
                  shape.bottomRight = shape.topLeft + Offset(d, d);
                },
              );
            }
          },
          child: Container(
            height: double.infinity,
            width: double.infinity,
          ),
        ),
        ...shapes.map(
          (shape) {
            if (shape is Line) {
              return LineShape(
                p1: shape.p1,
                p2: shape.p2,
                active: shape.active,
                updateP1: (delta) {
                  setState(
                    () {
                      shape.p1 += delta;
                    },
                  );
                },
                updateP2: (delta) {
                  setState(
                    () {
                      shape.p2 += delta;
                    },
                  );
                },
                onTap: () {
                  setState(
                    () {
                      if (!shape.active) {
                        shapes.deactivate();
                      }
                      shape.active = !shape.active;
                      shapes.sortByActivate();
                    },
                  );
                },
              );
            } else if (shape is Circle) {
              return CircleShape(
                topLeft: shape.topLeft,
                bottomRight: shape.bottomRight,
                active: shape.active,
                translation: (delta) {
                  setState(() {
                    shape
                      ..topLeft += delta
                      ..bottomRight += delta;
                  });
                },
                updateTopLeft: (newTopLeft) {
                  setState(
                    () {
                      shape.topLeft = newTopLeft;
                    },
                  );
                },
                updateBottomRight: (newBottomRight) {
                  setState(
                    () {
                      shape.bottomRight = newBottomRight;
                    },
                  );
                },
                onTap: () {
                  setState(
                    () {
                      if (!shape.active) {
                        shapes.deactivate();
                      }
                      shape.active = !shape.active;
                      shapes.sortByActivate();
                    },
                  );
                },
              );
            }
            return SizedBox.shrink();
          },
        ).toList()
      ],
    );
  }
}

extension Ex on List<Shape> {
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
