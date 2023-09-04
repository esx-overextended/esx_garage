---@param garageKey string
---@return boolean
function IsPlayerAuthorizedToAccessGarage(garageKey)
    local groupsToCheck = Config.Garages[garageKey]?.Groups

    return (not groupsToCheck or groupsToCheck == "" and true) or ESX.CanInteractWithGroup(groupsToCheck)
end

---@param coords vector3 | vector4 | table
---@return boolean
function IsCoordsAvailableToSpawn(coords, range)
    coords = vector3(coords.x, coords.y, coords.z)
    range = range or 2.25

    return not IsAnyPedNearPoint(coords.x, coords.y, coords.z, range) and
        not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, range) and
        not IsAnyObjectNearPoint(coords.x, coords.y, coords.z, range, false)
end

function OnPlayerData(key)
    if key ~= "job" and key ~= "groups" then return end

    RefreshBlips()

    for garageKey in pairs(Config.Garages) do
        if IsPlayerInGarageZone(garageKey) then
            if RadialMenu.addItem(garageKey) then return end
        end
    end

    RadialMenu.removeItem()
end

---@param accountName string
---@return string
function GetIconForAccount(accountName)
    if accountName == "money" then
        return "fa-solid fa-money-bill"
    elseif accountName == "bank" then
        return "fa-solid fa-building-columns"
    end

    return "fa-solid fa-money-check-dollar"
end
