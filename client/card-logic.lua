---------------------------------------------------------------------------------
--                            REDM NATIVE ABILITIES                            --
--                              Card Logic Module                              --
--          Contains business logic for ability cards and calculations         --
---------------------------------------------------------------------------------

local CardLogic = {}

-- Calculate ownership and equipment status
function CardLogic.calculateOwnership(context, cardData, inventoryItem, playerRank, loadout, contextData)
    if not cardData then
        return {
            owned = false,
            equipped = false,
            equippedSlot = nil,
            tier = 1,
            xp = 0,
            isLocked = false
        }
    end

    local owned = inventoryItem ~= nil
    local equipped = false
    local equippedSlot = nil
    local tier = inventoryItem and inventoryItem.tier or 1
    local xp = inventoryItem and inventoryItem.xp or 0
    local isLocked = cardData.rank and playerRank < cardData.rank

    -- Check if equipped in any slot
    if inventoryItem then
        for slot, cardId in pairs(loadout) do
            if cardId == inventoryItem.id then
                equipped = true
                equippedSlot = slot
                break
            end
        end
    end

    return {
        owned = owned,
        equipped = equipped,
        equippedSlot = equippedSlot,
        tier = tier,
        xp = xp,
        isLocked = isLocked
    }
end

-- Calculate pricing information for buying and upgrading
function CardLogic.calculatePricing(context, cardData, ownershipInfo, contextData)
    if not cardData then
        return {
            buyPrice = 0,
            nextTierCash = 0,
            nextTierXp = 0,
            maxTier = 3,
            nextTier = 2
        }
    end

    local tier = ownershipInfo.tier or 1
    local prevTier = tier - 1
    local buyPrice = 0
    local nextTierCash = 0
    local nextTierXp = 0
    local maxTier = cardData.tiers and #cardData.tiers or 3
    local nextTier = tier + 1

    -- Calculate buy price for unowned cards
    if cardData.tiers and cardData.tiers[1] then
        buyPrice = cardData.tiers[1].cash or 0
    end

    -- Calculate upgrade pricing for owned cards
    if ownershipInfo.owned and cardData.tiers then
        if context == "upgrade_focus" and contextData and contextData.focusedTier then
            -- For upgrade focus, use the focused tier's requirements
            local focusedTier = contextData.focusedTier
            local playerTier = ownershipInfo.tier or 1

            -- If focused tier is same or lower than player's current tier or higher than the next tier, set costs to 0
            if focusedTier <= playerTier or focusedTier > (playerTier + 1) then
                nextTierXp = 0
                nextTierCash = 0
            else
                -- Only show costs for tiers higher than player's current tier
                local requiredTierForXp = focusedTier - 1  -- XP requirement is from the previous tier
                if requiredTierForXp > 0 and cardData.tiers[requiredTierForXp] then
                    nextTierXp = cardData.tiers[requiredTierForXp].xp or 0
                end
                if cardData.tiers[focusedTier] then
                    nextTierCash = cardData.tiers[focusedTier].cash or 0
                end
            end
        else
            -- Normal pricing logic for other contexts
            if cardData.tiers[tier] then
                nextTierXp = cardData.tiers[tier].xp or 0
            end
            if cardData.tiers[nextTier] then
                nextTierCash = cardData.tiers[nextTier].cash or 0
            end
        end
    end

    return {
        buyPrice = buyPrice,
        nextTierCash = nextTierCash,
        nextTierXp = nextTierXp,
        maxTier = maxTier,
        nextTier = nextTier
    }
end

-- Check slot compatibility for equipment
function CardLogic.checkSlotCompatibility(context, cardData, selectedSlotId, slots, slotRules)
    if not selectedSlotId or not cardData then
        return true -- No restrictions if no slot selected
    end

    local selectedSlot = nil
    for _, slot in ipairs(slots) do
        if slot.id == selectedSlotId then
            selectedSlot = slot
            break
        end
    end

    if not selectedSlot then
        return false
    end

    -- Use slot rules to determine compatibility
    local rule = slotRules[cardData.category]
    if not rule then
        return false
    end

    if rule == "active_slot" then
        return selectedSlot.id == "active_slot"
    elseif rule == "passive" then
        return selectedSlot.id ~= "active_slot"
    end

    return false
end

-- Calculate XP progression information
function CardLogic.calculateXPProgression(context, ownershipInfo, pricingInfo)
    -- XP bar always starts from 0 for current tier
    local minXp = 0
    local maxXp = pricingInfo.nextTierXp
    local currentXp = ownershipInfo.xp

    return {
        minXp = minXp,
        maxXp = maxXp,
        currentXp = currentXp
    }
end

