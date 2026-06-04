import 'package:flutter/widgets.dart';

class AppRadius {
  const AppRadius._();

  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double full = 9999;

  static const BorderRadius button = BorderRadius.all(Radius.circular(md));
  static const BorderRadius input = BorderRadius.all(Radius.circular(md));
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius largeCard = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius chip = BorderRadius.all(Radius.circular(xs));
}
