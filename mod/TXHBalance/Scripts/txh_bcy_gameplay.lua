-- BCY gameplay 逻辑使用单文件实现，避免运行时 include 路径问题。

TXHBalanceBCY = TXHBalanceBCY or {}

local state = {
  recalculating = {},
  terrain_yields = {},
  resource_yields = {},
  feature_yields = {},
  base_guaranteed_yields = {
    [0] = 2,
    [1] = 1,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
  },
  flat_terrains = {
    [0] = true,
    [3] = true,
    [6] = true,
    [9] = true,
    [12] = true,
  },
  hill_terrains = {
    [1] = true,
    [4] = true,
    [7] = true,
    [10] = true,
    [13] = true,
  },
}

TXHBalanceBCY.State = state

local YIELD_NAME_TO_ID = {
  YIELD_FOOD = 0,
  YIELD_PRODUCTION = 1,
  YIELD_GOLD = 2,
  YIELD_SCIENCE = 3,
  YIELD_CULTURE = 4,
  YIELD_FAITH = 5,
}

local EXTRA_YIELD_PROPERTIES = {
  [0] = "EXTRA_YIELD_FOOD",
  [1] = "EXTRA_YIELD_PRODUCTION",
  [2] = "EXTRA_YIELD_GOLD",
  [3] = "EXTRA_YIELD_SCIENCE",
  [4] = "EXTRA_YIELD_CULTURE",
  [5] = "EXTRA_YIELD_FAITH",
}

local FIRAXIS_YIELD_PROPERTIES = {
  [0] = "FIRAXIS_YIELD_FOOD",
  [1] = "FIRAXIS_YIELD_PRODUCTION",
  [2] = "FIRAXIS_YIELD_GOLD",
  [3] = "FIRAXIS_YIELD_SCIENCE",
  [4] = "FIRAXIS_YIELD_CULTURE",
  [5] = "FIRAXIS_YIELD_FAITH",
}

function TXHBalanceBCY.GetMode()
  return GameConfiguration.GetValue("BBCC_SETTING") or -1
end

function TXHBalanceBCY.GetYieldMode()
  return GameConfiguration.GetValue("BBCC_SETTING_YIELD") or 0
end

function TXHBalanceBCY.YieldNameToID(name)
  return YIELD_NAME_TO_ID[name]
end

function TXHBalanceBCY.ExtraYieldPropertyName(iYieldId)
  return EXTRA_YIELD_PROPERTIES[iYieldId]
end

function TXHBalanceBCY.FiraxisYieldPropertyName(iYieldId)
  return FIRAXIS_YIELD_PROPERTIES[iYieldId]
end

function TXHBalanceBCY.FindPositions(list, search_item, key, multi)
  multi = multi or false
  local results = {}

  if search_item == nil then
    return false
  end

  for index, item in ipairs(list) do
    if key == nil then
      if item == search_item then
        if multi then
          table.insert(results, index)
        else
          return index
        end
      end
    elseif item[key] == search_item then
      if multi then
        table.insert(results, index)
      else
        return index
      end
    end
  end

  if #results == 0 then
    return false
  end

  return results
end

function TXHBalanceBCY.PopulateTerrainYields()
  local terrain_ids = {0, 1, 3, 4, 6, 7, 9, 10, 12, 13}
  local cached_yield_changes = DB.Query("SELECT * FROM Terrain_YieldChanges")

  for _, terrain_id in ipairs(terrain_ids) do
    local terrain_info = GameInfo.Terrains[terrain_id]
    if terrain_info ~= nil then
      local row = {}
      local occurrence_ids = TXHBalanceBCY.FindPositions(cached_yield_changes, terrain_info.TerrainType, "TerrainType", true)
      if occurrence_ids ~= false then
        for _, occurrence_id in ipairs(occurrence_ids) do
          local yield_row = cached_yield_changes[occurrence_id]
          row[TXHBalanceBCY.YieldNameToID(yield_row.YieldType)] = yield_row.YieldChange
        end
        state.terrain_yields[terrain_id] = row
      end
    end
  end
end

