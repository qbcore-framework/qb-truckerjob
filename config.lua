local QBCore = exports['qb-core']:GetCoreObject()
function CheckTrailer(coords, heading, trailer, source)
    local trailerHeading = GetEntityHeading(trailer)
    local ped = IsDuplicityVersion() and GetPlayerPed(source) or PlayerPedId()

    local headingDiff = trailerHeading - heading -- Get difference between trailer heading and delivery heading
    if headingDiff < -180 then
        headingDiff = headingDiff + 360
    elseif headingDiff > 180 then
        headingDiff = headingDiff - 360
    end
    headingDiff = math.abs(headingDiff) -- Get absolute value for when difference is below 0

    local coordDiff = #(GetEntityCoords(trailer) - GetEntityCoords(ped)) -- Used to calculate near half of trailer size due to coordinates being at the centre of the trailer
    local trailerDiff = #(GetEntityCoords(trailer) - coords)
    local pedDiff = #(GetEntityCoords(ped) - coords)

    if pedDiff <= coordDiff and trailerDiff <= 5 and headingDiff <= 10 then
        return true
    end
end

-- Initialises and formats rep data
function GetRep(source)
    local PlayerData = IsDuplicityVersion() and QBCore.Functions.GetPlayer(source).PlayerData or QBCore.Functions.GetPlayerData()
    local rep = PlayerData.metadata.rep
    local truckerRep = rep.trucker or {}
    truckerRep.skills = truckerRep.skills or {
        distance = 1,
        cargo = 1,
        time = 1,
    }
    truckerRep.activeTruck = truckerRep.activeTruck or Config.DefaultTruck
    truckerRep.trucks = truckerRep.trucks or {}
    truckerRep.skillPoints = truckerRep.skillPoints or 0
    truckerRep.XP = truckerRep.XP or 0
    rep.trucker = truckerRep

    return rep
end

Config = {
    FuelResource = 'LegacyFuel',

    JobGenerationTimer = 0.5, -- How often a job is generated in minutes
    MaxJobs = 50,

    FragileChanceGenerator = 10,
    TimedChanceGenerator = 15, -- The chance for a time-based job to be generated (15%)

    XPReward = 75, -- XP reward for completing a job

    Multipliers = {
        FragileXPMultiplier = 1.5, --XP Myultiplier for fragile jobs
        TimedXPMultiplier = 1.5, -- XP Multiplier for timed jobs  (Maybe rename to quick job)
    },

    PayPerMeter = 1.7,

    LateDeliveryPenalty = 10, -- 10% Penalty for late delivery
    DamagePenaltyThreshold = 30, -- Trailer is at 30% health, player will receive a penalty
    DamagePenalty = 10, -- 10% Penalty for damaging the cargo

    DefaultTruck = 'hauler', -- Default truck for players to use
    Trucks = {
        {name = 'hauler', price = 0 }, -- Default truck, maybe make default boolean value
        {name = 'phantom', price = 25000 },
        {name = 'packer', price = 50000 },
        {name = 'phantom3', price = 100000 }, -- Bigger and accelerates quicker
    },

    DeliveryTypes = { -- Potentially rename to cargo     
        [1] = { -- Skill Level
            {
                trailer = 'trailers',
                jobLabels = {'Furniture', 'Laptops', 'Computer Processors', 'Hoodies', 'T-Shirts', 'Speakers', 'Cameras', 'Headphones', 'Phones', 'Tires'}, -- Convert to locales?
                image = 'trailers.webp',
            },
            {
                trailer = 'docktrailer',
                jobLabels = {'Furniture', 'Laptops', 'Computer Processors', 'Hoodies', 'T-Shirts', 'Speakers', 'Cameras', 'Headphones', 'Phones', 'Tires'},
                image = 'docktrailer.webp',
            },
            {
                trailer = 'trailers4',
                jobLabels = {'Furniture', 'Laptops', 'Computer Processors', 'Hoodies', 'T-Shirts', 'Speakers', 'Cameras', 'Headphones', 'Phones', 'Tires'},
                image = 'trailers4.webp',
            },
        },
        [2] = {
            {
                trailer = 'trailers3',
                jobLabels = {'Home Lighting', 'Chairs', 'Couches', 'Soil'},
                image = 'trailers3.webp',
            },
            {
                trailer = 'trailerlogs',
                jobLabels = {'Wood Logs'},
                image = 'trailerlogs.webp',
            },
            {
                trailer = 'trailers2',
                jobLabels = {'Fries', 'Chicken Pallets', 'Condiments', 'Beef Pallets', 'Beer Bottles'},
                image = 'trailers2.webp',
            },
        },
        [3] = {
            {
                trailer = 'tr2',
                jobLabels = {'Empty Vehicle Trailer'},
                image = 'tr2.webp',
            },
            {
                trailer = 'trflat',
                jobLabels = {'Empty Flatbed Trailer'},
                image = 'trflat.webp',
            },
            {
                trailer = 'tvtrailer',
                jobLabels = {'Camera Equipment', 'Lighting Equipment', 'Props', 'Speakers', 'Musical Instruments', 'Outfits', 'Stage Equipment'},
                image = 'tvtrailer.webp',
            },
            {
                trailer = 'tanker2',
                jobLabels = {'Corrosive Substances', 'Toxic Chemicals'},
                image = 'tanker2.webp',
            }
        },
        [4] = {
            {
                trailer = 'tanker',
                jobLabels = {'Fuel Tanker'},
                image = 'tanker.webp',
            },
            {
                trailer = 'tr3',
                jobLabels = {'Yacht'},
                image = 'tr3.webp',
            },
            {
                trailer = 'tr4',
                jobLabels = {'Full Vehicle Trailer'},
                image = 'tr4.webp',
            },
            {
                trailer = 'trailerlarge',
                jobLabels = {'Medicine', 'Laboratory Supplies', 'Medical Equipment'},
                image = 'trailerlarge.webp',
            }
        }
    },
}

