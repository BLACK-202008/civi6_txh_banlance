-- BCY gameplay 逻辑使用单文件实现，避免运行时 include 路径问题。

TXHBalanceBCY = TXHBalanceBCY or {}

local state = {
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

local function build_city_context(player_id, city_id, x, y, yield_list)
  local city = CityManager.GetCity(player_id, city_id)
  if city == nil or should_skip_city(player_id) then
    return nil
  end

  local plot = Map.GetPlot(x, y)
  if plot == nil then
    return nil
  end

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
    city = city,
    base_yields = base_yields,
    resource_id = resource_id,
    control_table = control_table,
    is_strategic_resource = is_strategic_resource,
  }
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

function TXHBalanceBCY.OnCityBuiltLegacy(player_id, city_id, x, y)
  local context = build_city_context(player_id, city_id, x, y, {0, 1})
  if context == nil then
    return
  end

  local resource_type = nil
  if context.resource_id ~= nil and context.resource_id ~= -1 and context.is_strategic_resource then
    resource_type = GameInfo.Resources[context.resource_id].ResourceType
  end

  if context.resource_id ~= nil and context.resource_id ~= -1 then
    for i = 0, 1 do
      local final_tile_yield = context.base_yields[i] + TXHBalanceBCY.GetYield("RESOURCE", context.resource_id, i)
      local guaranteed_yield = GameInfo[context.control_table][i].Amount
      local firaxis_final_yield = math.max(state.base_guaranteed_yields[i], final_tile_yield)
      local base_bonus_count = 0
      local strategic_bonus_count = 0

      if guaranteed_yield > firaxis_final_yield then
        base_bonus_count = guaranteed_yield - firaxis_final_yield
        if context.is_strategic_resource then
          local firaxis_initial_yield = math.max(state.base_guaranteed_yields[i], context.base_yields[i])
          strategic_bonus_count = firaxis_final_yield - firaxis_initial_yield
        end
      elseif context.is_strategic_resource then
        local firaxis_initial_yield = math.max(state.base_guaranteed_yields[i], context.base_yields[i])
        if firaxis_initial_yield < guaranteed_yield then
          strategic_bonus_count = guaranteed_yield - firaxis_initial_yield
        end
      end

      apply_city_built_bonus(context.city, i, base_bonus_count, strategic_bonus_count, resource_type)
    end
  else
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

function TXHBalanceBCY.OnCityBuiltStandard(player_id, city_id, x, y)
  local context = build_city_context(player_id, city_id, x, y, nil)
  if context == nil then
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
  TXHBalanceBCY.RecalculateMapYield(parameters.iX, parameters.iY)
end

function TXHBalanceBCY.RecalculateMapYield(x, y)
  local city = CityManager.GetCityAt(x, y)
  if city == nil then
    return
  end

  if TXHBalanceBCY.GetMode() == 1 and Players[city:GetOwner()]:GetCities():GetCapitalCity() ~= city then
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

  local base_tile_yields = TXHBalanceBCY.CalculateBaseYield(plot)

  for i = 0, 5 do
    local firaxis_property = TXHBalanceBCY.FiraxisYieldPropertyName(i)
    local extra_property = TXHBalanceBCY.ExtraYieldPropertyName(i)
    local firaxis_full_tile_yield = plot:GetProperty(firaxis_property)
    local extra_yield = plot:GetProperty(extra_property)

    if extra_yield == nil then
      extra_yield = 0
    end

    if firaxis_full_tile_yield == nil then
      firaxis_full_tile_yield = math.max(plot:GetYield(i), state.base_guaranteed_yields[i])
    else
      firaxis_full_tile_yield = math.max(plot:GetYield(i), firaxis_full_tile_yield)
    end
    plot:SetProperty(firaxis_property, firaxis_full_tile_yield)

    local pre_watermill_yield = math.max(base_tile_yields[i], state.base_guaranteed_yields[i])
    local extra_bcy_yield = math.max(GameInfo[control_table][i].Amount, pre_watermill_yield) - pre_watermill_yield
    local target_yield = firaxis_full_tile_yield - extra_yield + extra_bcy_yield
    local yield_diff = target_yield - GameInfo[control_table][i].Amount

    if yield_diff > 0 then
      plot:SetProperty(extra_property, yield_diff + extra_yield)
      for step = 1, yield_diff do
        local modifier_id = "MODIFIER_CITY_REMOVE_" .. tostring(extra_yield + step) .. "_" .. extra_property .. "_BBG"
        city:AttachModifierByID(modifier_id)
      end
    end
  end
end

function TXHBalanceBCY.Initialize()
  TXHBalanceBCY.PopulateTerrainYields()
  TXHBalanceBCY.PopulateResourceYields()
  TXHBalanceBCY.PopulateFeatureYields()

  local mode = TXHBalanceBCY.GetMode()
  local yield_mode = TXHBalanceBCY.GetYieldMode()

  if mode ~= -1 then
    if yield_mode == 1 or yield_mode == 2 then
      GameEvents.CityBuilt.Add(TXHBalanceBCY.OnCityBuiltLegacy)
    elseif yield_mode == 0 then
      GameEvents.CityBuilt.Add(TXHBalanceBCY.OnCityBuiltStandard)
    end

    if yield_mode == 1 then
      GameEvents.GameplayBCYAdjustCityYield.Add(TXHBalanceBCY.OnGameplayAdjustCityYield)
    end
  end
end

TXHBalanceBCY.Initialize()
