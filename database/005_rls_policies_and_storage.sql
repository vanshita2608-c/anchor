-- ============================================================
-- ANCHOR DATABASE MIGRATION 005: ROW LEVEL SECURITY & STORAGE
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.families ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_keys ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wrapped_vault_keys ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.document_metadata ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.password_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shared_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.emergency_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.emergency_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expiry_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recovery_metadata ENABLE ROW LEVEL SECURITY;

-- 1. Profiles Policies
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- 2. User Keys & Wrapped Keys Policies
CREATE POLICY "Users can manage own keys" ON public.user_keys FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own wrapped keys" ON public.wrapped_vault_keys FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own recovery metadata" ON public.recovery_metadata FOR ALL USING (auth.uid() = user_id);

-- 3. Document Vault RLS Policies
CREATE POLICY "Users can select own documents" ON public.documents FOR SELECT USING (
    auth.uid() = owner_id OR
    id IN (SELECT item_id FROM public.shared_items WHERE recipient_id = auth.uid() AND revoked_at IS NULL AND item_type = 'DOCUMENT')
);
CREATE POLICY "Users can insert own documents" ON public.documents FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "Users can update own documents" ON public.documents FOR UPDATE USING (auth.uid() = owner_id);
CREATE POLICY "Users can delete own documents" ON public.documents FOR DELETE USING (auth.uid() = owner_id);

-- 4. Password Items RLS Policies
CREATE POLICY "Users can select own passwords" ON public.password_items FOR SELECT USING (
    auth.uid() = owner_id OR
    id IN (SELECT item_id FROM public.shared_items WHERE recipient_id = auth.uid() AND revoked_at IS NULL AND item_type = 'PASSWORD')
);
CREATE POLICY "Users can insert own passwords" ON public.password_items FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "Users can update own passwords" ON public.password_items FOR UPDATE USING (auth.uid() = owner_id);
CREATE POLICY "Users can delete own passwords" ON public.password_items FOR DELETE USING (auth.uid() = owner_id);

-- 5. Shared Items Policies
CREATE POLICY "Users can access shared items where sender or recipient" ON public.shared_items FOR ALL USING (
    auth.uid() = sender_id OR auth.uid() = recipient_id
);

-- 6. Audit Logs Policies
CREATE POLICY "Users can view own audit logs" ON public.audit_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own audit logs" ON public.audit_logs FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 7. Supabase Private Storage Bucket setup script
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('vault-documents', 'vault-documents', false, 52428800, ARRAY['image/jpeg', 'image/png', 'application/pdf'])
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Authenticated Users upload vault objects" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'vault-documents' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated Users access own vault objects" ON storage.objects
FOR SELECT USING (bucket_id = 'vault-documents' AND auth.role() = 'authenticated');
