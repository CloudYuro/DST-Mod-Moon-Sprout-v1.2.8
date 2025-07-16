local CHARACTERS = {
    "WILSON",
    "WILLOW",
    "WOLFGANG",
    "WENDY",
    "WX78",
    "WICKERBOTTOM",
    "WOODIE",
    "WAXWELL",
    "WATHGRITHR",
    "WEBBER",
    "WINONA",
    "WARLY",
    "WORTOX",
    "WORMWOOD",
    "WURT",
    "WALTER",
    "WANDA",
}

STRINGS.RECIPE_DESC.PETALS = "Может преждевременно завершить активное состояние навыков Вормвуда после употребления Лунного цветка или Наполненного лунного цветка."

STRINGS.RECIPE_DESC.MOON_TREE_BLOSSOM = "Должен быть съеден в цветущем состоянии, чтобы пробудить лунную силу."
STRINGS.MOON_TREE_BLOSSOM_INSPECT = {
    bloom_point = "Очки цветения: ",
    bloom_point_max = "Очки цветения достигли максимума: ",
    butter_produce = "\nПроизводство масла: ",
}

STRINGS.NAMES.MOON_TREE_BLOSSOM_CHARGED = "Наполненный лунный цветок"
STRINGS.RECIPE_DESC.MOON_TREE_BLOSSOM_CHARGED = "Наполнен чистой сияющей энергией, пробуждающей ваши продвинутые способности."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MOON_TREE_BLOSSOM_CHARGED = "Переполнен энергией"

STRINGS.WORMWOOD_SKILL = {
    get_moon_charged_1 = "Я чувствую себя таким легким!",
    get_moon_charged_2 = "Энергия!",
    lose_moon_charged_1 = "Больше не чувствую легкости...",
    lose_moon_charged_2 = "Не так ярко...",
}

----------------------------------------------------------------------------

STRINGS.NAMES.WORMWOOD_CORKCHEST = "Корневой каталитический бочонок"
STRINGS.RECIPE_DESC.WORMWOOD_CORKCHEST = "Большой амбар, размещение семян и лунного цветка в определенном порядке может вызвать направленные мутации семян."
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.WORMWOOD_CORKCHEST = "Дом друзей."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_CORKCHEST = "Раньше он не был таким большим!"

STRINGS.WORMWOOD_CORKCHEST = {
    need_salt_1 = "Другу нужны соленые камешки и синий блестящий камень",
    need_salt_2 = "Друг хочет что-то соленое",
    need_salt_3 = "Если бы у нас была соль...",
    need_salt_4 = "Нужна соль",
    need_more_salt_1 = "Нужно больше соли",
    need_more_salt_2 = "Соленого недостаточно!",
    need_bluegem_1 = "Друг хочет еще один синий камень",
    need_bluegem_2 = "Нужен еще один синий камень",
    wrong_position_1 = "Неверное положение",
    wrong_position_2 = "Хм... нужно изменить расположение",
    upgrade_complete = "Отлично!",
}

STRINGS.RECIPE_DESC.BULLKELP_ROOT = "Дружок воды."  
STRINGS.RECIPE_DESC.ROCK_AVOCADO_FRUIT_SPROUT = "Хрустит как орешки!"  
STRINGS.RECIPE_DESC.DUG_BANANABUSH = "Мой ням-ням любимчик!"  
STRINGS.RECIPE_DESC.ANCIENTTREE_SEED = "Кем ты станешь?"  

----------------------------------------------------------------------------

STRINGS.NAMES.BOOK_MOONPETS = "Словарь Бип-Боп"
STRINGS.RECIPE_DESC.BOOK_MOONPETS = "Учись говорить своим малышам, что делать."
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.BOOK_MOONPETS = "Книжка про моих малышей!" 
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_MOONPETS = "Написано: Разговорник Лунного острова от Черводрева" 

