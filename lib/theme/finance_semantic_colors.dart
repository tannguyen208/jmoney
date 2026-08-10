import 'package:flutter/material.dart';

@immutable
class FinanceSemanticColors extends ThemeExtension<FinanceSemanticColors> {
  const FinanceSemanticColors({
    required this.income,
    required this.onIncome,
    required this.transfer,
    required this.onTransfer,
  });

  static const cosmic = FinanceSemanticColors(
    income: Color(0xFF78D6B0),
    onIncome: Color(0xFF082A20),
    transfer: Color(0xFFAFC6F2),
    onTransfer: Color(0xFF172A45),
  );

  static const pastel = FinanceSemanticColors(
    income: Color(0xFF26745F),
    onIncome: Color(0xFFFFFFFF),
    transfer: Color(0xFF42689A),
    onTransfer: Color(0xFFFFFFFF),
  );

  static const appleLight = FinanceSemanticColors(
    income: Color(0xFF248A3D),
    onIncome: Color(0xFFFFFFFF),
    transfer: Color(0xFF007AFF),
    onTransfer: Color(0xFFFFFFFF),
  );

  static const appleDark = FinanceSemanticColors(
    income: Color(0xFF30D158),
    onIncome: Color(0xFF001D08),
    transfer: Color(0xFF0A84FF),
    onTransfer: Color(0xFFFFFFFF),
  );

  final Color income;
  final Color onIncome;
  final Color transfer;
  final Color onTransfer;

  @override
  FinanceSemanticColors copyWith({
    Color? income,
    Color? onIncome,
    Color? transfer,
    Color? onTransfer,
  }) {
    return FinanceSemanticColors(
      income: income ?? this.income,
      onIncome: onIncome ?? this.onIncome,
      transfer: transfer ?? this.transfer,
      onTransfer: onTransfer ?? this.onTransfer,
    );
  }

  @override
  FinanceSemanticColors lerp(
    covariant FinanceSemanticColors? other,
    double t,
  ) {
    if (other == null) return this;
    return FinanceSemanticColors(
      income: Color.lerp(income, other.income, t)!,
      onIncome: Color.lerp(onIncome, other.onIncome, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
      onTransfer: Color.lerp(onTransfer, other.onTransfer, t)!,
    );
  }
}
