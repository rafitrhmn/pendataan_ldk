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
    // Ambil body request untuk di-log
    const body = await req.json()
    
    // Log untuk debugging: lihat data mentah yang diterima server
    console.log('--- [DEBUG EDGE] Menerima request body: ---')
    console.log(JSON.stringify(body, null, 2))

    const { kelompok_id, tanggal, tempat, catatan, foto_url, laporan_mentees } = body;
    if (!kelompok_id || !tanggal || !laporan_mentees) {
      throw new Error('Data kelompok, tanggal, dan laporan mentee wajib diisi.');
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // 1. Masukkan data ke tabel 'pertemuan' dan ambil ID nya yang baru
    const { data: pertemuanData, error: pertemuanError } = await supabaseAdmin
      .from('pertemuan')
      .insert({
        kelompok_id: kelompok_id,
        tanggal: tanggal,
        tempat: tempat,
        catatan: catatan,
        foto_url: foto_url,
      })
      .select('id')
      .single();

    if (pertemuanError) throw pertemuanError;
    const newPertemuanId = pertemuanData.id;

    // 2. Siapkan data laporan mentee dengan menambahkan pertemuan_id ke setiap item
    const laporanData = laporan_mentees.map((laporan: any) => ({
      ...laporan,
      pertemuan_id: newPertemuanId,
    }));
    
    // Pastikan ada data laporan sebelum melakukan insert
    if(laporanData.length > 0) {
      // 3. Masukkan semua laporan mentee sekaligus (bulk insert)
      const { error: laporanError } = await supabaseAdmin
        .from('laporan_mentee')
        .insert(laporanData);

      if (laporanError) {
        // Rollback: Hapus data pertemuan jika insert laporan gagal
        await supabaseAdmin.from('pertemuan').delete().eq('id', newPertemuanId);
        throw laporanError;
      }
    }

    return new Response(JSON.stringify({ success: true, message: 'Laporan berhasil dibuat' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (err: any) {
    // Log untuk debugging: lihat error yang terjadi di server
    console.error('--- [ERROR EDGE] Terjadi kesalahan di server: ---', err)
    return new Response(JSON.stringify({ success: false, error: err.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})