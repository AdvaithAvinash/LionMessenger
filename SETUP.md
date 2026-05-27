# LionMessenger — Deployment Setup

## 1. Supabase (database)

1. Create a free project at [supabase.com](https://supabase.com)
2. Go to **Settings → Database → Connection string**
3. Copy both URLs:

| Vercel env var | Where to get it | Format |
|---|---|---|
| `DATABASE_URL` | **Transaction pooler** tab | `postgresql://postgres.REF:PASS@aws-0-REGION.pooler.supabase.com:6543/postgres?pgbouncer=true&connection_limit=1` |
| `DIRECT_URL` | **Session pooler** or **Direct connection** tab | `postgresql://postgres:PASS@db.REF.supabase.co:5432/postgres` |

4. Run migrations once:
```bash
cd backend
cp .env.example .env   # fill in DATABASE_URL and DIRECT_URL
npx prisma migrate deploy
```

---

## 2. Vercel environment variables

Go to your project → **Settings → Environment Variables** and add:

| Variable | Value |
|---|---|
| `DATABASE_URL` | Supabase pooler URL (from step 1) |
| `DIRECT_URL` | Supabase direct URL (from step 1) |
| `CLERK_SECRET_KEY` | `sk_test_zbbnOk4Fh6OEWkIgQscAf7h3VT7rVjbrqRjlwPHMZq` |
| `CLERK_PUBLISHABLE_KEY` | `pk_test_d29ya2FibGUtc2F3ZmlzaC04MC5jbGVyay5hY2NvdW50cy5kZXYk` |
| `CLERK_WEBHOOK_SECRET` | (from step 3 below) |
| `STREAM_API_KEY` | `g27tvktrtkb5` |
| `STREAM_API_SECRET` | `5py5ncxnqep88bnfa7stw77m3eg43myugcurez2edqkwsdvpq6xhgdhgzyhfgje8` |
| `NODE_ENV` | `production` |
| `ALLOWED_ORIGINS` | `https://lion-messenger-lygwukmv2-advaithavinash1.vercel.app` |

After adding env vars, **Redeploy** from the Vercel dashboard.

---

## 3. Clerk webhook

1. Go to [Clerk dashboard](https://dashboard.clerk.com) → **Webhooks → Add Endpoint**
2. **Endpoint URL:**
   ```
   https://lion-messenger-lygwukmv2-advaithavinash1.vercel.app/api/auth/webhook
   ```
3. **Subscribe to events:** `user.created`, `user.updated`, `user.deleted`
4. Click **Create** → copy the **Signing Secret** (starts with `whsec_`)
5. Add it as `CLERK_WEBHOOK_SECRET` in Vercel env vars → Redeploy

---

## 4. Flutter app

Build the Flutter app pointing at the Vercel backend:

```bash
flutter run \
  --dart-define=BACKEND_URL=https://lion-messenger-lygwukmv2-advaithavinash1.vercel.app

# or for release
flutter build apk \
  --dart-define=BACKEND_URL=https://lion-messenger-lygwukmv2-advaithavinash1.vercel.app
```

The Clerk publishable key and Stream API key are already baked into the app.

---

## 5. Verify deployment

```bash
curl https://lion-messenger-lygwukmv2-advaithavinash1.vercel.app/health
# → {"status":"ok","timestamp":"..."}
```
