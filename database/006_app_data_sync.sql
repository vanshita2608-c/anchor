-- ============================================================
-- ANCHOR DATABASE MIGRATION 006: APP DATA SYNC
-- Lets the Flutter app save each user's vault data to Supabase.
-- Safe to run more than once.
-- ============================================================

-- 1. Vault keys: AES-GCM needs the authentication tag (mac) to unwrap the VEK
ALTER TABLE public.wrapped_vault_keys ADD COLUMN IF NOT EXISTS vek_mac TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS uq_wrapped_vault_keys_user_version
    ON public.wrapped_vault_keys(user_id, key_version);

-- 2. Documents: file upload comes later, so file columns become optional
ALTER TABLE public.documents ALTER COLUMN encrypted_file_path DROP NOT NULL;
ALTER TABLE public.documents ALTER COLUMN file_size_bytes DROP NOT NULL;
ALTER TABLE public.documents ALTER COLUMN mime_type DROP NOT NULL;
ALTER TABLE public.documents ALTER COLUMN encryption_nonce DROP NOT NULL;

DROP POLICY IF EXISTS "Users manage metadata of own documents" ON public.document_metadata;
CREATE POLICY "Users manage metadata of own documents" ON public.document_metadata FOR ALL
    USING (document_id IN (SELECT id FROM public.documents WHERE owner_id = auth.uid()))
    WITH CHECK (document_id IN (SELECT id FROM public.documents WHERE owner_id = auth.uid()));

-- 3. Passwords: store the AES-GCM tag and who the item is shared with
ALTER TABLE public.password_items ADD COLUMN IF NOT EXISTS password_mac TEXT;
ALTER TABLE public.password_items ADD COLUMN IF NOT EXISTS access_level TEXT NOT NULL DEFAULT 'Only Me';

-- 4. Emergency contacts: the app collects name + phone; email is optional
ALTER TABLE public.emergency_contacts ADD COLUMN IF NOT EXISTS contact_name TEXT;
ALTER TABLE public.emergency_contacts ADD COLUMN IF NOT EXISTS contact_phone TEXT;
ALTER TABLE public.emergency_contacts ALTER COLUMN contact_email DROP NOT NULL;

DROP POLICY IF EXISTS "Users manage own emergency contacts" ON public.emergency_contacts;
CREATE POLICY "Users manage own emergency contacts" ON public.emergency_contacts FOR ALL
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 5. Families: one family vault per owner
CREATE UNIQUE INDEX IF NOT EXISTS uq_families_owner ON public.families(owner_id);

DROP POLICY IF EXISTS "Owners manage own family" ON public.families;
CREATE POLICY "Owners manage own family" ON public.families FOR ALL
    USING (auth.uid() = owner_id) WITH CHECK (auth.uid() = owner_id);

-- 6. Family invitations: members added in the app are invitations until they sign up
ALTER TABLE public.family_invitations ADD COLUMN IF NOT EXISTS invitee_name TEXT;
ALTER TABLE public.family_invitations ADD COLUMN IF NOT EXISTS relation TEXT;

DROP POLICY IF EXISTS "Inviters manage own invitations" ON public.family_invitations;
CREATE POLICY "Inviters manage own invitations" ON public.family_invitations FOR ALL
    USING (auth.uid() = inviter_id) WITH CHECK (auth.uid() = inviter_id);
