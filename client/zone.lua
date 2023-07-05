local zone, garageZones, impoundZones = {}, {}, {}

function zone.configureRadialMenu(action, data)
    if not data.garageKey or not data.RadialMenu and not Config.RadialMenu then return end

    if action == "enter" then
        RadialMenu.addItem(data.garageKey)
    elseif action == "exit" then
        RadialMenu.removeItem()
    end
end

function zone.configureVehicle(action, data)
    if not data.garageKey then return end

    if action == "enter" then
        garageZones[data.garageKey].vehicleTargetId = Target.addVehicle(data.garageKey)
    elseif action == "exit" then
        local vehicleTargetId = garageZones[data.garageKey].vehicleTargetId
        garageZones[data.garageKey].vehicleTargetId = nil

        Target.removeVehicle(vehicleTargetId)
    end
end

function zone.configurePed(action, data)
    local zoneData = Config.Garages[data.garageKey] or Config.Impounds[data.impoundKey]

    if not zoneData or not zoneData?.Peds then return end

    local zoneKey = data.garageKey or data.impoundKey
    local zoneTable = data.garageKey and garageZones or data.impoundKey and impoundZones

    if action == "enter" then
        for i = 1, #zoneData.Peds do
            local ped = zoneData.Peds[i]
            local pedModel = ped.Model or Config.DefaultPed --[[@as number | string]]
            pedModel = type(pedModel) == "string" and joaat(pedModel) or pedModel --[[@as number]]

            lib.requestModel(pedModel, 1000)

            local pedEntity = CreatePed(0, pedModel, ped.Coords.x, ped.Coords.y, ped.Coords.z, ped.Coords.w, false, true)

            SetPedFleeAttributes(pedEntity, 2, true)
            SetBlockingOfNonTemporaryEvents(pedEntity, true)
            SetPedCanRagdollFromPlayerImpact(pedEntity, false)
            SetPedDiesWhenInjured(pedEntity, false)
            FreezeEntityPosition(pedEntity, true)
            SetEntityInvincible(pedEntity, true)
            SetPedCanPlayAmbientAnims(pedEntity, false)

            if not zoneTable[zoneKey].pedEntities then zoneTable[zoneKey].pedEntities = {} end

            zoneTable[zoneKey].pedEntities[#zoneTable[zoneKey].pedEntities + 1] = pedEntity
        end

        zoneTable[zoneKey].pedTargetId = Target.addPed(zoneTable[zoneKey].pedEntities, data)
    elseif action == "exit" then
        local pedEntities = zoneTable[zoneKey].pedEntities
        zoneTable[zoneKey].pedEntities = nil

        for i = 1, #pedEntities do
            DeletePed(pedEntities[i])
        end

        local pedTargetId = zoneTable[zoneKey].pedTargetId
        zoneTable[zoneKey].pedTargetId = nil

        Target.removePed(pedEntities, pedTargetId)
    end
end

local function configureZone(action, data)
    for functionName in pairs(zone) do
        zone[functionName](action, data)
    end
end

local function onGarageZoneEnter(data)
    if garageZones[data.garageKey].inRange then return end

    garageZones[data.garageKey].inRange = true

    if Config.Debug then print("entered garage zone ", data.garageKey) end

    configureZone("enter", data)
    collectgarbage("collect")
end

local function onGarageZoneExit(data)
    if not garageZones[data.garageKey].inRange then return end

    garageZones[data.garageKey].inRange = false

    if Config.Debug then print("exited garage zone ", data.garageKey) end

    configureZone("exit", data)
    collectgarbage("collect")
end

local function setupGarage(garageKey)
    local garageData = Config.Garages[garageKey]
    local polyZone = lib.zones.poly({
        points = garageData.Points,
        thickness = garageData.Thickness or 4,
        debug = Config.Debug,
        onEnter = onGarageZoneEnter,
        onExit = onGarageZoneExit,
        garageKey = garageKey
    })
    garageZones[garageKey] = { polyZone = polyZone, inRange = false, pedEntities = nil, vehicleTargetId = nil }

    -- createBlip(garageData)
end

local function onImpoundZoneEnter(data)
    if impoundZones[data.impoundKey].inRange then return end

    impoundZones[data.impoundKey].inRange = true

    if Config.Debug then print("entered impound zone ", data.impoundKey) end

    configureZone("enter", data)
    collectgarbage("collect")
end

local function onImpoundZoneExit(data)
    if not impoundZones[data.impoundKey].inRange then return end

    impoundZones[data.impoundKey].inRange = false

    if Config.Debug then print("exited impound zone ", data.impoundKey) end

    configureZone("exit", data)
    collectgarbage("collect")
end

local function setupImpound(impoundKey)
    local impoundData = Config.Impounds[impoundKey]
    local polyZone = lib.zones.poly({
        points = impoundData.Points,
        thickness = impoundData.Thickness or 4,
        debug = Config.Debug,
        onEnter = onImpoundZoneEnter,
        onExit = onImpoundZoneExit,
        impoundKey = impoundKey
    })
    impoundZones[impoundKey] = { polyZone = polyZone, inRange = false, pedEntities = nil }

    -- createBlip(impoundData)
end

-- initializing
SetTimeout(1000, function()
    for key in pairs(Config.Garages) do
        setupGarage(key)
    end

    for key in pairs(Config.Impounds) do
        setupImpound(key)
    end
end)

---@param garageKey string
---@return boolean
function IsPlayerInGarageZone(garageKey)
    garageKey = tostring(garageKey) --[[@as string]]

    if not garageKey or not garageZones[garageKey] then return false end

    return garageZones[garageKey].polyZone:contains(cache.coords)
end

---@param coords vector3
---@param garageKey string
---@return boolean
function IsCoordsInGarageZone(coords, garageKey)
    coords = vector3(coords.x, coords.y, coords.z)
    garageKey = tostring(garageKey) --[[@as string]]

    if not coords or not garageKey or not garageZones[garageKey] then return false end

    return garageZones[garageKey].polyZone:contains(coords)
end

---@param impoundKey string
---@return boolean
function IsPlayerInImpoundZone(impoundKey)
    impoundKey = tostring(impoundKey) --[[@as string]]

    if not impoundKey or not impoundZones[impoundKey] then return false end

    return impoundZones[impoundKey].polyZone:contains(cache.coords)
end