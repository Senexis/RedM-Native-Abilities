---------------------------------------------------------------------------------
--                            REDM NATIVE ABILITIES                            --
--                           Utility Functions Module                          --
--              Contains helper functions used across the system               --
---------------------------------------------------------------------------------

local Utils = {}

-- Convert number to Roman numeral (for tier display)
function Utils.toRomanNumeral(number)
    local romanNumerals = {
        [1] = "I",
        [2] = "II",
        [3] = "III",
        [4] = "IV",
        [5] = "V"
    }
    return romanNumerals[number] or tostring(number)
end

-- Find inventory item by card ID
function Utils.findInventoryItemById(inventory, cardId)
    for i, item in ipairs(inventory) do
        if item.id == cardId then
            return item, i
        end
    end
    return nil, nil
end

-- Find card data by ID from the cards array
function Utils.findCardDataById(cards, cardId)
    for _, card in ipairs(cards) do
        if card.id == cardId then
            return card
        end
    end
    return nil
end

-- Get ability card color based on category and tier
function Utils.getAbilityCardColor(cardColors, category, tier)
    local categoryColors = cardColors[category]
    if categoryColors and categoryColors[tier] then
        return categoryColors[tier]
    end

    print("GetAbilityCardColor: Unknown category " .. tostring(category) .. " and tier " .. tostring(tier) .. ", defaulting to black")
    return joaat("COLOR_BLACK")
end

-- Check if a card category is compatible with a slot
function Utils.isSlotCompatible(slotRules, category, slotId)
    local rule = slotRules[category]
    if not rule then return false end

    if rule == "active_slot" then
        return slotId == "active_slot"
    elseif rule == "passive" then
        return slotId ~= "active_slot"
    end

    return false
end

-- Check if a card is equipped in any slot
function Utils.isCardEquipped(loadout, cardId)
    for slot, equippedCardId in pairs(loadout) do
        if equippedCardId == cardId then
            return true, slot
        end
    end
    return false, nil
end

-- Get the next available passive slot for equipment
function Utils.getNextAvailablePassiveSlot(loadout, slots)
    for _, slot in ipairs(slots) do
        if slot.id ~= "active_slot" and not loadout[slot.id] then
            return slot.id
        end
    end
    return nil
end

-- Format cash price into dollars and cents strings
function Utils.formatPrice(price)
    local dollars = tostring(math.floor(price / 100))
    local cents = string.format("%02d", price % 100)
    return dollars, cents
end

-- Get localized text from hash or return fallback
function Utils.getLocalizedText(textHash, fallback)
    if textHash then
        return GetStringFromHashKey(textHash)
    end
    return fallback or ""
end

-- Validate tier index is within valid range
function Utils.validateTierIndex(tier, maxTiers)
    maxTiers = maxTiers or 3
    return math.max(1, math.min(tier, maxTiers))
end

-- Make Utils globally available
_G.Utils = Utils
return Utils