import 'package:flutter/material.dart';

Widget MainButton({
  required String text,
  required VoidCallback onPressed,
  Color? color = const Color(0xFF273630),
  Color? textColor = Colors.white,
  double? width = 200,
  double? height = 50,
  double? fontSize = 16,
  double? borderRadius = 0,
}) {
  return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius != null
                ? BorderRadius.circular(borderRadius)
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ));
}
