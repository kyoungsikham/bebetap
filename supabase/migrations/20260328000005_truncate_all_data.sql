-- 모든 데이터 + auth.users 전체 초기화
TRUNCATE TABLE temperature_entries CASCADE;
TRUNCATE TABLE sleep_entries CASCADE;
TRUNCATE TABLE diaper_entries CASCADE;
TRUNCATE TABLE feeding_entries CASCADE;
TRUNCATE TABLE babies CASCADE;
TRUNCATE TABLE family_members CASCADE;
TRUNCATE TABLE families CASCADE;
TRUNCATE TABLE profiles CASCADE;
DELETE FROM auth.users;
