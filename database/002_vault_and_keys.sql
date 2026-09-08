-- ============================================================
-- ANCHOR DATABASE MIGRATION 002: VAULT & ZERO-KNOWLEDGE KEYS
-- ============================================================

-- 1. User Keys (Stores KDF metadata & salt, NO MASTER PASSWORD)
CREATE TABLE IF NOT EXISTS public.user_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    kdf_algorithm TEXT NOT NULL DEFAULT 'PBKDF2-SHA256',
    kdf_iterations INT NOT NULL DEFAULT 100000,
    kdf_salt TEXT NOT NULL, -- Base64 encoded random salt
    key_version INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Wrapped Vault Encryption Keys (Encrypted VEK wrapped with derived KEK)
CREATE TABLE IF NOT EXISTS public.wrapped_vault_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    key_version INT NOT NULL DEFAULT 1,
    wrapped_vek TEXT NOT NULL, -- AES-256-GCM encrypted Vault Encryption Key
    vek_nonce TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Document Vault Table
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    family_id UUID REFERENCES public.families(id) ON DELETE SET NULL,
    category TEXT NOT NULL, -- Identity, Passport, Aadhaar, Insurance, Vehicle, Property, Legal, Medical, etc.
    title TEXT NOT NULL,
    encrypted_file_path TEXT NOT NULL, -- Supabase Storage private path
    file_size_bytes BIGINT NOT NULL,
    mime_type TEXT NOT NULL,
    encryption_nonce TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Document Metadata (Encrypted fields for sensitive info)
CREATE TABLE IF NOT EXISTS public.document_metadata (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL UNIQUE REFERENCES public.documents(id) ON DELETE CASCADE,
    issue_date DATE,
    expiry_date DATE,
    tags TEXT[],
    encrypted_metadata_blob TEXT, -- Encrypted JSON string of sensitive extra fields
    ocr_extracted TEXT, -- Safe non-sensitive extracted tokens
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Password Vault Items
CREATE TABLE IF NOT EXISTS public.password_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    family_id UUID REFERENCES public.families(id) ON DELETE SET NULL,
    website_title TEXT NOT NULL,
    website_url TEXT,
    username TEXT NOT NULL,
    encrypted_password TEXT NOT NULL, -- AES-256-GCM encrypted password
    password_nonce TEXT NOT NULL,
    category TEXT DEFAULT 'General',
    tags TEXT[],
    is_favorite BOOLEAN DEFAULT FALSE,
    security_score_rating INT DEFAULT 100, -- Local calculated score
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_documents_owner ON public.documents(owner_id);
CREATE INDEX idx_documents_category ON public.documents(category);
CREATE INDEX idx_passwords_owner ON public.password_items(owner_id);