function TXHBalanceBCY.PopulateResourceYields()
  local cached_resources = DB.Query("SELECT * FROM Resources")
  local cached_yield_changes = DB.Query("SELECT * FROM Resource_YieldChanges")

  for index, resource_data in ipairs(cached_resources) do
    if resource_data.ResourceClassType ~= "RESOURCECLASS_ARTIFACT" then
      local resource_info = GameInfo.Resources[index - 1]
      if resource_info ~= nil then
        local row = {}
        local occurrence_ids = TXHBalanceBCY.FindPositions(cached_yield_changes, resource_info.ResourceType, "ResourceType", true)
        if occurrence_ids ~= false then
          for _, occurrence_id in ipairs(occurrence_ids) do
            local yield_row = cached_yield_changes[occurrence_id]
            row[TXHBalanceBCY.YieldNameToID(yield_row.YieldType)] = yield_row.YieldChange
          end
          state.resource_yields[index - 1] = row
        end
      end
    end
  end
end

function TXHBalanceBCY.PopulateFeatureYields()
  local cached_features = DB.Query("SELECT * FROM Features")
  local cached_yield_changes = DB.Query("SELECT * FROM Feature_YieldChanges")

  for index, feature_data in ipairs(cached_features) do
    if feature_data.Settlement == true and feature_data.Removable == false then
      local feature_info = GameInfo.Features[index - 1]
      if feature_info ~= nil then
        local row = {}
        local occurrence_ids = TXHBalanceBCY.FindPositions(cached_yield_changes, feature_info.FeatureType, "FeatureType", true)
        if occurrence_ids ~= false then
          for _, occurrence_id in ipairs(occurrence_ids) do
            local yield_row = cached_yield_changes[occurrence_id]
            row[TXHBalanceBCY.YieldNameToID(yield_row.YieldType)] = yield_row.YieldChange
          end
          state.feature_yields[index - 1] = row
        end
      end
    end
  end
end

function TXHBalanceBCY.GetYield(object_type, object_id, yield_id)
  local yield = nil

  if object_type == "TERRAIN" then
    if state.terrain_yields[object_id] ~= nil then
      yield = state.terrain_yields[object_id][yield_id]
    end
  elseif object_type == "RESOURCE" then
    if state.resource_yields[object_id] ~= nil then
      yield = state.resource_yields[object_id][yield_id]
    end
  elseif object_type == "FEATURE" then
    if state.feature_yields[object_id] ~= nil then
      yield = state.feature_yields[object_id][yield_id]
    end
  else
    return 0
  end

  if yield == nil then
    return 0
  end

  return yield
end

function TXHBalanceBCY.CalculateBaseYield(plot, yield_list, exclude_resource)
  yield_list = yield_list or nil
  exclude_resource = exclude_resource or false

  local calculated_yields = {}
  local terrain_id = plot:GetTerrainType()
  local resource_id = plot:GetResourceType()
  local feature_id = plot:GetFeatureType()

  if yield_list == nil then
    for i = 0, 5 do
      if exclude_resource then
        calculated_yields[i] = TXHBalanceBCY.GetYield("TERRAIN", terrain_id, i) + TXHBalanceBCY.GetYield("FEATURE", feature_id, i)
      else
        calculated_yields[i] = TXHBalanceBCY.GetYield("TERRAIN", terrain_id, i) + TXHBalanceBCY.GetYield("RESOURCE", resource_id, i) + TXHBalanceBCY.GetYield("FEATURE", feature_id, i)
      end
    end
  else
    for _, yield_id in ipairs(yield_list) do
      if exclude_resource then
        calculated_yields[yield_id] = TXHBalanceBCY.GetYield("TERRAIN", terrain_id, yield_id) + TXHBalanceBCY.GetYield("FEATURE", feature_id, yield_id)
      else
        calculated_yields[yield_id] = TXHBalanceBCY.GetYield("TERRAIN", terrain_id, yield_id) + TXHBalanceBCY.GetYield("RESOURCE", resource_id, yield_id) + TXHBalanceBCY.GetYield("FEATURE", feature_id, yield_id)
      end
    end
  end

  if exclude_resource then
    return calculated_yields, resource_id
  end

  return calculated_yields
end

function TXHBalanceBCY.GetControlTableName(iTerrain)
  if state.flat_terrains[iTerrain] then
    return "Flat_CutOffYieldValues"
  end

  if state.hill_terrains[iTerrain] then
    return "Hill_CutOffYieldValues"
  end

  return nil
end

local function should_skip_city(player_id)
  return TXHBalanceBCY.GetMode() == 1 and Players[player_id]:GetCities():GetCount() > 1
