import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const NAVER_CLIENT_ID = Deno.env.get('NAVER_CLIENT_ID')!

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 })
  }

  const { access_token } = await req.json()
  if (!access_token) {
    return new Response('Missing access_token', { status: 400 })
  }

  // 1. Naver 프로필 조회
  const profileRes = await fetch('https://openapi.naver.com/v1/nid/me', {
    headers: { Authorization: `Bearer ${access_token}` },
  })

  if (!profileRes.ok) {
    const err = await profileRes.text()
    return new Response(`Naver profile error: ${err}`, { status: 400 })
  }

  const profileJson = await profileRes.json()
  const profile = profileJson.response as {
    id: string
    email?: string
    name?: string
    profile_image?: string
  }

  const naverId = profile.id
  const naverEmail = profile.email
  const naverName = profile.name ?? 'Naver User'
  const naverPicture = profile.profile_image
  // 이메일 미동의 시 결정론적 fallback
  const userEmail = naverEmail ?? `naver_${naverId}@naver.bebetap.app`

  // 2. Supabase Admin 클라이언트
  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { autoRefreshToken: false, persistSession: false } },
  )

  // 3. 유저 생성 (이미 존재하면 에러 무시)
  await supabaseAdmin.auth.admin.createUser({
    email: userEmail,
    email_confirm: true,
    user_metadata: {
      provider: 'naver',
      naver_id: naverId,
      full_name: naverName,
      avatar_url: naverPicture,
    },
  })

  // 4. Magic link 생성 → hashed_token 추출
  const { data: linkData, error: linkError } = await supabaseAdmin.auth.admin.generateLink({
    type: 'magiclink',
    email: userEmail,
    options: {
      redirectTo: 'com.bebetap.app://login-callback',
    },
  })

  if (linkError || !linkData) {
    return new Response(`Link generation failed: ${linkError?.message}`, { status: 500 })
  }

  // 5. Flutter가 verifyOTP(tokenHash, type: magiclink)로 세션 생성
  return new Response(
    JSON.stringify({
      token_hash: linkData.properties.hashed_token,
      email: userEmail,
    }),
    {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    },
  )
})
