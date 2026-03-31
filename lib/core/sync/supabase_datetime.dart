/// Supabase에서 받은 timestamp 문자열을 안전하게 로컬 DateTime으로 변환.
/// Supabase는 항상 UTC로 저장하지만, Realtime 등에서 timezone 정보 없이
/// 반환될 수 있으므로 `isUtc == false`이면 UTC로 간주한다.
DateTime parseSupabaseDateTime(String s) {
  final parsed = DateTime.parse(s);
  if (parsed.isUtc) return parsed.toLocal();
  return DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
    parsed.microsecond,
  ).toLocal();
}
