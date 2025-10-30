-- Localization Module for X-Ray Plugin
-- Supports Turkish and English

local Localization = {
    current_language = "tr", -- Default language
    
    translations = {
        tr = {
            -- Menu items
            menu_xray = "X-Ray",
            menu_characters = "👥 Karakterler",
            menu_chapter_characters = "📖 Bu Bölümde Hangi Karakterler Var?",
            menu_character_notes = "📝 Karakter Notlarım",
            menu_timeline = "⏱️ Zaman Çizelgesi",
            menu_historical_figures = "📜 Tarihi Kişilikler",
            menu_locations = "📍 Mekanlar",
            menu_author_info = "✍️ Yazar Bilgisi",
            menu_summary = "📄 Özet",
            menu_themes = "🎨 Temalar",
            menu_fetch_ai = "🤖 AI ile Bilgi Çek",
            menu_ai_settings = "⚙️ AI Ayarları",
            menu_clear_cache = "🗑️ Cache Temizle",
            menu_xray_mode = "🔲 X-Ray Modu",
            menu_language = "🌍 Dil / Language",
            menu_about = "ℹ️ Hakkında",
            
            -- Status messages
            xray_mode_active = "✓ Aktif",
            xray_mode_inactive = "○ Kapalı",
            events = "olay",
            
            -- Info messages
            no_character_data = "Henüz karakter verisi yok. Önce 'AI ile Bilgi Çek' seçeneğini kullanın.",
            no_location_data = "Henüz mekan verisi yok. Önce 'AI ile Bilgi Çek' seçeneğini kullanın.",
            no_author_data = "Henüz yazar bilgisi yok. Önce 'AI ile Bilgi Çek' seçeneğini kullanın.",
            no_summary_data = "Henüz özet verisi yok. Önce 'AI ile Bilgi Çek' seçeneğini kullanın.",
            no_theme_data = "Henüz tema verisi yok. Önce 'AI ile Bilgi Çek' seçeneğini kullanın.",
            no_timeline_data = "⏱️ Henüz zaman çizelgesi yok.\n\nÖnce 'AI ile Bilgi Çek' seçeneğini kullanın.\n\nAI, kitaptaki önemli olayları\nkronolojik sırayla gösterecek.",
            no_historical_data = "📜 Henüz tarihi kişilik bilgisi yok.\n\nÖnce 'AI ile Bilgi Çek' seçeneğini kullanın.\n\nAI, kitapta geçen gerçek tarihi\nkişilikleri tespit edip bilgi verecek.",
            
            -- Auto-load messages
            xray_ready = "📖 X-Ray hazır ve aktif!",
            characters_loaded = "karakter",
            locations_loaded = "mekan",
            themes_loaded = "tema",
            no_cache_found = "Cache bulunamadı",
            
            -- Character details
            character_name = "Karakter:",
            description = "Açıklama:",
            role = "Rol:",
            gender = "Cinsiyet:",
            occupation = "Meslek:",
            not_specified = "Belirtilmemiş",
            no_description = "Açıklama yok",
            unnamed_character = "İsimsiz Karakter",
            unknown_character = "Bilinmeyen Karakter",
            
            -- Gender translations
            gender_male = "Erkek",
            gender_female = "Kadın",
            
            -- AI fetch messages
            checking_cache = "✅ Cache'den yüklendi!",
            book_title = "📚 Kitap:",
            characters_count = "👥 Karakterler:",
            locations_count = "📍 Mekanlar:",
            themes_count = "🎨 Temalar:",
            events_count = "⏱️ Olaylar:",
            historical_count = "📜 Tarihi Kişilikler:",
            cache_age = "📅 Cache yaşı:",
            days_old = "gün",
            unlimited_valid = "♾️ Süresiz geçerli!",
            fetch_new_data = "💡 Yeni veri çekmek için:\nMenü → X-Ray → Cache Temizle",
            
            no_api_key = "⚠️ AI API Key ayarlanmamış!\n\nMenü → X-Ray → AI Ayarları\nbölümünden API key girin.",
            fetching_ai = "🤖 AI'dan veri çekiliyor...\n\nSağlayıcı: %s\nLütfen bekleyin (10-15 saniye)",
            ai_fetch_failed = "❌ AI'dan veri çekilemedi!\n\nSebep olabilir:\n• API key hatalı\n• İnternet bağlantısı yok\n• API limiti aşıldı",
            
            ai_fetch_complete = "✅ AI'dan veri çekme tamamlandı!\n\n🤖 Sağlayıcı: %s\n📚 Kitap: %s\n\n👥 Karakterler: %d\n✍️ Yazar: %s\n📍 Mekanlar: %d\n🎨 Temalar: %d\n⏱️ Önemli Olaylar: %d\n📜 Tarihi Kişilikler: %d\n\n✨ Tüm bilgiler TÜRKÇE!\n♾️ Cache süresiz geçerli!\n%s",
            cache_saved = "💾 Cache'e kaydedildi!",
            cache_save_failed = "⚠️ Cache kaydedilemedi",
            
            -- Cache clear
            cache_clear_confirm = "⚠️ Cache Temizleme Onayı\n\nCache'i temizlerseniz:\n\n• Tüm karakter bilgileri silinir\n• Zaman çizelgesi silinir\n• Tarihi kişilikler silinir\n• Mekan ve tema bilgileri silinir\n• Yazar bilgisi silinir\n\nYeniden AI'dan veri çekmeniz gerekir.\n\nCache'i temizlemek istediğinizden emin misiniz?",
            yes_clear = "Evet, Temizle",
            cancel = "İptal",
            cache_cleared = "✅ Cache temizlendi!\n\nŞimdi yeni veri çekebilirsiniz:\nMenü → X-Ray → AI ile Bilgi Çek",
            cache_not_found = "⚠️ Cache bulunamadı veya temizlenemedi",
            
            -- X-Ray mode
            xray_mode_no_data = "⚠️ X-Ray Modu için önce veri çekin!\n\nMenü → X-Ray → AI ile Bilgi Çek",
            xray_mode_enabled = "✅ X-Ray Modu Aktif!\n\nℹ️ Not: Metin seçme özelliği\nşu an aktif değil.\n\nKarakter aramak için:\nMenü → X-Ray → Karakterler → 🔍 Ara",
            xray_mode_disabled = "❌ X-Ray Modu Kapatıldı",
            
            -- Search
            search_character = "🔍 Karakter Ara...",
            search_character_title = "🔍 Karakter Ara",
            search_hint = "İsim yazın (örn: Stavrogin)",
            search_button = "Ara",
            character_not_found = "❌ Karakter bulunamadı: %s\n\nİpucu: İsmin bir kısmını yazın",
            
            -- Timeline
            timeline_event = "⏱️ Olay #%d",
            chapter = "📖 Bölüm:",
            characters_involved = "👥 Karakterler:",
            importance = "🎯 Önemi:",
            
            -- Chapter analysis
            analyzing_chapter = "📖 Bölüm analiz ediliyor...\n\nLütfen bekleyin",
            chapter_text_error = "❌ Bölüm metni alınamadı",
            no_characters_in_chapter = "Bu bölümde hiç karakter bulunamadı.\n\nBölüm: %s",
            this_chapter = "Bu Bölüm",
            
            -- Character notes
            character_notes_title = "📝 Karakter Notlarım (%d not)",
            add_note = "Not ekle",
            note_saved = "✅ Not kaydedildi!\n\n%s",
            note_deleted = "✅ Not silindi!\n\n%s",
            add_note_title = "📝 %s için not ekle",
            note_hint = "Karakterle ilgili notunuz...",
            save = "Kaydet",
            delete = "Sil",
            
            -- Quick menu
            quick_menu_title = "📖 X-Ray Hızlı Erişim",
            fetch_data = "🔄 AI ile Veri Çek",
            
            -- About
            about_title = "X-Ray Plugin v1.0.0",
            about_text = [[📖 X-Ray Plugin v1.0.0
═══════════════════════════════

🎯 NE YAPAR?
Kitaplarınızı Amazon Kindle X-Ray gibi zenginleştirir!
AI kullanarak karakterler, mekanlar, tarihsel bağlam ve 
daha fazlasını otomatik olarak çıkarır.

═══════════════════════════════

🆕 YENİ ÖZELLIKLER (v1.0.0):

📊 Akıllı Menüler
   • Her menü öğesinde canlı sayaçlar
   • Karakterler (12), Mekanlar (8) gibi

🌍 Çoklu Dil Desteği
   • Türkçe ve İngilizce arayüz
   • AI'dan dile özel veri çekme
   • Kolayca yeni dil eklenebilir

🔍 Gelişmiş Tarihi Analiz
   • Doğrudan referansları yakalar
   • Dolaylı referansları tespit eder
   • Felsefi ve entelektüel bağlamları bulur

⏱️ Daha İyi Geri Bildirim
   • AI çekme süresi bildirimleri
   • Detaylı ilerleme mesajları
   • Cache durumu raporları

═══════════════════════════════

✨ TÜM ÖZELLİKLER:

🤖 AI Entegrasyonu
   • Google Gemini desteği (ÜCRETSİZ!)
   • ChatGPT desteği
   • Akıllı JSON parsing
   • Hata telafisi mekanizması

👥 Karakter Yönetimi
   • Otomatik karakter çıkarımı
   • Detaylı karakter profilleri
   • Cinsiyet, meslek, rol bilgisi
   • Karakter arama özelliği
   • Kişisel not alma sistemi

📖 Bölüm Analizi
   • Anlık bölüm karakterlerini göster
   • Karakter geçiş sıklığı analizi
   • Bölüm bazlı filtreleme

⏱️ Zaman Çizelgesi
   • Önemli olayları kronolojik sırala
   • Olay-karakter ilişkilendirme
   • Spoiler-free açıklamalar

📜 Tarihi Kişilikler
   • Gerçek tarihi figürleri tespit et
   • Biyografik bilgiler
   • Kitaptaki bağlam açıklaması
   • Doğum-ölüm tarihleri

📍 Mekanlar
   • Önemli lokasyonlar
   • Mekan açıklamaları
   • Hikayedeki önemleri

🎨 Temalar ve Özet
   • Ana temaları listele
   • Spoiler-free özet
   • Yazar biyografisi

💾 Cache Sistemi
   • Otomatik veri kaydetme
   • Süresiz geçerlilik
   • Offline kullanım
   • Kitap başına ayrı cache

═══════════════════════════════

🚀 HIZLI BAŞLANGIÇ:

1️⃣ API Key Al
   Menü → X-Ray → AI Ayarları
   → Google Gemini API Key
   (Ücretsiz: makersuite.google.com)

2️⃣ Veri Çek
   Menü → X-Ray → AI ile Bilgi Çek
   (İlk seferde 10-15 saniye sürer)

3️⃣ Keşfet!
   • Karakterler: Tüm karakterleri gör
   • Bu Bölümde: Mevcut bölümdeki karakterler
   • Zaman Çizelgesi: Olayları takip et
   • Tarihi Kişilikler: Gerçek tarihi figürler

═══════════════════════════════

⌨️ KISAYOLLAR:

Alt + X : Hızlı X-Ray menüsü
Menü → X-Ray : Tam menü
Menü tutarak bas : Hızlı menü

═══════════════════════════════

💡 İPUÇLARI:

• Cache bir kez oluşturulur, sonsuza kadar kullanılır
• İnternet sadece ilk veri çekme için gerekli
• Karakter notları kitap başına kaydedilir
• Dil değişikliği hemen uygulanır
• Gemini Flash modeli ücretsiz ve hızlıdır

═══════════════════════════════

🔧 TEKNİK BİLGİLER:

Versiyon: 1.0.0
Platform: KOReader
Geliştirme: 2025
Lisans: MIT (varsayılan)

AI Modelleri:
• Gemini 2.5 Flash (varsayılan, ücretsiz)
• Gemini 2.5 Pro (opsiyonel)
• GPT-3.5 Turbo

Cache Konumu:
~/.config/koreader/cache/xray/

Ayarlar Konumu:
~/.config/koreader/settings/xray/

═══════════════════════════════

📚 ÖRNEK KULLANIM SENARYOLARI:

"Ecinniler" (Dostoyevski) okuyorsunuz:
✓ 15+ karakter otomatik tespit edildi
✓ Sergei Nechayev gibi tarihi figürler eklendi
✓ 1860'lar Rusya sosyalist hareketi açıklandı
✓ Karakterlerin ilk görünüşleri işaretlendi

"Savaş ve Barış" (Tolstoy) okuyorsunuz:
✓ 100+ karakter organize edildi
✓ Napolyon, Kutuzov gibi tarihsel figürler
✓ Borodino Savaşı gibi olaylar zaman çizelgesinde
✓ Moskova, Petersburg gibi mekanlar detaylı

"1984" (Orwell) okuyorsunuz:
✓ Winston, Julia, O'Brien karakterleri
✓ Distopik temalar listelendi
✓ Bölüm bölüm karakter takibi
✓ Kişisel notlarla analiz

═══════════════════════════════

❓ SSS:

S: API key ücretsiz mi?
C: Evet! Gemini API ücretsiz kotası var.

S: İnternet her zaman gerekli mi?
C: Hayır, sadece ilk veri çekme için.

S: Veriler nereden geliyor?
C: Google Gemini AI'dan, kitap adına göre.

S: Spoiler verir mi?
C: Hayır, AI spoiler vermemesi için eğitildi.

S: Hangi dilleri destekliyor?
C: Şu an Türkçe ve İngilizce. Daha fazlası eklenebilir.

S: Cache'i nasıl temizlerim?
C: Menü → X-Ray → Cache Temizle

═══════════════════════════════

🙏 TEŞEKKÜRLER:

• KOReader topluluğuna
• Google Gemini ekibine
• Beta test kullanıcılarına

═══════════════════════════════

📮 GERİ BİLDİRİM:

Önerilerinizi ve hata raporlarınızı
GitHub veya KOReader forumlarında paylaşın!

═══════════════════════════════

Keyifli okumalar! 📖✨]],
            
            -- Language selection
            language_title = "🌍 Dil Seçin / Select Language",
            language_turkish = "🇹🇷 Türkçe",
            language_english = "🇬🇧 English",
            language_changed = "✅ Dil değiştirildi: Türkçe",
            please_restart = "Değişikliklerin tam olarak uygulanması için\nuygulamayı yeniden başlatın.",
        },
        
        en = {
            -- Menu items
            menu_xray = "X-Ray",
            menu_characters = "👥 Characters",
            menu_chapter_characters = "📖 Characters in This Chapter",
            menu_character_notes = "📝 My Character Notes",
            menu_timeline = "⏱️ Timeline",
            menu_historical_figures = "📜 Historical Figures",
            menu_locations = "📍 Locations",
            menu_author_info = "✍️ Author Info",
            menu_summary = "📄 Summary",
            menu_themes = "🎨 Themes",
            menu_fetch_ai = "🤖 Fetch AI Data",
            menu_ai_settings = "⚙️ AI Settings",
            menu_clear_cache = "🗑️ Clear Cache",
            menu_xray_mode = "🔲 X-Ray Mode",
            menu_language = "🌍 Language / Dil",
            menu_about = "ℹ️ About",
            
            -- Status messages
            xray_mode_active = "✓ Active",
            xray_mode_inactive = "○ Inactive",
            events = "events",
            
            -- Info messages
            no_character_data = "No character data yet. Please use 'Fetch AI Data' first.",
            no_location_data = "No location data yet. Please use 'Fetch AI Data' first.",
            no_author_data = "No author data yet. Please use 'Fetch AI Data' first.",
            no_summary_data = "No summary data yet. Please use 'Fetch AI Data' first.",
            no_theme_data = "No theme data yet. Please use 'Fetch AI Data' first.",
            no_timeline_data = "⏱️ No timeline data yet.\n\nPlease use 'Fetch AI Data' first.\n\nAI will show important events\nin chronological order.",
            no_historical_data = "📜 No historical figure data yet.\n\nPlease use 'Fetch AI Data' first.\n\nAI will detect real historical\nfigures mentioned in the book.",
            
            -- Auto-load messages
            xray_ready = "📖 X-Ray ready and active!",
            characters_loaded = "characters",
            locations_loaded = "locations",
            themes_loaded = "themes",
            no_cache_found = "No cache found",
            
            -- Character details
            character_name = "Character:",
            description = "Description:",
            role = "Role:",
            gender = "Gender:",
            occupation = "Occupation:",
            not_specified = "Not specified",
            no_description = "No description",
            unnamed_character = "Unnamed Character",
            unknown_character = "Unknown Character",
            
            -- Gender translations
            gender_male = "Male",
            gender_female = "Female",
            
            -- AI fetch messages
            checking_cache = "✅ Loaded from cache!",
            book_title = "📚 Book:",
            characters_count = "👥 Characters:",
            locations_count = "📍 Locations:",
            themes_count = "🎨 Themes:",
            events_count = "⏱️ Events:",
            historical_count = "📜 Historical Figures:",
            cache_age = "📅 Cache age:",
            days_old = "days",
            unlimited_valid = "♾️ Valid indefinitely!",
            fetch_new_data = "💡 To fetch new data:\nMenu → X-Ray → Clear Cache",
            
            no_api_key = "⚠️ AI API Key not set!\n\nPlease enter API key in:\nMenu → X-Ray → AI Settings",
            fetching_ai = "🤖 Fetching AI data...\n\nProvider: %s\nPlease wait (10-15 seconds)",
            ai_fetch_failed = "❌ Failed to fetch AI data!\n\nPossible reasons:\n• Invalid API key\n• No internet connection\n• API limit exceeded",
            
            ai_fetch_complete = "✅ AI data fetch complete!\n\n🤖 Provider: %s\n📚 Book: %s\n\n👥 Characters: %d\n✍️ Author: %s\n📍 Locations: %d\n🎨 Themes: %d\n⏱️ Important Events: %d\n📜 Historical Figures: %d\n\n✨ All info in your language!\n♾️ Cache valid indefinitely!\n%s",
            cache_saved = "💾 Saved to cache!",
            cache_save_failed = "⚠️ Failed to save cache",
            
            -- Cache clear
            cache_clear_confirm = "⚠️ Cache Clear Confirmation\n\nIf you clear the cache:\n\n• All character data will be deleted\n• Timeline will be deleted\n• Historical figures will be deleted\n• Location and theme data will be deleted\n• Author info will be deleted\n\nYou'll need to fetch data from AI again.\n\nAre you sure you want to clear the cache?",
            yes_clear = "Yes, Clear",
            cancel = "Cancel",
            cache_cleared = "✅ Cache cleared!\n\nYou can now fetch new data:\nMenu → X-Ray → Fetch AI Data",
            cache_not_found = "⚠️ Cache not found or couldn't be cleared",
            
            -- X-Ray mode
            xray_mode_no_data = "⚠️ Please fetch data first for X-Ray Mode!\n\nMenu → X-Ray → Fetch AI Data",
            xray_mode_enabled = "✅ X-Ray Mode Active!\n\nℹ️ Note: Text selection feature\nis currently disabled.\n\nTo search characters:\nMenu → X-Ray → Characters → 🔍 Search",
            xray_mode_disabled = "❌ X-Ray Mode Disabled",
            
            -- Search
            search_character = "🔍 Search Character...",
            search_character_title = "🔍 Search Character",
            search_hint = "Enter name (e.g., Stavrogin)",
            search_button = "Search",
            character_not_found = "❌ Character not found: %s\n\nTip: Try part of the name",
            
            -- Timeline
            timeline_event = "⏱️ Event #%d",
            chapter = "📖 Chapter:",
            characters_involved = "👥 Characters:",
            importance = "🎯 Importance:",
            
            -- Chapter analysis
            analyzing_chapter = "📖 Analyzing chapter...\n\nPlease wait",
            chapter_text_error = "❌ Could not get chapter text",
            no_characters_in_chapter = "No characters found in this chapter.\n\nChapter: %s",
            this_chapter = "This Chapter",
            
            -- Character notes
            character_notes_title = "📝 My Character Notes (%d notes)",
            add_note = "Add note",
            note_saved = "✅ Note saved!\n\n%s",
            note_deleted = "✅ Note deleted!\n\n%s",
            add_note_title = "📝 Add note for %s",
            note_hint = "Your notes about the character...",
            save = "Save",
            delete = "Delete",
            
            -- Quick menu
            quick_menu_title = "📖 X-Ray Quick Access",
            fetch_data = "🔄 Fetch AI Data",
            
            -- About
            about_title = "X-Ray Plugin v1.0.0",
            about_text = [[📖 X-Ray Plugin v1.0.0
═══════════════════════════════

🎯 WHAT IT DOES?
Enriches your books like Amazon Kindle X-Ray!
Uses AI to automatically extract characters, locations,
historical context, and more.

═══════════════════════════════

🆕 NEW FEATURES (v1.0.0):

📊 Smart Menus
   • Live counters in every menu item
   • Like Characters (12), Locations (8)

🌍 Multi-Language Support
   • Turkish and English interface
   • Language-specific AI data fetching
   • Easy to add new languages

🔍 Enhanced Historical Analysis
   • Captures direct references
   • Detects indirect references
   • Finds philosophical and intellectual contexts

⏱️ Better Feedback
   • AI fetch duration notifications
   • Detailed progress messages
   • Cache status reports

═══════════════════════════════

✨ ALL FEATURES:

🤖 AI Integration
   • Google Gemini support (FREE!)
   • ChatGPT support
   • Smart JSON parsing
   • Error recovery mechanism

👥 Character Management
   • Automatic character extraction
   • Detailed character profiles
   • Gender, occupation, role info
   • Character search feature
   • Personal note-taking system

📖 Chapter Analysis
   • Show current chapter characters
   • Character occurrence frequency
   • Chapter-based filtering

⏱️ Timeline
   • Chronologically sort important events
   • Event-character associations
   • Spoiler-free descriptions

📜 Historical Figures
   • Detect real historical figures
   • Biographical information
   • Context in the book
   • Birth-death dates

📍 Locations
   • Important locations
   • Location descriptions
   • Their importance in the story

🎨 Themes and Summary
   • List main themes
   • Spoiler-free summary
   • Author biography

💾 Cache System
   • Automatic data saving
   • Valid indefinitely
   • Offline usage
   • Separate cache per book

═══════════════════════════════

🚀 QUICK START:

1️⃣ Get API Key
   Menu → X-Ray → AI Settings
   → Google Gemini API Key
   (Free: makersuite.google.com)

2️⃣ Fetch Data
   Menu → X-Ray → Fetch AI Data
   (Takes 10-15 seconds first time)

3️⃣ Explore!
   • Characters: See all characters
   • This Chapter: Characters in current chapter
   • Timeline: Track events
   • Historical Figures: Real historical figures

═══════════════════════════════

⌨️ SHORTCUTS:

Alt + X : Quick X-Ray menu
Menu → X-Ray : Full menu
Hold menu : Quick menu

═══════════════════════════════

💡 TIPS:

• Cache is created once, used forever
• Internet only needed for initial data fetch
• Character notes saved per book
• Language change applies immediately
• Gemini Flash model is free and fast

═══════════════════════════════

🔧 TECHNICAL INFO:

Version: 1.0.0
Platform: KOReader
Development: 2025
License: MIT (default)

AI Models:
• Gemini 2.5 Flash (default, free)
• Gemini 2.5 Pro (optional)
• GPT-3.5 Turbo

Cache Location:
~/.config/koreader/cache/xray/

Settings Location:
~/.config/koreader/settings/xray/

═══════════════════════════════

📚 EXAMPLE USE CASES:

Reading "Demons" (Dostoevsky):
✓ 15+ characters auto-detected
✓ Historical figures like Sergei Nechayev added
✓ 1860s Russian socialist movement explained
✓ Character first appearances marked

Reading "War and Peace" (Tolstoy):
✓ 100+ characters organized
✓ Historical figures like Napoleon, Kutuzov
✓ Events like Battle of Borodino in timeline
✓ Locations like Moscow, Petersburg detailed

Reading "1984" (Orwell):
✓ Winston, Julia, O'Brien characters
✓ Dystopian themes listed
✓ Chapter-by-chapter character tracking
✓ Personal notes for analysis

═══════════════════════════════

❓ FAQ:

Q: Is the API key free?
A: Yes! Gemini API has a free quota.

Q: Is internet always required?
A: No, only for initial data fetch.

Q: Where does the data come from?
A: From Google Gemini AI, based on book title.

Q: Does it give spoilers?
A: No, AI is trained to avoid spoilers.

Q: What languages are supported?
A: Currently Turkish and English. More can be added.

Q: How to clear cache?
A: Menu → X-Ray → Clear Cache

═══════════════════════════════

🙏 THANKS TO:

• KOReader community
• Google Gemini team
• Beta test users

═══════════════════════════════

📮 FEEDBACK:

Share your suggestions and bug reports
on GitHub or KOReader forums!

═══════════════════════════════

Happy reading! 📖✨]],
            
            -- Language selection
            language_title = "🌍 Select Language / Dil Seçin",
            language_turkish = "🇹🇷 Türkçe",
            language_english = "🇬🇧 English",
            language_changed = "✅ Language changed: English",
            please_restart = "Please restart the app for changes\nto take full effect.",
        }
    }
}

