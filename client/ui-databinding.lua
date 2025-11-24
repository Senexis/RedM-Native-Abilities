---------------------------------------------------------------------------------
--                            REDM NATIVE ABILITIES                            --
--                            UI Databinding Module                            --
--         Handles databinding container initialization and UI updates         --
---------------------------------------------------------------------------------

local UIDataBinding = {}

-- Databinding containers (initialized once)
local dataBindings = {
    abilityCardData = 0,
    abilityCardFocusData = 0,
    abilityCardLoadoutFocusData = 0,
    abilityCardUpgradeFocusData = 0,
    loadoutCollection = 0,
    upgradeCollection = 0,
    browseCollection = 0,
    categoryIcons = 0,
    loadoutCards = {},              -- Array of databinding containers for loadout cards
    upgradeCards = {},              -- Array of databinding containers for upgrade cards
    browseCards = {},               -- Array of databinding containers for browse cards
    categoryIconsData = {}          -- Array of databinding containers for category icons
}

-- Initialize a base ability card container with all properties
function UIDataBinding.initializeBaseAbilityCardRoot(datastore, id)
    local data = DatabindingAddDataContainer(datastore, id)

    -- General card properties
    DatabindingAddDataHash(data, "ability_card_ability_hash", 0)
    DatabindingAddDataBool(data, "ability_card_display", false)
    DatabindingAddDataBool(data, "ability_card_is_deadeye", false)

    DatabindingAddDataHash(data, "ability_card_texture_dictionary", 0)
    DatabindingAddDataHash(data, "ability_card_texture", 0)
    DatabindingAddDataHash(data, "ability_card_color", 0)

    DatabindingAddDataString(data, "ability_card_title", "")
    DatabindingAddDataString(data, "ability_card_description", "")

    -- Ownership
    DatabindingAddDataBool(data, "ability_card_owned", false)
    DatabindingAddDataBool(data, "ability_card_not_owned", true)

    -- Equipment states
    DatabindingAddDataBool(data, "ability_card_equippable", false)
    DatabindingAddDataBool(data, "ability_card_equipped", false)
    DatabindingAddDataBool(data, "ability_card_locked", false)
    DatabindingAddDataBool(data, "ability_card_inactive", false)

    -- Purchase states
    DatabindingAddDataBool(data, "ability_card_buyable", false)
    DatabindingAddDataString(data, "ability_card_buyable_text", "IB_BUY")
    DatabindingAddDataBool(data, "ability_card_buyable_with_money", false)
    DatabindingAddDataBool(data, "ability_card_buyable_with_gold", false)
    DatabindingAddDataBool(data, "ability_card_buy_affordable", true)

    -- Upgrade prompt
    DatabindingAddDataBool(data, "ability_card_upgrade_visible", false)
    DatabindingAddDataBool(data, "ability_card_upgrade_enabled", false)
    DatabindingAddDataString(data, "ability_card_upgrade_text", "IB_UPGRADE")

    -- Upgrade states
    DatabindingAddDataBool(data, "ability_card_upgradeable", false)
    DatabindingAddDataBool(data, "ability_card_upgradeable_with_money", false)
    DatabindingAddDataBool(data, "ability_card_upgradeable_with_gold", false)
    DatabindingAddDataBool(data, "ability_card_upgrade_possible", false)
    DatabindingAddDataBool(data, "ability_card_upgrade_affordable", false)

    -- Focus/upgrade pricing
    DatabindingAddDataBool(data, "ability_card_is_affordable", false)
    DatabindingAddDataBool(data, "ability_card_use_money_price", true)
    DatabindingAddDataString(data, "ability_card_price_dollar", "0")
    DatabindingAddDataString(data, "ability_card_price_cents", "00")
    DatabindingAddDataBool(data, "ability_card_use_gold_price", false)
    DatabindingAddDataInt(data, "ability_card_price_gold", 0)

    -- Rank and progression
    DatabindingAddDataInt(data, "ability_card_tier", 0)
    DatabindingAddDataInt(data, "ability_card_rank", 0)
    DatabindingAddDataString(data, "ability_card_rank_text", "0")
    DatabindingAddDataInt(data, "ability_card_current_xp", 0)
    DatabindingAddDataInt(data, "ability_card_min_xp", 0)
    DatabindingAddDataInt(data, "ability_card_max_xp", 0)

    -- Visual effects
    DatabindingAddDataBool(data, "ability_card_glint_visible", false)
    DatabindingAddDataBool(data, "ability_card_pulse_buy", false)
    DatabindingAddDataBool(data, "ability_card_pulse_select", false)

    return data
end