end

local function plot_context(plot, yield_list)
  local base_yields, resource_id = TXHBalanceBCY.CalculateBaseYield(plot, yield_list, true)
  local control_table = TXHBalanceBCY.GetControlTableName(plot:GetTerrainType())
  if control_table == nil then
    return nil
  end

  local is_strategic_resource = false
  if resource_id ~= nil and resource_id ~= -1 then
    local resource_info = GameInfo.Resources[resource_id]
    is_strategic_resource = resource_info ~= nil and resource_info.ResourceClassType == "RESOURCECLASS_STRATEGIC"
  end

  return {
    base_yields = base_yields,
    resource_id = resource_id,
    control_table = control_table,
    is_strategic_resource = is_strategic_resource,
  }
end

local function build_city_context(player_id, city_id, x, y, yield_list)
  local city = CityManager.GetCity(player_id, city_id)
  if city == nil or should_skip_city(player_id) then
    return nil
  end

  local plot = Map.GetPlot(x, y)
  if plot == nil then
    return nil
  end

  local context = plot_context(plot, yield_list)
  if context ~= nil then
    context.city = city
  end
  return context
end

local function attach_modifier_count(city, modifier_id, count)
  if count == nil or count <= 0 then
    return
  end

  for _ = 1, count do
    city:AttachModifierByID(modifier_id)
  end
end

local function apply_city_built_bonus(city, yield_id, base_bonus_count, strategic_bonus_count, resource_type)
  if base_bonus_count ~= nil and base_bonus_count > 0 then
    attach_modifier_count(city, "MODIFIER_CITY_GRANT_1_" .. GameInfo.Yields[yield_id].YieldType .. "_BBCC", base_bonus_count)
  end

  if strategic_bonus_count ~= nil and strategic_bonus_count > 0 and resource_type ~= nil then
    attach_modifier_count(city, "MODIFIER_CITY_GRANT_1_" .. GameInfo.Yields[yield_id].YieldType .. "_NS_" .. resource_type .. "_BBCC", strategic_bonus_count)
  end
end

local FOUNDING_BONUS_PROPERTY = "TXH_BCY_FOUNDING_BONUS_APPLIED"

local function begin_founding_bonus(city)
  if city:GetProperty(FOUNDING_BONUS_PROPERTY) == 1 then
    return false
  end
  -- Persist before attaching, so a repeated or reentrant CityBuilt event cannot
  -- attach the same founding package again.
  city:SetProperty(FOUNDING_BONUS_PROPERTY, 1)
  return true
end

-- Founding package of the Maximum rule, for food and production: the
-- permanent bonus count, and the temporary count that applies only while the
-- owner cannot see the tile's strategic resource (*_NS_<resource>_BBCC).
-- Earlier versions founded No RNG cities with the same package.
local function legacy_founding_package(context)
  local resource_type = nil
  if context.resource_id ~= nil and context.resource_id ~= -1 and context.is_strategic_resource then
    resource_type = GameInfo.Resources[context.resource_id].ResourceType
  end

  local package = {}
  for i = 0, 1 do
    local guaranteed_yield = GameInfo[context.control_table][i].Amount
    local firaxis_initial_yield = math.max(state.base_guaranteed_yields[i], context.base_yields[i])
    local base_bonus_count = 0
    local strategic_bonus_count = 0

    if context.resource_id ~= nil and context.resource_id ~= -1 then
      local final_tile_yield = context.base_yields[i] + TXHBalanceBCY.GetYield("RESOURCE", context.resource_id, i)
      local firaxis_final_yield = math.max(state.base_guaranteed_yields[i], final_tile_yield)

      if guaranteed_yield > firaxis_final_yield then
        base_bonus_count = guaranteed_yield - firaxis_final_yield
        if context.is_strategic_resource then
          strategic_bonus_count = firaxis_final_yield - firaxis_initial_yield
        end
      elseif context.is_strategic_resource and firaxis_initial_yield < guaranteed_yield then
        strategic_bonus_count = guaranteed_yield - firaxis_initial_yield
      end
    elseif guaranteed_yield > firaxis_initial_yield then
      base_bonus_count = guaranteed_yield - firaxis_initial_yield
    end

    package[i] = {base = base_bonus_count, strategic = strategic_bonus_count}
  end

  return package, resource_type
end

