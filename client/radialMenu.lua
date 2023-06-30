RadialMenu = {}

local radialMenuSubId = "garage_radial_menu"
local radialMenuGlobalId = "garage_radial_menu_access"

local function registerRadialMenu(seatState)
    local items = { {
        label = "Open Garage",
        icon = "warehouse",
        onSelect = function()
            for garageKey in pairs(Config.Garages) do
                if IsPlayerInGarageZone(garageKey) then
                    TriggerEvent("esx_garages:openGarageMenu", { garageKey = garageKey })
                    break
                end
            end
        end
    } }

    if seatState == -1 then
        items[2] = {
            label = "Store Vehicle",
            icon = "fa-solid fa-parking",
            onSelect = function()
                for garageKey in pairs(Config.Garages) do
                    if IsPlayerInGarageZone(garageKey) then
                        TriggerServerEvent("esx_garages:storeOwnedVehicle", { netId = NetworkGetNetworkIdFromEntity(cache.vehicle), garageKey = garageKey, properties = ESX.Game.GetVehicleProperties(cache.vehicle) })
                        break
                    end
                end
            end
        }
    end

    lib.registerRadial({
        id = radialMenuSubId,
        items = items
    })
end

lib.onCache("seat", function(value)
    registerRadialMenu(value)
end)

do registerRadialMenu(cache.seat) end

function RadialMenu.addItem(garageKey)
    if not IsPlayerAuthorizedToAccessGarage(garageKey) then return false end

    lib.addRadialItem({
        id = radialMenuGlobalId,
        icon = "warehouse",
        label = "Garage",
        menu = radialMenuSubId
    })

    return true
end

function RadialMenu.removeItem()
    lib.removeRadialItem(radialMenuGlobalId)

    return true
end
