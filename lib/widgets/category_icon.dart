import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/category.dart';

abstract final class JMoneyIconAssets {
  static const income = 'assets/koboyo/income.svg';
  static const expense = 'assets/koboyo/expense.svg';
  static const transfer = 'assets/koboyo/transfer.svg';
  static const jar = 'assets/koboyo/jar.svg';
}

class CategoryIconOption {
  const CategoryIconOption({
    required this.key,
    required this.asset,
    required this.legacyIcon,
  });

  final String key;
  final String asset;
  final String legacyIcon;
}

const categoryIconOptions = <CategoryIconOption>[
  CategoryIconOption(
    key: 'icons8:essential-shopping',
    asset: 'assets/koboyo/essential_shopping.svg',
    legacyIcon: '🛒',
  ),
  CategoryIconOption(
    key: 'icons8:food',
    asset: 'assets/koboyo/food.svg',
    legacyIcon: '🍜',
  ),
  CategoryIconOption(
    key: 'icons8:coffee',
    asset: 'assets/koboyo/coffee.svg',
    legacyIcon: '☕',
  ),
  CategoryIconOption(
    key: 'icons8:groceries',
    asset: 'assets/koboyo/groceries.svg',
    legacyIcon: '🧺',
  ),
  CategoryIconOption(
    key: 'icons8:rent',
    asset: 'assets/koboyo/rent.svg',
    legacyIcon: '🏘️',
  ),
  CategoryIconOption(
    key: 'icons8:utilities',
    asset: 'assets/koboyo/utilities.svg',
    legacyIcon: '💡',
  ),
  CategoryIconOption(
    key: 'icons8:internet',
    asset: 'assets/koboyo/internet.svg',
    legacyIcon: '🌐',
  ),
  CategoryIconOption(
    key: 'icons8:phone',
    asset: 'assets/koboyo/phone.svg',
    legacyIcon: '📱',
  ),
  CategoryIconOption(
    key: 'icons8:fuel',
    asset: 'assets/koboyo/fuel.svg',
    legacyIcon: '⛽',
  ),
  CategoryIconOption(
    key: 'icons8:transport',
    asset: 'assets/koboyo/transport.svg',
    legacyIcon: '🛵',
  ),
  CategoryIconOption(
    key: 'icons8:healthcare',
    asset: 'assets/koboyo/healthcare.svg',
    legacyIcon: '🩺',
  ),
  CategoryIconOption(
    key: 'icons8:beauty',
    asset: 'assets/koboyo/beauty.svg',
    legacyIcon: '💄',
  ),
  CategoryIconOption(
    key: 'icons8:entertainment',
    asset: 'assets/koboyo/entertainment.svg',
    legacyIcon: '🎬',
  ),
  CategoryIconOption(
    key: 'icons8:travel',
    asset: 'assets/koboyo/travel.svg',
    legacyIcon: '✈️',
  ),
  CategoryIconOption(
    key: 'icons8:courses-books',
    asset: 'assets/koboyo/courses_books.svg',
    legacyIcon: '📚',
  ),
  CategoryIconOption(
    key: 'icons8:subscriptions',
    asset: 'assets/koboyo/subscriptions.svg',
    legacyIcon: '🔄',
  ),
  CategoryIconOption(
    key: 'icons8:technology',
    asset: 'assets/koboyo/technology.svg',
    legacyIcon: '💻',
  ),
  CategoryIconOption(
    key: 'icons8:gifts',
    asset: 'assets/koboyo/gifts.svg',
    legacyIcon: '🎁',
  ),
  CategoryIconOption(
    key: 'icons8:family',
    asset: 'assets/koboyo/family.svg',
    legacyIcon: '👨‍👩‍👧',
  ),
  CategoryIconOption(
    key: 'icons8:other-expenses',
    asset: 'assets/koboyo/other.svg',
    legacyIcon: '🧾',
  ),
];

const incomeCategoryIconOptions = <CategoryIconOption>[
  CategoryIconOption(
    key: 'icons8:income-salary',
    asset: 'assets/koboyo/income_salary.svg',
    legacyIcon: '💵',
  ),
  CategoryIconOption(
    key: 'icons8:income-bonus',
    asset: 'assets/koboyo/income_bonus.svg',
    legacyIcon: '🏆',
  ),
  CategoryIconOption(
    key: 'icons8:income-side-job',
    asset: 'assets/koboyo/income_side_job.svg',
    legacyIcon: '⏱️',
  ),
  CategoryIconOption(
    key: 'icons8:income-freelance',
    asset: 'assets/koboyo/income_freelance.svg',
    legacyIcon: '🧑‍💻',
  ),
  CategoryIconOption(
    key: 'icons8:income-business',
    asset: 'assets/koboyo/income_business.svg',
    legacyIcon: '🏪',
  ),
  CategoryIconOption(
    key: 'icons8:income-investment',
    asset: 'assets/koboyo/income_investment.svg',
    legacyIcon: '📈',
  ),
  CategoryIconOption(
    key: 'icons8:income-other',
    asset: 'assets/koboyo/income_other.svg',
    legacyIcon: '💰',
  ),
];

