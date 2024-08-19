import 'package:flutter/material.dart';

Color getColorFromDbString(String originalColor) {
  final List splitColor = originalColor.split(",");
  return Color.fromRGBO(
    int.parse(splitColor[0]),
    int.parse(splitColor[1]),
    int.parse(splitColor[2]),
    1,
  );
}
