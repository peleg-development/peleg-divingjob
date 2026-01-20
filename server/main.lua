--- Helper function to retrieve the coordinates of a player as a vector3.
--- @param src The source ID of the player.
--- @return vector3 The player's coordinates or a default zero vector if not found.
local function GetPlayerCoords(src)
    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 then
        local x, y, z = table.unpack(GetEntityCoords(ped))
        return vector3(x, y, z)
    end
    return vector3(0.0, 0.0, 0.0)
end

--- Checks if the player is within any defined diving zone.
--- @param src The source ID of the player.
--- @return boolean Whether the player is in a diving zone.
--- @return number|nil The index of the zone if found.
--- @return table|nil The zone data if found.
local function IsPlayerInAnyDivingZone(src)
    if not Config.DivingZones then 
        return false, nil, nil 
    end
    local coords = GetPlayerCoords(src)
    for zoneIndex, zone in ipairs(Config.DivingZones) do
        local distance = #(coords - zone.coords)
        if distance <= zone.radius then
            return true, zoneIndex, zone
        end
    end
    return false, nil, nil
end

--- Determines if the player is near any diving shop or a fallback location.
--- @param src The source ID of the player.
--- @param radius Optional radius to check (default 6.0).
--- @return boolean True if near a shop.
local function IsNearAnyShop(src, radius)
    radius = 20
    local coords = GetPlayerCoords(src)
    local fallbackShop = Config.ShopPed.coords.xyz
    if #(coords - fallbackShop) <= radius then 
        return true 
    end
    return false
end

--- Finds a shop item by its name in the configuration.
--- @param name The name of the item to find.
--- @return table|nil The item data if found.
local function FindShopItem(name)
    if not name or not Config.ShopItems then 
        return nil 
    end
    for _, it in ipairs(Config.ShopItems) do
        if it.item == name then 
            return it 
        end
    end
    return nil
end

--- Sanitizes and clamps a quantity value between 1 and 10.
--- @param q The quantity to sanitize.
--- @return number The sanitized quantity.
local function SanitizeQuantity(q)
    local n = tonumber(q) or 0
    n = math.floor(n)
    if n < 1 then n = 1 end
    if n > 10 then n = 10 end
    return n
end

--- Gets current player diving level from metadata, falling back to 1.
--- @param source number
--- @return number
local function GetLevel(source)
    local lvl = Bridge.GetMeta(source, 'divingLevel', 1)
    if not lvl then return 1 end
    lvl = tonumber(lvl) or 1
    if lvl < 1 then lvl = 1 end
    if lvl > #Config.Levels then lvl = #Config.Levels end
    return lvl
end

--- Table to track the last time a player claimed loot, to prevent spamming.
local lastLootClaimAt = {}

--- Retrieves the player's diving experience and level.
--- @param source The source ID of the player.
--- @return table Diving stats (divingXP and divingLevel).
local function GetPlayerDivingStats(source)
    local divingXP = Bridge.GetMeta(source, 'divingXP', 0)
    local divingLevel = Bridge.GetMeta(source, 'divingLevel', 1)
    if divingXP == nil then divingXP = 0 end
    if divingLevel == nil then divingLevel = 1 end
    return { divingXP = divingXP, divingLevel = divingLevel }
end

