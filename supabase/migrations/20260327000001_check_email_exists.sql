-- 이메일 존재 여부 확인 RPC (회원가입 시 중복 체크용)
-- auth.users는 클라이언트에서 직접 접근 불가하므로 SECURITY DEFINER 함수로 래핑
CREATE OR REPLACE FUNCTION public.check_email_exists(check_email TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM auth.users WHERE email = lower(check_email)
  );
END;
$$;

-- anon/authenticated 역할 모두 호출 가능
GRANT EXECUTE ON FUNCTION public.check_email_exists(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.check_email_exists(TEXT) TO authenticated;
