// supabase/functions/create-mentor/index.ts

import { serve } from 'https://deno.land/std@0.208.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0'

// Header CORS tidak perlu diubah
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// DIUBAH: Pesan log untuk kejelasan
console.log('Function "create-mentor" is up!');

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { username, phone, jabatan, password } = await req.json()

    if (!username || !phone || !jabatan || !password) {
      throw new Error("Data tidak lengkap: username, phone, jabatan, dan password wajib diisi.");
    }
    
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )
    
    // Logika pembuatan email bisa tetap sama
    const email = `${username.toLowerCase().replace(/\s+/g, '')}@alfaateh.com`;

    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email: email,
      password: password,
      email_confirm: true,
    })

    if (authError) {
      throw authError
    }

    const newUserId = authData.user.id;

    const { error: profileError } = await supabaseAdmin
      .from('profiles')
      .insert({
        id: newUserId,
        username: username,
        jabatan: jabatan,
        // ================== PERUBAHAN UTAMA ADA DI SINI ==================
        role: 'mentor', // DIUBAH dari 'kaderisasi' menjadi 'mentor'
        // ===============================================================
        no_hp: phone, 
      })

    // Logika rollback jika gagal insert profil tetap sama (ini bagus!)
    if (profileError) {
      await supabaseAdmin.auth.admin.deleteUser(newUserId);
      throw profileError
    }

    // DIUBAH: Pesan sukses
    return new Response(JSON.stringify({ success: true, message: 'Akun mentor berhasil dibuat' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (err: unknown) {
    let errorMessage = 'Terjadi kesalahan yang tidak diketahui';
    
    if (err instanceof Error) {
      errorMessage = err.message;
    } else if (typeof err === 'string') {
      errorMessage = err;
    }

    return new Response(JSON.stringify({ 
      success: false, 
      error: errorMessage 
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})