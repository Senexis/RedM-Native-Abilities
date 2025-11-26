-- Event handlers for debugging abilities system events
AddEventHandler("native_abilities:abilities_opened", function()
    print("Abilities UI opened")
end)

AddEventHandler("native_abilities:abilities_closed", function()
    print("Abilities UI closed")
end)

AddEventHandler("native_abilities:card_equipped", function(cardId, slotId)
    print("Card equipped:", cardId, "to slot:", slotId)
end)

AddEventHandler("native_abilities:card_removed", function(cardId, slotId)
    print("Card removed:", cardId, "from slot:", slotId)
end)

AddEventHandler("native_abilities:card_purchased", function(cardId)
    print("Card purchased:", cardId)
end)

AddEventHandler("native_abilities:card_upgraded", function(cardId, newTier)
    print("Card upgraded:", cardId, "to tier:", newTier)
end)

AddEventHandler("native_abilities:card_added_to_inventory", function(cardId, tier, xp)
    print("Card added to inventory:", cardId, "tier:", tier, "xp:", xp)
end)

AddEventHandler("native_abilities:card_removed_from_inventory", function(cardId)
    print("Card removed from inventory:", cardId)
end)

AddEventHandler("native_abilities:card_xp_added", function(cardId, xpAmount)
    print("XP added to card:", cardId, "amount:", xpAmount)
end)

AddEventHandler("native_abilities:rank_updated", function(newRank)
    print("Player rank updated to:", newRank)
end)

-- Register commands for testing the abilities triggers

RegisterCommand("abilities_open", function()
    print("Opening abilities UI...")
    TriggerEvent("native_abilities:open_abilities")
end, false)

RegisterCommand("abilities_close", function()
    print("Closing abilities UI...")
    TriggerEvent("native_abilities:close_abilities")
end, false)

RegisterCommand("abilities_loadout_equip", function(source, args)
    local cardId = args[1] or "net_player_ability__paint_it_black"
    local slotId = args[2] or "active_slot"

    print("Equipping card:", cardId, "to slot:", slotId)
    TriggerEvent("native_abilities:equip_card", cardId, slotId)
end, false)

RegisterCommand("abilities_loadout_unequip", function(source, args)
    local slotId = args[1] or "active_slot"

    print("Removing card from slot:", slotId)
    TriggerEvent("native_abilities:remove_card", slotId)
end, false)

RegisterCommand("abilities_sync_loadout", function()
    local testLoadout = {
        active_slot = "net_player_ability__paint_it_black",
        passive_slot_1 = "net_player_ability__strange_medicine",
        passive_slot_2 = "net_player_ability__iron_lung",
        passive_slot_3 = "net_player_ability__come_back_stronger"
    }

    print("Synchronizing loadout with test data...")
    TriggerEvent("native_abilities:synchronize_loadout", testLoadout)
end, false)

RegisterCommand("abilities_sync_inventory", function()
    local testInventory = {
        {
            id = "net_player_ability__paint_it_black",
            owned = true,
            tier = 3,
            xp = 15000
        },
        {
            id = "net_player_ability__focus_fire",
            owned = true,
            tier = 2,
            xp = 8000
        },
        {
            id = "net_player_ability__a_moment_to_recuperate",
            owned = true,
            tier = 1,
            xp = 1500
        },
        {
            id = "net_player_ability__strange_medicine",
            owned = true,
            tier = 3,
            xp = 12000
        },
        {
            id = "net_player_ability__iron_lung",
            owned = true,
            tier = 2,
            xp = 7500
        },
        {
            id = "net_player_ability__come_back_stronger",
            owned = true,
            tier = 1,
            xp = 2000
        },
        {
            id = "net_player_ability__sharpshooter",
            owned = true,
            tier = 2,
            xp = 9000
        },
        {
            id = "net_player_ability__fool_me_once",
            owned = true,
            tier = 1,
            xp = 1800
        }
    }

    print("Synchronizing inventory with test data...")
    TriggerEvent("native_abilities:synchronize_inventory", testInventory)
end, false)

RegisterCommand("abilities_inventory_add", function(source, args)
    local cardId = args[1] or "net_player_ability__paint_it_black"
    local tier = tonumber(args[2]) or 1
    local xp = tonumber(args[3]) or 0

    print("Adding card to inventory:", cardId, "tier:", tier, "xp:", xp)
    TriggerEvent("native_abilities:add_card_to_inventory", cardId, tier, xp)
end, false)

RegisterCommand("abilities_inventory_remove", function(source, args)
    local cardId = args[1] or "net_player_ability__paint_it_black"

    print("Removing card from inventory:", cardId)
    TriggerEvent("native_abilities:remove_card_from_inventory", cardId)
end, false)

RegisterCommand("abilities_add_xp", function(source, args)
    local cardId = args[1] or "net_player_ability__paint_it_black"
    local xpAmount = tonumber(args[2]) or 100

    print("Adding XP to card:", cardId, "amount:", xpAmount)
    TriggerEvent("native_abilities:add_card_xp", cardId, xpAmount)
end, false)

RegisterCommand("abilities_set_rank", function(source, args)
    local newRank = tonumber(args[1]) or 50

    print("Setting player rank to:", newRank)
    TriggerEvent("native_abilities:set_rank", newRank)
end, false)
