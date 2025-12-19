-- X-Ray Plugin for KOReader v2.0.0

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
    local Localization = require("localization_xray")
    self.loc = Localization
    self.loc:init() -- Load saved language preference
    
    self:onDispatcherRegisterActions()
    
    logger.info("XRayPlugin v1.0.0: Initialized with language:", self.loc:getLanguage())
end

function XRayPlugin:onReaderReady()
    -- Auto-load cache when book is opened
    self:autoLoadCache()
end

function XRayPlugin:onDispatcherRegisterActions()
    
    local Dispatcher = require("dispatcher")
    
    -- X-Ray Quick Menu action
    Dispatcher:registerAction("xray_quick_menu", {
        category = "none",
        event = "ShowXRayQuickMenu",
        title = self.loc:t("quick_menu_title") or "X-Ray Quick Menu",
        general = true,
        separator = true,
    })
    
    -- X-Ray Characters action
    Dispatcher:registerAction("xray_characters", {
        category = "none",
        event = "ShowXRayCharacters",
        title = self.loc:t("menu_characters") or "Characters",
        general = true,
    })
    
    -- X-Ray Chapter Characters action
    Dispatcher:registerAction("xray_chapter_characters", {
        category = "none",
        event = "ShowXRayChapterCharacters",
        title = self.loc:t("menu_chapter_characters") or "Chapter Characters",
        general = true,
    })
    
    -- X-Ray Timeline action
    Dispatcher:registerAction("xray_timeline", {
        category = "none",
        event = "ShowXRayTimeline",
        title = self.loc:t("menu_timeline") or "Timeline",
        general = true,
    })
    
    -- X-Ray Historical Figures action
    Dispatcher:registerAction("xray_historical", {
        category = "none",
        event = "ShowXRayHistorical",
        title = self.loc:t("menu_historical_figures") or "Historical Figures",
        general = true,
    })

    -- X-Ray Themes action
    Dispatcher:registerAction("xray_themes", {
        category = "none",
        event = "ShowXRayThemes",
        title = self.loc:t("menu_themes") or "Themes",
        general = true,
    })    
    
    -- X-Ray Locations action
    Dispatcher:registerAction("xray_locations", {
        category = "none",
        event = "ShowXRayLocations",
        title = self.loc:t("menu_locations") or "Locations",
        general = true,
    }) 
end

-- Event handlers for Dispatcher actions
function XRayPlugin:onShowXRayQuickMenu()
    self:showQuickXRayMenu()
    return true
end

function XRayPlugin:onShowXRayFullMenu()
    self:showFullXRayMenu()
    return true
end

function XRayPlugin:onShowXRayCharacters()
    self:showCharacters()
    return true
end

function XRayPlugin:onShowXRayChapterCharacters()
    self:showChapterCharacters()
    return true
end

function XRayPlugin:onShowXRayTimeline()
    self:showTimeline()
    return true
end

function XRayPlugin:onShowXRayHistorical()
    self:showHistoricalFigures()
    return true
end

function XRayPlugin:onShowXRayThemes()
    self:showThemes()
    return true
end

function XRayPlugin:onShowXRayLocations()
    self:showLocations()
    return true
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
        self.timeline = cached_data.timeline or {}
        self.historical_figures = cached_data.historical_figures or {}
        if cached_data.author_info then
            self.author_info = cached_data.author_info
        else
            -- Eğer yapı düz ise (author_bio varsa)
            self.author_info = {
                name = cached_data.author,
                description = cached_data.author_bio,
                birthDate = cached_data.author_birth,
                deathDate = cached_data.author_death
            }
        end
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

