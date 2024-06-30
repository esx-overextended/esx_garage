Config = {}

Config.Debug = true

Config.DefaultPed = `s_m_y_airworker`

Config.TransferPrice = 1000

Config.ImpoundPrice = 1000

Config.RestoreVehicles = false

Config.RadialMenu = true

Config.NotifyOnZoneInteraction = true

Config.Garages = {
    ["legion"] = {
        Label = "Legion Garage",
        Type = { "car", "bike", "bicycle" },
        RadialMenu = nil,              -- Can override Config.RadialMenu for this specific garage
        NotifyOnZoneInteraction = nil, -- Can override Config.NotifyOnZoneInteraction for this specific garage
        Blip = {
            Active = true,
            Coords = nil, -- Can set specific coords for blip, otherwise the center of the polyzone points will be picked
            Type = 357,
            Size = 0.8,
            Color = 2
        },
        Peds = {
            { Model = nil, Coords = vector4(213.6, -809.6, 30.0, 340.1) },
            { Model = nil, Coords = vector4(225.4, -740.5, 33.2, 263.6) }
        },
        Thickness = 9,
        Points = {
            vector3(239.9, -820.5, 33.0),
            vector3(199.9, -805.8, 33.0),
            vector3(226.3, -732.9, 33.0),
            vector3(272.1, -748.6, 33.0),
            vector3(258.4, -787.0, 33.0),
            vector3(252.7, -784.9, 33.0)
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
            -- Row 2
            vector4(215.206, -804.235, 30.403, 68.09),
            vector4(216.132, -801.701, 30.387, 68.875),
            vector4(217.159, -799.162, 30.372, 68.007),
            vector4(218.081, -796.656, 30.361, 68.894),
            vector4(219.081, -794.263, 30.349, 68.82),
            vector4(219.934, -791.667, 30.348, 67.984),
            vector4(220.853, -789.208, 30.355, 68.738),
            vector4(221.694, -786.673, 30.359, 69.179),
            vector4(222.665, -784.093, 30.356, 68.295),
            vector4(223.610, -781.623, 30.350, 67.585),
            vector4(224.507, -779.054, 30.350, 68.757),
            vector4(225.604, -776.588, 30.358, 68.191),
            vector4(226.551, -774.068, 30.365, 69.121),
            vector4(227.454, -771.555, 30.371, 68.737),
            vector4(228.409, -769.011, 30.375, 68.866),
            -- Row 3
            vector4(219.979, -809.236, 30.261, 248.024),
            vector4(220.985, -806.707, 30.270, 248.682),
            vector4(221.994, -804.136, 30.265, 249.616),
            vector4(222.888, -801.688, 30.252, 249.371),
            vector4(223.838, -799.144, 30.250, 248.769),
            vector4(224.744, -796.638, 30.252, 249.444),
            vector4(225.696, -794.162, 30.257, 249.798),
            vector4(226.569, -791.572, 30.262, 249.932),
            vector4(227.489, -789.074, 30.272, 250.235),
            vector4(228.343, -786.567, 30.286, 250.404),
            vector4(229.352, -784.076, 30.288, 249.494),
            vector4(230.314, -781.514, 30.290, 249.396),
            vector4(231.218, -778.950, 30.298, 249.539),
            vector4(232.194, -776.397, 30.311, 248.745),
            vector4(233.087, -773.788, 30.326, 248.839),
            vector4(234.138, -771.269, 30.345, 250.987),
            -- Row 5
            vector4(237.132, -812.778, 29.865, 68.107),
            vector4(238.030, -810.151, 29.882, 68.143),
            vector4(238.943, -807.613, 29.900, 68.624),
            vector4(239.927, -805.123, 29.921, 67.702),
            vector4(240.906, -802.586, 29.940, 68.105),
            vector4(242.115, -800.303, 29.952, 67.729),
            vector4(242.799, -797.604, 29.980, 67.151),
            vector4(243.676, -795.002, 30.011, 67.803),
            vector4(244.726, -792.523, 30.036, 68.501),
            vector4(245.656, -789.993, 30.062, 68.938),
            vector4(246.722, -787.458, 30.087, 68.57),
            vector4(247.267, -784.819, 30.121, 66.933),
            vector4(248.242, -782.256, 30.156, 68.409),
            vector4(249.081, -779.560, 30.196, 68.515),
            vector4(250.504, -777.226, 30.226, 68.435),
            vector4(251.387, -774.700, 30.264, 67.607),
            -- Level 1 (upstair)
            vector4(221.754, -750.667, 34.231, 338.745),
            vector4(224.942, -751.933, 34.225, 340.205),
            vector4(228.270, -753.074, 34.228, 339.962),
            vector4(241.562, -757.305, 34.227, 341.059),
            vector4(244.771, -758.564, 34.227, 340.125),
            vector4(248.138, -759.726, 34.230, 341.583),
            vector4(251.385, -760.901, 34.230, 340.206),
            vector4(254.561, -762.243, 34.230, 340.874),
            vector4(261.717, -766.023, 34.234, 70.547),
            vector4(263.124, -762.670, 34.233, 68.352),
            vector4(264.349, -759.238, 34.231, 69.421),
            vector4(253.459, -746.193, 34.226, 159.579),
            vector4(250.072, -744.831, 34.224, 161.153),
            vector4(246.859, -743.749, 34.218, 159.503),
            vector4(243.608, -742.496, 34.211, 160.643),
            vector4(240.301, -741.432, 34.201, 158.749),
            vector4(237.188, -740.213, 34.189, 160.723),
            vector4(233.842, -739.235, 34.163, 161.358)
        }
    },
    ["paleto"] = {
        Label = "Paleto Bay Garage",
        Type = { "car", "bike", "bicycle" },
        RadialMenu = nil,              -- Can override Config.RadialMenu for this specific garage
        NotifyOnZoneInteraction = nil, -- Can override Config.NotifyOnZoneInteraction for this specific garage
        Blip = {
            Active = true,
            Coords = nil, -- Can set specific coords for blip, otherwise the center of the polyzone points will be picked
            Type = 357,
            Size = 0.8,
            Color = 2
        },
        Peds = {
            { Model = nil, Coords = vector4(-197.432, 6204.079, 30.470, 45.354) },
            { Model = nil, Coords = vector4(-242.861, 6188.043, 30.487, 325.984) }
        },
        Thickness = 6,
        Points = {
            vector3(-178.9, 6221.7, 31.0),
            vector3(-196.1, 6238.7, 31.0),
            vector3(-234.5, 6200.3, 31.0),
            vector3(-251.8, 6217.4, 31.0),
            vector3(-262.7, 6207.1, 31.0),
            vector3(-228.6, 6172.1, 31.0)
        },
        Spawns = {
            -- Row 1
            vector4(-198.514, 6229.740, 31.082, 226.770),
            vector4(-200.901, 6227.182, 31.082, 226.770),
            vector4(-203.261, 6224.848, 31.065, 226.771),
            vector4(-205.687, 6222.566, 31.065, 226.771),
            vector4(-208.061, 6220.061, 31.065, 226.771),
            -- Row 2
            vector4(-238.378, 6196.707, 31.065, 133.228),
            vector4(-240.738, 6199.081, 31.065, 133.228),
            vector4(-243.151, 6201.560, 31.065, 133.228),
            vector4(-245.393, 6203.947, 31.065, 133.228),
            vector4(-247.832, 6206.307, 31.065, 133.228)
        }
    },
    ["pegasus_hangar"] = {
        Label = "Pegasus Hangar",
        Type = { "heli" },
        RadialMenu = nil,              -- Can override Config.RadialMenu for this specific garage
        NotifyOnZoneInteraction = nil, -- Can override Config.NotifyOnZoneInteraction for this specific garage
        Blip = {
            Active = true,
            Coords = nil, -- Can set specific coords for blip, otherwise the center of the polyzone points will be picked
            Type = 360,
            Size = 1.0,
            Color = 2
        },
        Peds = {
            { Model = `S_M_Y_DWService_01`, Coords = vector4(-708.0660, -1417.9265, 4.0005, 178.3207) },
            { Model = `S_M_Y_DWService_01`, Coords = vector4(-767.1332, -1472.6134, 4.0005, 295.4921) },
        },
        Thickness = 9,
        Points = {
            vector3(-718.6, -1374.3, 5.0),
            vector3(-793.0, -1463.0, 5.0),
            vector3(-787.0, -1479.6, 5.0),
            vector3(-767.2, -1472.6, 5.0),
            vector3(-753.9, -1512.5, 5.0),
            vector3(-727.0, -1501.1, 5.0),
            vector3(-721.1, -1493.7, 5.0),
            vector3(-709.4, -1489.3, 4.0),
            vector3(-679.7, -1453.0, 5.0),
            vector3(-676.8, -1392.6, 5.0),
            vector3(-682.8, -1387.2, 5.0),
            vector3(-699.6, -1407.1, 5.0),
            vector3(-712.7, -1396.1, 5.0),
            vector3(-704.2, -1386.3, 5.0)
        },
        Spawns = {
            vector4(-726.192, -1445.775, 4.881, 138.867),
            vector4(-746.592, -1469.947, 4.879, 141.685)
        }
    },
    ["mrpd_car"] = {
        Label = "MRPD Garage",
        Type = { "car", "bike" },
        RadialMenu = nil,              -- Can override Config.RadialMenu for this specific garage
        NotifyOnZoneInteraction = nil, -- Can override Config.NotifyOnZoneInteraction for this specific garage
        Groups = { "police" },
        Blip = {
            Active = true,
            Coords = nil, -- Can set specific coords for blip, otherwise the center of the polyzone points will be picked
            Type = 357,
            Size = 0.8,
            Color = 38
        },
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

Config.Impounds = {
    ["city_impound"] = {
        Label = "City Vehicle Impound Lot",
        Type = { "car", "bike", "bicycle" },
        NotifyOnZoneInteraction = nil, -- Can override Config.NotifyOnZoneInteraction for this specific impound
        Blip = {
            Active = true,
            Type = 357,
            Size = 0.8,
            Color = 1
        },
        Peds = {
            { Model = nil, Coords = vector4(409.022, -1622.879, 28.291, 232.386) },
        },
        Thickness = 4,
        Points = {
            vector3(409.402, -1616.627, 30.0),
            vector3(387.976, -1641.988, 30.0),
            vector3(410.544, -1661.237, 30.0),
            vector3(423.439, -1645.282, 30.0),
            vector3(424.056, -1640.452, 30.0),
            vector3(423.943, -1632.924, 30.0),
            vector3(423.212, -1628.171, 30.0),
        },
        Spawns = {
            vector4(417.190, -1627.592, 28.879, 141.321),
            vector4(419.605, -1629.507, 28.881, 142.663),
            vector4(421.022, -1635.795, 28.879, 90.529),
            vector4(421.096, -1638.895, 28.881, 89.679),
            vector4(420.992, -1642.005, 28.879, 88.776),
            vector4(418.494, -1646.497, 28.879, 48.97),
            vector4(410.576, -1656.858, 28.880, 320.644),
            vector4(408.009, -1654.771, 28.879, 319.99),
            vector4(405.635, -1652.724, 28.879, 319.605),
            vector4(403.247, -1650.694, 28.881, 319.616),
            vector4(400.883, -1648.632, 28.880, 319.01),
            vector4(398.481, -1646.473, 28.879, 318.613),
            vector4(396.039, -1644.567, 28.879, 319.265),
        }
    },
}
