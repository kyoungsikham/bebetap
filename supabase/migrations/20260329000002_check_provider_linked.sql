-- 이메일+provider 연결 상태 확인 RPC
-- 반환값: 'not_found' (이메일 미존재) | 'linked' (이미 연결됨) | 'not_linked' (미연결)
CREATE OR REPLACE FUNCTION public.check_provider_linked(
  check_email TEXT,
  check_provider TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  found_user_id uuid;
BEGIN
  SELECT id INTO found_user_id FROM auth.users WHERE email = lower(check_email);
  IF found_user_id IS NULL THEN
    RETURN 'not_found';
  END IF;

  IF EXISTS (
    SELECT 1 FROM auth.identities
    WHERE user_id = found_user_id AND provider = check_provider
  ) THEN
    RETURN 'linked';
  END IF;

  RETURN 'not_linked';
END;
$$;

GRANT EXECUTE ON FUNCTION public.check_provider_linked(TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.check_provider_linked(TEXT, TEXT) TO authenticated;
