local currentRentedVehicle = nil

function OpenVehicleRental(zoneIndex)
    local playerStats = Bridge.GetPlayerStats()
    local stats = Bridge.GetDivingStats(playerStats.divingXP, playerStats.divingLevel)
    
    local options = {}

    for _, vehicle in ipairs(Config.VehicleRentals) do
        local isUnlocked = stats.level >= vehicle.level
        local color = isUnlocked and '#66bb6a' or '#f44336'
        local description = isUnlocked and vehicle.description or 'Requires Level ' .. vehicle.level

        table.insert(options, {
            title = vehicle.label,
            description = description,
            icon = 'fas fa-ship',
            iconColor = color,
            disabled = not isUnlocked,
            image = vehicle.image,
            metadata = {
                { label = 'Price', value = '$' .. (math.groupdigits and math.groupdigits(vehicle.price) or vehicle.price) },
                { label = 'Level Required', value = vehicle.level }
            },
            onSelect = function()
                if isUnlocked then
                    RentVehicle(vehicle, zoneIndex)
                end
            end
        })
    end

    lib.registerContext({
        id = 'vehicle_rental_menu',
        title = 'Vehicle Rental',
        menu = 'diving_job_menu',
        options = options
    })

    lib.showContext('vehicle_rental_menu')
end

function RentVehicle(vehicle, zoneIndex)
    local input = lib.inputDialog('Rent ' .. vehicle.label, {
        {
            type = 'number',
            label = 'Rental Duration (hours)',
            description = 'How long do you want to rent this vehicle?',
            default = 1,
            min = 1,
            max = 24
        }
    })

    if not input then return end

    local duration = input[1]
    local totalPrice = vehicle.price * duration

    local confirm = lib.alertDialog({
        header = 'Confirm Rental',
        content = string.format('Rent %s for %d hour(s) for $%s?', vehicle.label, duration,
            math.groupdigits and math.groupdigits(totalPrice) or totalPrice),
        centered = true,
        cancel = true
    })

    if confirm == 'confirm' then
        TriggerServerEvent('peleg-diving:server:RentVehicle', vehicle.name, duration, totalPrice, zoneIndex)
    end
end

---@param vehicle number The vehicle entity to set fuel for
---@param fuelLevel number The fuel level to set (0-100)
local function SetVehicleFuel(vehicle, fuelLevel)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    
    local fuelSystem = Config.FuelSystem
    
    if fuelSystem == 'auto' then
        if GetResourceState('lc_fuel') == 'started' then
            fuelSystem = 'lc_fuel'
        elseif GetResourceState('ox_fuel') == 'started' then
            fuelSystem = 'ox_fuel'
        elseif GetResourceState('qb-fuel') == 'started' then
            fuelSystem = 'qb_fuel'
        else
            fuelSystem = 'legacy'
        end
    end
    
    if fuelSystem == 'lc_fuel' then
        exports['lc_fuel']:SetFuel(vehicle, fuelLevel)
    elseif fuelSystem == 'ox_fuel' then
        Entity(vehicle).state.fuel = fuelLevel
        -- exports['ox_fuel']:SetFuel(vehicle, fuelLevel)
    elseif fuelSystem == 'qb_fuel' then
        TriggerEvent('qb-fuel:client:SetFuel', vehicle, fuelLevel)
    else
        SetVehicleFuelLevel(vehicle, fuelLevel)
    end
end

RegisterNetEvent('peleg-diving:client:SpawnRentedVehicle', function(vehicleName, zoneIndex)
    if currentRentedVehicle and DoesEntityExist(currentRentedVehicle) then
        DeleteEntity(currentRentedVehicle)
    end

    local vehicleConfig = nil
    for _, vehicle in ipairs(Config.VehicleRentals) do
        if vehicle.name == vehicleName then
            vehicleConfig = vehicle
            break
        end
    end

    if not vehicleConfig then return end

    local spawnPoint = nil
    if zoneIndex and Config.DivingZones[zoneIndex] and Config.DivingZones[zoneIndex].vehicleSpawnPoint then
        spawnPoint = Config.DivingZones[zoneIndex].vehicleSpawnPoint
    end

    local modelHash = GetHashKey(vehicleConfig.model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(1)
    end

    currentRentedVehicle = CreateVehicle(modelHash, spawnPoint.x, spawnPoint.y, spawnPoint.z, spawnPoint.w, true, false)

    if not currentRentedVehicle or currentRentedVehicle == 0 then
        lib.notify({ title = 'Vehicle Rental', description = 'Failed to spawn vehicle!', type = 'error' })
        return
    end

    SetEntityAsMissionEntity(currentRentedVehicle, true, true)
    SetVehicleEngineOn(currentRentedVehicle, false, true, true)
    SetVehicleDoorsLocked(currentRentedVehicle, 1)

    SetVehicleFuel(currentRentedVehicle, Config.DefaultFuelLevel)

    TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(currentRentedVehicle))

    SetModelAsNoLongerNeeded(modelHash)
end)

function ReturnRentedVehicle()
    if currentRentedVehicle and DoesEntityExist(currentRentedVehicle) then
        DeleteEntity(currentRentedVehicle)
        currentRentedVehicle = nil

        lib.notify({ title = 'Vehicle Rental', description = 'Vehicle returned successfully!', type = 'success' })
    else
        lib.notify({ title = 'Vehicle Rental', description = 'No rented vehicle to return!', type = 'error' })
    end
end
