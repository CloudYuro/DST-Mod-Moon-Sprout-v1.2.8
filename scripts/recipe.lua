-- 我沃姆伍德想搓啥就搓啥，在永恒领域就是自由的爹，敢不敢来跟我沃姆伍德比划比划
env.STRINGS = GLOBAL.STRINGS -- 预设置
env.RECIPETABS = GLOBAL.RECIPETABS 

AllRecipes.wormwood_sapling.builder_tag = "plantkin"
AllRecipes.wormwood_berrybush.builder_tag = "plantkin"
AllRecipes.wormwood_berrybush2.builder_tag = "plantkin"
AllRecipes.wormwood_juicyberrybush.builder_tag = "plantkin"
AllRecipes.wormwood_reeds.builder_tag = "plantkin"
AllRecipes.wormwood_lureplant.builder_tag = "plantkin"
AllRecipes.ipecacsyrup.builder_tag = "plantkin"

AllRecipes.wormwood_sapling.builder_skill = nil
AllRecipes.wormwood_berrybush.builder_skill = nil
AllRecipes.wormwood_berrybush2.builder_skill = nil
AllRecipes.wormwood_juicyberrybush.builder_skill = nil
AllRecipes.wormwood_reeds.builder_skill = nil
AllRecipes.wormwood_lureplant.builder_skill = nil
AllRecipes.ipecacsyrup.builder_skill = nil

Recipe2("wormwood_carrat",		        {Ingredient("moon_tree_blossom", 1),  Ingredient("carrot", 1)},											                                        TECH.NONE,	{builder_skill="wormwood_pets_carrat", product="wormwood_mutantproxy_carrat",      sg_state="spawn_mutated_creature", actionstr="TRANSFORM", no_deconstruction=true, dropitem=true, nameoverride = "carrat", description="wormwood_carrat", canbuild = function(inst, builder) return (builder.components.petleash and not builder.components.petleash:IsFullForPrefab("wormwood_carrat")), "HASPET" end}) -- FIXME(JBK): "HASPET" to its own thing.
Recipe2("wormwood_lightflier",			{Ingredient("moon_tree_blossom", 2), Ingredient("lightbulb", 1)},										TECH.NONE,	{builder_skill="wormwood_pets_lightflier", product="wormwood_mutantproxy_lightflier",  sg_state="spawn_mutated_creature", actionstr="TRANSFORM", no_deconstruction=true, dropitem=true, nameoverride = "lightflier", description="wormwood_lightflier", canbuild = function(inst, builder) return (builder.components.petleash and not builder.components.petleash:IsFullForPrefab("wormwood_lightflier")), "HASPET" end})
Recipe2("wormwood_fruitdragon",			{Ingredient("moon_tree_blossom", 5), Ingredient("dragonfruit", 1)},									TECH.NONE,	{builder_skill="wormwood_pets_fruitdragon", product="wormwood_mutantproxy_fruitdragon", sg_state="spawn_mutated_creature", actionstr="TRANSFORM", no_deconstruction=true, dropitem=true, nameoverride = "fruitdragon", description="wormwood_fruitdragon", canbuild = function(inst, builder) return (builder.components.petleash and not builder.components.petleash:IsFullForPrefab("wormwood_fruitdragon")), "HASPET" end})

AddRecipe2("wormwood_piko",		{Ingredient("moon_tree_blossom", 2), Ingredient("pinecone", 1)},									TECH.NONE,	{builder_skill="wormwood_pets_piko", product="wormwood_mutantproxy_piko", sg_state="spawn_mutated_creature", actionstr="TRANSFORM", no_deconstruction=true, dropitem=true, description="wormwood_piko", canbuild = function(inst, builder) return (builder.components.petleash and not builder.components.petleash:IsFullForPrefab("wormwood_piko")), "HASPET" end,
        builder_tag = "plantkin",
        atlas = "images/inventoryimages/wormwood_piko.xml",
        image = "wormwood_piko.tex"}, 
        {"CHARACTER"})

