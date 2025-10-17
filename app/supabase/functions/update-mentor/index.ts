import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { id, username, jabatan, no_hp } = await req.json();
    if (!id || !username || !jabatan || !no_hp) {
        throw new Error('Semua field wajib diisi.');
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Cek dulu apakah username baru sudah digunakan oleh orang lain
    const { data: existingProfile } = await supabaseAdmin
      .from('profiles')
      .select('id')
      .eq('username', username)
      .not('id', 'eq', id) // Kecualikan user saat ini dari pengecekan
      .single();

    if (existingProfile) {
      throw new Error('Username baru sudah digunakan oleh user lain.');
    }

    // 1. Update email di sistem Auth
    const newEmail = `${username.toLowerCase().replace(/\s+/g, '')}@alfaateh.com`;
    const { error: authError } = await supabaseAdmin.auth.admin.updateUserById(id, {
      email: newEmail,
    });
    if (authError) throw authError;

    // 2. Update data di tabel profiles
    const { error: profileError } = await supabaseAdmin
      .from('profiles')
      .update({ 
        username: username, 
        jabatan: jabatan, 
        no_hp: no_hp 
      })
      .eq('id', id);
    if (profileError) throw profileError;

    return new Response(JSON.stringify({ success: true, message: 'Data berhasil diperbarui' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (err: any) {
    console.error('--- [ERROR EDGE] Gagal update mentor: ---', err)
    return new Response(JSON.stringify({ success: false, error: err.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
})