-- ============================================================
-- BebeTap 초기 스키마
-- ============================================================

-- -------------------------------------------------------
-- profiles (auth.users 1:1 미러)
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS profiles (
  id          uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text,
  avatar_url  text,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "profiles_self" ON profiles USING (id = auth.uid());

-- -------------------------------------------------------
-- families
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS families (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  invite_code text UNIQUE NOT NULL DEFAULT '',
  created_by  uuid REFERENCES profiles(id),
  created_at  timestamptz DEFAULT now()
);

-- 초대 코드 자동 생성 함수
CREATE OR REPLACE FUNCTION set_family_invite_code() RETURNS TRIGGER AS $$
BEGIN
  LOOP
    NEW.invite_code := 'BT-' || upper(substring(md5(random()::text), 1, 4));
    EXIT WHEN NOT EXISTS (SELECT 1 FROM families WHERE invite_code = NEW.invite_code);
  END LOOP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER before_insert_family
  BEFORE INSERT ON families FOR EACH ROW EXECUTE FUNCTION set_family_invite_code();

-- -------------------------------------------------------
-- family_members
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS family_members (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id  uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  user_id    uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role       text NOT NULL DEFAULT 'caregiver' CHECK (role IN ('owner','caregiver')),
  joined_at  timestamptz DEFAULT now(),
  UNIQUE (family_id, user_id)
);

-- -------------------------------------------------------
-- families RLS (family_members 생성 후 적용)
-- -------------------------------------------------------
ALTER TABLE families ENABLE ROW LEVEL SECURITY;

CREATE POLICY "families_read" ON families FOR SELECT
  USING (id IN (SELECT family_id FROM family_members WHERE user_id = auth.uid()));

CREATE POLICY "families_insert" ON families FOR INSERT
  WITH CHECK (created_by = auth.uid());

CREATE POLICY "families_update" ON families FOR UPDATE
  USING (created_by = auth.uid());

-- -------------------------------------------------------
-- family_members RLS
-- -------------------------------------------------------
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "family_members_read" ON family_members FOR SELECT
  USING (family_id IN (SELECT family_id FROM family_members WHERE user_id = auth.uid()));

CREATE POLICY "family_members_insert" ON family_members FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "family_members_delete" ON family_members FOR DELETE
  USING (user_id = auth.uid());

-- -------------------------------------------------------
-- babies
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS babies (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id   uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  name        text NOT NULL,
  birth_date  date NOT NULL,
  gender      text DEFAULT 'unknown' CHECK (gender IN ('male','female','unknown')),
  weight_kg   numeric(5,3),
  photo_url   text,
  is_active   boolean DEFAULT true,
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE babies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "babies_read" ON babies FOR SELECT
  USING (family_id IN (SELECT family_id FROM family_members WHERE user_id = auth.uid()));

CREATE POLICY "babies_insert" ON babies FOR INSERT
  WITH CHECK (family_id IN (SELECT family_id FROM family_members WHERE user_id = auth.uid()));

CREATE POLICY "babies_update" ON babies FOR UPDATE
  USING (family_id IN (SELECT family_id FROM family_members WHERE user_id = auth.uid()));

-- -------------------------------------------------------
-- feeding_entries
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS feeding_entries (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id              uuid NOT NULL REFERENCES babies(id) ON DELETE CASCADE,
  family_id            uuid NOT NULL REFERENCES families(id),
  recorded_by          uuid REFERENCES profiles(id),
  type                 text NOT NULL CHECK (type IN ('formula','breast','baby_food')),
  amount_ml            integer,
  duration_left_sec    integer,
  duration_right_sec   integer,
  started_at           timestamptz NOT NULL,
  ended_at             timestamptz,
  notes                text,
  local_id             text UNIQUE,
  created_at           timestamptz DEFAULT now(),
  updated_at           timestamptz DEFAULT now(),
  deleted_at           timestamptz
);

ALTER TABLE feeding_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "feeding_read" ON feeding_entries FOR SELECT
  USING (family_id IN (SELECT family_id FROM family_members WHERE user_id = auth.uid()));

CREATE POLICY "feeding_insert" ON feeding_entries FOR INSERT
  WITH CHECK (
    family_id IN (SELECT family_id FROM family_members WHERE user_id = auth.uid())
    AND recorded_by = auth.uid()
  );

CREATE POLICY "feeding_update" ON feeding_entries FOR UPDATE
  USING (recorded_by = auth.uid() AND created_at > now() - interval '24 hours');

-- -------------------------------------------------------
-- diaper_entries
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS diaper_entries (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id     uuid NOT NULL REFERENCES babies(id) ON DELETE CASCADE,
  family_id   uuid NOT NULL REFERENCES families(id),
  recorded_by uuid REFERENCES profiles(id),
  type        text NOT NULL CHECK (type IN ('wet','soiled','both','dry')),
  occurred_at timestamptz NOT NULL,
  local_id    text UNIQUE,
  created_at  timestamptz DEFAULT now(),
  deleted_at  timestamptz
);

ALTER TABLE diaper_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "diaper_read" ON diaper_entries FOR SELECT
  USING (family_id IN (SELECT family_id FROM family_members WHERE user_id = auth.uid()));

CREATE POLICY "diaper_insert" ON diaper_entries FOR INSERT
  WITH CHECK (
    family_id IN (SELECT family_id FROM family_members WHERE user_id = auth.uid())
    AND recorded_by = auth.uid()
  );

CREATE POLICY "diaper_update" ON diaper_entries FOR UPDATE
  USING (recorded_by = auth.uid() AND created_at > now() - interval '24 hours');

-- -------------------------------------------------------
-- sleep_entries
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS sleep_entries (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id     uuid NOT NULL REFERENCES babies(id) ON DELETE CASCADE,
  family_id   uuid NOT NULL REFERENCES families(id),
  recorded_by uuid REFERENCES profiles(id),
  started_at  timestamptz NOT NULL,
  ended_at    timestamptz,
  quality     text CHECK (quality IN ('good','fair','poor')),
  local_id    text UNIQUE,
  created_at  timestamptz DEFAULT now(),
  deleted_at  timestamptz
);

ALTER TABLE sleep_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sleep_read" ON sleep_entries FOR SELECT
  USING (family_id IN (SELECT family_id FROM family_members WHERE user_id = auth.uid()));

CREATE POLICY "sleep_insert" ON sleep_entries FOR INSERT
  WITH CHECK (
    family_id IN (SELECT family_id FROM family_members WHERE user_id = auth.uid())
    AND recorded_by = auth.uid()
  );

CREATE POLICY "sleep_update" ON sleep_entries FOR UPDATE
  USING (recorded_by = auth.uid() AND created_at > now() - interval '24 hours');

-- -------------------------------------------------------
-- temperature_entries
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS temperature_entries (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_id     uuid NOT NULL REFERENCES babies(id) ON DELETE CASCADE,
  family_id   uuid NOT NULL REFERENCES families(id),
  recorded_by uuid REFERENCES profiles(id),
  celsius     numeric(4,1) NOT NULL,
  method      text NOT NULL CHECK (method IN ('rectal','axillary','ear','forehead')),
  occurred_at timestamptz NOT NULL,
  local_id    text UNIQUE,
  created_at  timestamptz DEFAULT now(),
  deleted_at  timestamptz
);

ALTER TABLE temperature_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "temperature_read" ON temperature_entries FOR SELECT
  USING (family_id IN (SELECT family_id FROM family_members WHERE user_id = auth.uid()));

CREATE POLICY "temperature_insert" ON temperature_entries FOR INSERT
  WITH CHECK (
    family_id IN (SELECT family_id FROM family_members WHERE user_id = auth.uid())
    AND recorded_by = auth.uid()
  );

CREATE POLICY "temperature_update" ON temperature_entries FOR UPDATE
  USING (recorded_by = auth.uid() AND created_at > now() - interval '24 hours');

-- -------------------------------------------------------
-- 인덱스 (성능 최적화)
-- -------------------------------------------------------
CREATE INDEX idx_feeding_baby_started  ON feeding_entries(baby_id, started_at DESC)  WHERE deleted_at IS NULL;
CREATE INDEX idx_diaper_baby_occurred  ON diaper_entries(baby_id, occurred_at DESC)  WHERE deleted_at IS NULL;
CREATE INDEX idx_sleep_baby_started    ON sleep_entries(baby_id, started_at DESC)    WHERE deleted_at IS NULL;
CREATE INDEX idx_temp_baby_occurred    ON temperature_entries(baby_id, occurred_at DESC) WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX idx_families_invite ON families(invite_code);

-- -------------------------------------------------------
-- updated_at 자동 갱신 트리거
-- -------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at() RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_feeding_updated_at
  BEFORE UPDATE ON feeding_entries FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- profiles 자동 생성 (auth.users 회원가입 시)
CREATE OR REPLACE FUNCTION handle_new_user() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, display_name, avatar_url)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'avatar_url')
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();
