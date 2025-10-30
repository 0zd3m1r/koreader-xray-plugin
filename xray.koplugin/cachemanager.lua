-- CacheManager - X-Ray data caching system
local lfs = require("libs/libkoreader-lfs")
local logger = require("logger")
local DocSettings = require("docsettings")

local CacheManager = {}

function CacheManager:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Get cache file path for a book
function CacheManager:getCachePath(book_path)
    if not book_path then
        return nil
    end
    
    -- Use KOReader's sidecar directory
    local cache_dir = DocSettings:getSidecarDir(book_path)
    local cache_file = cache_dir .. "/xray_cache.lua"
    
    return cache_file
end

-- Save book data to cache
function CacheManager:saveCache(book_path, data)
    if not book_path or not data then
        logger.warn("CacheManager: Cannot save cache - invalid parameters")
        return false
    end
    
    local cache_file = self:getCachePath(book_path)
    if not cache_file then
        logger.warn("CacheManager: Cannot determine cache path")
        return false
    end
    
    -- Add timestamp
    data.cached_at = os.time()
    data.cache_version = "6.0"
    
    -- Serialize data
    local success = pcall(function()
        local f = io.open(cache_file, "w")
        if f then
            f:write("-- X-Ray Cache v6.0\n")
            f:write("return " .. self:serialize(data))
            f:close()
            logger.info("CacheManager: Saved cache to:", cache_file)
            return true
        else
            logger.warn("CacheManager: Cannot open file for writing:", cache_file)
            return false
        end
    end)
    
    return success
end

-- Load book data from cache
function CacheManager:loadCache(book_path)
    if not book_path then
        return nil
    end
    
    local cache_file = self:getCachePath(book_path)
    if not cache_file then
        logger.warn("CacheManager: Cannot determine cache path")
        return nil
    end
    
    -- Check if cache file exists
    local attr = lfs.attributes(cache_file)
    if not attr then
        logger.info("CacheManager: No cache file found")
        return nil
    end
    
    -- Load cache
    local success, data = pcall(function()
        return dofile(cache_file)
    end)
    
    if not success or not data then
        logger.warn("CacheManager: Failed to load cache")
        return nil
    end
    
    -- Check cache version
    if data.cache_version ~= "6.0" then
        logger.warn("CacheManager: Cache version mismatch, ignoring")
        return nil
    end
    
    -- Cache age check removed - cache is now永久 (永久 = permanent)
    -- Cache will stay valid forever unless manually cleared
    
    logger.info("CacheManager: Loaded cache from:", cache_file)
    if data.cached_at then
        local cache_age_days = math.floor((os.time() - data.cached_at) / 86400)
        logger.info("CacheManager: Cache age:", cache_age_days, "days (no expiration)")
    end
    
    return data
end

-- Serialize Lua table to string
function CacheManager:serialize(obj, indent)
    indent = indent or ""
    local t = type(obj)
    
    if t == "table" then
        local s = "{\n"
        for k, v in pairs(obj) do
            s = s .. indent .. "  "
            if type(k) == "string" then
                s = s .. "[" .. string.format("%q", k) .. "] = "
            else
                s = s .. "[" .. k .. "] = "
            end
            s = s .. self:serialize(v, indent .. "  ") .. ",\n"
        end
        s = s .. indent .. "}"
        return s
    elseif t == "string" then
        return string.format("%q", obj)
    elseif t == "number" or t == "boolean" then
        return tostring(obj)
    else
        return "nil"
    end
end

-- Clear cache for a book
function CacheManager:clearCache(book_path)
    local cache_file = self:getCachePath(book_path)
    if cache_file then
        os.remove(cache_file)
        logger.info("CacheManager: Cleared cache:", cache_file)
        return true
    end
    return false
end

return CacheManager
