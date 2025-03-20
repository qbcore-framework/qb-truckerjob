QBCore = exports['qb-core']:GetCoreObject()
-- could compact variables, used to keep track of entities and zones throughout functions
local truckZone = nil -- Truck return zone
local exitingTruck = false
local trailerZone = nil
local dropOffZone = nil
local isInDropoffZone = nil
local currentJob = nil
local currentTruck = nil
local currentTrailer = nil
local blip = nil

-- TODO -- 
-- Implement truck return point. [Done?] Maybe more testing for edge cases
-- Maybe implement chance for skilled jobs to increase low level job amount
-- Implement locales
-- Convert jobs UI page to grid?

-- Performs shape test to check if spawn is clear
local function GetSpawnPoint(isTrailer) -- Change parameter to string for better understanding?
    local locations = isTrailer and Config.Coords.TrailerSpawns or Config.Coords.TruckSpawns
    for k, v in pairs(locations) do
        local shapeTest = StartShapeTestCapsule(
            v.x,
            v.y,
            v.z,
            v.x,
            v.y,
            v.z,
            2.2, -- Radius
            2,
            0,
            2
        )

        local _, hit = GetShapeTestResult(shapeTest)
        if hit == 0 then
            return k
        end
    end

    return nil
end

local function CloseUI()
    SetNuiFocus(false, false)
    SendNUIMessage({action = 'close'})
end

local function DeleteTruck()
    if not currentTruck then return end

    CreateThread(function()
        while exitingTruck do
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if veh == 0 then
                DeleteEntity(currentTruck)
                currentTruck = nil
                exports['qb-core']:HideText()
                truckZone:destroy()
                truckZone = nil
                exitingTruck = false
            end
            Wait(800)
        end
    end)
end

local function CompleteJob(jobId, success)
    local trailerId = currentTrailer and NetworkGetNetworkIdFromEntity(currentTrailer) or nil
    QBCore.Functions.TriggerCallback('qb-truckerjob:server:completeJob', function(complete)
        if blip then RemoveBlip(blip) end
        if currentTrailer then RemoveBlip(GetBlipFromEntity(currentTrailer)) end
        blip = nil
        currentJob = nil

        if not dropOffZone then return end
        dropOffZone:onPlayerInOut(function(isPointInside, point) -- Delete trailer once player has left the area
            if isPointInside then return end
            isInDropoffZone = nil

            DeleteEntity(currentTrailer)
            currentTrailer = nil
            dropOffZone:destroy()
            dropOffZone = nil
        end)

        -- Truck Returning
        if truckZone then return end -- Dont create another unnecessary zone
        truckZone = CircleZone:Create(Config.Coords.TruckReturn, 10.0, {
            name = 'truck_return',
            debugPoly = true,
        })
        truckZone:onPlayerInOut(function(isPointInside, point)
            if isPointInside and not exitingTruck then
                if currentTrailer then return end
                exports['qb-core']:DrawText('Exit the vehicle to return the truck')
                exitingTruck = true
                DeleteTruck()
            else
                exports['qb-core']:HideText()
                exitingTruck = false
            end
        end)
    end, jobId, success, trailerId)
end

local function DrawZone(jobId, coords)
    local heading = coords.w
    local coords = vector3(coords.x, coords.y, coords.z-1)
    local isTrailerInZone = false
    local colour = nil

    CreateThread(function()
        while isInDropoffZone do
            isTrailerInZone = CheckTrailer(coords, heading, currentTrailer)
            colour = not isTrailerInZone and {r = 255, g = 0, b  = 0} or {r = 0, g = 185, b = 0}
            DrawMarker(30, coords, 0.0, 0.0, 1.0, 0.0, heading > 180 and 360 + 180 - heading or 180 - heading, 0.0, 3.0, 3.0, 5.0, colour.r, colour.g, colour.b, 185, false, false, 2, false, nil, nil, false)

            if isTrailerInZone and not IsEntityAttached(currentTrailer) then
                CompleteJob(jobId, true)
                break
            end

            Wait(0)
        end
    end)
end

local function CreateTrailerZone(jobId, jobInfo)
    blip = AddBlipForCoord(Config.Coords.TrailerLocator)
    SetBlipColour(blip, 5)
    SetBlipRoute(blip, true)

    trailerZone = 'trucker_getTrailer_' .. jobId -- Used for target cleanup
    exports['qb-target']:AddCircleZone(trailerZone, Config.Coords.TrailerLocator, 0.5, {
        name = trailerZone,
        debugPoly = false,
        useZ = true,
    }, {
        options = {
            {
                type = 'client',
                action = function()
                    local spawnId = GetSpawnPoint(true)
                    if not spawnId then return QBCore.Functions.Notify('There are no available trailer bays', 'error') end -- Locale?

                    QBCore.Functions.TriggerCallback('qb-truckerjob:server:createVehicle', function(netId)
                        while not NetworkDoesNetworkIdExist(netId) do Wait(10) end
                        exports['qb-target']:RemoveZone(trailerZone)
                        trailerZone = nil
                        RemoveBlip(blip)

                        QBCore.Functions.Notify('Your trailer is in Bay K' .. spawnId, 'success')
                        blip = AddBlipForCoord(jobInfo.coords)
                        SetBlipColour(blip, 5)
                        SetBlipRoute(blip, true)

                        currentTrailer = NetworkGetEntityFromNetworkId(netId)
                        SetTrailerLegsLowered(currentTrailer)

                        dropOffZone = CircleZone:Create(vector3(jobInfo.coords.x, jobInfo.coords.y, jobInfo.coords.z), 75.0, {
                            name = 'dropoff_zone',
                            debugPoly = false,
                        })

                        dropOffZone:onPointInOut(function()
                            return GetEntityCoords(currentTrailer)
                        end, function(isPointInside, point)
                            isInDropoffZone = isPointInside
                            if isInDropoffZone then DrawZone(jobId, jobInfo.coords) end
                        end)

                        local trailerBlip = AddBlipForEntity(currentTrailer)
                        SetBlipSprite(trailerBlip, 479)
                    end, 'trailer', jobId, spawnId)
                end,
                icon = 'fas fa-trailer',
                label = 'Get Trailer Information', -- Locale
            }
        },
        distance = 2.5,
    })
