Shared = {}

Shared.AvailableSpawnPointIndicator = "client" -- indicates whether the server or client should be responsible for locating closest available spawn point

exports("GetGarages", function()
    return Config.Garages
end)