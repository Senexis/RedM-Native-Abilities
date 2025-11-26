---------------------------------------------------------------------------------
--                            REDM NATIVE ABILITIES                            --
--                            Event Handlers Module                            --
--              Contains all UI event handling logic by function               --
---------------------------------------------------------------------------------

local EventHandlers = {}

-- Dependencies (will be injected)
local PlayerState = nil
local Utils = nil
local Config = nil
local CardRenderer = nil

-- Flag to track when UI needs refresh after upgrade
local needsCollectionRefresh = false

-- Initialize dependencies
function EventHandlers.init(playerState, utils, config, cardRenderer)
    PlayerState = playerState
    Utils = utils
    Config = config
    CardRenderer = cardRenderer
end

-- Handle loadout slot selection (for equipping cards)
function EventHandlers.handleLoadoutSlotSelect(datastore)
    local slotIndex = DatabindingReadDataIntFromParent(datastore, "ability_card_loadout_index")
    local slot = Config.slots[slotIndex + 1]

    if slot and PlayerState.getRank() >= slot.rank then
        PlayerState.setSelectedSlot(slot.id, slotIndex)

        -- Set category filter based on slot type
        if slot.id == "active_slot" then
            -- Active slot only accepts deadeye cards
            PlayerState.setCategoryFilter(0)
        else
            -- Passive slots only accept non-deadeye cards, default to recovery
            PlayerState.setCategoryFilter(1)
        end

        -- Rebuild UI components with the new category filter
        CardRenderer.updateCategoryIcons()
        CardRenderer.updatePrimaryTitle()
        CardRenderer.updateBrowseCollection()

        -- Indicates UI transition should proceed
        return true
    end

    return false
end

-- Handle loadout card focus (update focus data)
function EventHandlers.handleLoadoutCardFocus(datastore)
    local slotIndex = DatabindingReadDataIntFromParent(datastore, "ability_card_loadout_index")
    local slot = Config.slots[slotIndex + 1]

    if slot then
        local playerRank = PlayerState.getRank()
        local loadout = PlayerState.getLoadout()
        local slotUnlocked = playerRank >= slot.rank
        local equippedCardId = loadout[slot.id]
        local isActiveSlot = slot.id == "active_slot"

        -- Determine footer text based on slot state
        local footerText = ""

        if not slotUnlocked then
            -- Slot is locked - clear focus data and show locked message
            if isActiveSlot then
                footerText = GetStringFromHashKey("NET_PLAYER_ABILITY_FOOTER_LOADOUT_SLOT_ACTIVE_LOCKED")
            else
                local lockedText = GetStringFromHashKey("NET_PLAYER_ABILITY_FOOTER_LOADOUT_SLOT_PASSIVE_LOCKED")
                footerText = lockedText:gsub("~1~", tostring(slot.rank))
            end
            UIDataBinding.clearFocusData("ability_card_loadout_focus_data")
        elseif equippedCardId then
            -- Slot has a card equipped - show card info in focus data
            local cardData = Utils.findCardDataById(Config.cards, equippedCardId)
            local inventoryItem = Utils.findInventoryItemById(PlayerState.getInventory(), equippedCardId)

            if cardData and inventoryItem then
                CardRenderer.updateFocusData("ability_card_loadout_focus_data", cardData, inventoryItem, cardData.rank)
                if isActiveSlot then
                    footerText = GetStringFromHashKey("NET_PLAYER_ABILITY_FOOTER_LOADOUT_SLOT_ACTIVE_EQUIPPED")
                else
                    footerText = GetStringFromHashKey("NET_PLAYER_ABILITY_FOOTER_LOADOUT_SLOT_PASSIVE_EQUIPPED")
                end
            end
        else
            -- Empty slot - show empty slot info
            if isActiveSlot then
                footerText = GetStringFromHashKey("NET_PLAYER_ABILITY_FOOTER_LOADOUT_SLOT_ACTIVE_OPEN")
            else
                footerText = GetStringFromHashKey("NET_PLAYER_ABILITY_FOOTER_LOADOUT_SLOT_PASSIVE_OPEN")
            end
            UIDataBinding.clearFocusData("ability_card_loadout_focus_data")
        end

        CardRenderer.updateFooterText(footerText)
    end
end