STRINGS.BOOK_MOONPETS = {
    -- Подбор предметов
    switch_pickable = "Подбор предметов",
    announce_enable_pickable_1 = "Бип-бип!",
    announce_enable_pickable_2 = "Хватай-хватай!",
    announce_enable_pickable_3 = "Плюх-плюх, хватай!",
    
    announce_unenable_pickable_1 = "Бууп!",
    announce_unenable_pickable_2 = "Не бери!",
    announce_unenable_pickable_3 = "Брось-брось!",

    -- Передвижение
    switch_standstill = "Следовать/Ждать",
    announce_follow_1 = "За-за мной!",
    announce_follow_2 = "Иди-иди-иди!",
    announce_follow_3 = "Черво ведёт!",
    
    announce_standstill_1 = "З-здесь... жди!",
    announce_standstill_2 = "Не... уходи!",
    announce_standstill_3 = "Стой-стой тут!",

    -- Режимы боя
    switch_aggressive = "Агрессивный режим",
    announce_aggressive_1 = "Бей их!",
    announce_aggressive_2 = "Вперёд бить!",
    announce_aggressive_3 = "Кусай насмерть!",
    
    switch_defensive = "Защитный режим",
    announce_defensive_1 = "Защити меня!",
    announce_defensive_2 = "Прикрой-прикрой!",
    announce_defensive_3 = "Окружай вкруг!",
    
    switch_passive = "Пассивный режим",
    announce_passive_1 = "Не драться!",
    announce_passive_2 = "Глади-глади!",
    announce_passive_3 = "Притворись деревом!",

    -- Тактика
    switch_moving_combat = "Передвижной/Статичный бой",
    announce_moving_combat_1 = "Не попадайся!",
    announce_moving_combat_2 = "Беги и бей!",
    announce_moving_combat_3 = "Крутись и бей!",
    
    announce_sticking_combat_1 = "Держи позицию!",
    announce_sticking_combat_2 = "Стоять-стоять!",
    announce_sticking_combat_3 = "Пригвозди тут!",
}

STRINGS.NAMES.WORMWOOD_PIKO = "Пико"
STRINGS.RECIPE_DESC.WORMWOOD_PIKO = "Маленькое существо, ищущее запасы на зиму."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_PIKO = STRINGS.CHARACTERS.GENERIC.DESCRIBE.PIKO or "Нашел что-то?"

STRINGS.NAMES.WORMWOOD_PIKO_ORANGE = "Оранжевый Пико"
STRINGS.RECIPE_DESC.WORMWOOD_PIKO_ORANGE = "Оранжевое маленькое существо, ищущее запасы на зиму."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_PIKO_ORANGE = STRINGS.CHARACTERS.GENERIC.DESCRIBE.PIKO_ORANGE or "Нашел любимый фрукт?"

STRINGS.NAMES.WORMWOOD_GRASSGATOR = "Травяной аллигатор"
STRINGS.RECIPE_DESC.WORMWOOD_GRASSGATOR = "Он может переносить так много вещей!"
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.WORMWOOD_GRASSGATOR = STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.GRASSGATOR or "Другим друзьям он нравится"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_GRASSGATOR = STRINGS.CHARACTERS.GENERIC.DESCRIBE.GRASSGATOR or "Другим друзьям он нравится"

STRINGS.NAMES.WORMWOOD_FLYTRAP = "Венерина мухоловка"
STRINGS.RECIPE_DESC.WORMWOOD_FLYTRAP = "Самый свирепый друг, всегда ищет мясо."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_FLYTRAP = STRINGS.CHARACTERS.GENERIC.DESCRIBE.MEAN_FLYTRAP or "Ищет что-то, чтобы наполнить желудок"

STRINGS.NAMES.WORMWOOD_MANDRAKEMAN = "Старейшина мандрагоры"
STRINGS.RECIPE_DESC.WORMWOOD_MANDRAKEMAN = "Соня."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_MANDRAKEMAN = STRINGS.CHARACTERS.GENERIC.DESCRIBE.MANDRAKEMAN or "Немного шумный"

