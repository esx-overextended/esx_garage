local zone, garageZones, hasInitialized = {}, {}, false

function zone.configureRadialMenu(action, data)
    if not data.RadialMenu and not Config.RadialMenu then return end

    if action == "enter" then
        RadialMenu.addItem(data.garageKey)
    elseif action == "exit" then
        RadialMenu.removeItem()
    end
end

function zone.configureVehicle(action, data)
    if action == "enter" then
        garageZones[data.garageKey].vehicleTargetId = Target.addVehicle(data.garageKey)
    elseif action == "exit" then
        local vehicleTargetId = garageZones[data.garageKey].vehicleTargetId
        garageZones[data.garageKey].vehicleTargetId = nil

        Target.removeVehicle(vehicleTargetId)
    end
end

function zone.configurePed(action, data)
    local garageData = Config.Garages[data.garageKey]

    if action == "enter" then
        for i = 1, #garageData.Peds do
            local ped = garageData.Peds[i]
            local pedModel = ped.Model or Config.DefaultPed --[[@as number | string]]
            pedModel = type(pedModel) == "string" and joaat(pedModel) or pedModel --[[@as number]]

            lib.requestModel(pedModel)

            local pedEntity = CreatePed(0, pedModel, ped.Coords.x, ped.Coords.y, ped.Coords.z, ped.Coords.w, false, true)

            SetPedFleeAttributes(pedEntity, 2, true) -- TODO: test for true or false...
            SetBlockingOfNonTemporaryEvents(pedEntity, true)
            SetPedCanRagdollFromPlayerImpact(pedEntity, false)
            SetPedDiesWhenInjured(pedEntity, false)
            FreezeEntityPosition(pedEntity, true)
            SetEntityInvincible(pedEntity, true)
            SetPedCanPlayAmbientAnims(pedEntity, false)

            if not garageZones[data.garageKey].pedEntities then garageZones[data.garageKey].pedEntities = {} end

            garageZones[data.garageKey].pedEntities[#garageZones[data.garageKey].pedEntities + 1] = pedEntity
        end

        garageZones[data.garageKey].pedTargetId = Target.addPed(garageZones[data.garageKey].pedEntities, data.garageKey)
    elseif action == "exit" then
        local pedEntities = garageZones[data.garageKey].pedEntities
        garageZones[data.garageKey].pedEntities = nil

        for i = 1, #pedEntities do
            DeletePed(pedEntities[i])
        end

        local pedTargetId = garageZones[data.garageKey].pedTargetId
        garageZones[data.garageKey].pedTargetId = nil

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
    garageZones[garageKey] = { polyZone = polyZone, inRange = false, pedEntities = nil }

    -- createBlip(garageData)
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
