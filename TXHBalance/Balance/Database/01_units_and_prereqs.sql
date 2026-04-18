-- =========================================================
-- 鍗曚綅鍩虹骞宠　涓庡墠缃鎶€璋冩暣
-- Core unit tuning and prerequisite timing changes
-- =========================================================

-- 鏈烘灙銆佽埅姣嶄笌渚﹀療杈呭姪鍗曚綅鍩虹鏁板€艰皟鏁淬€?UPDATE Units SET Cost=430,Combat=60,RangedCombat=70,PrereqTech='TECH_REPLACEABLE_PARTS' WHERE UnitType='UNIT_MACHINE_GUN';
UPDATE Units SET Cost=540,Combat=75 WHERE UnitType='UNIT_AIRCRAFT_CARRIER';
UPDATE Units SET PrereqTech='TECH_SIEGE_TACTICS' WHERE UnitType='UNIT_TREBUCHET';
UPDATE Units SET Cost=180,BaseSightRange=4,BaseMoves=3 WHERE UnitType='UNIT_OBSERVATION_BALLOON';
UPDATE Units SET Cost=300,BaseSightRange=6,BaseMoves=4 WHERE UnitType='UNIT_DRONE';
UPDATE Units SET Range='2' WHERE UnitType='UNIT_CHINESE_CROUCHING_TIGER';

-- 閲嶉獞鍏典笌鐏櫒鏃朵唬鍗曚綅瑙ｉ攣鑺傚璋冩暣銆?UPDATE Units SET PrereqTech='TECH_MILITARY_SCIENCE' WHERE UnitType='UNIT_CUIRASSIER';
UPDATE Units SET PrereqTech='TECH_MILITARY_SCIENCE' WHERE UnitType='UNIT_POLISH_HUSSAR';
UPDATE Units SET PrereqTech='TECH_MILITARY_SCIENCE' WHERE UnitType='UNIT_AMERICAN_ROUGH_RIDER';
UPDATE Units SET PrereqTech='TECH_RIFLING' WHERE UnitType='UNIT_LINE_INFANTRY';
UPDATE Units SET PrereqTech='TECH_RIFLING' WHERE UnitType='UNIT_FRENCH_GARDE_IMPERIALE';
UPDATE Units SET PrereqTech='TECH_RIFLING' WHERE UnitType='UNIT_ENGLISH_REDCOAT';
UPDATE Units SET PrereqTech='TECH_BALLISTICS' WHERE UnitType='UNIT_RANGER';
UPDATE Units SET PrereqTech='TECH_BALLISTICS' WHERE UnitType='UNIT_SCOTTISH_HIGHLANDER';
UPDATE Units SET PrereqTech='TECH_STIRRUPS' WHERE UnitType='UNIT_COURSER';
UPDATE Units SET PrereqTech='TECH_STIRRUPS' WHERE UnitType='UNIT_ETHIOPIAN_OROMO_CAVALRY';
UPDATE Units SET PrereqTech='TECH_STIRRUPS' WHERE UnitType='UNIT_HUNGARY_BLACK_ARMY';

-- 鏃╂湡娴峰啗涓庣壒鑹插崟浣嶈皟鏁淬€?UPDATE Units SET Combat=25,RangedCombat=35 WHERE UnitType='UNIT_QUADRIREME';
UPDATE Units SET Combat=25,RangedCombat=35 WHERE UnitType='UNIT_BYZANTINE_DROMON';
UPDATE Units SET Combat=50 WHERE UnitType='UNIT_JAPANESE_SAMURAI';

