-- families INSERT/UPDATE 정책 교체 (DROP IF EXISTS로 안전하게)
DROP POLICY IF EXISTS "families_insert" ON families;
CREATE POLICY "families_insert" ON families FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "families_update" ON families;
CREATE POLICY "families_update" ON families FOR UPDATE
  USING (id IN (SELECT public.get_my_family_ids()));

-- family_members INSERT/UPDATE 정책 추가
DROP POLICY IF EXISTS "family_members_insert" ON family_members;
CREATE POLICY "family_members_insert" ON family_members FOR INSERT
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "family_members_update" ON family_members;
CREATE POLICY "family_members_update" ON family_members FOR UPDATE
  USING (user_id = auth.uid());
