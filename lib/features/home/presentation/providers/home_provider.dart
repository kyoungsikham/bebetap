import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../data/home_repository.dart';
import '../../domain/models/home_summary.dart';

part 'home_provider.g.dart';

@riverpod
HomeRepository homeRepository(Ref ref) =>
    HomeRepository(ref.watch(appDatabaseProvider));

@riverpod
Future<HomeSummary> homeSummary(Ref ref) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return HomeSummary.empty();
  return ref
      .watch(homeRepositoryProvider)
      .getSummary(baby.id, babyWeightKg: baby.weightKg);
}

/// 1초마다 틱 — elapsed time 표시를 위해 UI 위젯이 구독
@riverpod
Stream<int> minuteTicker(Ref ref) =>
    Stream.periodic(const Duration(seconds: 1), (i) => i);
