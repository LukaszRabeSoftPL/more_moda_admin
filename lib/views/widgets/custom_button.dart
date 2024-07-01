import 'package:flutter/material.dart';

Widget customButton({
  required String text,
  required VoidCallback onPressed,
  Color? color = const Color(0xFF6A93C3),
  Color? textColor = Colors.white,
  double? width = 250,
  double? height = 40,
  double? fontSize = 15,
  double? borderRadius = 0,
  Icon icon = const Icon(Icons.add, color: Color(0xFF6A93C3)),
}) {
  return SizedBox(
    width: width,
    height: height,
    child: GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
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
          ),
          Container(
            width: 40,
            height: height,
            child: icon,
            decoration: BoxDecoration(
              color: Color(0xFFB9D5EC),
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ],
      ),
    ),
  );
}
