-- AIHelper - Google Gemini & ChatGPT for X-Ray
local http = require("socket.http")
local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("json")
local logger = require("logger")

local AIHelper = {}

-- AI Provider settings (default values)
AIHelper.providers = {
    gemini = {
        name = "Google Gemini",
        enabled = true,
        api_key = nil,
        model = "gemini-2.5-flash", -- Default model
    },
    chatgpt = {
        name = "ChatGPT",
        enabled = true,
        api_key = nil,
        endpoint = "https://api.openai.com/v1/chat/completions",
        model = "gpt-4o-mini", -- Varsayılan model (uygun maliyet/performans)
    }
}

AIHelper.model_override = nil

-- Set Gemini model
function AIHelper:setGeminiModel(model_name)
    if not model_name or #model_name == 0 then return false end
    self.providers.gemini.model = model_name
    self:saveModelToConfig(model_name)
    return true
end

-- Set ChatGPT model
function AIHelper:setChatGPTModel(model_name)
    if not model_name or #model_name == 0 then return false end
    self.providers.chatgpt.model = model_name
    self:saveModelToConfig(model_name, "chatgpt")
    return true
end

-- Set default provider 
function AIHelper:setDefaultProvider(provider_name)
    if not provider_name or (provider_name ~= "gemini" and provider_name ~= "chatgpt") then 
        return false 
    end
    self.default_provider = provider_name
    self:saveProviderToConfig(provider_name)
    logger.info("AIHelper: Default provider changed to:", provider_name)
    return true
end

-- Save model preference to config file
function AIHelper:saveModelToConfig(model_name, provider)
    provider = provider or "gemini"
    local DataStorage = require("datastorage")
    local settings_dir = DataStorage:getSettingsDir()
    local xray_dir = settings_dir .. "/xray"
    local lfs = require("libs/libkoreader-lfs")
    lfs.mkdir(xray_dir)
    
    local model_file = xray_dir .. "/" .. provider .. "_model.txt"
    local file = io.open(model_file, "w")
    if file then
        file:write(model_name)
        file:close()
        return true
    end
    return false
end

-- Save provider preference to config file 
function AIHelper:saveProviderToConfig(provider_name)
    local DataStorage = require("datastorage")
    local settings_dir = DataStorage:getSettingsDir()
    local xray_dir = settings_dir .. "/xray"
    local lfs = require("libs/libkoreader-lfs")
    lfs.mkdir(xray_dir)
    
    local provider_file = xray_dir .. "/default_provider.txt"
    local file = io.open(provider_file, "w")
    if file then
        file:write(provider_name)
        file:close()
        logger.info("AIHelper: Saved default provider:", provider_name)
        return true
    end
    logger.warn("AIHelper: Failed to save provider preference")
    return false
end

-- Initialize AIHelper
function AIHelper:init()
    self:loadConfig()
    self:loadModelFromFile()
    self:loadLanguage()
    logger.info("AIHelper: Initialized with Gemini model:", self.providers.gemini.model)
    logger.info("AIHelper: ChatGPT model:", self.providers.chatgpt.model)
end

-- Load configuration
function AIHelper:loadConfig()
    local success, config = pcall(require, "config")
    if success and config then
        if config.gemini_api_key then self.providers.gemini.api_key = config.gemini_api_key end
        if config.gemini_model then self.providers.gemini.model = config.gemini_model end
        if config.chatgpt_api_key then self.providers.chatgpt.api_key = config.chatgpt_api_key end
        if config.chatgpt_model then self.providers.chatgpt.model = config.chatgpt_model end
        if config.default_provider then self.default_provider = config.default_provider end
        if config.settings then self.settings = config.settings end
    end
end

-- Load model preference
function AIHelper:loadModelFromFile()
    local DataStorage = require("datastorage")
    
    -- Gemini model
    local gemini_file = DataStorage:getSettingsDir() .. "/xray/gemini_model.txt"
    local file = io.open(gemini_file, "r")
    if file then
        local model = file:read("*a"):match("^%s*(.-)%s*$")
        file:close()
        if model and #model > 0 then
            self.providers.gemini.model = model
        end
    end
    
    -- ChatGPT model
    local chatgpt_file = DataStorage:getSettingsDir() .. "/xray/chatgpt_model.txt"
    file = io.open(chatgpt_file, "r")
    if file then
        local model = file:read("*a"):match("^%s*(.-)%s*$")
        file:close()
        if model and #model > 0 then
            self.providers.chatgpt.model = model
        end
    end
    
    -- Default provider (YENI)
    local provider_file = DataStorage:getSettingsDir() .. "/xray/default_provider.txt"
    file = io.open(provider_file, "r")
    if file then
        local provider = file:read("*a"):match("^%s*(.-)%s*$")
        file:close()
        if provider and (provider == "gemini" or provider == "chatgpt") then
            self.default_provider = provider
            logger.info("AIHelper: Loaded default provider from file:", provider)
        end
    end
