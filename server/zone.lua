local garageZones = {}

local function setupGarage(garageIndex)
    local garageData = Config.Garages[garageIndex]
    local polyZone = lib.zones.poly({
        points = garageData.Points,
        thickness = garageData.Thickness or 4,
        onEnter = onGarageZoneEnter,
        onExit = onGarageZoneExit
    })
    garageZones[garageIndex] = polyZone
end

local function initialize()
    if hasInitialized then return end
    hasInitialized = true

    SetTimeout(1000, function()
        print(("^7[^2%s^7] HAS LOADED ^5%s^7 GARAGE DATA(S)"):format(lib.context:upper(), #Config.Garages))
        for index = 1, #Config.Garages do
            setupGarage(index)
        end
    end)
end

do initialize() end


---@param source number
---@param garageIndex number
---@return boolean
function IsPlayerInGarageZone(source, garageIndex)
    source = tonumber(source) --[[@as number]]
    garageIndex = tonumber(garageIndex) --[[@as number]]

    if not source or not garageIndex or not garageZones[garageIndex] then return false end

    return garageZones[garageIndex]:contains(GetEntityCoords(GetPlayerPed(source)))
end