STRINGS.RECIPE_DESC.MANDRAKE = "Перестань шуметь!"
STRINGS.RECIPE_DESC.MANDRAKE_ACTIVE = "Перестань шуметь!"

----------------------------------------------------------------------------

STRINGS.NAMES.WORMWOOD_MUSHROOMBOMB = "Грибная бомба"
STRINGS.RECIPE_DESC.WORMWOOD_MUSHROOMBOMB = "Экологически чистый метод разрушения."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_MUSHROOMBOMB = STRINGS.CHARACTERS.GENERIC.DESCRIBE.MUSHROOMBOMB or "Довольно капризный друг"

STRINGS.NAMES.WORMWOOD_MUSHROOMBOMB_GAS = "Токсичная спора"
STRINGS.RECIPE_DESC.WORMWOOD_MUSHROOMBOMB_GAS = "Используй с осторожностью."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_MUSHROOMBOMB_GAS = STRINGS.CHARACTERS.GENERIC.DESCRIBE.MUSHROOMBOMB_DARK or "Его сила возросла!"

STRINGS.NAMES.WORMWOOD_MOON_MUSHROOMHAT = "Милд мун мушлумхат"
STRINGS.RECIPE_DESC.WORMWOOD_MOON_MUSHROOMHAT = "Безопасная и более дружелюбная шапочка из лунных грибов, изготовленная компанией Wormwood." 
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WWORMWOOD_MOON_MUSHROOMHAT = STRINGS.CHARACTERS.GENERIC.DESCRIBE.MOON_MUSHROOMHAT

STRINGS.NAMES.WORMWOOD_SPORE_MOON = STRINGS.NAMES.SPORE_MOON
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_SPORE_MOON = STRINGS.CHARACTERS.GENERIC.DESCRIBE.SPORE_MOON

STRINGS.WORMWOOD_MUSHROOMHAT = {
    put_on_red = "Красный гриб защищает меня!",  
    put_on_blue = "Синий гриб защищает меня!",  
    put_on_green = "Зелёный гриб защищает меня!",  
    put_on_moon = "Лунный гриб защищает меня!",  
    take_off_red = "Потерял защиту красного гриба...",  
    take_off_blue = "Потерял защиту синего гриба...",  
    take_off_green = "Потерял защиту зелёного гриба...",  
    take_off_moon = "Потерял защиту лунного гриба...",

    know_red_mushroomhat = "Теперь я знаю, как сделать красную грибную шляпу!",
    activate_red_buff = "Чувствую себя сильнее!",
    deactivate_red_buff = "Сила ослабевает",

    know_blue_mushroomhat = "Я могу сделать синюю грибную шляпу!",
    activate_blue_buff = "Корни стали крепче!",
    deactivate_blue_buff = "Ах, корни снова смягчаются...",

    know_green_mushroomhat = "Зеленая грибная шляпа! У меня есть идея!",
    activate_green_buff = "Лунная сила усиливается!",
    deactivate_green_buff = "Лунная сила ослабевает",
    
    know_moon_mushroomhat = "Лунная грибная шляпа! Я могу сделать это!",

    deactivate_shroomcake_buff = "Остался ли торт?",

    activate_shroombait_buff = "Хочется спать...",
    deactivate_shroombait_buff = "Хм... просыпаюсь...",
}

----------------------------------------------------------------------------

STRINGS.RECIPE_DESC.CACTUS_MEAT = "Полный рот колючек!"

STRINGS.EAT_CACTUS_MEAT = {
    eat_first = "Кажется, у меня выросли колючки!",
    eat_again = "Колючки!",
    eat_finish = "Колючее ощущение исчезло...",
}

STRINGS.RECIPE_DESC.ACORN = "Это нельзя есть сырым"

STRINGS.DECIDUOUS_ASSIST = {
    announce_1 = "Друг пришел мне на помощь!",
    announce_2 = "Он меня обижает!",
    announce_3 = "Вот он!",
}

STRINGS.NAMES.IVYSTAFF = "Посох плюща"
STRINGS.RECIPE_DESC.IVYSTAFF = "Порождение луны и корней."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.IVYSTAFF = "Очень много колючек!"

