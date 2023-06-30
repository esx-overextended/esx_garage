---@param garageKey string
---@return boolean
function IsPlayerAuthorizedToAccessGarage(garageKey)
    local garageGroups = Config.Garages[garageKey].Groups

    if not garageGroups then return true end

    local garageGroupsType = type(garageGroups)

    if garageGroupsType == "string" then
        garageGroups = { garageGroups }
        garageGroupsType = "table"
    end

    local playerGroups = ESX.PlayerData.groups
    local playerJobName = ESX.PlayerData.job.name
    local playerJobDuty = ESX.PlayerData.job.duty
    local playerJobGrade = ESX.PlayerData.job.grade

    if garageGroupsType == "table" then
        if table.type(garageGroups) == "array" then
            for i = 1, #garageGroups do
                local garageGroupName = garageGroups[i]

                if garageGroupName == playerJobName and playerJobDuty then return true end

                if playerGroups[garageGroupName] and not ESX.GetJob(garageGroupName) --[[making sure the group is not a job]] then return true end
            end
        else
            for garageGroupName, garageGroupGrade in pairs(garageGroups) do
                if garageGroupName == playerJobName and garageGroupGrade == playerJobGrade and playerJobDuty then return true end

                if playerGroups[garageGroupName] == garageGroupGrade and not ESX.GetJob(garageGroupName) --[[making sure the group is not a job]] then return true end
            end
        end
    end

    return false
end

function OnPlayerData(key)
    if key ~= "job" and key ~= "groups" then return end

    for garageKey in pairs(Config.Garages) do
        if IsPlayerInGarageZone(garageKey) then
            if RadialMenu.addItem(garageKey) then return end
        end
    end

    RadialMenu.removeItem()
end
