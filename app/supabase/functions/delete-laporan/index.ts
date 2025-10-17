// supabase/functions/delete-laporan/index.ts

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0'

const corsHeaders = {
  'Access-control-allow-origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { pertemuan_id } = await req.json();
    if (!pertemuan_id) throw new Error('ID Pertemuan wajib diisi.');

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );
    
    // LANGKAH 1: Ambil URL foto dari record yang akan dihapus
    const { data: pertemuanData, error: selectError } = await supabaseAdmin
      .from('pertemuan')
      .select('foto_url')
      .eq('id', pertemuan_id)
      .single();

    if (selectError) {
      // Jika record tidak ditemukan, anggap saja sudah terhapus.
      if(selectError.code === 'PGRST116') {
         return new Response(JSON.stringify({ success: true, message: 'Laporan tidak ditemukan, mungkin sudah dihapus' }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
          });
      }
      throw selectError;
    }

    // LANGKAH 2: Jika ada URL foto, hapus file dari Storage
    if (pertemuanData && pertemuanData.foto_url) {
      const fileName = pertemuanData.foto_url.split('/').pop();
      
      if (fileName) {
        //  PERBAIKAN: Tangkap error spesifik dari storage.remove
        const { error: storageError } = await supabaseAdmin.storage
          .from('foto_pertemuan')
          .remove([fileName]);
        
        // Jika ada error saat menghapus file (misal: file not found),
        // kita bisa memilih untuk mengabaikannya dan tetap lanjut, atau menghentikan proses.
        // Untuk kasus ini, kita log errornya tapi tetap lanjut menghapus record DB.
        if (storageError) {
          console.error(`Gagal menghapus file ${fileName} dari storage:`, storageError.message);
        }
      }
    }

    // LANGKAH 3: Hapus record dari tabel 'pertemuan'
    const { error: deleteDbError } = await supabaseAdmin
      .from('pertemuan')
      .delete()
      .eq('id', pertemuan_id);
      
    if (deleteDbError) throw deleteDbError;

    return new Response(JSON.stringify({ success: true, message: 'Laporan dan foto terkait berhasil dihapus' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (err: any) {
    console.error('--- [ERROR EDGE] Gagal hapus laporan: ---', err)
    return new Response(JSON.stringify({ success: false, error: err.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
})