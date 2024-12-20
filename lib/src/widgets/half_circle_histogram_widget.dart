import 'package:flutter/material.dart';

class HalfCircleHistogramPainter extends CustomPainter {
  const HalfCircleHistogramPainter({
    required this.progressState,
    required this.width,
    required this.height,
    required this.color,
  });

  final int progressState;
  final double width;
  final double height;
  final Color color;

  

  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    final rect = Rect.fromCircle(
      center: Offset(width / 2, height / 2),
      radius: 100.0,
    );
    const pi = 3.14159265359;
    const startAngle = pi;
    final sweepAngle = 2 * pi * progressState / 100;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class HalfCircleHistogramWidget extends StatelessWidget {
  const HalfCircleHistogramWidget({
    super.key,
    required this.progressState,
    required this.width,
    required this.height,
    required this.color,
  });

  final int progressState;
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: HalfCircleHistogramPainter(
        progressState: progressState,
        color: color,
        width: width,
        height: height,
      ),
    );
  }
}