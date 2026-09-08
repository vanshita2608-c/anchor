-- ============================================================
-- ANCHOR DATABASE MIGRATION 003: SHARING & EMERGENCY ACCESS
-- ============================================================

-- 1. Shared Items Table (Per-user re-wrapped key architecture)
CREATE TABLE IF NOT EXISTS public.shared_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_type TEXT NOT NULL, -- 'DOCUMENT' or 'PASSWORD'
    item_id UUID NOT NULL,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    rewrapped_item_key TEXT NOT NULL, -- Encrypted item key for recipient
    key_nonce TEXT NOT NULL,
    permission_level TEXT NOT NULL DEFAULT 'VIEW', -- VIEW, EDIT
    created_at TIMESTAMPTZ DEFAULT NOW(),
    revoked_at TIMESTAMPTZ
);

-- 2. Emergency Contacts Table
CREATE TABLE IF NOT EXISTS public.emergency_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    contact_user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    contact_email TEXT NOT NULL,
    relationship TEXT,
    allowed_categories TEXT[], -- Allowed document/password categories in emergency
    delay_hours INT NOT NULL DEFAULT 48, -- Delay before access auto-grants if unresponded
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Emergency Requests Table
CREATE TABLE IF NOT EXISTS public.emergency_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID NOT NULL REFERENCES public.emergency_contacts(id) ON DELETE CASCADE,
    owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    requester_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reason TEXT,
    status TEXT NOT NULL DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED, AUTO_APPROVED, EXPIRED
    requested_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    auto_approve_at TIMESTAMPTZ
);

CREATE INDEX idx_shared_recipient ON public.shared_items(recipient_id);
CREATE INDEX idx_emergency_owner ON public.emergency_requests(owner_id);
