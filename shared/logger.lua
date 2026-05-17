
local IS_SERVER <const> = IsDuplicityVersion()
local RESOURCE <const> = "st_appearance"

local function join(...)
  local n = select("#", ...)
  if n == 0 then return "" end
  local parts = {}
  for i = 1, n do parts[i] = tostring((select(i, ...))) end
  return table.concat(parts, " ")
end

local function debugEnabled()
  return GetConvar("st:debug", "0") == "1"
end

local logger = {}

if IS_SERVER then
  function logger.info(...)  if Log then Log.info(RESOURCE,  join(...)) end end
  function logger.warn(...)  if Log then Log.warn(RESOURCE,  join(...)) end end
  function logger.error(...) if Log then Log.error(RESOURCE, join(...)) end end
  function logger.debug(...) if Log then Log.debug(RESOURCE, join(...)) end end
else
  local function emit(level, msg)
    print(("^3[%s] [CLIENT] [%s]^7 %s^0"):format(RESOURCE, level, msg))
  end
  function logger.info(...)  if debugEnabled() then emit("INFO",  join(...)) end end
  function logger.debug(...) if debugEnabled() then emit("DEBUG", join(...)) end end
  function logger.warn(...)  emit("^1WARN^3",  join(...)) end
  function logger.error(...) emit("^1ERROR^3", join(...)) end
end

return logger
