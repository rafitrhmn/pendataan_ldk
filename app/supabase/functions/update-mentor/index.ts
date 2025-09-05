// supabase/functions/update-mentor/index.ts

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
    const { id, username, jabatan, no_hp } = await req.json()
    // DIUBAH: Pesan validasi
    if (!id) throw new Error('ID Mentor wajib diisi.')

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )
    
    // Logika inti tidak berubah sama sekali
    const { error } = await supabaseAdmin
      .from('profiles')
      .update({
        username: username,
        jabatan: jabatan,
        no_hp: no_hp,
      })
      .eq('id', id)

    if (error) throw error

    // DIUBAH: Pesan sukses
    return new Response(JSON.stringify({ success: true, message: 'Data mentor berhasil diupdate' }), {
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