function TXHBalanceBCY.OnCityBuiltLegacy(player_id, city_id, x, y)
  local context = build_city_context(player_id, city_id, x, y, {0, 1})
  if context == nil or not begin_founding_bonus(context.city) then
    return
  end

  local package, resource_type = legacy_founding_package(context)
  for i = 0, 1 do
    apply_city_built_bonus(context.city, i, package[i].base, package[i].strategic, resource_type)
  end
end

function TXHBalanceBCY.OnCityBuiltStandard(player_id, city_id, x, y)
  local context = build_city_context(player_id, city_id, x, y, nil)
  if context == nil or not begin_founding_bonus(context.city) then
    return
  end

  local final_tile_yields = {}
  local pre_reveal_rebalance = true
  local post_reveal_rebalance = true
  local unchanged_yield_count = 0
  local resource_type = nil

  if context.resource_id ~= nil and context.resource_id ~= -1 and context.is_strategic_resource then
    resource_type = GameInfo.Resources[context.resource_id].ResourceType
  end

  for i = 0, 5 do
    local guaranteed_yield = GameInfo[context.control_table][i].Amount
    final_tile_yields[i] = context.base_yields[i] + TXHBalanceBCY.GetYield("RESOURCE", context.resource_id, i)

    if guaranteed_yield < context.base_yields[i] and context.is_strategic_resource then
      pre_reveal_rebalance = false
      post_reveal_rebalance = false
      break
    elseif guaranteed_yield < final_tile_yields[i] then
      post_reveal_rebalance = false
      break
    elseif guaranteed_yield == final_tile_yields[i] then
      unchanged_yield_count = unchanged_yield_count + 1
    end
  end

  if unchanged_yield_count == 6 then
    post_reveal_rebalance = false
  end

  if context.resource_id ~= nil and context.resource_id ~= -1 then
    if post_reveal_rebalance then
      for i = 0, 1 do
        local guaranteed_yield = GameInfo[context.control_table][i].Amount
        local firaxis_final_yield = math.max(state.base_guaranteed_yields[i], final_tile_yields[i])
        local base_bonus_count = 0
        local strategic_bonus_count = 0

        if guaranteed_yield > firaxis_final_yield then
          base_bonus_count = guaranteed_yield - firaxis_final_yield
          if context.is_strategic_resource then
            local firaxis_initial_yield = math.max(state.base_guaranteed_yields[i], context.base_yields[i])
            strategic_bonus_count = firaxis_final_yield - firaxis_initial_yield
          end
        end

        apply_city_built_bonus(context.city, i, base_bonus_count, strategic_bonus_count, resource_type)
      end
    elseif pre_reveal_rebalance and context.is_strategic_resource then
      for i = 0, 1 do
        local guaranteed_yield = GameInfo[context.control_table][i].Amount
        local firaxis_initial_yield = math.max(state.base_guaranteed_yields[i], context.base_yields[i])
        local strategic_bonus_count = 0

        if firaxis_initial_yield < guaranteed_yield then
          strategic_bonus_count = guaranteed_yield - firaxis_initial_yield
        end

        apply_city_built_bonus(context.city, i, 0, strategic_bonus_count, resource_type)
      end
    end
  else
    if pre_reveal_rebalance == false then
      return
    end

    for i = 0, 1 do
      local firaxis_initial_yield = math.max(state.base_guaranteed_yields[i], context.base_yields[i])
      local guaranteed_yield = GameInfo[context.control_table][i].Amount
      local base_bonus_count = 0

      if guaranteed_yield > firaxis_initial_yield then
        base_bonus_count = guaranteed_yield - firaxis_initial_yield
      end

      apply_city_built_bonus(context.city, i, base_bonus_count, 0, nil)
    end
  end
end

function TXHBalanceBCY.OnGameplayAdjustCityYield(player_id, parameters)
  if type(parameters) ~= "table" or type(player_id) ~= "number" or player_id < 0 then
    return
  end
  if parameters.iOwnerId ~= player_id or Players[player_id] == nil then
    return
  end
  local x, y = parameters.iX, parameters.iY
  if type(x) ~= "number" or type(y) ~= "number" or x ~= x or y ~= y
    or x < 0 or y < 0 or x % 1 ~= 0 or y % 1 ~= 0 then
    return
  end
  local city = CityManager.GetCityAt(x, y)
  if city == nil or city:GetOwner() ~= player_id then
    return
  end
  TXHBalanceBCY.RecalculateMapYield(parameters.iX, parameters.iY)