end

-- Get book data from AI
function AIHelper:getBookData(title, author, provider_name, context)
    self:loadModelFromFile() -- Refresh model
    local provider = provider_name or "gemini"
    local provider_config = self.providers[provider]
    
    if not provider_config or not provider_config.api_key then
        return nil, "error_no_api_key"
    end
    
    -- Context ile prompt oluştur
    local prompt = self:createPrompt(title, author, context)
    
    logger.info("AIHelper: Using provider:", provider, "Model:", provider_config.model)
    if context and context.spoiler_free then
        logger.info("AIHelper: Spoiler-free mode active, reading:", context.reading_percent, "%")
    end
    
    if provider == "gemini" then
        return self:callGemini(prompt, provider_config)
    elseif provider == "chatgpt" then
        return self:callChatGPT(prompt, provider_config)
    end
    return nil, "error_unknown_provider"
end

-- Check network
function AIHelper:checkNetworkConnectivity()
    local socket = require("socket")
    local success, err = pcall(function()
        local tcp = socket.tcp()
        tcp:settimeout(3)
        local result = tcp:connect("8.8.8.8", 53)
        tcp:close()
        return result
    end)
    return success
end

-- Load language
function AIHelper:loadLanguage()
    local DataStorage = require("datastorage")
    local f = io.open(DataStorage:getSettingsDir() .. "/xray/language.txt", "r")
    self.current_language = f and f:read("*a"):match("^%s*(.-)%s*$") or "tr"
    if f then f:close() end
    self:loadPrompts()
end

-- Load prompts
function AIHelper:loadPrompts()
    local success, prompts = pcall(require, "prompts/" .. self.current_language)
    if not success then 
        success, prompts = pcall(require, "prompts/tr") 
    end
    self.prompts = prompts or {}
end

-- Create prompt
function AIHelper:createPrompt(title, author, context)
    if not self.prompts then self:loadLanguage() end
    
    -- Context varsa ve spoiler_free modundaysa özel prompt kullan
    if context and context.spoiler_free then
        local template = self.prompts.spoiler_free or self.prompts.main
        -- Artık sadece 3 parametre: title, author, percent
        return string.format(template, title, author or "Bilinmiyor", context.reading_percent)
    else
        -- Tam kitap için normal prompt
        local template = self.prompts.main
        return string.format(template, title, author or "Bilinmiyor")
    end
end

function AIHelper:getFallbackStrings()
    if not self.prompts then self:loadPrompts() end
    return self.prompts.fallback or {}
end

