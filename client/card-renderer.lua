---------------------------------------------------------------------------------
--                            REDM NATIVE ABILITIES                            --
--                             Card Renderer Module                            --
--             Handles card display logic and UI collection updates            --
---------------------------------------------------------------------------------

local CardRenderer = {}

-- Dependencies (will be injected)
local PlayerState = nil
local Utils = nil
local Config = nil
local CardLogic = nil
local UIDataBinding = nil

-- Initialize dependencies
function CardRenderer.init(playerState, utils, config, cardLogic, uiDataBinding)
    PlayerState = playerState
    Utils = utils
    Config = config
    CardLogic = cardLogic
    UIDataBinding = uiDataBinding
end

-- Update all loadout cards with current data
function CardRenderer.updateLoadoutCards()
    local dataBindings = UIDataBinding.getDataBindings()
    local playerRank = PlayerState.getRank()
    local loadout = PlayerState.getLoadout()
    local inventory = PlayerState.getInventory()

    for index, slot in ipairs(Config.slots) do
        local slotUnlocked = playerRank >= slot.rank
        local equippedCardId = slotUnlocked and loadout[slot.id] or nil

        local cardData = nil
        local inventoryItem = nil

        if equippedCardId then
            cardData = Utils.findCardDataById(Config.cards, equippedCardId)
            inventoryItem = Utils.findInventoryItemById(inventory, equippedCardId)
        end

        local data = dataBindings.loadoutCards[index]
        if data then
            UIDataBinding.clearBaseAbilityCard(data)

            -- Create card state for this loadout slot
            local selectedSlotId = PlayerState.getSelectedSlot()

            if not cardData then
                -- Set slot-specific properties
                DatabindingWriteDataBoolFromParent(data, "ability_card_is_deadeye", slot.id == "active_slot")
                DatabindingWriteDataBoolFromParent(data, "ability_card_locked", not slotUnlocked)
                DatabindingWriteDataBoolFromParent(data, "ability_card_inactive", not slotUnlocked)
                DatabindingWriteDataIntFromParent(data, "ability_card_rank", slot.rank)
                DatabindingWriteDataStringFromParent(data, "ability_card_rank_text", tostring(slot.rank))
            else
                local cardState = CardLogic.createCardState(
                    "loadout", cardData, inventoryItem, playerRank, loadout,
                    selectedSlotId, Config.slots, Config.slotRules, Config.cardColors
                )
                UIDataBinding.updateBaseAbilityCard(data, cardState, cardData)
            end

            -- Update loadout-specific properties
            local title = Utils.getLocalizedText(slot.titleHash, slot.title or slot.id)
            DatabindingWriteDataStringFromParent(data, "ability_card_loadout_slot_title", title)
            DatabindingWriteDataBoolFromParent(data, "ability_card_loadout_selectable_visible", slotUnlocked)
            DatabindingWriteDataBoolFromParent(data, "ability_card_loadout_selectable_enabled", slotUnlocked)
            DatabindingWriteDataBoolFromParent(data, "ability_card_loadout_removable_visible", slotUnlocked and equippedCardId ~= nil)
            DatabindingWriteDataBoolFromParent(data, "ability_card_loadout_removable_enabled", slotUnlocked and equippedCardId ~= nil)
            DatabindingWriteDataBoolFromParent(data, "ability_card_loadout_unlocked", slotUnlocked)
            DatabindingWriteDataStringFromParent(data, "ability_card_loadout_rank_text", tostring(slot.rank))
        end
    end
end

