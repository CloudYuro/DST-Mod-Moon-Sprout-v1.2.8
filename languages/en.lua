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

STRINGS.RECIPE_DESC.PETALS = "Can prematurely end Wormwood's skill activation state after consuming Lune Tree Blossom or Infused Lune Tree Blossom."

STRINGS.RECIPE_DESC.MOON_TREE_BLOSSOM = "Must be consumed during blooming state to unleash lunar power."
STRINGS.MOON_TREE_BLOSSOM_INSPECT = {
    bloom_point = "Bloom Point: ",
    bloom_point_max = "Bloom Point has reached max: ",
    butter_produce = "\nButter production：",
}

STRINGS.NAMES.MOON_TREE_BLOSSOM_CHARGED = "Infused Lune Tree Blossom"
STRINGS.RECIPE_DESC.MOON_TREE_BLOSSOM_CHARGED = "Infused with pure brilliance, awakening your advanced abilities."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MOON_TREE_BLOSSOM_CHARGED = "Brimming with energy"

STRINGS.WORMWOOD_SKILL = {
    get_moon_charged_1 = "I feel a bit fuzzy...",
    get_moon_charged_2 = "Energy!",
    lose_moon_charged_1 = "Not fuzzy anymore...",
    lose_moon_charged_2 = "Ah...not so bright anymore...",
}

----------------------------------------------------------------------------

STRINGS.NAMES.WORMWOOD_CORKCHEST = "Root Catalytic Barrel" 
STRINGS.RECIPE_DESC.WORMWOOD_CORKCHEST = "A large granary, with seeds and lune tree blossom placed in a specific order, can induce directional mutations in the seeds." 
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.WORMWOOD_CORKCHEST = "Friends' home." 
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_CORKCHEST = "It wasn't that big before!" 

STRINGS.WORMWOOD_CORKCHEST = {
    need_salt_1 = "Friend needs crunchy salty bits, and shiny blue stone",  -- 咸咸的东西 → crunchy salty bits
    need_salt_2 = "Friend wants salty crunchies",  -- 咸咸的东西 → salty crunchies
    need_salt_3 = "If only we had some salty sparkles...",  -- 盐 → salty sparkles
    need_salt_4 = "Need salty crystals",  -- 盐 → salty crystals
    need_more_salt_1 = "Need more salty crunchies",  -- 盐 → salty crunchies
    need_more_salt_2 = "Not enough salty sparkles",  -- 盐 → salty sparkles
    need_bluegem_1 = "Friend also wants a shiny blue stone",
    need_bluegem_2 = "Need another blue gemstone",
    wrong_position_1 = "Wrong placement",
    wrong_position_2 = "Hmm... need to rearrange",
    upgrade_complete = "Great!",
}

STRINGS.RECIPE_DESC.BULLKELP_ROOT = "Water buddy."  
STRINGS.RECIPE_DESC.ROCK_AVOCADO_FRUIT_SPROUT = "Crunchy as walnuts!"  
STRINGS.RECIPE_DESC.DUG_BANANABUSH = "Nummy favorite!"  
STRINGS.RECIPE_DESC.ANCIENTTREE_SEED = "What will you become?"  

----------------------------------------------------------------------------

STRINGS.NAMES.BOOK_MOONPETS = "Beep-Boop Dictionary"
STRINGS.RECIPE_DESC.BOOK_MOONPETS = "Teaches how to tell your lil' buddies what to do."
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.BOOK_MOONPETS = "A book 'bout my lil' buddies!" 
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_MOONPETS = "Cover says: Moon Island Talk Guide by Wormwood." 

