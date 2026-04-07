-- 데이터만 초기화 (스키마/정책/함수/트리거 유지)
TRUNCATE TABLE
  temperature_entries,
  sleep_entries,
  diaper_entries,
  feeding_entries,
  babies,
  family_members,
  families,
  profiles
CASCADE;

DELETE FROM auth.users;
