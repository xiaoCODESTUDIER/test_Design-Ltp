import 'package:flutter/material.dart';

class SmallSquare extends StatelessWidget {
  final Color color;
  final double size;

  const SmallSquare({
    super.key,
    this.color = Colors.blue,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: color,
    );
  }
}