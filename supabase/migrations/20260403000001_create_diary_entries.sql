-- diary_entries: 하루에 글쓴이당 한 개의 아기 일기
CREATE TABLE IF NOT EXISTS diary_entries (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id         uuid NOT NULL REFERENCES babies(id) ON DELETE CASCADE,
  family_id       uuid NOT NULL REFERENCES families(id),
  recorded_by     uuid REFERENCES profiles(id),
  title           text NOT NULL,
  content         text NOT NULL,
  entry_date      date NOT NULL,
  author_nickname text,
  local_id        text UNIQUE,
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now(),
  deleted_at      timestamptz
);

-- 글쓴이당 하루 1개 제약 (soft-delete 행 제외)
CREATE UNIQUE INDEX diary_unique_per_author_day
  ON diary_entries (baby_id, recorded_by, entry_date)
  WHERE deleted_at IS NULL;

-- RLS
ALTER TABLE diary_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "diary_read" ON diary_entries FOR SELECT
  USING (
    family_id IN (
      SELECT family_id FROM family_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "diary_insert" ON diary_entries FOR INSERT
  WITH CHECK (
    family_id IN (
      SELECT family_id FROM family_members WHERE user_id = auth.uid()
    )
    AND recorded_by = auth.uid()
  );

CREATE POLICY "diary_update" ON diary_entries FOR UPDATE
  USING (recorded_by = auth.uid());

-- updated_at 자동 갱신 트리거
CREATE TRIGGER set_diary_updated_at
  BEFORE UPDATE ON diary_entries
  FOR EACH ROW EXECUTE FUNCTION moddatetime(updated_at);
