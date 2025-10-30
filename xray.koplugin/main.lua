-- X-Ray Plugin for KOReader v1.0.0

local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local Menu = require("ui/widget/menu")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local logger = require("logger")
local _ = require("gettext")
local Screen = require("device").screen

local XRayPlugin = WidgetContainer:new{
    name = "xray",
    is_doc_only = true,
}

function XRayPlugin:init()
    self.ui.menu:registerToMainMenu(self)
    
    -- Load localization module
    local Localization = require("localization")
    self.loc = Localization
    self.loc:init() -- Load saved language preference
    
    logger.info("XRayPlugin v1.0.0: Initialized with language:", self.loc:getLanguage())
end

function XRayPlugin:onReaderReady()
    -- Auto-load cache when book is opened
    self:autoLoadCache()
end

function XRayPlugin:autoLoadCache()
    if not self.cache_manager then
        local CacheManager = require("cachemanager")
        self.cache_manager = CacheManager:new()
    end
    
    local book_path = self.ui.document.file
    logger.info("XRayPlugin: Auto-loading cache for:", book_path)
    local cached_data = self.cache_manager:loadCache(book_path)
    
    if cached_data then
        self.book_data = cached_data
        self.characters = cached_data.characters or {}
        self.locations = cached_data.locations or {}
        self.themes = cached_data.themes or {}
        self.summary = cached_data.summary
        self.author_info = cached_data.author_info
        self.timeline = cached_data.timeline or {}
        self.historical_figures = cached_data.historical_figures or {}
        
        local cache_age = math.floor((os.time() - cached_data.cached_at) / 86400)
        
        logger.info("XRayPlugin: Auto-loaded from cache -", #self.characters, "characters,", 
                    cache_age, "days old")
        
        if #self.characters > 0 then
            self.xray_mode_enabled = true
            logger.info("XRayPlugin: X-Ray mode auto-enabled")
        end
        
        UIManager:show(InfoMessage:new{
            text = self.loc:t("xray_ready") .. "\n\n" ..
                   "👥 " .. #self.characters .. " " .. self.loc:t("characters_loaded") .. "\n" ..
                   "📍 " .. #self.locations .. " " .. self.loc:t("locations_loaded") .. "\n" ..
                   "🎨 " .. #self.themes .. " " .. self.loc:t("themes_loaded"),
            timeout = 3,
        })
    else
        logger.info("XRayPlugin: No cache found for auto-load")
    end
end

function XRayPlugin:getMenuCounts()
    return {
        characters = self.characters and #self.characters or 0,
        locations = self.locations and #self.locations or 0,
        themes = self.themes and #self.themes or 0,
        timeline = self.timeline and #self.timeline or 0,
        historical_figures = self.historical_figures and #self.historical_figures or 0,
    }
end

function XRayPlugin:addToMainMenu(menu_items)
    logger.info("XRayPlugin: addToMainMenu called")
    
    self.ui:registerKeyEvents({
        ShowXRayMenu = {
            { "Alt", "X" },
            event = "ShowXRayMenu",
        },
    })
    
    local counts = self:getMenuCounts()
    
    menu_items.xray = {
        text = self.loc:t("menu_xray"),
        sorting_hint = "tools",
        callback = function()
            self:showQuickXRayMenu()
        end,
        hold_callback = function()
            self:showFullXRayMenu()
        end,
        sub_item_table = {
            {
                text = self.loc:t("menu_characters") .. (counts.characters > 0 and " (" .. counts.characters .. ")" or ""),
                keep_menu_open = true,
                callback = function()
                    self:showCharacters()
                end,
            },
            {
                text = self.loc:t("menu_chapter_characters"),
                keep_menu_open = true,
                callback = function()
                    self:showChapterCharacters()
                end,
            },
            {
                text = self.loc:t("menu_character_notes"),
                keep_menu_open = true,
                callback = function()
                    self:showCharacterNotes()
                end,
            },
            {
                text = self.loc:t("menu_timeline") .. (counts.timeline > 0 and " (" .. counts.timeline .. " " .. self.loc:t("events") .. ")" or ""),
                keep_menu_open = true,
                callback = function()
                    self:showTimeline()
                end,
            },
            {
                separator = true,
            },
            {
                text = self.loc:t("menu_historical_figures") .. (counts.historical_figures > 0 and " (" .. counts.historical_figures .. ")" or ""),
                keep_menu_open = true,
                callback = function()
                    self:showHistoricalFigures()
                end,
            },
            {
                text = self.loc:t("menu_locations") .. (counts.locations > 0 and " (" .. counts.locations .. ")" or ""),
                keep_menu_open = true,
                callback = function()
                    self:showLocations()
                end,
            },
            {
                text = self.loc:t("menu_author_info"),
                keep_menu_open = true,
                callback = function()
                    self:showAuthorInfo()
                end,
            },
            {
                text = self.loc:t("menu_summary"),
                keep_menu_open = true,
                callback = function()
                    self:showSummary()
                end,
            },
            {
                text = self.loc:t("menu_themes") .. (counts.themes > 0 and " (" .. counts.themes .. ")" or ""),
                keep_menu_open = true,
                callback = function()
                    self:showThemes()
                end,
            },
            {
                separator = true,
            },
            {
                text = self.loc:t("menu_fetch_ai"),
                keep_menu_open = true,
                callback = function()
                    self:fetchFromAI()
                end,
            },
            {
                separator = true,
            },
            {
                text = self.loc:t("menu_ai_settings"),
                keep_menu_open = true,
                sub_item_table = {
                    {
                        text = "Google Gemini API Key",
                        keep_menu_open = true,
                        callback = function()
                            self:setGeminiAPIKey()
                        end,
                    },
                    {
                        text = "ChatGPT API Key",
                        keep_menu_open = true,
                        callback = function()
                            self:setChatGPTAPIKey()
                        end,
                    },
                    {
                        text = "AI " .. (self.loc:getLanguage() == "tr" and "Sağlayıcı Seç" or "Provider"),
                        keep_menu_open = true,
                        callback = function()
                            self:selectAIProvider()
                        end,
                    },
                }
            },
            {
                text = self.loc:t("menu_clear_cache"),
                keep_menu_open = true,
                callback = function()
                    self:clearCache()
                end,
            },
            {
                text = self.loc:t("menu_xray_mode") .. " " .. (self.xray_mode_enabled and self.loc:t("xray_mode_active") or self.loc:t("xray_mode_inactive")),
                keep_menu_open = true,
                callback = function()
                    self:toggleXRayMode()
                end,
            },
            {
                text = self.loc:t("menu_language"),
                keep_menu_open = true,
                callback = function()
                    self:showLanguageSelection()
                end,
            },
            {
                separator = true,
            },
            {
                text = self.loc:t("menu_about"),
                keep_menu_open = true,
                callback = function()
                    self:showAbout()
                end,
            },
        }
    }
    
    logger.info("XRayPlugin: Menu item 'xray' added successfully")
