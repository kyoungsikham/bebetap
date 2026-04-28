-- feeding_entries.type CHECK 제약을 갱신해 'pumped' 허용.
-- 기존 제약 이름은 PostgreSQL 자동 생성('feeding_entries_type_check').
ALTER TABLE feeding_entries
  DROP CONSTRAINT IF EXISTS feeding_entries_type_check;

ALTER TABLE feeding_entries
  ADD CONSTRAINT feeding_entries_type_check
  CHECK (type IN ('formula','breast','baby_food','pumped'));
