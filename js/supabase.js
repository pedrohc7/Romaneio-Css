import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm'

// Preencha com os valores do seu projeto em supabase.com → Settings → API
export const SUPABASE_URL = 'https://mrjerjqcqepvapujuaoq.supabase.co'
export const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1yamVyanFjcWVwdmFwdWp1YW9xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExMTgzNDksImV4cCI6MjA5NjY5NDM0OX0.AiaoQ7msQGEcf_2um0CRA0mpsPAmZNmynnaPAhMJB7A'

export const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)
