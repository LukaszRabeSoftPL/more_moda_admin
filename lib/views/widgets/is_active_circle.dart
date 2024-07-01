import 'package:flutter/material.dart';

class IsActiveCircle extends StatelessWidget {
  Color color;
  IsActiveCircle({required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