-- Call Google Gemini API (FIXED VERSION)
function AIHelper:callGemini(prompt, config)
    logger.info("AIHelper: Calling Google Gemini API")
    
    if not self:checkNetworkConnectivity() then
        return nil, "error_no_network", "İnternet bağlantısı yok"
    end
    
    local model = config.model or "gemini-2.5-flash"
    local url = "https://generativelanguage.googleapis.com/v1beta/models/" .. model .. ":generateContent?key=" .. config.api_key
    
    -- GÜVENLİK FİLTRELERİNİ KAPAT (Dostoyevski vb. için şart)
    local safety_settings = {
        { category = "HARM_CATEGORY_HARASSMENT", threshold = "BLOCK_NONE" },
        { category = "HARM_CATEGORY_HATE_SPEECH", threshold = "BLOCK_NONE" },
        { category = "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold = "BLOCK_NONE" },
        { category = "HARM_CATEGORY_DANGEROUS_CONTENT", threshold = "BLOCK_NONE" }
    }

    local request_body = json.encode({
        contents = {{ parts = {{ text = prompt }} }},
        safetySettings = safety_settings,
        generationConfig = {
            temperature = 0.4,
            topK = 40,
            topP = 0.95,
            maxOutputTokens = 8192,
            responseMimeType = "application/json" -- JSON Modu
        }
    })
    
    -- RETRY LOGIC
    local max_retries = 1
    for attempt = 1, max_retries + 1 do
        if attempt > 1 then
             local socket = require("socket")
             socket.sleep(3) 
        end

        local response_body = {}
        local res, code, headers, status = https.request{
            url = url,
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json",
                ["Content-Length"] = tostring(#request_body),
            },
            source = ltn12.source.string(request_body),
            sink = ltn12.sink.table(response_body),
            timeout = 120
        }
        
        local response_text = table.concat(response_body)
        local code_num = tonumber(code)
        
        logger.info("AIHelper: API Code:", code_num, "Length:", #response_text)

        if code_num == 200 then
            local success, data = pcall(json.decode, response_text)
            if not success then return nil, "error_json_parse" end
            
            -- CRASH PROTECTION: Null check yapısı
            if data and data.candidates and data.candidates[1] then
                local candidate = data.candidates[1]
                
                -- Güvenlik sebebiyle engellendi mi?
                if candidate.finishReason == "SAFETY" then
                     logger.warn("AIHelper: BLOCKED BY SAFETY FILTER")
                     return nil, "error_safety", "Google Güvenlik Filtresi engelledi."
                end

                if candidate.content and candidate.content.parts and candidate.content.parts[1] then
                    return self:parseAIResponse(candidate.content.parts[1].text)
                else
                    logger.warn("AIHelper: No text in response")
                    return nil, "error_api", "API boş yanıt döndürdü."
                end
            else
                return nil, "error_api", "Geçersiz yanıt formatı"
            end
        elseif code_num == 503 then
             logger.warn("AIHelper: 503 Service Unavailable (Retrying...)")
        else
             return nil, "error_" .. tostring(code_num), "Hata Kodu: " .. tostring(code_num)
        end
    end
    
    return nil, "error_timeout", "Zaman aşımı"
end

-- Call ChatGPT API (COMPLETE IMPLEMENTATION)
function AIHelper:callChatGPT(prompt, config)
    logger.info("AIHelper: Calling ChatGPT API")
    
    if not self:checkNetworkConnectivity() then
        return nil, "error_no_network", "İnternet bağlantısı yok"
    end
    
    local model = config.model or "gpt-4o-mini"
    local url = config.endpoint or "https://api.openai.com/v1/chat/completions"
    
    -- System instruction ekle (eğer prompts'ta varsa)
    local system_instruction = self.prompts and self.prompts.system_instruction or 
        "You are an expert literary critic. Respond ONLY with valid JSON format."
    
    local request_body = json.encode({
        model = model,
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
        temperature = 0.4,
        max_tokens = 8192,
        top_p = 0.95,
        response_format = { type = "json_object" } -- JSON mode zorla
    })
    
    logger.info("AIHelper: ChatGPT request size:", #request_body)
    
    -- RETRY LOGIC
    local max_retries = 1
    for attempt = 1, max_retries + 1 do
        if attempt > 1 then
             local socket = require("socket")
             socket.sleep(3) 
             logger.info("AIHelper: Retrying ChatGPT request (attempt " .. attempt .. ")")
        end

        local response_body = {}
        local res, code, headers, status = https.request{
            url = url,
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. config.api_key,
                ["Content-Length"] = tostring(#request_body),
            },
            source = ltn12.source.string(request_body),
            sink = ltn12.sink.table(response_body),
            timeout = 120
        }
        
        local response_text = table.concat(response_body)
        local code_num = tonumber(code)
        
        logger.info("AIHelper: ChatGPT API Code:", code_num, "Length:", #response_text)

        if code_num == 200 then
            local success, data = pcall(json.decode, response_text)
            if not success then 
                logger.warn("AIHelper: JSON parse error")
                return nil, "error_json_parse" 
            end
            
            -- CRASH PROTECTION: OpenAI response structure
            if data and data.choices and data.choices[1] then
                local choice = data.choices[1]
                
                -- Finish reason kontrolü
                if choice.finish_reason == "content_filter" then
                    logger.warn("AIHelper: BLOCKED BY CONTENT FILTER")
                    return nil, "error_safety", "OpenAI içerik filtresi engelledi."
                end
                
                if choice.message and choice.message.content then
                    local content = choice.message.content
                    logger.info("AIHelper: ChatGPT response received, parsing...")
                    return self:parseAIResponse(content)
                else
                    logger.warn("AIHelper: No content in ChatGPT response")
                    return nil, "error_api", "API boş yanıt döndürdü."
                end
            else
                -- Hata mesajı varsa logla
                if data and data.error then
                    logger.warn("AIHelper: ChatGPT API Error:", data.error.message or "Unknown")
                    return nil, "error_api", data.error.message or "API Hatası"
                end
                return nil, "error_api", "Geçersiz yanıt formatı"
            end
        elseif code_num == 429 then
            logger.warn("AIHelper: 429 Rate Limit (Retrying...)")
            -- Rate limit için daha uzun bekle
            if attempt <= max_retries then
                local socket = require("socket")
                socket.sleep(5)
            end
        elseif code_num == 503 or code_num == 502 then
            logger.warn("AIHelper: " .. code_num .. " Service Error (Retrying...)")
        elseif code_num == 401 then
            return nil, "error_401", "API anahtarı geçersiz"
        else
            logger.warn("AIHelper: Unexpected error code:", code_num)
            return nil, "error_" .. tostring(code_num), "Hata Kodu: " .. tostring(code_num)
        end
    end
    
    return nil, "error_timeout", "Zaman aşımı"
end

function AIHelper:parseAIResponse(text)
    -- Temizlik
    local json_text = text:gsub("```json", ""):gsub("```", ""):gsub("^%s+", ""):gsub("%s+$", "")
    
    -- Parse
    local success, data = pcall(json.decode, json_text)
    
    -- Eğer başarısızsa, {} arasını bulmaya çalış
    if not success then
        local first = json_text:find("{")
        local last_brace = nil
        for i = #json_text, 1, -1 do
            if json_text:sub(i,i) == "}" then last_brace = i; break end
        end
        if first and last_brace then
             json_text = json_text:sub(first, last_brace)
             success, data = pcall(json.decode, json_text)
        end
    end

    if success and data then
        return self:validateAndCleanData(data)
    end
    return nil
end

function AIHelper:validateAndCleanData(data)
    if not data then return nil end
    local strings = self:getFallbackStrings()
    
    local function ensureString(v, d)
        return (type(v) == "string" and #v > 0) and v or d or ""
    end

    -- 1. YAZAR & KİTAP (Akıllı Eşleşme)
    data.book_title = data.book_title or data.title or strings.unknown_book
    data.author = data.author or data.book_author or strings.unknown_author
    data.author_bio = data.author_bio or data.AuthorBio or data.bio or ""
    data.summary = data.summary or data.book_summary or ""

    -- 2. KARAKTERLER
    local chars = data.characters or data.Characters or {}
    local valid_chars = {}
    for _, c in ipairs(chars) do
        if type(c) == "table" then
            table.insert(valid_chars, {
                name = ensureString(c.name or c.Name, strings.unnamed_character),
                role = ensureString(c.role or c.Role, strings.not_specified),
                description = ensureString(c.description or c.desc, strings.no_description),
                gender = ensureString(c.gender, ""),
                occupation = ensureString(c.occupation, "")
            })
        end
    end
    data.characters = valid_chars

    -- 3. TARİHİ KİŞİLİKLER
    local hists = data.historical_figures or data.historicalFigures or {}
    local valid_hists = {}
    for _, h in ipairs(hists) do
        if type(h) == "table" then
            table.insert(valid_hists, {
                name = ensureString(h.name or h.Name, strings.unnamed_person),
                biography = ensureString(h.biography or h.bio, strings.no_biography),
                role = ensureString(h.role, ""),
                importance_in_book = ensureString(h.importance_in_book or h.importance, "Kitapta geçiyor"),
                context_in_book = ensureString(h.context_in_book or h.context, "Dönemsel referans")
            })
        end
    end
    data.historical_figures = valid_hists

    -- 4. DİĞERLERİ
    data.locations = data.locations or {}
    data.themes = data.themes or {}
    data.timeline = data.timeline or {}
    
    return data
end

function AIHelper:setAPIKey(provider, api_key)
    if self.providers[provider] then
        self.providers[provider].api_key = api_key:gsub("%s+", "")
        return true
    end
    return false
end

return AIHelper