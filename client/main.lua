---@param groupsToCheck? string | table
---@return boolean
function DoesPlayerHaveAccessToGroup(groupsToCheck)
    if not groupsToCheck or groupsToCheck == "" then return true end

    local groupsToCheckType = type(groupsToCheck)

    if groupsToCheckType == "string" then
        groupsToCheck = { groupsToCheck }
        groupsToCheckType = "table"
    end

    local playerGroups = ESX.PlayerData.groups
    local playerJobName = ESX.PlayerData.job.name
    local playerJobDuty = ESX.PlayerData.job.duty
    local playerJobGrade = ESX.PlayerData.job.grade

    if groupsToCheckType == "table" then
        if table.type(groupsToCheck) == "array" then
            for i = 1, #groupsToCheck do
                local groupName = groupsToCheck[i]

                if groupName == playerJobName and playerJobDuty then return true end

                if playerGroups[groupName] and not ESX.GetJob(groupName) --[[making sure the group is not a job]] then return true end
            end
        else
            for groupName, garageGroupGrade in pairs(groupsToCheck) do
                if groupName == playerJobName and garageGroupGrade == playerJobGrade and playerJobDuty then return true end

                if playerGroups[groupName] == garageGroupGrade and not ESX.GetJob(groupName) --[[making sure the group is not a job]] then return true end
            end
        end
    end

    return false
end

---@param garageKey string
---@return boolean
function IsPlayerAuthorizedToAccessGarage(garageKey)
    return DoesPlayerHaveAccessToGroup(Config.Garages[garageKey]?.Groups)
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
    if accountName == "money" then return "fa-solid fa-money-bill"
    elseif accountName == "bank" then return "fa-solid fa-building-columns" end

    return "fa-solid fa-money-check-dollar"
end