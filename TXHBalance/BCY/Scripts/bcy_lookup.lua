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
