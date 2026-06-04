import 'package:flutter/material.dart';

import '../../core/constants/typography.dart';

class PrimaryText extends StatelessWidget {
  const PrimaryText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: AppTypography.body.merge(style),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class SecondaryText extends StatelessWidget {
  const SecondaryText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: AppTypography.bodySmall.merge(style),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class CaptionText extends StatelessWidget {
  const CaptionText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: AppTypography.caption.merge(style),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class NumericText extends StatelessWidget {
  const NumericText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: AppTypography.numeric.merge(style),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
