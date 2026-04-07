import 'package:flutter/material.dart';

import '../../../log/domain/models/timeline_entry.dart';

@immutable
class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.babyId,
    required this.familyId,
    required this.title,
    required this.content,
    required this.entryDate,
    this.recordedBy,
    this.authorNickname,
  });

  final String id;
  final String babyId;
  final String familyId;
  final String title;
  final String content;
  final DateTime entryDate;
  final String? recordedBy;
  final String? authorNickname;

  TimelineEntry toTimelineEntry() => TimelineEntry(
        id: id,
        type: TimelineEntryType.diary,
        occurredAt: entryDate,
        title: title,
        subtitle: authorNickname ?? '작성자',
        icon: Icons.auto_stories,
        color: const Color(0xFF42A5F5),
        rawTitle: title,
        rawContent: content,
        rawRecordedBy: recordedBy,
        rawAuthorNickname: authorNickname,
      );
}
