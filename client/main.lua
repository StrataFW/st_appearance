local bridge <const> = require("client.framework")
local config <const> = require("config")
local logger <const> = require("shared.logger")
local locale <const> = require("shared.locale")
locale.init()

local nui <const> = require("client.nui")
local ped <const> = require("client.ped")
local camera <const> = require("client.camera")
local menu <const> = require("client.menu")
local animation <const> = require("client.animation")
local zones <const> = require("client.zones")

local admin <const> = require("client.admin")
admin.init()

local uniforms <const> = require("client.uniforms")
uniforms.init()

local sharing <const> = require("client.sharing")
local wardrobe <const> = require("client.wardrobe")

local initialSpawn = true

---@param model string
---@return boolean
local function isPedMenuModelAllowed(model)
  if not menu.pedMenuActive then return true end

  local pedMenuModels <const> = config.pedMenu and config.pedMenu.models
  if type(pedMenuModels) ~= "table" then return true end

  for _, pedModel in ipairs(pedMenuModels) do
    if type(pedModel) == "table" and pedModel.value == model then
      return true
    end
  end

  return false
end

local function initAppearance()
  logger.debug("Fetching appearance from server")

  local appearance <const> = lib.callback.await("st_appearance:server:getAppearance", false)
  if not appearance then
    logger.debug("No saved appearance for this character yet")
    return
  end

  logger.debug("Applying initial appearance")
  if appearance.model then
    ped.applyModel(appearance.model)
  end

  ped.applyAppearance(cache.ped, appearance)
end

---@param data table
RegisterNetEvent("st_appearance:client:applyAppearance", function(data)
  if type(data) ~= "table" then return end

  if data.model then
    ped.applyModel(data.model)
  end

  ped.applyAppearance(cache.ped, data)
end)

---@param targetSrc number
---@param targetAppearance table
RegisterNetEvent("st_appearance:client:adminOpenEditor", function(targetSrc, targetAppearance)
  admin.openForPlayer(targetSrc, targetAppearance)
end)

nui.handleMessage("appearance:setModel", function(data)
  if type(data) ~= "table" or type(data.model) ~= "string" then return end

  if not isPedMenuModelAllowed(data.model) then
    logger.warn("Ped model is not allowed in pedmenu: " .. data.model)
    return
  end

  local modelHash <const> = joaat(data.model)
  if not IsModelInCdimage(modelHash) then
    logger.warn("Invalid ped model: " .. data.model)
    return
  end

  if not lib.requestModel(modelHash, config.modelLoadTimeout or 5000) then
    logger.warn("Timed out loading model: " .. data.model)
    return
  end

  SetPlayerModel(cache.playerId, modelHash)
  SetModelAsNoLongerNeeded(modelHash)

  cache.ped = PlayerPedId()
  ped.currentModelName = data.model

  if ped.isFreemode(cache.ped) then
    SetPedDefaultComponentVariation(cache.ped)
    SetPedHeadBlendData(cache.ped, 0, 0, 0, 0, 0, 0, config.defaultShapeMix or 0.5, config.defaultSkinMix or 0.5, 0, false)
  end

  local appearance <const> = ped.getAppearance(cache.ped)
  nui.sendMessage("updateModelAppearance", appearance)
  nui.sendMessage("setMaxValues", ped.getMaxValues(cache.ped))
end)

nui.handleMessage("appearance:exit", function()
  logger.debug("NUI exit requested")
  menu.close(false)
end)

nui.handleMessage("appearance:apply", function(data)
  if type(data) ~= "table" then return end

  logger.debug("Applying and saving appearance")
  if data.model then
    ped.applyModel(data.model)
  end
  ped.applyAppearance(cache.ped, data)
  menu.originalAppearance = ped.getAppearance(cache.ped)

  TriggerServerEvent("st_appearance:server:saveAppearance", menu.originalAppearance)

  if menu.shopType then
    TriggerServerEvent("st_appearance:server:chargeCustomer", menu.shopType)
  end
end)

nui.handleMessage("appearance:revert", function()
  if not menu.originalAppearance then return end

  logger.debug("Reverting appearance")
  if menu.originalAppearance.model then
    ped.applyModel(menu.originalAppearance.model)
  end
  ped.applyAppearance(cache.ped, menu.originalAppearance)
end)

nui.handleMessage("appearance:quickEdit", function(data)
  if type(data) ~= "table" or not data.type or not data.id then return end

  ped.quickEdit(data)
end)

