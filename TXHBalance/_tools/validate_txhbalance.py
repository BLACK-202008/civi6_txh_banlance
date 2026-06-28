from __future__ import annotations

import sys
from collections import Counter
from pathlib import Path
import xml.etree.ElementTree as ET


MOD_ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "TXHBalance.modinfo",
    "README.md",
    "TXHBalance_Units.dep",
    "ArtDefs/Units.artdef",
    "Balance/Database/01_units_and_prereqs.sql",
    "Balance/Database/02_siege_rules_and_policies.sql",
    "Balance/Database/03_economy_and_infrastructure.sql",
    "Balance/Database/04_specialists_and_misc.sql",
    "Balance/Database/05_civilization_traits.sql",
    "Balance/Database/06_leader_projects.sql",
    "Balance/Text/balance_text.xml",
    "BCY/Config/options.xml",
    "BCY/Database/10_config_values.sql",
    "BCY/Database/11_core_rules.sql",
    "BCY/Database/12_no_rng_rules.sql",
    "BCY/Database/13_runtime_support.sql",
    "BCY/Database/14_capital_only.sql",
    "BCY/Scripts/bcy_lookup.lua",
    "BCY/Scripts/bcy_city_built.lua",
    "BCY/Scripts/bcy_recalculate.lua",
    "BCY/Scripts/bcy_init.lua",
    "Scripts/txh_bcy_gameplay.lua",
    "Scripts/txh_bcy_bridge.lua",
    "Scripts/txh_bcy_bridge.xml",
    "NewUnits/Database/new_units_gameplay.xml",
    "NewUnits/Text/new_units_text.xml",
    "NewUnits/UI/new_units_icons.xml",
    "Compat/Text/pen_wonder_compat.xml",
]

DISALLOWED_MODINFO_REFERENCES = {
    "database.sql",
    "text.xml",
    "txh_new_units_gameplay.xml",
    "txh_new_units_icons.xml",
    "Config/txh_bcy_config.xml",
    "Text/text_pen_wonder_compat.xml",
    "BCY/bbcc_configvalues.sql",
    "BCY/core_bbcc.sql",
    "BCY/no_rng_bbcc.sql",
    "BCY/no_rng_runtime_support.sql",
    "BCY/cap_only_bbcc.sql",
    "SQL/hanging_gardens.sql",
}

REQUIRED_LOC_KEYS = {
    "BBCC_SETTING_DESC",
    "BBCC_SETTING_NAME",
    "BBCC_SETTING_YIELD_DESC",
    "BBCC_SETTING_YIELD_NAME",
    "LOC_BBG_FRONT_BBCC_SETTING_0_DESC",
    "LOC_BBG_FRONT_BBCC_SETTING_0_NAME",
    "LOC_BBG_FRONT_BBCC_SETTING_1_DESC",
    "LOC_BBG_FRONT_BBCC_SETTING_1_NAME",
    "LOC_BBG_FRONT_BBCC_SETTING_M1_DESC",
    "LOC_BBG_FRONT_BBCC_SETTING_M1_NAME",
    "LOC_BBG_FRONT_BBCC_SETTING_YIELD_0_DESC",
    "LOC_BBG_FRONT_BBCC_SETTING_YIELD_0_NAME",
    "LOC_BBG_FRONT_BBCC_SETTING_YIELD_1_DESC",
    "LOC_BBG_FRONT_BBCC_SETTING_YIELD_1_NAME",
    "LOC_BBG_FRONT_BBCC_SETTING_YIELD_2_DESC",
    "LOC_BBG_FRONT_BBCC_SETTING_YIELD_2_NAME",
    "LOC_BUILDING_HANGING_GARDENS_DESCRIPTION",
    "LOC_BUILDING_PALGUM_DESCRIPTION",
    "LOC_BUILDING_WATER_MILL_DESCRIPTION",
    "LOC_IMPROVEMENT_FISHING_BOATS_DESCRIPTION",
    "LOC_POLICY_HARD_SHELL_EXPLOSIVES_DESCRIPTION",
    "LOC_POLICY_HARD_SHELL_EXPLOSIVES_NAME",
    "LOC_POLICY_SIEGE_DESCRIPTION",
    "LOC_POLICY_SIEGE_NAME",
    "LOC_POLICY_TRENCH_WARFARE_DESCRIPTION",
    "LOC_POLICY_TRENCH_WARFARE_NAME",
    "LOC_PROJECT_LIJIA_FAITH_DESCRIPTION",
    "LOC_PROJECT_LIJIA_FOOD_DESCRIPTION",
    "LOC_PROJECT_LIJIA_GOLD_DESCRIPTION",
    "LOC_SIEGE_RANGED_DEFENSE_DESCRIPTION",
    "LOC_TRAIT_CIVILIZATION_BABYLON_DESCRIPTION",
    "LOC_TRAIT_LEADER_YONGLE_DESCRIPTION",
    "LOC_TRAIT_LEADER_YONGLE_XP_DESCRIPTION",
    "LOC_UNIT_AIRCRAFT_CARRIER_PRO_DESCRIPTION",
    "LOC_UNIT_AIRCRAFT_CARRIER_PRO_NAME",
    "LOC_UNIT_CHINESE_CROUCHING_TIGER_DESCRIPTION",
    "LOC_UNIT_MACHINE_GUN_PRO_DESCRIPTION",
    "LOC_UNIT_MACHINE_GUN_PRO_NAME",
}

