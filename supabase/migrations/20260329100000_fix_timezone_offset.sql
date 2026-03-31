-- 기존 데이터의 타임스탬프 보정: 로컬 시간(KST, UTC+9)이 UTC 변환 없이
-- 저장되어 9시간 차이가 발생한 문제 수정.
-- 모든 타임스탬프를 9시간 앞당겨 올바른 UTC 값으로 보정.

UPDATE feeding_entries
SET started_at = started_at - interval '9 hours',
    ended_at   = ended_at   - interval '9 hours'
WHERE deleted_at IS NULL;

UPDATE diaper_entries
SET occurred_at = occurred_at - interval '9 hours'
WHERE deleted_at IS NULL;

UPDATE sleep_entries
SET started_at = started_at - interval '9 hours',
    ended_at   = ended_at   - interval '9 hours'
WHERE deleted_at IS NULL;

UPDATE temperature_entries
SET occurred_at = occurred_at - interval '9 hours'
WHERE deleted_at IS NULL;
