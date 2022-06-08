import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recolf/models/shape.dart';
import 'package:recolf/video/bloc/video_bloc.dart';
import 'package:recolf/video/util.dart';
import 'package:recolf/video/widgets/circle_shape.dart';
import 'package:recolf/video/widgets/line_shape.dart';

const _kDistance = 5;

bool _isSameVector(Vector p1, Vector p2) {
  final distance = sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
  return distance < _kDistance;
}

class DrawView extends StatelessWidget {
  const DrawView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        return Stack(
          children: [
            IgnorePointer(
              ignoring: state.mode == VideoMode.viewMode,
              child: GestureDetector(
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

                  state.video.shapes
                    ..deactivate()
                    ..add(shape);

                  context.read<VideoBloc>().add(
                        ShapesChanged(state.video.shapes),
                      );
                },
                onPanUpdate: (details) {
                  final shape = state.video.shapes.firstWhere(
                    (e) => e.active == true,
                  );

                  if (shape is Line) {
                    shape.p2 = Vector(
                      details.globalPosition.dx,
                      details.globalPosition.dy,
                    );
                  } else if (shape is Circle) {
                    var d = 0.0;
                    if ((details.globalPosition - shape.topLeft.toOffset()).dx >
                        (details.globalPosition - shape.topLeft.toOffset())
                            .dy) {
                      d = (details.globalPosition - shape.topLeft.toOffset())
                          .dx;
                    } else {
                      d = (details.globalPosition - shape.topLeft.toOffset())
                          .dy;
                    }

                    if (d < 0) {
                      return;
                    }

                    shape.bottomRight = shape.topLeft + Vector(d, d);
                  }
                  context.read<VideoBloc>().add(
                        ShapesChanged(state.video.shapes),
                      );
                },
                onPanEnd: (details) {
                  final shape = state.video.shapes.last;
                  if ((shape is Line && _isSameVector(shape.p1, shape.p2)) |
                      (shape is Circle &&
                          _isSameVector(shape.topLeft, shape.bottomRight))) {
                    state.video.shapes.removeLast();
                  }

                  context.read<VideoBloc>().add(
                        ShapesChanged(state.video.shapes),
                      );
                },
                child: const SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                ),
              ),
            ),
            ...state.video.shapes.map(
              (shape) {
                if (shape is Line) {
                  return LineShape(
                    p1: shape.p1.toOffset(),
                    p2: shape.p2.toOffset(),
                    disable: state.mode == VideoMode.viewMode,
                    active: shape.active,
                    updateP1: (delta) {
                      shape.p1 += delta.toVector();

                      context.read<VideoBloc>().add(
                            ShapesChanged(state.video.shapes),
                          );
                    },
                    updateP2: (delta) {
                      shape.p2 += delta.toVector();

                      context.read<VideoBloc>().add(
                            ShapesChanged(state.video.shapes),
                          );
                    },
                    onTap: () {
                      if (!shape.active) {
                        state.video.shapes.deactivate();
                      }
                      shape.active = !shape.active;
                      state.video.shapes.sortByActivate();

                      context.read<VideoBloc>().add(
                            ShapesChanged(state.video.shapes),
                          );
                    },
                  );
                } else if (shape is Circle) {
                  return CircleShape(
                    topLeft: shape.topLeft.toOffset(),
                    bottomRight: shape.bottomRight.toOffset(),
                    disable: state.mode == VideoMode.viewMode,
                    active: shape.active,
                    translation: (delta) {
                      shape
                        ..topLeft += delta.toVector()
                        ..bottomRight += delta.toVector();

                      context.read<VideoBloc>().add(
                            ShapesChanged(state.video.shapes),
                          );
                    },
                    updateTopLeft: (newTopLeft) {
                      shape.topLeft = newTopLeft.toVector();

                      context.read<VideoBloc>().add(
                            ShapesChanged(state.video.shapes),
                          );
                    },
                    updateBottomRight: (newBottomRight) {
                      shape.bottomRight = newBottomRight.toVector();

                      context.read<VideoBloc>().add(
                            ShapesChanged(state.video.shapes),
                          );
                    },
                    onTap: () {
                      if (!shape.active) {
                        state.video.shapes.deactivate();
                      }
                      shape.active = !shape.active;
                      state.video.shapes.sortByActivate();

                      context.read<VideoBloc>().add(
                            ShapesChanged(state.video.shapes),
                          );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ).toList(),
          ],
        );
      },
    );
  }
}