nui.handleMessage("appearance:setFaceFeature", function(data)
  if type(data) ~= "table" or type(data.key) ~= "string" or type(data.value) ~= "number" then return end

  ped.setFaceFeature(data.key, data.value)
end)

nui.handleMessage("appearance:setHeadBlend", function(data)
  if type(data) ~= "table" then return end

  ped.setHeadBlend(data)
end)

nui.handleMessage("appearance:setHair", function(data)
  if type(data) ~= "table" or data.style == nil or data.color == nil or data.highlight == nil then return end

  ped.setHair(data)
end)

nui.handleMessage("appearance:setHairColor", function(data)
  if type(data) ~= "table" or type(data.color) ~= "number" or type(data.highlight) ~= "number" then return end

  ped.setHairColor(data.color, data.highlight)
end)

nui.handleMessage("appearance:setOverlay", function(data)
  if type(data) ~= "table" or type(data.index) ~= "number" then return end

  ped.setOverlay(data)
end)

nui.handleMessage("appearance:setEyeColor", function(data)
  if type(data) ~= "table" or type(data.color) ~= "number" then return end

  ped.setEyeColor(data.color)
end)

nui.handleMessage("appearance:setClothing", function(data)
  if type(data) ~= "table" or type(data.component) ~= "number" or type(data.drawable) ~= "number" or type(data.texture) ~= "number" then return end

  ped.setClothing(data)
  nui.sendMessage("updateTextureMax", {
    type = "component",
    id = data.component,
    maxTexture = ped.getComponentTextureMax(cache.ped, data.component, data.drawable),
  })
end)

nui.handleMessage("appearance:setProp", function(data)
  if type(data) ~= "table" or type(data.prop) ~= "number" or type(data.drawable) ~= "number" or type(data.texture) ~= "number" then return end

  ped.setProp(data)
  nui.sendMessage("updateTextureMax", {
    type = "prop",
    id = data.prop,
    maxTexture = ped.getPropTextureMax(cache.ped, data.prop, data.drawable),
  })
end)

nui.handleMessage("appearance:browseTattoos", function(data)
  if type(data) ~= "table" or type(data.zone) ~= "string" then return end

  if config.rcoreTattoosCompatibility then
    nui.sendMessage("tattooList", { zone = data.zone, tattoos = {} })
    return
  end

  local available = {}
  for _, t in ipairs(config.tattoos) do
    if t.zone == data.zone then
      available[#available + 1] = {
        collection = t.collection,
        overlay = t.overlay,
        zone = t.zone,
        label = t.label,
      }
    end
  end

  nui.sendMessage("tattooList", { zone = data.zone, tattoos = available })
end)

nui.handleMessage("appearance:addTattoo", function(data)
  if type(data) ~= "table" or type(data.collection) ~= "string" or type(data.overlay) ~= "string" then return end

  if config.rcoreTattoosCompatibility then
    ped.applyRCoreTattoos()
    return
  end

  AddPedDecorationFromHashes(cache.ped, joaat(data.collection), joaat(data.overlay))
end)

nui.handleMessage("appearance:reapplyTattoos", function(data)
  if type(data) ~= "table" then return end

  ped.applyTattoos(cache.ped, data)
end)

nui.handleMessage("appearance:clearTattoos", function()
  ped.clearTattoos()
end)

nui.handleMessage("appearance:savePreset", function(data)
  if type(data) ~= "table" or type(data.id) ~= "string" or type(data.name) ~= "string" then return end

  logger.debug("Saving preset:", data.name)
  TriggerServerEvent("st_appearance:server:savePreset", data)
end)

nui.handleMessage("appearance:deletePreset", function(presetId)
  if type(presetId) ~= "string" then return end

  logger.debug("Deleting preset:", presetId)
  TriggerServerEvent("st_appearance:server:deletePreset", presetId)
end)

nui.handleMessage("appearance:applyPreset", function(data)
  if type(data) ~= "table" then return end

  ped.applyAppearance(cache.ped, data)
end)

nui.handleMessage("appearance:previewPreset", function(data)
  if type(data) ~= "table" then return end

  ped.applyAppearance(cache.ped, data)
end)

nui.handleMessage("appearance:saveOutfit", function(data)
  if type(data) ~= "table" or type(data.id) ~= "string" or type(data.name) ~= "string" then return end

  logger.debug("Saving outfit:", data.name)
  TriggerServerEvent("st_appearance:server:saveOutfit", data)
end)