end

function XRayPlugin:showLanguageSelection()
    local ButtonDialog = require("ui/widget/buttondialog")
    
    local current_lang = self.loc:getLanguage()
    
    local buttons = {
        {
            {
                text = self.loc:t("language_turkish") .. (current_lang == "tr" and " ✓" or ""),
                callback = function()
                    self.loc:setLanguage("tr")
                    UIManager:close(self.language_dialog)
                    
                    -- Show success message
                    UIManager:show(InfoMessage:new{
                        text = "✅ Dil değiştirildi: Türkçe\n\nDil değişikliği hemen uygulandı.\nMenüyü yeniden açtığınızda\nyeni dili göreceksiniz.",
                        timeout = 5,
                    })
                    
                    logger.info("XRayPlugin: Language changed to Turkish")
                end,
            },
        },
        {
            {
                text = self.loc:t("language_english") .. (current_lang == "en" and " ✓" or ""),
                callback = function()
                    self.loc:setLanguage("en")
                    UIManager:close(self.language_dialog)
                    
                    -- Show success message
                    UIManager:show(InfoMessage:new{
                        text = "✅ Language changed: English\n\nLanguage change applied immediately.\nYou will see the new language\nwhen you reopen the menu.",
                        timeout = 5,
                    })
                    
                    logger.info("XRayPlugin: Language changed to English")
                end,
            },
        },
    }
    
    self.language_dialog = ButtonDialog:new{
        title = self.loc:t("language_title"),
        buttons = buttons,
    }
    
    UIManager:show(self.language_dialog)
end

function XRayPlugin:refreshMenu()
    -- Menu will refresh automatically on next open
    -- No need to force close, just let the language change take effect
    logger.info("XRayPlugin: Language changed, menu will refresh on next open")
end

function XRayPlugin:showCharacters()
    if not self.characters or #self.characters == 0 then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("no_character_data"),
            timeout = 3,
        })
        return
    end
    
    local items = {}
    
    table.insert(items, {
        text = self.loc:t("search_character"),
        callback = function()
            self:showCharacterSearch()
        end
    })
    
    table.insert(items, {
        text = "────────────────",
        separator = true,
    })
    
    for i, char in ipairs(self.characters) do
        local name = char.name or self.loc:t("unknown_character")
        local text = "│ " .. name
        
        if char.description then
            text = text .. "\n  " .. char.description
        elseif char.gender or char.occupation then
            local details = {}
            if char.gender then table.insert(details, char.gender) end
            if char.occupation then table.insert(details, char.occupation) end
            text = text .. "\n  " .. table.concat(details, ", ")
        end
        
        table.insert(items, {
            text = text,
            callback = function()
                self:showCharacterDetails(char)
            end
        })
    end
    
    local character_menu = Menu:new{
        title = self.loc:t("menu_characters") .. " (" .. #self.characters .. ")",
        item_table = items,
        is_borderless = true,
        is_popout = false,
        title_bar_fm_style = true,
        width = Screen:getWidth(),
        height = Screen:getHeight(),
    }
    
    UIManager:show(character_menu)
end

function XRayPlugin:showCharacterDetails(character)
    if not character then
        return
    end
    
    local function safeString(value, default)
        if value == nil then
            return default or self.loc:t("not_specified")
        elseif type(value) == "string" then
            return value
        elseif type(value) == "number" then
            return tostring(value)
        elseif type(value) == "table" then
            return json.encode(value)
        elseif type(value) == "function" then
            return self.loc:t("not_specified")
        else
            return tostring(value)
        end
    end
    
    local name = safeString(character.name, self.loc:t("unnamed_character"))
    local description = safeString(character.description, self.loc:t("no_description"))
    local role = safeString(character.role, self.loc:t("not_specified"))
    local gender = safeString(character.gender, self.loc:t("not_specified"))
    local occupation = safeString(character.occupation, self.loc:t("not_specified"))
    
    local text = string.format([[
%s %s

%s
%s

%s %s
%s %s
%s %s
]], self.loc:t("character_name"), name, 
    self.loc:t("description"), description,
    self.loc:t("role"), role,
    self.loc:t("gender"), gender,
    self.loc:t("occupation"), occupation)
    
    UIManager:show(InfoMessage:new{
        text = text,
        width = Screen:getWidth() * 0.9,
    })
