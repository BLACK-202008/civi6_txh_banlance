TXHBalanceBCY = TXHBalanceBCY or {}

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

  local state = TXHBalanceBCY.State
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

