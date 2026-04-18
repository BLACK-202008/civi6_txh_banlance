# TXH Balance Integrated

这是一个《文明6》整合平衡模组，围绕中后期作战节奏、基础设施收益、文明特性和市中心产出规则做了一组成体系的调整，并整合了两个新单位。

## 基本信息

- 模组名称：`TXH Balance Integrated`
- 模组入口：[TXHBalance.modinfo](</C:/Users/oh_black/Desktop/code/test-civi6/civi6_txh_banlance - gpt5.4/TXHBalance/TXHBalance.modinfo>)
- 依赖扩展包：`Rise and Fall`、`Gathering Storm`
- 作者：`TXH`、`oh_black`

## 这个模组改了什么

### 1. 单位平衡与前置科技调整

以下单位的数值或前置科技被调整：

- `UNIT_MACHINE_GUN`
  - `Cost=430`
  - `Combat=60`
  - `RangedCombat=70`
  - 前置科技改为 `TECH_REPLACEABLE_PARTS`
- `UNIT_AIRCRAFT_CARRIER`
  - `Cost=540`
  - `Combat=75`
- `UNIT_TREBUCHET`
  - 前置科技改为 `TECH_SIEGE_TACTICS`
  - `Cost=160`
  - `BaseMoves=2`
  - `Bombard=48`
- `UNIT_OBSERVATION_BALLOON`
  - `Cost=180`
  - `BaseSightRange=4`
  - `BaseMoves=3`
- `UNIT_DRONE`
  - `Cost=300`
  - `BaseSightRange=6`
  - `BaseMoves=4`
- `UNIT_CHINESE_CROUCHING_TIGER`
  - `Range=2`
- `UNIT_CUIRASSIER`
  - 前置科技改为 `TECH_MILITARY_SCIENCE`
- `UNIT_POLISH_HUSSAR`
  - 前置科技改为 `TECH_MILITARY_SCIENCE`
- `UNIT_AMERICAN_ROUGH_RIDER`
  - 前置科技改为 `TECH_MILITARY_SCIENCE`
- `UNIT_LINE_INFANTRY`
  - 前置科技改为 `TECH_RIFLING`
- `UNIT_FRENCH_GARDE_IMPERIALE`
  - 前置科技改为 `TECH_RIFLING`
- `UNIT_ENGLISH_REDCOAT`
  - 前置科技改为 `TECH_RIFLING`
- `UNIT_RANGER`
  - 前置科技改为 `TECH_BALLISTICS`
- `UNIT_SCOTTISH_HIGHLANDER`
  - 前置科技改为 `TECH_BALLISTICS`
- `UNIT_COURSER`
  - 前置科技改为 `TECH_STIRRUPS`
- `UNIT_ETHIOPIAN_OROMO_CAVALRY`
  - 前置科技改为 `TECH_STIRRUPS`
- `UNIT_HUNGARY_BLACK_ARMY`
  - 前置科技改为 `TECH_STIRRUPS`
- `UNIT_QUADRIREME`
  - `Combat=25`
  - `RangedCombat=35`
- `UNIT_BYZANTINE_DROMON`
  - `Combat=25`
  - `RangedCombat=35`
- `UNIT_JAPANESE_SAMURAI`
  - `Combat=50`

### 2. 攻城体系强化

攻城线和辅助攻城单位被整体强化：

- `UNIT_SIEGE_TOWER`
  - `BaseMoves=3`
  - `Cost=80`
- `UNIT_BATTERING_RAM`
  - `BaseMoves=2`
  - `Cost=50`
  - 前置科技改为 `TECH_THE_WHEEL`
- `UNIT_CATAPULT`
  - `Cost=110`
  - `BaseMoves=2`
  - `Bombard=38`
- `UNIT_KHMER_DOMREY`
  - 前置科技改为 `TECH_SIEGE_TACTICS`
  - `Cost=160`
  - `BaseMoves=2`
  - `Range=2`
  - `Bombard=53`
  - `Combat=40`
