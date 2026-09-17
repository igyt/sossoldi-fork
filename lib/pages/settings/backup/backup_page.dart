import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../providers/settings_provider.dart';
import '../../../services/backup/drive_backup_service.dart';
import '../../../services/backup/drive_oauth_config.dart';
import '../../../services/csv/csv_file_picker.dart';
import '../../../services/database/sossoldi_database.dart';
import '../../../ui/device.dart';
import '../../../ui/snack_bars/snack_bar.dart';
import '../../../ui/widgets/default_card.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  final _drive = DriveBackupService.instance;
  GoogleSignInAccount? _driveUser;
  bool _driveReady = false;

  @override
  void initState() {
    super.initState();
    _restoreDriveSession();
  }

  Future<void> _restoreDriveSession() async {
    if (!_drive.isSupported || !_drive.isConfigured) {
      if (mounted) setState(() => _driveReady = true);
      return;
    }
    try {
      final user = await _drive.restoreSession();
      if (mounted) {
        setState(() {
          _driveUser = user;
          _driveReady = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _driveReady = true);
    }
  }

  Future<void> _handleImport() async {
    try {
      final file = await CSVFilePicker.pickCSVFile(context);
      if (file != null) {
        if (!mounted) return;
        CSVFilePicker.showLoading(context, 'Importing data...');
        final results = await SossoldiDatabase.instance.importFromCSV(
          file.path,
        );
        if (!mounted) return;
        CSVFilePicker.hideLoading(context);

        if (results.values.every((success) => success)) {
          await CSVFilePicker.showSuccess(
            context,
            'Data imported successfully',
          );
          if (mounted) Phoenix.rebirth(context);
        } else {
          final failedTables = results.entries
              .where((e) => !e.value)
              .map((e) => e.key)
              .join(', ');

          if (!mounted) return;

          showSnackBar(
            context,
            message: 'Failed to import some tables: $failedTables',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      CSVFilePicker.hideLoading(context);

      showSnackBar(context, message: 'Import failed: ${e.toString()}');
    }
  }

  Future<void> _handleExport() async {
    try {
      CSVFilePicker.showLoading(context, 'Exporting data...');

      final csv = await SossoldiDatabase.instance.exportToCSV();

      if (!mounted) return;
      CSVFilePicker.hideLoading(context);

      await CSVFilePicker.saveCSVFile(csv, context);
    } catch (e) {
      if (!mounted) return;
      CSVFilePicker.hideLoading(context);
      showSnackBar(context, message: 'Export failed: ${e.toString()}');
    }
  }

  Future<void> _handleDriveSignIn() async {
    try {
      final user = await _drive.signIn();
      if (mounted) setState(() => _driveUser = user);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      if (mounted) {
        await _showDriveError(describeDriveAuthError(e));
      }
    } catch (e) {
      if (mounted) {
        await _showDriveError(describeDriveAuthError(e));
      }
    }
  }

  Future<void> _showDriveError(String message) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Drive'),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDriveSignOut() async {
    try {
      await _drive.signOut();
      if (mounted) setState(() => _driveUser = null);
    } catch (e) {
      if (mounted) showSnackBar(context, message: e.toString());
    }
  }

  Future<void> _handleDriveBackup() async {
    try {
      CSVFilePicker.showLoading(context, 'Uploading to Drive...');
      final csv = await SossoldiDatabase.instance.exportToCSV();
      await _drive.uploadCsv(csv);
      final prefs = ref.read(sharedPrefProvider);
      await prefs.setInt(
        driveLastBackupMsPref,
        DateTime.now().millisecondsSinceEpoch,
      );
      if (!mounted) return;
      CSVFilePicker.hideLoading(context);
      await CSVFilePicker.showSuccess(context, 'Backup uploaded to Drive');
    } catch (e) {
      if (!mounted) return;
      CSVFilePicker.hideLoading(context);
      showSnackBar(context, message: 'Drive backup failed: $e');
    }
  }

  Future<void> _handleDriveRestore() async {
    try {
      CSVFilePicker.showLoading(context, 'Loading backups...');
      final files = await _drive.listBackups();
      if (!mounted) return;
      CSVFilePicker.hideLoading(context);

      if (files.isEmpty) {
        showSnackBar(context, message: 'No Drive backups found');
        return;
      }

      final selected = await showDialog<DriveBackupFile>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('Restore Drive backup'),
          children: files
              .map(
                (file) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, file),
                  child: Text(file.name),
                ),
              )
              .toList(),
        ),
      );
      if (selected == null || !mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning: Data Overwrite'),
          content: const Text(
            'Importing this file will permanently replace your existing data. This action cannot be undone. Ensure you have a backup before proceeding.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Proceed with Import'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      CSVFilePicker.showLoading(context, 'Restoring from Drive...');
      final csv = await _drive.downloadCsv(selected.id);
      final dir = await getTemporaryDirectory();
      final path = p.join(dir.path, 'sossoldi-drive-restore.csv');
      await File(path).writeAsString(csv);
      final results = await SossoldiDatabase.instance.importFromCSV(path);
      if (!mounted) return;
      CSVFilePicker.hideLoading(context);

      if (results.values.every((success) => success)) {
        await CSVFilePicker.showSuccess(context, 'Data restored from Drive');
        if (mounted) Phoenix.rebirth(context);
      } else {
        showSnackBar(context, message: 'Restore failed for some tables');
      }
    } catch (e) {
      if (!mounted) return;
      CSVFilePicker.hideLoading(context);
      showSnackBar(context, message: 'Drive restore failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPrefProvider);
    final backupOnOpen = prefs.getBool(driveBackupOnOpenPref) ?? false;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Import/Export'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: Sizes.xl, bottom: Sizes.xl),
        children: [
          _BackupCard(
            icon: Icons.upload_file,
            title: 'Import data',
            description: 'Import a CSV file to update your database',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Warning: Data Overwrite'),
                  content: const Text(
                    'Importing this file will permanently replace your existing data. This action cannot be undone. Ensure you have a backup before proceeding.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _handleImport();
                      },
                      child: const Text('Proceed with Import'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: Sizes.lg),
          _BackupCard(
            icon: Icons.download,
            title: 'Export data',
            description: 'Save your data as a CSV file',
            onTap: _handleExport,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Sizes.lg,
              Sizes.xxl,
              Sizes.lg,
              Sizes.sm,
            ),
            child: Text(
              'GOOGLE DRIVE',
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: primary),
            ),
          ),
          if (!_drive.isSupported)
            _BackupCard(
              icon: Icons.cloud_off,
              title: 'Not available here',
              description:
                  'Google Drive backup works on Android. Build the APK to use it on your phone.',
              onTap: () {},
            )
          else if (!DriveOAuthConfig.isConfigured)
            _BackupCard(
              icon: Icons.cloud_off,
              title: 'Drive not configured',
              description:
                  'Create a Google Cloud Web OAuth client and rebuild with --dart-define=GOOGLE_OAUTH_WEB_CLIENT_ID=...',
              onTap: () {},
            )
          else ...[
            _BackupCard(
              icon: Icons.account_circle,
              title: _driveUser == null
                  ? 'Sign in with Google'
                  : (_driveUser!.displayName ?? _driveUser!.email),
              description: _driveUser == null
                  ? 'Connect your Google account to back up to Drive'
                  : 'Tap to sign out',
              onTap: _driveReady
                  ? (_driveUser == null
                        ? _handleDriveSignIn
                        : _handleDriveSignOut)
                  : () {},
            ),
            const SizedBox(height: Sizes.lg),
            _BackupCard(
              icon: Icons.cloud_upload,
              title: 'Backup to Drive',
              description: 'Upload a CSV into the Sossoldi folder in Drive',
              onTap: _driveUser == null
                  ? () => showSnackBar(
                      context,
                      message: 'Sign in with Google first',
                    )
                  : _handleDriveBackup,
            ),
            const SizedBox(height: Sizes.lg),
            _BackupCard(
              icon: Icons.cloud_download,
              title: 'Restore from Drive',
              description: 'Replace local data with a Drive backup',
              onTap: _driveUser == null
                  ? () => showSnackBar(
                      context,
                      message: 'Sign in with Google first',
                    )
                  : _handleDriveRestore,
            ),
            const SizedBox(height: Sizes.lg),
            DefaultCard(
              onTap: _driveUser == null
                  ? () {}
                  : () async {
                      final next = !backupOnOpen;
                      await prefs.setBool(driveBackupOnOpenPref, next);
                      setState(() {});
                    },
              child: Row(
                children: [
                  Icon(Icons.schedule, color: primary, size: 32),
                  const SizedBox(width: Sizes.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Backup when the app opens',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge!.copyWith(color: primary),
                        ),
                        const SizedBox(height: Sizes.xs),
                        Text(
                          'If you are signed in, upload once per day on launch',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(color: primary),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: backupOnOpen,
                    onChanged: _driveUser == null
                        ? null
                        : (value) async {
                            await prefs.setBool(driveBackupOnOpenPref, value);
                            setState(() {});
                          },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BackupCard extends StatelessWidget {
  const _BackupCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return DefaultCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: primary, size: 32),
          const SizedBox(width: Sizes.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(color: primary),
                ),
                const SizedBox(height: Sizes.xs),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: primary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: primary),
        ],
      ),
    );
  }
}
