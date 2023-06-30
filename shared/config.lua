Config = {}

Config.Debug = true

Config.DefaultPed = `s_m_y_airworker`

Config.TransferPrice = 1000

Config.RestoreVehicles = true

Config.RadialMenu = true

Config.Garages = {
    ["legion"] = {
        Label = "Legion Garage",
        Type = "car",
        Groups = {},
        RadialMenu = nil, -- Can override Config.RadialMenu for this specific garage
        Peds = {
            { Model = nil, Coords = vector4(213.6, -809.6, 30.0, 340.1) },
            { Model = nil, Coords = vector4(225.4, -740.5, 33.2, 263.6) }
        },
        Thickness = 8,
        Points = {
            vector3(239.9, -820.5, 34.0),
            vector3(199.9, -805.8, 34.0),
            vector3(226.3, -732.9, 34.0),
            vector3(272.1, -748.6, 34.0),
            vector3(258.4, -787.0, 34.0),
            vector3(252.7, -784.9, 34.0)
        },
        Spawns = {
            -- Row 1
            vector4(205.809, -800.931, 30.599, 249.639),
            vector4(206.862, -798.512, 30.581, 249.514),
            vector4(207.777, -796.039, 30.560, 250.769),
            vector4(208.805, -793.563, 30.540, 247.452),
            vector4(209.772, -791.013, 30.523, 249.38),
            vector4(210.682, -788.559, 30.508, 249.795),
            vector4(211.510, -786.013, 30.497, 249.169),
            vector4(212.519, -783.519, 30.482, 249.545),
            vector4(213.403, -780.950, 30.471, 250.734),
            vector4(214.450, -778.573, 30.456, 247.855),
            vector4(215.281, -775.930, 30.449, 248.958),
            vector4(216.158, -773.473, 30.442, 250.145),
            vector4(217.133, -770.971, 30.433, 250.111),
            vector4(218.016, -768.383, 30.428, 249.411),
            vector4(218.935, -765.852, 30.424, 250.146),
        }
    },
}
