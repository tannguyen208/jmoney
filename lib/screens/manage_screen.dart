import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../providers/finance_provider.dart';
import '../widgets/button_label.dart';
import 'budget_screen.dart';
import 'categories_screen.dart';
import 'data_backup_screen.dart';
import 'goals_screen.dart';
import 'jars_screen.dart';
import 'recurring_screen.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _SettingsGroup(
              children: [
                _ManageTile(
                  icon: Icons.savings_outlined,
                  title: l10n.jarsSettings,
                  onTap: () => _open(context, const JarsScreen()),
                ),
                _ManageTile(
                  icon: Icons.category_outlined,
                  title: l10n.categoriesSettings,
                  onTap: () => _open(context, const CategoriesScreen()),
                ),
                _ManageTile(
                  tileKey: const ValueKey('manage-budget'),
                  icon: Icons.account_balance_wallet_outlined,
                  title: l10n.budgetSettings,
                  onTap: () => _open(context, const BudgetScreen()),
                ),
                _ManageTile(
                  icon: Icons.flag_outlined,
                  title: l10n.goalsSettings,
                  onTap: () => _open(context, const GoalsScreen()),
                ),
                _ManageTile(
                  icon: Icons.event_repeat_outlined,
                  title: l10n.recurringSettings,
                  onTap: () => _open(context, const RecurringScreen()),
                ),
                _ManageTile(
                  icon: Icons.import_export_rounded,
                  title: l10n.dataSettings,
                  onTap: () => _open(context, const DataBackupScreen()),
                ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => _openKoboyo(context),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: ButtonLabel(l10n.iconsByKoboyo),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.dangerZone,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            _ResetDataTile(
              isSaving: provider.isSaving,
              onTap: () => _confirmReset(context),
            ),
          ],
        ),
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  static Future<void> _openKoboyo(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse('https://koboyo.com/icons'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).cannotOpenLink)),
      );
    }
  }

  static Future<void> _confirmReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        icon: Icon(Icons.delete_forever_outlined, color: colorScheme.error),
        title: Text(l10n.resetAllDataTitle),
        content: Text(l10n.resetAllDataMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: ButtonLabel(l10n.cancel),
          ),
          FilledButton(
            key: const ValueKey('reset-all-data-confirm'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: ButtonLabel(l10n.resetAllDataConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final success = await context.read<FinanceProvider>().resetAllData();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? l10n.resetAllDataSuccess : l10n.resetAllDataFailed,
        ),
      ),
    );
  }
}

class _ResetDataTile extends StatelessWidget {
  const _ResetDataTile({required this.isSaving, required this.onTap});

  final bool isSaving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        key: const ValueKey('reset-all-data'),
        minTileHeight: 60,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        onTap: isSaving ? null : onTap,
        leading: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.delete_sweep_outlined,
            color: colorScheme.onError,
            size: 21,
          ),
        ),
        title: Text(
          l10n.resetAllData,
          style: TextStyle(
            color: colorScheme.onErrorContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
        trailing: isSaving
            ? SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.error,
                ),
              )
            : Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onErrorContainer,
              ),
      ),
    );
  }
}

class _ManageTile extends StatelessWidget {
  const _ManageTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.tileKey,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Key? tileKey;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      key: tileKey,
      minTileHeight: 58,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: colors.onPrimary, size: 21),
      ),
      title: Text(title),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1) const SizedBox(height: 1),
          ],
        ],
      ),
    );
  }
}