--- Event handler for giving loot from a container while diving.
RegisterNetEvent('peleg-diving:server:GiveContainerLoot', function(containerId, containerTypeName, zoneIndex)
    local source = source
    local Player = Bridge.GetPlayer(source)
    if not Player then return end

    local isInZone, actualZoneIndex, zone = IsPlayerInAnyDivingZone(source)
    if not isInZone or (zoneIndex ~= nil and zoneIndex ~= actualZoneIndex) then
        return
    end

    local requestedType = nil
    for _, c in ipairs(Config.Containers) do
        if c.name == containerTypeName then
            requestedType = c
            break
        end
    end
    if not requestedType then return end
    
    local allowed = false
    if zone and zone.containers then
        for _, n in ipairs(zone.containers) do 
            if n == requestedType.name then
                allowed = true
                break
            end
        end
    end
    if not allowed then return end

    local now = os.time()
    if (lastLootClaimAt[source] or 0) + 3 > now then return end
    lastLootClaimAt[source] = now

    local itemsToGive = {}
    local itemCount = math.random(1, requestedType.maxItems)
    local rareItemsFound = 0
    local selectedItems = {}

    for i = 1, itemCount do
        local totalWeight = 0
        local availableItems = {}

        for _, item in ipairs(requestedType.lootTable) do
            if not selectedItems[item.item] then
                totalWeight = totalWeight + item.chance
                table.insert(availableItems, item)
            end
        end

        if #availableItems == 0 then
            break
        end

        local randomValue = math.random(1, totalWeight)
        local currentWeight = 0
        local selectedItem = nil

        for _, item in ipairs(availableItems) do
            currentWeight = currentWeight + item.chance
            if randomValue <= currentWeight then
                selectedItem = item
                break
            end
        end

        if selectedItem then
            local amount = math.random(selectedItem.min, selectedItem.max)
            table.insert(itemsToGive, {
                name = selectedItem.item,
                amount = amount
            })

            selectedItems[selectedItem.item] = true

            if selectedItem.item == 'diamond' or selectedItem.item == 'emerald' or selectedItem.item == 'ruby' or
                selectedItem.item == 'rare_gem' or selectedItem.item == 'ancient_artifact' or selectedItem.item == 'ancient_coin' then
                rareItemsFound = rareItemsFound + 1
            end
        end
    end

    for _, item in ipairs(itemsToGive) do
        if Bridge and Bridge.AddItem then
            Bridge.AddItem(source, item.name, item.amount)
        else
            exports.ox_inventory:AddItem(source, item.name, item.amount)
        end
    end

    local xpGain = requestedType.xpReward
    if rareItemsFound > 0 then
        xpGain = xpGain + (rareItemsFound * Config.XP.RareItemFound)
    end

    local metadata = GetPlayerDivingStats(source)
    if metadata then
        local currentLevel = tonumber(metadata.divingLevel) or 1
        local oldLevelStored = currentLevel
        local xpWithinLevel = tonumber(metadata.divingXP) or 0

        if currentLevel < 1 then currentLevel = 1 end
        if currentLevel > #Config.Levels then currentLevel = #Config.Levels end

        if currentLevel >= #Config.Levels then
            xpWithinLevel = 0
        else
            xpWithinLevel = xpWithinLevel + xpGain

            while currentLevel < #Config.Levels do
                local currentThreshold = Config.Levels[currentLevel] or 0
                local nextThreshold = Config.Levels[currentLevel + 1] or currentThreshold
                local needed = nextThreshold - currentThreshold
                if needed <= 0 then break end
                if xpWithinLevel >= needed then
                    currentLevel = currentLevel + 1
                    if currentLevel >= #Config.Levels then
                        xpWithinLevel = 0
                        break
                    end
                    xpWithinLevel = 0
                else
                    break
                end
            end
        end

        Bridge.SetMeta(source, 'divingLevel', currentLevel)
        Bridge.SetMeta(source, 'divingXP', xpWithinLevel)

        if currentLevel > oldLevelStored then
            local levelInfo = Config.LevelColors[currentLevel]
            local levelName = levelInfo and levelInfo.name or 'Unknown'
            TriggerClientEvent('peleg-diving:client:notify', source, {
                title = 'Diving',
                description = string.format('Level Up! You are now Level %d %s', currentLevel, levelName),
                type = 'success'
            })
        end
    end

    local itemCount = #itemsToGive
    if itemCount > 0 then
        TriggerClientEvent('peleg-diving:client:notify', source,
            {
                title = 'Diving Job',
                description = string.format('Found %d items in %s! +%d XP', itemCount,
                    requestedType.label, xpGain),
                type = 'success'
            })
    else
        TriggerClientEvent('peleg-diving:client:notify', source,
            { title = 'Diving Job', description = string.format('Container was empty! +%d XP', xpGain), type = 'inform' })
    end
end)