SPOT_CHECKS = {
    "UNIT_MACHINE_GUN update present": [
        "Balance/Database/01_units_and_prereqs.sql",
        "UNIT_MACHINE_GUN",
    ],
    "UNIT_TREBUCHET siege tuning present": [
        "Balance/Database/02_siege_rules_and_policies.sql",
        "UNIT_TREBUCHET",
    ],
    "WATER_MILL production rules present": [
        "Balance/Database/03_economy_and_infrastructure.sql",
        "TXH_WATERMILL_PRODUCTION_FARM",
    ],
    "GRANARY housing and no-fresh-water rules present": [
        "Balance/Database/03_economy_and_infrastructure.sql",
        "TXH_GRANARY_NO_FRESH_WATER_HOUSING",
    ],
    "BABYLON trait rebalance present": [
        "Balance/Database/05_civilization_traits.sql",
        "TRAIT_CIVILIZATION_BABYLON",
    ],
    "LIJIA gold project present": [
        "Balance/Database/06_leader_projects.sql",
        "PROJECT_LIJIA_GOLD",
    ],
    "BCY entry script includes init module": [
        "Scripts/txh_bcy_gameplay.lua",
        "GameEvents.CityBuilt",
    ],
}


def fail(message: str) -> None:
    print(f"FAIL: {message}")


def ok(message: str) -> None:
    print(f"PASS: {message}")


def parse_xml(path: Path) -> ET.ElementTree:
    try:
        return ET.parse(path)
    except ET.ParseError as exc:
        raise AssertionError(f"XML parse failed for {path.relative_to(MOD_ROOT)}: {exc}") from exc


def collect_loc_keys(root: Path) -> set[str]:
    loc_keys: set[str] = set()
    for xml_path in root.rglob("*.xml"):
        tree = ET.parse(xml_path)
        if tree.getroot().find(".//LocalizedText") is None:
            continue
        for node in tree.findall(".//*[@Tag]"):
            tag = node.attrib.get("Tag")
            if tag:
                loc_keys.add(tag)
    return loc_keys


