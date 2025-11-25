-- X-Ray API Configuration

return {
    -- Google Gemini API Key
    -- API key almak için: https://makersuite.google.com/app/apikey
    gemini_api_key = "AIzaSy----",  -- Buraya API keyinizi yazın: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    
    -- Gemini Model Seçimi
    -- "gemini-2.5-flash"
    -- "gemini-2.5-pro"
    -- "gemini-3.0-preview"
    gemini_model = "gemini-2.5-flash",
    
    -- ChatGPT API Key 
    -- API key almak için: https://platform.openai.com/api-keys
    chatgpt_api_key = "sk-XXXX",  -- Buraya API keyinizi yazın: "sk-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    
    -- Varsayılan AI Sağlayıcı
    default_provider = "gemini",
    
    -- Ayarlar
    settings = {
        auto_fetch_on_open = false,  -- Kitap açılınca otomatik veri çeksin mi?
        cache_duration_days = -1,    -- Cache süresiz geçerli! 
        max_characters = 20,         -- Maksimum kaç karakter gösterilsin?
    }
}