--- Secure server-side handler for selling diving items based on config prices.
RegisterNetEvent('peleg-diving:server:SellItem', function(itemName, quantity)
    local source = source
    local Player = Bridge.GetPlayer(source)
    if not Player then return end

    if type(itemName) ~= 'string' or itemName == '' then return end
    local unitPrice = 0
    if Config.SellPrices and Config.SellPrices[itemName] then
        local itemData = Config.SellPrices[itemName]
        unitPrice = tonumber(itemData.price) or 0
    end
    if unitPrice <= 0 then
        TriggerClientEvent('peleg-diving:client:notify', source,
            { title = 'Diving', description = 'Item cannot be sold', type = 'error' })
        return
    end

    local hasCount = 0
    if Bridge.Inventory == 'ox' then
        hasCount = exports.ox_inventory:Search(source, 'count', itemName) or 0
    elseif Bridge.Inventory == 'qs' then
        local item = exports['qs-inventory']:GetItemByName(source, itemName)
        hasCount = (item and item.amount or 0)
    elseif Bridge.Inventory == 'qb' then
        local p = Bridge.GetPlayer(source)
        local invItem = p and p.Functions.GetItemByName and p.Functions.GetItemByName(itemName)
        hasCount = (invItem and invItem.amount or 0)
    end

    if hasCount <= 0 then
        TriggerClientEvent('peleg-diving:client:notify', source,
            { title = 'Diving', description = 'You do not have this item', type = 'error' })
        return
    end

    local qty = tonumber(quantity) or 0
    if qty <= 0 or qty > hasCount then
        qty = hasCount
    end
    if qty <= 0 then return end

    local total = unitPrice * qty
    if total <= 0 then return end

    local removed = false
    if Bridge.RemoveItem then
        removed = Bridge.RemoveItem(source, itemName, qty)
    else
        if Bridge.Inventory == 'ox' then
            removed = exports.ox_inventory:RemoveItem(source, itemName, qty)
        elseif Bridge.Inventory == 'qs' then
            removed = exports['qs-inventory']:RemoveItem(source, itemName, qty)
        elseif Bridge.Inventory == 'qb' then
            local p = Bridge.GetPlayer(source)
            removed = p and p.Functions.RemoveItem and p.Functions.RemoveItem(itemName, qty) or false
        end
    end

    if not removed then
        TriggerClientEvent('peleg-diving:client:notify', source,
            { title = 'Diving', description = 'Failed to remove items', type = 'error' })
        return
    end

    if Bridge.AddMoney then
        Bridge.AddMoney(source, 'cash', total, 'diving-sell')
    end

    TriggerClientEvent('peleg-diving:client:notify', source,
        { title = 'Diving', description = ('Sold %dx %s for $%s'):format(qty, itemName, total), type = 'success' })
end)

--- Event handler for purchasing items from the diving shop.
RegisterNetEvent('peleg-diving:server:PurchaseItem', function(itemName, quantity, _clientTotal)
    local source = source
    local Player = Bridge.GetPlayer(source)
    if not Player then return end

    local shopItem = FindShopItem(itemName)

    if not shopItem then
        TriggerClientEvent('peleg-diving:client:notify', source,
            { title = 'Diving Shop', description = 'Item not found in shop!', type = 'error' })
        return
    end

    local qty = SanitizeQuantity(quantity)

    local playerLevel = GetLevel(source)
    if shopItem.level and playerLevel < shopItem.level then
        TriggerClientEvent('peleg-diving:client:notify', source,
            { title = 'Diving Shop', description = ('Requires Level %d'):format(shopItem.level), type = 'error' })
        return
    end

    local totalPrice = (shopItem.price or 0) * qty
    if totalPrice <= 0 then
        TriggerClientEvent('peleg-diving:client:notify', source,
            { title = 'Diving Shop', description = 'Invalid price for item.', type = 'error' })
        return
    end

    if Bridge.GetMoney(source, 'cash') < totalPrice then
        TriggerClientEvent('peleg-diving:client:notify', source,
            { title = 'Diving Shop', description = 'Not enough cash!', type = 'error' })
        return
    end

    if Bridge and Bridge.RemoveMoney then
        Bridge.RemoveMoney(source, 'cash', totalPrice, 'diving-shop-purchase')
    else
        Player.Functions.RemoveMoney('cash', totalPrice, 'diving-shop-purchase')
    end
    if Bridge and Bridge.AddItem then
        Bridge.AddItem(source, itemName, qty)
    else
        exports.ox_inventory:AddItem(source, itemName, qty)
    end

    TriggerClientEvent('peleg-diving:client:notify', source,
        { title = 'Diving Shop', description = 'Purchase successful!', type = 'success' })
end)