-- Update upgrade collection cards
function CardRenderer.updateUpgradeCollection()
    local upgradeCardData, upgradeInventoryItem = PlayerState.getUpgradeData()
    local dataBindings = UIDataBinding.getDataBindings()

    if not upgradeCardData then
        upgradeCardData = Config.cards[1] -- Default to first card
    end

    if not upgradeInventoryItem and upgradeCardData then
        upgradeInventoryItem = Utils.findInventoryItemById(PlayerState.getInventory(), upgradeCardData.id)
    end

    if upgradeCardData and upgradeCardData.tiers then
        local playerRank = PlayerState.getRank()
        local loadout = PlayerState.getLoadout()
        local selectedSlotId = PlayerState.getSelectedSlot()

        for tier = 1, math.min(#upgradeCardData.tiers, 3) do
            local data = dataBindings.upgradeCards[tier]
            if data then
                UIDataBinding.clearBaseAbilityCard(data)

                -- Create virtual inventory item for this tier
                local tierInventoryItem = upgradeInventoryItem and {
                    id = upgradeInventoryItem.id,
                    tier = tier,
                    xp = upgradeInventoryItem.xp
                } or nil

                local cardState = CardLogic.createCardState(
                    "upgrade", upgradeCardData, tierInventoryItem, playerRank, loadout,
                    selectedSlotId, Config.slots, Config.slotRules, Config.cardColors
                )

                UIDataBinding.updateBaseAbilityCard(data, cardState, upgradeCardData)
                CardRenderer.updateUpgradeCardSpecific(data, tier, upgradeCardData, upgradeInventoryItem)
            end
        end
    end
end

-- Update upgrade-specific card properties
function CardRenderer.updateUpgradeCardSpecific(data, tierIndex, cardData, inventoryItem)
    local color = Utils.getAbilityCardColor(Config.cardColors, cardData.category, tierIndex)
    DatabindingWriteDataHashStringFromParent(data, "ability_card_color", color)

    local tier = GetStringFromHashKey("MP_PLAYER_CARD_TIER_DISPLAY_CONTAINER")
    tier = tier:gsub("~1~", Utils.toRomanNumeral(tierIndex))
    DatabindingWriteDataStringFromParent(data, "ability_card_upgrade_tier_title", tier)

    -- Determine upgrade states
    local currentTier = inventoryItem and inventoryItem.tier or 0
    local currentXp = inventoryItem and inventoryItem.xp or 0
    local isUpgradeable = false
    local showGlint = false

    if not inventoryItem or tierIndex <= currentTier then
        -- Already owned/unlocked tiers - use defaults
    elseif tierIndex == currentTier + 1 then
        -- Next tier - check XP requirement
        if cardData.tiers and cardData.tiers[currentTier] and cardData.tiers[currentTier].xp then
            local requiredXp = cardData.tiers[currentTier].xp
            if currentXp >= requiredXp then
                isUpgradeable = true
                showGlint = true
            end
        end
    else
        -- Future tiers - locked
    end

    -- For disabled future tiers, use default back texture
    if tierIndex > currentTier then
        DatabindingWriteDataHashStringFromParent(data, "ability_card_texture", joaat("ability_card_back"))
        DatabindingWriteDataHashStringFromParent(data, "ability_card_texture_dictionary", joaat("ability_cards"))
    end

    DatabindingWriteDataBoolFromParent(data, "ability_card_upgrade_visible", isUpgradeable)
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgrade_enabled", isUpgradeable)
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgradeable", isUpgradeable)
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgradeable_with_money", isUpgradeable)
    DatabindingWriteDataBoolFromParent(data, "ability_card_upgrade_affordable", isUpgradeable)
    DatabindingWriteDataBoolFromParent(data, "ability_card_glint_visible", showGlint)
end

-- Update category icons
function CardRenderer.updateCategoryIcons()
    local dataBindings = UIDataBinding.getDataBindings()
    local currentFilter = PlayerState.getCategoryFilter()
    local isDeadeyeCategory = currentFilter == 0

    DatabindingWriteDataBoolFromParent(dataBindings.abilityCardData, "ability_card_filter_display", not isDeadeyeCategory)

    -- Always update category icons with proper textures and enabled states
    local iconIndex = 0
    for index, category in ipairs(Config.categories) do
        if category.id ~= "deadeye" then
            local data = dataBindings.categoryIconsData[iconIndex + 1]
            if data then
                -- Always set textures
                DatabindingWriteDataHashStringFromParent(data, "dynamic_list_item_main_img_texture_dic", joaat(category.txd))
                DatabindingWriteDataHashStringFromParent(data, "dynamic_list_item_main_img_texture", joaat(category.texture))

                -- Set enabled state based on selection (only when not in deadeye category)
                if not isDeadeyeCategory then
                    local isSelected = (iconIndex + 1) == currentFilter
                    DatabindingWriteDataBoolFromParent(data, "dynamic_list_item_main_img_enabled", isSelected)
                else
                    -- When in deadeye category, all icons should be enabled but not selected
                    DatabindingWriteDataBoolFromParent(data, "dynamic_list_item_main_img_enabled", true)
                end
            end
            iconIndex = iconIndex + 1
        end
    end
end

-- Update browse collection
function CardRenderer.updateBrowseCollection()
    local dataBindings = UIDataBinding.getDataBindings()
    local currentFilter = PlayerState.getCategoryFilter()
    local filterCategory = Config.categories[currentFilter + 1]

    if not filterCategory then return end

    -- Clear existing collection
    UIDataBinding.clearCollection("browseCollection")

    local playerRank = PlayerState.getRank()
    local loadout = PlayerState.getLoadout()
    local inventory = PlayerState.getInventory()
    local selectedSlotId = PlayerState.getSelectedSlot()

    local index = 0
    for i, cardData in ipairs(Config.cards) do
        if cardData.category == filterCategory.id then
            local inventoryItem = Utils.findInventoryItemById(inventory, cardData.id)

            -- Create card state for browse display
            local cardState = CardLogic.createCardState(
                "browse", cardData, inventoryItem, playerRank, loadout,
                selectedSlotId, Config.slots, Config.slotRules, Config.cardColors
            )

            -- Create new databinding container for this card
            local data = UIDataBinding.initializeBaseAbilityCardRoot(dataBindings.abilityCardData, "Ability_Card_Root_" .. index)
            UIDataBinding.updateBaseAbilityCard(data, cardState, cardData)

            -- Add to the collection
            DatabindingInsertUiItemToListFromContextStringAlias(dataBindings.browseCollection, index, "ability_card", data)
            dataBindings.browseCards[index + 1] = data

            index = index + 1
        end
    end
end

-- Update primary title based on current category
function CardRenderer.updatePrimaryTitle()
    local currentFilter = PlayerState.getCategoryFilter()
    local currentCategory = Config.categories[currentFilter + 1]

    if currentCategory then
        local title = Utils.getLocalizedText(currentCategory.titleHash, currentCategory.title or currentCategory.id)
        UIDataBinding.updatePrimaryTitle(title)
    end
end

-- Update footer text
function CardRenderer.updateFooterText(text)
    UIDataBinding.updateFooterText(text or "")
end

-- Update footer text based on card hash
function CardRenderer.updateFooterTextFromHash(focusedCardHash)
    if not focusedCardHash or focusedCardHash == 0 then
        UIDataBinding.updateFooterText("Select an ability card to view details")
        return
    end

    -- Find the card by hash
    local focusedCard = nil
    for _, card in ipairs(Config.cards) do
        if joaat(card.id) == focusedCardHash then
            focusedCard = card
            break
        end
    end

    if not focusedCard then
        UIDataBinding.updateFooterText("Card information not available")
        return
    end

    local inventory = PlayerState.getInventory()
    local loadout = PlayerState.getLoadout()
    local playerRank = PlayerState.getRank()

    local inventoryItem = Utils.findInventoryItemById(inventory, focusedCard.id)
    local isOwned = inventoryItem ~= nil
    local isLocked = focusedCard.rank and playerRank < focusedCard.rank
    local isEquipped, equippedSlot = Utils.isCardEquipped(loadout, focusedCard.id)
    local canUpgrade = false

    -- Check if upgradeable
    if isOwned then
        local maxTier = focusedCard.tiers and #focusedCard.tiers or 3
        if inventoryItem.tier < maxTier and focusedCard.tiers and focusedCard.tiers[inventoryItem.tier] and focusedCard.tiers[inventoryItem.tier].xp then
            canUpgrade = inventoryItem.xp >= focusedCard.tiers[inventoryItem.tier].xp
        end
    end

    local footerText = ""

    if isLocked then
        local lockedString = GetStringFromHashKey("NET_PLAYER_ABILITY_FOOTER_ABILITY_CARD_BUY_LOCKED")
        footerText = lockedString:gsub("~1~", tostring(focusedCard.rank))
    elseif not isOwned then
        footerText = GetStringFromHashKey("NET_PLAYER_ABILITY_FOOTER_ABILITY_CARD_BUY_CASH")
    elseif canUpgrade then
        footerText = GetStringFromHashKey("NET_PLAYER_ABILITY_FOOTER_UPGRADE")
    elseif isEquipped then
        footerText = GetStringFromHashKey("NET_PLAYER_ABILITY_FOOTER_ABILITY_CARD_EQUIPPED")
    else
        footerText = GetStringFromHashKey("NET_PLAYER_ABILITY_FOOTER_ABILITY_CARD_UNEQUIPPED")
    end

    UIDataBinding.updateFooterText(footerText)
end

-- Update focus data containers
function CardRenderer.updateFocusData(focusDataName, cardData, inventoryItem, requiredRank, focusedTier)
    UIDataBinding.clearFocusData(focusDataName)

    if not cardData then return end

    local dataBindings = UIDataBinding.getDataBindings()
    local dataContainer = nil
    local cardStateContext = nil

    if focusDataName == "ability_card_focus_data" then
        dataContainer = dataBindings.abilityCardFocusData
        cardStateContext = "browse_focus"
    elseif focusDataName == "ability_card_loadout_focus_data" then
        dataContainer = dataBindings.abilityCardLoadoutFocusData
        cardStateContext = "loadout_focus"
    elseif focusDataName == "ability_card_upgrade_focus_data" then
        dataContainer = dataBindings.abilityCardUpgradeFocusData
        cardStateContext = "upgrade_focus"
    end

    if dataContainer then
        local playerRank = PlayerState.getRank()
        local loadout = PlayerState.getLoadout()
        local selectedSlotId = PlayerState.getSelectedSlot()

        -- Create card state and update base card data
        -- For upgrade focus, pass the focused tier as additional context
        local contextData = (focusedTier and cardStateContext == "upgrade_focus") and { focusedTier = focusedTier } or nil
        local cardState = CardLogic.createCardState(
            cardStateContext, cardData, inventoryItem, playerRank, loadout,
            selectedSlotId, Config.slots, Config.slotRules, Config.cardColors, contextData
        )

        UIDataBinding.updateBaseAbilityCard(dataContainer, cardState, cardData)

        -- Update focus-specific properties
        CardRenderer.updateFocusSpecificData(dataContainer, cardState, cardData)
    end
end

-- Update focus-specific data properties
function CardRenderer.updateFocusSpecificData(dataContainer, cardState, cardData)
    local ownership = cardState.ownership or {}
    local pricing = cardState.pricing or {}
    local xp = cardState.xp or {}
    local ui = cardState.ui or {}

    -- Use cardState data instead of recalculating
    local owned = ownership.owned or false
    local tier = ownership.tier or 1
    local currentXp = xp.currentXp or 0
    local isLocked = ownership.isLocked or false
    local canUpgrade = ui.canUpgrade or false
    local hasEnoughXp = ui.upgradeEnabled or false
    local nextTierXp = pricing.nextTierXp or 0

    -- Determine display text
    local purchaseTypeText = ""
    local xpText = ""
    local secondaryText = ""
    local showSecondaryText = false
    local showInfo = true

    if not owned then
        purchaseTypeText = "IB_PRICE"
    else
        purchaseTypeText = "IB_UPGRADE"
    end

    if isLocked or tier >= pricing.maxTier then
        showInfo = false
    elseif not owned then
        -- Skip, defaults are fine
    elseif canUpgrade and hasEnoughXp then
        xpText = GetStringFromHashKey("NET_PLAYER_ABILITY_FOCUS_XP_INFO")
        xpText = xpText:gsub("~1~", tostring(currentXp)):gsub("~2~", tostring(nextTierXp))
    else
        showSecondaryText = true
        secondaryText = "NET_PLAYER_ABILITY_ADDITIONAL_XP_REQUIRED"
        xpText = GetStringFromHashKey("NET_PLAYER_ABILITY_FOCUS_XP_INFO")
        xpText = xpText:gsub("~1~", tostring(currentXp)):gsub("~2~", tostring(nextTierXp))
    end

    -- Write focus data
    DatabindingWriteDataStringFromParent(dataContainer, "ability_card_focus_xp_text", xpText)
    DatabindingWriteDataStringFromParent(dataContainer, "ability_card_focus_purchase_type_text", purchaseTypeText)
    DatabindingWriteDataBoolFromParent(dataContainer, "ability_card_focus_info_visible", showInfo)
    DatabindingWriteDataBoolFromParent(dataContainer, "ability_card_use_money_price", not showSecondaryText)
    DatabindingWriteDataBoolFromParent(dataContainer, "ability_card_focus_secondary_text_visible", showSecondaryText)
    DatabindingWriteDataStringFromParent(dataContainer, "ability_card_focus_secondary_text", secondaryText)
end

-- Refresh all UI components
function CardRenderer.refreshUI()
    CardRenderer.updatePrimaryTitle()
    CardRenderer.updateFooterText("")
    CardRenderer.updateCategoryIcons()
    CardRenderer.updateLoadoutCards()
    CardRenderer.updateBrowseCollection()
    CardRenderer.updateUpgradeCollection()
end

-- Make CardRenderer globally available
_G.CardRenderer = CardRenderer
return CardRenderer