nui.handleMessage("appearance:deleteOutfit", function(outfitId)
  if type(outfitId) ~= "string" then return end

  logger.debug("Deleting outfit:", outfitId)
  TriggerServerEvent("st_appearance:server:deleteOutfit", outfitId)
end)

nui.handleMessage("appearance:updateOutfit", function(data)
  if type(data) ~= "table" or type(data.id) ~= "string" then return end

  TriggerServerEvent("st_appearance:server:updateOutfit", data)
end)

nui.handleMessage("appearance:applyOutfit", function(data)
  if type(data) ~= "table" then return end

  if data.clothing then
    for _, c in ipairs(data.clothing) do
      ped.setClothing(c)
    end
  end

  if data.props then
    for _, p in ipairs(data.props) do
      ped.setProp(p)
    end
  end

  if data.tattoos then
    ped.applyTattoos(cache.ped, data.tattoos)
  end

  if data.hair then
    if data.hair.collection then
      SetPedCollectionComponentVariation(cache.ped, 2, data.hair.collection, data.hair.localIndex, 0, 0)
    else
      SetPedComponentVariation(cache.ped, 2, data.hair.style, 0, 0)
    end

    SetPedHairColor(cache.ped, data.hair.color, data.hair.highlight)
  end
end)

nui.handleMessage("appearance:setCameraPreset", function(data)
  if type(data) ~= "table" or type(data.preset) ~= "string" then return end

  camera.setPreset(data.preset)
end)

nui.handleMessage("appearance:setLighting", function(data)
  if type(data) ~= "table" or type(data.lighting) ~= "string" then return end

  camera.setLighting(data.lighting)
end)

nui.handleMessage("appearance:setFov", function(data)
  if type(data) ~= "table" or type(data.fov) ~= "number" then return end

  camera.setFov(data.fov)
end)

nui.handleMessage("appearance:setZoom", function(data)
  if type(data) ~= "table" or type(data.zoom) ~= "number" then return end

  camera.setZoom(data.zoom)
end)

nui.handleMessage("appearance:setRotation", function(data)
  if type(data) ~= "table" or type(data.rotation) ~= "number" then return end

  camera.setRotation(data.rotation)
end)

nui.handleMessage("appearance:toggleCompare", function(data)
  if type(data) ~= "table" then return end

  if data.enabled then
    if menu.originalAppearance then
      menu.pendingAppearance = ped.getAppearance(cache.ped)
      ped.applyAppearance(cache.ped, menu.originalAppearance)
    end
  else
    if menu.pendingAppearance then
      ped.applyAppearance(cache.ped, menu.pendingAppearance)
      menu.pendingAppearance = nil
    end
  end
end)

nui.handleMessage("appearance:playAnimation", function(data)
  if type(data) ~= "table" or type(data.animation) ~= "string" then return end

  animation.play(data.animation)
end)

nui.handleMessage("appearance:setWalkStyle", function(data)
  if type(data) ~= "table" or type(data.walkStyle) ~= "string" then return end

  ped.applyWalkStyle(data.walkStyle)
end)

nui.handleMessage("appearance:applyAccessorySet", function(data)
  if type(data) ~= "table" then return end

  local p <const> = cache.ped

  if data.clothing then
    for _, c in ipairs(data.clothing) do
      if c.collection then
        local maxTex <const> = GetNumberOfPedCollectionTextureVariations(p, c.component, c.collection, c.localIndex) - 1
        local tex <const> = math.min(c.texture, math.max(maxTex, 0))
        SetPedCollectionComponentVariation(p, c.component, c.collection, c.localIndex, tex, 0)
      else
        local maxTex <const> = GetNumberOfPedTextureVariations(p, c.component, c.drawable) - 1
        local tex <const> = math.min(c.texture, math.max(maxTex, 0))
        SetPedComponentVariation(p, c.component, c.drawable, tex, 0)
      end
    end
  end

  if data.props then
    for _, pr in ipairs(data.props) do
      if pr.drawable == -1 then
        ClearPedProp(p, pr.prop)
      else
        if pr.collection then
          local maxTex <const> = GetNumberOfPedCollectionPropTextureVariations(p, pr.prop, pr.collection, pr.localIndex) - 1
          local tex <const> = math.min(pr.texture, math.max(maxTex, 0))
          SetPedCollectionPropIndex(p, pr.prop, pr.collection, pr.localIndex, tex, false)
        else
          local maxTex <const> = GetNumberOfPedPropTextureVariations(p, pr.prop, pr.drawable) - 1
          local tex <const> = math.min(pr.texture, math.max(maxTex, 0))
          SetPedPropIndex(p, pr.prop, pr.drawable, tex, false)
        end
      end
    end
  end
end)

