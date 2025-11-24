---------------------------------------------------------------------------------
--                            REDM NATIVE ABILITIES                            --
--                            Configuration Module                             --
--       Contains all configuration data for ability cards and categories      --
---------------------------------------------------------------------------------

local Config = {}

-- The available ability card slots with unlock requirements
Config.slots = {
    { id = "active_slot", title = nil, titleHash = "NET_PLAYER_ABILITY_ACTIVE_SLOT_TITLE", rank = 0 },
    { id = "passive_slot_1", title = nil, titleHash = "NET_PLAYER_ABILITY_PASSIVE_SLOT_1_TITLE", rank = 10 },
    { id = "passive_slot_2", title = nil, titleHash = "NET_PLAYER_ABILITY_PASSIVE_SLOT_2_TITLE", rank = 20 },
    { id = "passive_slot_3", title = nil, titleHash = "NET_PLAYER_ABILITY_PASSIVE_SLOT_3_TITLE", rank = 40 },
}

-- Available ability card categories with their textures
Config.categories = {
    { id = "deadeye", title = nil, titleHash = "NET_PLAYER_ABILITY_CATEGORY_TITLE_DEAD_EYE", txd = "MENU_TEXTURES", texture = "MENU_ICON_ABILITY_DEADEYE" },
    { id = "recovery", title = nil, titleHash = "NET_PLAYER_ABILITY_CATEGORY_TITLE_RECOVERY", txd = "MENU_TEXTURES", texture = "MENU_ICON_ABILITY_RECOVERY" },
    { id = "combat", title = nil, titleHash = "NET_PLAYER_ABILITY_CATEGORY_TITLE_COMBAT", txd = "MENU_TEXTURES", texture = "MENU_ICON_ABILITY_COMBAT" },
    { id = "defense", title = nil, titleHash = "NET_PLAYER_ABILITY_CATEGORY_TITLE_DEFENSE", txd = "MENU_TEXTURES", texture = "MENU_ICON_ABILITY_DEFENSE" }
}

-- Standard tier progression (XP requirements and cash costs)
Config.standardTiers = {
    { xp = 2500, cash = 10000 },
    { xp = 10000, cash = 35000 },
    { xp = nil, cash = 50000 }  -- Final tier has no XP requirement
}

-- Helper function to create card with standard tier progression
local function createCard(category, id, rank, labelHash, txd, texture, descPrefix)
    return {
        category = category,
        id = id,
        rank = rank,
        label = nil,
        labelHash = labelHash,
        txd = txd,
        texture = texture,
        tiers = {
            {
                xp = Config.standardTiers[1].xp,
                cash = Config.standardTiers[1].cash,
                description = nil,
                descriptionHash = descPrefix .. "_TIER_ONE_DESC"
            },
            {
                xp = Config.standardTiers[2].xp,
                cash = Config.standardTiers[2].cash,
                description = nil,
                descriptionHash = descPrefix .. "_TIER_TWO_DESC"
            },
            {
                xp = Config.standardTiers[3].xp,
                cash = Config.standardTiers[3].cash,
                description = nil,
                descriptionHash = descPrefix .. "_TIER_THREE_DESC"
            }
        }
    }
end

