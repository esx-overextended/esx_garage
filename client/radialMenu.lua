RadialMenu = {
    SubId = "garage_radial_menu",
    GlobalId = "garage_radial_menu_access"
}

local function registerRadialMenu(seatState)
    local items = { {
        label = "Open Garage",
        icon = "warehouse",
        onSelect = function()
            for garageKey in pairs(Config.Garages) do
                if IsPlayerInGarageZone(garageKey) then
                    TriggerEvent("esx_garages:openGarageMenu", { garageKey = garageKey })
                end
            end
        end
    } }

    if seatState == -1 then
        items[2] = {
            label = "Store Vehicle",
            icon = "fa-solid fa-parking",
            onSelect = function()
                local vehicleNetId = NetworkGetNetworkIdFromEntity(cache.vehicle)

                for garageKey in pairs(Config.Garages) do
                    if IsPlayerInGarageZone(garageKey) then
                        TriggerServerEvent("esx_garages:storeOwnedVehicle", { entity = vehicleNetId, garageKey = garageKey })
                    end
                end
            end
        }
    end

    lib.registerRadial({
        id = RadialMenu.SubId,
        items = items
    })
end

lib.onCache("seat", function(value)
    registerRadialMenu(value)
end)

do registerRadialMenu(cache.seat) end
