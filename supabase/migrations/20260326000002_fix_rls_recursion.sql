-- ============================================================
-- RLS 무한 재귀 수정
-- family_members 정책이 자기 자신을 참조하는 문제 해결
-- SECURITY DEFINER 헬퍼 함수로 RLS 우회 후 서브쿼리 교체
-- ============================================================

-- 1. 헬퍼 함수 생성 (SECURITY DEFINER = RLS 우회)
CREATE OR REPLACE FUNCTION public.get_my_family_ids()
RETURNS SETOF uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT family_id FROM public.family_members WHERE user_id = auth.uid();
$$;

-- 2. family_members RLS 재생성 (자기참조 → 함수 사용)
DROP POLICY IF EXISTS "family_members_read" ON family_members;
CREATE POLICY "family_members_read" ON family_members FOR SELECT
  USING (family_id IN (SELECT public.get_my_family_ids()));

-- 3. families RLS 재생성
DROP POLICY IF EXISTS "families_read" ON families;
CREATE POLICY "families_read" ON families FOR SELECT
  USING (id IN (SELECT public.get_my_family_ids()));

-- 4. babies RLS 재생성
DROP POLICY IF EXISTS "babies_read"   ON babies;
DROP POLICY IF EXISTS "babies_insert" ON babies;
DROP POLICY IF EXISTS "babies_update" ON babies;

CREATE POLICY "babies_read" ON babies FOR SELECT
  USING (family_id IN (SELECT public.get_my_family_ids()));
CREATE POLICY "babies_insert" ON babies FOR INSERT
  WITH CHECK (family_id IN (SELECT public.get_my_family_ids()));
CREATE POLICY "babies_update" ON babies FOR UPDATE
  USING (family_id IN (SELECT public.get_my_family_ids()));

-- 5. feeding_entries RLS 재생성
DROP POLICY IF EXISTS "feeding_read"   ON feeding_entries;
DROP POLICY IF EXISTS "feeding_insert" ON feeding_entries;
DROP POLICY IF EXISTS "feeding_update" ON feeding_entries;

CREATE POLICY "feeding_read" ON feeding_entries FOR SELECT
  USING (family_id IN (SELECT public.get_my_family_ids()));
CREATE POLICY "feeding_insert" ON feeding_entries FOR INSERT
  WITH CHECK (family_id IN (SELECT public.get_my_family_ids()) AND recorded_by = auth.uid());
CREATE POLICY "feeding_update" ON feeding_entries FOR UPDATE
  USING (recorded_by = auth.uid() AND created_at > now() - interval '24 hours');

-- 6. diaper_entries RLS 재생성
DROP POLICY IF EXISTS "diaper_read"   ON diaper_entries;
DROP POLICY IF EXISTS "diaper_insert" ON diaper_entries;
DROP POLICY IF EXISTS "diaper_update" ON diaper_entries;

CREATE POLICY "diaper_read" ON diaper_entries FOR SELECT
  USING (family_id IN (SELECT public.get_my_family_ids()));
CREATE POLICY "diaper_insert" ON diaper_entries FOR INSERT
  WITH CHECK (family_id IN (SELECT public.get_my_family_ids()) AND recorded_by = auth.uid());
CREATE POLICY "diaper_update" ON diaper_entries FOR UPDATE
  USING (recorded_by = auth.uid() AND created_at > now() - interval '24 hours');

-- 7. sleep_entries RLS 재생성
DROP POLICY IF EXISTS "sleep_read"   ON sleep_entries;
DROP POLICY IF EXISTS "sleep_insert" ON sleep_entries;
DROP POLICY IF EXISTS "sleep_update" ON sleep_entries;

CREATE POLICY "sleep_read" ON sleep_entries FOR SELECT
  USING (family_id IN (SELECT public.get_my_family_ids()));
CREATE POLICY "sleep_insert" ON sleep_entries FOR INSERT
  WITH CHECK (family_id IN (SELECT public.get_my_family_ids()) AND recorded_by = auth.uid());
CREATE POLICY "sleep_update" ON sleep_entries FOR UPDATE
  USING (recorded_by = auth.uid() AND created_at > now() - interval '24 hours');

-- 8. temperature_entries RLS 재생성
DROP POLICY IF EXISTS "temperature_read"   ON temperature_entries;
DROP POLICY IF EXISTS "temperature_insert" ON temperature_entries;
DROP POLICY IF EXISTS "temperature_update" ON temperature_entries;

CREATE POLICY "temperature_read" ON temperature_entries FOR SELECT
  USING (family_id IN (SELECT public.get_my_family_ids()));
CREATE POLICY "temperature_insert" ON temperature_entries FOR INSERT
  WITH CHECK (family_id IN (SELECT public.get_my_family_ids()) AND recorded_by = auth.uid());
CREATE POLICY "temperature_update" ON temperature_entries FOR UPDATE
  USING (recorded_by = auth.uid() AND created_at > now() - interval '24 hours');