-- All ability cards organized by category
Config.cards = {
    -- Dead Eye Cards (Active Slot Only)
    createCard("deadeye", "net_player_ability__a_moment_to_recuperate", 2, "ABILITY_CARD_A_MOMENT_TO_RECUPERATE", "ability_cards_set_a", "ability_card_a_moment_to_recuperate", "ABILITY_CARD_A_MOMENT_TO_RECUPERATE"),
    createCard("deadeye", "net_player_ability__focus_fire", 2, "ABILITY_CARD_FOCUS_FIRE", "ability_cards_set_a", "ability_card_focus_fire", "ABILITY_CARD_FOCUS_FIRE"),
    createCard("deadeye", "net_player_ability__paint_it_black", 2, "ABILITY_CARD_PAINT_IT_BLACK", "ability_cards_set_a", "ability_card_paint_it_black", "ABILITY_CARD_PAINT_IT_BLACK"),
    createCard("deadeye", "net_player_ability__slow_and_steady", 24, "ABILITY_CARD_SLOW_AND_STEADY", "ability_cards_set_a", "ability_card_slow_and_steady", "ABILITY_CARD_SLOW_AND_STEADY"),
    createCard("deadeye", "net_player_ability__quite_an_inspiration", 44, "ABILITY_CARD_QUITE_AN_INSPIRATION", "ability_cards_set_a", "ability_card_quite_an_inspiration", "ABILITY_CARD_QUITE_AN_INSPIRATION"),
    createCard("deadeye", "net_player_ability__slippery_bastard", 50, "ABILITY_CARD_SLIPPERY_BASTARD", "ability_cards_set_a", "ability_card_slippery_bastard", "ABILITY_CARD_SLIPPERY_BASTARD"),

    -- Recovery Cards (Passive Slots)
    createCard("recovery", "net_player_ability__come_back_stronger", 10, "ABILITY_CARD_COME_BACK_STRONGER", "ability_cards_set_b", "ability_card_come_back_stronger", "ABILITY_CARD_COME_BACK_STRONGER"),
    createCard("recovery", "net_player_ability__iron_lung", 10, "ABILITY_CARD_IRON_LUNG", "ability_cards_set_b", "ability_card_iron_lung", "ABILITY_CARD_IRON_LUNG"),
    createCard("recovery", "net_player_ability__kick_in_the_butt", 10, "ABILITY_CARD_KICK_IN_THE_BUTT", "ability_cards_set_b", "ability_card_kick_in_the_butt", "ABILITY_CARD_KICK_IN_THE_BUTT"),
    createCard("recovery", "net_player_ability__live_for_the_fight", 10, "ABILITY_CARD_LIVE_FOR_THE_FIGHT", "ability_cards_set_b", "ability_card_live_for_the_fight", "ABILITY_CARD_LIVE_FOR_THE_FIGHT"),
    createCard("recovery", "net_player_ability__ride_like_the_wind", 10, "ABILITY_CARD_RIDE_LIKE_THE_WIND", "ability_cards_set_b", "ability_card_ride_like_the_wind", "ABILITY_CARD_RIDE_LIKE_THE_WIND"),
    createCard("recovery", "net_player_ability__peak_condition", 14, "ABILITY_CARD_PEAK_CONDITION", "ability_cards_set_b", "ability_card_peak_condition", "ABILITY_CARD_PEAK_CONDITION"),
    createCard("recovery", "net_player_ability__eye_for_an_eye", 28, "ABILITY_CARD_EYE_FOR_AN_EYE", "ability_cards_set_b", "ability_card_eye_for_an_eye", "ABILITY_CARD_EYE_FOR_AN_EYE"),
    createCard("recovery", "net_player_ability__strange_medicine", 32, "ABILITY_CARD_STRANGE_MEDICINE", "ability_cards_set_b", "ability_card_strange_medicine", "ABILITY_CARD_STRANGE_MEDICINE"),
    createCard("recovery", "net_player_ability__cold_blooded", 36, "ABILITY_CARD_COLD_BLOODED", "ability_cards_set_b", "ability_card_cold_blooded", "ABILITY_CARD_COLD_BLOODED"),
    createCard("recovery", "net_player_ability__the_gift_of_focus", 40, "ABILITY_CARD_THE_GIFT_OF_FOCUS", "ability_cards_set_b", "ability_card_the_gift_of_focus", "ABILITY_CARD_THE_GIFT_OF_FOCUS"),

    -- Combat Cards (Passive Slots)
    createCard("combat", "net_player_ability__gunslingers_choice", 10, "ABILITY_CARD_GUNSLINGERS_CHOICE", "ability_cards_set_c", "ability_card_gunslingers_choice", "ABILITY_CARD_GUNSLINGERS_CHOICE"),
    createCard("combat", "net_player_ability__horseman", 10, "ABILITY_CARD_HORSEMAN", "ability_cards_set_c", "ability_card_horseman", "ABILITY_CARD_HORSEMAN"),
    createCard("combat", "net_player_ability__sharpshooter", 10, "ABILITY_CARD_SHARPSHOOTER", "ability_cards_set_c", "ability_card_sharpshooter", "ABILITY_CARD_SHARPSHOOTER"),
    createCard("combat", "net_player_ability__necessity_breeds", 16, "ABILITY_CARD_NECESSITY_BREEDS", "ability_cards_set_c", "ability_card_necessity_breeds", "ABILITY_CARD_NECESSITY_BREEDS"),
    createCard("combat", "net_player_ability__landons_patience", 18, "ABILITY_CARD_LANDONS_PATIENCE", "ability_cards_set_c", "ability_card_landons_patience", "ABILITY_CARD_LANDONS_PATIENCE"),
    createCard("combat", "net_player_ability__the_short_game", 38, "ABILITY_CARD_THE_SHORT_GAME", "ability_cards_set_c", "ability_card_the_short_game", "ABILITY_CARD_THE_SHORT_GAME"),
    createCard("combat", "net_player_ability__hangman", 42, "ABILITY_CARD_HANGMAN", "ability_cards_set_c", "ability_card_hangman", "ABILITY_CARD_HANGMAN"),
    createCard("combat", "net_player_ability__winning_streak", 48, "ABILITY_CARD_WINNING_STREAK", "ability_cards_set_c", "ability_card_winning_streak", "ABILITY_CARD_WINNING_STREAK"),

    -- Defense Cards (Passive Slots)
    createCard("defense", "net_player_ability__fool_me_once", 10, "ABILITY_CARD_FOOL_ME_ONCE", "ability_cards_set_d", "ability_card_fool_me_once", "ABILITY_CARD_FOOL_ME_ONCE"),
    createCard("defense", "net_player_ability__friends_for_life", 10, "ABILITY_CARD_FRIENDS_FOR_LIFE", "ability_cards_set_d", "ability_card_friends_for_life", "ABILITY_CARD_FRIENDS_FOR_LIFE"),
    createCard("defense", "net_player_ability__strength_in_numbers", 10, "ABILITY_CARD_STRENGTH_IN_NUMBERS", "ability_cards_set_d", "ability_card_strength_in_numbers", "ABILITY_CARD_STRENGTH_IN_NUMBERS"),
    createCard("defense", "net_player_ability__hunker_down", 20, "ABILITY_CARD_HUNKER_DOWN", "ability_cards_set_d", "ability_card_hunker_down", "ABILITY_CARD_HUNKER_DOWN"),
    createCard("defense", "net_player_ability__to_fight_another_day", 22, "ABILITY_CARD_TO_FIGHT_ANOTHER_DAY", "ability_cards_set_d", "ability_card_to_fight_another_day", "ABILITY_CARD_TO_FIGHT_ANOTHER_DAY"),
    createCard("defense", "net_player_ability__the_unblinking_eye", 26, "ABILITY_CARD_THE_UNBLINKING_EYE", "ability_cards_set_d", "ability_card_the_unblinking_eye", "ABILITY_CARD_THE_UNBLINKING_EYE"),
    createCard("defense", "net_player_ability__take_the_pain_away", 34, "ABILITY_CARD_TAKE_THE_PAIN_AWAY", "ability_cards_set_d", "ability_card_take_the_pain_away", "ABILITY_CARD_TAKE_THE_PAIN_AWAY"),
    createCard("defense", "net_player_ability__of_single_purpose", 40, "ABILITY_CARD_OF_SINGLE_PURPOSE", "ability_cards_set_d", "ability_card_of_single_purpose", "ABILITY_CARD_OF_SINGLE_PURPOSE"),
    createCard("defense", "net_player_ability__never_without_one", 46, "ABILITY_CARD_NEVER_WITHOUT_ONE", "ability_cards_set_d", "ability_card_never_without_one", "ABILITY_CARD_NEVER_WITHOUT_ONE"),
}

