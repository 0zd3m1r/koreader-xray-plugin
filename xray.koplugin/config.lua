-- X-Ray API Configuration

return {
    -- Google Gemini API Key
    -- API key almak için: https://makersuite.google.com/app/apikey
    gemini_api_key = "AIzaSy*****",  -- Write API key: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    
    -- Gemini Model
    -- "gemini-2.5-flash" (free, fast)
    -- "gemini-2.5-pro" (Gemini Pro account)
    gemini_model = "gemini-2.5-flash",
    
    -- ChatGPT API Key 
    -- API key almak için: https://platform.openai.com/api-keys
    chatgpt_api_key = "",  -- Write API key: "sk-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    
    -- Default AI Provider ("gemini" or "chatgpt")
    default_provider = "gemini",
    
    -- Ayarlar
    settings = {
        auto_fetch_on_open = false,  -- Kitap açılınca otomatik veri çeksin mi?
        cache_duration_days = -1,    -- Cache süresiz geçerli! 
        max_characters = 20,         -- Maksimum kaç karakter gösterilsin?
    }
}
