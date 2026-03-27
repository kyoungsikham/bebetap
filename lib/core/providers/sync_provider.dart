import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../sync/sync_engine.dart';
import 'database_provider.dart';

part 'sync_provider.g.dart';

@Riverpod(keepAlive: true)
SyncEngine syncEngine(Ref ref) {
  return SyncEngine(
    ref.watch(appDatabaseProvider),
    Supabase.instance.client,
  );
}