STRINGS.NAMES.BRAMBLESPIKE = "Колючка"
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.BRAMBLESPIKE = "Ура!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BRAMBLESPIKE = "Выглядит болезненно!"

STRINGS.NAMES.WORMWOOD_LUNARTHRALL_PLANT = "Лунное растение Вормвуда"
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.WORMWOOD_LUNARTHRALL_PLANT = "Я подружился с ним"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_LUNARTHRALL_PLANT = "Кажется, теперь оно менее сердитое"

STRINGS.NAMES.WORMWOOD_LUNARTHRALL_PLANT_VINE_END = STRINGS.NAMES.LUNARTHRALL_PLANT_VINE_END
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.WORMWOOD_LUNARTHRALL_PLANT_VINE_END = "Ищет плохих парней!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_LUNARTHRALL_PLANT_VINE_END = "Вперед, маленькая лоза!"

----------------------------------------------------------------------------

STRINGS.WORMWOOD_MOTHLING = {
    inspect_cut_1 = "Лунная энергия: ",
}

STRINGS.NAMES.WORMWOOD_GESTALT_GUARD = "Призрак Вормвуда"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_GESTALT_GUARD = STRINGS.CHARACTERS.GENERIC.DESCRIBE.GESTALT_GUARD or "Кажется, теперь оно более добродушное"

STRINGS.NAMES.WORMWOOD_LUNAR_GRAZER = "Лунный пастух Вормвуда"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_LUNAR_GRAZER = STRINGS.CHARACTERS.GENERIC.DESCRIBE.LUNAR_GRAZER or "Он любит спать"

----------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
local moon_charged_1_time = tonumber(GetModConfigData("moon_charged_1_time"))
local moon_charged_2_time = tonumber(GetModConfigData("moon_charged_2_time"))

local pets_num_carrat = tonumber(GetModConfigData("pets_num_carrat"))
local pets_num_lightflier = tonumber(GetModConfigData("pets_num_lightflier"))
local pets_num_piko = tonumber(GetModConfigData("pets_num_piko"))
local pets_num_piko_orange = tonumber(GetModConfigData("pets_num_piko_orange"))
local pets_num_fruitdragon = tonumber(GetModConfigData("pets_num_fruitdragon"))
local pets_num_grassgator = tonumber(GetModConfigData("pets_num_grassgator"))
local pets_num_flytrap = tonumber(GetModConfigData("pets_num_flytrap"))
local pets_num_mandrakeman = tonumber(GetModConfigData("pets_num_mandrakeman"))

local mushroom_buff_time = tonumber(GetModConfigData("mushroom_buff_time"))
local shroomcake_buff_time = tonumber(GetModConfigData("shroomcake_buff_time"))
local shroombait_buff_time = tonumber(GetModConfigData("shroombait_buff_time"))
local shroombait_common_multi = tonumber(GetModConfigData("shroombait_common_multi"))
local shroombait_epic_multi = tonumber(GetModConfigData("shroombait_epic_multi"))
local shroombait_affect_teammate = GetModConfigData("shroombait_affect_teammate")
local mushroomhat_unlock_chance = tonumber(GetModConfigData("mushroomhat_unlock_chance"))
local mushroomhat_damage_absorb = tonumber(GetModConfigData("mushroomhat_damage_absorb"))
local mushroomhat_consume_val = tonumber(GetModConfigData("mushroomhat_consume_val"))
local moon_mushroomhat_consume_val = tonumber(GetModConfigData("moon_mushroomhat_consume_val"))
local moon_mushroomhat_buff_time = tonumber(GetModConfigData("moon_mushroomhat_buff_time"))

