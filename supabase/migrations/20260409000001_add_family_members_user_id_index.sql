-- family_members.user_id 인덱스 추가
-- 모든 RLS 정책에서 호출되는 get_my_family_ids() 함수가
-- 이 컬럼으로 조회하므로 인덱스가 없으면 full table scan 발생
CREATE INDEX IF NOT EXISTS idx_family_members_user_id
  ON public.family_members (user_id);