-- Determine UI interaction states
function CardLogic.determineUIStates(context, inventoryItem, ownershipInfo, pricingInfo, slotCompatible, contextData)
    local isInactive = ownershipInfo.isLocked
    local isBuyable = not ownershipInfo.owned and not ownershipInfo.isLocked
    local isEquippable = ownershipInfo.owned and not ownershipInfo.equipped and not ownershipInfo.isLocked and slotCompatible
    -- Calculate canUpgrade based on context
    local canUpgrade = false
    if context == "upgrade_focus" and contextData and contextData.focusedTier then
        local playerTier = ownershipInfo.tier
        local focusedTier = contextData.focusedTier
        -- In upgrade focus, can only upgrade if focusing on the next tier (playerTier + 1) AND have enough XP
        canUpgrade = ownershipInfo.owned and not ownershipInfo.isLocked and
                    focusedTier == (playerTier + 1) and focusedTier <= pricingInfo.maxTier and
                    pricingInfo.nextTierXp > 0 and ownershipInfo.xp >= pricingInfo.nextTierXp
    else
        -- Normal context - can upgrade if owned, not locked, not at max tier, AND have enough XP for next tier
        canUpgrade = ownershipInfo.owned and not ownershipInfo.isLocked and
                    ownershipInfo.tier < pricingInfo.maxTier and
                    pricingInfo.nextTierXp > 0 and ownershipInfo.xp >= pricingInfo.nextTierXp
    end

    local canBuyWithMoney = isBuyable and pricingInfo.buyPrice > 0
    local upgradeEnabled = canUpgrade and pricingInfo.nextTierXp > 0 and ownershipInfo.xp >= pricingInfo.nextTierXp

    if inventoryItem and context == "upgrade_focus" then
        local playerTier = inventoryItem.tier  -- Player's actual owned tier
        local focusedTier = (contextData and contextData.focusedTier) or ownershipInfo.tier  -- Tier being focused on
        local maxTier = pricingInfo.maxTier    -- Maximum tier available
    end

    return {
        isBuyable = isBuyable,
        isEquippable = isEquippable,
        canUpgrade = canUpgrade,
        canBuyWithMoney = canBuyWithMoney,
        upgradeEnabled = upgradeEnabled,
        isInactive = isInactive
    }
end

-- Get card visual properties (texture, color, etc.)
function CardLogic.getCardVisuals(context, cardData, ownershipInfo, cardColors, contextData)
    if not cardData then
        return {
            texture = "ability_card_back",
            txd = "ability_cards",
            color = joaat("COLOR_WHITE"),
            category = "deadeye"
        }
    end

    local category = cardData and cardData.category or "deadeye"
    local cardTexture = cardData and cardData.texture or "ability_card_back"
    local cardTxd = cardData and cardData.txd or "ability_cards"

    -- Use color from lookup table
    local cardColor = joaat("COLOR_WHITE") -- Default fallback
    if cardColors and cardColors[category] and cardColors[category][ownershipInfo.tier] then
        cardColor = cardColors[category][ownershipInfo.tier]
    end

    -- Override with back texture if not owned
    if not ownershipInfo.owned then
        cardTexture = "ability_card_back"
        cardTxd = "ability_cards"
        cardColor = joaat("COLOR_WHITE")
    end

    return {
        texture = cardTexture,
        txd = cardTxd,
        color = cardColor,
        category = category
    }
end

-- Get card text content (title and description)
function CardLogic.getCardText(context, cardData, ownershipInfo, contextData)
    if not cardData then
        return {
            title = "Unknown Card",
            description = ""
        }
    end

    local cardTitle = cardData and cardData.label or ""
    if cardData and cardData.labelHash then
        cardTitle = GetStringFromHashKey(cardData.labelHash)
    end

    -- Determine which tier's description to show
    local tierToShow = ownershipInfo.tier
    if context == "upgrade_focus" and contextData and contextData.focusedTier then
        tierToShow = contextData.focusedTier
    end

    -- Get description from the appropriate tier
    local cardDescription = ""
    if cardData and cardData.tiers and cardData.tiers[tierToShow] then
        if cardData.tiers[tierToShow].descriptionHash then
            cardDescription = GetStringFromHashKey(cardData.tiers[tierToShow].descriptionHash)
        elseif cardData.tiers[tierToShow].description then
            cardDescription = cardData.tiers[tierToShow].description
        end
    end

    return {
        title = cardTitle,
        description = cardDescription
    }
end

-- Create comprehensive card state object (combines all calculations)
function CardLogic.createCardState(context, cardData, inventoryItem, playerRank, loadout, selectedSlotId, slots, slotRules, cardColors, contextData)
    if not cardData then
        return nil
    end

    local ownershipInfo = CardLogic.calculateOwnership(context, cardData, inventoryItem, playerRank, loadout, contextData)
    local pricingInfo = CardLogic.calculatePricing(context, cardData, ownershipInfo, contextData)
    local slotCompatible = CardLogic.checkSlotCompatibility(context, cardData, selectedSlotId, slots, slotRules)
    local xpInfo = CardLogic.calculateXPProgression(context, ownershipInfo, pricingInfo)
    local uiStates = CardLogic.determineUIStates(context, inventoryItem, ownershipInfo, pricingInfo, slotCompatible, contextData)
    local visuals = CardLogic.getCardVisuals(context, cardData, ownershipInfo, cardColors, contextData)
    local text = CardLogic.getCardText(context, cardData, ownershipInfo, contextData)

    return {
        ownership = ownershipInfo,
        pricing = pricingInfo,
        xp = xpInfo,
        ui = uiStates,
        visuals = visuals,
        text = text,
        slotCompatible = slotCompatible
    }
end

-- Make CardLogic globally available
_G.CardLogic = CardLogic
return CardLogic