-- HK AI Doctor — Supabase Database Schema
-- Run this in your Supabase project: SQL Editor → New Query → paste & run

CREATE TABLE IF NOT EXISTS hk_users (
  id SERIAL PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  full_name TEXT,
  email TEXT,
  phone TEXT,
  position TEXT,
  department TEXT,
  account_expires_at TIMESTAMPTZ,
  must_change_password BOOLEAN NOT NULL DEFAULT FALSE,
  password_changed_at TIMESTAMPTZ,
  last_login_at TIMESTAMPTZ,
  failed_login_count INTEGER NOT NULL DEFAULT 0,
  locked_until TIMESTAMPTZ,
  monthly_fee INTEGER NOT NULL DEFAULT 5,
  last_payment_at TIMESTAMPTZ,
  status TEXT NOT NULL DEFAULT 'approved',
  specialty TEXT,
  license_number TEXT,
  passport_url TEXT,
  certificate_url TEXT,
  agreed_terms_at TIMESTAMPTZ,
  agreed_terms_version TEXT,
  rejection_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS hk_settings (
  id SERIAL PRIMARY KEY,
  policy JSONB NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS hk_sessions (
  token TEXT PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES hk_users(id) ON DELETE CASCADE,
  device_type TEXT NOT NULL DEFAULT 'desktop',
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS hk_sessions_user_idx ON hk_sessions(user_id);
CREATE INDEX IF NOT EXISTS hk_sessions_expires_idx ON hk_sessions(expires_at);

CREATE TABLE IF NOT EXISTS hk_activity (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES hk_users(id) ON DELETE CASCADE,
  module TEXT NOT NULL,
  action TEXT NOT NULL,
  summary TEXT,
  duration_ms INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS hk_activity_user_idx ON hk_activity(user_id);
CREATE INDEX IF NOT EXISTS hk_activity_created_idx ON hk_activity(created_at);

CREATE TABLE IF NOT EXISTS hk_reports (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES hk_users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  patient_name TEXT,
  payload JSONB NOT NULL,
  report JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS hk_reports_user_idx ON hk_reports(user_id);
CREATE INDEX IF NOT EXISTS hk_reports_created_idx ON hk_reports(created_at);

CREATE TABLE IF NOT EXISTS hk_appointments (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES hk_users(id) ON DELETE CASCADE,
  patient_name TEXT NOT NULL,
  patient_phone TEXT,
  scheduled_at TIMESTAMPTZ NOT NULL,
  duration_mins INTEGER NOT NULL DEFAULT 30,
  location TEXT,
  notes TEXT,
  status TEXT NOT NULL DEFAULT 'scheduled',
  reminder_sent_at TIMESTAMPTZ,
  reminder_error TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS hk_appt_user_idx ON hk_appointments(user_id);
CREATE INDEX IF NOT EXISTS hk_appt_scheduled_idx ON hk_appointments(scheduled_at);
CREATE INDEX IF NOT EXISTS hk_appt_status_idx ON hk_appointments(status);

CREATE TABLE IF NOT EXISTS hk_trial_requests (
  id SERIAL PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  organization TEXT,
  role TEXT,
  message TEXT,
  status TEXT NOT NULL DEFAULT 'new',
  created_username TEXT,
  notify_email TEXT,
  notify_sent_at TIMESTAMPTZ,
  notify_error TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS hk_trial_status_idx ON hk_trial_requests(status);
CREATE INDEX IF NOT EXISTS hk_trial_created_idx ON hk_trial_requests(created_at);

CREATE TABLE IF NOT EXISTS hk_notifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  type TEXT NOT NULL DEFAULT 'payment',
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  sent_by_admin TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
