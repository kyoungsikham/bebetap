-- 초대 코드로 가족 조회를 위한 SECURITY DEFINER 함수
-- 기존 RLS는 자기 가족/자기가 만든 가족만 SELECT 허용하므로
-- 새 유저가 초대 코드로 합류 시 families를 조회할 수 없었음
CREATE OR REPLACE FUNCTION public.find_family_by_invite_code(code text)
RETURNS TABLE (
  id uuid,
  name text,
  invite_code text,
  created_by uuid,
  created_at timestamptz
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT f.id, f.name, f.invite_code, f.created_by, f.created_at
  FROM families f
  WHERE f.invite_code = upper(trim(code))
  LIMIT 1;
$$;
