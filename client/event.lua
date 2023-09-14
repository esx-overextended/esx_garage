local function onLoad()
    Wait(1000)

    if ESX.IsPlayerLoaded() then RefreshBlips() end
end

AddEventHandler("esx:playerLoaded", onLoad)

local function onResourceStart(resource)
    return resource == cache.resource and onLoad()
end

AddEventHandler("ontResourceStart", onResourceStart)
AddEventHandler("onClientResourceStart", onResourceStart)

AddEventHandler("esx_garage:openGarageMenu", function(data)
    if not IsPlayerInGarageZone(data?.garageKey) or not IsPlayerAuthorizedToAccessGarage(data?.garageKey) then return print("[^1ERROR^7] You are NOT authorized to access this garage at the moment!") end

    local vehicles, contextOptions = lib.callback.await(not Config.Garages[data.garageKey].Groups and "esx_garage:getOwnedVehicles" or "esx_garage:getSocietyVehicles", false, data.garageKey)

    lib.registerContext({
        id = "esx_garage:garageMenu",
        title = Config.Garages[data.garageKey]?.Label,
        options = vehicles and contextOptions
    })

    return lib.showContext("esx_garage:garageMenu")
end)

AddEventHandler("esx_garage:openVehicleMenu", function(data)
    if not IsPlayerInGarageZone(data?.garageKey) or not IsPlayerAuthorizedToAccessGarage(data?.garageKey) then return print("[^1ERROR^7] You are NOT authorized to access this garage at the moment!") end

    local canTakeoutVehicle = data.storedGarage == data.garageKey

    lib.registerContext({
        id = "esx_garage:vehicleMenu",
        title = data.vehicleName,
        menu = "esx_garage:garageMenu",
        options = {
            {
                title = "Transfer vehicle to this garage",
                event = "esx_garage:openGarageMenu",
                args = data,
                arrow = not canTakeoutVehicle,
                disabled = canTakeoutVehicle,
                onSelect = function()
                    lib.callback.await("esx_garage:transferVehicle", false, data)
                end
            },
            {
                title = "Take out vehicle",
                arrow = canTakeoutVehicle,
                disabled = not canTakeoutVehicle,
                onSelect = function()
                    if Shared.AvailableSpawnPointIndicator == lib.context then
                        local spawnPoints = {}

                        for i = 1, #Config.Garages[data.garageKey].Spawns do
                            local spawnPoint = Config.Garages[data.garageKey].Spawns[i]
                            spawnPoints[i] = { x = spawnPoint.x, y = spawnPoint.y, z = spawnPoint.z, index = i }
                        end

                        local coords = vector3(cache.coords.x, cache.coords.y, cache.coords.z)

                        table.sort(spawnPoints, function(a, b)
                            return #(vector3(a.x, a.y, a.z) - coords) < #(vector3(b.x, b.y, b.z) - coords)
                        end)

                        for i = 1, #spawnPoints do
                            local spawnPoint = spawnPoints[i]

                            if IsCoordsAvailableToSpawn(spawnPoint) then
                                data.spawnIndex = spawnPoint.index
                                break
                            end
                        end
                    end

                    TriggerServerEvent("esx_garage:takeOutOwnedVehicle", data)
                end
            },
        }
    })

    return lib.showContext("esx_garage:vehicleMenu")
end)

AddEventHandler("esx_garage:storeOwnedVehicle", function(data)
    if not IsCoordsInGarageZone(GetEntityCoords(data?.entity), data?.garageKey) then return end

    if not IsPlayerInGarageZone(data?.garageKey) or not IsPlayerAuthorizedToAccessGarage(data?.garageKey) then return print("[^1ERROR^7] You are NOT authorized to access this garage at the moment!") end

    data.netId = NetworkGetNetworkIdFromEntity(data.entity)
    data.properties = ESX.Game.GetVehicleProperties(data.entity)

    TriggerServerEvent("esx_garage:storeOwnedVehicle", data)
end)

AddEventHandler("esx_garage:openImpoundMenu", function(data)
    if not IsPlayerInImpoundZone(data?.impoundKey) then return print("[^1ERROR^7] You are NOT authorized to access this impound at the moment!") end

    local vehicles, contextOptions = lib.callback.await("esx_garage:getImpoundedVehicles", false, data.impoundKey)

    lib.registerContext({
        id = "esx_garage:impoundMenu",
        title = Config.Impounds[data.impoundKey]?.Label,
        options = vehicles and contextOptions
    })

    return lib.showContext("esx_garage:impoundMenu")
end)

AddEventHandler("esx_garage:openImpoundConfirmation", function(data)
    if not IsPlayerInImpoundZone(data?.impoundKey) then return print("[^1ERROR^7] You are NOT authorized to access this impound at the moment!") end

    local accounts, options = { ["bank"] = true, ["money"] = true }, {}

    for i = 1, #ESX.PlayerData.accounts do
        local accountName = ESX.PlayerData.accounts[i]

        if accounts[accountName?.name] then
            accounts[accountName.name] = i
        end
    end

    for _, accountIndex in pairs(accounts) do
        local account = ESX.PlayerData.accounts[accountIndex]
        local canUseThisAccount = account?.money >= data.releaseFee

        options[#options + 1] = {
            title = ("Pay impound price with %s"):format(account?.label),
            description = ("Release Fee: $%s"):format(data.releaseFee),
            icon = GetIconForAccount(account?.name),
            iconColor = canUseThisAccount and "green" or "red",
            arrow = canUseThisAccount,
            disabled = not canUseThisAccount,
            onSelect = function()
                lib.hideContext()

                local inputDialogOptions = {
                    { label = "Spawn vehicle & don't transfer it...", value = nil }
                }

                for garageKey, garageData in pairs(Config.Garages) do
                    if IsPlayerAuthorizedToAccessGarage(garageKey) then
                        inputDialogOptions[#inputDialogOptions + 1] = { label = garageData.Label, value = garageKey }
                    end
                end

                local garageToTransfer = lib.inputDialog(("Garage to transfer %s"):format(data.vehicleName), {
                    { type = "select", label = ("Which garage should %s transfer to?"):format(data.vehicleName), icon = "fa-solid fa-warehouse", options = inputDialogOptions, clearable = false, }
                }, { allowCancel = true })

                if not garageToTransfer then return lib.showContext("esx_garage:impoundConfirmation") end

                data.garage = garageToTransfer[1]
                data.account = account?.name

                if not data.garage then
                    for i = 1, #Config.Impounds[data.impoundKey].Spawns do
                        if IsCoordsAvailableToSpawn(Config.Impounds[data.impoundKey].Spawns[i]) then
                            data.spawnIndex = i
                            break
                        end
                    end

                    if not data.spawnIndex then
                        ESX.ShowNotification("None of the spawn points are clear at the moment!")
                        return lib.showContext("esx_garage:impoundConfirmation")
                    end
                end

                TriggerServerEvent("esx_garage:removeVehicleFromImpound", data)
            end
        }
    end

    lib.registerContext({
        id = "esx_garage:impoundConfirmation",
        title = data.vehicleName,
        menu = "esx_garage:impoundMenu",
        options = options
    })

    return lib.showContext("esx_garage:impoundConfirmation")
end)
