-- families_read: 생성자도 즉시 읽을 수 있도록 수정
-- INSERT 후 .select() 호출 시 family_members에 아직 등록 전이라
-- get_my_family_ids()가 빈 결과 → SELECT 실패하는 문제 해결
DROP POLICY IF EXISTS "families_read" ON families;
CREATE POLICY "families_read" ON families FOR SELECT
  USING (
    id IN (SELECT public.get_my_family_ids())
    OR created_by = auth.uid()
  );