-- Get current reading progress (works for EPUB, PDF, MOBI, etc.)
function XRayPlugin:getReadingProgress()
    -- Default values
    local current_page = 0
    local total_pages = 0
    local progress = 0
    
    if not self.ui or not self.ui.document then
        logger.warn("XRayPlugin: No document or UI available")
        return current_page, total_pages, progress
    end
    
    local doc = self.ui.document
    
    -- Get total pages
    local success_pages, pages = pcall(function() return doc:getPageCount() end)
    if success_pages and pages and pages > 0 then
        total_pages = pages
    else
        logger.warn("XRayPlugin: Could not get page count")
        return current_page, total_pages, progress
    end
    
    -- Try multiple methods to get current page
    local methods = {
        -- Method 1: Paging (for PDF, DjVu)
        function()
            if self.ui.paging and type(self.ui.paging.getCurrentPage) == "function" then
                return self.ui.paging:getCurrentPage()
            end
        end,
        -- Method 2: Rolling (for EPUB, MOBI)
        function()
            if self.ui.rolling and type(self.ui.rolling.getCurrentPage) == "function" then
                return self.ui.rolling:getCurrentPage()
            end
        end,
        -- Method 3: Document direct
        function()
            if type(doc.getCurrentPage) == "function" then
                return doc:getCurrentPage()
            end
        end,
        -- Method 4: View state
        function()
            if self.view and self.view.state and self.view.state.page then
                return self.view.state.page
            end
        end,
        -- Method 5: Document settings
        function()
            if self.ui.doc_settings then
                local settings = self.ui.doc_settings
                return settings:readSetting("last_page") or settings:readSetting("page")
            end
        end,
    }
    
    -- Try each method
    for i, method in ipairs(methods) do
        local success_method, page = pcall(method)
        if success_method and page and tonumber(page) then
            current_page = tonumber(page)
            logger.info("XRayPlugin: Got current page using method", i, ":", current_page)
            break
        end
    end
    
    -- If still no page, try one more fallback
    if current_page == 0 and self.ui.document then
        local success_fallback, fallback_page = pcall(function()
            -- Try to get from bookmark or last position
            if self.ui.bookmark and self.ui.bookmark.getCurrentPageNumber then
                return self.ui.bookmark:getCurrentPageNumber()
            end
        end)
        
        if success_fallback and fallback_page then
            current_page = tonumber(fallback_page) or 0
            logger.info("XRayPlugin: Got current page from fallback:", current_page)
        end
    end
    
    -- Calculate progress
    if total_pages > 0 and current_page > 0 then
        progress = math.floor((current_page / total_pages) * 100)
    end
    
    logger.info("XRayPlugin: Reading progress -", current_page, "/", total_pages, "=", progress .. "%")
    
    return current_page, total_pages, progress
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
    local function safe_t(key)
        if self.loc and self.loc.t then
            return self.loc:t(key) or key
        end
        return key
    end
    
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
            { separator = true,},
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
            { separator = true },
            {
                text = self.loc:t("menu_fetch_ai"),
                keep_menu_open = true,
                callback = function()
                    self:fetchFromAI()
                end,
            },
            {
                text = self.loc:t("menu_ai_settings"),
                keep_menu_open = true,
                sub_item_table = {
                    {
                        text = self.loc:t("menu_gemini_key"), 
                        keep_menu_open = true,
                        callback = function()
                            self:setGeminiAPIKey()
                        end,
                    },
                    {
                        text = self.loc:t("menu_gemini_model"), 
                        keep_menu_open = true,
                        callback = function()
                            self:selectGeminiModel()
                        end,
                    },
                    { separator = true },
                    {
                        text = self.loc:t("menu_chatgpt_key"), 
                        keep_menu_open = true,
                        callback = function()
                            self:setChatGPTAPIKey()
                        end,
                    },
                    { separator = true },
                    {
                        text = self.loc:t("menu_provider_select"), 
                        keep_menu_open = true,
                        callback = function()
                            self:selectAIProvider()
                        end,
                    },
                }
            },
            {separator = true,},
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
                text = self.loc:t("menu_xray_language") or "X-Ray Data Language",
                keep_menu_open = true,
                callback = function()
                    self:showXRayLanguageSelection()
                end,
            },
            { separator = true },
            {
                text = self.loc:t("menu_about"),
                keep_menu_open = true,
                callback = function()
                    self:showAbout()
                end,
            },
        }
    }
    
    logger.info("XRayPlugin: Menu item 'xray' added successfully with Gemini Model option")
