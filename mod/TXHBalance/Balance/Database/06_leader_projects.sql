-- =========================================================
-- 领袖项目平衡
-- Leader project tuning
-- =========================================================

-- 永乐“里甲”项目收益调整。
UPDATE Project_YieldConversions
SET PercentOfProductionRate = 80
WHERE ProjectType = 'PROJECT_LIJIA_FAITH'
  AND YieldType = 'YIELD_FAITH';

UPDATE Project_YieldConversions
SET PercentOfProductionRate = 80
WHERE ProjectType = 'PROJECT_LIJIA_FOOD'
  AND YieldType = 'YIELD_FOOD';

UPDATE Project_YieldConversions
SET PercentOfProductionRate = 200
WHERE ProjectType = 'PROJECT_LIJIA_GOLD'
  AND YieldType = 'YIELD_GOLD';