end

function XRayPlugin:fetchFromAI()
    if not self.ai_helper then
        local AIHelper = require("aihelper")
        self.ai_helper = AIHelper
        self.ai_helper:init()
    end
    
    if not self.cache_manager then
        local CacheManager = require("cachemanager")
        self.cache_manager = CacheManager:new()
    end
    
    local book_path = self.ui.document.file
    
    logger.info("XRayPlugin: Checking cache for:", book_path)
    local cached_data = self.cache_manager:loadCache(book_path)
    
    if cached_data then
        self.book_data = cached_data
        self.characters = cached_data.characters or {}
        self.locations = cached_data.locations or {}
        self.themes = cached_data.themes or {}
        self.summary = cached_data.summary
        self.author_info = cached_data.author_info
        self.timeline = cached_data.timeline or {}
        self.historical_figures = cached_data.historical_figures or {}
        
        local cache_age = math.floor((os.time() - cached_data.cached_at) / 86400)
        
        UIManager:show(InfoMessage:new{
            text = self.loc:t("checking_cache") .. "\n\n" ..
                   self.loc:t("book_title") .. " " .. (cached_data.book_title or "Unknown") .. "\n\n" ..
                   self.loc:t("characters_count") .. " " .. #self.characters .. "\n" ..
                   self.loc:t("locations_count") .. " " .. #self.locations .. "\n" ..
                   self.loc:t("themes_count") .. " " .. #self.themes .. "\n" ..
                   self.loc:t("events_count") .. " " .. #self.timeline .. "\n" ..
                   self.loc:t("historical_count") .. " " .. #self.historical_figures .. "\n\n" ..
                   self.loc:t("cache_age") .. " " .. cache_age .. " " .. self.loc:t("days_old") .. "\n" ..
                   self.loc:t("unlimited_valid") .. "\n\n" ..
                   self.loc:t("fetch_new_data"),
            timeout = 7,
        })
        
        logger.info("XRayPlugin: Loaded from cache -", #self.characters, "characters")
        return
    end
    
    logger.info("XRayPlugin: No cache found, fetching from AI")
    
    local provider = self.ai_provider or "gemini"
    
    local has_key = self.ai_helper.providers[provider] and 
                    self.ai_helper.providers[provider].api_key
    
    if not has_key then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("no_api_key") .. "\n\n" ..
                   "Google Gemini (Free):\n" ..
                   "https://makersuite.google.com/app/apikey\n\n" ..
                   "ChatGPT:\n" ..
                   "https://platform.openai.com/api-keys",
            timeout = 10,
        })
        return
    end
    
    UIManager:show(InfoMessage:new{
        text = string.format(self.loc:t("fetching_ai"), self.ai_helper.providers[provider].name),
        timeout = 2,
    })
    
    local title = self.ui.document:getProps().title or "Unknown"
    local author = self.ui.document:getProps().authors or nil
    
    logger.info("XRayPlugin: Fetching AI data for:", title, "by", author)
    
    local book_data = self.ai_helper:getBookData(title, author, provider)
    
    if not book_data then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("ai_fetch_failed"),
            timeout = 7,
        })
        return
    end
    
    self.book_data = book_data
    self.characters = book_data.characters or {}
    self.locations = book_data.locations or {}
    self.themes = book_data.themes or {}
    self.summary = book_data.summary
    self.timeline = book_data.timeline or {}
    self.historical_figures = book_data.historical_figures or {}
    
    if book_data.author then
        self.author_info = {
            name = book_data.author,
            description = book_data.author_bio,
            birthDate = book_data.author_birth,
            deathDate = book_data.author_death,
        }
        book_data.author_info = self.author_info
    end
    
    logger.info("XRayPlugin: Saving to cache")
    local cache_saved = self.cache_manager:saveCache(book_path, book_data)
    
    local message = string.format(
        self.loc:t("ai_fetch_complete"),
        self.ai_helper.providers[provider].name,
        book_data.book_title or title,
        #self.characters,
        book_data.author or "Unknown",
        #self.locations,
        #self.themes,
        #self.timeline,
        #self.historical_figures,
        cache_saved and self.loc:t("cache_saved") or self.loc:t("cache_save_failed")
    )
    
    UIManager:show(InfoMessage:new{
        text = message,
        timeout = 7,
    })
    
    logger.info("XRayPlugin: AI data fetch complete")
end

function XRayPlugin:showLocations()
    if not self.locations or #self.locations == 0 then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("no_location_data"),
            timeout = 3,
        })
        return
    end
    
    local items = {}
    for i, loc in ipairs(self.locations) do
        local text = loc.name or "Unknown Location"
        
        if loc.description then
            text = text .. "\n   " .. loc.description
        end
        if loc.importance then
            text = text .. "\n   🎯 " .. loc.importance
        end
        
        table.insert(items, {
            text = text,
            callback = function()
                local detail_text = "📍 " .. (loc.name or "Unknown") .. "\n\n"
                if loc.description then
                    detail_text = detail_text .. loc.description .. "\n\n"
                end
                if loc.importance then
                    detail_text = detail_text .. "🎯 " .. self.loc:t("importance") .. "\n" .. loc.importance
                end
                UIManager:show(InfoMessage:new{
                    text = detail_text,
                    timeout = 10,
                })
            end,
        })
    end
    
    local location_menu = Menu:new{
        title = self.loc:t("menu_locations") .. " (" .. #self.locations .. ")",
        item_table = items,
        is_borderless = true,
        is_popout = false,
        title_bar_fm_style = true,
        width = Screen:getWidth(),
        height = Screen:getHeight(),
    }
    
    UIManager:show(location_menu)
