local bridge <const> = require("server.framework")
local db     <const> = require("server.db")
local logger <const> = require("shared.logger")

local players = {}
local cache = {}

---@param src number
---@return table?
function cache.load(src)
  if players[src] then return players[src] end

  local identifier <const> = bridge.getIdentifier(src)
  if not identifier then
    logger.warn("Failed to get identifier for player:", src)
    return
  end

  logger.debug("Loading player data:", src, identifier)

  local skin       <const> = db.getSkin(identifier)
  local presetRows <const> = db.listPresets(identifier)
  local outfitRows <const> = db.listOutfits(identifier)

  local presets = {}
  for _, row in ipairs(presetRows or {}) do
    presets[row.preset_id] = {
      id = row.preset_id,
      name = row.name,
      tags = json.decode(row.tags) or {},
      data = json.decode(row.data),
      createdAt = row.created_at,
      shareCode = row.share_code,
    }
  end

  local outfits = {}
  for _, row in ipairs(outfitRows or {}) do
    outfits[row.outfit_id] = {
      id = row.outfit_id,
      name = row.name,
      category = row.category or "custom",
      data = json.decode(row.data),
      shareCode = row.share_code,
      favorite = row.favorite == 1,
      createdAt = row.created_at,
      tags = row.tags and json.decode(row.tags) or {},
    }
  end

  local wardrobeRows <const> = db.listWardrobe(identifier)
  local wardrobe = {}
  for _, row in ipairs(wardrobeRows) do
    wardrobe[row.slot] = {
      slot = row.slot,
      name = row.name,
      data = json.decode(row.data),
      updatedAt = row.updated_at,
    }
  end

  players[src] = {
    identifier = identifier,
    appearance = skin and json.decode(skin) or nil,
    presets = presets,
    outfits = outfits,
    wardrobe = wardrobe,
  }

  if Log then
    Log.info('st_appearance', 'appearance loaded', { src = src })
  else
    logger.info('Player data loaded:', src, identifier)
  end
  return players[src]
end

---@param src number
function cache.unload(src)
  local player <const> = players[src]
  if not player then return end

  logger.debug("Unloading player data:", src, player.identifier)

  if player.appearance then
    db.upsertSkin(player.identifier, player.appearance)
  end

  players[src] = nil
end

---@param src number
---@return table?
function cache.getAppearance(src)
  local player <const> = cache.load(src)
  if not player then return end

  return player.appearance
end

---@param src number
---@param appearance table
function cache.setAppearance(src, appearance)
  local player <const> = cache.load(src)
  if not player then return end

  player.appearance = appearance
  db.upsertSkin(player.identifier, appearance)
end

---@param src number
---@return table
function cache.getPresets(src)
  local player <const> = cache.load(src)
  if not player then return {} end

  local list = {}
  for _, preset in pairs(player.presets) do
    list[#list + 1] = preset
  end

  table.sort(list, function(a, b) return (a.createdAt or 0) > (b.createdAt or 0) end)
  return list
end

---@param src number
---@param preset table
function cache.addPreset(src, preset)
  local player <const> = cache.load(src)
  if not player then return end

  local createdAt <const> = preset.createdAt or os.time() * 1000
  player.presets[preset.id] = {
    id = preset.id,
    name = preset.name,
    tags = preset.tags or {},
    data = preset.data,
    createdAt = createdAt,
    shareCode = preset.shareCode,
  }

  db.insertPreset(player.identifier, {
    id        = preset.id,
    name      = preset.name,
    tags      = preset.tags or {},
    data      = preset.data,
    shareCode = preset.shareCode,
    createdAt = createdAt,
  })
end

---@param src number
---@param presetId string
function cache.removePreset(src, presetId)
  local player <const> = cache.load(src)
  if not player then return end

  player.presets[presetId] = nil
  db.deletePreset(player.identifier, presetId)
end

---@param src number
---@return table
function cache.getOutfits(src)
  local player <const> = cache.load(src)
  if not player then return {} end

  local list = {}
  for _, outfit in pairs(player.outfits) do
    list[#list + 1] = outfit
  end

  table.sort(list, function(a, b) return (a.createdAt or 0) > (b.createdAt or 0) end)
  return list
end

---@param src number
---@param outfit table
function cache.addOutfit(src, outfit)
  local player <const> = cache.load(src)
  if not player then return end

  local createdAt <const> = outfit.createdAt or os.time() * 1000
  player.outfits[outfit.id] = {
    id = outfit.id,
    name = outfit.name,
    category = outfit.category or "custom",
    data = outfit.data,
    shareCode = outfit.shareCode,
    favorite = outfit.favorite or false,
    createdAt = createdAt,
    tags = outfit.tags or {},
  }

  db.insertOutfit(player.identifier, {
    id        = outfit.id,
    name      = outfit.name,
    category  = outfit.category or "custom",
    data      = outfit.data,
    shareCode = outfit.shareCode,
    favorite  = outfit.favorite or false,
    createdAt = createdAt,
    tags      = outfit.tags or {},
  })
end

---@param src number
---@param outfitId string
function cache.removeOutfit(src, outfitId)
  local player <const> = cache.load(src)
  if not player then return end

  player.outfits[outfitId] = nil
  db.deleteOutfit(player.identifier, outfitId)
end

---@param src number
---@param outfitId string
---@param updates table
function cache.updateOutfit(src, outfitId, updates)
  local player <const> = cache.load(src)
  if not player or not player.outfits[outfitId] then return end

  local outfit <const> = player.outfits[outfitId]

  if updates.name then outfit.name = updates.name end
  if updates.category then outfit.category = updates.category end
  if updates.favorite ~= nil then outfit.favorite = updates.favorite end
  if updates.tags then outfit.tags = updates.tags end

  db.updateOutfit(player.identifier, outfitId, {
    name     = outfit.name,
    category = outfit.category,
    favorite = outfit.favorite,
    tags     = outfit.tags or {},
  })
end

---@param src number
---@return string?
function cache.getIdentifier(src)
  local player <const> = cache.load(src)
  return player and player.identifier or nil
end

---@param src number
---@return table[]
function cache.getWardrobe(src)
  local player <const> = cache.load(src)
  if not player then return {} end

  local list = {}
  for _, slot in pairs(player.wardrobe) do
    list[#list + 1] = slot
  end
  table.sort(list, function(a, b) return (a.slot or 0) < (b.slot or 0) end)
  return list
end

---@param src number
---@param slot number
---@param entry table { name, data }
function cache.setWardrobeSlot(src, slot, entry)
  local player <const> = cache.load(src)
  if not player then return end

  local stored <const> = {
    slot = slot,
    name = entry.name,
    data = entry.data,
    updatedAt = os.time() * 1000,
  }
  player.wardrobe[slot] = stored

  db.upsertWardrobeSlot(player.identifier, slot, {
    name      = stored.name,
    data      = stored.data,
    updatedAt = stored.updatedAt,
  })
end

---@param src number
---@param slot number
function cache.deleteWardrobeSlot(src, slot)
  local player <const> = cache.load(src)
  if not player then return end

  player.wardrobe[slot] = nil
  db.deleteWardrobeSlot(player.identifier, slot)
end

function cache.saveAll()
  local count = 0
  for src in pairs(players) do
    cache.unload(src)
    count = count + 1
  end
  logger.info("Saved all player data:", count, "players")
end

return cache
