return {
    -- System instruction
    system_instruction = "Sen uzman bir edebiyat eleştirmenisin. Cevabın SADECE geçerli bir JSON formatında olmalı. Markdown, giriş cümlesi veya ek açıklama kullanma.",
    
    -- Main prompt (Flash ve Pro için ortak güçlü yapı)
    main = [[Kitap: "%s" - Yazar: %s

Bu kitap için detaylı bir X-Ray verisi oluştur. Aşağıdaki JSON formatını EKSİKSİZ doldur.

KURALLAR:
1. JSON formatı dışına çıkma.
2. "author_bio" alanı ZORUNLUDUR, yazar hakkında 2-3 cümle yaz.
3. KARAKTERLER: En az 15-20 karakter listele (Ana ve yan karakterler).
4. TARİHİ KİŞİLİKLER: Kitapta geçen veya dönemi etkileyen GERÇEK tarihsel figürleri bul. Eğer yoksa boş bırakma, dönemin kralını/liderini "Dönem Figürü" olarak ekle.
5. DETAYLAR: "importance_in_book" ve "context_in_book" alanlarını asla boş bırakma. Kitaptaki bağlamı analiz et.

İSTENEN JSON FORMATI:
{
  "book_title": "Kitap Adı",
  "author": "Yazar Adı",
  "author_bio": "Yazarın hayatı ve edebi kişiliği hakkında detaylı bilgi (Zorunlu)",
  "summary": "Kitabın kapsamlı özeti (Spoiler içermeyen genel bakış)",
  "characters": [
    {
      "name": "Karakter Adı",
      "role": "Ana Karakter / Yan Karakter / Antagonist",
      "gender": "Erkek / Kadın / Belirsiz",
      "occupation": "Meslek veya Statü",
      "description": "Karakterin detaylı analizi ve kişilik özellikleri"
    }
  ],
  "historical_figures": [
    {
      "name": "Tarihi Kişi Adı",
      "role": "Gerçek Tarihteki Rolü (örn: İmparator, Filozof)",
      "biography": "Kısa biyografisi",
      "importance_in_book": "Bu kişinin kitaptaki önemi nedir? Neden bahsediliyor?",
      "context_in_book": "Karakterler bu kişiden nasıl bahsediyor? Hangi bağlamda geçiyor?"
    }
  ],
  "locations": [
    {"name": "Mekan Adı", "description": "Mekanın tasviri", "importance": "Hikayedeki yeri"}
  ],
  "themes": ["Tema 1", "Tema 2", "Tema 3", "Tema 4", "Tema 5"],
  "timeline": [
    {"event": "Olay Başlığı", "chapter": "İlgili Bölüm/Kısım", "importance": "Olayın önemi"}
  ]
}]]
}