STRINGS.BOOK_MOONPETS = {
    -- Pickup system
    switch_pickable = "Toggle Pickup",
    announce_enable_pickable_1 = "Beep-beep!",
    announce_enable_pickable_2 = "Grab-grab!",
    announce_enable_pickable_3 = "Splish-splash take!",
    
    announce_unenable_pickable_1 = "Booop!",
    announce_unenable_pickable_2 = "No pickee!",
    announce_unenable_pickable_3 = "Drop-drop!",

    -- Movement system
    switch_standstill = "Toggle Follow/Wait",
    announce_follow_1 = "F-follow me!",
    announce_follow_2 = "Go-go-go!",
    announce_follow_3 = "Wormwood lead!",
    
    announce_standstill_1 = "H-here... waait!",
    announce_standstill_2 = "Don't... go 'way!",
    announce_standstill_3 = "Stay-stay here!",

    -- Combat modes
    switch_aggressive = "Aggressive Mode",
    announce_aggressive_1 = "Beat 'em up!",
    announce_aggressive_2 = "Charge 'n punch!",
    announce_aggressive_3 = "Bite 'em dead!",
    
    switch_defensive = "Defensive Mode",
    announce_defensive_1 = "Protecc me!",
    announce_defensive_2 = "Block-block front!",
    announce_defensive_3 = "Circle-round!",
    
    switch_passive = "Passive Mode",
    announce_passive_1 = "No fight!",
    announce_passive_2 = "Hug-hug pet!",
    announce_passive_3 = "Play tree!",

    -- Tactics
    switch_moving_combat = "Toggle Kiting/Stand Fight",
    announce_moving_combat_1 = "Don't get hit!",
    announce_moving_combat_2 = "Run 'n whack!",
    announce_moving_combat_3 = "Spin'n'punch!",
    
    announce_sticking_combat_1 = "Hold ground!",
    announce_sticking_combat_2 = "Stand-stand firm!",
    announce_sticking_combat_3 = "Nail here!",
}

STRINGS.NAMES.WORMWOOD_PIKO = "Piko"
STRINGS.RECIPE_DESC.WORMWOOD_PIKO = "A little creature searching for winter stores."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_PIKO = STRINGS.CHARACTERS.GENERIC.DESCRIBE.PIKO or "Found something?"

STRINGS.NAMES.WORMWOOD_PIKO_ORANGE = "Orange Piko"
STRINGS.RECIPE_DESC.WORMWOOD_PIKO_ORANGE = "An orange little creature searching for winter stores."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_PIKO_ORANGE = STRINGS.CHARACTERS.GENERIC.DESCRIBE.PIKO_ORANGE or "Found your favorite fruit?"

STRINGS.NAMES.WORMWOOD_GRASSGATOR = "Grass Gator"
STRINGS.RECIPE_DESC.WORMWOOD_GRASSGATOR = "It can carry so many things!"
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.WORMWOOD_GRASSGATOR = STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.GRASSGATOR or "Other friends love it"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_GRASSGATOR = STRINGS.CHARACTERS.GENERIC.DESCRIBE.GRASSGATOR or "Other friends love it"

STRINGS.NAMES.WORMWOOD_FLYTRAP = "Venus Flytrap"
STRINGS.RECIPE_DESC.WORMWOOD_FLYTRAP = "The fiercest friend, always hunting for meat."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_FLYTRAP = STRINGS.CHARACTERS.GENERIC.DESCRIBE.MEAN_FLYTRAP or "Looking for something to fill its belly"

STRINGS.NAMES.WORMWOOD_MANDRAKEMAN = "Elder Mandrake"
STRINGS.RECIPE_DESC.WORMWOOD_MANDRAKEMAN = "Sleepyhead."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_MANDRAKEMAN = STRINGS.CHARACTERS.GENERIC.DESCRIBE.MANDRAKEMAN or "A bit noisy"

STRINGS.RECIPE_DESC.MANDRAKE = "Stop making noise!"
STRINGS.RECIPE_DESC.MANDRAKE_ACTIVE = "Stop making noise!"

----------------------------------------------------------------------------

STRINGS.NAMES.WORMWOOD_MUSHROOMBOMB = "Mushroom Bomb"
STRINGS.RECIPE_DESC.WORMWOOD_MUSHROOMBOMB = "An eco-friendly demolition method."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_MUSHROOMBOMB = STRINGS.CHARACTERS.GENERIC.DESCRIBE.MUSHROOMBOMB or "A rather temperamental friend"

