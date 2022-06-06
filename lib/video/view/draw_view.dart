import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recolf/models/shape.dart';
import 'package:recolf/video/bloc/video_bloc.dart';
import 'package:recolf/video/widgets/circle_shape.dart';
import 'package:recolf/video/widgets/line_shape.dart';
import 'package:recolf/video/util.dart';

const _kDistance = 5;

bool _isSameVector(Vector p1, Vector p2) {
  final distance = sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
  return distance < _kDistance;
}

class DrawView extends StatefulWidget {
  const DrawView({Key? key}) : super(key: key);

  @override
  State<DrawView> createState() => _DrawViewState();
}

class _DrawViewState extends State<DrawView> {
  late List<Shape> shapes;

  @override
  void initState() {
    shapes = [...context.read<VideoBloc>().state.video.shapes];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                final tapVector = Vector(
                  details.globalPosition.dx,
                  details.globalPosition.dy,
                );
                Shape shape;

                switch (state.type) {
                  case ShapeType.line:
                    shape = Line(
                      p1: tapVector,
                      p2: tapVector,
                      active: true,
                    );
                    break;
                  case ShapeType.circle:
                    shape = Circle(
                      topLeft: tapVector,
                      bottomRight: tapVector,
                      active: true,
                    );
                    break;
                }

                setState(
                  () {
                    shapes
                      ..deactivate()
                      ..add(shape);
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
              onPanEnd: (details) {
                final shape = shapes.last;
                if ((shape is Line && _isSameVector(shape.p1, shape.p2)) |
                    (shape is Circle &&
                        _isSameVector(shape.topLeft, shape.bottomRight))) {
                  setState(() {
                    shapes.removeLast();
                  });
                }
              },
              child: const SizedBox(
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
            Align(
              alignment: Alignment.bottomCenter,
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
            if (state.type == ShapeType.line)
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.toggle_on),
                  onPressed: () {
                    context.read<VideoBloc>().add(
                          ShapeTypeChanged(ShapeType.circle),
                        );
                  },
                ),
              )
            else
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.toggle_on),
                  onPressed: () {
                    context.read<VideoBloc>().add(
                          ShapeTypeChanged(ShapeType.line),
                        );
                  },
                ),
              ),
          ],
        );
      },
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
