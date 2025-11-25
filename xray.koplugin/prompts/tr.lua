return {
    -- System instruction
    system_instruction = "Sen uzman bir edebiyat eleştirmenisin. Cevabın YALNIZCA geçerli JSON formatında olmalı. Markdown, giriş cümleleri veya ek açıklamalar kullanma. Yanıtını Türkçe olarak hazırla.",
    
    -- Main prompt (Full book analysis)
    main = [[Kitap: "%s" - Yazar: %s
Bu kitap için detaylı X-Ray verisi oluştur. Aşağıdaki JSON formatını EKSİKSİZ olarak doldur.

KURALLAR:
1. JSON formatından asla sapma.
2. "author_bio" alanı ZORUNLUDUR; yazar hakkında 2-3 cümle yaz.
3. KARAKTERLER: En az 15-20 karakter listele (Baş kahramanlar ve yardımcı karakterler).
4. TARİHİ ŞAHSİYETLER: Kitapta adı geçen veya o dönemi etkileyen GERÇEK tarihi kişileri bul. Hiçbiri yoksa boş bırakma; dönemin kralını/liderini "Dönem Figürü" olarak ekle.
5. DETAYLAR: "importance_in_book" ve "context_in_book" alanlarını asla boş bırakma. Kitap içindeki bağlamı analiz et.

GEREKLİ JSON FORMATI:
{
  "book_title": "Kitap Başlığı",
  "author": "Yazar Adı",
  "author_bio": "Yazarın hayatı ve edebi kişiliği hakkında detaylı bilgi (Zorunlu)",
  "summary": "Kitabın kapsamlı özeti (Spoiler içermeyen genel bakış)",
  "characters": [
    {
      "name": "Karakter Adı",
      "role": "Baş Kahraman / Yardımcı Karakter / Antagonist",
      "gender": "Erkek / Kadın / Belirsiz",
      "occupation": "Meslek veya Statü",
      "description": "Karakterin detaylı analizi ve kişilik özellikleri"
    }
  ],
  "historical_figures": [
    {
      "name": "Tarihi Kişinin Adı",
      "role": "Gerçek Tarihteki Rolü (örn. İmparator, Filozof)",
      "biography": "Kısa biyografi",
      "importance_in_book": "Bu kişinin kitaptaki önemi nedir? Neden bahsediliyor?",
      "context_in_book": "Karakterler bu kişiden nasıl bahsediyor? Hangi bağlamda geçiyor?"
    }
  ],
  "locations": [
    {"name": "Konum Adı", "description": "Konumun açıklaması", "importance": "Hikayedeki önemi"}
  ],
  "themes": ["Tema 1", "Tema 2", "Tema 3", "Tema 4", "Tema 5"],
  "timeline": [
    {"event": "Olay Başlığı", "chapter": "İlgili Bölüm/Kısım", "importance": "Olayın önemi"}
  ]
}]],

    -- Spoiler-free prompt (Based on reading progress)
    spoiler_free = [[Kitap: "%s" - Yazar: %s
KRİTİK: Okuyucu bu kitabın %d%% kadarını okudu. YALNIZCA bu okuma noktasına kadar olan içerik için X-Ray verisi oluştur.

SPOILER ÖNLEME KURALLARI:
1. Bu okuma noktasından SONRA ortaya çıkan karakterleri DAHİL ETME.
2. Bu noktadan SONRA gerçekleşen olaylardan bahsetme.
3. Kitabın ilerleyen kısımlarında gerçekleşen karakter gelişimlerini açığa çıkarma.
4. Zaman çizelgesi olayları YALNIZCA okuyucunun okuduğu kısımları kapsamalıdır.
5. Karakter tanımları daha sonraki gelişmeleri değil, mevcut durumlarını yansıtmalıdır.
6. Özet YALNIZCA okuyucunun deneyimlediği olayları kapsamalıdır.

EK KURALLAR:
1. Yazar biyografisi zorunludur (bu asla spoiler içermez).
2. Tarihi şahsiyetler, halihazırda okunan kısımda bahsedilmişlerse dahil edilebilir.
3. Konumlar yalnızca şimdiye kadar ziyaret edilen/bahsedilenler olmalıdır.
4. Temalar hikayenin bu noktasına kadar belirgin olanları yansıtmalıdır.

GEREKLİ JSON FORMATI:
{
  "book_title": "Kitap Başlığı",
  "author": "Yazar Adı",
  "author_bio": "Yazarın hayatı ve edebi kişiliği hakkında detaylı bilgi (Zorunlu)",
  "summary": "YALNIZCA okuyucunun şimdiye kadar okuduğu kısmı kapsayan özet",
  "characters": [
    {
      "name": "Karakter Adı (yalnızca tanıtıldıysa)",
      "role": "Baş Kahraman / Yardımcı Karakter / Antagonist",
      "gender": "Erkek / Kadın / Belirsiz",
      "occupation": "Meslek veya Statü",
      "description": "Mevcut okuma noktasındaki karakter durumu - sonraki gelişmeleri AÇIKLAMA"
    }
  ],
  "historical_figures": [
    {
      "name": "Tarihi Kişinin Adı",
      "role": "Gerçek Tarihteki Rolü",
      "biography": "Kısa biyografi",
      "importance_in_book": "Mevcut okuma noktasına kadar olan ilgisi",
      "context_in_book": "Okunan kısımda nasıl bahsedildiği"
    }
  ],
  "locations": [
    {"name": "Konum Adı (yalnızca şimdiye kadar ziyaret edildiyse/bahsedildiyse)", "description": "Açıklama", "importance": "Bu noktaya kadar olan önemi"}
  ],
  "themes": ["Yalnızca şimdiye kadar hikayede belirgin olan temalar"],
  "timeline": [
    {"event": "Olay Başlığı (YALNIZCA gerçekleşmiş olaylar)", "chapter": "İlgili Bölüm/Kısım", "importance": "Önem"}
  ]
}]],

    -- Fallback strings
    fallback = {
        unknown_book = "Bilinmeyen Kitap",
        unknown_author = "Bilinmeyen Yazar",
        unnamed_character = "İsimsiz Karakter",
        not_specified = "Belirtilmemiş",
        no_description = "Açıklama Yok",
        unnamed_person = "İsimsiz Kişi",
        no_biography = "Biyografi Mevcut Değil"
    }
}