end

function XRayPlugin:showAuthorInfo()
    if not self.author_info then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("no_author_data"),
            timeout = 3,
        })
        return
    end
    
    local text = "✍️ " .. (self.author_info.name or "Unknown Author") .. "\n\n"
    
    if self.author_info.description then
        text = text .. self.author_info.description .. "\n\n"
    end
    
    if self.author_info.birthDate then
        text = text .. "📅 " .. (self.loc:getLanguage() == "tr" and "Doğum" or "Birth") .. ": " .. self.author_info.birthDate .. "\n"
    end
    
    if self.author_info.deathDate then
        text = text .. "💀 " .. (self.loc:getLanguage() == "tr" and "Ölüm" or "Death") .. ": " .. self.author_info.deathDate .. "\n"
    end
    
    if self.author_info.occupation then
        text = text .. "💼 " .. self.loc:t("occupation") .. ": " .. self.author_info.occupation .. "\n"
    end
    
    UIManager:show(InfoMessage:new{
        text = text,
        timeout = 15,
    })
end

function XRayPlugin:showAbout()
    local TextViewer = require("ui/widget/textviewer")
    
    local about_viewer = TextViewer:new{
        title = self.loc:t("about_title"),
        text = self.loc:t("about_text"),
        justified = false,
    }
    
    UIManager:show(about_viewer)
end

function XRayPlugin:clearCache()
    if not self.cache_manager then
        local CacheManager = require("cachemanager")
        self.cache_manager = CacheManager:new()
    end
    
    local ConfirmBox = require("ui/widget/confirmbox")
    UIManager:show(ConfirmBox:new{
        text = self.loc:t("cache_clear_confirm"),
        ok_text = self.loc:t("yes_clear"),
        cancel_text = self.loc:t("cancel"),
        ok_callback = function()
            local book_path = self.ui.document.file
            local success = self.cache_manager:clearCache(book_path)
            
            if success then
                self.book_data = nil
                self.characters = {}
                self.locations = {}
                self.themes = {}
                self.summary = nil
                self.author_info = nil
                self.timeline = {}
                self.historical_figures = {}
                
                UIManager:show(InfoMessage:new{
                    text = self.loc:t("cache_cleared"),
                    timeout = 5,
                })
            else
                UIManager:show(InfoMessage:new{
                    text = self.loc:t("cache_not_found"),
                    timeout = 3,
                })
            end
        end,
    })
end

function XRayPlugin:toggleXRayMode()
    if not self.characters or #self.characters == 0 then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("xray_mode_no_data"),
            timeout = 5,
        })
        return
    end
    
    self.xray_mode_enabled = not self.xray_mode_enabled
    
    if self.xray_mode_enabled then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("xray_mode_enabled"),
            timeout = 7,
        })
    else
        UIManager:show(InfoMessage:new{
            text = self.loc:t("xray_mode_disabled"),
            timeout = 3,
        })
    end
    
    logger.info("XRayPlugin: X-Ray mode:", self.xray_mode_enabled and "enabled" or "disabled")
end

function XRayPlugin:findCharacterByName(word)
    if not self.characters or not word then
        return nil
    end
    
    local word_lower = string.lower(word)
    
    for _, char in ipairs(self.characters) do
        local name_lower = string.lower(char.name or "")
        
        if name_lower == word_lower then
            return char
        end
        
        if string.find(name_lower, word_lower, 1, true) or
           string.find(word_lower, name_lower, 1, true) then
            return char
        end
        
        local first_name = string.match(name_lower, "^(%S+)")
        if first_name and first_name == word_lower then
            return char
        end
    end
    
    return nil
end

function XRayPlugin:showCharacterInfo(char)
    local text = "👤 " .. (char.name or "Unknown") .. "\n\n"
    
    if char.description then
        text = text .. char.description .. "\n\n"
    end
    
    if char.role then
        text = text .. "🎭 " .. self.loc:t("role") .. ": " .. char.role .. "\n"
    end
    
    if char.gender then
        local gender_tr = char.gender == "male" and self.loc:t("gender_male") or 
                         char.gender == "female" and self.loc:t("gender_female") or 
                         char.gender == "erkek" and self.loc:t("gender_male") or
                         char.gender == "kadın" and self.loc:t("gender_female") or
                         char.gender
        text = text .. "👤 " .. self.loc:t("gender") .. ": " .. gender_tr .. "\n"
    end
    
    if char.occupation then
        text = text .. "💼 " .. self.loc:t("occupation") .. ": " .. char.occupation .. "\n"
    end
    
    UIManager:show(InfoMessage:new{
        text = text,
        timeout = 10,
    })
end

