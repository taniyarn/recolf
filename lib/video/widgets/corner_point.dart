import 'package:flutter/material.dart';
import 'package:recolf/camera/camera_const.dart';

class CornerPoint extends StatelessWidget {
  const CornerPoint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: kTapRadius,
      height: kTapRadius,
      child: Container(
        width: kRadius,
        height: kRadius,
        decoration: BoxDecoration(
          color: Colors.red[300],
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