local bramblefx_consume_val_1 = tonumber(GetModConfigData("bramblefx_consume_val_1"))
local bramblefx_consume_val_2 = tonumber(GetModConfigData("bramblefx_consume_val_2"))
local vine_consume_val = tonumber(GetModConfigData("vine_consume_val"))
local vine_chance_val = tonumber(GetModConfigData("vine_chance_val"))
local deciduoustree_consume_val = tonumber(GetModConfigData("deciduoustree_consume_val"))
local deciduoustree_time = tonumber(GetModConfigData("deciduoustree_time"))
local ivystaff_lunarplant_consume_val = tonumber(GetModConfigData("ivystaff_lunarplant_consume_val"))
local ivystaff_lunarplant_time = tonumber(GetModConfigData("ivystaff_lunarplant_time"))

local fertilizer_healing_multi = tonumber(GetModConfigData("fertilizer_healing_multi"))
local photosynthesis_light_healing_multi = tonumber(GetModConfigData("photosynthesis_light_healing_multi"))
local photosynthesis_moisture_consume_multi = tonumber(GetModConfigData("photosynthesis_moisture_consume_multi"))
local photosynthesis_moisture_healing_multi = tonumber(GetModConfigData("photosynthesis_moisture_healing_multi"))
local photosynthesis_timer_multi = tonumber(GetModConfigData("photosynthesis_timer_multi"))
local overheatprotection_buff_multi = tonumber(GetModConfigData("overheatprotection_buff_multi"))
local lunartree_consume_val = tonumber(GetModConfigData("lunartree_consume_val"))
local lunartree_healing_multi = tonumber(GetModConfigData("lunartree_healing_multi"))
local opalstaff_frozen_consume_val = tonumber(GetModConfigData("opalstaff_frozen_consume_val"))
local opalstaff_frozen_exist_val = tonumber(GetModConfigData("opalstaff_frozen_exist_val"))
local opalstaff_summon_consume_val = tonumber(GetModConfigData("opalstaff_summon_consume_val"))
local opalstaff_summon_exist_val = tonumber(GetModConfigData("opalstaff_summon_exist_val"))
-----------------------------------------------------------------------------------------------------------------------

local SKILLTREESTRINGS = STRINGS.SKILLTREE.WORMWOOD
GLOBAL.SKILLTREESTRINGSEX = {}

SKILLTREESTRINGSEX.WORMWOOD_IDENTIFY_PLANTS2_DESC_EX = "Может идентифицировать посаженные семена. В цветущем состоянии Вормвуд может восполнять очки цветения (BP) из еды. Получает лунное родство, эффекты которого усиливаются с фазами луны. Может создавать Лунный цветок, проверяя его свежесть, чтобы узнать текущие BP. Употребление активирует навыки на " .. string.format("%d", moon_charged_1_time) .. "с. Употребление лепестков прекращает активацию досрочно."



SKILLTREESTRINGSEX.WORMWOOD_PETS_CARRAT_DESC_EX = SKILLTREESTRINGS.LUNAR_MUTATIONS_1_DESC .. " Созданные вами маленькие существа могут подбирать предметы в инвентарь. Кормление продлевает их жизнь. Кормление Наполненным лунным цветком дает им планарные атрибуты. \"Фотосинтез\" может продлевать существование и планарные атрибуты спутников."

SKILLTREESTRINGSEX.WORMWOOD_PETS_PIKO_DESC_EX = "Превращайте шишки в Пико.\nОни помогают собирать разбросанные ресурсы, но иногда ведут себя немного озорно?"

SKILLTREESTRINGSEX.WORMWOOD_PETS_GRASSGATOR_DESC_EX = "Превращайте инжир в Травяных аллигаторов.\nУ них 9 слотов инвентаря, кормите их вегетарианской едой в 5-м слоте.\nОни избегают боя с предметами в инвентаре. Освободите слоты для помощи в бою."

SKILLTREESTRINGSEX.WORMWOOD_PETS_FLYTRAP_DESC_EX = "Превращайте семена плотоядных растений в Венерины мухоловки.\nОни растут с каждой трапезой, достигая 1600 HP и планарных атрибутов.\nМандрагоры превращаются в Старейшин, их атаки накапливают 1 очко сна у врагов."