- `UNIT_BOMBARD`
  - `Cost=260`
  - `BaseMoves=3`
  - `Bombard=58`
- `UNIT_ARTILLERY`
  - `BaseMoves=3`
  - `Cost=420`
- `UNIT_ROCKET_ARTILLERY`
  - `BaseMoves=4`
  - `Cost=650`

并且新增了攻城单位通用能力：

- `ABILITY_SIEGE_RANGED_DEFENSE`
  - 防守远程攻击时 `+10 Combat Strength`

### 3. 新增攻城生产政策卡

新增三张军事政策卡，统一强化攻城单位产能：

- `POLICY_SIEGE`
  - 解锁：`CIVIC_MILITARY_TRADITION`
  - 效果：远古、古典、中世纪攻城单位 `+50% Production`
- `POLICY_HARD_SHELL_EXPLOSIVES`
  - 解锁：`CIVIC_MEDIEVAL_FAIRES`
  - 效果：文艺复兴及更早攻城单位 `+50% Production`
- `POLICY_TRENCH_WARFARE`
  - 解锁：`CIVIC_SCORCHED_EARTH`
  - 效果：全部攻城单位 `+50% Production`

过时链：

- `POLICY_SIEGE -> POLICY_HARD_SHELL_EXPLOSIVES -> POLICY_TRENCH_WARFARE`

### 4. 建筑、区域与基础设施调整

工业区、发电厂和城市基础设施整体加强：

- `BUILDING_WORKSHOP`
  - `Cost=175`
  - 产能改为 `+4`
- `BUILDING_FACTORY`
  - `Cost=300`
  - 产能改为 `+5`
- `BUILDING_ELECTRONICS_FACTORY`
  - `Cost=150`
  - 产能改为 `+6`
- `BUILDING_POWER_PLANT`
  - `Cost=400`
  - 产能改为 `+6`
  - 科技改为 `+3`
- `BUILDING_FOSSIL_FUEL_POWER_PLANT`
  - `Cost=350`
  - 产能改为 `+5`
- `BUILDING_COAL_POWER_PLANT`
  - `Cost=300`
- `BUILDING_FOOD_MARKET`
  - 食物改为 `+6`
- `BUILDING_SHOPPING_MALL`
  - 金币改为 `+4`
- `BUILDING_GRANARY`
  - `Cost=46`
- `DISTRICT_AQUEDUCT`
  - `Cost=24`
- `DISTRICT_BATH`
  - `Cost=12`
- `DISTRICT_CANAL`
  - `Cost=54`
- `DISTRICT_DAM`
  - `Cost=40`

### 5. 水磨 / Palgum 重做

- `BUILDING_WATER_MILL`
  - 基础食物改为 `+2`
  - 删除原有基于稻米 / 小麦 / 玉米的旧 modifier
  - 改为：
    - 农场 `+1 Production`
    - 种植园 `+1 Production`
- `BUILDING_PALGUM`
  - 基础产能改为 `+3`
  - 同步获得：
    - 农场 `+1 Production`
    - 种植园 `+1 Production`

### 6. 杂项平衡调整

- `BUILDING_HANGING_GARDENS`
  - `Housing=1`
  - 6 格内城市额外 `+1 Housing`
- `BUILDING_GREAT_LIBRARY`
  - 前置市政改为 `CIVIC_DRAMA_POETRY`
- `IMPROVEMENT_FISHING_BOATS`
  - `YieldChange=+1 Production`

### 7. 专家产出调整

- `DISTRICT_COMMERCIAL_HUB` / `DISTRICT_SUGUBA`
  - 专家金币改为 `+6`
- `DISTRICT_INDUSTRIAL_ZONE` / `DISTRICT_HANSA` / `DISTRICT_OPPIDUM`
  - 专家产能改为 `+3`
- `DISTRICT_HARBOR` / `DISTRICT_ROYAL_NAVY_DOCKYARD` / `DISTRICT_COTHON`
  - 专家金币改为 `+5`
