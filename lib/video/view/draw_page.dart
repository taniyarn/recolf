import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recolf/models/shape.dart';
import 'package:recolf/video/bloc/video_bloc.dart';
import 'package:recolf/video/components/circle_shape.dart';
import 'package:recolf/video/components/line_shape.dart';
import 'package:recolf/video/util.dart';

const _isLineMode = false;

class DrawPage extends StatefulWidget {
  const DrawPage({Key? key}) : super(key: key);

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  late List<Shape> shapes;

  @override
  void initState() {
    shapes = [...context.read<VideoBloc>().state.video.shapes];

    super.initState();
  }

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
                        p1: Vector(
                          details.globalPosition.dx,
                          details.globalPosition.dy,
                        ),
                        p2: Vector(
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
                        topLeft: Vector(
                          details.globalPosition.dx,
                          details.globalPosition.dy,
                        ),
                        bottomRight: Vector(
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
                  shape.p2 = Vector(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                  );
                },
              );
            } else if (shape is Circle) {
              var d = 0.0;
              if ((details.globalPosition - shape.topLeft.toOffset()).dx >
                  (details.globalPosition - shape.topLeft.toOffset()).dy) {
                d = (details.globalPosition - shape.topLeft.toOffset()).dx;
              } else {
                d = (details.globalPosition - shape.topLeft.toOffset()).dy;
              }

              if (d < 0) {
                return;
              }

              setState(
                () {
                  shape.bottomRight = shape.topLeft + Vector(d, d);
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
                p1: shape.p1.toOffset(),
                p2: shape.p2.toOffset(),
                active: shape.active,
                updateP1: (delta) {
                  setState(
                    () {
                      shape.p1 += delta.toVector();
                    },
                  );
                },
                updateP2: (delta) {
                  setState(
                    () {
                      shape.p2 += delta.toVector();
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
                topLeft: shape.topLeft.toOffset(),
                bottomRight: shape.bottomRight.toOffset(),
                active: shape.active,
                translation: (delta) {
                  setState(() {
                    shape
                      ..topLeft += delta.toVector()
                      ..bottomRight += delta.toVector();
                  });
                },
                updateTopLeft: (newTopLeft) {
                  setState(
                    () {
                      shape.topLeft = newTopLeft.toVector();
                    },
                  );
                },
                updateBottomRight: (newBottomRight) {
                  setState(
                    () {
                      shape.bottomRight = newBottomRight.toVector();
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
            return const SizedBox.shrink();
          },
        ).toList(),
        Positioned(
          bottom: 100,
          left: 100,
          child: IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              context.read<VideoBloc>().add(
                    VideoUpdated(
                      id: context.read<VideoBloc>().state.video.id,
                      shapes: shapes,
                    ),
                  );
            },
          ),
        ),
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
