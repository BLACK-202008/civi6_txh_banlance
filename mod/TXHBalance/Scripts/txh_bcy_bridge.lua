-- BCY UI bridge for the No RNG mode.

function OnBCYPlotYieldChanged(iX, iY)
  if GameConfiguration.GetValue("BBCC_SETTING") == -1 or GameConfiguration.GetValue("BBCC_SETTING_YIELD") ~= 1 then
    return
  end
  local pPlot = Map.GetPlot(iX, iY)
  if pPlot == nil then
    return
  end

  local iOwnerId = pPlot:GetOwner()
  if iOwnerId == nil or iOwnerId < 0 or iOwnerId ~= Game.GetLocalPlayer() then
    return
  end

  local pCity = CityManager.GetCityAt(iX, iY)
  if pCity == nil then
    return
  end

  if CityManager.GetCity(iOwnerId, pCity:GetID()) == nil then
    return
  end

  local kParameters = {}
  kParameters.OnStart = "GameplayBCYAdjustCityYield"
  kParameters.iOwnerId = iOwnerId
  kParameters.iX = iX
  kParameters.iY = iY
  UI.RequestPlayerOperation(iOwnerId, PlayerOperations.EXECUTE_SCRIPT, kParameters)
end

function Initialize()
  if GameConfiguration.GetValue("BBCC_SETTING") ~= -1 and GameConfiguration.GetValue("BBCC_SETTING_YIELD") == 1 then
    Events.PlotYieldChanged.Add(OnBCYPlotYieldChanged)
  end
end

Initialize()