- `DISTRICT_ENCAMPMENT` / `DISTRICT_THANH` / `DISTRICT_IKANDA`
  - 专家产能改为 `+2`

### 8. 文明与领袖特性调整

- 巴比伦 `TRAIT_CIVILIZATION_BABYLON`
  - 尤里卡收益调整为 `88%`
  - 每回合科技惩罚调整为 `-33%`
- 永乐里甲项目：
  - `PROJECT_LIJIA_FAITH` -> `80% Production -> Faith`
  - `PROJECT_LIJIA_FOOD` -> `80% Production -> Food`
  - `PROJECT_LIJIA_GOLD` -> `200% Production -> Gold`

### 9. BCY 市中心产出规则

这个模组集成了 BCY 选项，并提供两个维度的前端配置：

- `BBCC_SETTING`
  - `-1`：关闭
  - `0`：所有城市
  - `1`：仅首都
- `BBCC_SETTING_YIELD`
  - `0`：平衡模式
  - `1`：无随机模式
  - `2`：最大模式

具体行为：

- 平衡模式
  - 以标准 BCY 规则补平部分平地市中心产出
- 无随机模式
  - 平地市中心固定 `3 Food / 1 Production`
  - 丘陵市中心固定 `2 Food / 2 Production`
  - 地块产出变化时动态重算
- 最大模式
  - 平地至少 `3 Food / 1 Production`
  - 丘陵至少 `2 Food / 2 Production`
  - 在保障值与实际结算值之间取高值

### 10. 新增单位

#### `UNIT_AIRCRAFT_CARRIER_PRO`

- 名称：核动力航母
- 前置科技：`TECH_TELECOMMUNICATIONS`
- `Cost=600`
- `Maintenance=7`
- `BaseMoves=4`
- `Combat=90`
- `AntiAirCombat=110`
- `AirSlots=3`
- 升级链：`UNIT_AIRCRAFT_CARRIER -> UNIT_AIRCRAFT_CARRIER_PRO`

#### `UNIT_MACHINE_GUN_PRO`

- 名称：自行火炮
- 前置科技：`TECH_ADVANCED_BALLISTICS`
- `Cost=540`
- `Maintenance=6`
- `BaseMoves=3`
- `Combat=70`
- `RangedCombat=88`
- `Range=3`
- 升级链：`UNIT_MACHINE_GUN -> UNIT_MACHINE_GUN_PRO`
- 图标头像已改为复用原版火箭炮 portrait

### 11. 兼容内容

- 当检测到 `pen_wonder_enhanced` 模组启用时：
  - 覆盖 `LOC_BUILDING_HANGING_GARDENS_DESCRIPTION`
  - 使悬园描述与兼容版本效果保持一致

## 目录说明

- `Balance/Database/`
  - 主要平衡 SQL，按主题拆分
- `Balance/Text/`
  - 共用文本与说明文字
- `BCY/Config/`
  - BCY 前端参数定义
- `BCY/Database/`
  - BCY 数据库对象和规则
- `NewUnits/Database/`
  - 新单位定义
- `NewUnits/UI/`
  - 新单位图标映射
- `NewUnits/Text/`
  - 新单位名称与描述
- `Compat/Text/`
  - 条件兼容文本
- `Scripts/txh_bcy_gameplay.lua`
  - BCY gameplay 主入口
- `Scripts/txh_bcy_bridge.lua`
  - No RNG UI 桥接

## 安装方式

1. 将整个 `TXHBalance` 文件夹放入 Civilization VI 的 `Mods` 目录。
2. 在附加内容中启用本模组。
3. 确保 `Rise and Fall` 和 `Gathering Storm` 已启用。

## 回归检查建议

建议在每次改动后至少确认以下内容：

- BCY 选项在前端高级设置中仍然显示正常
- 新单位名称、图标、升级链正常
- 水磨、Palgum、巴比伦、永乐文本描述与效果一致
- 悬园兼容文本在 `pen_wonder_enhanced` 启用时正常覆盖
- 运行 `python _tools\validate_txhbalance.py` 无报错
