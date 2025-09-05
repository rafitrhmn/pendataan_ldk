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
    const { id } = await req.json()
    if (!id) throw new Error('ID Kader wajib diisi.')

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Perintah untuk menghapus user dari sistem otentikasi Supabase
    const { error } = await supabaseAdmin.auth.admin.deleteUser(id)

    if (error) throw error

    // CATATAN PENTING:
    // Kita tidak perlu menghapus data dari tabel 'profiles' secara manual.
    // Karena ada Foreign Key dengan 'ON DELETE CASCADE', saat user di auth dihapus,
    // profilnya akan otomatis ikut terhapus oleh database. Ajaib!

    return new Response(JSON.stringify({ success: true, message: 'Kader berhasil dihapus' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (err: unknown) {
    let errorMessage = 'Terjadi kesalahan yang tidak diketahui';
    if (err instanceof Error) { errorMessage = err.message; }
    return new Response(JSON.stringify({ success: false, error: errorMessage }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})