-- on_auth_user_created 트리거를 public.handle_new_user()로 재연결
-- (v1 마이그레이션에서 schema prefix 없이 생성된 트리거 수정)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