--- Event handler for renting a vehicle in a diving zone.
RegisterNetEvent('peleg-diving:server:RentVehicle', function(vehicleName, _duration, _clientTotal, zoneIndex)
    local source = source
    local Player = Bridge.GetPlayer(source)
    if not Player then return end

    local vehicleConfig = nil
    for _, vehicle in ipairs(Config.VehicleRentals) do
        if vehicle.name == vehicleName then
            vehicleConfig = vehicle
            break
        end
    end

    if not vehicleConfig then
        TriggerClientEvent('peleg-diving:client:notify', source,
            { title = 'Vehicle Rental', description = 'Vehicle not found!', type = 'error' })
        return
    end

    local metadata = GetPlayerDivingStats(source)
    if not metadata or metadata.divingLevel < vehicleConfig.level then
        TriggerClientEvent('peleg-diving:client:notify', source,
            {
                title = 'Vehicle Rental',
                description = 'You need level ' ..
                    vehicleConfig.level .. ' to rent this vehicle!',
                type = 'error'
            })
        return
    end

    local totalPrice = vehicleConfig.price or 0
    if totalPrice <= 0 then
        TriggerClientEvent('peleg-diving:client:notify', source,
            { title = 'Vehicle Rental', description = 'Invalid rental price.', type = 'error' })
        return
    end

    if Bridge.GetMoney(source, 'cash') < totalPrice then
        TriggerClientEvent('peleg-diving:client:notify', source,
            { title = 'Vehicle Rental', description = 'Not enough cash!', type = 'error' })
        return
    end

    if Bridge and Bridge.RemoveMoney then
        Bridge.RemoveMoney(source, 'cash', totalPrice, 'vehicle-rental')
    else
        Player.Functions.RemoveMoney('cash', totalPrice, 'vehicle-rental')
    end
    TriggerClientEvent('peleg-diving:client:SpawnRentedVehicle', source, vehicleName, zoneIndex)

    TriggerClientEvent('peleg-diving:client:notify', source,
        { title = 'Vehicle Rental', description = 'Vehicle rented successfully!', type = 'success' })
end)


local RESOURCE = GetCurrentResourceName()
local VERSION_URL = "https://raw.githubusercontent.com/peleg-development/peleg-divingjob/main/version.txt"

CreateThread(function()
    Wait(3000)

    local currentVersion = GetResourceMetadata(RESOURCE, "version", 0)

    if not currentVersion then
        print(("^1[%s]^7 Version not found in fxmanifest.lua"):format(RESOURCE))
        return
    end

    PerformHttpRequest(VERSION_URL, function(status, response)
        if status ~= 200 or not response then
            print(("^1[%s]^7 Failed to fetch version.txt"):format(RESOURCE))
            return
        end

        local lines = {}
        for line in response:gmatch("[^\r\n]+") do
            lines[#lines + 1] = line
        end

        local latestVersion = lines[1]

        if not latestVersion then
            print(("^1[%s]^7 Invalid version.txt format"):format(RESOURCE))
            return
        end

        if latestVersion == currentVersion then
            print(("^2[%s]^7 Up to date (v%s)"):format(RESOURCE, currentVersion))
        else
            print(("^3[%s]^7 Outdated!"):format(RESOURCE))
            print(("^7Current: ^1v%s^7 | Latest: ^2v%s"):format(currentVersion, latestVersion))

            for i = 2, #lines do
                print("^7" .. lines[i])
            end
        end
    end, "GET")
end)
