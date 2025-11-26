---------------------------------------------------------------------------------
--                            REDM NATIVE ABILITIES                            --
--                              Main Entry Point                               --
---------------------------------------------------------------------------------

-- UI channels
local uiAppChannel = joaat("abilities")
local uiEventChannel = joaat("abilities")

-- Initialize all modules with their dependencies
local function initializeModules()
    -- Initialize UI databinding system first
    local dataBindings = UIDataBinding.initialize()

    -- Setup dependencies for other modules
    CardRenderer.init(PlayerState, Utils, Config, CardLogic, UIDataBinding)
    EventHandlers.init(PlayerState, Utils, Config, CardRenderer)

    -- Initialize loadout and upgrade cards in the UI
    for index, slot in ipairs(Config.slots) do
        local data = UIDataBinding.initializeLoadoutCard(dataBindings.abilityCardData, index - 1)
        dataBindings.loadoutCards[index] = data
        DatabindingInsertUiItemToListFromContextStringAlias(dataBindings.loadoutCollection, index - 1, "ability_loadout_card_focusable", data)
    end

    -- Initialize upgrade cards (max 3 tiers)
    for tier = 1, 3 do
        local data = UIDataBinding.initializeUpgradeCard(dataBindings.abilityCardData, tier)
        dataBindings.upgradeCards[tier] = data
        DatabindingInsertUiItemToListFromContextStringAlias(dataBindings.upgradeCollection, tier - 1, "ability_upgrade_card_focusable_large", data)
    end

    -- Initialize category icons (excluding deadeye category)
    local iconIndex = 0
    for index, category in ipairs(Config.categories) do
        if category.id ~= "deadeye" then
            local data = UIDataBinding.initializeCategoryIcon(dataBindings.abilityCardData, iconIndex)
            dataBindings.categoryIconsData[iconIndex + 1] = data
            DatabindingInsertUiItemToListFromContextStringAlias(dataBindings.categoryIcons, iconIndex, "filter_image", data)
            iconIndex = iconIndex + 1
        end
    end

    -- Setup state change callbacks
    PlayerState.onStateChange("loadout", function()
        CardRenderer.updateLoadoutCards()
        CardRenderer.updateBrowseCollection()
    end)

    PlayerState.onStateChange("inventory", function()
        CardRenderer.refreshUI()
    end)

    return dataBindings
end

-- Main system initialization
local function initialize()
    local dataBindings = initializeModules()

    -- Initialize the UI with current state
    CardRenderer.refreshUI()

    return dataBindings
end

-- Start the main system
initialize()

