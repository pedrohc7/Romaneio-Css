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

-- Qualquer usuário autenticado (equipe: Pedro, Leo, ...) vê e gerencia
-- todos os romaneios, não só os que ele mesmo criou. user_id continua
-- sendo gravado com o autor real (novo.html), só não é mais usado para
-- restringir visibilidade.
CREATE POLICY "equipe_acesso_total" ON romaneios
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

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
--
-- Policy 4 — equipe logada também pode fazer upload na pasta pa/:
--   Necessária porque o Supabase client reaproveita a sessão autenticada
--   já salva no navegador (mesma origem), mesmo em assinar.html — então
--   testar o link do P.A. logado como Pedro/Leo cai na role "authenticated",
--   não "anon", e sem essa policy o upload é bloqueado pelo RLS.
--   Nome: authenticated_upload_pa
--   Allowed operation: INSERT
--   Target roles: authenticated
--   Policy: bucket_id = 'arquivos' AND (storage.foldername(name))[1] = 'pa'
-- ============================================================

-- 4. Habilite Auth em: Authentication → Providers → Email → Enable