end

-- No RNG keeps a ledger on the city center plot: how many +1/-1 corrections
-- of each yield BCY has attached to the city that owns it.
--
-- In a gameplay script plot:GetYield() is the tile's own yield (terrain,
-- feature, resources the owner can see, adjacent natural wonders, yields left
-- by disasters). Modifiers attached to the city never show up in it; only the
-- UI context sees them (in game: a snow city center reads 0/0 here and 3/1 in
-- the UI). The city center gets that yield raised to the base guarantee
-- (2 food, 1 production), plus the attached corrections. So each
-- recalculation attaches target - guaranteed tile yield - ledger. What it
-- attaches never changes its own input, so repeating it adds nothing.
local LEDGER_VERSION = 2
local LEDGER_VERSION_PROPERTY = "TXH_BCY_LEDGER_VERSION"
local LEDGER_OWNER_PROPERTY = "TXH_BCY_LEDGER_OWNER"
local LEDGER_CITY_PROPERTY = "TXH_BCY_LEDGER_CITY"
local LEGACY_HIDDEN_RESOURCE_PROPERTY = "TXH_BCY_LEGACY_HIDDEN_RESOURCE"
local GAME_LEDGER_PROPERTY = "TXH_BCY_NO_RNG_LEDGER_VERSION"
-- 13_runtime_support.sql defines only MODIFIER_CITY_REMOVE_1..20_EXTRA_*.
local LEGACY_REMOVAL_LIMIT = 20

-- GetProperty returns no value at all for a key that was never set. Passed
-- straight into tonumber() that raises "value expected", so assign it first.
local function read_number(object, key)
  local value = object:GetProperty(key)
  return tonumber(value)
end

local function runtime_property(yield_id)
  return "TXH_BCY_NET_" .. GameInfo.Yields[yield_id].YieldType
end

local function legacy_hidden_property(yield_id)
  return "TXH_BCY_LEGACY_HIDDEN_" .. GameInfo.Yields[yield_id].YieldType
end

local function owner_sees_resource(player, resource_info)
  if resource_info.PrereqTech ~= nil then
    local tech = GameInfo.Technologies[resource_info.PrereqTech]
    if tech ~= nil and not player:GetTechs():HasTech(tech.Index) then
      return false
    end
  end
  if resource_info.PrereqCivic ~= nil then
    local civic = GameInfo.Civics[resource_info.PrereqCivic]
    if civic ~= nil and not player:GetCulture():HasCivic(civic.Index) then
      return false
    end
  end
  return true
end

-- Cities founded by an earlier version can carry founding bonuses that apply
-- only while the owner cannot see the tile's strategic resource. The game
-- switches them off when the resource is revealed.
local function legacy_hidden_correction(plot, player, yield_id)
  local count = read_number(plot, legacy_hidden_property(yield_id)) or 0
  if count == 0 then
    return 0
  end
  local resource_type = plot:GetProperty(LEGACY_HIDDEN_RESOURCE_PROPERTY)
  local resource_info = nil
  if resource_type ~= nil then
    resource_info = GameInfo.Resources[resource_type]
  end
  if resource_info == nil or owner_sees_resource(player, resource_info) then
    return 0
  end
  return count
end

-- Compare by ID: two lookups of the same city need not return one object.
local function is_capital(player, city)
  local capital = player:GetCities():GetCapitalCity()
  return capital ~= nil and capital:GetID() == city:GetID()
end

local function ledger_binding(plot, city)
  local version = read_number(plot, LEDGER_VERSION_PROPERTY)
  local bound = version ~= nil
    and read_number(plot, LEDGER_OWNER_PROPERTY) == city:GetOwner()
    and read_number(plot, LEDGER_CITY_PROPERTY) == city:GetID()
  return bound, version
end

local function start_ledger(plot, city)
  for i = 0, 5 do
    plot:SetProperty(runtime_property(i), 0)
    plot:SetProperty(legacy_hidden_property(i), 0)
  end
  plot:SetProperty(LEGACY_HIDDEN_RESOURCE_PROPERTY, nil)
  plot:SetProperty(LEDGER_VERSION_PROPERTY, LEDGER_VERSION)
  plot:SetProperty(LEDGER_OWNER_PROPERTY, city:GetOwner())
  plot:SetProperty(LEDGER_CITY_PROPERTY, city:GetID())
