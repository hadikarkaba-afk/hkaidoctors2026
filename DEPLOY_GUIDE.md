# HK AI Doctor — Free Deployment Guide
# Render (API) + Vercel (Web) + Supabase (Database)

---

## Step 1 — Set up Supabase (Database)

1. Go to https://supabase.com → Sign up free
2. Click **New Project** → give it a name like `hk-ai-doctor`
3. Set a strong database password (save it somewhere)
4. Wait ~2 minutes for it to provision
5. Go to **SQL Editor** → **New Query**
6. Open the file `supabase-schema.sql` from your downloaded zip
7. Paste the entire contents → click **Run**
8. Go to **Project Settings** → **Database**
9. Copy the **Connection String (URI)** — it looks like:
   `postgresql://postgres:[PASSWORD]@db.[REF].supabase.co:5432/postgres`
10. Save this — you'll need it as `DATABASE_URL`

---

## Step 2 — Deploy API Server on Render

1. Go to https://render.com → Sign up free
2. Click **New** → **Web Service**
3. Connect your GitHub account and push your code there, OR use **Deploy from existing repo**
4. Set these settings:
   - **Name:** `hk-ai-doctor-api`
   - **Environment:** Node
   - **Build Command:** `pnpm install --frozen-lockfile && pnpm --filter @workspace/api-server run build`
   - **Start Command:** `node artifacts/api-server/dist/index.mjs`
   - **Plan:** Free
5. Add these **Environment Variables**:
   | Key | Value |
   |-----|-------|
   | `NODE_ENV` | `production` |
   | `PORT` | `10000` |
   | `DATABASE_URL` | (your Supabase connection string from Step 1) |
   | `HK_ADMIN_PASSWORD` | `Compaq@785711` (or a new strong password) |
   | `GEMINI_API_KEY` | (your Gemini API key from Google AI Studio) |
6. Click **Create Web Service**
7. Wait ~5 minutes for first build
8. Copy your Render URL e.g. `https://hk-ai-doctor-api.onrender.com`

---

## Step 3 — Deploy Web App on Vercel

1. Go to https://vercel.com → Sign up free
2. Click **Add New** → **Project**
3. Import your GitHub repo
4. Set these settings:
   - **Root Directory:** `artifacts/hk-ai-doctor`
   - **Framework Preset:** Vite
   - **Build Command:** `cd ../.. && pnpm install --frozen-lockfile && PORT=3000 BASE_PATH=/ pnpm --filter @workspace/hk-ai-doctor run build`
   - **Output Directory:** `dist/public`
5. Add **Environment Variables**:
   | Key | Value |
   |-----|-------|
   | `PORT` | `3000` |
   | `BASE_PATH` | `/` |
   | `VITE_API_URL` | (your Render URL from Step 2) |
6. Click **Deploy**
7. Once deployed, go to **Settings** → **Domains**
8. Add `hkaidoctors.com` and follow DNS instructions

---

## Step 4 — Point your domain to Vercel

In your domain registrar (wherever you bought hkaidoctors.com):

Add these DNS records:
```
Type: A     Name: @    Value: 76.76.21.21
Type: CNAME Name: www  Value: cname.vercel-dns.com
```

Wait 5–30 minutes for DNS to propagate. Your site will be live at https://hkaidoctors.com

---

## Step 5 — Connect API to Vercel (CORS fix)

In Render dashboard, add one more environment variable:
| Key | Value |
|-----|-------|
| `ALLOWED_ORIGINS` | `https://hkaidoctors.com,https://www.hkaidoctors.com` |

---

## Summary

| Service | What it runs | Cost |
|---------|-------------|------|
| Supabase | PostgreSQL database | Free |
| Render | Node.js API server | Free (sleeps after 15 min inactivity) |
| Vercel | Web app + domain | Free forever |

**Upgrade tip:** When you have real users, upgrade Render to the $7/mo paid plan so the API never sleeps (no cold start delays).

---

## Need help?

Contact: hadi.karkaba@gmail.com
