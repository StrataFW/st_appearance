local db       <const> = require("server.db")
local logger   <const> = require("shared.logger")
local security <const> = require("shared.security")
local config   <const> = require("config")

local sharing = {}

---@param identifier string
---@param payload table 
---@param opts? { kind?:string, maxUses?:number, ttlSeconds?:number }
---@return string? code, string? error
function sharing.generate(identifier, payload, opts)
  if type(identifier) ~= "string" or type(payload) ~= "table" then
    return nil, "invalid_args"
  end

  opts = opts or {}

  if not security.fitsBudget(
    payload,
    (config.share.maxPayloadBytes) or 100000)
  then
    return nil, "payload_too_large"
  end

  if not security.allow(
    "share-gen:" .. identifier,
    config.share.rateLimitGen or 5,
    (config.share.rateLimitWindowMs) or 60000)
  then
    return nil, "rate_limited"
  end

  local code
  for _ = 1, 5 do
    local candidate <const> = security.randomCode(config.share.codeLength or 6)
    if not db.shareCodeExists(candidate) then code = candidate; break end
  end
  if not code then return nil, "code_collision" end

  local now <const> = os.time() * 1000
  local expiresAt = nil
  if opts.ttlSeconds and opts.ttlSeconds > 0 then
    expiresAt = now + (opts.ttlSeconds * 1000)
  end

  db.insertShareCode(
    code,
    identifier,
    opts.kind or "outfit",
    payload,
    math.max(0, math.floor(tonumber(opts.maxUses) or 0)),
    expiresAt,
    now
  )

  logger.info("Share code generated:", code, "by:", identifier)
  return code, nil
end

---@param identifier string
---@param code string
---@return table? data, nil, string? error
function sharing.import(identifier, code)
  if type(code) ~= "string" or #code < 4 or #code > 32 then
    return nil, nil, "invalid_code"
  end

  if not security.allow(
    "share-import:" .. identifier,
    (config.share.rateLimitImport) or 20,
    (config.share.rateLimitWindowMs) or 60000)
  then
    return nil, nil, "rate_limited"
  end

  local row <const> = db.findShareCode(code:upper())
  if not row then return nil, nil, "not_found" end

  local now <const> = os.time() * 1000
  if row.expires_at and now > row.expires_at then
    return nil, nil, "expired"
  end

  if row.max_uses and row.max_uses > 0 and row.uses >= row.max_uses then
    return nil, nil, "exhausted"
  end

  db.incrementShareCodeUses(row.code)

  local ok, decoded = pcall(json.decode, row.payload)
  if not ok then return nil, nil, "corrupt" end

  return decoded, nil, nil
end

---@param identifier string
---@param code string
---@return boolean
function sharing.revoke(identifier, code)
  if type(code) ~= "string" then return false end
  return db.deleteShareCode(code:upper(), identifier)
end

---@param identifier string
---@return table[]
function sharing.list(identifier)
  return db.listShareCodes(identifier)
end

return sharing
