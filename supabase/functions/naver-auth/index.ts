import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

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

  // 4. Magic link 생성
  const { data: linkData, error: linkError } = await supabaseAdmin.auth.admin.generateLink({
    type: 'magiclink',
    email: userEmail,
    options: { redirectTo: 'com.bebetap.app://login-callback' },
  })

  if (linkError || !linkData) {
    return new Response(`Link generation failed: ${linkError?.message}`, { status: 500 })
  }

  // 5. action_link을 서버에서 직접 호출 → com.bebetap.app://login-callback#refresh_token=... 캡처
  const verifyRes = await fetch(linkData.properties.action_link, {
    method: 'GET',
    redirect: 'manual',
  })

  const location = verifyRes.headers.get('Location') ?? ''
  if (!location.startsWith('com.bebetap.app://')) {
    return new Response(`Unexpected redirect location: ${location}`, { status: 500 })
  }

  // URL fragment에서 refresh_token 파싱
  const fragment = location.includes('#') ? location.split('#')[1] : ''
  const params = new URLSearchParams(fragment)
  const refreshToken = params.get('refresh_token')

  if (!refreshToken) {
    return new Response(`refresh_token not found in redirect: ${location}`, { status: 500 })
  }

  // 6. Flutter가 setSession(refreshToken)으로 세션 생성 (Line 패턴과 동일)
  return new Response(
    JSON.stringify({ refresh_token: refreshToken }),
    { status: 200, headers: { 'Content-Type': 'application/json' } },
  )
})
