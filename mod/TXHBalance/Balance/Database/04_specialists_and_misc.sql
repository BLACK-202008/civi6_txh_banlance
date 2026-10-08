-- =========================================================
-- 其他平衡项、专家产出与悬园增强
-- Miscellaneous balance, specialists, and Hanging Gardens changes
-- =========================================================

-- 悬园增强：本城住房 +1，6 格内城市住房 +1。
UPDATE Buildings
SET Housing = 1
WHERE BuildingType = 'BUILDING_HANGING_GARDENS';

INSERT OR IGNORE INTO BuildingModifiers (BuildingType, ModifierId)
VALUES ('BUILDING_HANGING_GARDENS', 'HANGING_GARDENS_REGIONAL_HOUSING');

INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
VALUES ('HANGING_GARDENS_REGIONAL_HOUSING', 'MODIFIER_PLAYER_CITIES_ADJUST_BUILDING_HOUSING', 'HANGING_GARDENS_REGIONAL_HOUSING_REQUIREMENTS');

INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('HANGING_GARDENS_REGIONAL_HOUSING', 'Amount', '1');

INSERT OR IGNORE INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('HANGING_GARDENS_REGIONAL_HOUSING_REQUIREMENTS', 'REQUIREMENTSET_TEST_ANY');

INSERT OR IGNORE INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES ('HANGING_GARDENS_REGIONAL_HOUSING_REQUIREMENTS', 'REQUIRES_PLOT_HAS_HANGING_GARDENS_WITHIN_6');

INSERT OR IGNORE INTO Requirements (RequirementId, RequirementType)
VALUES ('REQUIRES_PLOT_HAS_HANGING_GARDENS_WITHIN_6', 'REQUIREMENT_PLOT_ADJACENT_BUILDING_TYPE_MATCHES');

INSERT OR IGNORE INTO RequirementArguments (RequirementId, Name, Value)
VALUES ('REQUIRES_PLOT_HAS_HANGING_GARDENS_WITHIN_6', 'BuildingType', 'BUILDING_HANGING_GARDENS');

INSERT OR IGNORE INTO RequirementArguments (RequirementId, Name, Value)
VALUES ('REQUIRES_PLOT_HAS_HANGING_GARDENS_WITHIN_6', 'MaxRange', '6');

INSERT OR IGNORE INTO RequirementArguments (RequirementId, Name, Value)
VALUES ('REQUIRES_PLOT_HAS_HANGING_GARDENS_WITHIN_6', 'MinRange', '0');

-- 其他平衡项。
UPDATE Buildings SET PrereqCivic='CIVIC_DRAMA_POETRY' WHERE BuildingType='BUILDING_GREAT_LIBRARY';
UPDATE Improvement_YieldChanges SET YieldChange=1 WHERE ImprovementType='IMPROVEMENT_FISHING_BOATS' AND YieldType='YIELD_PRODUCTION';

-- 专家产出增强。
UPDATE District_CitizenYieldChanges SET YieldChange=6 WHERE YieldType='YIELD_GOLD' AND DistrictType='DISTRICT_COMMERCIAL_HUB';
UPDATE District_CitizenYieldChanges SET YieldChange=6 WHERE YieldType='YIELD_GOLD' AND DistrictType='DISTRICT_SUGUBA';
UPDATE District_CitizenYieldChanges SET YieldChange=3 WHERE YieldType='YIELD_PRODUCTION' AND DistrictType='DISTRICT_INDUSTRIAL_ZONE';
UPDATE District_CitizenYieldChanges SET YieldChange=3 WHERE YieldType='YIELD_PRODUCTION' AND DistrictType='DISTRICT_HANSA';
UPDATE District_CitizenYieldChanges SET YieldChange=3 WHERE YieldType='YIELD_PRODUCTION' AND DistrictType='DISTRICT_OPPIDUM';
UPDATE District_CitizenYieldChanges SET YieldChange=5 WHERE YieldType='YIELD_GOLD' AND DistrictType='DISTRICT_HARBOR';
UPDATE District_CitizenYieldChanges SET YieldChange=5 WHERE YieldType='YIELD_GOLD' AND DistrictType='DISTRICT_ROYAL_NAVY_DOCKYARD';
UPDATE District_CitizenYieldChanges SET YieldChange=5 WHERE YieldType='YIELD_GOLD' AND DistrictType='DISTRICT_COTHON';
UPDATE District_CitizenYieldChanges SET YieldChange=2 WHERE YieldType='YIELD_PRODUCTION' AND DistrictType='DISTRICT_ENCAMPMENT';
UPDATE District_CitizenYieldChanges SET YieldChange=2 WHERE YieldType='YIELD_PRODUCTION' AND DistrictType='DISTRICT_THANH';
UPDATE District_CitizenYieldChanges SET YieldChange=2 WHERE YieldType='YIELD_PRODUCTION' AND DistrictType='DISTRICT_IKANDA';