end

function XRayPlugin:showLanguageSelection()
    local ButtonDialog = require("ui/widget/buttondialog")
    local InfoMessage = require("ui/widget/infomessage")
    
    local current_lang = "en" -- Default
    if self.loc then
        current_lang = self.loc:getLanguage()
    end
    
    local function changeLang(lang_code, lang_name)
        UIManager:close(self.ldlg)
        
        if self.loc then 
            self.loc:setLanguage(lang_code) 
        end
        
        UIManager:show(InfoMessage:new{
            text = "✅" .. self.loc:t("language_changed") .. "\n\n" .. self.loc:t("please_restart"),
            timeout = 4 
        })
    end
    
    local buttons = {
        {
            {
                text = "English" .. (current_lang == "en" and " ✓" or ""), 
                callback = function() changeLang("en", "English") end
            }
        },
        {
            {
                text = "Русский" .. (current_lang == "ru" and " ✓" or ""), 
                callback = function() changeLang("ru", "Русский") end
            }
        },
        {
            {
                text = "Українська" .. (current_lang == "uk" and " ✓" or ""), 
                callback = function() changeLang("uk", "Українська") end
            }
        },
        {
            {
                text = "Türkçe" .. (current_lang == "tr" and " ✓" or ""), 
                callback = function() changeLang("tr", "Türkçe") end
            }
        },
        {
            {
                text = "Português" .. (current_lang == "pt_br" and " ✓" or ""), 
                callback = function() changeLang("pt_br", "Português") end
            }
        },
        {
            {
                text = "Español" .. (current_lang == "es" and " ✓" or ""), 
                callback = function() changeLang("es", "Español") end
            }
        },
    }
    
    self.ldlg = ButtonDialog:new{title = "🌐 " .. (self.loc:t("language_title") or "Language"), buttons = buttons}
    UIManager:show(self.ldlg)
end

function XRayPlugin:showXRayLanguageSelection()
    local ButtonDialog = require("ui/widget/buttondialog")
    local InfoMessage = require("ui/widget/infomessage")
    
    -- Initialize AI Helper if needed
    if not self.ai_helper then
        local AIHelper = require("aihelper")
        self.ai_helper = AIHelper
        self.ai_helper:init()
    end
    
    local current_xray_lang = self.ai_helper:getXRayLanguage()
    
    local function setXRayLang(lang_code)
        UIManager:close(self.xldlg)
        self.ai_helper:saveXRayLanguage(lang_code)
        
        local msg = self.loc:t("xray_language_changed") or "X-Ray language changed"
        UIManager:show(InfoMessage:new{
            text = "✅ " .. msg,
            timeout = 3 
        })
    end
    
    local buttons = {
        {
            {
                text = (self.loc:t("xray_language_auto") or "Auto (book language)") .. (current_xray_lang == "auto" and " ✓" or ""), 
                callback = function() setXRayLang("auto") end
            }
        },
        {
            {
                text = (self.loc:t("xray_language_ui") or "Same as UI language") .. (current_xray_lang == "ui" and " ✓" or ""), 
                callback = function() setXRayLang("ui") end
            }
        },
        {
            {
                text = "English" .. (current_xray_lang == "en" and " ✓" or ""), 
                callback = function() setXRayLang("en") end
            }
        },
        {
            {
                text = "Русский" .. (current_xray_lang == "ru" and " ✓" or ""), 
                callback = function() setXRayLang("ru") end
            }
        },
        {
            {
                text = "Українська" .. (current_xray_lang == "uk" and " ✓" or ""), 
                callback = function() setXRayLang("uk") end
            }
        },
        {
            {
                text = "Türkçe" .. (current_xray_lang == "tr" and " ✓" or ""), 
                callback = function() setXRayLang("tr") end
            }
        },
        {
            {
                text = "Português" .. (current_xray_lang == "pt_br" and " ✓" or ""), 
                callback = function() setXRayLang("pt_br") end
            }
        },
        {
            {
                text = "Español" .. (current_xray_lang == "es" and " ✓" or ""), 
                callback = function() setXRayLang("es") end
            }
        },
    }
    
    self.xldlg = ButtonDialog:new{
        title = "📖 " .. (self.loc:t("xray_language_title") or "X-Ray Data Language"),
        buttons = buttons
    }
    UIManager:show(self.xldlg)
