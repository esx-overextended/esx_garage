local garageZones = {}

local function setupGarage(garageKey)
    local garageData = Config.Garages[garageKey]
    local polyZone = lib.zones.poly({
        points = garageData.Points,
        thickness = garageData.Thickness or 4,
        onEnter = onGarageZoneEnter,
        onExit = onGarageZoneExit
    })
    garageZones[garageKey] = polyZone
end

local function initialize()
    if hasInitialized then return end
    hasInitialized = true

    SetTimeout(1000, function()
        for key in pairs(Config.Garages) do
            setupGarage(key)
        end
    end)
end

do initialize() end


---@param source number
---@param garageKey string
---@return boolean
function IsPlayerInGarageZone(source, garageKey)
    source = tonumber(source) --[[@as number]]
    garageKey = tostring(garageKey) --[[@as string]]

    if not source or not garageKey or not garageZones[garageKey] then return false end

    return garageZones[garageKey]:contains(GetEntityCoords(GetPlayerPed(source)))
end

---@param coords vector3
---@param garageKey string
---@return boolean
function IsCoordsInGarageZone(coords, garageKey)
    coords = vector3(coords.x, coords.y, coords.z)
    garageKey = tostring(garageKey) --[[@as string]]

    if not coords or not garageKey or not garageZones[garageKey] then return false end

    return garageZones[garageKey]:contains(coords)
end
