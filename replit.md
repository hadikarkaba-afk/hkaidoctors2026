# Workspace

## Overview

**HK AI Doctor** — a clinical-AI platform for doctors. Three artifacts in a pnpm monorepo:

- **`artifacts/hk-ai-doctor`** (web, React + Vite) — primary product UI.
- **`artifacts/hk-ai-doctor-mobile`** (Expo / React Native) — companion mobile app, light theme that mirrors the web's HK logo, Outfit typography, and sky → teal → green accent palette.
- **`artifacts/api-server`** (Express 5) — backend, served at `/api`.

## Modules (web)

Dashboard, Medical AI, Research AI, Finance AI, Smart Calculator, Email Generator, Professional Reports, Appointments (with reminder scheduler), Admin (Users / Billing / Trial Requests / Policy).

## Authentication

- Bearer token issued at login; sent both as `Authorization: Bearer …` and `x-hk-token`. Sessions persisted in `hk_sessions`.
- Default super admin: `admin` / `Compaq@785711`.
- **First-login forced password change**: when `mustChangePassword` is true on the user, the web app shows a blocking `ChangePasswordDialog` until the user updates their password. `/auth/me` always returns the fresh flag so a hard refresh still enforces it. Backend route: `POST /api/hk-ai/auth/change-password`.
- Admin can reset / deactivate / unlock / delete users from the Admin → Users tab (PATCH/DELETE `/admin/users/:id`).

## Free trial flow

- Public `Free Trial Request` button on the login screen opens `FreeTrialDialog` (name, email, phone, organization, role, message).
- `POST /trial/request` validates with Zod and writes to `hk_trial_requests` with `notify_email = "hadi.karkaba@gmail.com"` stamped server-side (the operator address is never exposed in the UI).
- Admin → Trial Requests tab lists all submissions with status (new / contacted / approved / rejected) and delete.
- Email notification to the operator is dispatched via **Gmail** (Replit connector `google-mail`, `@replit/connectors-sdk`) whenever a new trial request is submitted. Logic lives in `artifacts/api-server/src/lib/email.ts` (`sendTrialRequestEmail`), called fire-and-forget from the trial handler. The email is an HTML message containing all submitted fields (name, email, phone, org, role, message). Delivery requires the Gmail connector OAuth token to be valid — re-authorize via the Replit Integrations panel if emails stop arriving.

## Tech support

Floating WhatsApp FAB on every authenticated screen and a Technical Support link on the login page, both → `https://wa.me/96170406880`.

## Stack

- **Monorepo**: pnpm workspaces, Node 24, TypeScript 5.9.
- **Database**: PostgreSQL + Drizzle ORM.
- **Validation**: Zod (`zod/v4`).
- **AI**: Replit's Gemini integration via `new GoogleGenAI({ apiKey, httpOptions: { apiVersion: "", baseUrl }})` — empty `apiVersion` is required for the Replit proxy.
- **Mobile fonts**: Outfit, registered under the legacy `Inter_*` keys in `useFonts` so existing `fontFamily: "Inter_…"` references render Outfit without per-file edits.

## Stack details

- **Monorepo tool**: pnpm workspaces
- **Node.js version**: 24
- **Package manager**: pnpm
- **TypeScript version**: 5.9
- **Frontend**: React + Vite (artifacts/procurement), served at /
- **API framework**: Express 5 (artifacts/api-server), served at /api
- **Database**: PostgreSQL + Drizzle ORM
- **Validation**: Zod (`zod/v4`), `drizzle-zod`
- **API codegen**: Orval (from OpenAPI spec)
- **Build**: esbuild (CJS bundle)
- **Charts**: Recharts
- **Routing**: Wouter

## Database tables (HK AI Doctor)

- `hk_users` — accounts (admin / doctor / user roles, `mustChangePassword`, lockout, `monthlyFee`, `lastPaymentAt`)
- `hk_sessions` — bearer token sessions
- `hk_settings` — auth/billing/global policy
- `hk_activity` — per-user activity log
- `hk_reports` — saved AI-generated reports
- `hk_appointments` — patient appointments + reminder dispatch fields
- `hk_trial_requests` — public Free Trial submissions

The repo also still contains older procurement / multi-tenant tables (`companies`, `suppliers`, `purchase_orders`, etc.) — these are not used by the HK AI Doctor product but remain in the schema and are not referenced by the active artifacts.

## Key Commands

- `pnpm run typecheck` — full typecheck across all packages
- `pnpm run build` — typecheck + build all packages
- `pnpm --filter @workspace/api-spec run codegen` — regenerate API hooks and Zod schemas from OpenAPI spec
- `pnpm --filter @workspace/db run push` — push DB schema changes (dev only)
- `pnpm --filter @workspace/api-server run dev` — run API server locally
- `pnpm --filter @workspace/procurement run dev` — run frontend locally

## Important Notes

- `lib/api-zod/src/index.ts` must only export `export * from "./generated/api"` — the generated types subfolder creates duplicate names
- The orval config no longer generates the `schemas` subfolder to avoid conflicts
- PR/PO line items are stored as JSON arrays in the DB for simplicity (not separate junction tables)
- AI uses Replit's Gemini integration: `new GoogleGenAI({ apiKey, httpOptions: { apiVersion: "", baseUrl }})` — empty `apiVersion` is required for the Replit proxy
- App font: Outfit (sans) + JetBrains Mono (mono); brand mark is `<GlobalLogo>` (animated globe SVG)

## CRITICAL: Tailwind v4 dark: classes break in production

**`dark:` utility classes DO NOT work in the published/deployed build.** They appear to work in the Replit dev preview but are silently dropped by the Tailwind v4 production CSS scanner.

**Rule: NEVER use `dark:` prefixed Tailwind classes for any color, background, border, or text property.** Always use inline `style={{}}` props with hardcoded dark-theme hex values instead.

Standard dark-theme color palette to use in inline styles:
- Page / card background: `#0f172a` (slate-950), `#1e293b` (slate-800), `#334155` (slate-700 — borders)
- Primary text: `#f1f5f9` (slate-100)
- Secondary text: `#94a3b8` (slate-400), `#cbd5e1` (slate-300)
- Muted / label text: `#64748b` (slate-500)
- Accent blue: `#3b82f6`, indigo: `#6366f1`, violet: `#7c3aed`
- Error red: `#f87171`, error bg: `#450a0a`

See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details.