function XRayPlugin:setGeminiAPIKey()
    local InputDialog = require("ui/widget/inputdialog")
    
    if not self.ai_helper then
        local AIHelper = require("aihelper")
        self.ai_helper = AIHelper
        self.ai_helper:init()
    end
    
    local current_key = self.ai_helper.providers.gemini.api_key or ""
    
    local input_dialog
    input_dialog = InputDialog:new{
        title = "Google Gemini API Key",
        input = current_key,
        input_hint = "API key",
        description = "Free API key:\nhttps://makersuite.google.com/app/apikey\n\nOr edit config.lua:\ngemini_api_key = \"AIzaSy...\"",
        buttons = {
            {
                {
                    text = self.loc:t("cancel"),
                    callback = function()
                        UIManager:close(input_dialog)
                    end,
                },
                {
                    text = self.loc:t("save"),
                    is_enter_default = true,
                    callback = function()
                        local api_key = input_dialog:getInputText()
                        if api_key and #api_key > 0 then
                            if not self.ai_helper then
                                local AIHelper = require("aihelper")
                                self.ai_helper = AIHelper
                            end
                            
                            self.ai_helper:setAPIKey("gemini", api_key)
                            self.ai_provider = "gemini"
                            
                            UIManager:show(InfoMessage:new{
                                text = "⏳ Testing API key...",
                                timeout = 2,
                            })
                            
                            local success, message = self.ai_helper:testAPIKey("gemini")
                            
                            if success then
                                UIManager:show(InfoMessage:new{
                                    text = "✅ Gemini API Key saved successfully!\n\n🎉 Test passed!\n\nYou can now use 'Fetch AI Data'.",
                                    timeout = 5,
                                })
                            else
                                UIManager:show(InfoMessage:new{
                                    text = "⚠️ API Key saved but test failed!\n\nError: " .. message .. "\n\nPlease check your API key.",
                                    timeout = 8,
                                })
                            end
                        end
                        UIManager:close(input_dialog)
                    end,
                },
            }
        },
    }
    UIManager:show(input_dialog)
    input_dialog:onShowKeyboard()
end

function XRayPlugin:setChatGPTAPIKey()
    local InputDialog = require("ui/widget/inputdialog")
    
    if not self.ai_helper then
        local AIHelper = require("aihelper")
        self.ai_helper = AIHelper
        self.ai_helper:init()
    end
    
    local current_key = self.ai_helper.providers.chatgpt.api_key or ""
    
    local input_dialog
    input_dialog = InputDialog:new{
        title = "ChatGPT API Key",
        input = current_key,
        input_hint = "sk-...",
        description = "API key:\nhttps://platform.openai.com/api-keys\n\nOr edit config.lua:\nchatgpt_api_key = \"sk-...\"",
        buttons = {
            {
                {
                    text = self.loc:t("cancel"),
                    callback = function()
                        UIManager:close(input_dialog)
                    end,
                },
                {
                    text = self.loc:t("save"),
                    is_enter_default = true,
                    callback = function()
                        local api_key = input_dialog:getInputText()
                        if api_key and #api_key > 0 then
                            if not self.ai_helper then
                                local AIHelper = require("aihelper")
                                self.ai_helper = AIHelper
                            end
                            self.ai_helper:setAPIKey("chatgpt", api_key)
                            self.ai_provider = "chatgpt"
                            
                            UIManager:show(InfoMessage:new{
                                text = "✅ ChatGPT API Key saved!",
                                timeout = 3,
                            })
                        end
                        UIManager:close(input_dialog)
                    end,
                },
            }
        },
    }
    UIManager:show(input_dialog)
    input_dialog:onShowKeyboard()
end

function XRayPlugin:selectAIProvider()
    if not self.ai_helper then
        local AIHelper = require("aihelper")
        self.ai_helper = AIHelper
        self.ai_helper:init()
    end
    
    if not self.ai_provider and self.ai_helper.default_provider then
        self.ai_provider = self.ai_helper.default_provider
    end
    
    local providers = {}
    
    if self.ai_helper.providers.gemini.api_key then
        table.insert(providers, {
            text = "✅ Google Gemini (" .. (self.loc:getLanguage() == "tr" and "Aktif" or "Active") .. ": " .. (self.ai_provider == "gemini" and (self.loc:getLanguage() == "tr" and "EVET" or "YES") or (self.loc:getLanguage() == "tr" and "HAYIR" or "NO")) .. ")",
            callback = function()
                self.ai_provider = "gemini"
                UIManager:show(InfoMessage:new{
                    text = "✅ Google Gemini " .. (self.loc:getLanguage() == "tr" and "seçildi" or "selected"),
                    timeout = 2,
                })
            end,
        })
    else
        table.insert(providers, {
            text = "❌ Google Gemini (" .. (self.loc:getLanguage() == "tr" and "API key yok" or "No API key") .. ")",
            callback = function()
                UIManager:show(InfoMessage:new{
                    text = (self.loc:getLanguage() == "tr" and "⚠️ Önce API key ayarlayın" or "⚠️ Please set API key first"),
                    timeout = 3,
                })
            end,
        })
    end
    
    if self.ai_helper.providers.chatgpt.api_key then
        table.insert(providers, {
            text = "✅ ChatGPT (" .. (self.loc:getLanguage() == "tr" and "Aktif" or "Active") .. ": " .. (self.ai_provider == "chatgpt" and (self.loc:getLanguage() == "tr" and "EVET" or "YES") or (self.loc:getLanguage() == "tr" and "HAYIR" or "NO")) .. ")",
            callback = function()
                self.ai_provider = "chatgpt"
                UIManager:show(InfoMessage:new{
                    text = "✅ ChatGPT " .. (self.loc:getLanguage() == "tr" and "seçildi" or "selected"),
                    timeout = 2,
                })
            end,
        })
    else
        table.insert(providers, {
            text = "❌ ChatGPT (" .. (self.loc:getLanguage() == "tr" and "API key yok" or "No API key") .. ")",
            callback = function()
                UIManager:show(InfoMessage:new{
                    text = (self.loc:getLanguage() == "tr" and "⚠️ Önce API key ayarlayın" or "⚠️ Please set API key first"),
                    timeout = 3,
                })
            end,
        })
    end
    
    local provider_menu = Menu:new{
        title = self.loc:getLanguage() == "tr" and "AI Sağlayıcı Seç" or "Select AI Provider",
        item_table = providers,
        is_borderless = true,
        is_popout = false,
        title_bar_fm_style = true,
        width = Screen:getWidth(),
        height = Screen:getHeight(),
    }
    
    UIManager:show(provider_menu)