STRINGS.NAMES.WORMWOOD_MUSHROOMBOMB_GAS = "Toxic Spore Bomb" 
STRINGS.RECIPE_DESC.WORMWOOD_MUSHROOMBOMB_GAS = "Handle with care."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_MUSHROOMBOMB_GAS = STRINGS.CHARACTERS.GENERIC.DESCRIBE.MUSHROOMBOMB_DARK or "Its power has grown stronger!"

STRINGS.NAMES.WORMWOOD_MOON_MUSHROOMHAT = "Mild Lunar Funcap"
STRINGS.RECIPE_DESC.WORMWOOD_MOON_MUSHROOMHAT = "Safer and more friendly Moon Mushroom Cap, made by Womwood." 
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WWORMWOOD_MOON_MUSHROOMHAT = STRINGS.CHARACTERS.GENERIC.DESCRIBE.MOON_MUSHROOMHAT

STRINGS.NAMES.WORMWOOD_SPORE_MOON = STRINGS.NAMES.SPORE_MOON
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_SPORE_MOON = STRINGS.CHARACTERS.GENERIC.DESCRIBE.SPORE_MOON

STRINGS.WORMWOOD_MUSHROOMHAT = {
    put_on_red = "Red Cap Protection!",
    put_on_blue = "Blue Cap Protection!",  
    put_on_green = "Green Cap Protection!",  
    put_on_moon = "Moon Cap Protection!",
    take_off_red = "No more Red Cap Protection...",  
    take_off_blue = "No more Blue Cap Protection...",  
    take_off_green = "No more Green Cap Protection...",  
    take_off_moon = "No more Moon Cap Protection...",

    know_red_mushroomhat = "I know how to make red mushroom hat now!",
    activate_red_buff = "Feeling stronger!",
    deactivate_red_buff = "Strength fading",

    know_blue_mushroomhat = "I can make blue mushroom hat!",
    activate_blue_buff = "Roots feel tougher!",
    deactivate_blue_buff = "Ah, roots softening again...",

    know_green_mushroomhat = "Green mushroom hat! Got an idea!",
    activate_green_buff = "Moon power intensifying!",
    deactivate_green_buff = "Moon power weakening",
    
    know_moon_mushroomhat = "Moon mushroom hat! I can make it!",

    deactivate_shroomcake_buff = "Any cake left?",

    activate_shroombait_buff = "Feeling sleepy...",
    deactivate_shroombait_buff = "Hmm... waking up...",  
}

----------------------------------------------------------------------------

STRINGS.RECIPE_DESC.CACTUS_MEAT = "A mouthful of spines!"

STRINGS.EAT_CACTUS_MEAT = {
    eat_first = "I seem to have grown thorns!",  
    eat_again = "Thorns!",  
    eat_finish = "The prickly feeling is gone...",
}

STRINGS.RECIPE_DESC.ACORN = "Can't eat."

STRINGS.DECIDUOUS_ASSIST = {
    announce_1 = "My friend is here to help me!",
    announce_2 = "It's bullying me!",
    announce_3 = "That's the one!",
}

STRINGS.NAMES.IVYSTAFF = "Ivy Staff"
STRINGS.RECIPE_DESC.IVYSTAFF = "Born of moon and roots."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.IVYSTAFF = "So very many thorns!"

STRINGS.NAMES.BRAMBLESPIKE = "Bramble"
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.BRAMBLESPIKE = "Yay!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BRAMBLESPIKE = "Don't touch it!"

STRINGS.NAMES.WORMWOOD_LUNARTHRALL_PLANT = "Wormwood's Brightshade"
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.WORMWOOD_LUNARTHRALL_PLANT = "I made friends with it."  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_LUNARTHRALL_PLANT = "It seems a little less grumpy now."  

