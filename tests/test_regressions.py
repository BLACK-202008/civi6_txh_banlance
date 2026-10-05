"""SQLite execution and Lua gameplay regressions; no game installation needed."""

from pathlib import Path
import re
import shutil
import sqlite3
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT / "TXHBalance"


def database():
    db = sqlite3.connect(":memory:")
    db.executescript("""
        CREATE TABLE Units (UnitType TEXT PRIMARY KEY, Cost INT, Combat INT,
            RangedCombat INT, PrereqTech TEXT, PrereqCivic TEXT,
            BaseSightRange INT, BaseMoves INT, Range INT);
        CREATE TABLE Buildings (BuildingType TEXT PRIMARY KEY, Cost INT, Housing INT);
        CREATE TABLE Building_YieldChanges (BuildingType TEXT, YieldType TEXT, YieldChange INT);
        CREATE TABLE Districts (DistrictType TEXT, Cost INT);
        CREATE TABLE BuildingModifiers (BuildingType TEXT, ModifierId TEXT, PRIMARY KEY(BuildingType, ModifierId));
        CREATE TABLE Modifiers (ModifierId TEXT PRIMARY KEY, ModifierType TEXT,
            SubjectRequirementSetId TEXT, Repeatable INT DEFAULT 0);
        CREATE TABLE ModifierArguments (ModifierId TEXT, Name TEXT, Value TEXT, PRIMARY KEY(ModifierId, Name));
        CREATE TABLE Requirements (RequirementId TEXT PRIMARY KEY, RequirementType TEXT, Inverse INT DEFAULT 0);
        CREATE TABLE RequirementArguments (RequirementId TEXT, Name TEXT, Value TEXT, PRIMARY KEY(RequirementId, Name));
        CREATE TABLE RequirementSets (RequirementSetId TEXT PRIMARY KEY, RequirementSetType TEXT);
        CREATE TABLE RequirementSetRequirements (RequirementSetId TEXT, RequirementId TEXT, PRIMARY KEY(RequirementSetId, RequirementId));
        CREATE TABLE Resources (ResourceType TEXT, ResourceClassType TEXT);
        CREATE TABLE DynamicModifiers (ModifierType TEXT PRIMARY KEY, CollectionType TEXT, EffectType TEXT);
        INSERT INTO DynamicModifiers VALUES
            ('MODIFIER_PLAYER_CITIES_ADJUST_BUILDING_HOUSING', 'COLLECTION_PLAYER_CITIES', 'EFFECT_ADJUST_BUILDING_HOUSING'),
            ('MODIFIER_CITY_OWNER_ADJUST_BUILDING_HOUSING', 'COLLECTION_OWNER_CITY', 'EFFECT_ADJUST_BUILDING_HOUSING');
    """)
    return db


def execute(db, relative):
    db.executescript((MOD / relative).read_text(encoding="utf-8-sig"))


class DatabaseRegressions(unittest.TestCase):
    def setUp(self):
        self.db = database()
        self.addCleanup(self.db.close)

    def test_unit_updates_execute_instead_of_becoming_comments(self):
        # Catches the lost newline between SQL comments and executable UPDATEs.
        sql = (MOD / "Balance/Database/01_units_and_prereqs.sql").read_text(encoding="utf-8-sig")
        units = set(re.findall(r"WHERE UnitType='([^']+)'", sql))
        self.db.executemany("INSERT INTO Units VALUES (?, -1, -1, -1, 'OLD', NULL, -1, -1, -1)", [(unit,) for unit in units])
        execute(self.db, "Balance/Database/01_units_and_prereqs.sql")
        for unit, want in [
            ("UNIT_MACHINE_GUN", (430, 60, 70, "TECH_REPLACEABLE_PARTS")),
            ("UNIT_CUIRASSIER", (-1, -1, -1, "TECH_MILITARY_SCIENCE")),
            ("UNIT_QUADRIREME", (-1, 25, 35, "OLD")),
        ]:
            with self.subTest(unit=unit):
                got = self.db.execute("SELECT Cost,Combat,RangedCombat,PrereqTech FROM Units WHERE UnitType=?", (unit,)).fetchone()
                self.assertEqual(got, want)

    def test_hussar_technology_replaces_its_original_civic_requirement(self):
        # A technology move must remove Poland's existing Mercantilism gate.
        self.db.execute("INSERT INTO Units VALUES ('UNIT_POLISH_HUSSAR', 330, 64, 0, NULL, 'CIVIC_MERCANTILISM', 2, 4, 0)")
        execute(self.db, "Balance/Database/01_units_and_prereqs.sql")
        self.assertEqual(self.db.execute("SELECT PrereqTech,PrereqCivic FROM Units WHERE UnitType='UNIT_POLISH_HUSSAR'").fetchone(), ("TECH_MILITARY_SCIENCE", None))

    def test_granary_housing_targets_only_the_buildings_own_city(self):
        # Executes the actual binding and resolves its collection through DB data.
        execute(self.db, "Balance/Database/03_economy_and_infrastructure.sql")
        row = self.db.execute("""SELECT d.CollectionType,a.Value
            FROM BuildingModifiers b JOIN Modifiers m USING(ModifierId)
            JOIN DynamicModifiers d USING(ModifierType)
            JOIN ModifierArguments a USING(ModifierId)
            WHERE b.BuildingType='BUILDING_GRANARY' AND a.Name='Amount'""").fetchone()
        self.assertEqual(row, ("COLLECTION_OWNER_CITY", "1"))


class LuaRegressions(unittest.TestCase):
    def test_real_gameplay_and_ui_scripts_with_sql_defined_effects(self):
        lua = shutil.which("lua")
        self.assertIsNotNone(lua, "Lua 5.3+ is required to run the gameplay regression fixture")
        db = database()
        self.addCleanup(db.close)
        execute(db, "BCY/Database/10_config_values.sql")
        execute(db, "BCY/Database/11_core_rules.sql")
        execute(db, "BCY/Database/13_runtime_support.sql")
        rows = db.execute("""SELECT m.ModifierId,y.Value,a.Value
            FROM Modifiers m JOIN ModifierArguments y USING(ModifierId)
            JOIN ModifierArguments a USING(ModifierId)
            WHERE y.Name='YieldType' AND a.Name='Amount'""").fetchall()
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", suffix=".lua", dir=ROOT / "tests", delete=False) as handle:
            effects = Path(handle.name)
            handle.write("return {\n" + "\n".join(f'["{name}"]={{yield="{yield_type}",amount={amount}}},' for name, yield_type, amount in rows) + "\n}\n")
        try:
            result = subprocess.run([lua, str(ROOT / "tests/test_bcy_runtime.lua"), str(MOD), str(effects)], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            print(result.stdout.strip())
        finally:
            effects.unlink()


if __name__ == "__main__":
    unittest.main(verbosity=2)