end

function XRayPlugin:showSummary()
    if not self.summary or #self.summary == 0 then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("no_summary_data"),
            timeout = 3,
        })
        return
    end
    
    UIManager:show(InfoMessage:new{
        text = "📖 " .. (self.loc:getLanguage() == "tr" and "Kitap Özeti" or "Book Summary") .. "\n\n" .. self.summary .. "\n\n(Spoiler-free)",
        timeout = 15,
    })
end

function XRayPlugin:showThemes()
    if not self.themes or #self.themes == 0 then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("no_theme_data"),
            timeout = 3,
        })
        return
    end
    
    local text = "🎨 " .. (self.loc:getLanguage() == "tr" and "Kitabın Temaları" or "Book Themes") .. "\n\n"
    for i, theme in ipairs(self.themes) do
        text = text .. i .. ". " .. theme .. "\n"
    end
    
    UIManager:show(InfoMessage:new{
        text = text,
        timeout = 10,
    })
end

function XRayPlugin:showTimeline()
    if not self.timeline or #self.timeline == 0 then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("no_timeline_data"),
            timeout = 5,
        })
        return
    end
    
    local items = {}
    for i, event in ipairs(self.timeline) do
        local text = ""
        
        if event.chapter then
            text = text .. "📖 " .. event.chapter .. "\n"
        end
        
        if event.event then
            text = text .. event.event
        end
        
        if event.characters and #event.characters > 0 then
            text = text .. "\n👥 " .. table.concat(event.characters, ", ")
        end
        
        table.insert(items, {
            text = text,
            callback = function()
                local detail_text = string.format(self.loc:t("timeline_event"), i) .. "\n\n"
                
                if event.chapter then
                    detail_text = detail_text .. self.loc:t("chapter") .. " " .. event.chapter .. "\n\n"
                end
                
                if event.event then
                    detail_text = detail_text .. event.event .. "\n\n"
                end
                
                if event.characters and #event.characters > 0 then
                    detail_text = detail_text .. self.loc:t("characters_involved") .. "\n"
                    for _, char in ipairs(event.characters) do
                        detail_text = detail_text .. "  • " .. char .. "\n"
                    end
                end
                
                if event.importance then
                    detail_text = detail_text .. "\n" .. self.loc:t("importance") .. "\n" .. event.importance
                end
                
                UIManager:show(InfoMessage:new{
                    text = detail_text,
                    timeout = 15,
                })
            end,
        })
    end
    
    local timeline_menu = Menu:new{
        title = self.loc:t("menu_timeline") .. " (" .. #self.timeline .. " " .. self.loc:t("events") .. ")",
        item_table = items,
        is_borderless = true,
        is_popout = false,
        title_bar_fm_style = true,
        width = Screen:getWidth(),
        height = Screen:getHeight(),
    }
    
    UIManager:show(timeline_menu)
end

function XRayPlugin:showHistoricalFigures()
    if not self.historical_figures or #self.historical_figures == 0 then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("no_historical_data"),
            timeout = 5,
        })
        return
    end
    
    local items = {}
    for i, figure in ipairs(self.historical_figures) do
        local text = ""
        
        if figure.name then
            text = text .. "👤 " .. figure.name
        end
        
        if figure.birth_year or figure.death_year then
            text = text .. "\n   "
            if figure.birth_year then
                text = text .. figure.birth_year
            end
            if figure.death_year then
                text = text .. " - " .. figure.death_year
            elseif figure.birth_year then
                text = text .. " - ?"
            end
        end
        
        if figure.role then
            text = text .. "\n   " .. figure.role
        end
        
        table.insert(items, {
            text = text,
            callback = function()
                self:showHistoricalFigureDetails(figure)
            end,
        })
    end
    
    local figures_menu = Menu:new{
        title = self.loc:t("menu_historical_figures") .. " (" .. #self.historical_figures .. ")",
        item_table = items,
        is_borderless = true,
        is_popout = false,
        title_bar_fm_style = true,
        width = Screen:getWidth(),
        height = Screen:getHeight(),
    }
    
    UIManager:show(figures_menu)
end

function XRayPlugin:showHistoricalFigureDetails(figure)
    local text = "📜 " .. (figure.name or "Unknown") .. "\n\n"
    
    if figure.birth_year or figure.death_year then
        text = text .. "📅 "
        if figure.birth_year then
            text = text .. figure.birth_year
        end
        if figure.death_year then
            text = text .. " - " .. figure.death_year
        elseif figure.birth_year then
            text = text .. " - ?"
        end
        text = text .. "\n\n"
    end
    
    if figure.role then
        text = text .. "👔 " .. self.loc:t("role") .. ": " .. figure.role .. "\n\n"
    end
    
    if figure.biography then
        text = text .. "📖 " .. (self.loc:getLanguage() == "tr" and "Biyografi" or "Biography") .. ":\n" .. figure.biography .. "\n\n"
    end
    
    if figure.importance_in_book then
        text = text .. "📚 " .. (self.loc:getLanguage() == "tr" and "Kitaptaki Önemi" or "Importance in Book") .. ":\n" .. figure.importance_in_book .. "\n\n"
    end
    
    if figure.context_in_book then
        text = text .. "💡 " .. (self.loc:getLanguage() == "tr" and "Kitaptaki Bağlam" or "Context in Book") .. ":\n" .. figure.context_in_book
    end
    
    UIManager:show(InfoMessage:new{
        text = text,
        timeout = 20,
    })
