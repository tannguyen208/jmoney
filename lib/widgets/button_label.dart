import 'package:flutter/material.dart';

/// A stable, single-line label for every text-bearing button in JMoney.
class ButtonLabel extends StatelessWidget {
  const ButtonLabel(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: style,
    );
  }
}