-- Handle removing card from loadout slot
function EventHandlers.handleLoadoutCardRemove(datastore)
    local slotIndex = DatabindingReadDataIntFromParent(datastore, "ability_card_loadout_index")
    local slot = Config.slots[slotIndex + 1]

    if slot then
        local success = PlayerState.unequipCard(slot.id)
        if success then
            -- Update UI to reflect the change
            CardRenderer.updateLoadoutCards()
            CardRenderer.updateBrowseCollection()
            UIDataBinding.clearFocusData("ability_card_loadout_focus_data")

            -- Update footer text to show the slot is now open
            local isActiveSlot = slot.id == "active_slot"
            local footerText = ""
            if isActiveSlot then
                footerText = GetStringFromHashKey("NET_PLAYER_ABILITY_FOOTER_LOADOUT_SLOT_ACTIVE_OPEN")
            else
                footerText = GetStringFromHashKey("NET_PLAYER_ABILITY_FOOTER_LOADOUT_SLOT_PASSIVE_OPEN")
            end
            CardRenderer.updateFooterText(footerText)
        end
    end
end

-- Handle equipping a card to selected slot
function EventHandlers.handleCardEquip(datastore)
    local cardHash = DatabindingReadDataHashStringFromParent(datastore, "ability_card_ability_hash")
    local selectedSlotId, selectedSlotIndex = PlayerState.getSelectedSlot()

    if not selectedSlotId then
        print("No slot selected for equipping")
        return false
    end

    -- Find the card to equip
    local cardToEquip = nil
    for _, card in ipairs(Config.cards) do
        if joaat(card.id) == cardHash then
            cardToEquip = card
            break
        end
    end

    if cardToEquip then
        local owned, inventoryItem = PlayerState.validateCardOwnership(cardToEquip.id)
        if owned then
            -- Check slot compatibility
            local compatible = Utils.isSlotCompatible(Config.slotRules, cardToEquip.category, selectedSlotId)
            if compatible then
                local success = PlayerState.equipCard(selectedSlotId, cardToEquip.id)
                if success then
                    -- Clear selection and update UI
                    PlayerState.clearSelectedSlot()
                    CardRenderer.updateLoadoutCards()
                    CardRenderer.updateBrowseCollection()

                    -- Trigger event for server/developer integration
                    TriggerEvent(Config.eventHandlerKey .. ":card_equipped", cardToEquip.id, selectedSlotId)
                end

                -- Indicates UI transition should proceed
                return true
            else
                print("Card " .. cardToEquip.id .. " is not compatible with slot " .. selectedSlotId)
            end
        else
            print("Player does not own card: " .. cardToEquip.id)
        end
    end

    return false
end

-- Handle buying a card
function EventHandlers.handleCardBuy(datastore)
    local cardHash = DatabindingReadDataHashStringFromParent(datastore, "ability_card_ability_hash")

    -- Find the card to buy
    local cardToBuy = nil
    for _, card in ipairs(Config.cards) do
        if joaat(card.id) == cardHash then
            cardToBuy = card
            break
        end
    end

    if cardToBuy then
        local owned = PlayerState.validateCardOwnership(cardToBuy.id)
        if not owned then
            -- Add card to inventory (tier 1 with 0 XP initially)
            local success = PlayerState.addCardToInventory(cardToBuy.id, 1, 0)
            if success then
                CardRenderer.refreshUI()

                -- Trigger event for server/developer integration
                TriggerEvent(Config.eventHandlerKey .. ":card_purchased", cardToBuy.id)
            end
        else
            print("Player already owns card: " .. cardToBuy.id)
        end
    end
end

-- Handle viewing card upgrades
function EventHandlers.handleViewUpgrades(datastore)
    local cardHash = DatabindingReadDataHashStringFromParent(datastore, "ability_card_ability_hash")

    -- Find card data and set upgrade ephemeral state
    for _, card in ipairs(Config.cards) do
        if joaat(card.id) == cardHash then
            local inventoryItem = Utils.findInventoryItemById(PlayerState.getInventory(), card.id)
            PlayerState.setUpgradeData(card, inventoryItem)
            CardRenderer.updateUpgradeCollection()
            break
        end
    end

    return true -- Indicates UI transition should proceed
end