AddRecipe2("wormwood_piko_orange",		{Ingredient("moon_tree_blossom", 2), Ingredient("acorn", 1)},									TECH.NONE,	{builder_skill="wormwood_pets_piko", product="wormwood_mutantproxy_piko_orange", sg_state="spawn_mutated_creature", actionstr="TRANSFORM", no_deconstruction=true, dropitem=true, description="wormwood_piko_orange", canbuild = function(inst, builder) return (builder.components.petleash and not builder.components.petleash:IsFullForPrefab("wormwood_piko_orange")), "HASPET" end,
        builder_tag = "plantkin",
        atlas = "images/inventoryimages/wormwood_piko_orange.xml",
        image = "wormwood_piko_orange.tex"}, 
        {"CHARACTER"})

AddRecipe2("wormwood_grassgator",		{Ingredient("moon_tree_blossom", 10), Ingredient("fig", 1)},									TECH.NONE,	{builder_skill="wormwood_pets_grassgator", product="wormwood_mutantproxy_grassgator", sg_state="spawn_mutated_creature", actionstr="TRANSFORM", no_deconstruction=true, dropitem=true, nameoverride = "grassgator", description="wormwood_grassgator", canbuild = function(inst, builder) return (builder.components.petleash and not builder.components.petleash:IsFullForPrefab("wormwood_grassgator")), "HASPET" end,
        builder_tag = "plantkin",
        atlas = "images/inventoryimages/wormwood_grassgator.xml",
        image = "wormwood_grassgator.tex"}, 
        {"CHARACTER"})

AddRecipe2("wormwood_flytrap",		{Ingredient("moon_tree_blossom", 5), Ingredient("lureplantbulb", 1)},									TECH.NONE,	{builder_skill="wormwood_pets_flytrap", product="wormwood_mutantproxy_flytrap", sg_state="spawn_mutated_creature", actionstr="TRANSFORM", no_deconstruction=true, dropitem=true, description="wormwood_flytrap", canbuild = function(inst, builder) return (builder.components.petleash and not builder.components.petleash:IsFullForPrefab("wormwood_flytrap")), "HASPET" end,
        builder_tag = "plantkin",
        atlas = "images/inventoryimages/wormwood_flytrap.xml",
        image = "wormwood_flytrap.tex"},
        {"CHARACTER"})

AddRecipe2("wormwood_mandrakeman",		{Ingredient("moon_tree_blossom", 5), Ingredient("mandrake", 1)},									TECH.NONE,	{builder_skill="wormwood_pets_flytrap", product="wormwood_mutantproxy_mandrakeman", sg_state="spawn_mutated_creature", actionstr="TRANSFORM", no_deconstruction=true, dropitem=true, description="wormwood_mandrakeman", canbuild = function(inst, builder) return (builder.components.petleash and not builder.components.petleash:IsFullForPrefab("wormwood_mandrakeman")), "HASPET" end,
        builder_tag = "plantkin",
        atlas = "images/inventoryimages/wormwood_mandrakeman.xml",
        image = "wormwood_mandrakeman.tex"}, 
        {"CHARACTER"})

AddRecipe2("mandrake_active",		{Ingredient("greengem", 2), Ingredient("moon_tree_blossom", 5), Ingredient("carrot", 1)},									TECH.NONE,	{builder_skill="wormwood_pets_flytrap", product="wormwood_mutantproxy_mandrake_active", sg_state="spawn_mutated_creature", actionstr="TRANSFORM", no_deconstruction=true, dropitem=true, description="mandrake_active", canbuild = function(inst, builder) return (builder.components.petleash and not builder.components.petleash:IsFullForPrefab("mandrake_active")), "HASPET" end,
        builder_tag = "plantkin",
        description = "mandrake_active",
        atlas = "images/inventoryimages/mandrake_planted.xml",
        image = "mandrake_planted.tex"}, 
        {"CHARACTER"})

AddRecipe2("book_moonpets",
        {Ingredient("papyrus", 2), Ingredient("moon_tree_blossom", 1)}, 
        TECH.SCIENCE_ONE, 
        {builder_skill = "wormwood_pets_carrat", 
        builder_tag = "plantkin",
        atlas = "images/inventoryimages/book_moonpets.xml",
        image = "book_moonpets.tex"},
        {"CHARACTER"})