end

function XRayPlugin:showCharacters()
    if not self.characters or #self.characters == 0 then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("no_character_data") or "No character data",
            timeout = 3,
        })
        return
    end
    
    local items = {}
    
    -- Add search option
    table.insert(items, {
        text = self.loc:t("search_character") or "🔍 Search Character",
        callback = function()
            self:showCharacterSearch()
        end
    })
    
    -- Add characters
    for i, char in ipairs(self.characters) do
        -- CRITICAL: Ensure char and char.name exist
        if char and type(char) == "table" then
            local name = char.name
            
            -- Ensure name is a string
            if type(name) ~= "string" or name == "" then
                name = self.loc:t("unknown_character") or "Unknown Character"
            end
            
            local text = "│ " .. name
            
            -- Add description if available
            if char.description and type(char.description) == "string" and #char.description > 0 then
                text = text .. "\n   " .. char.description
            elseif char.gender or char.occupation then
                local details = {}
                if char.gender and type(char.gender) == "string" then 
                    table.insert(details, char.gender) 
                end
                if char.occupation and type(char.occupation) == "string" then 
                    table.insert(details, char.occupation) 
                end
                if #details > 0 then
                    text = text .. "\n   " .. table.concat(details, ", ")
                end
            end
            
            -- CRITICAL: Ensure text is not nil
            if text and type(text) == "string" and #text > 0 then
                table.insert(items, {
                    text = text,
                    callback = function()
                        self:showCharacterDetails(char)
                    end
                })
            else
                logger.warn("XRayPlugin: Skipping character with invalid text at index", i)
            end
        else
            logger.warn("XRayPlugin: Skipping invalid character at index", i)
        end
    end
    
    -- Ensure we have items to display
    if #items <= 2 then
        -- Only search and separator
        UIManager:show(InfoMessage:new{
            text = self.loc:t("no_character_data") or "No valid character data",
            timeout = 3,
        })
        return
    end
    
    local character_menu = Menu:new{
        title = (self.loc:t("menu_characters") or "Characters") .. " (" .. #self.characters .. ")",
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

function XRayPlugin:selectGeminiModel()
    if not self.ai_helper then
        local AIHelper = require("aihelper")
        self.ai_helper = AIHelper
        self.ai_helper:init()
    end

    local current_model = "gemini-2.5-flash"
    if self.ai_helper.providers and self.ai_helper.providers.gemini then
        current_model = self.ai_helper.providers.gemini.model or "gemini-2.5-flash"
    end

    local ButtonDialog = require("ui/widget/buttondialog")
    local buttons = {
        {
            {
                text = "Gemini 2.5 Flash" .. (current_model == "gemini-2.5-flash" and " ✓" or ""),
                callback = function()
                    self.ai_helper:setGeminiModel("gemini-2.5-flash")
                    UIManager:close(self.dlg)
                    local InfoMessage = require("ui/widget/infomessage")
                    UIManager:show(InfoMessage:new{text = self.loc:t("gemini_model_flash_info"), timeout = 2})
                end
            }
        },
        {
            {
                text = "Gemini 2.5 Pro" .. (current_model == "gemini-2.5-pro" and " ✓" or ""),
                callback = function()
                    self.ai_helper:setGeminiModel("gemini-2.5-pro")
                    UIManager:close(self.dlg)
                    local InfoMessage = require("ui/widget/infomessage")
                    UIManager:show(InfoMessage:new{text = self.loc:t("gemini_model_pro_info"), timeout = 2})
                end
            }
        },
        {
            {
                text = "Gemini 3 Pro Preview" .. (current_model == "gemini-3-pro-preview" and " ✓" or ""),
                callback = function()
                    self.ai_helper:setGeminiModel("gemini-3-pro-preview")
                    UIManager:close(self.dlg)
                    local InfoMessage = require("ui/widget/infomessage")
                    UIManager:show(InfoMessage:new{text = self.loc:t("gemini_model_3_pro_info"), timeout = 2})
                end
            }
        },
    }
    self.dlg = ButtonDialog:new{
        title = self.loc:t("gemini_model_title"),
        buttons = buttons,
    }
    UIManager:show(self.dlg)
end

function XRayPlugin:fetchFromAI()
    logger.info("XRayPlugin: Fetching AI data")
    
    -- 1. WİRELESS KONTROL
    local NetworkMgr = require("ui/network/manager")
    
    if not NetworkMgr:isOnline() then
        logger.info("XRayPlugin: Network is offline, asking user...")
        
        local UIManager = require("ui/uimanager")
        local ConfirmBox = require("ui/widget/confirmbox")
        
        UIManager:show(ConfirmBox:new{
            text = self.loc:t("network_offline_prompt"),
            ok_text = self.loc:t("turn_on_wifi"),
            cancel_text = self.loc:t("cancel"),
            ok_callback = function()
                logger.info("XRayPlugin: User chose to turn on WiFi")
                
                -- WiFi'yi aç
                NetworkMgr:turnOnWifi(function()
                    logger.info("XRayPlugin: WiFi turned on, proceeding with fetch")
                    -- WiFi açıldıktan sonra spoiler tercihini sor
                    self:askSpoilerPreference()
                end)
            end,
            cancel_callback = function()
                logger.info("XRayPlugin: User cancelled WiFi activation")
                local InfoMessage = require("ui/widget/infomessage")
                UIManager:show(InfoMessage:new{
                    text = self.loc:t("fetch_cancelled"),
                    timeout = 3,
                })
            end,
        })
        return
    end
    
    -- WiFi zaten açıksa spoiler tercihini sor
    self:askSpoilerPreference()
end

function XRayPlugin:askSpoilerPreference()
    logger.info("XRayPlugin: Asking spoiler preference")
    
    local UIManager = require("ui/uimanager")
    local Menu = require("ui/widget/menu")
    local Screen = require("device").screen
    
    -- Okuma yüzdesini hesapla
    local current_page = self.ui:getCurrentPage()
    local total_pages = self.ui.document:getPageCount()
    local reading_percent = math.floor((current_page / total_pages) * 100)
    
    local spoiler_menu = Menu:new{
        title = self.loc:t("spoiler_preference_title"),
        item_table = {
            {
                text = string.format(
                    self.loc:t("spoiler_free_option"),
                    reading_percent
                ),
                callback = function()
                    logger.info("XRayPlugin: User chose spoiler-free mode")
                    UIManager:close(spoiler_menu)
                    self:continueWithFetch(reading_percent)
                end,
            },
            {
                text = self.loc:t("full_book_option"),
                callback = function()
                    logger.info("XRayPlugin: User chose full book mode")
                    UIManager:close(spoiler_menu)
                    self:continueWithFetch(100)
                end,
            },
            {
                text = self.loc:t("cancel"),
                callback = function()
                    logger.info("XRayPlugin: User cancelled fetch")
                    UIManager:close(spoiler_menu)
                    local InfoMessage = require("ui/widget/infomessage")
                    UIManager:show(InfoMessage:new{
                        text = self.loc:t("fetch_cancelled"),
                        timeout = 3,
                    })
                end,
            },
        },
        is_borderless = true,
        is_popout = false,
        title_bar_fm_style = true,
        width = Screen:getWidth(),
        height = Screen:getHeight(),
    }
    
    UIManager:show(spoiler_menu)
end

function XRayPlugin:continueWithFetch(reading_percent)
    logger.info("XRayPlugin: Continuing with fetch process (reading_percent:", reading_percent, ")")
    
    -- 1. Cache Manager Başlat (Kontrol için gerekli)
    if not self.cache_manager then
        local CacheManager = require("cachemanager")
        self.cache_manager = CacheManager:new()
    end
    
    -- 2. CACHE KONTROLÜ
    local book_path = self.ui.document.file
    local cache_path = self.cache_manager:getCachePath(book_path)
    local lfs = require("libs/libkoreader-lfs")
    
    -- Eğer cache dosyası varsa, işlemi durdur ve uyarı ver
    if cache_path and lfs.attributes(cache_path) then
        local InfoMessage = require("ui/widget/infomessage")
        UIManager:show(InfoMessage:new{
            text = self.loc:t("cache_verify"),
            timeout = 6,
        })
        return 
    end

    -- 3. AI Helper Başlat (Eğer cache yoksa devam et)
    if not self.ai_helper then
        local AIHelper = require("aihelper")
        self.ai_helper = AIHelper
        self.ai_helper:init()
    end
    
    -- Seçili provider'ı al (varsayılan: gemini)
    local selected_provider = self.ai_provider or self.ai_helper.default_provider or "gemini"
    local provider_config = self.ai_helper.providers[selected_provider]
    
    local title = self.ui.document:getProps().title or "Unknown"
    local author = self.ui.document:getProps().authors or ""
    
    -- Model adını seçili provider'a göre al
    local current_model = self.loc:t("unknown_model")
    if provider_config and provider_config.model then
        current_model = provider_config.model
    end
    
    -- Provider adını al
    local provider_name = provider_config and provider_config.name or "AI"
    
    -- Spoiler durumunu hazırla
    local spoiler_status = reading_percent < 100 and 
        string.format(self.loc:t("spoiler_free_mode"), reading_percent) or 
        self.loc:t("full_book_mode_active")
    
    -- 4. Bekleme Mesajı Göster
    local InfoMessage = require("ui/widget/infomessage")
    local wait_msg = InfoMessage:new{
        text = string.format(
            self.loc:t("fetching_ai") ..
            self.loc:t("fetching_model") .. "%s\n" ..
            self.loc:t("book_title") .. "%s\n" ..
            "%s\n\n" ..
            self.loc:t("fetching_wait") ..
            self.loc:t("dont_touch"), 
            current_model,
            title,
            spoiler_status
        ),
        timeout = 60,
    }
    UIManager:show(wait_msg)
    
    -- 5. İşlemi Başlat
    UIManager:scheduleIn(1.0, function()
        -- Seçili provider'ı kullan (reading_percent context olarak gönderiliyor)
        local context = {
            reading_percent = reading_percent,
            spoiler_free = reading_percent < 100
        }
        
        -- Get book language from metadata
        local book_language = nil
        local props = self.ui.document:getProps()
        if props and props.language then
            book_language = props.language
            logger.info("XRayPlugin: Book language from metadata:", book_language)
        end
        
        local book_data, error_code, error_msg = self.ai_helper:getBookData(title, author, selected_provider, context, book_language)
        
        if wait_msg then UIManager:close(wait_msg) end
        
        if not book_data then
            local error_text = self.loc:t("error_info") .. "\n\n"
            if error_code == "error_safety" then
                error_text = error_text .. self.loc:t("error_filtered")
            elseif error_code == "error_503" then
                error_text = error_text .. self.loc:t("error_network_timeout")
            elseif error_msg then
                error_text = error_text .. error_msg
            else
                error_text = error_text .. self.loc:t("ai_fetch_failed")
            end
            
            UIManager:show(InfoMessage:new{
                text = error_text,
                timeout = 7,
            })
            return
        end
    
        -- Save data to plugin state
        self.book_title = book_data.book_title
        self.author = book_data.author
        self.author_bio = book_data.author_bio
        self.author_birth = book_data.author_birth
        self.author_death = book_data.author_death
        self.summary = book_data.summary
        self.characters = book_data.characters or {}
        self.themes = book_data.themes or {}
        self.locations = book_data.locations or {}
        self.timeline = book_data.timeline or {}
        self.historical_figures = book_data.historical_figures or {}
        
        logger.info("XRayPlugin: Found", #self.characters, "characters")
        logger.info("XRayPlugin: Found", #self.themes, "themes")
        logger.info("XRayPlugin: Found", #self.locations, "locations")
        logger.info("XRayPlugin: Found", #self.timeline, "timeline events")
        logger.info("XRayPlugin: Found", #self.historical_figures, "historical figures")
        
        -- Save to cache
        logger.info("XRayPlugin: Saving to cache")
        local cache_saved = self.cache_manager:saveCache(book_path, book_data)
        
        local cache_msg = cache_saved and self.loc:t("cache_saved") or self.loc:t("cache_save_failed")
        
        -- Show detailed success message with proper string.format
        local success_message = string.format(
            self.loc:t("ai_fetch_complete"),
            provider_name,                          -- %s: Provider adı (Google Gemini / ChatGPT)
            book_data.book_title,                   -- %s: Kitap adı
            book_data.author,                       -- %s: Yazar
            #self.characters,                       -- %d: Karakter sayısı
            #self.locations,                        -- %d: Mekan sayısı
            #self.themes,                           -- %d: Tema sayısı
            #self.timeline,                         -- %d: Olay sayısı
            #self.historical_figures,               -- %d: Tarihi kişilik sayısı
            cache_msg                               -- %s: Cache mesajı
        )
        
        UIManager:show(InfoMessage:new{
            text = success_message,
            timeout = 10,
        })
    end)
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
    if not self.author_info or not self.author_info.description or #self.author_info.description == 0 then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("no_author_data"),
            timeout = 3,
        })
        return
    end
    
    local text = "✍️ " .. (self.author_info.name or self.loc:t("menu_author_info")) .. "\n\n"
    text = text .. self.author_info.description .. "\n\n"
    
    if self.author_info.birthDate and #self.author_info.birthDate > 0 then
        text = text .. "📅: " .. self.author_info.birthDate .. "\n"
    end
    if self.author_info.deathDate and #self.author_info.deathDate > 0 then
        text = text .. "💀: " .. self.author_info.deathDate .. "\n"
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
        title = self.loc:t("gemini_key_title"), 
        input = current_key,
        input_hint = self.loc:t("gemini_key_hint"), 
        description = self.loc:t("gemini_key_desc"), 
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
                                text = self.loc:t("gemini_key_saved"), 
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
        title = self.loc:t("chatgpt_key_title"), 
        input = current_key,
        input_hint = self.loc:t("chatgpt_key_hint"), 
        description = self.loc:t("chatgpt_key_desc"), 
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
                                text = self.loc:t("chatgpt_key_saved"), 
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
    
    -- 1. ADIM: Değişkeni burada önceden tanımlıyoruz (henüz boş)
    local provider_menu 

    local providers = {}
    
    local gemini_key = self.ai_helper.providers.gemini and self.ai_helper.providers.gemini.api_key
    if gemini_key and gemini_key ~= "" then
        table.insert(providers, {
            text = "✅ Google Gemini (" .. (self.loc:getLanguage() == "tr" and "Aktif" or "Active") .. ": " .. (self.ai_provider == "gemini" and (self.loc:getLanguage() == "tr" and "EVET" or "YES") or (self.loc:getLanguage() == "tr" and "HAYIR" or "NO")) .. ")",
            callback = function()
                self.ai_provider = "gemini"
                self.ai_helper:setDefaultProvider("gemini")
                UIManager:show(InfoMessage:new{
                    text = self.loc:t("gemini_selected"), 
                    timeout = 2,
                })
                
                -- 3. ADIM: Artık provider_menu dolu olduğu için bu satır çalışır
                if provider_menu then
                    UIManager:close(provider_menu)
                end
            end,
        })
    else
        table.insert(providers, {
            text = "❌ Google Gemini (" .. (self.loc:getLanguage() == "tr" and "API key yok" or "No API key") .. ")",
            callback = function()
                UIManager:show(InfoMessage:new{
                    text = self.loc:t("set_key_first"), 
                    timeout = 3,
                })
            end,
        })
    end
    
    local chatgpt_key = self.ai_helper.providers.chatgpt and self.ai_helper.providers.chatgpt.api_key
    if chatgpt_key and chatgpt_key ~= "" then
        table.insert(providers, {
            text = "✅ ChatGPT (" .. (self.loc:getLanguage() == "tr" and "Aktif" or "Active") .. ": " .. (self.ai_provider == "chatgpt" and (self.loc:getLanguage() == "tr" and "EVET" or "YES") or (self.loc:getLanguage() == "tr" and "HAYIR" or "NO")) .. ")",
            callback = function()
                self.ai_provider = "chatgpt"
                self.ai_helper:setDefaultProvider("chatgpt")
                UIManager:show(InfoMessage:new{
                    text = self.loc:t("chatgpt_selected"), 
                    timeout = 2,
                })
                
                -- 3. ADIM: Burada da menüyü kapatıyoruz
                if provider_menu then
                    UIManager:close(provider_menu)
                end
            end,
        })
    else
        table.insert(providers, {
            text = "❌ ChatGPT (" .. (self.loc:getLanguage() == "tr" and "API key yok" or "No API key") .. ")",
            callback = function()
                UIManager:show(InfoMessage:new{
                    text = self.loc:t("set_key_first"), 
                    timeout = 3,
                })
            end,
        })
    end
    
    -- 2. ADIM: Daha önce tanımladığımız değişkene atama yapıyoruz (başındaki 'local' ifadesini kaldırdık)
    provider_menu = Menu:new{
        title = self.loc:t("provider_select_title"), 
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
        text = "📖 " .. self.loc:t("summary_title") .. "\n\n" .. self.summary .. "\n\n(Spoiler-free)", 
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
    
    local text = "🎨 " .. self.loc:t("themes_title") .. "\n\n" 
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
        text = text .. "📖 " .. self.loc:t("hist_bio") .. ":\n" .. figure.biography .. "\n\n"
    end
    
    if figure.importance_in_book then
        text = text .. "📚 " .. self.loc:t("hist_importance") .. ":\n" .. figure.importance_in_book .. "\n\n"
    end
    
    if figure.context_in_book then
        text = text .. "💡 " .. self.loc:t("hist_context") .. ":\n" .. figure.context_in_book
    end
    
    UIManager:show(InfoMessage:new{
        text = text,
        timeout = 20,
    })
end

function XRayPlugin:showChapterCharacters()
    if not self.characters or #self.characters == 0 then
        UIManager:show(InfoMessage:new{
            text = self.loc:t("no_char_data_fetch"), 
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
                             self.loc:t("chapter_chars_title")), 
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
            text = self.loc:t("no_char_data_fetch"), 
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
        local char_name = char.name or self.loc:t("unknown_character")
        local note = self.notes_manager:getNote(self.character_notes, char.name)
        if note then
            notes_count = notes_count + 1
            
            local note_preview = note.text or ""
            if #note_preview > 50 then
                note_preview = string.sub(note_preview, 1, 50) .. "..."
            end
            
            table.insert(items, {
                text = "📝 " .. char_name .. "\n   " .. note_preview,
                callback = function()
                    self:showCharacterWithNote(char, note)
                end,
            })
        end
    end
    
    if notes_count > 0 then
        table.insert(items, {            
            separator = true,
        })
    end
    
    for _, char in ipairs(self.characters) do
        local char_name = char.name or self.loc:t("unknown_character")
        local note = self.notes_manager:getNote(self.character_notes, char.name)
        if not note then
            table.insert(items, {
                text = "➕ " .. char_name .. " (" .. self.loc:t("add_note") .. ")",
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
        self.full_menu = Menu:new{
            title = self.loc:t("menu_xray"),
            item_table = menu_items.xray.sub_item_table,
            is_borderless = true,
            is_popout = false,
            title_bar_fm_style = true,
            width = Screen:getWidth(),
            height = Screen:getHeight(),
        }
        UIManager:show(self.full_menu)
    end
end


function XRayPlugin:onShowXRayMenu()
    self:showQuickXRayMenu()
    return true
end

return XRayPlugin

