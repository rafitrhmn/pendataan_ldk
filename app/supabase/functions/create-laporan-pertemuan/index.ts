// supabase/functions/create-laporan-pertemuan/index.ts

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
    // DIUBAH: Hapus 'foto_url' dan tambahkan 'tempat'
    const { kelompok_id, tanggal, tempat, catatan, laporan_mentees } = await req.json()
    if (!kelompok_id || !tanggal || !laporan_mentees) {
      throw new Error('Data kelompok, tanggal, dan laporan mentee wajib diisi.');
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Masukkan data ke tabel 'pertemuan' dan ambil ID nya yang baru
    const { data: pertemuanData, error: pertemuanError } = await supabaseAdmin
      .from('pertemuan')
      .insert({
        kelompok_id: kelompok_id,
        tanggal: tanggal,
        tempat: tempat, // Kolom baru ditambahkan
        catatan: catatan,
        // foto_url dihapus dari sini
      })
      .select('id')
      .single();

    if (pertemuanError) throw pertemuanError;
    const newPertemuanId = pertemuanData.id;

    // Siapkan data laporan mentee dengan menambahkan pertemuan_id ke setiap item
    const laporanData = laporan_mentees.map((laporan: any) => ({
      ...laporan,
      pertemuan_id: newPertemuanId,
    }));
    
    if(laporanData.length > 0) {
      // Masukkan semua laporan mentee sekaligus (bulk insert)
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
    return new Response(JSON.stringify({ success: false, error: err.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})