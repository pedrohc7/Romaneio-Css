-- ============================================================
-- ROMANEIO DIGITAL — Setup Supabase
-- Execute este script no SQL Editor do seu projeto Supabase
-- supabase.com → seu projeto → SQL Editor → New Query
-- ============================================================

-- 1. Tabela principal
CREATE TABLE IF NOT EXISTS romaneios (
  id            uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id       uuid        REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  nome_arquivo  text        NOT NULL,
  arquivo_pedro text        NOT NULL,  -- path no Storage: pedro/{userId}/{id}.png
  arquivo_pa    text,                  -- path no Storage: pa/{id}.png
  status        text        DEFAULT 'pendente'
                            CHECK (status IN ('pendente', 'assinado')) NOT NULL,
  share_token   uuid        DEFAULT gen_random_uuid() NOT NULL UNIQUE,
  nome_pa       text,
  criado_em     timestamptz DEFAULT now() NOT NULL
);

-- 2. Row Level Security
ALTER TABLE romaneios ENABLE ROW LEVEL SECURITY;

-- Pedro vê e gerencia somente seus próprios romaneios
CREATE POLICY "autenticado_proprio" ON romaneios
  FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- P.A. (anon) pode ler qualquer romaneio — filtrado por share_token na query
CREATE POLICY "anon_leitura" ON romaneios
  FOR SELECT TO anon
  USING (true);

-- P.A. (anon) pode atualizar romaneios ainda pendentes (para assinar)
CREATE POLICY "anon_assinar" ON romaneios
  FOR UPDATE TO anon
  USING (status = 'pendente')
  WITH CHECK (status = 'assinado');

-- ============================================================
-- 3. Storage
--    Faça isso pelo painel: Storage → New Bucket
--    Nome: arquivos
--    Public bucket: SIM (habilite "Public bucket")
--
-- Depois adicione estas policies no bucket "arquivos":
--
-- Policy 1 — Leitura pública de todos os arquivos:
--   Nome: public_read
--   Allowed operation: SELECT
--   Target roles: anon, authenticated
--   Policy: true
--
-- Policy 2 — Pedro pode fazer upload na pasta pedro/:
--   Nome: authenticated_upload_pedro
--   Allowed operation: INSERT
--   Target roles: authenticated
--   Policy: bucket_id = 'arquivos' AND (storage.foldername(name))[1] = 'pedro'
--
-- Policy 3 — P.A. pode fazer upload na pasta pa/:
--   Nome: anon_upload_pa
--   Allowed operation: INSERT
--   Target roles: anon
--   Policy: bucket_id = 'arquivos' AND (storage.foldername(name))[1] = 'pa'
-- ============================================================

-- 4. Habilite Auth em: Authentication → Providers → Email → Enable
