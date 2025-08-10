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
