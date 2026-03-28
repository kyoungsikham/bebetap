-- profiles 테이블에 명시적 INSERT 정책 추가
-- 기존 "profiles_self" 정책은 USING만 있어서 INSERT WITH CHECK가 암묵적으로 처리됨
-- 명시적으로 INSERT 정책을 분리하여 확실히 허용

DROP POLICY IF EXISTS "profiles_self" ON profiles;

-- SELECT / UPDATE / DELETE: 자신의 row만
CREATE POLICY "profiles_select" ON profiles FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "profiles_insert" ON profiles FOR INSERT
  WITH CHECK (id = auth.uid());

CREATE POLICY "profiles_update" ON profiles FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());
