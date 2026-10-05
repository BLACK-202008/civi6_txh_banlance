-- Engine-boundary fixture: use unchanged production Lua and SQL-defined effects.
-- Does not emulate Firaxis multiplayer, rendering or asynchronous modifier timing.
local root, effectsPath = assert(arg[1]), assert(arg[2])
local effects = dofile(effectsPath)
local names = {"YIELD_FOOD", "YIELD_PRODUCTION", "YIELD_GOLD", "YIELD_SCIENCE", "YIELD_CULTURE", "YIELD_FAITH"}
local tests, failures = 0, 0

local function equal(got, want, reason)
  if got ~= want then error((reason or "unexpected result") .. ": got " .. tostring(got) .. ", want " .. tostring(want), 2) end
end
local function test(name, fn)
  tests = tests + 1
  local ok, message = pcall(fn)
  if not ok then failures = failures + 1; print("FAIL " .. name .. ": " .. message) else print("PASS " .. name) end
end
local function event()
  local e = {callbacks = {}}
  e.Add = function(fn) e.callbacks[#e.callbacks + 1] = fn end
  e.fire = function(...) for _, fn in ipairs(e.callbacks) do fn(...) end end
  return e
end

local function fixture(terrain, food, production, mode, yieldMode)
  local f = {mode = mode or 0, yieldMode = yieldMode or 1, props = {}, natural = {[0] = food, [1] = production, [2] = 0, [3] = 0, [4] = 0, [5] = 0}, attached = {}, owner = 0, cityId = 10, capital = true, requests = {}}
  f.spawned = f.yieldMode == 1
  GameConfiguration = {GetValue = function(k) return k == "BBCC_SETTING" and f.mode or f.yieldMode end}
  GameInfo = {Terrains = {[0] = {TerrainType = "TERRAIN_GRASS"}, [4] = {TerrainType = "TERRAIN_PLAINS_HILLS"}}, Resources = {}, Features = {}, Yields = {}, Flat_CutOffYieldValues = {}, Hill_CutOffYieldValues = {}}
  for i = 0, 5 do
    GameInfo.Yields[i] = {YieldType = names[i + 1]}
    GameInfo.Flat_CutOffYieldValues[i] = {Amount = ({3, 1, 0, 0, 0, 0})[i + 1]}
    GameInfo.Hill_CutOffYieldValues[i] = {Amount = ({2, 2, 0, 0, 0, 0})[i + 1]}
  end
  DB = {Query = function(sql)
    if sql == "SELECT * FROM Terrain_YieldChanges" then return {
      {TerrainType = "TERRAIN_GRASS", YieldType = "YIELD_FOOD", YieldChange = 2},
      {TerrainType = "TERRAIN_PLAINS_HILLS", YieldType = "YIELD_FOOD", YieldChange = 1},
      {TerrainType = "TERRAIN_PLAINS_HILLS", YieldType = "YIELD_PRODUCTION", YieldChange = 2},
    } end
    return {}
  end}
  f.plot = {
    GetTerrainType = function() return terrain end, GetResourceType = function() return -1 end,
    GetFeatureType = function() return -1 end, GetOwner = function() return f.owner end,
    GetProperty = function(self, k) return f.props[k] end,
    SetProperty = function(self, k, v) f.props[k] = v end,
    GetYield = function(self, i)
      local result = f.natural[i]
      if f.mode ~= 1 or f.capital then
        for _, id in ipairs(f.attached) do local e = assert(effects[id], "undefined SQL modifier " .. id); if e.yield == names[i + 1] then result = result + e.amount end end
      end
      return result
    end,
  }
  f.city = {
    GetOwner = function() return f.owner end, GetID = function() return f.cityId end,
    GetX = function() return 2 end, GetY = function() return 3 end,
    GetProperty = function(self, k) return f.props[k] end, SetProperty = function(self, k, v) f.props[k] = v end,
    AttachModifierByID = function(self, id) assert(effects[id], "undefined SQL modifier " .. id); f.attached[#f.attached + 1] = id end,
  }
  local cities = {GetCount = function() return f.spawned and 1 or 0 end,
    GetCapitalCity = function() return f.spawned and f.capital and f.city or nil end,
    Members = function() return ipairs(f.spawned and {f.city} or {}) end}
  Players = {[0] = {GetCities = function() return cities end}, [1] = {GetCities = function() return cities end}}
  PlayerManager = {GetAlive = function() return {Players[f.owner]} end}
  CityManager = {GetCity = function(owner, id) if owner == f.owner and id == f.cityId then return f.city end end, GetCityAt = function(x, y) if x == 2 and y == 3 then return f.city end end}
  Map = {GetPlot = function(x, y) if x == 2 and y == 3 then return f.plot end end}
  GameEvents = {CityBuilt = event(), GameplayBCYAdjustCityYield = event(), PlayerTurnStarted = event()}
  Events = {PlotYieldChanged = event()}
  Game = {GetLocalPlayer = function() return 0 end}
  PlayerOperations = {EXECUTE_SCRIPT = 99}
  UI = {RequestPlayerOperation = function(owner, operation, params) f.requests[#f.requests + 1] = {owner = owner, operation = operation, params = params} end}
  f.reload = function() TXHBalanceBCY = nil; dofile(root .. "/Scripts/txh_bcy_gameplay.lua") end
  f.reload()
  f.built = function() f.spawned = true; GameEvents.CityBuilt.fire(f.owner, f.cityId, 2, 3) end
  f.recalculate = function() TXHBalanceBCY.RecalculateMapYield(2, 3) end
  f.value = function(i) return f.plot:GetYield(i) end
  return f
end

test("flat founding stays at three food after duplicate yield events", function()
  local f = fixture(0, 2, 1); f.built(); f.recalculate(); f.recalculate()
  equal(f.value(0), 3); equal(f.value(1), 1)
end)
test("every repeated external increment is corrected", function()
  local f = fixture(4, 2, 2); f.built()
  for n = 1, 4 do f.natural[1] = f.natural[1] + 1; f.recalculate(); equal(f.value(1), 2, "increment " .. n) end
end)
test("correction reverses when a temporary bonus disappears", function()
  local f = fixture(4, 2, 2); f.built(); f.natural[1] = 3; f.recalculate(); f.natural[1] = 2; f.recalculate()
  equal(f.value(1), 2)
end)
test("reload and a duplicate operation do not stack corrections", function()
  local f = fixture(4, 2, 4); f.built(); f.recalculate(); local count = #f.attached
  f.reload(); f.recalculate(); f.recalculate()
  equal(f.value(1), 2); equal(#f.attached, count)
end)
test("legacy negative corrections migrate without trusting historical maximum", function()
  local f = fixture(4, 2, 3); f.attached = {"MODIFIER_CITY_REMOVE_1_EXTRA_YIELD_PRODUCTION_BBG"}
  f.props.EXTRA_YIELD_PRODUCTION = 1; f.props.FIRAXIS_YIELD_PRODUCTION = 99
  f.recalculate(); equal(f.value(1), 2); f.natural[1] = 2; f.recalculate(); equal(f.value(1), 2)
end)
test("old founding bonus is not counted a second time during migration", function()
  local f = fixture(0, 2, 1); f.attached = {"MODIFIER_CITY_GRANT_1_YIELD_FOOD_BBCC"}
  f.props.FIRAXIS_YIELD_FOOD = 3; f.recalculate(); equal(f.value(0), 3)
end)
test("production changes larger than twenty remain correctable", function()
  local f = fixture(4, 2, 30); f.recalculate(); equal(f.value(1), 2); f.natural[1] = 2; f.recalculate(); equal(f.value(1), 2)
end)
test("disabled BCY and other yield modes do not run the No RNG correction", function()
  for _, settings in ipairs({{-1, 1}, {0, 0}, {0, 2}}) do
    local f = fixture(4, 2, 5, settings[1], settings[2]); f.recalculate(); equal(f.value(1), 5)
  end
end)
test("capital restriction excludes other cities and refreshes a new capital", function()
  local f = fixture(0, 2, 1, 1, 1); f.capital = false; f.recalculate(); equal(f.value(0), 2)
  f.capital = true; GameEvents.PlayerTurnStarted.fire(0); equal(f.value(0), 3)
  f.capital = false; f.recalculate(); equal(f.value(0), 2)
end)
test("captured city does not inherit a detached owners runtime correction", function()
  local f = fixture(4, 2, 4); f.recalculate(); equal(f.value(1), 2)
  f.owner = 1; f.cityId = 21; f.attached = {}; f.natural[1] = 2; f.recalculate(); equal(f.value(1), 2)
  f.natural[1] = 3; f.recalculate(); equal(f.value(1), 2)
end)
test("gameplay rejects malformed and mismatched operation payloads", function()
  local f = fixture(4, 2, 5)
  for _, params in ipairs({{}, {iX = "bad", iY = 3}, {iX = 2, iY = 3, iOwnerId = 1}, {iX = 99, iY = 99, iOwnerId = 0}}) do
    local ok = pcall(TXHBalanceBCY.OnGameplayAdjustCityYield, 0, params); equal(ok, true); equal(f.value(1), 5)
  end
  TXHBalanceBCY.OnGameplayAdjustCityYield(1, {iX = 2, iY = 3, iOwnerId = 0}); equal(f.value(1), 5)
end)
test("turn-start gameplay refresh handles cities without a local UI request", function()
  local f = fixture(4, 2, 6); f.owner = 1; GameEvents.PlayerTurnStarted.fire(1); equal(f.value(1), 2)
  local count = #f.attached; GameEvents.PlayerTurnStarted.fire(1); equal(#f.attached, count)
end)
test("UI bridge sends only for the local owner and enabled No RNG mode", function()
  local f = fixture(4, 2, 2); dofile(root .. "/Scripts/txh_bcy_bridge.lua")
  OnBCYPlotYieldChanged(2, 3); equal(#f.requests, 1); equal(f.requests[1].owner, 0)
  f.owner = 1; OnBCYPlotYieldChanged(2, 3); equal(#f.requests, 1)
  f.owner = -1; OnBCYPlotYieldChanged(2, 3); equal(#f.requests, 1)
  f.owner = 0; f.mode = -1; OnBCYPlotYieldChanged(2, 3); equal(#f.requests, 1)
end)
test("Balanced and Maximum founding rules are preserved", function()
  for _, mode in ipairs({0, 2}) do local f = fixture(0, 2, 1, 0, mode); f.built(); equal(f.value(0), 3); equal(f.value(1), 1) end
end)

test("Balanced and Maximum duplicate founding events grant their bonus once", function()
  for _, mode in ipairs({0, 2}) do
    local f = fixture(0, 2, 1, 0, mode); f.built(); f.built()
    equal(f.value(0), 3); equal(f.value(1), 1)
  end
end)

test("founding after a context reload with retained callbacks cannot double grant", function()
  for _, mode in ipairs({0, 2}) do
    local f = fixture(0, 2, 1, 0, mode); f.reload(); f.built()
    equal(f.value(0), 3)
  end
end)

test("legacy existing cities are adopted without replaying founding bonuses", function()
  for _, mode in ipairs({0, 2}) do
    local f = fixture(0, 2, 1, 0, mode)
    f.spawned = true; f.attached = {"MODIFIER_CITY_GRANT_1_YIELD_FOOD_BBCC"}
    f.reload(); f.built(); equal(f.value(0), 3)
    local count = #f.attached; f.reload(); f.built(); equal(#f.attached, count)
  end
end)

print(string.format("%d Lua behavior cases, %d failed", tests, failures))
if failures > 0 then os.exit(1) end
