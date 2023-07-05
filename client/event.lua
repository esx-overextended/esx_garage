AddEventHandler("esx_garages:openGarageMenu", function(data)
    if not IsPlayerInGarageZone(data?.garageKey) or not IsPlayerAuthorizedToAccessGarage(data?.garageKey) then return print("[^1ERROR^7] You are NOT authorized to access this garage at the moment!") end

    local vehicles, contextOptions = lib.callback.await(not Config.Garages[data.garageKey].Groups and "esx_garages:getOwnedVehicles" or "esx_garages:getSocietyVehicles", false, data.garageKey)

    lib.registerContext({
        id = "esx_garages:garageMenu",
        title = Config.Garages[data.garageKey]?.Label,
        options = vehicles and contextOptions
    })

    return lib.showContext("esx_garages:garageMenu")
end)

AddEventHandler("esx_garages:openVehicleMenu", function(data)
    if not IsPlayerInGarageZone(data?.garageKey) or not IsPlayerAuthorizedToAccessGarage(data?.garageKey) then return print("[^1ERROR^7] You are NOT authorized to access this garage at the moment!") end

    local canTakeoutVehicle = data.storedGarage == data.garageKey

    lib.registerContext({
        id = "esx_garages:vehicleMenu",
        title = data.vehicleName,
        menu = "esx_garages:garageMenu",
        options = {
            {
                title = "Transfer vehicle to this garage",
                event = "esx_garages:openGarageMenu",
                args = data,
                arrow = not canTakeoutVehicle,
                disabled = canTakeoutVehicle,
                onSelect = function()
                    lib.callback.await("esx_garages:transferVehicle", false, data)
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

                    TriggerServerEvent("esx_garages:takeOutOwnedVehicle", data)
                end
            },
        }
    })

    return lib.showContext("esx_garages:vehicleMenu")
end)

AddEventHandler("esx_garages:storeOwnedVehicle", function(data)
    if not IsCoordsInGarageZone(GetEntityCoords(data?.entity), data?.garageKey) then return end

    if not IsPlayerInGarageZone(data?.garageKey) or not IsPlayerAuthorizedToAccessGarage(data?.garageKey) then return print("[^1ERROR^7] You are NOT authorized to access this garage at the moment!") end

    data.netId = NetworkGetNetworkIdFromEntity(data.entity)
    data.properties = ESX.Game.GetVehicleProperties(data.entity)

    TriggerServerEvent("esx_garages:storeOwnedVehicle", data)
end)

AddEventHandler("esx_garages:openImpoundMenu", function(data)
    if not IsPlayerInImpoundZone(data?.impoundKey) then return print("[^1ERROR^7] You are NOT authorized to access this impound at the moment!") end

    local vehicles, contextOptions = lib.callback.await("esx_garages:getImpoundedVehicles", false, data.impoundKey)

    lib.registerContext({
        id = "esx_garages:impoundMenu",
        title = Config.Impounds[data.impoundKey]?.Label,
        options = vehicles and contextOptions
    })

    return lib.showContext("esx_garages:impoundMenu")
end)

AddEventHandler("esx_garages:openImpoundConfirmation", function(data)
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
                    { label = "Spawn vehicle & don't transfer it...", value = nil}
                }

                for garageKey, garageData in pairs(Config.Garages) do
                    if DoesPlayerHaveAccessToGroup(garageData.Groups) then
                        inputDialogOptions[#inputDialogOptions + 1] = { label = garageData.Label, value = garageKey }
                    end
                end

                local garageToTransfer = lib.inputDialog(("Garage to transfer %s"):format(data.vehicleName), {
                    { type = "select", label = ("Which garage should %s transfer to?"):format(data.vehicleName), icon = "fa-solid fa-warehouse", options = inputDialogOptions, required = true, clearable = false, }
                }, { allowCancel = true })

                if not garageToTransfer then return lib.showContext("esx_garages:impoundConfirmation") end

                data.garage = garageToTransfer[1]
                data.account = account?.name

                if not data.garage then
                    for i = 1, #Config.Impounds[data.impoundKey].Spawns do
                        if IsCoordsAvailableToSpawn(Config.Impounds[data.impoundKey].Spawns[i]) then
                            data.spawnIndex = i
                            break
                        end
                    end

                    if not data.spawnIndex then ESX.ShowNotification("None of the spawn points are clear at the moment!") return lib.showContext("esx_garages:impoundConfirmation") end
                end

                TriggerServerEvent("esx_garages:removeVehicleFromImpound", data)
            end
        }
    end

    lib.registerContext({
        id = "esx_garages:impoundConfirmation",
        title = data.vehicleName,
        menu = "esx_garages:impoundMenu",
        options = options
    })

    return lib.showContext("esx_garages:impoundConfirmation")
end)