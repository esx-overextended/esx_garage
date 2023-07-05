local garageZones, impoundZones = {}, {}

local function setupGarage(garageKey)
    local garageData = Config.Garages[garageKey]
    local polyZone = lib.zones.poly({
        points = garageData.Points,
        thickness = garageData.Thickness or 4
    })
    garageZones[garageKey] = polyZone
end

local function setupImpound(impoundKey)
    local impoundData = Config.Impounds[impoundKey]
    local polyZone = lib.zones.poly({
        points = impoundData.Points,
        thickness = impoundData.Thickness or 4
    })
    impoundZones[impoundKey] = polyZone
end

SetTimeout(1000, function()
    for key in pairs(Config.Garages) do
        setupGarage(key)
    end

    for key in pairs(Config.Impounds) do
        setupImpound(key)
    end
end)

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

---@param source number
---@param impoundKey string
---@return boolean
function IsPlayerInImpoundZone(source, impoundKey)
    source = tonumber(source) --[[@as number]]
    impoundKey = tostring(impoundKey) --[[@as string]]

    if not source or not impoundKey or not impoundZones[impoundKey] then return false end

    return impoundZones[impoundKey]:contains(GetEntityCoords(GetPlayerPed(source)))
end
