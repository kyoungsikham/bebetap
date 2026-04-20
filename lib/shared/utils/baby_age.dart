import 'package:flutter/material.dart';

import '../extensions/l10n_ext.dart';

String babyAgeLabel(BuildContext context, DateTime birthDate) {
  final today = DateTime.now();
  final days = today
      .difference(DateTime(birthDate.year, birthDate.month, birthDate.day))
      .inDays;
  if (days < 100) {
    return context.l10n.babyAgeDays(days);
  }
  final months = (today.year - birthDate.year) * 12 +
      (today.month - birthDate.month) -
      (today.day < birthDate.day ? 1 : 0);
  final remainDays = today.day < birthDate.day
      ? today.day +
          (DateTime(today.year, today.month, 0).day - birthDate.day)
      : today.day - birthDate.day;
  if (remainDays == 0) return context.l10n.babyAgeMonths(months);
  return context.l10n.babyAgeMonthsDays(months, remainDays);
}
