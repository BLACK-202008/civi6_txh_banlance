TXHBalanceBCY = TXHBalanceBCY or {}

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

  local state = TXHBalanceBCY.State
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

  local state = TXHBalanceBCY.State
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
