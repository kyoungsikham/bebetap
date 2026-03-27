import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const LINE_CHANNEL_ID = Deno.env.get('LINE_CHANNEL_ID')!
const LINE_CHANNEL_SECRET = Deno.env.get('LINE_CHANNEL_SECRET')!

Deno.serve(async (req: Request) => {
  const url = new URL(req.url)
  const code = url.searchParams.get('code')
  const REDIRECT_URI = `${Deno.env.get('SUPABASE_URL')}/functions/v1/line-auth`

  if (!code) {
    return new Response('Missing authorization code', { status: 400 })
  }

  // 1. Line 인증 코드 → 토큰 교환
  const tokenRes = await fetch('https://api.line.me/oauth2/v2.1/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      code,
      redirect_uri: REDIRECT_URI,
      client_id: LINE_CHANNEL_ID,
      client_secret: LINE_CHANNEL_SECRET,
    }),
  })

  const lineTokens = await tokenRes.json()

  if (!lineTokens.id_token) {
    return new Response(`Line token error: ${JSON.stringify(lineTokens)}`, { status: 400 })
  }

  // 2. ID 토큰 디코딩 (OIDC JWT payload)
  const b64 = lineTokens.id_token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')
  const payload = JSON.parse(atob(b64))

  const lineUserId: string = payload.sub
  const lineName: string = payload.name ?? 'Line User'
  const linePicture: string | undefined = payload.picture
  const lineEmail: string | undefined = payload.email
  // Line이 이메일 제공하지 않는 경우 결정론적 이메일 생성
  const userEmail = lineEmail ?? `line_${lineUserId}@line.bebetap.app`

  // 3. Supabase Admin 클라이언트
  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { autoRefreshToken: false, persistSession: false } }
  )

  // 4. 유저 생성 (이미 존재하면 에러 무시)
  await supabaseAdmin.auth.admin.createUser({
    email: userEmail,
    email_confirm: true,
    user_metadata: {
      provider: 'line',
      line_id: lineUserId,
      full_name: lineName,
      avatar_url: linePicture,
    },
  })

  // 5. Magic link 생성 (앱 딥링크로 리디렉션)
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

  // 6. Supabase verify URL로 리디렉션
  // Supabase가 토큰 검증 후 com.bebetap.app://login-callback#access_token=...&refresh_token=... 으로 리디렉션
  return new Response(null, {
    status: 302,
    headers: { 'Location': linkData.properties.action_link },
  })
})