STRINGS.NAMES.WORMWOOD_LUNARTHRALL_PLANT_VINE_END = STRINGS.NAMES.LUNARTHRALL_PLANT_VINE_END  
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.WORMWOOD_LUNARTHRALL_PLANT_VINE_END = "Looking for bad guys!"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_LUNARTHRALL_PLANT_VINE_END = "Go get 'em, little vine!"  

----------------------------------------------------------------------------

STRINGS.WORMWOOD_MOTHLING = {
    inspect_cut_1 = "Moon Energy: ",
}

STRINGS.NAMES.WORMWOOD_GESTALT_GUARD = "Wormwood's Gestal" 
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_GESTALT_GUARD = STRINGS.CHARACTERS.GENERIC.DESCRIBE.GESTALT_GUARD or "It seems more good-natured"

STRINGS.NAMES.WORMWOOD_LUNAR_GRAZER = "Wormwood's Grazer"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORMWOOD_LUNAR_GRAZER = STRINGS.CHARACTERS.GENERIC.DESCRIBE.LUNAR_GRAZER or "It loves to sleep"

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

SKILLTREESTRINGSEX.WORMWOOD_IDENTIFY_PLANTS2_DESC_EX = "Identify planted seeds. In bloom, Wormwood can replenish BP(Bloom Point) from food. Gain lunar affinity, increasing effects with moon phase. Craft Lune Tree Blossom, check its freshness to know current BP. Eating it activates skills for " .. string.format("%d", moon_charged_1_time) .. "s. Eating petals ends activation early."



SKILLTREESTRINGSEX.WORMWOOD_PETS_CARRAT_DESC_EX = SKILLTREESTRINGS.LUNAR_MUTATIONS_1_DESC .. " Your created small creatures can pick up items into their inventory. Feeding them extends their lifespan. Feeding them Infused Lune Tree Blossom grants them planar attributes. \"Photosynthesis\" can prolong the existence and planar attributes time of the followers."

SKILLTREESTRINGSEX.WORMWOOD_PETS_PIKO_DESC_EX = "Transform pinecones into Pikos. They help collect scattered resources, but sometimes they seem a bit mischievous."

SKILLTREESTRINGSEX.WORMWOOD_PETS_GRASSGATOR_DESC_EX = "Transform figs into Grass Gators. They have 9 inventory slots, feed them with vegetarian food in the 5th slot. Grass Gators avoid combat when they have items in their inventory. Remove all items to let them assist you in battle."

SKILLTREESTRINGSEX.WORMWOOD_PETS_FLYTRAP_DESC_EX = "Transform Fleshy Bulbs into Venus Flytraps. They grow with each meal, reaching 1600 health at max stage and gaining planar attributes. Transform them into Elder Mandrakes with Mandrake roots, their attacks accumulate 1 sleep point on enemies."



SKILLTREESTRINGSEX.WORMWOOD_MUSHROOMPLANTER_UPGRADE_DESC_EX = "Mushroom farms yield more mushrooms. Eating tricolor mushrooms grants various effects for " .. string.format("%d", mushroom_buff_time) .. "s. Red: +10% dmg, Blue: -15% dmg taken, Green: +20% lunar affinity. Repeatedly eating resets duration, but different effects don't stack. Each mushroom eaten has a small chance to unlock the corresponding mushroom hat."

SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_MUSHROOMBOMB_DESC_EX = "Learn to craft mushroom bombs that can be thrown on the ground to explode after a delay, dealing area damage. \nRotten mushroom bombs poison enemies."

SKILLTREESTRINGSEX.WORMWOOD_MOON_CAP_EATING_DESC_EX = SKILLTREESTRINGS.MOON_CAP_EATING_DESC .. " Eating all mushroom items increases their effect duration by 50% while in bloom.\nAfter unlocking all the blueprints of three-color mushroom hats, Wormwood could figure out another way to make the moon mushroom hat."

SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_SHROOMCAKE_DESC_EX = "Eating Mushroom Cake grants all mushroom effects at half strength for " .. string.format("%d", shroomcake_buff_time) .. "s. Repeated eating resets duration and stacks with individual mushroom effects. Eating Stuffed Night Cap applies 30 sleep points to all nearby creatures, reducing their damage by 25%, while granting you a sleep aura for " .. string.format("%d", shroombait_buff_time) .. "s, making any creature that approaches you fall asleep."

SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_MUSHROOMHAT_DESC_EX = "Mushroom hats absorb "..(mushroomhat_damage_absorb*100).."% dmg. Tri-hats: Self mushroom buff. With Lune: "..mushroomhat_consume_val.." bloom/s for AoE buff. Moon hat: Attack to stack random buff. With Infused: "..moon_mushroomhat_consume_val.." bloom/atk for double spores. \"Photosynthesis\" can regenerate hats' freshness when equipped."



SKILLTREESTRINGSEX.WORMWOOD_THORN_CACTUS_DESC_EX = "Learn to transform cactus flesh and birch fruit into each other. Eating it increases bramble spike damage by +5 for 30 seconds. Repeated eating resets duration."

SKILLTREESTRINGSEX.BUGS_DESC_EX = SKILLTREESTRINGS.BUGS_DESC .. "\nWormwood can pick up bees and butterflies by hand."

SKILLTREESTRINGSEX.ARMOR_BRAMBLE_DESC_EX = SKILLTREESTRINGS.ARMOR_BRAMBLE_DESC .. " In bloom, eat Lune Tree Blossom to reduce bramble spikes to 2 hits and consume "..bramblefx_consume_val_1.." bloom per hit."

SKILLTREESTRINGSEX.WORMWOOD_THORN_DECIDUOUSTREE_DESC_EX = "When fighting near the birchnut tree, there is a chance to receive assistance from the poisonous birchnut tree, with a cooldown time of a total day time.In bloom, eat Lune Tree Blossom to plant and instantly grow a Deciduous Tree consuming "..deciduoustree_consume_val.." BP. It creates chaos for "..deciduoustree_time.."s."

SKILLTREESTRINGSEX.WORMWOOD_THORN_IVYSTAFF_DESC_EX = "Craft Ivy Staff, provide 10% extra speed and increase to 25% when you arrive max blooming. Attacks consume durability and root enemies. Throwing consumes more durability, creating two thorn walls at the impact point.\nIn bloom, eat Infused Blossom to throw a protective Brightshade consuming "..ivystaff_lunarplant_consume_val.." bloom for "..ivystaff_lunarplant_time.."s. \"Photosynthesis\" can regenerate Ivy Staff's freshness when equipped."



SKILLTREESTRINGSEX.WORMWOOD_QUICK_SELFFERTILIZER_DESC_EX = "Fertilizer heals faster. Growth Booster accelerates bloom by 30%. Fertilizer healing increased by "..(fertilizer_healing_multi * 100 - 100).."%."

SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_FARMRANGE1_DESC_EX = "First two bloom stages require 25% less bloomness. Faster blooming in light and wet conditions, larger care range. Wormwood gains 5% and 15% speed in bud stage, and all future bloom bonuses, but weaker."

SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_OVERHEATPROTECTION_DESC_EX = "Max bloom stage grants 180 insulation. In bloom, wearing Enlightened Crown or no headgear increases all bloom bonuses and the efficiency of photosynthesis by "..(overheatprotection_buff_multi * 100 - 100).."%."

SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_MAX_UPGRADE_DESC_EX = "Increases Bloom Points to 3600. Under light conditions, energy can be obtained to restore Wormwood's health. Moisture conditions enhance the efficiency of photosynthesis. When health is full, Bloom Points gradually recover. When Bloom Points exceed 1800, energy from photosynthesis can be allocated to other uses, such as refreshing certain item, extending the lifespan of pets, and producing butter."

SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_LUNARTREE_DESC_EX = "High BP attracts Moon Moths. Wormwood can pick them up by hand. Moon Moth freshness syncs with Bloom Point. In bloom, eat Lune Tree Blossom to plant a Lunar Tree consuming "..lunartree_consume_val.." BP. The planted tree grows quickly and heals all allies around it for 60s. \"Photosynthesis\" can keep Moon Moths alive. The Mothling you adopted can obtain moon energy from the moonlight and can heal injured players and help you with energy supply tasks."

SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_OPALSTAFF_DESC_EX = "Wormwood's Moon Caller Staff creates a Moonlight Aura that grants 10% extra lunar affinity effect to nearby allies. In bloom, eat Lune Tree Blossom to consume "..opalstaff_frozen_consume_val.." BP, releasing an Aurora that gradually freezes nearby creatures for "..opalstaff_frozen_exist_val.."s. Also, eat Infused Lune Tree Blossom and consume "..opalstaff_summon_consume_val.." BP to summon gestals and grazers in a wide area for "..opalstaff_summon_exist_val.."s."



SKILLTREESTRINGSEX.LUNAR_GEAR_1_DESC_EX = SKILLTREESTRINGS.LUNAR_GEAR_1_DESC .. "\nIn bloom, eat Infused Lune Tree Blossom to consume "..bramblefx_consume_val_2.." BP per attack, causing every hit to release a spike burst."

SKILLTREESTRINGSEX.LUNAR_GEAR_2_DESC_EX = SKILLTREESTRINGS.LUNAR_GEAR_2_DESC .. "\nIn bloom, eat Infused Lune Tree Blossom to consume "..vine_consume_val.." BP per attack, increasing vine summon chance to 50%."


SKILLTREESTRINGSEX.WORMWOOD_IDENTIFY_PLANTS2_TITLE_EX = "Moon Sprout"
SKILLTREESTRINGSEX.WORMWOOD_PETS_CARRAT_TITLE_EX = "Moon Gatherer"
SKILLTREESTRINGSEX.LUNAR_MUTATIONS_2_TITLE_EX = "Moon Illuminator"
SKILLTREESTRINGSEX.WORMWOOD_PETS_PIKO_TITLE_EX = "Exotic Collector"
SKILLTREESTRINGSEX.LUNAR_MUTATIONS_3_TITLE_EX = "Moon Defender"
SKILLTREESTRINGSEX.WORMWOOD_PETS_GRASSGATOR_TITLE_EX = "Moon Hauler"
SKILLTREESTRINGSEX.WORMWOOD_PETS_FLYTRAP_TITLE_EX = "Exotic Predator"
SKILLTREESTRINGSEX.MUSHROOMPLANTER_RATEBONUS_2_TITLE_EX = "Mushroom Culturist"
SKILLTREESTRINGSEX.WORMWOOD_MUSHROOMPLANTER_UPGRADE_TITLE_EX = "Mushroom Feast"
SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_MUSHROOMBOMB_TITLE_EX = "Mushroom Explosives"
SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_SHROOMCAKE_TITLE_EX = "Mushroom Gourmet"
SKILLTREESTRINGSEX.WORMWOOD_MUSHROOM_MUSHROOMHAT_TITLE_EX = "Mushroom Protection"
SKILLTREESTRINGSEX.WORMWOOD_THORN_CACTUS_TITLE_EX = "Spike Retort"
SKILLTREESTRINGSEX.WORMWOOD_THORN_DECIDUOUSTREE_TITLE_EX = "Birch Botherer"
SKILLTREESTRINGSEX.WORMWOOD_THORN_IVYSTAFF_TITLE_EX = "Ivy Spreader"
SKILLTREESTRINGSEX.WORMWOOD_QUICK_SELFFERTILIZER_TITLE_EX = "Efficient Absorption"
SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_FARMRANGE1_TITLE_EX = "Impatient Bloom"
SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_OVERHEATPROTECTION_TITLE_EX = "Radiant Bloom"
SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_MAX_UPGRADE_TITLE_EX = "Photosynthesis"
SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_LUNARTREE_TITLE_EX = "Lunar Tree Therapy"
SKILLTREESTRINGSEX.WORMWOOD_BLOOMING_OPALSTAFF_TITLE_EX = "Moonlight Descent"