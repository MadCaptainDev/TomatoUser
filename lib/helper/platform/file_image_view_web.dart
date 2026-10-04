import 'package:flutter/material.dart';

Widget fileImage(String path, {double? width, double? height, BoxFit? fit}) {
  return Image.network(path, width: width, height: height, fit: fit);
}
