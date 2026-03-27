-- families.created_by의 FK 제약(→ profiles) 제거
-- profiles row가 없는 유저가 가족 생성 시 FK 위반 → INSERT 실패 방지
-- created_by 컬럼은 uuid로 유지 (값은 auth.uid() 저장)
ALTER TABLE public.families
  DROP CONSTRAINT IF EXISTS families_created_by_fkey;
