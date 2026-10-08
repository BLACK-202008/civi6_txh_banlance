-- =========================================================
-- 文明特性平衡
-- Civilization trait rebalancing
-- =========================================================

-- 巴比伦：尤里卡 88%，科研 -33%。
INSERT INTO Modifiers(ModifierId, ModifierType) VALUES
    ('BBG_TRAIT_BABYLON_EUREKA', 'MODIFIER_PLAYER_ADJUST_TECHNOLOGY_BOOST');
INSERT INTO ModifierArguments(ModifierId, Name, Value, Extra) VALUES
    ('BBG_TRAIT_BABYLON_EUREKA', 'Amount', '48', '-1');
DELETE FROM TraitModifiers WHERE TraitType='TRAIT_CIVILIZATION_BABYLON' AND ModifierID='TRAIT_EUREKA_INCREASE';
INSERT INTO TraitModifiers(TraitType, ModifierID) VALUES
    ('TRAIT_CIVILIZATION_BABYLON', 'BBG_TRAIT_BABYLON_EUREKA');

UPDATE ModifierArguments
SET Value = '-33'
WHERE ModifierId = 'TRAIT_SCIENCE_DECREASE'
  AND Name = 'Amount';
