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

-- Resource cleanup
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    if IsUiappActiveByHash(uiAppChannel) then
        CloseUiappByHashImmediate(uiAppChannel)
    end
end)