-- AddRecipe2("mandrake",		
--         {Ingredient("greengem", 1), Ingredient("moon_tree_blossom", 1), Ingredient("carrot", 1)},									
--         TECH.NONE,	
--         {builder_skill="wormwood_pets_flytrap", 
--         builder_tag = "plantkin",
--         description = "mandrake",}, 
--         {"CHARACTER"})

AddRecipe2("wormwood_mushroombomb",
        {Ingredient("charcoal", 1), Ingredient("red_cap", 1), Ingredient("blue_cap", 1), Ingredient("green_cap", 1)}, 
        TECH.NONE, 
        {builder_skill = "wormwood_mushroom_mushroombomb", 
        builder_tag = "plantkin",
        description = "wormwood_mushroombomb", 
        atlas = "images/inventoryimages/wormwood_mushroombomb.xml",
        image = "wormwood_mushroombomb.tex"},
        {"CHARACTER"})

AllRecipes.wormwood_mushroombomb.numtogive = 1

AddRecipe2("wormwood_mushroombomb_gas",
        {Ingredient("canary_poisoned", 1), Ingredient("red_cap", 1), Ingredient("blue_cap", 1), Ingredient("green_cap", 1)}, 
        TECH.NONE, 
        {builder_skill = "disable_to_make", 
        builder_tag = "plantkin",
        atlas = "images/inventoryimages/wormwood_mushroombomb_gas.xml",
        image = "wormwood_mushroombomb_gas.tex",
        description = "wormwood_mushroombomb_gas"},
        {"CHARACTER"})

-- AllRecipes.wormwood_mushroombomb_gas.numtogive = 1

AddRecipe2("wormwood_red_mushroomhat",		{Ingredient("red_cap", 6)},	
        TECH.LOST, 
        {builder_tag = "plantkin",
        builder_skill = "wormwood_mushroomplanter_upgrade",
        product = "red_mushroomhat",
        description = "red_mushroomhat",},
        {"CHARACTER"})

AddRecipe2("wormwood_blue_mushroomhat",		{Ingredient("blue_cap", 6)},	
        TECH.LOST, 
        {builder_tag = "plantkin",
        builder_skill = "wormwood_mushroomplanter_upgrade",
        product = "blue_mushroomhat",
        description = "blue_mushroomhat",},
        {"CHARACTER"})

AddRecipe2("wormwood_green_mushroomhat",		{Ingredient("green_cap", 6)},	
        TECH.LOST, 
        {builder_tag = "plantkin",
        builder_skill = "wormwood_mushroomplanter_upgrade",
        product = "green_mushroomhat",
        description = "green_mushroomhat",},
        {"CHARACTER"})

AddRecipe2("wormwood_moon_mushroomhat",		{Ingredient("red_cap", 2), Ingredient("blue_cap", 2), Ingredient("green_cap", 2), Ingredient("moon_cap", 4)},	
        TECH.LOST, 
        {builder_tag = "plantkin",
        builder_skill = "wormwood_moon_cap_eating",
        atlas = "images/inventoryimages/wormwood_moon_mushroomhat.xml",
        image = "wormwood_moon_mushroomhat.tex"},
        {"CHARACTER"})

AddRecipe2("wormwood_cactus_meat",
        {Ingredient("moon_tree_blossom", 2), Ingredient("acorn", 1)}, 
        TECH.NONE, 
        {builder_skill = "wormwood_thorn_cactus", 
        builder_tag = "plantkin",
        product = "cactus_meat",
        description = "cactus_meat"},
        {"CHARACTER"})
        
AddRecipe2("wormwood_acorn",
        {Ingredient("moon_tree_blossom", 2), Ingredient("cactus_meat", 1)}, 
        TECH.NONE, 
        {builder_skill = "wormwood_thorn_cactus", 
        builder_tag = "plantkin",
        product = "acorn",
        description = "acorn"},
        {"CHARACTER"})
        
-- AddRecipe2("dug_marsh_bush",
--         {Ingredient(CHARACTER_INGREDIENT.SANITY, 15), Ingredient("moon_tree_blossom", 1), Ingredient("dug_sapling_moon", 1) }, 
--         TECH.NONE, 
--         {builder_skill = "wormwood_identify_plants2", 
--         builder_tag = "plantkin"},
--         {"CHARACTER"})