end

function XRayPlugin:showChapterCharacters()
    if not self.characters or #self.characters == 0 then
        UIManager:show(InfoMessage:new{
            text = self.loc:getLanguage() == "tr" and "Henüz karakter bilgisi yok.\n\nLütfen önce AI'dan veri çekin." or "No character data yet.\n\nPlease fetch AI data first.",
            timeout = 3,
        })
        return
    end
    
    if not self.chapter_analyzer then
        local ChapterAnalyzer = require("chapteranalyzer")
        self.chapter_analyzer = ChapterAnalyzer:new()
    end
    
    UIManager:show(InfoMessage:new{
        text = self.loc:t("analyzing_chapter"),
        timeout = 1,
    })
    
    local chapter_text, chapter_title = self.chapter_analyzer:getCurrentChapterText(self.ui)
    
    if not chapter_text or #chapter_text == 0 then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("chapter_text_error"),
            timeout = 3,
        })
        return
    end
    
    local found_chars = self.chapter_analyzer:findCharactersInText(chapter_text, self.characters)
    
    if #found_chars == 0 then
        UIManager:show(InfoMessage:new{
            text = string.format(self.loc:t("no_characters_in_chapter"), chapter_title or self.loc:t("this_chapter")),
            timeout = 5,
        })
        return
    end
    
    local items = {}
    for _, char_info in ipairs(found_chars) do
        local char = char_info.character
        local count = char_info.count
        
        local gender_icon = ""
        if char.gender == "male" or char.gender == "erkek" then
            gender_icon = "👨 "
        elseif char.gender == "female" or char.gender == "kadın" then
            gender_icon = "👩 "
        else
            gender_icon = "👤 "
        end
        
        table.insert(items, {
            text = string.format("%s%s (%dx)", gender_icon, char.name, count),
            callback = function()
                self:showCharacterInfo(char)
            end,
        })
    end
    
    local menu = Menu:new{
        title = string.format("📖 %s\n👥 %d %s", 
                             chapter_title or self.loc:t("this_chapter"), 
                             #found_chars,
                             self.loc:getLanguage() == "tr" and "Karakter" or "Characters"),
        item_table = items,
        is_borderless = true,
        is_popout = false,
        title_bar_fm_style = true,
        width = Screen:getWidth(),
        height = Screen:getHeight(),
    }
    
    UIManager:show(menu)
    
    logger.info("XRayPlugin: Showed chapter characters -", #found_chars, "found")
end

function XRayPlugin:showCharacterNotes()
    if not self.characters or #self.characters == 0 then
        UIManager:show(InfoMessage:new{
            text = self.loc:getLanguage() == "tr" and "Henüz karakter bilgisi yok.\n\nLütfen önce AI'dan veri çekin." or "No character data yet.\n\nPlease fetch AI data first.",
            timeout = 3,
        })
        return
    end
    
    if not self.notes_manager then
        local CharacterNotes = require("characternotes")
        self.notes_manager = CharacterNotes:new()
    end
    
    local book_path = self.ui.document.file
    self.character_notes = self.notes_manager:loadNotes(book_path)
    
    local items = {}
    local notes_count = 0
    
    for _, char in ipairs(self.characters) do
        local note = self.notes_manager:getNote(self.character_notes, char.name)
        if note then
            notes_count = notes_count + 1
            
            local note_preview = note.text or ""
            if #note_preview > 50 then
                note_preview = string.sub(note_preview, 1, 50) .. "..."
            end
            
            table.insert(items, {
                text = "📝 " .. char.name .. "\n   " .. note_preview,
                callback = function()
                    self:showCharacterWithNote(char, note)
                end,
            })
        end
    end
    
    if notes_count > 0 then
        table.insert(items, {
            text = "────────────────",
            separator = true,
        })
    end
    
    for _, char in ipairs(self.characters) do
        local note = self.notes_manager:getNote(self.character_notes, char.name)
        if not note then
            table.insert(items, {
                text = "➕ " .. char.name .. " (" .. self.loc:t("add_note") .. ")",
                callback = function()
                    self:addCharacterNote(char)
                end,
            })
        end
    end
    
    local menu = Menu:new{
        title = string.format(self.loc:t("character_notes_title"), notes_count),
        item_table = items,
        is_borderless = true,
        is_popout = false,
        title_bar_fm_style = true,
        width = Screen:getWidth(),
        height = Screen:getHeight(),
    }
    
    UIManager:show(menu)
end

function XRayPlugin:showCharacterWithNote(char, note)
    local InputDialog = require("ui/widget/inputdialog")
    
    local input_dialog
    input_dialog = InputDialog:new{
        title = "📝 " .. char.name,
        input = note.text,
        input_hint = self.loc:t("note_hint"),
        buttons = {
            {
                {
                    text = self.loc:t("cancel"),
                    callback = function()
                        UIManager:close(input_dialog)
                    end,
                },
                {
                    text = self.loc:t("delete"),
                    callback = function()
                        self:deleteCharacterNote(char)
                        UIManager:close(input_dialog)
                    end,
                },
                {
                    text = self.loc:t("save"),
                    is_enter_default = true,
                    callback = function()
                        local new_note = input_dialog:getInputText()
                        self:updateCharacterNote(char, new_note)
                        UIManager:close(input_dialog)
                    end,
                },
            },
        },
    }
    
    UIManager:show(input_dialog)
    input_dialog:onShowKeyboard()
end

function XRayPlugin:addCharacterNote(char)
    local InputDialog = require("ui/widget/inputdialog")
    
    local input_dialog
    input_dialog = InputDialog:new{
        title = string.format(self.loc:t("add_note_title"), char.name),
        input = "",
        input_hint = self.loc:t("note_hint"),
        buttons = {
            {
                {
                    text = self.loc:t("cancel"),
                    callback = function()
                        UIManager:close(input_dialog)
                    end,
                },
                {
                    text = self.loc:t("save"),
                    is_enter_default = true,
                    callback = function()
                        local note_text = input_dialog:getInputText()
                        if note_text and #note_text > 0 then
                            self:updateCharacterNote(char, note_text)
                        end
                        UIManager:close(input_dialog)
                    end,
                },
            },
        },
    }
    
    UIManager:show(input_dialog)
    input_dialog:onShowKeyboard()
end

function XRayPlugin:updateCharacterNote(char, note_text)
    if not self.notes_manager then
        return
    end
    
    self.notes_manager:setNote(self.character_notes, char.name, note_text)
    
    local book_path = self.ui.document.file
    self.notes_manager:saveNotes(book_path, self.character_notes)
    
    UIManager:show(InfoMessage:new{
        text = string.format(self.loc:t("note_saved"), char.name),
        timeout = 2,
    })
end

function XRayPlugin:deleteCharacterNote(char)
    if not self.notes_manager then
        return
    end
    
    self.notes_manager:deleteNote(self.character_notes, char.name)
    
    local book_path = self.ui.document.file
    self.notes_manager:saveNotes(book_path, self.character_notes)
    
    UIManager:show(InfoMessage:new{
        text = string.format(self.loc:t("note_deleted"), char.name),
        timeout = 2,
    })
    
    self:showCharacterNotes()
end

function XRayPlugin:showQuickXRayMenu()
    local ButtonDialog = require("ui/widget/buttondialog")
    
    local buttons = {
        {
            {
                text = self.loc:t("menu_characters"),
                callback = function()
                    UIManager:close(self.quick_dialog)
                    self:showCharacters()
                end,
            },
        },
        {
            {
                text = self.loc:t("menu_chapter_characters"),
                callback = function()
                    UIManager:close(self.quick_dialog)
                    self:showChapterCharacters()
                end,
            },
        },
        {
            {
                text = self.loc:t("menu_timeline"),
                callback = function()
                    UIManager:close(self.quick_dialog)
                    self:showTimeline()
                end,
            },
        },
        {
            {
                text = self.loc:t("menu_historical_figures"),
                callback = function()
                    UIManager:close(self.quick_dialog)
                    self:showHistoricalFigures()
                end,
            },
        },
        {
            {
                text = self.loc:t("menu_character_notes"),
                callback = function()
                    UIManager:close(self.quick_dialog)
                    self:showCharacterNotes()
                end,
            },
        },
        {
            {
                text = self.loc:t("fetch_data"),
                callback = function()
                    UIManager:close(self.quick_dialog)
                    self:fetchFromAI()
                end,
            },
        },
    }
    
    self.quick_dialog = ButtonDialog:new{
        title = self.loc:t("quick_menu_title"),
        buttons = buttons,
    }
    
    UIManager:show(self.quick_dialog)
end

function XRayPlugin:showCharacterSearch()
    if not self.characters or #self.characters == 0 then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("no_character_data"),
            timeout = 3,
        })
        return
    end
    
    local InputDialog = require("ui/widget/inputdialog")
    local plugin = self
    
    local input_dialog
    input_dialog = InputDialog:new{
        title = self.loc:t("search_character_title"),
        input = "",
        input_hint = self.loc:t("search_hint"),
        buttons = {
            {
                {
                    text = self.loc:t("cancel"),
                    callback = function()
                        UIManager:close(input_dialog)
                    end,
                },
                {
                    text = self.loc:t("search_button"),
                    is_enter_default = true,
                    callback = function()
                        local search_text = input_dialog:getInputText()
                        UIManager:close(input_dialog)
                        
                        if search_text and #search_text > 0 then
                            local found_char = plugin:findCharacterByName(search_text)
                            if found_char then
                                plugin:showCharacterInfo(found_char)
                            else
                                UIManager:show(InfoMessage:new{
                                    text = string.format(self.loc:t("character_not_found"), search_text),
                                    timeout = 3,
                                })
                            end
                        end
                    end,
                },
            },
        },
    }
    
    UIManager:show(input_dialog)
    input_dialog:onShowKeyboard()
end

function XRayPlugin:showFullXRayMenu()
    local menu_items = {}
    self:addToMainMenu(menu_items)
    
    if menu_items.xray and menu_items.xray.sub_item_table then
        local full_menu = Menu:new{
            title = self.loc:t("menu_xray"),
            item_table = menu_items.xray.sub_item_table,
            is_borderless = true,
            is_popout = false,
            title_bar_fm_style = true,
            width = Screen:getWidth(),
            height = Screen:getHeight(),
        }
        UIManager:show(full_menu)
    end
end

function XRayPlugin:onShowXRayMenu()
    self:showQuickXRayMenu()
    return true
end

return XRayPlugin