nui.handleMessage("appearance:adminApply", function(data)
  if admin.isAdminEdit then
    admin.saveForPlayer(data)
    admin.close()
    menu.close(false)
  end
end)

nui.handleMessage("appearance:generateShareCode", function(payload)
  if type(payload) ~= "table" or type(payload.outfitId) ~= "string" then return end

  sharing.generate(payload.outfitId, payload, function(code, err)
    nui.sendMessage("shareCodeResult", { code = code, err = err, outfitId = payload.outfitId })
  end)
end)

nui.handleMessage("appearance:importShareCode", function(payload)
  if type(payload) ~= "table" or type(payload.code) ~= "string" then return end

  sharing.import(payload.code, function(ok, err, outfitId)
    nui.sendMessage("importCodeResult", { ok = ok, err = err, outfitId = outfitId })
    if ok then
      local userOutfits <const> = lib.callback.await("st_appearance:server:getOutfits", false)
      if userOutfits then nui.sendMessage("setOutfits", userOutfits) end
    end
  end)
end)

nui.handleMessage("appearance:revokeShareCode", function(payload)
  if type(payload) ~= "table" or type(payload.code) ~= "string" then return end

  sharing.revoke(payload.code)
end)

nui.handleMessage("appearance:fetchWardrobe", function()
  wardrobe.refresh(function(list, max)
    nui.sendMessage("wardrobeSlots", { slots = list, maxSlots = max })
  end)
end)

nui.handleMessage("appearance:saveWardrobeSlot", function(payload)
  if type(payload) ~= "table" or type(payload.slot) ~= "number" then return end
  local data <const> = payload.data or ped.getAppearance(cache.ped)
  wardrobe.save(payload.slot, payload.name or ("Slot " .. payload.slot), data)
end)

nui.handleMessage("appearance:deleteWardrobeSlot", function(payload)
  if type(payload) ~= "table" or type(payload.slot) ~= "number" then return end
  wardrobe.delete(payload.slot)
end)

nui.handleMessage("appearance:applyWardrobeSlot", function(payload)
  if type(payload) ~= "table" or type(payload.slot) ~= "number" then return end
  wardrobe.apply(payload.slot)
end)

bridge.onPlayerLoaded(function()
  initialSpawn = false
  logger.info("Player loaded — initializing appearance")

  initAppearance()
  zones.init()
end)

---@param resource string
AddEventHandler("onResourceStart", function(resource)
  if resource ~= cache.resource then return end

  logger.info("Resource started — initializing")
  initAppearance()
  zones.init()
end)

---@param resource string
AddEventHandler("onResourceStop", function(resource)
  if resource ~= cache.resource then return end

  logger.info("Resource stopping — cleaning up")
  zones.destroy()
  menu.close(false)
end)

if config.debug then
  RegisterCommand("appearance", function()
    menu.setPedMenuActive(false)
    menu.open()
  end, false)
end

if config.pedMenu and config.pedMenu.enabled then
  RegisterCommand(config.pedMenu.command or "pedmenu", function()
    menu.setPedMenuActive(true)
    menu.setAllowedTabs({ "ped" })
    menu.open()
  end, false)

  if config.pedMenu.acePermission then
    ExecuteCommand(("add_ace builtin.everyone command.%s deny"):format(config.pedMenu.command or "pedmenu"))
  end
end

RegisterCommand(config.commands and config.commands.reloadSkin or "reloadskin", function()
  logger.info("Reloading skin from database")
  initAppearance()
  lib.notify({ title = locale.t("ui.sidebar.appearance"), description = locale.t("notify.skin_reloaded"), type = "success" })
end, false)

---@param options? { tabs?: string[], pedMenu?: boolean }
exports("open", function(options)
  local opts = type(options) == "table" and options or {}
  menu.setPedMenuActive(opts.pedMenu == true)

  if opts.tabs then
    menu.setAllowedTabs(opts.tabs)
  else
    menu.allowedTabs = nil
  end

  menu.open()
end)

exports("close", function() menu.close(false) end)

---@param targetPed number
---@param appearance table
exports("applyAppearance", function(targetPed, appearance)
  if not appearance then return end
  ped.applyAppearance(targetPed, appearance)
end)