-- =========================================================

-- Bidirectional runtime corrections reuse one repeatable +/-1 effect per
-- yield. Their persistent Lua net ledger has no 20-instance naming limit.
-- Keep the legacy numbered removals below so existing saves can migrate.
INSERT OR IGNORE INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId, Repeatable)
SELECT 'TXH_BCY_RUNTIME_' || direction || '_' || YieldType || '_BBCC',
       'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 'REQSET_PLOT_IS_CITY_CENTER_BBCC', 1
FROM (SELECT 'ADD' AS direction UNION ALL SELECT 'REMOVE')
CROSS JOIN Flat_CutOffYieldValues;

INSERT OR IGNORE INTO ModifierArguments(ModifierId, Name, Value)
SELECT 'TXH_BCY_RUNTIME_' || direction || '_' || YieldType || '_BBCC', 'YieldType', YieldType
FROM (SELECT 'ADD' AS direction UNION ALL SELECT 'REMOVE')
CROSS JOIN Flat_CutOffYieldValues;

INSERT OR IGNORE INTO ModifierArguments(ModifierId, Name, Value)
SELECT 'TXH_BCY_RUNTIME_' || direction || '_' || YieldType || '_BBCC', 'Amount',
       CASE WHEN direction = 'ADD' THEN 1 ELSE -1 END
FROM (SELECT 'ADD' AS direction UNION ALL SELECT 'REMOVE')
CROSS JOIN Flat_CutOffYieldValues;
-- Runtime support modifiers for BCY No RNG recalculation.
-- 预建可由 Lua 动态附加的负产出修正，用于 No RNG 模式。
-- =========================================================

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_FOOD_BBG', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 'REQSET_PLOT_IS_CITY_CENTER_BBCC'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_FOOD_BBG', 'YieldType', 'YIELD_FOOD'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_FOOD_BBG', 'Amount', '-1'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_PRODUCTION_BBG', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 'REQSET_PLOT_IS_CITY_CENTER_BBCC'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_PRODUCTION_BBG', 'YieldType', 'YIELD_PRODUCTION'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_PRODUCTION_BBG', 'Amount', '-1'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_GOLD_BBG', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 'REQSET_PLOT_IS_CITY_CENTER_BBCC'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_GOLD_BBG', 'YieldType', 'YIELD_GOLD'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_GOLD_BBG', 'Amount', '-1'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_SCIENCE_BBG', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 'REQSET_PLOT_IS_CITY_CENTER_BBCC'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_SCIENCE_BBG', 'YieldType', 'YIELD_SCIENCE'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_SCIENCE_BBG', 'Amount', '-1'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_CULTURE_BBG', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 'REQSET_PLOT_IS_CITY_CENTER_BBCC'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_CULTURE_BBG', 'YieldType', 'YIELD_CULTURE'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_CULTURE_BBG', 'Amount', '-1'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_FAITH_BBG', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 'REQSET_PLOT_IS_CITY_CENTER_BBCC'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_FAITH_BBG', 'YieldType', 'YIELD_FAITH'
FROM nums;

WITH RECURSIVE nums(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_CITY_REMOVE_' || n || '_EXTRA_YIELD_FAITH_BBG', 'Amount', '-1'
FROM nums;
