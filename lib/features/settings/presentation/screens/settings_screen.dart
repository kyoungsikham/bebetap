import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(context.l10n.logout, style: AppTypography.bodyLarge),
              onTap: () async {
                final db = ref.read(appDatabaseProvider);
                try {
                  await db.clearAllData();
                } catch (e) {
                  debugPrint('clearAllData error (ignored): $e');
                }
                ref.invalidate(babiesProvider);
                await Supabase.instance.client.auth.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
