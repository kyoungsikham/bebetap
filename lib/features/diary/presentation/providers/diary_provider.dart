import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../family/presentation/providers/family_provider.dart';
import '../../../log/presentation/providers/log_provider.dart';
import '../../data/diary_repository_impl.dart';
import '../../domain/models/diary_entry.dart';

part 'diary_provider.g.dart';

@riverpod
DiaryRepository diaryRepository(Ref ref) =>
    DiaryRepository(ref.watch(appDatabaseProvider));

/// 오늘 날짜에 현재 로그인 사용자가 쓴 일기 (있으면 반환, 없으면 null)
@riverpod
Future<DiaryEntry?> todayDiaryForCurrentUser(Ref ref) async {
  final baby = ref.watch(selectedBabyProvider).valueOrNull;
  if (baby == null) return null;
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;
  return ref
      .watch(diaryRepositoryProvider)
      .getTodayDiaryForAuthor(baby.id, userId);
}

@riverpod
class DiaryNotifier extends _$DiaryNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> saveDiary({
    required String title,
    required String content,
  }) async {
    final baby = ref.read(selectedBabyProvider).valueOrNull;
    if (baby == null) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final existing = await ref
        .read(diaryRepositoryProvider)
        .getTodayDiaryForAuthor(baby.id, userId);
    if (existing != null) {
      return updateDiary(existing.id, title: title, content: content);
    }

    final members = await ref.read(familyMembersProvider.future);
    final nickname = members
            .where((m) => m.userId == userId)
            .firstOrNull
            ?.nickname ??
        '작성자';

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(diaryRepositoryProvider).saveDiary(
            babyId: baby.id,
            familyId: baby.familyId,
            title: title,
            content: content,
            entryDate: DateTime.now(),
            recordedBy: userId,
            authorNickname: nickname,
          );
      ref.invalidate(todayDiaryForCurrentUserProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
    });
  }

  Future<void> updateDiary(
    String id, {
    required String title,
    required String content,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(diaryRepositoryProvider)
          .updateDiary(id, title: title, content: content);
      ref.invalidate(todayDiaryForCurrentUserProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
    });
  }
}
