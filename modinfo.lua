local isCh = locale == "zh" or locale == "zhr"
local isRu = locale == "ru"
local isEn = not isCh and not isRu

name = isCh and "沃姆伍德技能树大修——月裔萌芽" or "Wormwood Skill Tree Overhaul - Moon Sprout"
version = "1.2.8"
description = isCh and [[
对沃姆伍德四条技能线进行了大幅度的修改。(当前版本: v1.2.8)
详细更新内容请前往创意工坊页面查看改动说明

2025.7.15
随从线：
- 我又把胡萝卜鼠和松鼠回避敌人的逻辑移除了，因为工作效率会变低
- 偷偷把随从的默认减伤率砍到 0%，希望没人发现（我觉得 50% 减伤太超模了，还是削回去吧，虽然之后打boss可能会变难
- 修复了召唤曼德拉长者时可能出现的崩溃问题

小蛾子：
- “月树疗愈”可以为小蛾子充能，充能量为治疗量的一半
- 修复了检查小蛾子时可能导致的崩溃
- 修复了在洞穴世界能够无条件充能的问题

其他调整：
- 修复了角色制作栏处可能不显示蘑菇帽配方的问题
- 增加了公牛海带茎、发芽的石果、香蕉丛、惊喜种子的合成配方
- 修正了“月树疗愈”恢复特效高度显示不正确的问题

]] or [[
Significantly modified Wormwood's four skill lines.(Current Version: v1.2.8)
For detailed update content, please visit the Workshop page to view the change description.

2025.7.15
**Pet System:**  
- Removed enemy avoidance logic from Carrats and Pikos *(was reducing work efficiency)*  
- Stealth-nerfed pet damage reduction to 0% *(50% felt OP; boss fights might get spicy!)*  

**Mothlings:**  
- "Lunar Tree Therapy" now charges Mothlings at 50% healing value  
- Fixed inspection crash bug  
- Patched unconditional charging in caves  

**QoL Tweaks:**  
- Fixed missing Mushroom Hat recipe in character crafting tabs  
- Added crafting recipes for:  
  • Bull Kelp Stalks  
  • Rock Avocado Sprouts  
  • Banana Bushes  
  • Surprise Seeds  

]]

author = "Lemonade"
forumthread = ""
icon_atlas = "modicon.xml"
icon = "modicon.tex"
dst_compatible = true
client_only_mod = false
all_clients_require_mod = true
api_version = 10
priority = -20   -- 小于 -10 (兼容永不妥协，在永不妥协加载完成后再加载本模组，覆盖永不妥协的技能设置)

local STRING_DEFAULT = (isCh and "默认") or (isRu and "По умолчан") or "Default"
local STRING_AUTO = (isCh and "自动") or (isRu and "Авто") or "Auto"

local STRING_YES = (isCh and "是") or (isRu and "Да") or "Yes"
local STRING_NO = (isCh and "否") or (isRu and "Нет") or "No"

local STRING_ON = (isCh and "启用") or (isRu and "Вкл") or "On"
local STRING_OFF = (isCh and "关闭") or (isRu and "Выкл") or "Off"