def main() -> int:
    failures: list[str] = []

    for relative_path in REQUIRED_FILES:
        if (MOD_ROOT / relative_path).exists():
            ok(f"required file exists: {relative_path}")
        else:
            failures.append(f"required file missing: {relative_path}")

    xml_paths = list(MOD_ROOT.rglob("*.xml"))
    for xml_path in xml_paths:
        try:
            parse_xml(xml_path)
            ok(f"xml parse: {xml_path.relative_to(MOD_ROOT)}")
        except AssertionError as exc:
            failures.append(str(exc))

    modinfo_path = MOD_ROOT / "TXHBalance.modinfo"
    if modinfo_path.exists():
        try:
            modinfo_tree = parse_xml(modinfo_path)
            root = modinfo_tree.getroot()

            file_nodes = root.findall(".//Files/File")
            referenced_files = [node.text for node in file_nodes if node.text]
            for relative_path in referenced_files:
                if (MOD_ROOT / relative_path).exists():
                    ok(f"modinfo file listed and present: {relative_path}")
                else:
                    failures.append(f"modinfo references missing file: {relative_path}")

            disallowed = sorted(DISALLOWED_MODINFO_REFERENCES.intersection(referenced_files))
            if disallowed:
                failures.append("modinfo still references legacy paths: " + ", ".join(disallowed))
            else:
                ok("modinfo legacy file references removed")

            action_ids = [
                node.attrib["id"]
                for node in root.findall(".//FrontEndActions/*[@id]")
                + root.findall(".//InGameActions/*[@id]")
            ]
            duplicates = [item for item, count in Counter(action_ids).items() if count > 1]
            if duplicates:
                failures.append("duplicate action ids: " + ", ".join(sorted(duplicates)))
            else:
                ok("modinfo action ids are unique")

            criteria_ids = [node.attrib["id"] for node in root.findall(".//ActionCriteria/Criteria[@id]")]
            duplicates = [item for item, count in Counter(criteria_ids).items() if count > 1]
            if duplicates:
                failures.append("duplicate criteria ids: " + ", ".join(sorted(duplicates)))
            else:
                ok("modinfo criteria ids are unique")
        except AssertionError as exc:
            failures.append(str(exc))

    current_loc_keys = collect_loc_keys(MOD_ROOT)
    missing_loc_keys = sorted(REQUIRED_LOC_KEYS - current_loc_keys)
    extra_loc_keys = sorted(current_loc_keys - REQUIRED_LOC_KEYS)

    if missing_loc_keys:
        failures.append(f"missing LOC keys: {', '.join(missing_loc_keys[:20])}")
    else:
        ok("required LOC keys preserved")

    if extra_loc_keys:
        ok(f"extra LOC keys present: {len(extra_loc_keys)}")
    else:
        ok("no unexpected extra LOC keys")

    for label, (relative_path, needle) in SPOT_CHECKS.items():
        file_path = MOD_ROOT / relative_path
        if not file_path.exists():
            failures.append(f"{label}: file missing {relative_path}")
            continue
        content = file_path.read_text(encoding="utf-8")
        if needle in content:
            ok(label)
        else:
            failures.append(f"{label}: did not find {needle!r} in {relative_path}")

    granary_sql = (MOD_ROOT / "Balance/Database/03_economy_and_infrastructure.sql").read_text(encoding="utf-8")
    granary_checks = {
        "granary food is +2": "UPDATE Building_YieldChanges SET YieldChange=2 WHERE BuildingType='BUILDING_GRANARY' AND YieldType='YIELD_FOOD';",
        "granary housing is +2": "UPDATE Buildings SET Housing=2 WHERE BuildingType='BUILDING_GRANARY';",
        "granary no-fresh-water housing requirement exists": "REQUIRES_TXH_GRANARY_CITY_NOT_FRESH_WATER",
        "granary no-fresh-water housing modifier exists": "TXH_GRANARY_NO_FRESH_WATER_HOUSING",
        "granary no-fresh-water housing amount is +1": "('TXH_GRANARY_NO_FRESH_WATER_HOUSING', 'Amount', '1')",
        "granary no-fresh-water rule uses inverse fresh water check": "('REQUIRES_TXH_GRANARY_CITY_NOT_FRESH_WATER', 'REQUIREMENT_PLOT_IS_FRESH_WATER', 1)",
    }
    for label, needle in granary_checks.items():
        if needle in granary_sql:
            ok(label)
        else:
            failures.append(f"{label}: missing {needle!r} in Balance/Database/03_economy_and_infrastructure.sql")

    if failures:
        for message in failures:
            fail(message)
        return 1

    ok("all validation checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())