-- UI event processing thread
CreateThread(function()
    while true do
        Wait(0)

        if EventsUiIsPending(uiAppChannel) then
            local msg = DataView.ArrayBuffer(8 * 4)
            msg:SetInt32(0, 0)
            msg:SetInt32(8, 0)
            msg:SetInt32(16, 0)
            msg:SetInt32(24, 0)

            if Citizen.InvokeNative(0x90237103F27F7937, uiEventChannel, msg:Buffer()) ~= 0 then -- EVENTS_UI_PEEK_MESSAGE
                local event = msg:GetInt32(0)
                local index = msg:GetInt32(8)
                local parameter = msg:GetInt32(16)
                local datastore = msg:GetInt32(24)

                if event == joaat("NEW_PAGE") then
                    if parameter == joaat("ABILITY_CARD_UI_EVENT_MENU_LOAD_LOCAL_PLAYER_EVENT") then
                        if UiStateMachineRequestTransition(uiAppChannel, -700246597) ~= 1 then
                            CloseUiappByHash(uiAppChannel)
                        end
                    elseif parameter == joaat("ABILITY_CARD_UI_EVENT_MENU_LOAD_EVENT") then
                        if UiStateMachineRequestTransition(uiAppChannel, -700246597) ~= 1 then
                            CloseUiappByHash(uiAppChannel)
                        end
                    end
                elseif event == joaat("ITEM_FOCUSED") then
                    if parameter == joaat("ABILITY_CARD_UI_EVENT_LOADOUT_CARD_FOCUS_EVENT") then
                        EventHandlers.handleLoadoutCardFocus(datastore)
                    elseif parameter == joaat("ABILITY_CARD_UI_EVENT_FOCUS_EVENT") then
                        EventHandlers.handleBrowseCardFocus(datastore)
                    elseif parameter == joaat("ABILITY_CARD_UI_EVENT_UPGRADE_CARD_FOCUS_EVENT") then
                        EventHandlers.handleUpgradeCardFocus(datastore)
                    end
                elseif event == joaat("TAB_PAGE_INCREMENT") then
                    if parameter == joaat("ABILITY_CARD_UI_EVENT_CATEGORY_FILTER_EVENT") then
                        EventHandlers.handleCategoryFilter(1)
                    end
                elseif event == joaat("TAB_PAGE_DECREMENT") then
                    if parameter == joaat("ABILITY_CARD_UI_EVENT_CATEGORY_FILTER_EVENT") then
                        EventHandlers.handleCategoryFilter(-1)
                    end
                elseif event == joaat("ITEM_SELECTED") then
                    if parameter == joaat("ABILITY_CARD_UI_EVENT_LOADOUT_CARD_SELECT_SLOT_EVENT") then
                        if EventHandlers.handleLoadoutSlotSelect(datastore) then
                            if UiStateMachineCanRequestTransition(uiAppChannel) then
                                UiStateMachineRequestTransition(uiAppChannel, -2109508723)
                            end
                        end
                    elseif parameter == joaat("ABILITY_CARD_UI_EVENT_LOADOUT_CARD_REMOVE_CARD_EVENT") then
                        EventHandlers.handleLoadoutCardRemove(datastore)
                    elseif parameter == joaat("ABILITY_CARD_UI_EVENT_EQUIP_CARD_EVENT") then
                        if EventHandlers.handleCardEquip(datastore) then
                            if UiStateMachineCanRequestTransition(uiAppChannel) then
                                UiStateMachineRequestTransition(uiAppChannel, 927041140)
                            end
                        end
                    elseif parameter == joaat("ABILITY_CARD_UI_EVENT_BUY_CARD_EVENT") then
                        EventHandlers.handleCardBuy(datastore)
                    elseif parameter == joaat("ABILITY_CARD_UI_EVENT_VIEW_UPGRADES_EVENT") then
                        if EventHandlers.handleViewUpgrades(datastore) then
                            if UiStateMachineCanRequestTransition(uiAppChannel) then
                                UiStateMachineRequestTransition(uiAppChannel, -1316999016)
                            end
                        end
                    elseif parameter == joaat("ABILITY_CARD_UI_EVENT_UPGRADE_CARD_EVENT") then
                        EventHandlers.handleCardUpgrade(datastore)
                    end
                end
            end

            EventsUiPopMessage(uiEventChannel)
        end
    end
end)

-- Open abilities UI
local function openAbilities()
    -- Launch the abilities UI
    LaunchUiappByHashWithEntry(uiAppChannel, '')

    -- Trigger event for server/developer integration
    TriggerEvent(Config.eventHandlerKey .. ":abilities_opened")

    -- Monitor UI state
    Citizen.CreateThread(function()
        while IsUiappRunningByHash(uiAppChannel) == 1 do
            Citizen.Wait(0)
        end

        -- Trigger event when UI closes
        TriggerEvent(Config.eventHandlerKey .. ":abilities_closed")
    end)
end

-- Close abilities UI
local function closeAbilities()
    if IsUiappRunningByHash(uiAppChannel) then
        CloseUiappByHashImmediate(uiAppChannel)
    end
end

-- Resource cleanup
AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    initialize()
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    closeAbilities()
end)

-- Abilities Control Triggers (External Integration)
AddEventHandler(Config.eventHandlerKey .. ":open_abilities", function()
    openAbilities()
end)

AddEventHandler(Config.eventHandlerKey .. ":close_abilities", function()
    closeAbilities()
end)

-- Loadout Management Triggers
AddEventHandler(Config.eventHandlerKey .. ":synchronize_loadout", function(loadout)
    if type(loadout) ~= "table" then
        print("[Native Abilities] Can't synchronize without a valid table of loadout items")
        return
    end

    PlayerState.setLoadout(loadout)
    CardRenderer.updateLoadoutCards()
end)

AddEventHandler(Config.eventHandlerKey .. ":synchronize_inventory", function(inventory)
    if type(inventory) ~= "table" then
        print("[Native Abilities] Can't synchronize without a valid table of inventory items")
        return
    end

    PlayerState.setInventory(inventory)
    CardRenderer.refreshUI()
end)

