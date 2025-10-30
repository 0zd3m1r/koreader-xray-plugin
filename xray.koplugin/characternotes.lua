-- CharacterNotes - Personal notes for characters
local logger = require("logger")
local lfs = require("libs/libkoreader-lfs")
local DocSettings = require("docsettings")

local CharacterNotes = {}

function CharacterNotes:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Get notes file path
function CharacterNotes:getNotesPath(book_path)
    if not book_path then
        return nil
    end
    
    local cache_dir = DocSettings:getSidecarDir(book_path)
    local notes_file = cache_dir .. "/xray_notes.lua"
    
    return notes_file
end

-- Load all notes for a book
function CharacterNotes:loadNotes(book_path)
    local notes_file = self:getNotesPath(book_path)
    if not notes_file then
        return {}
    end
    
    local attr = lfs.attributes(notes_file)
    if not attr then
        logger.info("CharacterNotes: No notes file found")
        return {}
    end
    
    local success, notes = pcall(function()
        return dofile(notes_file)
    end)
    
    if success and notes then
        logger.info("CharacterNotes: Loaded", self:countNotes(notes), "notes")
        return notes
    end
    
    return {}
end

-- Save notes for a book
function CharacterNotes:saveNotes(book_path, notes)
    local notes_file = self:getNotesPath(book_path)
    if not notes_file then
        return false
    end
    
    local success = pcall(function()
        local f = io.open(notes_file, "w")
        if f then
            f:write("-- X-Ray Character Notes\n")
            f:write("return " .. self:serialize(notes))
            f:close()
            logger.info("CharacterNotes: Saved notes to:", notes_file)
            return true
        end
        return false
    end)
    
    return success
end

-- Get note for a specific character
function CharacterNotes:getNote(notes, character_name)
    if not notes or not character_name then
        return nil
    end
    
    return notes[character_name]
end

-- Add or update note for a character
function CharacterNotes:setNote(notes, character_name, note_text)
    if not notes or not character_name then
        return false
    end
    
    notes[character_name] = {
        text = note_text,
        updated_at = os.time(),
    }
    
    logger.info("CharacterNotes: Updated note for:", character_name)
    return true
end

-- Delete note for a character
function CharacterNotes:deleteNote(notes, character_name)
    if not notes or not character_name then
        return false
    end
    
    notes[character_name] = nil
    logger.info("CharacterNotes: Deleted note for:", character_name)
    return true
end

-- Count total notes
function CharacterNotes:countNotes(notes)
    if not notes then
        return 0
    end
    
    local count = 0
    for _ in pairs(notes) do
        count = count + 1
    end
    
    return count
end

-- Serialize table to string
function CharacterNotes:serialize(obj, indent)
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

return CharacterNotes