-- Initialize a loadout ability card container with all properties
function UIDataBinding.initializeLoadoutCard(datastore, index)
    local id = "Loadout_Ability_Card_Root_" .. index
    local data = UIDataBinding.initializeBaseAbilityCardRoot(datastore, id)

    -- Additional loadout-specific properties
    DatabindingAddDataInt(data, "ability_card_loadout_index", index)
    DatabindingAddDataString(data, "ability_card_loadout_slot_title", "")
    DatabindingAddDataBool(data, "ability_card_loadout_selectable_visible", false)
    DatabindingAddDataBool(data, "ability_card_loadout_selectable_enabled", false)
    DatabindingAddDataBool(data, "ability_card_loadout_removable_visible", false)
    DatabindingAddDataBool(data, "ability_card_loadout_removable_enabled", false)
    DatabindingAddDataBool(data, "ability_card_active", false)
    DatabindingAddDataInt(data, "ability_card_highlight_opacity", 30)
    DatabindingAddDataBool(data, "ability_card_loadout_unlocked", false)
    DatabindingAddDataString(data, "ability_card_loadout_rank_text", "0")

    return data
end

-- Initialize an upgrade ability card container with all properties
function UIDataBinding.initializeUpgradeCard(datastore, index)
    local id = "Upgrade_Ability_Card_Root_" .. index
    local data = UIDataBinding.initializeBaseAbilityCardRoot(datastore, id)

    -- Additional upgrade-specific properties
    DatabindingAddDataInt(data, "ability_card_upgrade_tier_index", index)
    DatabindingAddDataString(data, "ability_card_upgrade_tier_title", "")

    return data
end

-- Initialize a category icon container with all properties
function UIDataBinding.initializeCategoryIcon(datastore, index)
    local id = "Ability_Card_Category_Filter_" .. index
    local data = DatabindingAddDataContainer(datastore, id)

    DatabindingAddDataBool(data, "dynamic_list_item_main_img_enabled", false)
    DatabindingAddDataHash(data, "dynamic_list_item_main_img_texture_dic", 0)
    DatabindingAddDataHash(data, "dynamic_list_item_main_img_texture", 0)

    return data
end

-- Initialize focus data container with all properties
function UIDataBinding.initializeFocusData(parentDatastore, id)
    local data = UIDataBinding.initializeBaseAbilityCardRoot(parentDatastore, id)

    -- Add focus-specific properties with static names
    DatabindingAddDataString(data, "ability_card_focus_xp_text", "")
    DatabindingAddDataString(data, "ability_card_focus_purchase_type_text", "")
    DatabindingAddDataBool(data, "ability_card_focus_secondary_text_visible", false)
    DatabindingAddDataString(data, "ability_card_focus_secondary_text", "")
    DatabindingAddDataBool(data, "ability_card_focus_info_visible", false)

    return data
end