-- Handle upgrade card focus
function EventHandlers.handleUpgradeCardFocus(datastore)
    local tierIndex = DatabindingReadDataIntFromParent(datastore, "ability_card_upgrade_tier_index")
    local upgradeCardData, upgradeInventoryItem = PlayerState.getUpgradeData()

    if upgradeCardData then
        -- Pass the actual inventory item (with player's real tier) and focused tier separately
        -- Don't create a virtual inventory item that overwrites the real tier information
        CardRenderer.updateFocusData("ability_card_upgrade_focus_data", upgradeCardData, upgradeInventoryItem, upgradeCardData.rank, tierIndex)
    end
end

-- Handle card upgrade
function EventHandlers.handleCardUpgrade(datastore)
    local tierIndex = DatabindingReadDataIntFromParent(datastore, "ability_card_upgrade_tier_index")
    local upgradeCardData, upgradeInventoryItem = PlayerState.getUpgradeData()

    if upgradeCardData and upgradeInventoryItem then
        local maxTier = upgradeCardData.tiers and #upgradeCardData.tiers or 3

        if tierIndex == upgradeInventoryItem.tier + 1 and tierIndex <= maxTier then
            -- Validate XP requirement
            if upgradeCardData.tiers and upgradeCardData.tiers[upgradeInventoryItem.tier] then
                local requiredXp = upgradeCardData.tiers[upgradeInventoryItem.tier].xp or 0

                if upgradeInventoryItem.xp >= requiredXp then
                    local success = PlayerState.upgradeCard(upgradeCardData.id, tierIndex)
                    if success then
                        -- Update ephemeral state with new inventory item
                        local newInventoryItem = Utils.findInventoryItemById(PlayerState.getInventory(), upgradeCardData.id)
                        PlayerState.setUpgradeData(upgradeCardData, newInventoryItem)

                        -- Set flag to refresh UI when user next interacts with browse collection
                        needsCollectionRefresh = true

                        -- Only update upgrade collection immediately
                        CardRenderer.updateUpgradeCollection()

                        -- Update focus data to reflect the changes for the current tier
                        CardRenderer.updateFocusData("ability_card_upgrade_focus_data", upgradeCardData, newInventoryItem, upgradeCardData.rank, tierIndex)

                        -- Trigger event for server/developer integration
                        TriggerEvent(Config.eventHandlerKey .. ":card_upgraded", upgradeCardData.id, tierIndex)
                    end
                else
                    print("Insufficient XP for upgrade. Required: " .. requiredXp .. ", Current: " .. upgradeInventoryItem.xp)
                end
            end
        else
            print("Invalid upgrade: current tier is " .. upgradeInventoryItem.tier .. ", trying to upgrade to " .. tierIndex)
        end
    end
end

-- Handle category filter changes
function EventHandlers.handleCategoryFilter(direction)
    -- When in deadeye category, filtering is hidden so this shouldn't be called
    local currentFilter = PlayerState.getCategoryFilter()
    if currentFilter == 0 then
        return
    end

    local passiveCategoryCount = #Config.categories - 1 -- Exclude deadeye category
    local newFilter = ((currentFilter - 1 + direction) % passiveCategoryCount) + 1

    PlayerState.setCategoryFilter(newFilter)
    CardRenderer.updateCategoryIcons()
    CardRenderer.updatePrimaryTitle()
    CardRenderer.updateBrowseCollection()
    CardRenderer.updateFooterText("")
end

-- Handle browse card focus
function EventHandlers.handleBrowseCardFocus(datastore)
    -- Check if the browser UI requires a refresh
    if needsCollectionRefresh then
        CardRenderer.updateBrowseCollection()
        needsCollectionRefresh = false
    end

    local cardHash = DatabindingReadDataHashStringFromParent(datastore, "ability_card_ability_hash")

    -- Update footer text based on focused card
    CardRenderer.updateFooterTextFromHash(cardHash)

    -- Update focus data for browse screen
    if cardHash and cardHash ~= 0 then
        for _, card in ipairs(Config.cards) do
            if joaat(card.id) == cardHash then
                local inventoryItem = Utils.findInventoryItemById(PlayerState.getInventory(), card.id)
                CardRenderer.updateFocusData("ability_card_focus_data", card, inventoryItem, card.rank)
                break
            end
        end
    else
        -- Clear focus data when no card is focused
        UIDataBinding.clearFocusData("ability_card_focus_data")
    end
end

-- Make EventHandlers globally available
_G.EventHandlers = EventHandlers
return EventHandlers