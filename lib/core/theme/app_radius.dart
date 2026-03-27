import 'package:flutter/material.dart';

abstract class AppRadius {
  static const BorderRadius tile        = BorderRadius.all(Radius.circular(16));
  static const BorderRadius card        = BorderRadius.all(Radius.circular(12));
  static const BorderRadius button      = BorderRadius.all(Radius.circular(12));
  static const BorderRadius small       = BorderRadius.all(Radius.circular(8));
  static const BorderRadius bottomSheet = BorderRadius.vertical(top: Radius.circular(24));
  static const BorderRadius circle      = BorderRadius.all(Radius.circular(999));
}
