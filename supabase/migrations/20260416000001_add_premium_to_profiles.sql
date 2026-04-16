-- profiles 테이블에 인앱결제(광고 제거) 상태 컬럼 추가
-- is_premium: 결제 완료 시 true, 기본값 false
-- premium_purchased_at: 최초 구매 시각 (감사 목적)
-- premium_platform: 결제 플랫폼 ('ios' | 'android' | 'manual')

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_premium boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS premium_purchased_at timestamptz,
  ADD COLUMN IF NOT EXISTS premium_platform text
    CHECK (premium_platform IN ('ios', 'android', 'manual'));

-- 기존 profiles_self 정책이 id = auth.uid() 조건으로 본인 행 전체를 허용하므로
-- 별도 RLS 정책 추가 불필요.