-- Color mapping lookup table for card tiers by category
Config.cardColors = {
    deadeye = {
        [1] = joaat("ABILITY_CARD_DEAD_EYE_TIER_1"),
        [2] = joaat("ABILITY_CARD_DEAD_EYE_TIER_2"),
        [3] = joaat("ABILITY_CARD_DEAD_EYE_TIER_3"),
        [4] = joaat("ABILITY_CARD_DEAD_EYE_TIER_4")
    },
    combat = {
        [1] = joaat("ABILITY_CARD_COMBAT_TIER_1"),
        [2] = joaat("ABILITY_CARD_COMBAT_TIER_2"),
        [3] = joaat("ABILITY_CARD_COMBAT_TIER_3"),
        [4] = joaat("ABILITY_CARD_COMBAT_TIER_4")
    },
    defense = {
        [1] = joaat("ABILITY_CARD_DEFENSE_TIER_1"),
        [2] = joaat("ABILITY_CARD_DEFENSE_TIER_2"),
        [3] = joaat("ABILITY_CARD_DEFENSE_TIER_3"),
        [4] = joaat("ABILITY_CARD_DEFENSE_TIER_4")
    },
    recovery = {
        [1] = joaat("ABILITY_CARD_RECOVERY_TIER_1"),
        [2] = joaat("ABILITY_CARD_RECOVERY_TIER_2"),
        [3] = joaat("ABILITY_CARD_RECOVERY_TIER_3"),
        [4] = joaat("ABILITY_CARD_RECOVERY_TIER_4")
    }
}

-- Slot compatibility rules
Config.slotRules = {
    deadeye = "active_slot",  -- Deadeye cards can only go in active slot
    recovery = "passive",      -- Recovery cards go in passive slots
    combat = "passive",        -- Combat cards go in passive slots
    defense = "passive"        -- Defense cards go in passive slots
}

-- Make Config globally available
_G.Config = Config
return Config