-- Update a base ability card with card state data
function UIDataBinding.updateBaseAbilityCard(data, cardState, cardData)
    if not data or not cardState then
        return
    end

    local ownership = cardState.ownership or {}
    local pricing = cardState.pricing or {}
    local xp = cardState.xp or {}
    local ui = cardState.ui or {}
    local visuals = cardState.visuals or {}
    local text = cardState.text or {}

    -- Calculate display values with safety checks
    local displayPrice = (ui.isBuyable and pricing.buyPrice) or pricing.nextTierCash or 0
    local showPricing = displayPrice > 0
    local priceDollars, priceCents = math.floor(displayPrice / 100), displayPrice % 100
    local displayRank = cardData and cardData.rank or 0

    -- General card properties
    DatabindingWriteDataHashStringFromParent(data, "ability_card_ability_hash", cardData and joaat(cardData.id) or 0)
    DatabindingWriteDataBoolFromParent(data, "ability_card_display", true)
    DatabindingWriteDataBoolFromParent(data, "ability_card_is_deadeye", (visuals.category or "") == "deadeye")

    DatabindingWriteDataHashStringFromParent(data, "ability_card_texture_dictionary", joaat(visuals.txd or "ability_cards"))
    DatabindingWriteDataHashStringFromParent(data, "ability_card_texture", joaat(visuals.texture or "ability_card_back"))
    DatabindingWriteDataHashStringFromParent(data, "ability_card_color", visuals.color or joaat("COLOR_WHITE"))

    DatabindingWriteDataStringFromParent(data, "ability_card_title", text.title or "")
    DatabindingWriteDataStringFromParent(data, "ability_card_description", text.description or "")

    -- Ownership
    DatabindingWriteDataBoolFromParent(data, "ability_card_owned", ownership.owned or false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_not_owned", not (ownership.owned or false))

    -- Equipment states
    DatabindingWriteDataBoolFromParent(data, "ability_card_equippable", ui.isEquippable or false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_equipped", ownership.equipped or false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_locked", ownership.isLocked or false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_inactive", ui.isInactive or false)

    -- Purchase states
    DatabindingWriteDataBoolFromParent(data, "ability_card_buyable", (ui.isBuyable or false) and showPricing)
    DatabindingWriteDataBoolFromParent(data, "ability_card_buyable_with_money", (ui.canBuyWithMoney or false) and showPricing)
    DatabindingWriteDataBoolFromParent(data, "ability_card_buyable_with_gold", false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_buy_affordable", (ui.isBuyable or false) and showPricing)

    -- Upgrade prompt
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgrade_visible", ui.canUpgrade or false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgrade_enabled", ui.upgradeEnabled or false)

    -- Upgrade states
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgradeable", (ui.canUpgrade or false) and showPricing)
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgradeable_with_money", (ui.canUpgradeWithMoney or false) and showPricing)
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgradeable_with_gold", false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgrade_affordable", (ui.canUpgrade or false) and showPricing)

    -- Focus/upgrade pricing
    DatabindingWriteDataStringFromParent(data, "ability_card_price_dollar", tostring(priceDollars))
    DatabindingWriteDataStringFromParent(data, "ability_card_price_cents", string.format("%02d", priceCents))
    DatabindingWriteDataIntFromParent(data, "ability_card_price_gold", 0)
    DatabindingWriteDataBoolFromParent(data, "ability_card_is_affordable", (ui.isBuyable or false) or (ui.canUpgrade or false))

    -- Rank and progression
    DatabindingWriteDataIntFromParent(data, "ability_card_tier", (ownership.tier or 1) - 1)
    DatabindingWriteDataIntFromParent(data, "ability_card_rank", displayRank)
    DatabindingWriteDataStringFromParent(data, "ability_card_rank_text", tostring(displayRank))
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgrade_possible", ui.canUpgrade or false)
    DatabindingWriteDataIntFromParent(data, "ability_card_current_xp", xp.currentXp or 0)
    DatabindingWriteDataIntFromParent(data, "ability_card_min_xp", xp.minXp or 0)
    DatabindingWriteDataIntFromParent(data, "ability_card_max_xp", xp.maxXp or 0)

    -- Visual effects
    DatabindingWriteDataBoolFromParent(data, "ability_card_glint_visible", ui.upgradeEnabled or false)
end

-- Initialize all databinding containers
function UIDataBinding.initialize()
    local refAbilityCardData = DatabindingGetDataContainerFromPath("ability_card_data")
    if refAbilityCardData == 0 then
        refAbilityCardData = DatabindingAddDataContainerFromPath("", "ability_card_data")
    end
    dataBindings.abilityCardData = refAbilityCardData

    -- Initialize all static databinding properties once
    DatabindingAddDataBool(refAbilityCardData, "hudAbilityCardsVisible", true)
    DatabindingAddDataBool(refAbilityCardData, "allowMenuAccess", true)
    DatabindingAddDataString(refAbilityCardData, "ability_card_primary_title", "")
    DatabindingAddDataString(refAbilityCardData, "ability_card_footer_text", "")
    DatabindingAddDataBool(refAbilityCardData, "ability_card_footer_warning_state", false)
    DatabindingAddDataBool(refAbilityCardData, "ability_card_loadout_back_enabled", true)
    DatabindingAddDataBool(refAbilityCardData, "ability_card_loadout_back_pulse", false)
    DatabindingAddDataBool(refAbilityCardData, "ability_card_browse_back_enabled", true)
    DatabindingAddDataBool(refAbilityCardData, "ability_card_browse_back_pulse", false)
    DatabindingAddDataBool(refAbilityCardData, "ability_card_filter_display", false)
    DatabindingAddDataInt(refAbilityCardData, "ability_card_loadout_initial_index", 0)
    DatabindingAddDataInt(refAbilityCardData, "ability_card_selection_initial_index", 0)

    -- Initialize focus data containers as separate datastores
    dataBindings.abilityCardFocusData = UIDataBinding.initializeFocusData(refAbilityCardData, "ability_card_focus_data")
    dataBindings.abilityCardLoadoutFocusData = UIDataBinding.initializeFocusData(refAbilityCardData, "ability_card_loadout_focus_data")
    dataBindings.abilityCardUpgradeFocusData = UIDataBinding.initializeFocusData(refAbilityCardData, "ability_card_upgrade_focus_data")

    -- Initialize collections
    dataBindings.loadoutCollection = DatabindingAddUiItemList(refAbilityCardData, "ability_card_loadout_collection")
    dataBindings.upgradeCollection = DatabindingAddUiItemList(refAbilityCardData, "ability_card_upgrade_collection")
    dataBindings.browseCollection = DatabindingAddUiItemList(refAbilityCardData, "ability_card_browse_collection")
    dataBindings.categoryIcons = DatabindingAddUiItemList(refAbilityCardData, "ability_card_category_icons")

    -- Clear collections before adding items
    DatabindingClearBindingArray(dataBindings.loadoutCollection)
    DatabindingClearBindingArray(dataBindings.upgradeCollection)
    DatabindingClearBindingArray(dataBindings.browseCollection)
    DatabindingClearBindingArray(dataBindings.categoryIcons)

    return dataBindings
end

-- Get databinding containers
function UIDataBinding.getDataBindings()
    return dataBindings
end

-- Update text properties
function UIDataBinding.updatePrimaryTitle(title)
    DatabindingWriteDataStringFromParent(dataBindings.abilityCardData, "ability_card_primary_title", title)
end

function UIDataBinding.updateFooterText(text)
    DatabindingWriteDataStringFromParent(dataBindings.abilityCardData, "ability_card_footer_text", text)
end

-- Clear collections
function UIDataBinding.clearCollection(collectionName)
    local collection = dataBindings[collectionName]
    if collection then
        DatabindingClearBindingArray(collection)
        if collectionName == "browseCollection" then
            dataBindings.browseCards = {}
        end
    end
end

-- Clear base ability card data to empty/default state
function UIDataBinding.clearBaseAbilityCard(data)
    -- Set empty slot properties directly
    DatabindingWriteDataHashStringFromParent(data, "ability_card_ability_hash", 0)
    DatabindingWriteDataBoolFromParent(data, "ability_card_display", true)
    DatabindingWriteDataBoolFromParent(data, "ability_card_is_deadeye", false)

    DatabindingWriteDataHashStringFromParent(data, "ability_card_texture_dictionary", joaat("ability_cards"))
    DatabindingWriteDataHashStringFromParent(data, "ability_card_texture", joaat("ability_card_back"))
    DatabindingWriteDataHashStringFromParent(data, "ability_card_color", joaat("COLOR_WHITE"))

    DatabindingWriteDataStringFromParent(data, "ability_card_title", "")
    DatabindingWriteDataStringFromParent(data, "ability_card_description", "")

    -- Ownership states
    DatabindingWriteDataBoolFromParent(data, "ability_card_owned", false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_not_owned", true)

    -- Equipment states
    DatabindingWriteDataBoolFromParent(data, "ability_card_equippable", false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_equipped", false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_locked", false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_inactive", false)

    -- Purchase states
    DatabindingWriteDataBoolFromParent(data, "ability_card_buyable", false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_buyable_with_money", false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_buy_affordable", false)

    -- Upgrade states
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgrade_visible", false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgrade_enabled", false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgradeable", false)
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgrade_affordable", false)

    -- Pricing
    DatabindingWriteDataStringFromParent(data, "ability_card_price_dollar", "0")
    DatabindingWriteDataStringFromParent(data, "ability_card_price_cents", "00")
    DatabindingWriteDataBoolFromParent(data, "ability_card_is_affordable", false)

    -- Rank and progression
    DatabindingWriteDataIntFromParent(data, "ability_card_tier", 0)
    DatabindingWriteDataIntFromParent(data, "ability_card_rank", 0)
    DatabindingWriteDataStringFromParent(data, "ability_card_rank_text", "0")
    DatabindingWriteDataIntFromParent(data, "ability_card_current_xp", 0)
    DatabindingWriteDataIntFromParent(data, "ability_card_min_xp", 0)
    DatabindingWriteDataIntFromParent(data, "ability_card_max_xp", 0)

    -- Visual effects
    DatabindingWriteDataBoolFromParent(data, "ability_card_glint_visible", false)
end

-- Clear focus data containers
function UIDataBinding.clearFocusData(focusDataName)
    local dataContainer = nil

    if focusDataName == "ability_card_focus_data" then
        dataContainer = dataBindings.abilityCardFocusData
    elseif focusDataName == "ability_card_loadout_focus_data" then
        dataContainer = dataBindings.abilityCardLoadoutFocusData
    elseif focusDataName == "ability_card_upgrade_focus_data" then
        dataContainer = dataBindings.abilityCardUpgradeFocusData
    end

    if dataContainer then
        UIDataBinding.clearBaseAbilityCard(dataContainer)
        DatabindingWriteDataStringFromParent(dataContainer, "ability_card_focus_xp_text", "")
        DatabindingWriteDataStringFromParent(dataContainer, "ability_card_focus_purchase_type_text", "")
        DatabindingWriteDataBoolFromParent(dataContainer, "ability_card_focus_secondary_text_visible", false)
        DatabindingWriteDataStringFromParent(dataContainer, "ability_card_focus_secondary_text", "")
        DatabindingWriteDataBoolFromParent(dataContainer, "ability_card_focus_info_visible", false)
    end
end

-- Make UIDataBinding globally available
_G.UIDataBinding = UIDataBinding
return UIDataBinding