AddEventHandler(Config.eventHandlerKey .. ":equip_card", function(cardId, slotId)
    if type(cardId) ~= "string" or type(slotId) ~= "string" then
        print("[Native Abilities] Can't equip card without valid card ID and slot ID")
        return
    end

    -- Find the card configuration
    local cardConfig = nil
    for _, card in ipairs(Config.cards) do
        if card.id == cardId then
            cardConfig = card
            break
        end
    end

    if not cardConfig then
        print("[Native Abilities] Card '" .. cardId .. "' not found in configuration")
        return
    end

    -- Check slot compatibility
    local slotIndex = nil
    for i, slot in ipairs(Config.slots) do
        if slot.id == slotId then
            slotIndex = i - 1
            break
        end
    end

    if not slotIndex then
        print("[Native Abilities] Slot '" .. slotId .. "' not found in configuration")
        return
    end

    -- Update loadout
    local currentLoadout = PlayerState.getLoadout()
    currentLoadout[slotId] = cardId

    PlayerState.setLoadout(currentLoadout)
    CardRenderer.updateLoadoutCards()

    -- Trigger event for server notification
    TriggerEvent(Config.eventHandlerKey .. ":card_equipped", cardId, slotId)
end)

AddEventHandler(Config.eventHandlerKey .. ":remove_card", function(slotId)
    if type(slotId) ~= "string" then
        print("[Native Abilities] Can't remove card without valid slot ID")
        return
    end

    -- Find slot index
    local slotIndex = nil
    for i, slot in ipairs(Config.slots) do
        if slot.id == slotId then
            slotIndex = i - 1
            break
        end
    end

    if not slotIndex then
        print("[Native Abilities] Slot '" .. slotId .. "' not found in configuration")
        return
    end

    -- Remove from loadout
    local currentLoadout = PlayerState.getLoadout()
    local removedCard = currentLoadout[slotId]
    currentLoadout[slotId] = nil

    PlayerState.setLoadout(currentLoadout)
    CardRenderer.updateLoadoutCards()

    -- Trigger event for server notification
    if removedCard then
        TriggerEvent(Config.eventHandlerKey .. ":card_removed", removedCard, slotId)
    end
end)

-- Inventory Management Triggers
AddEventHandler(Config.eventHandlerKey .. ":add_card_to_inventory", function(cardId, tier, xp)
    if type(cardId) ~= "string" then
        print("[Native Abilities] Can't add card without valid card ID")
        return
    end

    tier = tier or 1
    xp = xp or 0

    if PlayerState.addCardToInventory(cardId, tier, xp) then
        CardRenderer.refreshUI()
        TriggerEvent(Config.eventHandlerKey .. ":card_added_to_inventory", cardId, tier, xp)
    end
end)

AddEventHandler(Config.eventHandlerKey .. ":remove_card_from_inventory", function(cardId)
    if type(cardId) ~= "string" then
        print("[Native Abilities] Can't remove card without valid card ID")
        return
    end

    if PlayerState.removeCardFromInventory(cardId) then
        CardRenderer.refreshUI()
        TriggerEvent(Config.eventHandlerKey .. ":card_removed_from_inventory", cardId)
    end
end)

AddEventHandler(Config.eventHandlerKey .. ":add_card_xp", function(cardId, xpAmount)
    if type(cardId) ~= "string" then
        print("[Native Abilities] Can't add XP without valid card ID")
        return
    end

    xpAmount = tonumber(xpAmount) or 0
    if xpAmount <= 0 then
        print("[Native Abilities] XP amount must be positive")
        return
    end

    if PlayerState.addCardXP(cardId, xpAmount) then
        CardRenderer.refreshUI()
        TriggerEvent(Config.eventHandlerKey .. ":card_xp_added", cardId, xpAmount)
    end
end)

AddEventHandler(Config.eventHandlerKey .. ":set_rank", function(newRank)
    newRank = tonumber(newRank)
    if not newRank or newRank < 0 then
        print("[Native Abilities] Invalid rank: must be a positive number")
        return
    end

    if PlayerState.setRank(newRank) then
        CardRenderer.refreshUI()
        TriggerEvent(Config.eventHandlerKey .. ":rank_updated", newRank)
    end
end)
