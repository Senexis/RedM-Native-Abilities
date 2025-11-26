---------------------------------------------------------------------------------
--                            REDM NATIVE ABILITIES                            --
--                             Player State Module                             --
--            Manages player data, inventory, loadout, and state               --
---------------------------------------------------------------------------------

local PlayerState = {}

-- Initialize default player state
local state = {
    rank = 25,
    loadout = {
        ["active_slot"] = "net_player_ability__a_moment_to_recuperate",
        ["passive_slot_1"] = nil,
        ["passive_slot_2"] = nil,
        ["passive_slot_3"] = nil
    },
    inventory = {
        { id = "net_player_ability__a_moment_to_recuperate", tier = 1, xp = 2500 },
        { id = "net_player_ability__focus_fire", tier = 2, xp = 10000 },
        { id = "net_player_ability__paint_it_black", tier = 3, xp = 10000 },
    }
}

-- Ephemeral UI state (temporary, doesn't persist)
local ephemeralState = {
    selectedSlotId = nil,           -- Which slot is being selected for equipping
    selectedSlotIndex = nil,        -- Index of the selected slot
    upgradeCardData = nil,          -- Card data for the upgrade screen
    upgradeInventoryItem = nil,     -- Inventory item for the upgrade screen
    currentCategoryFilter = 0       -- Current category filter (0=deadeye, 1=recovery, 2=combat, 3=defense)
}

-- State change callbacks
local stateChangeCallbacks = {
    rank = {},
    loadout = {},
    inventory = {}
}

-- Register callback for state changes
function PlayerState.onStateChange(stateType, callback)
    if stateChangeCallbacks[stateType] then
        table.insert(stateChangeCallbacks[stateType], callback)
    end
end

-- Trigger state change callbacks
local function triggerCallbacks(stateType, ...)
    if stateChangeCallbacks[stateType] then
        for _, callback in ipairs(stateChangeCallbacks[stateType]) do
            callback(...)
        end
    end
end

-- Getters for persistent state
function PlayerState.getRank()
    return state.rank
end

function PlayerState.getLoadout()
    return state.loadout
end

function PlayerState.getInventory()
    return state.inventory
end

-- Getters for ephemeral state
function PlayerState.getEphemeralState()
    return ephemeralState
end

function PlayerState.getSelectedSlot()
    return ephemeralState.selectedSlotId, ephemeralState.selectedSlotIndex
end

function PlayerState.getUpgradeData()
    return ephemeralState.upgradeCardData, ephemeralState.upgradeInventoryItem
end

function PlayerState.getCategoryFilter()
    return ephemeralState.currentCategoryFilter
end

-- Setters with validation
function PlayerState.setRank(newRank)
    if type(newRank) ~= "number" or newRank < 0 then
        print("Invalid rank: " .. tostring(newRank))
        return false
    end

    local oldRank = state.rank
    state.rank = newRank
    triggerCallbacks("rank", newRank, oldRank)
    return true
end

function PlayerState.equipCard(slotId, cardId)
    if not slotId then
        print("Invalid slot ID")
        return false
    end

    local oldCardId = state.loadout[slotId]
    state.loadout[slotId] = cardId
    triggerCallbacks("loadout", slotId, cardId, oldCardId)
    print("Equipped card " .. tostring(cardId) .. " in slot " .. slotId)
    return true
end

function PlayerState.unequipCard(slotId)
    if not slotId or not state.loadout[slotId] then
        print("Invalid slot or no card equipped")
        return false
    end

    local oldCardId = state.loadout[slotId]
    state.loadout[slotId] = nil
    triggerCallbacks("loadout", slotId, nil, oldCardId)
    print("Removed card " .. oldCardId .. " from slot " .. slotId)
    return true
end

function PlayerState.addCardToInventory(cardId, tier, xp)
    tier = tier or 1
    xp = xp or 0

    -- Validate that player has sufficient rank to own this card
    if not PlayerState.validateCardUnlocked(cardId) then
        print("Cannot add locked card: " .. cardId .. " (requires higher rank)")
        return false
    end

    -- Check if card already exists
    for _, item in ipairs(state.inventory) do
        if item.id == cardId then
            print("Player already owns card: " .. cardId)
            return false
        end
    end

    local newItem = { id = cardId, tier = tier, xp = xp }
    table.insert(state.inventory, newItem)
    triggerCallbacks("inventory", "add", newItem)
    print("Added card to inventory: " .. cardId .. " (Tier " .. tier .. ")")
    return true
end

function PlayerState.upgradeCard(cardId, newTier)
    for _, item in ipairs(state.inventory) do
        if item.id == cardId then
            local oldTier = item.tier
            item.tier = newTier
            item.xp = 0  -- Reset XP after upgrade
            triggerCallbacks("inventory", "upgrade", item, oldTier, newTier)
            print("Upgraded card " .. cardId .. " from tier " .. oldTier .. " to " .. newTier)
            return true
        end
    end

    print("Card not found in inventory: " .. cardId)
    return false
end

function PlayerState.addCardXP(cardId, xpAmount)
    for _, item in ipairs(state.inventory) do
        if item.id == cardId then
            local oldXp = item.xp
            item.xp = item.xp + xpAmount
            triggerCallbacks("inventory", "xp", item, oldXp, item.xp)
            return true
        end
    end
    return false
end

function PlayerState.removeCardFromInventory(cardId)
    for i, item in ipairs(state.inventory) do
        if item.id == cardId then
            local removedItem = table.remove(state.inventory, i)
            triggerCallbacks("inventory", "remove", removedItem)
            print("Removed card from inventory: " .. cardId)
            return true
        end
    end

    print("Card not found in inventory: " .. cardId)
    return false
end

-- Ephemeral state setters
function PlayerState.setSelectedSlot(slotId, slotIndex)
    ephemeralState.selectedSlotId = slotId
    ephemeralState.selectedSlotIndex = slotIndex
end

function PlayerState.clearSelectedSlot()
    ephemeralState.selectedSlotId = nil
    ephemeralState.selectedSlotIndex = nil
end

function PlayerState.setUpgradeData(cardData, inventoryItem)
    ephemeralState.upgradeCardData = cardData
    ephemeralState.upgradeInventoryItem = inventoryItem
end

function PlayerState.clearUpgradeData()
    ephemeralState.upgradeCardData = nil
    ephemeralState.upgradeInventoryItem = nil
end

function PlayerState.setCategoryFilter(filterIndex)
    ephemeralState.currentCategoryFilter = filterIndex
end

-- Bulk state setters for synchronization
function PlayerState.setLoadout(newLoadout)
    if type(newLoadout) ~= "table" then
        print("Invalid loadout data")
        return false
    end

    local oldLoadout = {}
    for k, v in pairs(state.loadout) do
        oldLoadout[k] = v
    end

    state.loadout = {}
    for k, v in pairs(newLoadout) do
        state.loadout[k] = v
    end

    triggerCallbacks("loadout", state.loadout, oldLoadout)
    print("Synchronized loadout")
    return true
end

function PlayerState.setInventory(newInventory)
    if type(newInventory) ~= "table" then
        print("Invalid inventory data")
        return false
    end

    local oldInventory = state.inventory
    state.inventory = {}
    local skippedCount = 0

    for _, item in ipairs(newInventory) do
        if type(item) == "table" and item.id then
            -- Validate that player has sufficient rank to own this card
            if PlayerState.validateCardUnlocked(item.id) then
                table.insert(state.inventory, {
                    id = item.id,
                    tier = item.tier or 1,
                    xp = item.xp or 0,
                    owned = item.owned
                })
            else
                skippedCount = skippedCount + 1
                print("Skipped locked card: " .. item.id .. " (requires higher rank)")
            end
        end
    end

    triggerCallbacks("inventory", state.inventory, oldInventory)
    print("Synchronized inventory with " .. #state.inventory .. " items" ..
          (skippedCount > 0 and " (skipped " .. skippedCount .. " locked cards)" or ""))
    return true
end

-- Validation helpers
function PlayerState.validateSlotUnlocked(slotId, slots)
    for _, slot in ipairs(slots) do
        if slot.id == slotId then
            return state.rank >= slot.rank
        end
    end
    return false
end

function PlayerState.validateCardUnlocked(cardId)
    -- Get card configuration from Config (which should be available globally)
    if not _G.Config or not _G.Config.cards then
        return true -- If no config available, allow all cards (fallback)
    end

    for _, card in ipairs(_G.Config.cards) do
        if card.id == cardId then
            return state.rank >= card.rank
        end
    end

    return false -- Card not found in config, assume locked
end

function PlayerState.validateCardOwnership(cardId)
    for _, item in ipairs(state.inventory) do
        if item.id == cardId then
            return true, item
        end
    end
    return false, nil
end

function PlayerState.clearEphemeralState()
    ephemeralState.selectedSlotId = nil
    ephemeralState.selectedSlotIndex = nil
    ephemeralState.upgradeCardData = nil
    ephemeralState.upgradeInventoryItem = nil
    ephemeralState.currentCategoryFilter = 0
end

-- Make PlayerState globally available
_G.PlayerState = PlayerState
return PlayerState