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
    // Ambil semua data yang dikirim dari Flutter
   const { pertemuan_id, tanggal, tempat, catatan, foto_url, old_foto_url, laporan_mentees } = await req.json();
    if (!pertemuan_id || !tanggal || !laporan_mentees) {
      throw new Error('ID pertemuan, tanggal, dan laporan mentee wajib diisi.');
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

     if (old_foto_url && old_foto_url !== foto_url) {
      try {
        const oldFileName = old_foto_url.split('/').pop();
        if (oldFileName) {
          await supabaseAdmin.storage.from('foto_pertemuan').remove([oldFileName]);
        }
      } catch(e) {
        const error = e as Error;
        console.error('Gagal menghapus foto lama:', error.message);
      }
    }


    // 1. Update data utama di tabel 'pertemuan'
    const { error: updateError } = await supabaseAdmin
      .from('pertemuan')
      .update({ 
        tanggal: tanggal, 
        tempat: tempat, 
        catatan: catatan, 
        foto_url: foto_url 
      })
      .eq('id', pertemuan_id);
      
    if (updateError) throw updateError;

    // 2. Hapus semua laporan mentee lama yang terkait dengan pertemuan ini
    const { error: deleteError } = await supabaseAdmin
      .from('laporan_mentee')
      .delete()
      .eq('pertemuan_id', pertemuan_id);
      
    if (deleteError) throw deleteError;

    // 3. Siapkan dan masukkan kembali laporan mentee yang baru
    const laporanData = laporan_mentees.map((laporan: any) => ({
      ...laporan,
      pertemuan_id: pertemuan_id,
    }));
    
    if (laporanData.length > 0) {
      const { error: insertError } = await supabaseAdmin
        .from('laporan_mentee')
        .insert(laporanData);
        
      if (insertError) throw insertError;
    }

    return new Response(JSON.stringify({ success: true, message: 'Laporan berhasil diperbarui' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (err: any) {
    console.error('--- [ERROR EDGE] Gagal update laporan: ---', err)
    return new Response(JSON.stringify({ success: false, error: err.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})