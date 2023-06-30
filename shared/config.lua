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
    ["mrpd_car"] = {
        Label = "MRPD Garage",
        Type = "car",
        RadialMenu = nil, -- Can override Config.RadialMenu for this specific garage
        Groups = { "police" },
        Peds = {
            { Model = `S_M_Y_Cop_01`, Coords = vector4(441.214, -1013.074, 27.612, 186.823) }
        },
        Thickness = 6,
        Points = {
            vector3(410.654, -1033.008, 28.2),
            vector3(410.673, -1017.740, 28.2),
            vector3(427.415, -1017.518, 28.2),
            vector3(427.683, -1011.576, 28.2),
            vector3(429.052, -1011.428, 28.2),
            vector3(428.639, -994.029, 28.2),
            vector3(455.265, -993.977, 28.2),
            vector3(454.976, -1011.248, 28.2),
            vector3(456.283, -1011.470, 28.2),
            vector3(456.348, -1006.206, 28.2),
            vector3(459.030, -1006.944, 28.2),
            vector3(459.325, -1012.908, 28.2),
            vector3(466.138, -1012.951, 28.2),
            vector3(466.132, -1021.347, 28.2),
            vector3(459.030, -1021.654, 28.2),
            vector3(467.137, -1022.700, 28.2),
            vector3(467.229, -1020.639, 28.2),
            vector3(471.741, -1020.451, 28.2),
            vector3(471.742, -1017.718, 28.2),
            vector3(488.454, -1017.525, 28.2),
            vector3(488.173, -1025.240, 28.2),
            vector3(467.408, -1027.735, 28.2),
            vector3(467.329, -1026.067, 28.2),
        },
        Spawns = {
            vector4(427.378, -1027.928, 28.577, 5.853),
            vector4(431.201, -1027.353, 28.509, 5.82),
            vector4(434.924, -1026.973, 28.442, 4.693),
            vector4(438.628, -1026.483, 28.372, 5.391),
            vector4(442.508, -1025.965, 28.297, 5.215),
            vector4(446.111, -1025.423, 28.225, 6.965),
        }
    },
}
