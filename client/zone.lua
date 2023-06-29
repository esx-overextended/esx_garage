local zone, garageZones, hasInitialized = {}, {}, false

function zone.configureVehicle(action, data)
    if action == "enter" then
        garageZones[data.id].vehicleTargetId = Target.addVehicle()
    elseif action == "exit" then
        local vehicleTargetId = garageZones[data.id].vehicleTargetId
        garageZones[data.id].vehicleTargetId = nil

        Target.removeVehicle(vehicleTargetId)
    end
end

function zone.configurePed(action, data)
    local garageData = Config.Garages[data.garageIndex]

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

            if not garageZones[data.id].pedEntities then garageZones[data.id].pedEntities = {} end

            garageZones[data.id].pedEntities[#garageZones[data.id].pedEntities + 1] = pedEntity
        end

        garageZones[data.id].pedTargetId = Target.addPed(garageZones[data.id].pedEntities, data.garageIndex)
    elseif action == "exit" then
        local pedEntities = garageZones[data.id].pedEntities
        garageZones[data.id].pedEntities = nil

        for i = 1, #pedEntities do
            DeletePed(pedEntities[i])
        end

        local pedTargetId = garageZones[data.id].pedTargetId
        garageZones[data.id].pedTargetId = nil

        Target.removePed(pedEntities, pedTargetId)
    end
end

local function configureZone(action, data)
    for functionName in pairs(zone) do
        zone[functionName](action, data)
    end
end

local function onGarageZoneEnter(data)
    if garageZones[data.id].inRange then return end

    garageZones[data.id].inRange = true

    if Config.Debug then print("entered garage zone ", data.id) end

    configureZone("enter", data)
    collectgarbage("collect")
end

local function onGarageZoneExit(data)
    if not garageZones[data.id].inRange then return end

    garageZones[data.id].inRange = false

    if Config.Debug then print("exited garage zone ", data.id) end

    configureZone("exit", data)
    collectgarbage("collect")
end

local function setupGarage(garageIndex)
    local garageData = Config.Garages[garageIndex]
    local polyZone = lib.zones.poly({
        points = garageData.Points,
        thickness = garageData.Thickness or 4,
        debug = Config.Debug,
        onEnter = onGarageZoneEnter,
        onExit = onGarageZoneExit,
        garageIndex = garageIndex
    })
    garageZones[polyZone.id] = { inRange = false, pedEntities = nil }
    -- createBlip(garageData)
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
