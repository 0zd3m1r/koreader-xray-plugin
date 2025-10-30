-- AIHelper - Google Gemini & ChatGPT for X-Ray v1.0.0
local http = require("socket.http")
local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("json")
local logger = require("logger")

local AIHelper = {}

-- Load configuration from config.lua
function AIHelper:loadConfig()
    local config_path = "config"
    local success, config = pcall(require, config_path)
    
    if success and config then
        logger.info("AIHelper: Config loaded from config.lua")
        
        -- Load Gemini API key
        if config.gemini_api_key and #config.gemini_api_key > 0 then
            self.providers.gemini.api_key = config.gemini_api_key
            logger.info("AIHelper: Gemini API key loaded from config")
        end
        
        -- Load Gemini model preference
        if config.gemini_model then
            self.providers.gemini.model = config.gemini_model
            logger.info("AIHelper: Gemini model set to:", config.gemini_model)
        end
        
        -- Load ChatGPT API key
        if config.chatgpt_api_key and #config.chatgpt_api_key > 0 then
            self.providers.chatgpt.api_key = config.chatgpt_api_key
            logger.info("AIHelper: ChatGPT API key loaded from config")
        end
        
        -- Load default provider
        if config.default_provider then
            self.default_provider = config.default_provider
            logger.info("AIHelper: Default provider set to:", config.default_provider)
        end
        
        -- Load settings
        if config.settings then
            self.settings = config.settings
            logger.info("AIHelper: Settings loaded from config")
        end
        
        return true
    else
        logger.info("AIHelper: No config.lua found or error loading it")
        return false
    end
end

-- Initialize AIHelper (call this when module loads)
function AIHelper:init()
    self:loadConfig()
    
    -- Load current language
    self:loadLanguage()
end

-- Load language preference
function AIHelper:loadLanguage()
    local DataStorage = require("datastorage")
    local settings_dir = DataStorage:getSettingsDir()
    local language_file = settings_dir .. "/xray/language.txt"
    
    local file = io.open(language_file, "r")
    if file then
        local lang = file:read("*a")
        file:close()
        
        -- Trim whitespace
        lang = lang:match("^%s*(.-)%s*$")
        
        if lang == "tr" or lang == "en" then
            self.current_language = lang
            logger.info("AIHelper: Language loaded:", lang)
        else
            self.current_language = "tr" -- Default
            logger.info("AIHelper: Using default language: tr")
        end
    else
        self.current_language = "tr" -- Default
        logger.info("AIHelper: No language file found, using default: tr")
    end
end

-- AI Provider settings
AIHelper.providers = {
    gemini = {
        name = "Google Gemini",
        enabled = true,
        api_key = nil,
        model = "gemini-2.5-flash",
    },
    chatgpt = {
        name = "ChatGPT",
        enabled = true,
        api_key = nil,
        endpoint = "https://api.openai.com/v1/chat/completions",
        model = "gpt-3.5-turbo",
    }
}

-- Get book data from AI
function AIHelper:getBookData(title, author, provider_name)
    logger.info("AIHelper: Getting book data from", provider_name or "default provider")
    logger.info("AIHelper: Language:", self.current_language or "tr")
    
    local provider = provider_name or "gemini"
    local provider_config = self.providers[provider]
    
    if not provider_config or not provider_config.enabled then
        logger.warn("AIHelper: Provider not available:", provider)
        return nil
    end
    
    if not provider_config.api_key then
        logger.warn("AIHelper: API key not set for provider:", provider)
        return nil
    end
    
    -- Create prompt in selected language
    local prompt = self:createPrompt(title, author)
    
    -- Call AI based on provider
    if provider == "gemini" then
        return self:callGemini(prompt, provider_config)
    elseif provider == "chatgpt" then
        return self:callChatGPT(prompt, provider_config)
    end
    
    return nil
end