const _retiredCategoryAssets = <String, String>{
  'icons8:housing': 'assets/koboyo/rent.svg',
  '🏠': 'assets/koboyo/rent.svg',
  'icons8:bank-savings': 'assets/koboyo/jar.svg',
  '🏦': 'assets/koboyo/jar.svg',
  'icons8:stock-investment': 'assets/koboyo/income_investment.svg',
  'icons8:skills-workshop': 'assets/koboyo/courses_books.svg',
  '🎓': 'assets/koboyo/courses_books.svg',
};

const _categoryIconWidthScales = <String, double>{
  'icons8:essential-shopping': 0.95,
  'icons8:food': 0.84,
  'icons8:coffee': 1,
  'icons8:groceries': 1,
  'icons8:rent': 0.92,
  'icons8:utilities': 1.2,
  'icons8:internet': 1.2,
  'icons8:phone': 1.05,
  'icons8:fuel': 0.92,
  'icons8:transport': 0.82,
  'icons8:healthcare': 1.05,
  'icons8:beauty': 1.8,
  'icons8:entertainment': 1,
  'icons8:travel': 0.9,
  'icons8:courses-books': 0.9,
  'icons8:subscriptions': 0.8,
  'icons8:technology': 0.84,
  'icons8:gifts': 1,
  'icons8:family': 1.2,
  'icons8:other-expenses': 1.45,
  'icons8:income-salary': 1,
  'icons8:income-bonus': 0.9,
  'icons8:income-side-job': 0.95,
  'icons8:income-freelance': 0.84,
  'icons8:income-business': 0.9,
  'icons8:income-investment': 0.86,
  'icons8:income-other': 0.9,
};

String? normalizeCategoryIcon(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  for (final option in [...categoryIconOptions, ...incomeCategoryIconOptions]) {
    if (normalized == option.key || normalized == option.legacyIcon) {
      return option.key;
    }
  }
  return normalized;
}

String? categoryIconAsset(String? value) {
  final normalized = normalizeCategoryIcon(value);
  if (normalized == null) return null;
  for (final option in [...categoryIconOptions, ...incomeCategoryIconOptions]) {
    if (option.key == normalized) return option.asset;
  }
  return _retiredCategoryAssets[value?.trim()];
}

double categoryIconVisualScale(String? value) {
  switch (normalizeCategoryIcon(value)) {
    case 'icons8:beauty':
      return 1.35;
    case 'icons8:other-expenses':
      return 1.2;
    case 'icons8:utilities':
    case 'icons8:internet':
      return 1.15;
    case 'icons8:technology':
    case 'icons8:subscriptions':
      return 0.9;
    default:
      return 1;
  }
}

double categoryIconHorizontalScale(String? value) {
  return _categoryIconWidthScales[normalizeCategoryIcon(value)] ?? 1;
}

class KoboyoAssetIcon extends StatelessWidget {
  const KoboyoAssetIcon({
    super.key,
    required this.asset,
    this.size = 28,
    this.semanticLabel,
    this.horizontalScale = 1,
  });

  final String asset;
  final double size;
  final String? semanticLabel;
  final double horizontalScale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: horizontalScale,
      child: SvgPicture.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        semanticsLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 28,
    this.fallbackColor,
  });

  final Category category;
  final double size;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.8;
    final asset = categoryIconAsset(category.icon);
    if (asset != null) {
      return KoboyoAssetIcon(
        asset: asset,
        size: iconSize,
        horizontalScale: categoryIconHorizontalScale(category.icon),
      );
    }
    final legacyIcon = category.icon?.trim();
    if (legacyIcon != null && legacyIcon.isNotEmpty) {
      return SizedBox.square(
        dimension: iconSize,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(legacyIcon),
        ),
      );
    }
    return Icon(
      Icons.category_outlined,
      size: iconSize,
      color: fallbackColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}

class CategoryOptionLabel extends StatelessWidget {
  const CategoryOptionLabel({
    super.key,
    required this.category,
    this.iconSize = 24,
  });

  final Category category;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox.square(
          dimension: iconSize,
          child: CategoryIcon(category: category, size: iconSize),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