end

local function AcceptJob(jobId, cb)
    QBCore.Functions.TriggerCallback('qb-truckerjob:server:acceptJob', function(isActive, jobInfo) -- isActive mightn't be needed
        if currentJob then return QBCore.Functions.Notify('You already have an active job', 'error') end -- Somewhat redundant because server-side checks this

        local spawnId = GetSpawnPoint(false)
        if not spawnId then return QBCore.Functions.Notify('There are no available truck bays', 'error') end

        currentJob = jobId
        CloseUI()
        
        if not currentTruck then
            QBCore.Functions.TriggerCallback('qb-truckerjob:server:createVehicle', function(netId)
                while not NetworkDoesNetworkIdExist(netId) do Wait(10) end

                currentTruck = NetworkGetEntityFromNetworkId(netId)

                exports[Config.FuelResource]:SetFuel(currentTruck, math.random(50, 70))
                SetVehicleNumberPlateText(currentTruck, 'TRK' .. jobId)
                TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', QBCore.Functions.GetPlate(currentTruck))
            end, 'truck', jobId, spawnId)
        else
            QBCore.Functions.Notify('You already have a truck in use, continue to use that', 'error')
        end

        CreateTrailerZone(jobId, jobInfo)
    end, jobId)
end

-- Target cleanup
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    exports['qb-target']:RemoveZone(trailerZone)
    exports['qb-target']:RemoveZone('trucker_jobMenu')
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if not currentJob then return end
    if name ~= 'CEventNetworkVehicleUndrivable' then return end

    local entity = args[1]
    if entity == currentTrailer then
        -- If trailer is destroyed, end job
        QBCore.Functions.Notify('Your trailer has been destroyed', 'error')
        CompleteJob(currentJob, false)
        DeleteEntity(currentTrailer)
        currentTrailer = nil
        dropOffZone:destroy() -- Should exist if currentJob isn't nil
        dropOffZone = nil
        isInDropoffZone = nil
    elseif entity == currentTruck then
        -- If truck is destroyed, reset variable
        currentTruck = nil

        if not truckZone then return end
        truckZone:destroy()
        truckZone = nil
    end
end)

RegisterNetEvent('qb-truckerjob:client:openMenu', function()
    QBCore.Functions.TriggerCallback('qb-truckerjob:server:getJobs', function(jobs)
        local rep = GetRep()
        local repData = rep.trucker

        -- Should just format the data one way for both server and client instead of this:
        repData.skills.distance = {level = repData.skills.distance, icon = 'fa-solid fa-road'}
        repData.skills.cargo = {level = repData.skills.cargo, icon = 'fa-solid fa-box'}
        repData.skills.time = {level = repData.skills.time, icon = 'fa-solid fa-clock'}
        
        local truckData = {}
        for k, v in pairs(Config.Trucks) do
            local vehicle = QBCore.Shared.Vehicles[v.name]
            if vehicle then
                truckData[k] = {
                    name = vehicle.name,
                    spawnName = v.name,
                    speed = GetVehicleModelEstimatedMaxSpeed(vehicle.hash) * 2.236936,
                    price = v.price,
                    owned = repData.trucks[v.name] or false,
                }
            else
                -- Error Handling, could assert
                print(string.format("Vehicle not found in shared: %s", k))
            end
        end

        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'open',
            data = {
                jobs = jobs,
                skillPoints = repData.skillPoints or 0,
                skills = repData.skills,
                activeJob = currentJob ~= nil,
                payPerMeter = Config.PayPerMeter,
                trucks = truckData,
                activeTruck = repData.activeTruck or Config.DefaultTruck,
            },
        })
    end)
end)

-- NUI Callbacks

RegisterNUICallback('acceptJob', function(data, cb)
    AcceptJob(data.jobId)
    cb(true)
end)

RegisterNUICallback('cancelJob', function(_, cb)
    CompleteJob(currentJob, false)
    cb(true)
end)

RegisterNUICallback('upgradeSkill', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-truckerjob:server:upgradeSkill', function(success)
        if success then
            QBCore.Functions.Notify('Skill upgraded', 'success')
        else
            QBCore.Functions.Notify('You do not have enough skill points', 'error')
        end
        cb(success)
    end, data.skill)
end)

RegisterNUICallback('purchaseTruck', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-truckerjob:server:purchaseTruck', function(success)
        if success then
            QBCore.Functions.Notify('Truck purchased', 'success')
        else
            QBCore.Functions.Notify('You do not have enough money', 'error')
        end
        cb({trucks = QBCore.Functions.GetPlayerData().metadata.rep.trucker.trucks, success = success})
    end, data.truck)
end)

RegisterNUICallback('useTruck', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-truckerjob:server:useTruck', function(success)
        if success then
            QBCore.Functions.Notify('Truck selected', 'success')
        else
            QBCore.Functions.Notify('You do not own this truck', 'error')
        end

        cb({activeTruck = QBCore.Functions.GetPlayerData().metadata.rep.trucker.activeTruck, success = success})
    end, data.truck)
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb(true)
end)