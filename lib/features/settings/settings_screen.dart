import 'package:flutter/material.dart';

import '../../core/models.dart';
import '../../core/services/local_store_service.dart';
import '../../core/services/onedrive_sync_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.syncService,
    required this.localStore,
    required this.yearPlan,
  });

  final OneDriveSyncService syncService;
  final LocalStoreService localStore;
  final YearPlan yearPlan;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _passphraseController = TextEditingController();
  String _status = 'Ready';

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _sync() async {
    final passphrase = _passphraseController.text.trim();
    if (passphrase.isEmpty) {
      setState(() {
        _status = 'Enter passphrase before sync.';
      });
      return;
    }

    await widget.localStore.savePlan(widget.yearPlan);
    await widget.syncService.syncEncryptedBackup(widget.yearPlan, passphrase: passphrase);

    setState(() {
      _status = 'Sync requested (service implementation pending).';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Mode: Local-first with optional encrypted OneDrive sync.'),
        const SizedBox(height: 12),
        TextField(
          controller: _passphraseController,
          obscureText: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Encryption passphrase',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _sync,
          icon: const Icon(Icons.cloud_upload),
          label: const Text('Sync to OneDrive'),
        ),
        const SizedBox(height: 8),
        Text('Status: $_status'),
      ],
    );
  }
}
