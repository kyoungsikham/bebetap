import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { SignJWT, importPKCS8 } from 'https://deno.land/x/jose@v4.15.4/index.ts';

// ─────────────────────────────────────────────────
// 타입
// ─────────────────────────────────────────────────
interface RequestBody {
  platform: 'ios' | 'android';
  productId: string;
  // iOS: App Store Server Notification의 transactionId
  transactionId?: string;
  // Android: Play Console의 purchaseToken
  purchaseToken?: string;
}

// ─────────────────────────────────────────────────
// 상수
// ─────────────────────────────────────────────────
const PRODUCT_ID = 'com.bebetap.remove_ads';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// ─────────────────────────────────────────────────
// iOS 영수증 검증 (App Store Server API)
// ─────────────────────────────────────────────────
async function verifyIos(transactionId: string): Promise<boolean> {
  const keyId = Deno.env.get('APP_STORE_CONNECT_KEY_ID')!;
  const issuerId = Deno.env.get('APP_STORE_CONNECT_ISSUER_ID')!;
  const privateKeyPem = Deno.env.get('APP_STORE_CONNECT_PRIVATE_KEY')!;

  const privateKey = await importPKCS8(privateKeyPem, 'ES256');

  const jwt = await new SignJWT({})
    .setProtectedHeader({ alg: 'ES256', kid: keyId, typ: 'JWT' })
    .setIssuer(issuerId)
    .setIssuedAt()
    .setExpirationTime('10m')
    .setAudience('appstoreconnect-v1')
    .sign(privateKey);

  // 프로덕션 엔드포인트 먼저 시도, 실패 시 샌드박스
  for (const env of ['production', 'sandbox']) {
    const base = env === 'production'
      ? 'https://api.storekit.itunes.apple.com'
      : 'https://api.storekit-sandbox.itunes.apple.com';

    const res = await fetch(`${base}/inApps/v1/transactions/${transactionId}`, {
      headers: { Authorization: `Bearer ${jwt}` },
    });

    if (res.status === 200) {
      const data = await res.json();
      // signedTransactionInfo는 JWS 페이로드 — productId만 확인
      const payload = JSON.parse(atob(data.signedTransactionInfo.split('.')[1]));
      return payload.productId === PRODUCT_ID;
    }
    if (res.status !== 404) break; // 404 = sandbox에서 찾을 수 없음, 다음 환경 시도
  }
  return false;
}

// ─────────────────────────────────────────────────
// Android 영수증 검증 (Google Play Developer API)
// ─────────────────────────────────────────────────
async function verifyAndroid(purchaseToken: string): Promise<boolean> {
  const serviceAccountJson = Deno.env.get('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON')!;
  const sa = JSON.parse(serviceAccountJson);

  // JWT로 Google OAuth 액세스 토큰 취득
  const privateKey = await importPKCS8(sa.private_key, 'RS256');
  const now = Math.floor(Date.now() / 1000);

  const assertion = await new SignJWT({
    scope: 'https://www.googleapis.com/auth/androidpublisher',
  })
    .setProtectedHeader({ alg: 'RS256', typ: 'JWT' })
    .setIssuer(sa.client_email)
    .setSubject(sa.client_email)
    .setAudience('https://oauth2.googleapis.com/token')
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(privateKey);

  const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });
  const { access_token } = await tokenRes.json();

  const packageName = 'com.bebetap.app';
  const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}/purchases/products/${PRODUCT_ID}/tokens/${purchaseToken}`;

  const verifyRes = await fetch(url, {
    headers: { Authorization: `Bearer ${access_token}` },
  });

  if (verifyRes.status !== 200) return false;

  const data = await verifyRes.json();
  // purchaseState: 0 = 구매됨
  return data.purchaseState === 0;
}

// ─────────────────────────────────────────────────
// 메인 핸들러
// ─────────────────────────────────────────────────
serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS });
  }

  // 인증 헤더에서 Supabase 클라이언트 초기화 (RLS 적용)
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'missing authorization' }), {
      status: 401,
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
    });
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  // 요청 사용자 확인
  const userClient = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } } },
  );
  const { data: { user }, error: authError } = await userClient.auth.getUser();
  if (authError || !user) {
    return new Response(JSON.stringify({ error: 'unauthorized' }), {
      status: 401,
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
    });
  }

  // 요청 본문 파싱
  let body: RequestBody;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: 'invalid json' }), {
      status: 400,
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
    });
  }

  const { platform, productId, transactionId, purchaseToken } = body;

  // 상품 ID 검증
  if (productId !== PRODUCT_ID) {
    return new Response(JSON.stringify({ error: 'invalid product' }), {
      status: 400,
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
    });
  }

  // 플랫폼별 영수증 검증
  let valid = false;
  try {
    if (platform === 'ios' && transactionId) {
      valid = await verifyIos(transactionId);
    } else if (platform === 'android' && purchaseToken) {
      valid = await verifyAndroid(purchaseToken);
    } else {
      return new Response(JSON.stringify({ error: 'missing receipt data' }), {
        status: 400,
        headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      });
    }
  } catch (e) {
    console.error('receipt verification error:', e);
    return new Response(JSON.stringify({ error: 'verification failed' }), {
      status: 500,
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
    });
  }

  if (!valid) {
    return new Response(JSON.stringify({ error: 'invalid receipt' }), {
      status: 403,
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
    });
  }

  // profiles.is_premium = true 업데이트 (이미 구매된 경우 중복 OK)
  const { error: updateError } = await supabase
    .from('profiles')
    .update({
      is_premium: true,
      premium_purchased_at: new Date().toISOString(),
      premium_platform: platform,
    })
    .eq('id', user.id);

  if (updateError) {
    console.error('DB update error:', updateError);
    return new Response(JSON.stringify({ error: 'db error' }), {
      status: 500,
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
    });
  }

  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
});