end

local function bind_runtime_ledger(plot, city)
  local bound, version = ledger_binding(plot, city)
  if not bound then
    -- No ledger yet, or one left by a former city on this plot (captured, or
    -- razed and founded again): none of those corrections belong to this city.
    start_ledger(plot, city)
  elseif version < LEDGER_VERSION then
    -- Version 1 counted exactly the runtime corrections it attached.
    plot:SetProperty(LEDGER_VERSION_PROPERTY, LEDGER_VERSION)
  end
end

function TXHBalanceBCY.RecalculateMapYield(x, y)
  if TXHBalanceBCY.GetMode() == -1 or TXHBalanceBCY.GetYieldMode() ~= 1 then
    return
  end
  local city = CityManager.GetCityAt(x, y)
  if city == nil then
    return
  end

  local player = Players[city:GetOwner()]
  if player == nil then
    return
  end
  if TXHBalanceBCY.GetMode() == 1 and not is_capital(player, city) then
    return
  end

  local plot = Map.GetPlot(x, y)
  if plot == nil then
    return
  end

  local control_table = TXHBalanceBCY.GetControlTableName(plot:GetTerrainType())
  if control_table == nil then
    return
  end

  local key = tostring(city:GetOwner()) .. ":" .. tostring(city:GetID())
  if state.recalculating[key] then
    return
  end
  state.recalculating[key] = true
  local ok, message = pcall(function()
    bind_runtime_ledger(plot, city)
    for i = 0, 5 do
      local property = runtime_property(i)
      local net = read_number(plot, property) or 0
      local tile_yield = plot:GetYield(i)
      local center_yield = math.max(state.base_guaranteed_yields[i], tonumber(tile_yield) or 0)
      local applied = net + legacy_hidden_correction(plot, player, i)
      local delta = GameInfo[control_table][i].Amount - center_yield - applied
      if delta ~= 0 then
        local direction = delta > 0 and "ADD" or "REMOVE"
        local amount = delta > 0 and 1 or -1
        local modifier = "TXH_BCY_RUNTIME_" .. direction .. "_" .. GameInfo.Yields[i].YieldType .. "_BBCC"
        for _ = 1, math.abs(delta) do
          city:AttachModifierByID(modifier)
          net = net + amount
          plot:SetProperty(property, net)
        end
      end
    end
  end)
  state.recalculating[key] = nil
  if not ok then
    error(message)
  end
end

function TXHBalanceBCY.RefreshPlayerCities(player_id)
  if type(player_id) ~= "number" or Players[player_id] == nil then
    return
  end
  for _, city in Players[player_id]:GetCities():Members() do
    if city:GetOwner() == player_id then
      TXHBalanceBCY.RecalculateMapYield(city:GetX(), city:GetY())
    end
  end
end

function TXHBalanceBCY.OnCityBuiltNoRng(player_id, city_id, x, y)
  TXHBalanceBCY.RecalculateMapYield(x, y)
end

local function adopt_existing_founding_bonuses()
  -- Loading an old game cannot reconstruct its original founding conditions or
  -- modifier counts. Adopt existing cities without replaying their old bonuses.
  for _, player in ipairs(PlayerManager.GetAlive()) do
    local cities = player:GetCities()
    if cities ~= nil then
      for _, city in cities:Members() do
        if city:GetProperty(FOUNDING_BONUS_PROPERTY) == nil then
          city:SetProperty(FOUNDING_BONUS_PROPERTY, 1)
        end
      end
    end
  end
end

local function has_legacy_no_rng_traces(plot)
  for i = 0, 5 do
    local removed = plot:GetProperty(TXHBalanceBCY.ExtraYieldPropertyName(i))
    local peak = plot:GetProperty(TXHBalanceBCY.FiraxisYieldPropertyName(i))
    if removed ~= nil or peak ~= nil then
      return true
    end
  end
  return false
end

