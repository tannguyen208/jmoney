import 'package:flutter_test/flutter_test.dart';
import 'package:jmoney/utils/income_distribution.dart';

void main() {
  test('rounds each allocation and gives the final jar the remainder', () {
    final result = distributeIncome(
      amount: 100003,
      percentages: [55, 25, 10, 10],
    );

    expect(result, [55002, 25001, 10000, 10000]);
    expect(result.reduce((a, b) => a + b), 100003);
  });

  test('normalizes percentages that do not total 100', () {
    final result = distributeIncome(
      amount: 9000000,
      percentages: [50, 25, 10, 5],
    );

    expect(result, [5000000, 2500000, 1000000, 500000]);
  });

  test('never creates a negative final allocation for tiny income', () {
    final result = distributeIncome(
      amount: 1,
      percentages: [50, 50, 0, 0],
    );

    expect(result.every((amount) => amount >= 0), isTrue);
    expect(result.reduce((a, b) => a + b), 1);
  });

  test('rejects a zero total percentage', () {
    expect(
      () => distributeIncome(amount: 100000, percentages: [0, 0, 0, 0]),
      throwsStateError,
    );
  });
}
