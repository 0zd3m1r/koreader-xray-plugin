-- Localization Manager for X-Ray Plugin (with .po support)

local logger = require("logger")
local lfs = require("libs/libkoreader-lfs")

local Localization = {
    current_language = "tr",
    translations = {},
    available_languages = {},
}

-- Simple .po file parser
function Localization:parsePO(filepath)
    local translations = {}
    local file = io.open(filepath, "r")
    
    if not file then
        logger.warn("Localization: Cannot open .po file:", filepath)
        return nil
    end
    
    local msgid = nil
    local msgstr = nil
    local in_msgid = false
    local in_msgstr = false
    
    for line in file:lines() do
        -- Skip comments and empty lines
        if line:match("^#") or line:match("^%s*$") then
            goto continue
        end
        
        -- Start of msgid
        if line:match('^msgid%s+"') then
            -- Save previous translation
            if msgid and msgstr then
                translations[msgid] = msgstr
            end
            
            msgid = line:match('^msgid%s+"(.-)"')
            msgstr = nil
            in_msgid = true
            in_msgstr = false
        
        -- Start of msgstr
        elseif line:match('^msgstr%s+"') then
            msgstr = line:match('^msgstr%s+"(.-)"')
            in_msgid = false
            in_msgstr = true
        
        -- Continuation line
        elseif line:match('^"') then
            local continuation = line:match('^"(.-)"')
            if in_msgid and msgid then
                msgid = msgid .. continuation
            elseif in_msgstr and msgstr then
                msgstr = msgstr .. continuation
            end
        end
        
        ::continue::
    end
    
    -- Save last translation
    if msgid and msgstr then
        translations[msgid] = msgstr
    end
    
    file:close()
    
    -- Process escape sequences
    for key, value in pairs(translations) do
        value = value:gsub("\\n", "\n")
        value = value:gsub("\\t", "\t")
        value = value:gsub('\\"', '"')
        value = value:gsub("\\\\", "\\")
        translations[key] = value
    end
    
    return translations
end

-- Initialize localization system
function Localization:init()
    logger.info("Localization: Initializing...")
    
    -- Discover available language files
    self:discoverLanguages()
    
    -- Load saved language preference
    self:loadLanguage()
    
    -- Load translation file
    self:loadTranslations()
    
    logger.info("Localization: Initialized with language:", self.current_language)
end

-- Discover available .po files
function Localization:discoverLanguages()
    local plugin_dir = "plugins/xray.koplugin"
    local lang_dir = plugin_dir .. "/languages"
    
    self.available_languages = {}
    
    local attr = lfs.attributes(lang_dir)
    if not attr or attr.mode ~= "directory" then
        logger.warn("Localization: Languages directory not found:", lang_dir)
        return
    end
    
    for file in lfs.dir(lang_dir) do
        if file:match("%.po$") then
            local lang_code = file:match("^(.+)%.po$")
            if lang_code then
                table.insert(self.available_languages, lang_code)
                logger.info("Localization: Found language:", lang_code)
            end
        end
    end
    
    table.sort(self.available_languages)
    logger.info("Localization: Discovered", #self.available_languages, "languages")
end

-- Load translations from .po file
function Localization:loadTranslations()
    local plugin_dir = "plugins/xray.koplugin"
    local po_file = plugin_dir .. "/languages/" .. self.current_language .. ".po"
    
    logger.info("Localization: Loading translations from:", po_file)
    
    local translations = self:parsePO(po_file)
    
    if translations then
        self.translations = translations
        logger.info("Localization: Loaded", self:tableSize(translations), "translations")
    else
        logger.warn("Localization: Failed to load .po file")
        
        -- Fallback to Turkish
        if self.current_language ~= "tr" then
            logger.info("Localization: Falling back to Turkish")
            self.current_language = "tr"
            po_file = plugin_dir .. "/languages/tr.po"
            translations = self:parsePO(po_file)
            if translations then
                self.translations = translations
            else
                self.translations = {}
                logger.error("Localization: Failed to load fallback!")
            end
        end
    end
end

-- Helper: count table size
function Localization:tableSize(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Get translated string with better error handling
function Localization:t(key, ...)
    local translation = self.translations[key]
    
    if not translation or translation == "" then
        logger.warn("Localization: Missing translation key:", key)
        -- Return a user-friendly fallback instead of the key
        local fallbacks = {
            cache_saved = "💾 Saved!",
            cache_save_failed = "❌ Save failed",
            ai_fetch_complete = "✅ Fetched from %s\n\n📖 %s\n👤 %s\n\n👥 %d | 📍 %d | 🎨 %d | 📅 %d | 📜 %d\n\n%s",
            fetching_ai = "🤖 Fetching from %s...",
            no_api_key = "⚠️ No API key set!",
        }
        translation = fallbacks[key] or key
    end
    
    -- Format with arguments
    if select('#', ...) > 0 then
        local success, result = pcall(string.format, translation, ...)
        if success then
            return result
        else
            logger.warn("Localization: Format error for key:", key)
            logger.warn("Localization: Error:", result)
            logger.warn("Localization: Args count:", select('#', ...))
            -- Print arguments for debugging
            for i = 1, select('#', ...) do
                local arg = select(i, ...)
                logger.warn("Localization: Arg", i, "type:", type(arg), "value:", tostring(arg))
            end
            return translation
        end
    end
    
    return translation
end

-- Load/save language preference (same as before)
function Localization:loadLanguage()
    local DataStorage = require("datastorage")
    local settings_dir = DataStorage:getSettingsDir()
    local language_file = settings_dir .. "/xray/language.txt"
    
    local file = io.open(language_file, "r")
    if file then
        local lang = file:read("*a")
        file:close()
        lang = lang:match("^%s*(.-)%s*$")
        
        if self:languageExists(lang) then
            self.current_language = lang
            logger.info("Localization: Loaded language from file:", lang)
        else
            logger.warn("Localization: Language not found:", lang)
            self.current_language = "tr"
        end
    else
        self.current_language = "tr"
        logger.info("Localization: No saved language, using default: tr")
    end
end

function Localization:languageExists(lang_code)
    for _, code in ipairs(self.available_languages) do
        if code == lang_code then return true end
    end
    return false
end

function Localization:getLanguage()
    return self.current_language
end

function Localization:getLanguageName()
    return self.translations["language_name"] or self.current_language
end

function Localization:setLanguage(lang_code)
    if not self:languageExists(lang_code) then
        logger.warn("Localization: Cannot set non-existent language:", lang_code)
        return false
    end
    
    self.current_language = lang_code
    
    local DataStorage = require("datastorage")
    local settings_dir = DataStorage:getSettingsDir()
    local xray_dir = settings_dir .. "/xray"
    lfs.mkdir(xray_dir)
    
    local language_file = xray_dir .. "/language.txt"
    local file = io.open(language_file, "w")
    if file then
        file:write(lang_code)
        file:close()
        logger.info("Localization: Language saved:", lang_code)
    end
    
    self:loadTranslations()
    
    local AIHelper = require("aihelper")
    if AIHelper then
        AIHelper:loadLanguage()
    end
    
    return true
end

-- Reload translations (call this after editing .po files)
function Localization:reload()
    logger.info("Localization: Reloading translations...")
    self:loadTranslations()
    
    -- Clear cached translations in AIHelper if it exists
    local AIHelper = require("aihelper")
    if AIHelper and AIHelper.localization then
        AIHelper.localization = nil
    end
    
    logger.info("Localization: Reload complete")
end

return Localization