-- Prompt templates for each language
AIHelper.prompts = {
    tr = {
        system_instruction = "Sen bir kitap uzmanısın. Kitaplar hakkında detaylı bilgi veriyorsun. SADECE JSON formatında cevap ver, başka hiçbir şey yazma.",
        
        main_prompt = [[
Kitap: "%s" - Yazar: %s

Lütfen bu kitap hakkında aşağıdaki bilgileri TÜRKÇE olarak JSON formatında ver. SADECE JSON döndür, başka açıklama yazma.

{
  "book_title": "kitap adı",
  "author": "yazar adı",
  "author_bio": "yazarın kısa biyografisi (2-3 cümle)",
  "author_birth": "doğum tarihi",
  "author_death": "ölüm tarihi (varsa)",
  "characters": [
    {
      "name": "karakter adı",
      "description": "karakterin kim olduğu (2-3 cümle, SPOILER VERME)",
      "role": "romanın içindeki rolü (ana karakter, yan karakter, vb)",
      "gender": "erkek/kadın",
      "occupation": "mesleği (varsa)"
    }
  ],
  "locations": [
    {
      "name": "mekan adı",
      "description": "mekanın kısa açıklaması",
      "importance": "bu mekanın hikayedeki önemi"
    }
  ],
  "themes": [
    "tema 1",
    "tema 2",
    "tema 3"
  ],
  "summary": "kitabın kısa özeti (3-4 cümle, SPOILER VERME)",
  "timeline": [
    {
      "chapter": "bölüm adı veya numarası (örn: Bölüm 1, Başlangıç)",
      "event": "önemli olay açıklaması (SPOILER VERME, sadece genel açıklama)",
      "characters": ["bu olayda yer alan karakter1", "karakter2"],
      "importance": "bu olayın hikayedeki önemi"
    }
  ],
  "historical_figures": [
    {
      "name": "tarihi kişiliğin tam adı",
      "birth_year": "doğum yılı (örn: 1769)",
      "death_year": "ölüm yılı (örn: 1821, veya yaşıyorsa null)",
      "role": "kısa rol/ünvan (örn: Fransız İmparatoru, Rus Yazar)",
      "biography": "kişi hakkında kısa biyografi (2-3 cümle)",
      "importance_in_book": "bu kişinin kitapta neden geçtiği",
      "context_in_book": "kitapta nasıl/nerede bahsedildiği"
    }
  ]
}

ÖNEMLİ: 
- Tüm açıklamalar TÜRKÇE olsun
- SPOILER verme, sadece karakterin kim olduğunu anlat
- En az 10 ana karakter ekle
- Timeline için 5-10 önemli olay ekle (kronolojik sırayla)
- Timeline'da SPOILER verme, sadece genel olayları belirt

TARİHİ KİŞİLİKLER İÇİN GELİŞMİŞ KURALLAR:
Bu kitabı analiz et ve şu tür gerçek tarihi kişilikleri bul:

1. DOĞRUDAN REFERANSLAR:
   - Kitapta ismi açıkça geçen gerçek tarihi kişiler

2. DOLAYLI REFERANSLAR (ÇOK ÖNEMLİ!):
   - Tarihi olaylar: Eğer "Nechayev Olayı", "Fransız Devrimi" gibi olaylar geçiyorsa, bu olayların aktörleri
   - Entelektüel hareketler: "1860'lar nihilizmi", "Alman idealizmi" gibi akımlar geçiyorsa, önemli temsilcileri
   - Felsefi göndermeler: Karakterler Fourier, Hegel, Marx'tan bahsediyorsa onları ekle
   - Dönemin atmosferi: Romanın geçtiği dönemin önemli figürleri (sadece çok relevantsa)

3. ÖRNEKLER:
   - "Ecinniler" (Dostoyevski):
     * Sergei Nechayev (romanın temelindeki gerçek olay)
     * Alexander Herzen (dönemin sosyalist düşünürü)
     * Vissarion Belinski (1860'lar entelektüel atmosferi)
   
   - "Savaş ve Barış":
     * Napolyon Bonaparte (merkezi figür)
     * Kutuzov (Rus generali)
     * Alexander I (Rus çarı)

4. NE YAPMA:
   - Kurgusal karakterleri ekleme
   - Emin olmadığın kişileri ekleme
   - Zorlama, relevans yoksa boş liste [] döndür

- JSON formatı bozuk olmasın
]],
        
        fallback_strings = {
            unnamed_character = "İsimsiz Karakter",
            no_description = "Açıklama yok",
            not_specified = "Belirtilmemiş",
            unnamed_location = "İsimsiz Mekan",
            unnamed_person = "İsimsiz Kişi",
            no_biography = "Biyografi yok",
            chapter = "Bölüm",
            no_event_description = "Olay açıklaması yok",
            unknown_book = "Bilinmeyen Kitap",
            unknown_author = "Bilinmeyen Yazar",
        }
    },
    
    en = {
        system_instruction = "You are a book expert. You provide detailed information about books. ONLY respond in JSON format, nothing else.",
        
        main_prompt = [[
Book: "%s" - Author: %s

Please provide the following information about this book in ENGLISH in JSON format. ONLY return JSON, no other text.

{
  "book_title": "book title",
  "author": "author name",
  "author_bio": "author's brief biography (2-3 sentences)",
  "author_birth": "birth date",
  "author_death": "death date (if applicable)",
  "characters": [
    {
      "name": "character name",
      "description": "who the character is (2-3 sentences, NO SPOILERS)",
      "role": "role in the novel (main character, supporting character, etc)",
      "gender": "male/female",
      "occupation": "occupation (if any)"
    }
  ],
  "locations": [
    {
      "name": "location name",
      "description": "brief description of the location",
      "importance": "importance of this location in the story"
    }
  ],
  "themes": [
    "theme 1",
    "theme 2",
    "theme 3"
  ],
  "summary": "brief book summary (3-4 sentences, NO SPOILERS)",
  "timeline": [
    {
      "chapter": "chapter name or number (e.g., Chapter 1, Beginning)",
      "event": "important event description (NO SPOILERS, general description only)",
      "characters": ["character1 in this event", "character2"],
      "importance": "importance of this event in the story"
    }
  ],
  "historical_figures": [
    {
      "name": "full name of historical figure",
      "birth_year": "birth year (e.g., 1769)",
      "death_year": "death year (e.g., 1821, or null if alive)",
      "role": "brief role/title (e.g., French Emperor, Russian Writer)",
      "biography": "brief biography about the person (2-3 sentences)",
      "importance_in_book": "why this person is mentioned in the book",
      "context_in_book": "how/where they are mentioned in the book"
    }
  ]
}

IMPORTANT: 
- All descriptions should be in ENGLISH
- NO SPOILERS, only explain who the character is
- Add at least 10 main characters
- Add 5-10 important events for timeline (in chronological order)
- NO SPOILERS in timeline, only general events

ADVANCED RULES FOR HISTORICAL FIGURES:
Analyze this book and find these types of real historical figures:

1. DIRECT REFERENCES:
   - Real historical figures explicitly mentioned in the book

2. INDIRECT REFERENCES (VERY IMPORTANT!):
   - Historical events: If events like "Nechayev Affair", "French Revolution" are mentioned, include their actors
   - Intellectual movements: If movements like "1860s nihilism", "German idealism" are mentioned, include key representatives
   - Philosophical references: If characters mention Fourier, Hegel, Marx, include them
   - Period atmosphere: Important figures of the period when the novel is set (only if very relevant)

3. EXAMPLES:
   - "Demons" (Dostoevsky):
     * Sergei Nechayev (the real event behind the novel)
     * Alexander Herzen (socialist thinker of the period)
     * Vissarion Belinsky (intellectual atmosphere of the 1860s)
   
   - "War and Peace":
     * Napoleon Bonaparte (central figure)
     * Kutuzov (Russian general)
     * Alexander I (Russian Tsar)

4. DON'T:
   - Add fictional characters
   - Add people you're not sure about
   - Force it, return empty list [] if no relevance

- JSON format must be valid
]],
        
        fallback_strings = {
            unnamed_character = "Unnamed Character",
            no_description = "No description",
            not_specified = "Not specified",
            unnamed_location = "Unnamed Location",
            unnamed_person = "Unnamed Person",
            no_biography = "No biography",
            chapter = "Chapter",
            no_event_description = "No event description",
            unknown_book = "Unknown Book",
            unknown_author = "Unknown Author",
        }
    }
}

-- Create prompt for AI (with language support)
function AIHelper:createPrompt(title, author)
    local lang = self.current_language or "tr"
    local prompt_template = self.prompts[lang].main_prompt
    
    local prompt = string.format(prompt_template, title, author or "")
    
    logger.info("AIHelper: Created prompt in language:", lang)
    return prompt
end

-- Call Google Gemini API
function AIHelper:callGemini(prompt, config)
    logger.info("AIHelper: Calling Google Gemini API")
    
    local model = config.model or "gemini-2.5-flash"
    local endpoint = "https://generativelanguage.googleapis.com/v1beta/models/" .. model .. ":generateContent"
    
    logger.info("AIHelper: Using Gemini model:", model)
    
    local url = endpoint .. "?key=" .. config.api_key
    
    logger.info("AIHelper: Gemini URL (key hidden):", string.gsub(url, config.api_key, "***"))
    
    local request_body = json.encode({
        contents = {{
            parts = {{
                text = prompt
            }}
        }},
        generationConfig = {
            temperature = 0.7,
            topK = 40,
            topP = 0.95,
            maxOutputTokens = 8192,
        }
    })
    
    logger.info("AIHelper: Request body length:", #request_body)
    
    local response_body = {}
    
    local ssl = require("ssl")
    local params = {
        mode = "client",
        protocol = "any",
        verify = "none",
        options = {"all", "no_sslv2", "no_sslv3"},
    }
    
    local res, code, headers, status = https.request{
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#request_body),
        },
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body),
        verify = "none",
        protocol = "any",
    }
    
    logger.info("AIHelper: Response code:", tostring(code))
    logger.info("AIHelper: Response status:", tostring(status))
    
    local code_num = tonumber(code)
    if not code_num then
        logger.warn("AIHelper: Invalid response code:", code)
        logger.warn("AIHelper: This might be an SSL/TLS error")
        logger.warn("AIHelper: Response body:", table.concat(response_body))
        return nil
    end
    
    if code_num ~= 200 then
        logger.warn("AIHelper: Gemini API failed with code:", code_num)
        local response_text = table.concat(response_body)
        logger.warn("AIHelper: Response:", response_text)
        
        if code_num == 400 then
            logger.warn("AIHelper: API key might be invalid or improperly formatted")
            logger.warn("AIHelper: Key length:", #config.api_key)
            logger.warn("AIHelper: Key starts with:", string.sub(config.api_key, 1, 10))
        end
        
        return nil
    end
    
    local response_text = table.concat(response_body)
    logger.info("AIHelper: Gemini response received, length:", #response_text)
    
    local data = json.decode(response_text)
    
    if data and data.candidates and data.candidates[1] then
        local text = data.candidates[1].content.parts[1].text
        return self:parseAIResponse(text)
    end
    
    return nil
end

-- Call ChatGPT API
function AIHelper:callChatGPT(prompt, config)
    logger.info("AIHelper: Calling ChatGPT API")
    
    local lang = self.current_language or "tr"
    local system_instruction = self.prompts[lang].system_instruction
    
    local request_body = json.encode({
        model = config.model,
        messages = {
            {
                role = "system",
                content = system_instruction
            },
            {
                role = "user",
                content = prompt
            }
        },
        temperature = 0.7,
        max_tokens = 2048
    })
    
    local response_body = {}
    local res, code, headers = https.request{
        url = config.endpoint,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. config.api_key,
            ["Content-Length"] = tostring(#request_body)
        },
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body),
    }
    
    if code ~= 200 then
        logger.warn("AIHelper: ChatGPT API failed with code:", code)
        logger.warn("AIHelper: Response:", table.concat(response_body))
        return nil
    end
    
    local response_text = table.concat(response_body)
    logger.info("AIHelper: ChatGPT response received, length:", #response_text)
    
    local data = json.decode(response_text)
    
    if data and data.choices and data.choices[1] then
        local text = data.choices[1].message.content
        return self:parseAIResponse(text)
    end
    
    return nil
end

-- Parse AI response (extract JSON from markdown code blocks if needed)
function AIHelper:parseAIResponse(text)
    logger.info("AIHelper: Parsing AI response")
    
    logger.info("AIHelper: Response preview:", text:sub(1, 500))
    
    local json_text = text
    
    -- Remove ```json and ``` markers if present
    json_text = string.gsub(json_text, "```json\n", "")
    json_text = string.gsub(json_text, "```json", "")
    json_text = string.gsub(json_text, "\n```", "")
    json_text = string.gsub(json_text, "```", "")
    json_text = string.gsub(json_text, "^%s+", "")
    
    -- Find complete JSON object with bracket matching
    local json_start = string.find(json_text, "{")
    if not json_start then
        logger.warn("AIHelper: No opening { found")
        return nil
    end
    
    local bracket_count = 0
    local json_end = nil
    local in_string = false
    local escape_next = false
    
    for i = json_start, #json_text do
        local char = string.sub(json_text, i, i)
        
        if escape_next then
            escape_next = false
        elseif char == "\\" then
            escape_next = true
        elseif char == '"' then
            in_string = not in_string
        elseif not in_string then
            if char == "{" then
                bracket_count = bracket_count + 1
            elseif char == "}" then
                bracket_count = bracket_count - 1
                if bracket_count == 0 then
                    json_end = i
                    break
                end
            end
        end
    end
    
    if not json_end then
        logger.warn("AIHelper: No matching closing } found")
        logger.warn("AIHelper: Trying to find partial JSON...")
        
        local last_quote = string.find(json_text, '"[^"]*"[%s]*[,}]', json_start)
        if last_quote then
            json_end = last_quote + 1
            json_text = string.sub(json_text, json_start, json_end) .. "\n}"
            logger.info("AIHelper: Attempting partial JSON parse")
        else
            return nil
        end
    else
        json_text = string.sub(json_text, json_start, json_end)
    end
    
    logger.info("AIHelper: Extracted JSON length:", #json_text)
    
    local success, book_data = pcall(json.decode, json_text)
    
    if success and book_data then
        book_data = self:validateAndCleanData(book_data)
        logger.info("AIHelper: Successfully parsed book data")
        logger.info("AIHelper: Found", book_data.characters and #book_data.characters or 0, "characters")
        logger.info("AIHelper: Found", book_data.locations and #book_data.locations or 0, "locations")
        logger.info("AIHelper: Found", book_data.timeline and #book_data.timeline or 0, "timeline events")
        logger.info("AIHelper: Found", book_data.historical_figures and #book_data.historical_figures or 0, "historical figures")
        return book_data
    else
        logger.warn("AIHelper: Failed to parse JSON response")
        logger.warn("AIHelper: Parse error:", tostring(book_data))
        logger.warn("AIHelper: JSON text (first 500 chars):", json_text:sub(1, 500))
        
        logger.info("AIHelper: Attempting basic field extraction...")
        local basic_data = self:extractBasicFields(text)
        if basic_data then
            logger.info("AIHelper: Basic extraction successful")
            return basic_data
        end
        
        return nil
    end
end

function AIHelper:validateAndCleanData(data)
    if not data then return nil end
    
    local lang = self.current_language or "tr"
    local strings = self.prompts[lang].fallback_strings
    
    local function ensureString(value, default)
        if type(value) == "string" then
            return value
        elseif type(value) == "number" then
            return tostring(value)
        elseif value == nil then
            return default or ""
        else
            return default or ""
        end
    end
    
    -- Characters
    if data.characters and type(data.characters) == "table" then
        for i, char in ipairs(data.characters) do
            data.characters[i] = {
                name = ensureString(char.name, strings.unnamed_character),
                description = ensureString(char.description, strings.no_description),
                role = ensureString(char.role, strings.not_specified),
                gender = ensureString(char.gender, strings.not_specified),
                occupation = ensureString(char.occupation, strings.not_specified)
            }
        end
    else
        data.characters = {}
    end
    
    -- Locations
    if data.locations and type(data.locations) == "table" then
        for i, loc in ipairs(data.locations) do
            data.locations[i] = {
                name = ensureString(loc.name, strings.unnamed_location),
                description = ensureString(loc.description, strings.no_description),
                importance = ensureString(loc.importance, strings.not_specified)
            }
        end
    else
        data.locations = {}
    end
    
    -- Timeline
    if data.timeline and type(data.timeline) == "table" then
        for i, event in ipairs(data.timeline) do
            data.timeline[i] = {
                chapter = ensureString(event.chapter, strings.chapter),
                event = ensureString(event.event, strings.no_event_description),
                characters = event.characters or {},
                importance = ensureString(event.importance, strings.not_specified)
            }
        end
    else
        data.timeline = {}
    end
    
    -- Historical figures
    if data.historical_figures and type(data.historical_figures) == "table" then
        for i, fig in ipairs(data.historical_figures) do
            data.historical_figures[i] = {
                name = ensureString(fig.name, strings.unnamed_person),
                birth_year = ensureString(fig.birth_year, ""),
                death_year = ensureString(fig.death_year, ""),
                role = ensureString(fig.role, strings.not_specified),
                biography = ensureString(fig.biography, strings.no_biography),
                importance_in_book = ensureString(fig.importance_in_book, ""),
                context_in_book = ensureString(fig.context_in_book, "")
            }
        end
    else
        data.historical_figures = {}
    end
    
    -- Themes
    if not data.themes or type(data.themes) ~= "table" then
        data.themes = {}
    end
    
    -- Other fields
    data.book_title = ensureString(data.book_title, strings.unknown_book)
    data.author = ensureString(data.author, strings.unknown_author)
    data.author_bio = ensureString(data.author_bio, "")
    data.author_birth = ensureString(data.author_birth, "")
    data.author_death = ensureString(data.author_death, "")
    data.summary = ensureString(data.summary, "")
    
    return data
end

-- Fallback: Extract basic fields if JSON parsing fails
function AIHelper:extractBasicFields(text)
    local lang = self.current_language or "tr"
    local strings = self.prompts[lang].fallback_strings
    
    local data = {
        characters = {},
        locations = {},
        themes = {},
        timeline = {},
        historical_figures = {}
    }
    
    -- Try to extract book title
    local title_match = string.match(text, '"book_title"%s*:%s*"([^"]+)"')
    if title_match then
        data.book_title = title_match
    end
    
    -- Try to extract author
    local author_match = string.match(text, '"author"%s*:%s*"([^"]+)"')
    if author_match then
        data.author = author_match
    end
    
    -- Try to extract author bio
    local bio_match = string.match(text, '"author_bio"%s*:%s*"([^"]+)"')
    if bio_match then
        data.author_bio = bio_match
    end
    
    -- Basic character extraction (simplified)
    for name_match in string.gmatch(text, '"name"%s*:%s*"([^"]+)"') do
        table.insert(data.characters, {
            name = name_match,
            description = lang == "tr" and "Karakter bilgisi kısmi yüklendi" or "Character info partially loaded",
            role = strings.not_specified
        })
    end
    
    if #data.characters > 0 or data.book_title or data.author then
        logger.info("AIHelper: Extracted", #data.characters, "characters via fallback")
        return data
    end
    
    return nil
end

-- Test API key with a simple request
function AIHelper:testAPIKey(provider)
    logger.info("AIHelper: Testing API key for provider:", provider)
    
    local provider_config = self.providers[provider]
    if not provider_config or not provider_config.api_key then
        logger.warn("AIHelper: No API key set for provider:", provider)
        return false, "API key not set"
    end
    
    if provider == "gemini" then
        local model = provider_config.model or "gemini-2.5-flash"
        local url = "https://generativelanguage.googleapis.com/v1beta/models/" .. model .. ":generateContent?key=" .. provider_config.api_key
        
        logger.info("AIHelper: Testing with model:", model)
        
        local test_body = json.encode({
            contents = {{
                parts = {{
                    text = "Say hello"
                }}
            }}
        })
        
        local response_body = {}
        local res, code = https.request{
            url = url,
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json",
                ["Content-Length"] = tostring(#test_body),
            },
            source = ltn12.source.string(test_body),
            sink = ltn12.sink.table(response_body),
        }
        
        logger.info("AIHelper: Test response code:", code)
        
        if code == 200 then
            return true, "API key is valid!"
        elseif code == 400 then
            return false, "API key is invalid or malformed"
        else
            return false, "Test failed with code: " .. tostring(code)
        end
    end
    
    return false, "Provider test not implemented"
end

-- Set API key for a provider
function AIHelper:setAPIKey(provider, api_key)
    if self.providers[provider] then
        -- Trim whitespace and newlines
        api_key = string.gsub(api_key, "^%s*(.-)%s*$", "%1")
        api_key = string.gsub(api_key, "\n", "")
        api_key = string.gsub(api_key, "\r", "")
        
        self.providers[provider].api_key = api_key
        logger.info("AIHelper: API key set for provider:", provider)
        logger.info("AIHelper: Key length:", #api_key)
        logger.info("AIHelper: Key preview:", string.sub(api_key, 1, 10) .. "...")
        return true
    end
    return false
end

-- Get available providers
function AIHelper:getAvailableProviders()
    local available = {}
    for name, config in pairs(self.providers) do
        if config.enabled and config.api_key then
            table.insert(available, {
                name = name,
                display_name = config.name
            })
        end
    end
    return available
end

return AIHelper