-- Count the corrections an earlier version left on an existing city, so the
-- first recalculation attaches only the remaining difference.
local function adopt_legacy_no_rng_city(player, city, plot, founded_with_package)
  local bound, version = ledger_binding(plot, city)
  if bound then
    if version < LEDGER_VERSION then
      plot:SetProperty(LEDGER_VERSION_PROPERTY, LEDGER_VERSION)
    end
    return
  end

  start_ledger(plot, city)
  for i = 0, 5 do
    -- Numbered removals; IDs above 20 never existed, so they changed nothing.
    local removed = read_number(plot, TXHBalanceBCY.ExtraYieldPropertyName(i)) or 0
    removed = math.max(0, math.min(LEGACY_REMOVAL_LIMIT, math.floor(removed)))
    plot:SetProperty(runtime_property(i), -removed)
    plot:SetProperty(TXHBalanceBCY.ExtraYieldPropertyName(i), nil)
    plot:SetProperty(TXHBalanceBCY.FiraxisYieldPropertyName(i), nil)
  end

  -- The founding package was never recorded. It went to every city its owner
  -- founded; under Capital Only, only to a player's first city.
  if not founded_with_package or city:GetOriginalOwner() ~= city:GetOwner() then
    return
  end
  if TXHBalanceBCY.GetMode() == 1 and not is_capital(player, city) then
    return
  end
  local context = plot_context(plot, {0, 1})
  if context == nil then
    return
  end
  local package, resource_type = legacy_founding_package(context)
  for i = 0, 1 do
    local property = runtime_property(i)
    plot:SetProperty(property, (read_number(plot, property) or 0) + package[i].base)
    if package[i].strategic > 0 and resource_type ~= nil then
      plot:SetProperty(legacy_hidden_property(i), package[i].strategic)
      plot:SetProperty(LEGACY_HIDDEN_RESOURCE_PROPERTY, resource_type)
    end
  end
end

local function adopt_legacy_no_rng_cities()
  -- Runs once per game: a game started or already migrated by this version
  -- carries the marker, and its cities without a ledger have no corrections.
  local migrated = Game:GetProperty(GAME_LEDGER_PROPERTY)
  if migrated ~= nil then
    return
  end

  local entries = {}
  -- Only the earlier BBG-style version left these properties, and it also
  -- attached the founding package. Version 1 never got far enough to do either.
  local founded_with_package = false
  for _, player in ipairs(PlayerManager.GetAlive()) do
    local cities = player:GetCities()
    if cities ~= nil then
      for _, city in cities:Members() do
        local plot = Map.GetPlot(city:GetX(), city:GetY())
        if plot ~= nil and TXHBalanceBCY.GetControlTableName(plot:GetTerrainType()) ~= nil then
          entries[#entries + 1] = {player = player, city = city, plot = plot}
          founded_with_package = founded_with_package or has_legacy_no_rng_traces(plot)
        end
      end
    end
  end

  for _, entry in ipairs(entries) do
    adopt_legacy_no_rng_city(entry.player, entry.city, entry.plot, founded_with_package)
  end
  Game:SetProperty(GAME_LEDGER_PROPERTY, LEDGER_VERSION)
end

function TXHBalanceBCY.Initialize()
  TXHBalanceBCY.PopulateTerrainYields()
  TXHBalanceBCY.PopulateResourceYields()
  TXHBalanceBCY.PopulateFeatureYields()

  local mode = TXHBalanceBCY.GetMode()
  local yield_mode = TXHBalanceBCY.GetYieldMode()

  if mode ~= -1 then
    if yield_mode == 0 or yield_mode == 2 then
      adopt_existing_founding_bonuses()
    end
    if yield_mode == 1 then
      GameEvents.CityBuilt.Add(TXHBalanceBCY.OnCityBuiltNoRng)
    elseif yield_mode == 2 then
      GameEvents.CityBuilt.Add(TXHBalanceBCY.OnCityBuiltLegacy)
    elseif yield_mode == 0 then
      GameEvents.CityBuilt.Add(TXHBalanceBCY.OnCityBuiltStandard)
    end

    if yield_mode == 1 then
      GameEvents.GameplayBCYAdjustCityYield.Add(TXHBalanceBCY.OnGameplayAdjustCityYield)
      -- AI and remote players do not rely on operations sent by a local UI.
      -- This also refreshes loaded games and newly reassigned capitals.
      GameEvents.PlayerTurnStarted.Add(TXHBalanceBCY.RefreshPlayerCities)
      -- Last, so the handlers above stay registered even if this fails.
      adopt_legacy_no_rng_cities()
    end
  end
end

TXHBalanceBCY.Initialize()
