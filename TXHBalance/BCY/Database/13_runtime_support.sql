-- =========================================================
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
