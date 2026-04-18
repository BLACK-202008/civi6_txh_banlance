TXHBalanceBCY = TXHBalanceBCY or {}

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
