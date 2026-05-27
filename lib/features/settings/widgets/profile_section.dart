import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../gen/app_localizations.dart';
import '../../../shared/widgets/glass_button.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({
    super.key,
    required this.db,
    required this.userId,
  });

  final AppDatabase db;
  final String userId;

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final _displayNameController = TextEditingController();
  String? _lastDisplayName;

  String _displayNameKey(String userId) => 'profile_display_name_$userId';

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = widget.db;
    final userId = widget.userId;

    return FutureBuilder<String?>(
      future: db.appSettingsDao.getString(_displayNameKey(userId)),
      builder: (context, snapshot) {
        final current = snapshot.data;
        if (current != _lastDisplayName) {
          _lastDisplayName = current;
          _displayNameController.text = current ?? '';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _displayNameController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.settingsDisplayNameLabel,
                hintText: l10n.settingsDisplayNameHint,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassButton(
              label: l10n.settingsSaveProfile,
              icon: const Icon(Icons.save_rounded),
              onPressed: () async {
                final name = _displayNameController.text.trim();
                final messenger = ScaffoldMessenger.of(context);
                await db.appSettingsDao.setString(
                  _displayNameKey(userId),
                  name.isEmpty ? null : name,
                );
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.settingsProfileSaved)),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
