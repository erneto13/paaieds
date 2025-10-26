import 'dart:math';
import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';

class GeometricShape extends StatelessWidget {
  final Size size;
  final Color color;
  final double top;
  final double left;
  final bool isCircle;

  const GeometricShape({
    super.key,
    required this.size,
    required this.color,
    required this.top,
    required this.left,
    required this.isCircle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class GeometricShapeGenerator {
  static final Random _random = Random();

  static List<Widget> generateShapes(BuildContext context) {
    final List<Widget> shapes = [];

    final List<Color> colors = [
      AppColors.lightBlue,
      Colors.blueAccent,
      Colors.lightBlue,
      Colors.blue.shade300,
      Colors.blue.shade200,
      Colors.lightBlue.shade300,
      Colors.blueAccent.shade100,
    ];

    for (int i = 0; i < 25 + _random.nextInt(6); i++) {
      final int edge = _random.nextInt(4);
      final double size = 30.0 + _random.nextDouble() * 90.0;
      final bool isCircle = _random.nextBool();
      final Color color = colors[_random.nextInt(colors.length)];
      double top, left;

      switch (edge) {
        case 0:
          top = -size * 0.5 + _random.nextDouble() * 50.0;
          left = _random.nextDouble();
          break;
        case 1:
          top = _random.nextDouble();
          left =
              1.0 -
              (size * 0.5 / MediaQuery.of(context).size.width) +
              _random.nextDouble() * 0.1;
          break;
        case 2:
          top =
              1.0 -
              (size * 0.5 / MediaQuery.of(context).size.height) +
              _random.nextDouble() * 0.1;
          left = _random.nextDouble();
          break;
        case 3:
          top = _random.nextDouble();
          left = -size * 0.5 + _random.nextDouble() * 50.0;
          break;
        default:
          top = 0.0;
          left = 0.0;
      }

      final double absoluteTop = top * MediaQuery.of(context).size.height;
      final double absoluteLeft = left * MediaQuery.of(context).size.width;

      shapes.add(
        GeometricShape(
          size: Size(size, size),
          color: color,
          top: absoluteTop,
          left: absoluteLeft,
          isCircle: isCircle,
        ),
      );
    }

    return shapes;
  }
}
