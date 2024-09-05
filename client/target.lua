CreateThread(function()
    exports['qb-target']:AddCircleZone('trucker_jobMenu', Config.Coords.JobStation, 0.5, {
        name = 'trucker_jobMenu',
        debugPoly = true,
        useZ = true,
    }, {
        options = {
            {
                type = 'client',
                event = 'qb-truckerjob:client:openMenu',
                icon = 'fas fa-truck',
                label = 'Trucking Jobs Menu', -- Locale
                --canInteract = function() return QBCore.Functions.GetPlayerData().job.name == 'trucker' end,
            }
        },
        distance = 2.5,
    })
end)