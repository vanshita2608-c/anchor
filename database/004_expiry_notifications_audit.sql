-- ============================================================
-- ANCHOR DATABASE MIGRATION 004: EXPIRY, NOTIFICATIONS & AUDIT LOGS
-- ============================================================

-- 1. Expiry Records Table
CREATE TABLE IF NOT EXISTS public.expiry_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    document_id UUID REFERENCES public.documents(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    expiry_date DATE NOT NULL,
    reminder_days_before INT[] DEFAULT ARRAY[30, 15, 7, 1],
    status TEXT NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, EXPIRING_SOON, EXPIRED
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Audit Logs Table (Strict: NO PLAINTEXT PASSWORDS OR SECRETS)
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    action TEXT NOT NULL, -- e.g. LOGIN, DOCUMENT_ADDED, PASSWORD_COPIED, EMERGENCY_REQUESTED
    target_type TEXT,
    target_id UUID,
    ip_address_hash TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Recovery Metadata Table (Encrypted Vault Recovery Code verification material)
CREATE TABLE IF NOT EXISTS public.recovery_metadata (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    recovery_key_hash TEXT NOT NULL, -- Cryptographic hash of recovery key
    wrapped_vek_recovery TEXT NOT NULL, -- VEK encrypted with Recovery Key
    recovery_nonce TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_user ON public.audit_logs(user_id);
CREATE INDEX idx_expiry_user_date ON public.expiry_records(user_id, expiry_date);