SKILLTREESTRINGSEX.WORMWOOD_MUSHROOMPLANTER_UPGRADE_DESC_EX = "Грибные фермы дают больше урожая. Триколорные грибы дают эффекты на " .. string.format("%d", mushroom_buff_time) .. "с. Красные: +10% урона, Синие: -15% получаемого урона, Зеленые: +20% лунного родства.\nПовторное поедание сбрасывает время, эффекты не складываются. Каждый гриб имеет шанс открыть соответствующую шляпу."

SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_MUSHROOMBOMB_DESC_EX = "Создавайте грибные бомбы для замедленного взрыва с областью поражения.\nПолностью сгнившие становятся токсичными бомбами с ядовитым газом."

SKILLTREESTRINGSEX.WORMWOOD_MOON_CAP_EATING_DESC_EX = SKILLTREESTRINGS.MOON_CAP_EATING_DESC .. "\nВ цвету длительность эффектов грибных предметов +50%.\nИзучив все три цветные шляпы, можно открыть рецепт лунной шляпы."

SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_SHROOMCAKE_DESC_EX = "Грибной торт дает все эффекты вполсилы на " .. string.format("%d", shroomcake_buff_time) .. "с. Складывается с одиночными эффектами. Ночная шляпа дает 30 очков сна и -25% урона врагам, плюс ауру сна на " .. string.format("%d", shroombait_buff_time) .. "с."

SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_MUSHROOMHAT_DESC_EX = "Грибные шляпы поглощают "..(mushroomhat_damage_absorb*100).."% урона. Триколорные: дают эффекты. С Лунным цветком: тратят "..mushroomhat_consume_val.." BP/с на ауру. Лунная шляпа: атаки дают случайные эффекты. С Наполненным: "..moon_mushroomhat_consume_val.." BP/атака за двойные эффекты. \"Фотосинтез\" восстанавливает свежесть."



SKILLTREESTRINGSEX.WORMWOOD_THORN_CACTUS_DESC_EX = "Превращайте кактусовую мякоть и березовые орехи. Кактус дает +5 к урону шипов на 30с."

SKILLTREESTRINGSEX.BUGS_DESC_EX = SKILLTREESTRINGS.BUGS_DESC .. "\nВормвуд может ловить пчел и бабочек руками."

SKILLTREESTRINGSEX.ARMOR_BRAMBLE_DESC_EX = SKILLTREESTRINGS.ARMOR_BRAMBLE_DESC .. " В цвету с Лунным цветком тратит "..bramblefx_consume_val_1.." BP/атаку для шипов за 2 удара."

SKILLTREESTRINGSEX.WORMWOOD_THORN_DECIDUOUSTREE_DESC_EX = "У берез есть шанс помочь в бою (КД: день). В цвету можно посадить ядовитую березу за "..deciduoustree_consume_val.." BP на "..deciduoustree_time.."с."

SKILLTREESTRINGSEX.WORMWOOD_THORN_IVYSTAFF_DESC_EX = "Посох плюща дает +10% скорости (+25% при макс. цветении). Атаки корнят врагов. Бросок создает стены. В цвету с Наполненным можно бросить Защитника за "..ivystaff_lunarplant_consume_val.." BP на "..ivystaff_lunarplant_time.."с. \"Фотосинтез\" восстанавливает свежесть."



SKILLTREESTRINGSEX.WORMWOOD_QUICK_SELFFERTILIZER_DESC_EX = "Удобрения лечат быстрее. Стимулятор ускоряет цветение на 30%. Лечение +"..(fertilizer_healing_multi * 100 - 100).."%."

SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_FARMRANGE1_DESC_EX = "Первые две стадии требуют на 25% меньше BP. Быстрее цветет при свете и влаге. +5% и +15% скорости в бутонах со слабыми бонусами."

SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_OVERHEATPROTECTION_DESC_EX = "Макс. цветение дает 180 термоизоляции. С короной Просветления или без шлема бонусы цветения и фотосинтеза +"..(overheatprotection_buff_multi * 100 - 100).."%."

SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_MAX_UPGRADE_DESC_EX = "Макс. BP увеличен до 3600. Свет дает энергию для лечения. Влага усиливает фотосинтез. При полном HP BP медленно восстанавливаются. При BP >1800 энергия может идти на другие нужды."

SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_LUNARTREE_DESC_EX = "Высокий BP привлекает Лунных мотыльков. Можно сажать Лунные деревья за "..lunartree_consume_val.." BP для лечения союзников 60с. \"Фотосинтез\" поддерживает мотыльков. Мотылек, которого вы усыновили, мог получить лунную энергию от лунного света, исцелить раненого игрока и обеспечить вас распределением энергии."

SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_OPALSTAFF_DESC_EX = "Посох дает +10% лунного родства союзникам. В цвету можно выпускать Замораживающее сияние за "..opalstaff_frozen_consume_val.." BP на "..opalstaff_frozen_exist_val.."с или Просветляющее за "..opalstaff_summon_consume_val.." BP на "..opalstaff_summon_exist_val.."с."



SKILLTREESTRINGSEX.LUNAR_GEAR_1_DESC_EX = SKILLTREESTRINGS.LUNAR_GEAR_1_DESC .. "\nВ цвету с Наполненным тратит "..bramblefx_consume_val_2.." BP/атаку для шипов каждый удар."

SKILLTREESTRINGSEX.LUNAR_GEAR_2_DESC_EX = SKILLTREESTRINGS.LUNAR_GEAR_2_DESC .. "\nВ цвету с Наполненным тратит "..vine_consume_val.." BP/атаку для 50% шанса лиан."


SKILLTREESTRINGSEX.WORMWOOD_IDENTIFY_PLANTS2_TITLE_EX = "Лунный росток"
SKILLTREESTRINGSEX.WORMWOOD_PETS_CARRAT_TITLE_EX = "Лунный собиратель"
SKILLTREESTRINGSEX.LUNAR_MUTATIONS_2_TITLE_EX = "Лунный светоч"
SKILLTREESTRINGSEX.WORMWOOD_PETS_PIKO_TITLE_EX = "Экзотический коллекционер"
SKILLTREESTRINGSEX.LUNAR_MUTATIONS_3_TITLE_EX = "Лунный защитник"
SKILLTREESTRINGSEX.WORMWOOD_PETS_GRASSGATOR_TITLE_EX = "Лунный перевозчик"
SKILLTREESTRINGSEX.WORMWOOD_PETS_FLYTRAP_TITLE_EX = "Экзотический хищник"
SKILLTREESTRINGSEX.MUSHROOMPLANTER_RATEBONUS_2_TITLE_EX = "Грибовод"
SKILLTREESTRINGSEX.WORMWOOD_MUSHROOMPLANTER_UPGRADE_TITLE_EX = "Грибной пикник"
SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_MUSHROOMBOMB_TITLE_EX = "Грибная бомба"
SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_SHROOMCAKE_TITLE_EX = "Грибной гурман"
SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_MUSHROOMHAT_TITLE_EX = "Грибная защита"
SKILLTREESTRINGSEX.WORMWOOD_THORN_CACTUS_TITLE_EX = "Шипастый ответ"
SKILLTREESTRINGSEX.WORMWOOD_THORN_DECIDUOUSTREE_TITLE_EX = "Березовый задира"
SKILLTREESTRINGSEX.WORMWOOD_THORN_IVYSTAFF_TITLE_EX = "Распространитель плюща"
SKILLTREESTRINGSEX.WORMWOOD_QUICK_SELFFERTILIZER_TITLE_EX = "Эффективное впитывание"
SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_FARMRANGE1_TITLE_EX = "Нетерпеливое цветение"
SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_OVERHEATPROTECTION_TITLE_EX = "Пышное цветение"
SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_MAX_UPGRADE_TITLE_EX = "Фотосинтез"
SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_LUNARTREE_TITLE_EX = "Лунное лечение"
SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_OPALSTAFF_TITLE_EX = "Лунный свет"