local logger <const> = require("shared.logger")

local locale = {}

---@type table
local strings = {}

---@type table<string, string>
local flat = {}

---@param tbl table
---@param prefix string
---@param result table<string, string>
local function flatten(tbl, prefix, result)
    for k, v in pairs(tbl) do
        local fullKey <const> = prefix == "" and k or (prefix .. "." .. k)
        if type(v) == "table" then
            flatten(v, fullKey, result)
        else
            result[fullKey] = v
        end
    end
end

---@param tbl table
---@param key string
---@return string|nil
local function resolve(tbl, key)
    local current = tbl
    for part in key:gmatch("[^%.]+") do
        if type(current) ~= "table" then return nil end
        current = current[part]
    end
    return type(current) == "string" and current or nil
end

function locale.init()
    local raw <const> = LoadResourceFile(cache.resource, "locales/en.json")
    if not raw then
        logger.error("locales/en.json missing")
        strings, flat = {}, {}
        return
    end

    local ok, data = pcall(json.decode, raw)
    if not ok or type(data) ~= "table" then
        logger.error("locales/en.json failed to parse")
        strings, flat = {}, {}
        return
    end

    strings = data
    flat    = {}
    flatten(strings, "", flat)
end

---@param key string
---@param ... any
---@return string
function locale.t(key, ...)
    local value <const> = resolve(strings, key) or key
    if select("#", ...) > 0 then
        local ok, result = pcall(string.format, value, ...)
        if ok then return result end
    end
    return value
end

---@return table<string, string>
function locale.getAll()
    return flat
end

return locale
