import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/finance_provider.dart';
import '../widgets/button_label.dart';

class DataBackupScreen extends StatefulWidget {
  const DataBackupScreen({super.key});

  @override
  State<DataBackupScreen> createState() => _DataBackupScreenState();
}

class _DataBackupScreenState extends State<DataBackupScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dataTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_outlined),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.restoreWarning)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              minLines: 10,
              maxLines: 18,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.pasteJson,
                helperText: l10n.backupRequired,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: provider.isSaving ? null : _export,
              icon: const Icon(Icons.copy_all_outlined),
              label: ButtonLabel(l10n.copyBackup),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: provider.isSaving ? null : _loadLatestBackup,
              icon: const Icon(Icons.history_rounded),
              label: ButtonLabel(l10n.latestBackup),
            ),
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: provider.isSaving || _controller.text.trim().isEmpty
                  ? null
                  : _import,
              icon: const Icon(Icons.restore_rounded),
              label: ButtonLabel(l10n.importData),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    final value = await context.read<FinanceProvider>().exportSnapshot();
    _controller.text = value;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.dataExported)),
    );
  }

  Future<void> _loadLatestBackup() async {
    final value = await context.read<FinanceProvider>().getLatestBackup();
    if (!mounted) return;
    if (value == null || value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noBackupAvailable),
        ),
      );
      return;
    }
    _controller.text = value;
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    if (_controller.text.trim().isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importData),
        content: Text(l10n.restoreWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: ButtonLabel(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: ButtonLabel(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final success = await context
        .read<FinanceProvider>()
        .importSnapshot(_controller.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? l10n.dataImported : l10n.invalidBackup),
      ),
    );
  }
}
