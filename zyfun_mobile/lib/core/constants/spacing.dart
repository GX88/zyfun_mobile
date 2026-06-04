import 'package:flutter/widgets.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double giant = 40;
  static const double huge = 48;

  static const double pagePadding = lg;
  static const double cardPadding = lg;
  static const double cardGap = md;
  static const double listItemGap = md;
  static const double iconTextGap = sm;

  static const EdgeInsets pageInsets = EdgeInsets.all(pagePadding);
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
}
