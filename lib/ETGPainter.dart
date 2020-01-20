import 'dart:ui';

import 'package:clock/colors.dart';
import 'package:flutter/material.dart';

// ElectroTimogram 😀
class ETGPainter extends CustomPainter {
  final double percent;

  ETGPainter(this.percent);

  Paint _paint = Paint()
    ..color = foreground
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final xLine = height / 1.8;

    final p = Path()
      ..moveTo(0, xLine)
      ..lineTo(width / 6, xLine)
      ..quadraticBezierTo(width / 4.5, xLine - (xLine / 5), width / 4, xLine)
      ..lineTo(width / 3.2, xLine)
      ..lineTo(width / 3, xLine + (xLine / 5))
      ..lineTo(width / 2.7, (xLine / 3))
      ..lineTo(width / 2.4, (xLine * 1.4))
      ..lineTo(width / 2.2, xLine)
      ..lineTo(width, xLine);

    canvas.drawPath(createAnimatedPath(p, percent), _paint);
  }

  @override
  bool shouldRepaint(ETGPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ETGPainter oldDelegate) => false;
}

// Path extractor from https://stackoverflow.com/a/57233047/7899146
Path extractPathUntilLength(
  Path originalPath,
  double length,
) {
  var currentLength = 0.0;

  final path = new Path();

  Iterator metricsIterator = originalPath.computeMetrics().iterator;

  while (metricsIterator.moveNext()) {
    PathMetric metric = metricsIterator.current;

    double nextLength = currentLength + metric.length;

    final isLastSegment = nextLength > length;
    if (isLastSegment) {
      final remainingLength = length - currentLength;
      final pathSegment = metric.extractPath(0.0, remainingLength);

      path.addPath(pathSegment, Offset.zero);
      break;
    } else {
      final Path pathSegment = metric.extractPath(0.0, metric.length);
      path.addPath(pathSegment, Offset.zero);
    }

    currentLength = nextLength;
  }

  return path;
}

Path createAnimatedPath(
  Path originalPath,
  double animationPercent,
) {
  final totalLength = originalPath
      .computeMetrics()
      .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);
  final currentLength = totalLength * animationPercent;
  return extractPathUntilLength(originalPath, currentLength);
}