-- Get translation for a key
function Localization:t(key)
    local lang = self.current_language
    if self.translations[lang] and self.translations[lang][key] then
        return self.translations[lang][key]
    end
    -- Fallback to Turkish if key not found
    if self.translations["tr"][key] then
        return self.translations["tr"][key]
    end
    return key
end

-- Set language
function Localization:setLanguage(lang)
    if self.translations[lang] then
        self.current_language = lang
        self:saveLanguage()
        return true
    end
    return false
end

-- Get current language
function Localization:getLanguage()
    return self.current_language
end

-- Save language preference
function Localization:saveLanguage()
    local DataStorage = require("datastorage")
    local lfs = require("libs/libkoreader-lfs")
    
    local settings_dir = DataStorage:getSettingsDir()
    local xray_dir = settings_dir .. "/xray"
    
    -- Create directory if it doesn't exist
    if lfs.attributes(xray_dir, "mode") ~= "directory" then
        lfs.mkdir(xray_dir)
    end
    
    local settings_file = xray_dir .. "/language.txt"
    local file = io.open(settings_file, "w")
    if file then
        file:write(self.current_language)
        file:close()
    end
end

-- Load language preference
function Localization:loadLanguage()
    local DataStorage = require("datastorage")
    local settings_dir = DataStorage:getSettingsDir()
    local settings_file = settings_dir .. "/xray/language.txt"
    
    local file = io.open(settings_file, "r")
    if file then
        local lang = file:read("*a")
        file:close()
        
        -- Trim whitespace
        lang = lang:match("^%s*(.-)%s*$")
        
        if self.translations[lang] then
            self.current_language = lang
        end
    end
end

-- Initialize (load saved language)
function Localization:init()
    self:loadLanguage()
end

return Localization