AddRecipe2("ivystaff",
        {Ingredient("moon_tree_blossom", 1), Ingredient("livinglog", 2), Ingredient("cactus_meat", 4), }, 
        TECH.NONE, 
        {builder_skill = "wormwood_thorn_ivystaff", 
        builder_tag = "plantkin",
        description = "ivystaff", 
        atlas = "images/inventoryimages/ivystaff.xml",
        image = "ivystaff.tex"},
        {"CHARACTER"})

AddRecipe2("wormwood_petals",
        {Ingredient(CHARACTER_INGREDIENT.HEALTH, 5)}, 
        TECH.NONE, 
        {builder_tag = "plantkin",
        product = "petals",
        description = "petals"},
        {"CHARACTER"})
AllRecipes.wormwood_petals.numtogive = 5

AddRecipe2("wormwood_moon_tree_blossom",
        {Ingredient(CHARACTER_INGREDIENT.HEALTH, 10), Ingredient(CHARACTER_INGREDIENT.SANITY, 10)}, 
        TECH.NONE, 
        {builder_skill = "wormwood_identify_plants2", 
        builder_tag = "plantkin",
        product = "moon_tree_blossom"},
        {"CHARACTER"})
AllRecipes.wormwood_moon_tree_blossom.numtogive = 3

AddRecipe2("moon_tree_blossom_charged",
        {Ingredient("moon_tree_blossom", 3), Ingredient("purebrilliance", 1)}, 
        TECH.NONE, 
        {builder_skill = "wormwood_identify_plants2", 
        builder_tag = "plantkin",
        atlas = "images/inventoryimages/moon_tree_blossom_charged.xml",
        image = "moon_tree_blossom_charged.tex"},
        {"CHARACTER"})
AllRecipes.moon_tree_blossom_charged.numtogive = 3

AddRecipe2("wormwood_corkchest", 
        {Ingredient("fertilizer", 2), Ingredient("livinglog", 2), Ingredient("nitre", 4)},
	TECH.SCIENCE_TWO,
	{placer= "wormwood_corkchest_placer", min_spacing= 1.5,builder_tag="plantkin",testfn=function(pt) return not (TheWorld.Map:GetPlatformAtPoint(pt.x, 0, pt.z, -0.5) or TheWorld.Map:IsDockAtPoint(pt.x, 0, pt.z)) end,
		atlas="images/inventoryimages/corkchest.xml", image= "corkchest.tex"}, 
	{"CONTAINERS","CHARACTER"})

AddRecipe2("wormwood_bullkelp_root",
        {Ingredient("kelp", 6), Ingredient("moon_tree_blossom", 3)}, 
        TECH.NONE, 
        {builder_tag = "plantkin",
        description = "bullkelp_root",
        product = "bullkelp_root"},
        {"CHARACTER"})

AddRecipe2("wormwood_dug_bananabush",
        {Ingredient("dug_berrybush2", 1), Ingredient("cave_banana", 6), Ingredient("moon_tree_blossom", 3)}, 
        TECH.NONE, 
        {builder_tag = "plantkin",
        description = "dug_bananabush",
        product = "dug_bananabush"},
        {"CHARACTER"})

AddRecipe2("wormwood_rock_avocado_fruit_sprout",
        {Ingredient("dug_berrybush", 1), Ingredient("rock_avocado_fruit_ripe", 12), Ingredient("moon_tree_blossom", 3)}, 
        TECH.NONE, 
        {builder_tag = "plantkin",
        description = "rock_avocado_fruit_sprout",
        product = "rock_avocado_fruit_sprout"},
        {"CHARACTER"})

AddRecipe2("wormwood_ancienttree_seed",
        {Ingredient("rock_avocado_fruit_sprout", 1), Ingredient("opalpreciousgem", 1), Ingredient("moon_tree_blossom", 10)}, 
        TECH.NONE, 
        {builder_tag = "plantkin",
        description = "ancienttree_seed",
        product = "ancienttree_seed"},
        {"CHARACTER"})