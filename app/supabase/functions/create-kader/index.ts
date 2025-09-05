// deno-lint-ignore-file no-irregular-whitespace
// Import library yang dibutuhkan
import { serve } from 'https://deno.land/std@0.208.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0'

// Header CORS agar Flutter bisa mengakses fungsi ini
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

console.log('Function "create-kader" is up!');

serve(async (req) => {
  // Tangani request preflight CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Ambil data yang dikirim dari Flutter (username, phone, dll.)
    const { username, phone, jabatan, password } = await req.json()

    // Validasi input sederhana
    if (!username || !phone || !jabatan || !password) {
      throw new Error("Data tidak lengkap: username, phone, jabatan, dan password wajib diisi.");
    }
    
    // 2. Buat Admin Client Supabase
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )
    
    // 3. Buat user baru di sistem otentikasi (auth.users)
    const email = `${username.toLowerCase().replace(/\s+/g, '')}@alfaateh.com`;

    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email: email,
      password: password,
      // ▼ PERUBAHAN 1: Baris 'phone' kita hapus dari sini karena tidak disimpan di auth.users
      email_confirm: true,
    })

    if (authError) {
      throw authError
    }

    const newUserId = authData.user.id;

    // 4. Masukkan data profil ke tabel 'profiles'
    const { error: profileError } = await supabaseAdmin
      .from('profiles')
      .insert({
        id: newUserId,
        username: username,
        jabatan: jabatan,
        role: 'kaderisasi',
        // ▼ PERUBAHAN 2: Menyimpan nomor HP ke kolom 'no_hp'
        no_hp: phone, 
      })

    if (profileError) {
      await supabaseAdmin.auth.admin.deleteUser(newUserId);
      throw profileError
    }

    // 5. Kirim respons sukses kembali ke Flutter
    return new Response(JSON.stringify({ success: true, message: 'Akun kader berhasil dibuat' }), {
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