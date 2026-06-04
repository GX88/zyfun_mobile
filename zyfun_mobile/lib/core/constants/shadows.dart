import 'package:flutter/material.dart';

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> lg = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> floating = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> darkCard = <BoxShadow>[
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 28,
      offset: Offset(0, 16),
    ),
  ];
}