Config.Coords = {
    JobStation = vector4(153.86, -3211.76, 5.95, 274.5),
    TrailerLocator = vector3(858.59, -3202.2, 6.08),

    TruckSpawns = {
        vector4(144.22, -3209.09, 5.85, 269.69),
        vector4(134.34, -3209.41, 6.04, 272.36),
        vector4(126.03, -3184.12, 6.22, 269.85),
        vector4(143.61, -3183.96, 6.47, 270.74),
    },

    TruckReturn = vector3(187.07, -3219.34, 5.86),

    TrailerSpawns = {
        vector4(892.6301025390625, -3154.96736328125, 7.90080881118774, 180.57),
        vector4(896.5723266601562, -3154.268359375, 7.90080738067626, 180.57),
        vector4(900.6295166015625, -3154.331787109375, 7.90080690383911, 180.57),
        vector4(904.72509765625, -3154.280224609375, 7.90080547332763, 180.57),
        vector4(908.696044921875, -3154.21123046875, 7.90080547332763, 180.57),
        vector4(912.6459350585938, -3154.29296875, 7.90080547332763, 180.57),
        vector4(916.761474609375, -3154.233203125, 7.900803565979, 180.57),
        vector4(920.7520141601562, -3154.284375, 7.90080833435058, 180.57),
        vector4(924.9879150390625, -3154.20830078125, 7.90080785751342, 180.57),
        vector4(928.938232421875, -3154.12158203125, 7.90080785751342, 180.57),
        vector4(933.2094116210938, -3154.36865234375, 7.90080785751342, 180.57),
        vector4(937.1226196289062, -3154.04990234375, 7.900803565979, 180.57),
        vector4(941.1094360351562, -3154.06787109375, 7.900803565979, 180.57),
        vector4(945.2094116210938, -3154.36865234375, 7.900803565979, 180.57),
        vector4(949.399658203125, -3154.07294921875, 7.90074968338012, 180.57),
        vector4(953.2979736328125, -3154.225341796875, 7.90080213546752, 180.57),
        vector4(957.470458984375, -3154.0556640625, 7.90079879760742, 180.57),
        vector4(961.26611328125, -3154.060693359375, 7.90079927444458, 180.57),
        vector4(965.5117797851562, -3154.197021484375, 7.90079927444458, 180.57),
        vector4(969.551025390625, -3154.27099609375, 7.90079927444458, 180.57),
    },
    -- Move to locations file?
    Deliveries = {
        vector4(-758.14, 5540.96, 33.49, 110.53),
        vector4(-3046.19, 143.27, 11.6, 11.14),
        vector4(-1153.01, 2672.99, 18.1, 312.25),
        vector4(622.67, 110.27, 92.59, 340.75),
        vector4(-574.62, -1147.27, 22.18, 177.7),
        vector4(376.31, 2638.97, 44.5, 286.38),
        vector4(1738.32, 3283.89, 41.13, 16.24),
        vector4(1419.98, 3618.63, 34.91, 195.33),
        vector4(1452.67, 6552.02, 14.89, 138.69),
        vector4(3472.4, 3681.97, 33.79, 76.44),
        vector4(2485.73, 4116.13, 38.07, 66.71),
        vector4(65.02, 6345.89, 31.22, 206.64),
        vector4(-303.28, 6118.17, 31.5, 135.24),
        vector4(-63.41, -2015.25, 18.02, 299.48),
        vector4(-46.35, -2112.38, 16.71, 290.84),
        vector4(-746.6, -1496.67, 5.01, 28.08),
        vector4(369.54, 272.07, 103.11, 247.94),
        vector4(907.61, -44.12, 78.77, 323.08),
        vector4(-1517.31, -428.29, 35.45, 55.77),
        vector4(235.04, -1520.18, 29.15, 316.76),
        vector4(34.8, -1730.13, 29.31, 226.06),
        vector4(350.4, -2466.9, 6.4, 169.38),
        vector4(1213.97, -1229.01, 35.35, 270.74),
        vector4(1395.7, -2061.38, 52.0, 135.81),
        vector4(729.09, -2023.63, 29.31, 268.75),
        vector4(840.72, -1952.59, 28.85, 81.46),
        vector4(551.76, -1840.26, 25.34, 40.72),
        vector4(723.78, -1372.08, 26.29, 106.65),
        vector4(-339.92, -1284.25, 31.32, 89.06),
        vector4(1137.23, -1285.05, 34.6, 189.65),
        vector4(466.93, -1231.55, 29.95, 267.14),
        vector4(442.28, -584.28, 28.5, 252.12),
        vector4(1560.52, 888.69, 77.46, 19.02),
        vector4(2561.78, 426.67, 108.46, 301.57),
        vector4(569.21, 2730.83, 42.07, 91.35),
        vector4(2665.4, 1700.63, 24.49, 269.33),
        vector4(1120.1, 2652.5, 38.0, 181.77),
        vector4(2004.23, 3071.87, 47.06, 237.58),
        vector4(2038.78, 3175.7, 45.09, 140.47),
        vector4(1635.54, 3562.84, 35.23, 296.61),
        vector4(2744.55, 3412.43, 56.57, 247.48),
        vector4(1972.17, 3839.16, 32.0, 304.36),
        vector4(1980.59, 3754.65, 32.18, 211.64),
        vector4(1716.0, 4706.41, 42.69, 91.44),
        vector4(1691.36, 4918.42, 42.08, 57.29),
        vector4(1970.3, 5177.39, 47.83, 318.89),
        vector4(1908.78, 4932.06, 48.97, 340.08),
        vector4(140.79, -1077.85, 29.2, 262.4),
        vector4(-323.98, -1522.86, 27.55, 258.59),
        vector4(-1060.53, -221.7, 37.84, 299.01),
        vector4(2471.47, 4463.07, 35.3, 277.56),
        vector4(2699.47, 3444.81, 55.8, 153.49),
        vector4(2651.19, 3252.42, 54.93, 232.7),
        vector4(2730.39, 2778.2, 36.01, 134.51),
        vector4(-2966.68, 363.37, 14.77, 359.8),
        vector4(2788.89, 2816.49, 41.72, 296.22),
        vector4(-604.45, -1212.24, 14.95, 227.43),
        vector4(2534.83, 2589.08, 37.95, 2.48),
        vector4(-143.31, 205.88, 92.12, 86.41),
        vector4(2381.84, 2594.34, 46.66, 192.86),
        vector4(860.47, -896.87, 25.53, 181.8),
        vector4(973.34, -1038.19, 40.84, 272.3),
        vector4(-409.04, 1200.44, 325.65, 164.59),
        vector4(-1664.81, 3076.59, 31.23, 229.86),
        vector4(-71.8, -1089.98, 26.56, 339.06),
        vector4(1246.34, 1860.78, 79.47, 315.78),
        vector4(-1777.63, 3082.36, 32.81, 236.17),
        vector4(-1775.87, 3088.13, 32.81, 239.97),
        vector4(-1827.5, 2934.11, 32.82, 59.53),
        vector4(-2123.69, 3270.14, 32.82, 145.14),
        vector4(-2444.59, 2981.63, 32.82, 283.55),
        vector4(-2448.59, 2962.8, 32.82, 333.19),
        vector4(-2277.86, 3176.57, 32.81, 236.61),
        vector4(-2969.0, 366.46, 14.77, 292.99),
        vector4(-1637.61, -814.53, 10.17, 139.15),
        vector4(-1494.72, -891.67, 10.11, 73.06),
        vector4(-902.27, -1528.42, 5.03, 106.23),
        vector4(-1173.93, -1749.87, 3.97, 211.53),
        vector4(-1087.8, -2047.55, 13.23, 314.93),
        vector4(-1108.63, -2026.09, 13.24, 308.01),
        vector4(-1828.58, -2823.35, 13.95, 155.0),
        vector4(-1025.97, -2223.62, 8.99, 224.96),
        vector4(850.42, 2197.69, 51.93, 243.19),
        vector4(42.61, 2803.45, 57.88, 145.49),
        vector4(-1193.54, -2155.4, 13.2, 138.82),
        vector4(-1184.37, -2185.67, 13.2, 336.13),
        vector4(2041.76, 3172.26, 44.98, 155.2),
        vector4(-477.44, -2166.87, 9.59, 121.48),
        vector4(-3189.8, 1078.75, 20.85, 154.85),
        vector4(-433.69, -2277.29, 7.61, 268.97),
        vector4(-395.18, -2182.97, 10.29, 94.54),
        vector4(-3029.7, 591.68, 7.79, 199.33),
        vector4(-1007.29, -3021.72, 13.95, 65.31),
        vector4(-61.32, -1832.75, 26.8, 227.87),
        vector4(822.72, -2134.28, 29.29, 349.36),
        vector4(942.22, -2487.76, 28.34, 89.41),
        vector4(279.31, -2078.18, 16.83, 28.94),
        vector4(783.08, -2523.98, 20.51, 5.67),
        vector4(720.61, -2128.76, 29.22, 87.12),
        vector4(787.05, -1612.38, 31.17, 48.33),
        vector4(913.52, -1556.87, 30.74, 272.14),
        vector4(785.52, -2529.75, 21.15, 96.09),
        vector4(843.82, -2474.47, 25.3, 87.54),
        vector4(711.79, -1395.19, 26.35, 103.31),
        vector4(723.38, -1286.3, 26.3, 90.13),
        vector4(986.73, -1225.64, 25.38, 305.27),
        vector4(818.01, -2422.85, 23.6, 174.28),
        vector4(885.53, -1166.38, 24.99, 94.77),
        vector4(700.85, -1106.93, 22.47, 163.11),
        vector4(882.26, -2384.1, 28.0, 179.16),
        vector4(1003.55, -1860.27, 30.89, 268.33),
        vector4(-1138.73, -759.77, 18.87, 234.36),
        vector4(938.71, -1154.36, 25.38, 178.46),
        vector4(973.0, -1156.18, 25.43, 267.36),
        vector4(689.41, -963.48, 23.49, 178.61),
        vector4(140.72, -375.29, 43.26, 336.19),
        vector4(-497.09, -62.13, 39.96, 353.27),
        vector4(-606.34, 187.43, 70.01, 270.65),
        vector4(117.12, -356.15, 42.59, 252.09),
        vector4(53.91, -1571.07, 29.47, 137.1),
        vector4(1528.1, 1719.32, 109.97, 34.6),
        vector4(1411.29, 1060.33, 114.34, 269.14),
        vector4(1145.76, -287.73, 68.96, 284.29),
        vector4(-441.96, -1704.7, 18.89, 250.12),
        vector4(874.28, -949.16, 26.29, 358.46),
        vector4(829.28, -874.08, 25.26, 270.18),
        vector4(725.37, -874.53, 24.67, 265.96),
        vector4(693.66, -1090.43, 22.45, 174.62),
        vector4(1210.33, -1076.89, 39.96, 304.44),
        vector4(945.1, -1163.54, 25.68, 270.98),
        vector4(911.7, -1258.04, 25.58, 33.69),
        vector4(847.06, -1397.72, 26.14, 151.79),
        vector4(852.32, -1393.03, 26.14, 151.28),
        vector4(130.47, -1066.12, 29.2, 160.09),
        vector4(-52.79, -1078.65, 26.93, 67.2),
        vector4(-131.74, -1097.38, 21.69, 335.25),
        vector4(-621.47, -1106.05, 22.18, 1.07),
        vector4(-668.65, -1182.07, 10.62, 208.79),
        vector4(-111.84, -956.71, 27.27, 339.83),
        vector4(-1359.83, -1144.35, 4.26, 6.03),
        vector4(-1190.55, -2057.76, 14.33, 4.39),
        vector4(-1169.18, -1768.78, 3.87, 306.82),
        vector4(-1343.38, -744.02, 22.28, 309.26),
        vector4(-1532.84, -578.16, 33.63, 304.2),
        vector4(-1461.4, -362.39, 43.89, 219.06),
        vector4(-1457.25, -384.15, 38.51, 114.12),
        vector4(-1544.42, -411.45, 41.99, 226.04),
        vector4(-1432.72, -250.32, 46.37, 130.83),
        vector4(-1040.24, -499.88, 36.07, 118.78),
        vector4(346.43, -1107.19, 29.41, 177.11),
        vector4(523.99, -2112.7, 5.99, 182.08),
        vector4(977.19, -2539.34, 28.31, 353.75),
        vector4(1132.61, -2375.44, 31.4, 259.61),
        vector4(1591.9, -1714.0, 88.16, 120.75),
        vector4(1693.41, -1497.45, 113.05, 66.92),
        vector4(1029.44, -2501.31, 28.43, 149.34),
        vector4(2492.55, -320.89, 93.0, 82.83),
        vector4(2846.31, 1463.1, 24.56, 74.93),
        vector4(3631.05, 3768.61, 28.52, 320.0),
        vector4(3572.5, 3665.53, 33.9, 75.93),
        vector4(2919.03, 4337.85, 50.31, 203.77),
        vector4(2521.47, 4203.47, 39.95, 327.93),
        vector4(2926.2, 4627.28, 48.55, 143.26),
        vector4(3808.59, 4463.22, 4.37, 87.61),
        vector4(2802.35, 4838.31, 44.99, 118.49),
        vector4(2133.06, 4789.57, 40.98, 26.62),
        vector4(1900.83, 4913.82, 48.87, 154.21),
        vector4(381.06, 3591.37, 33.3, 82.49),
        vector4(642.8, 3502.47, 34.09, 95.04),
        vector4(277.33, 2884.71, 43.61, 296.91),
        vector4(-60.3, 1961.45, 190.19, 294.86),
        vector4(225.63, 1244.33, 225.46, 194.24),
        vector4(-513.24, 5257.73, 80.62, 159.3),
        vector4(-519.96, 5243.84, 79.95, 72.76),
        vector4(-602.87, 5326.63, 70.46, 168.65),
        vector4(-797.95, 5400.61, 34.24, 86.78),
        vector4(-776.0, 5579.11, 33.49, 167.58),
        vector4(-704.2, 5772.55, 17.34, 68.44),
        vector4(-299.24, 6300.27, 31.5, 134.2),
        vector4(402.52, 6619.61, 28.26, 357.71),
        vector4(-247.72, 6205.46, 31.49, 45.5),
        vector4(-326.49, 6104.64, 31.49, 46.83),
        vector4(-64.73, 6553.21, 31.5, 41.71),
        vector4(2204.73, 5574.04, 53.74, 351.31),
        vector4(1638.98, 4840.41, 42.03, 185.92),
        vector4(1961.26, 4640.93, 40.71, 293.6),
        vector4(1776.61, 4584.67, 37.65, 181.45),
        vector4(137.29, 281.73, 109.98, 335.6),
        vector4(607.49, 165.2, 98.24, 341.06),
        vector4(212.28, 2789.95, 45.66, 276.37),
        vector4(708.58, -295.1, 59.19, 277.93),
        vector4(581.28, 2799.43, 42.1, 1.52),
        vector4(1296.73, 1424.35, 100.45, 178.89),
        vector4(955.85, -22.89, 78.77, 147.51),
    },
}