configuration_options =
{
    {
        name = "HEADER_LANGUAGE",
        label = isCh and "语言"
             or isRu and "Язык"
             or "LANGUAGE",
        options = { {description = "", data = false} },
        default = false,
    },
    {
        name = "language_setting",
        label = isCh and "语言设置" or "Language Setting",
        hover = isCh and "选择语言" or
            "Select language",
        options =
        {
            {description = STRING_AUTO, data = 0},
            {description = "简体中文", data = 1},
            {description = "Русский", data = 2},
            {description = "English", data = 3},
        },
        default = 0,
    },
    {
        name = "HEADER_MOON_TREE_BLOSSOM",
        label = isCh and "月树花"
            or isRu and "Лунный цветок"
            or "Lune Tree Blossom",
        options = { {description = "", data = false} },
        default = false,
    },
    {
        name = "moon_charged_1_time",
        label = isCh and "月树花激活状态持续时间"
            or isRu and "Длительность активации Лунного цветка"
            or "Lune Tree Blossom Duration",
        hover = isCh and "调整食用月树花后，沃姆伍德处于月树花激活状态的持续时间，默认为 30 秒。"
            or isRu and "Изменяет длительность активного состояния после употребления Лунного цветка. По умолчанию: 30 сек."
            or "Duration of Lune Tree Blossom active state after consumption. Default: 30s",
        options =
        {
            {description = "0s", data = 0},
            {description = "5s", data = 5},
            {description = "10s", data = 10},
            {description = "15s", data = 15},
            {description = "20s", data = 20},
            {description = "25s", data = 25},
            {description = STRING_DEFAULT, data = 30},
            {description = "45s", data = 45},
            {description = "60s", data = 60},
            {description = "90s", data = 90},
            {description = "120s", data = 120},
            {description = "180s", data = 180},
            {description = "240s", data = 240},
            {description = "480s", data = 480},
        },
        default = 30,
    },
    {
        name = "moon_charged_2_time",
        label = isCh and "注能月树花激活状态持续时间"
            or isRu and "Длительность активации Заряженного лунного цветка"
            or "Infused Lune Tree Blossom Dur",
        hover = isCh and "调整食用注能月树花后，沃姆伍德处于注能月树花激活状态的持续时间，默认为 30 秒。"
            or isRu and "Изменяет длительность активного состояния после употребления Заряженного лунного цветка. По умолчанию: 30 сек."
            or "Duration of Infused Lune Tree Blossom active state. Default: 30s",
        options =
        {
            {description = "0s", data = 0},
            {description = "5s", data = 5},
            {description = "10s", data = 10},
            {description = "15s", data = 15},
            {description = "20s", data = 20},
            {description = "25s", data = 25},
            {description = STRING_DEFAULT, data = 30},
            {description = "45s", data = 45},
            {description = "60s", data = 60},
            {description = "90s", data = 90},
            {description = "120s", data = 120},
            {description = "180s", data = 180},
            {description = "240s", data = 240},
            {description = "480s", data = 480},
        },
        default = 30,
    },
    {
        name = "HEADER_FARMING",
        label = isCh and "种田相关"
            or isRu and "Фермерство"
            or "FARMING",
        options = { {description = "", data = false} },
        default = false,
    },
    {
        name = "dig_penalty",
        label = isCh and "挖掘植物额外理智惩罚"
            or isRu and "Доп. штраф рассудка за выкапывание растений"
            or "Dig Plant Sanity Penalty",
        hover = isCh and "调整沃姆伍德在挖掘植物时是否受到额外 5 点理智惩罚，默认为是。"
            or isRu and "Включить дополнительный штраф рассудка (5) при выкапывании растений. По умолчанию: Вкл."
            or "Adjust whether Womwood is subject to an additional 5 sanity penalties when digging plants. Default: On.",
        options = 
        {
            {description = STRING_ON, data = true},
            {description = STRING_OFF, data = false},
        },
        default = true,
    },
    {
        name = "farming_cork_energy_consume_mult",
        label = isCh and "根脉催化桶月树花新鲜度消耗倍率"
            or isRu and "Множитель расхода свежести Лунного цветка в бочке"
            or "Lune Tree Blosson Freshness Consume Multi",
        hover = isCh and "调整使用根脉催化桶变异种子时，消耗月树花新鲜度的倍率，默认为 0.25。"
            or isRu and "Множитель расхода свежести Лунного цветка при мутации семян в каталитической бочке. По умолчанию: 0.25."
            or "Multiplier for the consumption of the freshness of the Lune Tree Blosson when using the Root Catalytic Barrel to mutate seeds. Default: 0.25.",
        options =
        {
            {description = "0", data = 0},
            {description = "0.05", data = 0.5},
            {description = "0.10", data = 0.1},
            {description = "0.15", data = 0.15},
            {description = "0.20", data = 0.2},
            {description = STRING_DEFAULT, data = 0.25},
            {description = "0.30", data = 0.3},
            {description = "0.35", data = 0.35},
            {description = "0.40", data = 0.4},
            {description = "0.45", data = 0.45},
            {description = "0.50", data = 0.5},
            {description = "0.55", data = 0.55},
            {description = "0.60", data = 0.6},
            {description = "0.65", data = 0.65},
            {description = "0.70", data = 0.7},
            {description = "0.75", data = 0.75},
            {description = "0.80", data = 0.8},
            {description = "0.85", data = 0.85},
            {description = "0.90", data = 0.9},
            {description = "0.95", data = 0.95},
            {description = "1.00", data = 1.0},
        },
        default = 0.25,
    },
    {
        name = "HEADER_PETS",
        label = isCh and "随从线"
            or isRu and "Компаньоны"
            or "Companions",
        options = { {description = "", data = false} },
        default = false,
    },
    {
        name = "pets_damage_absorb",
        label = isCh and "随从基础减伤率"
            or isRu and "Базовое поглощение урона компаньонами"
            or "Pets Basic Damage Absorption",
        hover = isCh and "调整随从的基础减伤率，默认为 0%。"
            or isRu and "Изменяет базовый процент поглощения урона компаньонами. По умолчанию: 0%."
            or "Adjust the base damage absorption of your pets. Default: 0%.",
        options =
        {
            {description = STRING_DEFAULT, data = 0},
            {description = "10%", data = 0.1},
            {description = "20%", data = 0.2},
            {description = "30%", data = 0.3},
            {description = "40%", data = 0.4},
            {description = "50%", data = 0.5},
            {description = "60%", data = 0.6},
            {description = "70%", data = 0.7},
            {description = "80%", data = 0.8},
            {description = "90%", data = 0.9},
            {description = "95%", data = 0.95},
        },
        default = 0,
    },
    {
        name = "pets_healing_multi_base",
        label = isCh and "月树疗愈治疗随从倍率"
            or isRu and "Множитель лечения компаньонов Лунным деревом"
            or "Lunar Tree Therapy Healing Multiplier",
        hover = isCh and "调整月树疗愈治疗随从倍率，默认为 5 倍。"
            or isRu and "Изменяет множитель лечения компаньонов Лунным деревом. По умолчанию: 5."
            or "Adjust the healing multiplier of Lunar Tree Therapy for pets. Default: 5.",
        options =
        {
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = STRING_DEFAULT, data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 5,
    },
    -- {
    --     name = "pets_piko_sleep_atnight",
    --     label = isCh and "异食松鼠晚上睡觉" or "Flytrap Sleep At Night",
    --     hover = isCh and "调整异食松鼠是否在白天时睡觉，默认为是。" or
    --         "Adjust whether Piko sleeps at night. Default: Yes.",
    --     options =
    --     {
    --         {description = STRING_YES, data = true},
    --         {description = STRING_NO, data = false},
    --     },
    --     default = true,
    -- },
    {
        name = "pets_flytrap_sleep_onday",
        label = isCh and "利齿捕蝇草白天睡觉"
            or isRu and "Дневной сон мухоловки"
            or "Flytrap Sleep During Daytime",
        hover = isCh and "调整利齿捕蝇草是否在白天时睡觉，如果你想看它睡觉的话。默认为否。"
            or isRu and "Спит ли мухоловка днём (если хотите посмотреть)? По умолчанию: Нет."
            or "Adjust whether Flytrap sleeps during the day if you want to watch it sleep. Default: No.",
        options =
        {
            {description = STRING_YES, data = true},
            {description = STRING_NO, data = false},
        },
        default = false,
    },
    {
        name = "pets_mandrakeman_sleep_onday",
        label = isCh and "曼德拉长者白天睡觉"
            or isRu and "Дневной сон мандрагоры"
            or "Mandrakeman Sleep During Daytime",
        hover = isCh and "调整曼德拉长者是否在白天时睡觉，如果你想看它睡觉的话。默认为否。"
            or isRu and "Спит ли мандрагора днём (если хотите посмотреть)? По умолчанию: Нет."
            or "Adjust whether Mandrakeman sleeps during the day if you want to watch it sleep. Default: No.",
        options =
        {
            {description = STRING_YES, data = true},
            {description = STRING_NO, data = false},
        },
        default = false,
    },
    {
        name = "pets_num_carrat",
        label = isCh and "胡萝卜鼠数量上限"
            or isRu and "Максимум моркокрыс"
            or "Carrat Max Count",
        hover = isCh and "调整可以创造的胡萝卜鼠的最大数量，默认为 4 个。"
            or isRu and "Максимальное количество создаваемых моркокрыс. По умолчанию: 4."
            or "Max Carrats that can be created. Default: 4",
        options =
        {
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = STRING_DEFAULT, data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 4,
    },
    {
        name = "pets_num_lightflier",
        label = isCh and "球状光虫数量上限"
            or isRu and "Максимум светляков"
            or "Bulbous Lightbug Max Count",
        hover = isCh and "调整可以创造的球状光虫的最大数量，默认为 6 个。"
            or isRu and "Максимальное количество создаваемых светляков. По умолчанию: 6."
            or "Max Bulbous Lightbug that can be created. Default: 6",
        options =
        {
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = STRING_DEFAULT, data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
            {description = "11", data = 11},
            {description = "12", data = 12},
        },
        default = 6,
    },
    {
        name = "pets_num_piko",
        label = isCh and "异食松鼠数量上限"
            or isRu and "Максимум пико"
            or "Piko Max Count",
        hover = isCh and "调整可以创造的异食松鼠的最大数量，默认为 1 个。"
            or isRu and "Максимальное количество создаваемых пико. По умолчанию: 1."
            or "Max Pikos that can be created. Default: 1",
        options =
        {
            {description = STRING_DEFAULT, data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 1,
    },
    {
        name = "pets_num_piko_orange",
        label = isCh and "橙色异食松鼠数量上限"
            or isRu and "Максимум оранжевых пико"
            or "Orange Piko Max",
        hover = isCh and "调整可以创造的橙色异食松鼠的最大数量，默认为 1 个。"
            or isRu and "Максимальное количество создаваемых оранжевых пико. По умолчанию: 1."
            or "Max Orange Pikos that can be created. Default: 1",
        options =
        {
            {description = STRING_DEFAULT, data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 1,
    },
    {
        name = "pets_num_fruitdragon",
        label = isCh and "沙拉蝾螈数量上限"
            or isRu and "Максимум саламандров"
            or "Saladmander Max",
        hover = isCh and "调整可以创造的沙拉蝾螈的最大数量，默认为 2 个。"
            or isRu and "Максимальное количество создаваемых саламандров. По умолчанию: 2."
            or "Max Saladmanders that can be created. Default: 2",
        options =
        {
            {description = "1", data = 1},
            {description = STRING_DEFAULT, data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 2,
    },
    {
        name = "pets_num_grassgator",
        label = isCh and "草鳄鱼数量上限"
            or isRu and "Максимум травяных аллигаторов"
            or "Grass Gator Max",
        hover = isCh and "调整可以创造的草鳄鱼的最大数量，默认为 1 个。"
            or isRu and "Максимальное количество создаваемых травяных аллигаторов. По умолчанию: 1."
            or "Max Grass Gators that can be created. Default: 1",
        options =
        {
            {description = STRING_DEFAULT, data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 1,
    },
    {
        name = "pets_num_flytrap",
        label = isCh and "捕蝇草数量上限"
            or isRu and "Максимум мухоловок"
            or "Flytrap Max Count",
        hover = isCh and "调整可以创造的捕蝇草的最大数量，默认为 3 个。"
            or isRu and "Максимальное количество создаваемых мухоловок. По умолчанию: 3."
            or "Max Flytraps that can be created. Default: 3",
        options =
        {
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = STRING_DEFAULT, data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 3,
    },
    {
        name = "pets_num_mandrakeman",
        label = isCh and "曼德拉长者数量上限"
            or isRu and "Максимум мандрагор"
            or "Elder Mandrake Max Count",
        hover = isCh and "调整可以创造的曼德拉长者的最大数量，默认为 4 个。"
            or isRu and "Максимальное количество создаваемых мандрагор. По умолчанию: 4."
            or "Max Elder Mandrake that can be created. Default: 4",
        options =
        {
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = STRING_DEFAULT, data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 4,
    },
    {
        name = "HEADER_MUSHROOM",
        label = isCh and "蘑菇线"
            or isRu and "Грибы"
            or "Mushroom",
        options = { {description = "", data = false} },
        default = false,
    },
    {
        name = "mushroom_buff_time",
        label = isCh and "三色蘑菇效果持续时间"
            or isRu and "Длительность эффекта триколорного гриба"
            or "Mushroom Buff Duration",
        hover = isCh and "调整食用三色蘑菇后 buff 的持续时间，默认为 30 秒。"
            or isRu and "Изменяет длительность эффекта после употребления триколорного гриба. По умолчанию: 30 сек."
            or "Duration of tri-color mushroom buff. Default: 30s",
        options =
        {
            {description = "5s", data = 5},
            {description = "10s", data = 10},
            {description = "15s", data = 15},
            {description = STRING_DEFAULT, data = 30},
            {description = "45s", data = 45},
            {description = "60s", data = 60},
            {description = "75s", data = 75},
            {description = "90s", data = 90},
            {description = "120s", data = 120},
        },
        default = 30,
    },
    {
        name = "shroomcake_buff_time",
        label = isCh and "蘑菇蛋糕效果持续时间"
            or isRu and "Длительность эффекта грибного торта"
            or "Shroomcake Buff Duration",
        hover = isCh and "调整食用蘑菇蛋糕后 buff 的持续时间，默认为 120 秒。"
            or isRu and "Изменяет длительность эффекта после употребления грибного торта. По умолчанию: 120 сек."
            or "Duration of Shroomcake buff. Default: 120s",
        options =
        {
            {description = "5s", data = 5},
            {description = "10s", data = 10},
            {description = "15s", data = 15},
            {description = "30s", data = 30},
            {description = "45s", data = 45},
            {description = "60s", data = 60},
            {description = "75s", data = 75},
            {description = "90s", data = 90},
            {description = STRING_DEFAULT, data = 120},
            {description = "150s", data = 150},
            {description = "180s", data = 180},
            {description = "240s", data = 240},
            {description = "480s", data = 480},
        },
        default = 120,
    },
    {
        name = "shroombait_buff_time",
        label = isCh and "酿夜帽效果持续时间"
            or isRu and "Длительность эффекта ночной шляпы"
            or "Shroombait Buff Duration",
        hover = isCh and "调整食用酿夜帽后 buff 的持续时间，默认为 60 秒。"
            or isRu and "Изменяет длительность эффекта после употребления ночной шляпы. По умолчанию: 60 сек."
            or "Duration of Stuffed Night Cap buff. Default: 60s",
        options =
        {
            {description = "5s", data = 5},
            {description = "10s", data = 10},
            {description = "15s", data = 15},
            {description = "30s", data = 30},
            {description = "45s", data = 45},
            {description = STRING_DEFAULT, data = 60},
            {description = "75s", data = 75},
            {description = "90s", data = 90},
            {description = "120s", data = 120},
            {description = "150s", data = 150},
            {description = "180s", data = 180},
            {description = "240s", data = 240},
            {description = "480s", data = 480},
        },
        default = 60,
    },
    {
        name = "shroombait_common_multi",
        label = isCh and "酿夜帽催眠光环对普通生物催眠倍率"
            or isRu and "Множитель гипноза ночной шляпы (обычные существа)"
            or "Shroombait: Common Hypnosis",
        hover = isCh and "调整酿夜帽催眠光环催眠普通生物的强度，默认为 5 倍。"
            or isRu and "Изменяет силу гипноза ночной шляпы для обычных существ. По умолчанию: 5x."
            or "Stuffed Night Cap Hypnosis multiplier for common creatures. Default: 5x",
        options =
        {
            {description = "0", data = 0},
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = STRING_DEFAULT, data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 5,
    },
    {
        name = "shroombait_epic_multi",
        label = isCh and "酿夜帽催眠光环对 BOSS 催眠倍率"
            or isRu and "Множитель гипноза ночной шляпы (боссы)"
            or "Shroombait: Boss Hypnosis",
        hover = isCh and "调整酿夜帽催眠光环催眠 BOSS 生物的强度，默认为 2 倍。"
            or isRu and "Изменяет силу гипноза ночной шляпы для боссов. По умолчанию: 2x."
            or "Stuffed Night Cap Hypnosis multiplier for bosses. Default: 2x",
        options =
        {
            {description = "0", data = 0},
            {description = "1", data = 1},
            {description = STRING_DEFAULT, data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 2,
    },
    {
        name = "shroombait_affect_teammate",
        label = isCh and "酿夜帽催眠队友"
            or isRu and "Ночная шляпа гипнотизирует союзников"
            or "Shroombait Affects Team",
        hover = isCh and "调整酿夜帽的效果是否影响队友，默认为否。"
            or isRu and "Влияет ли эффект ночной шляпы на союзников. По умолчанию: Нет."
            or "Whether Stuffed Night Cap affects teammates. Default: No",
        options =
        {
            {description = STRING_YES, data = true},
            {description = STRING_NO, data = false},
        },
        default = false,
    },
    {
        name = "mushroomhat_unlock_chance",
        label = isCh and "蘑菇帽解锁起始概率"
            or isRu and "Начальный шанс открытия грибной шляпы"
            or "Funcap Unlock Chance",
        hover = isCh and "调整解锁蘑菇帽的概率，默认为第一天 1%， 在 100 天内逐渐增长至 20%。"
            or isRu and "Начальный шанс открытия грибной шляпы. По умолчанию: 1% в первый день, увеличивается до 20% за 100 дней."
            or "Initial unlock chance for Funcap. Default 1% on the first day, and increases to 20% within 100 days. Default: 1%",
        options =
        {
            {description = STRING_DEFAULT, data = 0.01},
            {description = "2%", data = 0.02},
            {description = "3%", data = 0.03},
            {description = "4%", data = 0.04},
            {description = "5%", data = 0.05},
            {description = "10%", data = 0.10},
            {description = "15%", data = 0.15},
            {description = "20%", data = 0.20},
            {description = "25%", data = 0.25},
            {description = "50%", data = 0.50},
            {description = "75%", data = 0.75},
            {description = "100%", data = 1.00},
        },
        default = 0.01,
    },
    {
        name = "mushroomhat_damage_absorb",
        label = isCh and "蘑菇帽减伤率"
            or isRu and "Поглощение урона грибной шляпой"
            or "Funcap Damage Absorb",
        hover = isCh and "调整蘑菇帽吸收伤害的数值，默认为吸收 50%。"
            or isRu and "Изменяет процент поглощения урона грибной шляпой. По умолчанию: 50%."
            or "Damage absorption rate of Funcap. Default: 50%",
        options =
        {
            {description = "0%", data = 0.00},
            {description = "10%", data = 0.10},
            {description = "15%", data = 0.15},
            {description = "20%", data = 0.20},
            {description = "25%", data = 0.25},
            {description = STRING_DEFAULT, data = 0.50},
            {description = "60%", data = 0.60},
            {description = "80%", data = 0.80},
            {description = "85%", data = 0.85},
            {description = "90%", data = 0.90},
            {description = "95%", data = 0.95},
            {description = "100%", data = 1.00},
        },
        default = 0.50,
    },
    {
        name = "mushroomhat_consume_val",
        label = isCh and "三色蘑菇帽消耗开花值"
            or isRu and "Потребление очков цветения триколорной шляпой"
            or "Funcap BP Cost",
        hover = isCh and "调整食用月树花后，三色蘑菇帽每秒消耗的开花值，默认为 10。"
            or isRu and "Потребление очков цветения триколорной шляпой после употребления Лунного цветка. По умолчанию: 10 в сек."
            or "Bloom Point Cost per second for Funcap after comsuming Lune Tree Blossom. Default: 10",
        options =
        {
            {description = "0", data = 0},
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = STRING_DEFAULT, data = 10},
            {description = "11", data = 11},
            {description = "12", data = 12},
            {description = "13", data = 13},
            {description = "14", data = 14},
            {description = "15", data = 15},
            {description = "16", data = 16},
            {description = "17", data = 17},
            {description = "18", data = 18},
            {description = "19", data = 19},
            {description = "20", data = 20},
        },
        default = 10,
    },
    {
        name = "moon_mushroomhat_consume_val",
        label = isCh and "月亮蘑菇帽消耗开花值"
            or isRu and "Потребление очков цветения лунной шляпой"
            or "Lunar Funcap BP Cost",
        hover = isCh and "调整装备月亮蘑菇帽食用注能月树花后，每次攻击消耗的开花值，默认为 20。"
            or isRu and "Потребление очков цветения лунной шляпой за атаку после употребления Заряженного лунного цветка. По умолчанию: 20."
            or "Bloom Point Cost per attack for Lunar Funcap after comsuming Infused Lune Tree Blossom. Default: 20",
        options =
        {
            {description = "0", data = 0},
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "10", data = 10},
            {description = "15", data = 15},
            {description = STRING_DEFAULT, data = 20},
            {description = "25", data = 25},
            {description = "30", data = 30},
            {description = "35", data = 35},
            {description = "40", data = 40},
            {description = "45", data = 45},
            {description = "50", data = 50},
            {description = "60", data = 60},
            {description = "70", data = 70},
            {description = "80", data = 80},
            {description = "90", data = 90},
            {description = "100", data = 100},
        },
        default = 20,
    },
    {
        name = "moon_mushroomhat_buff_time",
        label = isCh and "月亮蘑菇帽每层效果持续时间"
            or isRu and "Длительность каждого эффекта лунной шляпы"
            or "Lunar Funcap Buff Stack Time",
        hover = isCh and "调整装备月亮蘑菇帽每一层孢子效果持续的时间，默认为 3s。"
            or isRu and "Длительность каждого эффекта споры лунной шляпы. По умолчанию: 3 сек."
            or "Duration per spore buff stack of Lunar Funcap. Default: 3s",
        options =
        {
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = STRING_DEFAULT, data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 3,
    },
    {
        name = "HEADER_THORNS",
        label = isCh and "荆棘线"
            or isRu and "Шипы"
            or "Bramble",
        options = { {description = "", data = false} },
        default = false,
    },
    {
        name = "bramblefx_consume_val_1",
        label = isCh and "月树花尖刺爆发消耗开花值"
            or isRu and "Расход очков цветения для шипов (Лунный цветок)"
            or "Lv.1 Bramble Husk BP Cost",
        hover = isCh and "调整装备荆棘甲时食用月树花后，每次攻击消耗的开花值，默认为 10。"
            or isRu and "Изменяет расход очков цветения при атаке в броне из шипов после употребления Лунного цветка. По умолчанию: 10."
            or "Bloom Point Cost per attack when equip Bramble Husk after consuming Lune Tree Blossom. Default: 10",
        options =
        {
            {description = "0", data = 0},
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = STRING_DEFAULT, data = 10},
            {description = "11", data = 11},
            {description = "12", data = 12},
            {description = "13", data = 13},
            {description = "14", data = 14},
            {description = "15", data = 15},
            {description = "16", data = 16},
            {description = "17", data = 17},
            {description = "18", data = 18},
            {description = "19", data = 19},
            {description = "20", data = 20},
            {description = "30", data = 30},
            {description = "40", data = 40},
            {description = "50", data = 50},
            {description = "100", data = 100},
        },
        default = 10,
    },
    {
        name = "bramblefx_consume_val_2",
        label = isCh and "注能月树花尖刺爆发消耗开花值"
            or isRu and "Расход очков цветения для шипов (Заряженный лунный цветок)"
            or "Lv.2 Bramble Husk BP Cost",
        hover = isCh and "调整装备荆棘甲时食用注能月树花后，每次攻击消耗的开花值，默认为 15。"
            or isRu and "Изменяет расход очков цветения при атаке в броне из шипов после употребления Заряженного лунного цветка. По умолчанию: 15."
            or "Bloom Point Cost per attack when equip Bramble Husk after consuming Infused Lune Tree Blossom. Default: 15",
        options =
        {
            {description = "0", data = 0},
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
            {description = "11", data = 11},
            {description = "12", data = 12},
            {description = "13", data = 13},
            {description = "14", data = 14},
            {description = STRING_DEFAULT, data = 15},
            {description = "16", data = 16},
            {description = "17", data = 17},
            {description = "18", data = 18},
            {description = "19", data = 19},
            {description = "20", data = 20},
            {description = "30", data = 30},
            {description = "40", data = 40},
            {description = "50", data = 50},
            {description = "100", data = 100},
        },
        default = 15,
    },
    {
        name = "vine_consume_val",
        label = isCh and "召唤藤蔓消耗开花值"
            or isRu and "Расход очков цветения для призыва лиан"
            or "Lunar Weapon BP Cost",
        hover = isCh and "调整装备亮茄近战武器时食用注能月树花后，每次攻击消耗的开花值，默认为 15。"
            or isRu and "Изменяет расход очков цветения при атаке лунным оружием после употребления Заряженного лунного цветка. По умолчанию: 15."
            or "Bloom Point Cost per attack to summon vines when equip Lunar Weapon after consuming Infused Lune Tree Blossom. Default: 15",
        options =
        {
            {description = "0", data = 0},
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
            {description = "11", data = 11},
            {description = "12", data = 12},
            {description = "13", data = 13},
            {description = "14", data = 14},
            {description = STRING_DEFAULT, data = 15},
            {description = "16", data = 16},
            {description = "17", data = 17},
            {description = "18", data = 18},
            {description = "19", data = 19},
            {description = "20", data = 20},
            {description = "30", data = 30},
            {description = "40", data = 40},
            {description = "50", data = 50},
            {description = "100", data = 100},
        },
        default = 15,
    },
    {
        name = "vine_chance_val",
        label = isCh and "召唤藤蔓概率"
            or isRu and "Шанс призыва лиан"
            or "Vine Summon Chance",
        hover = isCh and "调整装备亮茄近战武器时食用注能月树花后，每次攻击召唤藤蔓的概率，默认为 50%。"
            or isRu and "Изменяет шанс призыва лиан при атаке лунным оружием после употребления Заряженного лунного цветка. По умолчанию: 50%."
            or "Chance to summon vines per attack when equip Lunar Weapon after consuming Infused Lune Tree Blossom. Default: 50%",
        options =
        {
            {description = "20%", data = 0.2},
            {description = "30%", data = 0.3},
            {description = "40%", data = 0.4},
            {description = STRING_DEFAULT, data = 0.5},
            {description = "60%", data = 0.6},
            {description = "70%", data = 0.7},
            {description = "80%", data = 0.8},
            {description = "90%", data = 0.9},
            {description = "100%", data = 1.0},
        },
        default = 0.5,
    },
    {
        name = "deciduoustree_consume_val",
        label = isCh and "召唤毒桦栗树消耗开花值"
            or isRu and "Расход очков цветения для призыва ядовитого берёзового дерева"
            or "Poison Birchnut Tree BP Cost",
        hover = isCh and "调整召唤毒桦栗树消耗开花值，默认为 300。"
            or isRu and "Изменяет расход очков цветения для призыва ядовитого берёзового дерева. По умолчанию: 300."
            or "Bloom Point Cost to summon Poison Birchnut Tree after consuming Lune Tree Blossom. Default: 300",
        options =
        {
            {description = "0", data = 0},
            {description = "50", data = 50},
            {description = "100", data = 100},
            {description = "150", data = 150},
            {description = STRING_DEFAULT, data = 300},
            {description = "600", data = 600},
            {description = "900", data = 900},
            {description = "1200", data = 1200},
            {description = "1500", data = 1500},
            {description = "1800", data = 1800},
            {description = "2100", data = 2100},
            {description = "2400", data = 2400},
            {description = "2700", data = 2700},
            {description = "3000", data = 3000},
            {description = "3300", data = 3300},
        },
        default = 300,
    },
    {
        name = "deciduoustree_time",
        label = isCh and "召唤毒桦栗树持续时间"
            or isRu and "Время существования ядовитого берёзового дерева"
            or "Poison Birchnut Tree Duration",
        hover = isCh and "调整召唤的毒桦栗树可存在的时间，默认为 120 秒。"
            or isRu and "Изменяет время существования призванного ядовитого берёзового дерева. По умолчанию: 120 сек."
            or "Duration of summoned Poison Birchnut Tree. Default: 120s",
        options =
        {
            {description = "30s", data = 30},
            {description = "45s", data = 45},
            {description = "60s", data = 60},
            {description = "75s", data = 75},
            {description = "90s", data = 90},
            {description = STRING_DEFAULT, data = 120},
            {description = "150s", data = 150},
            {description = "180s", data = 180},
            {description = "210s", data = 210},
            {description = "240s", data = 240},
            {description = "270s", data = 270},
            {description = "300s", data = 300},
            {description = "330s", data = 330},
            {description = "360s", data = 360},
        },
        default = 120,
    },
    {
        name = "ivystaff_lunarplant_consume_val",
        label = isCh and "荆棘魔杖召唤亮茄消耗开花值"
            or isRu and "Расход очков цветения для призыва лунного растения жезлом"
            or "Ivy Staff BP Cost",
        hover = isCh and "调整投掷荆棘魔杖召唤亮茄时所消耗的开花值，默认为 600。"
            or isRu and "Изменяет расход очков цветения при призыве лунного растения с помощью жезла. По умолчанию: 600."
            or "Bloom Point Cost to summon Lunarplant when throwing Ivy Staff. Default: 600",
        options =
        {
            {description = "0", data = 0},
            {description = "50", data = 50},
            {description = "100", data = 100},
            {description = "150", data = 150},
            {description = "200", data = 200},
            {description = "250", data = 250},
            {description = "300", data = 300},
            {description = STRING_DEFAULT, data = 600},
            {description = "900", data = 900},
            {description = "1200", data = 1200},
            {description = "1500", data = 1500},
            {description = "1800", data = 1800},
            {description = "2100", data = 2100},
            {description = "2400", data = 2400},
            {description = "2700", data = 2700},
            {description = "3000", data = 3000},
            {description = "3300", data = 3300},
        },
        default = 600,
    },
    {
        name = "ivystaff_lunarplant_time",
        label = isCh and "荆棘魔杖召唤亮茄存在时间"
            or isRu and "Время существования лунного растения (жезл)"
            or "Ivy Staff: Lunarplant Duration",
        hover = isCh and "调整投掷荆棘魔杖召唤的亮茄可存在的时间，默认为 240 秒。"
            or isRu and "Изменяет время существования лунного растения, призванного жезлом. По умолчанию: 240 сек."
            or "Duration of summoned Lunarplant. Default: 240s",
        options =
        {
            {description = "30s", data = 30},
            {description = "45s", data = 45},
            {description = "60s", data = 60},
            {description = "75s", data = 75},
            {description = "90s", data = 90},
            {description = "120s", data = 120},
            {description = "150s", data = 150},
            {description = "180s", data = 180},
            {description = "210s", data = 210},
            {description = STRING_DEFAULT, data = 240},
            {description = "270s", data = 270},
            {description = "300s", data = 300},
            {description = "330s", data = 330},
            {description = "360s", data = 360},
        },
        default = 240,
    },
    {
        name = "HEADER_BLOOMING",
        label = isCh and "开花线"
            or isRu and "Цветение"
            or "Blooming",
        options = { {description = "", data = false} },
        default = false,
    },
    {
        name = "fertilizer_healing_multi",
        label = isCh and "高效吸收回血倍率"
            or isRu and "Множитель исцеления удобрениями"
            or "Fertilizer Heal Multi",
        hover = isCh and "调整使用堆肥和粪肥的回血倍率，默认为 1.5。"
            or isRu and "Изменяет множитель исцеления при использовании компоста и навоза. По умолчанию: 1.5."
            or "Healing multiplier for fertilizers. Default: 1.5",
        options =
        {
            {description = "1.0", data = 1.0},
            {description = STRING_DEFAULT, data = 1.5},
            {description = "2.0", data = 2.0},
            {description = "2.5", data = 2.5},
            {description = "3.0", data = 3.0},
        },
        default = 1.5,
    },
    {
        name = "photosynthesis_light_healing_multi",
        label = isCh and "光合作用日光回血倍率"
            or isRu and "Множитель исцеления от света (фотосинтез)"
            or "Photosynthesis: Light Heal Mult",
        hover = isCh and "调整在自然光和矮星下的回血倍率，默认为 1.0。"
            or isRu and "Изменяет множитель исцеления на солнце или возле карликовой звезды. По умолчанию: 1.0."
            or "Healing multiplier in sunlight or dwarf star. Default: 1.0",
        options =
        {
            {description = "0.5", data = 0.5},
            {description = STRING_DEFAULT, data = 1.0},
            {description = "1.5", data = 1.5},
            {description = "2.0", data = 2.0},
            {description = "2.5", data = 2.5},
            {description = "3.0", data = 3.0},
            {description = "4.0", data = 4.0},
            {description = "5.0", data = 5.0},
            {description = "10.0", data = 10.0},
        },
        default = 1.0,
    },
    {
        name = "photosynthesis_moisture_consume_multi",
        label = isCh and "光合作用潮湿度消耗倍率"
            or isRu and "Множитель расхода влаги (фотосинтез)"
            or "Photosynthesis: Wetness Drain Mult",
        hover = isCh and "调整潮湿度下降倍率，默认为 1.0。潮湿度越高，下降速度越快。"
            or isRu and "Изменяет скорость снижения влажности при фотосинтезе. По умолчанию: 1.0."
            or "Wetness drain multiplier when experiencing photosynthesis. Default: 1.0",
        options =
        {
            {description = "0.1", data = 0.1},
            {description = "0.2", data = 0.2},
            {description = "0.5", data = 0.5},
            {description = STRING_DEFAULT, data = 1.0},
            {description = "1.5", data = 1.5},
            {description = "2.0", data = 2.0},
            {description = "2.5", data = 2.5},
            {description = "3.0", data = 3.0},
            {description = "4.0", data = 4.0},
            {description = "5.0", data = 5.0},
            {description = "10.0", data = 10.0},
        },
        default = 1.0,
    },
    {
        name = "photosynthesis_moisture_healing_multi",
        label = isCh and "光合作用潮湿度回血倍率"
            or isRu and "Множитель исцеления от влаги (фотосинтез)"
            or "Photosynthesis: Wet Heal Multi",
        hover = isCh and "调整在潮湿状态下的回血倍率，默认为 1.0。潮湿度越高，回血速度越快。"
            or isRu and "Изменяет множитель исцеления от влажности при фотосинтезе. По умолчанию: 1.0."
            or "Healing multiplier from wetness when experiencing photosynthesis. Default: 1.0",
        options =
        {
            {description = "0.1", data = 0.1},
            {description = "0.2", data = 0.2},
            {description = "0.5", data = 0.5},
            {description = STRING_DEFAULT, data = 1.0},
            {description = "1.5", data = 1.5},
            {description = "2.0", data = 2.0},
            {description = "2.5", data = 2.5},
            {description = "3.0", data = 3.0},
            {description = "4.0", data = 4.0},
            {description = "5.0", data = 5.0},
            {description = "10.0", data = 10.0},
        },
        default = 1.0,
    },
    {
        name = "photosynthesis_timer_multi",
        label = isCh and "光合作用开花值回复倍率"
            or isRu and "Множитель восстановления очков цветения (фотосинтез)"
            or "Photosynthesis: BP Regen Mult",
        hover = isCh and "调整在生命值满的条件下的开花值恢复倍率，默认为 2.5。"
            or isRu and "Изменяет множитель восстановления очков цветения при полном здоровье. По умолчанию: 2.5."
            or "Bloom Point regeneration multiplier when full HP. Default: 2.5",
        options =
        {
            {description = "0", data = 0},
            {description = "0.5", data = 0.5},
            {description = "1.0", data = 1.0},
            {description = "1.5", data = 1.5},
            {description = "2.0", data = 2.0},
            {description = STRING_DEFAULT, data = 2.5},
            {description = "3.0", data = 3.0},
            {description = "3.5", data = 3.5},
            {description = "4.0", data = 4.0},
            {description = "4.5", data = 4.5},
            {description = "5.0", data = 5.0},
            {description = "6.0", data = 6.0},
            {description = "7.0", data = 7.0},
            {description = "8.0", data = 8.0},
            {description = "9.0", data = 9.0},
            {description = "10", data = 10},
            {description = "15", data = 15},
            {description = "20", data = 20},
            {description = "25", data = 25},
            {description = "30", data = 30},
            {description = "35", data = 35},
            {description = "40", data = 40},
            {description = "45", data = 45},
            {description = "50", data = 50},
        },
        default = 2.5,
    },
    {
        name = "photosynthesis_energy_cost_multi",
        label = isCh and "光合作用供能基准能耗倍率"
            or isRu and "Базовый множитель энергозатрат (фотосинтез)"
            or "Photosynthesis: Energy Cost Mult",
        hover = isCh and "调整光合作用供能给其他需能任务的基准能耗倍率，默认为 1.0。倍率越高、负载越多，能耗就越高，开花值消耗也越高。"
            or isRu and "Базовый множитель энергозатрат для фотосинтеза. Чем выше множитель и нагрузка, тем выше расход энергии и очков цветения. По умолчанию: 1.0."
            or "The base energy cost multiplier for adjusting photosynthetic energy supply to other energy-demanding tasks. Default: 1.0. The higher the multiplier and the greater the load, the higher the energy consumption and the more the Bloom Point is consumed.",
        options =
        {
            {description = "0.1", data = 0.1},
            {description = "0.2", data = 0.2},
            {description = "0.3", data = 0.3},
            {description = "0.4", data = 0.4},
            {description = "0.5", data = 0.5},
            {description = "0.6", data = 0.6},
            {description = "0.7", data = 0.7},
            {description = "0.8", data = 0.8},
            {description = "0.9", data = 0.9},
            {description = STRING_DEFAULT, data = 1.0},
            {description = "1.5", data = 1.5},
            {description = "2.0", data = 2.0},
            {description = "2.5", data = 2.5},
            {description = "3.0", data = 3.0},
            {description = "4.0", data = 4.0},
            {description = "5.0", data = 5.0},
        },
        default = 1.0,
    },
    {
        name = "overheatprotection_buff_multi",
        label = isCh and "盛情绽放增益提升倍率"
            or isRu and "Множитель бонуса цветения"
            or "Blooming Buff Multiplier",
        hover = isCh and "调整佩戴启迪之冠或不佩戴头部装备时的开花增益倍率，默认为 2.0。"
            or isRu and "Изменяет множитель бонуса цветения при ношении короны просветления или без головного убора. По умолчанию: 2.0."
            or "Bloom buff multiplier when wearing the Enlighten Crown or not wearing any hat. Default: 2.0",
        options =
        {
            {description = "1.0", data = 1.0},
            {description = "1.1", data = 1.1},
            {description = "1.2", data = 1.2},
            {description = "1.3", data = 1.3},
            {description = "1.4", data = 1.4},
            {description = "1.5", data = 1.5},
            {description = "1.6", data = 1.6},
            {description = "1.7", data = 1.7},
            {description = "1.8", data = 1.8},
            {description = "1.9", data = 1.9},
            {description = STRING_DEFAULT, data = 2.0},
            {description = "2.5", data = 2.5},
            {description = "3.0", data = 3.0},
            {description = "4.0", data = 4.0},
            {description = "5.0", data = 5.0},
        },
        default = 2.0,
    },
    {
        name = "lunartree_consume_val",
        label = isCh and "月树疗愈消耗开花值"
            or isRu and "Расход очков цветения для лечения Лунным деревом"
            or "Lunar Tree Heal BP Cost",
        hover = isCh and "调整月树疗愈所消耗的开花值，默认为 1200。"
            or isRu and "Изменяет расход очков цветения для лечения Лунным деревом. По умолчанию: 1200."
            or "Bloom Point Cost for Lunar Tree Healing. Default: 1200",
        options =
        {
            {description = "0", data = 0},
            {description = "50", data = 50},
            {description = "100", data = 100},
            {description = "150", data = 150},
            {description = "300", data = 300},
            {description = "600", data = 600},
            {description = "900", data = 900},
            {description = STRING_DEFAULT, data = 1200},
            {description = "1500", data = 1500},
            {description = "1800", data = 1800},
            {description = "2100", data = 2100},
            {description = "2400", data = 2400},
            {description = "2700", data = 2700},
            {description = "3000", data = 3000},
            {description = "3300", data = 3300},
        },
        default = 1200,
    },
    {
        name = "lunartree_healing_multi",
        label = isCh and "月树疗愈回血倍率"
            or isRu and "Множитель исцеления Лунным деревом"
            or "Lunar Tree Heal Multi",
        hover = isCh and "调整月树疗愈总回血量，默认为 1.0，回复 150 + 60 点生命值。"
            or isRu and "Изменяет общий множитель исцеления Лунным деревом. По умолчанию: 1.0 (150 + 60 здоровья)."
            or "Healing multiplier for Lunar Tree Healing. Default: 1.0",
        options =
        {
            {description = "0.5", data = 0.5},
            {description = STRING_DEFAULT, data = 1.0},
            {description = "1.5", data = 1.5},
            {description = "2.0", data = 2.0},
            {description = "2.5", data = 2.5},
            {description = "3.0", data = 3.0},
            {description = "4.0", data = 4.0},
            {description = "5.0", data = 5.0},
        },
        default = 1.0,
    },
    {
        name = "opalstaff_frozen_consume_val",
        label = isCh and "冻结极光消耗开花值"
            or isRu and "Расход очков цветения для замороженного сияния"
            or "Frozen Coldlight BP Cost",
        hover = isCh and "调整使用唤月者魔杖释放冻结极光所消耗的开花值，默认为 600。"
            or isRu and "Изменяет расход очков цветения для создания замороженного сияния. По умолчанию: 600."
            or "Bloom Point Cost to release Frozen Coldlight. Default: 600",
        options =
        {
            {description = "0", data = 0},
            {description = "50", data = 50},
            {description = "100", data = 100},
            {description = "150", data = 150},
            {description = "200", data = 200},
            {description = "300", data = 300},
            {description = STRING_DEFAULT, data = 600},
            {description = "900", data = 900},
            {description = "1200", data = 1200},
            {description = "1500", data = 1500},
            {description = "1800", data = 1800},
            {description = "2100", data = 2100},
            {description = "2400", data = 2400},
            {description = "2700", data = 2700},
            {description = "3000", data = 3000},
            {description = "3300", data = 3300},
        },
        default = 600,
    },
    {
        name = "opalstaff_frozen_exist_val",
        label = isCh and "冻结极光持续时间"
            or isRu and "Длительность замороженного сияния"
            or "Frozen Coldlight Duration",
        hover = isCh and "调整使用唤月者魔杖释放冻结极光所持续的时间，默认为 120s。"
            or isRu and "Изменяет длительность замороженного сияния. По умолчанию: 120 сек."
            or "Duration of Frozen Coldlight. Default: 120s",
        options =
        {
            {description = "30s", data = 30},
            {description = "60s", data = 60},
            {description = "90s", data = 90},
            {description = STRING_DEFAULT, data = 120},
            {description = "150s", data = 150},
            {description = "180s", data = 180},
            {description = "210s", data = 210},
            {description = "240s", data = 240},
            {description = "270s", data = 270},
            {description = "300s", data = 300},
            {description = "360s", data = 360},
            {description = "480s", data = 480},
            {description = "720s", data = 720},
            {description = "960s", data = 960},
        },
        default = 120,
    },
    {
        name = "opalstaff_summon_consume_val",
        label = isCh and "启迪极光消耗开花值"
            or isRu and "Расход очков цветения для просветлённого сияния"
            or "Enlightened Coldlight BP Cost",
        hover = isCh and "调整使用唤月者魔杖释放启迪极光所消耗的开花值，默认为 1800。"
            or isRu and "Изменяет расход очков цветения для создания просветлённого сияния. По умолчанию: 1800."
            or "Bloom Point Cost for Enlightened Coldlight. Default: 1800",
        options =
        {
            {description = "0", data = 0},
            {description = "50", data = 50},
            {description = "100", data = 100},
            {description = "150", data = 150},
            {description = "300", data = 300},
            {description = "600", data = 600},
            {description = "900", data = 900},
            {description = "1200", data = 1200},
            {description = "1500", data = 1500},
            {description = STRING_DEFAULT, data = 1800},
            {description = "2100", data = 2100},
            {description = "2400", data = 2400},
            {description = "2700", data = 2700},
            {description = "3000", data = 3000},
            {description = "3300", data = 3300},
        },
        default = 1800,
    },
    {
        name = "opalstaff_summon_exist_val",
        label = isCh and "启迪极光持续时间"
            or isRu and "Длительность просветлённого сияния"
            or "Enlightened Coldlight Duration",
        hover = isCh and "调整使用唤月者魔杖释放启迪极光所持续的时间，默认为 240s。"
            or isRu and "Изменяет длительность просветлённого сияния. По умолчанию: 240 сек."
            or "Duration of Enlightened Coldlight. Default: 240s",
        options =
        {
            {description = "5s", data = 5},
            {description = "10s", data = 10},
            {description = "15s", data = 15},
            {description = "30s", data = 30},
            {description = "60s", data = 60},
            {description = "90s", data = 90},
            {description = "120s", data = 120},
            {description = "150s", data = 150},
            {description = "180s", data = 180},
            {description = "210s", data = 210},
            {description = STRING_DEFAULT, data = 240},
            {description = "270s", data = 270},
            {description = "300s", data = 300},
            {description = "360s", data = 360},
            {description = "480s", data = 480},
            {description = "720s", data = 720},
            {description = "960s", data = 960},
        },
        default = 240,
    },
}
