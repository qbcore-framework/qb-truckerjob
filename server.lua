local QBCore = exports['qb-core']:GetCoreObject()
local jobs = setmetatable({}, {__len = function(t)
    local length = 0
    for k, v in pairs(t) do
        length += 1
    end
    return length
end})

local skillDistances = { -- Maybe move to config?
    [1] = 1500,
    [2] = 3000, -- Lvl 2 0-3000
    [3] = 5000,
    [4] = 7000,
}
local skillTimeMultipliers = {
    [1] = 1,
    [2] = 1.2,
    [3] = 1.4,
    [4] = 1.6,
}

local function generateJob()
    local deliveryCoords = Config.Coords.Deliveries[math.random(1, #Config.Coords.Deliveries)] -- Generates random delivery coordinates
    local skillLevel = math.random(1, #Config.DeliveryTypes)
    local jobLevel = Config.DeliveryTypes[skillLevel] -- Selects a random delivery skill level
    local jobInformation = jobLevel[math.random(1, #jobLevel)] -- Generates a random job from the level

    local job = {
        coords = deliveryCoords,
        distance = math.floor(#(deliveryCoords - Config.Coords.JobStation)),
        cargo = {
            label = jobInformation.jobLabels[math.random(1, #jobInformation.jobLabels)],
            trailer = jobInformation.trailer,
        },
        image = jobInformation.image,
        cargoLevel = skillLevel, -- Maybe seperate and allow for random actual fragile cargo to go with multiplier?
    }

    -- Determine which level of distance the job is
    -- Used in the front end to determine if eligible rather than calculating boundaries
    job.distanceLevel = 1
    for k, v in pairs(skillDistances) do
        if k == #skillDistances then
            if job.distance > skillDistances[k] then
                job.distanceLevel = k
                break
            end
        end
    
        if job.distance > v and job.distance <= (skillDistances[k + 1] or skillDistances[k]) then
            job.distanceLevel = k + 1
            break
        end
    end

    if math.random(1, 100) <= Config.TimedChanceGenerator then
        job.timeLevel = math.random(2, 4) -- Randomly generate a timed job for a random skill level
    end

    jobs[QBCore.Shared.RandomStr(3)..QBCore.Shared.RandomInt(3)] = job
end

CreateThread(function()
    for i = 1, 50 do -- Initialise jobs
        generateJob()
    end

    while true do
        if #jobs <= Config.MaxJobs then generateJob() end
        Wait(Config.JobGenerationTimer * 1000 * 60)
    end
end)

QBCore.Functions.CreateCallback('qb-truckerjob:server:getJobs', function(source, cb)
    return cb(jobs)
end)

QBCore.Functions.CreateCallback('qb-truckerjob:server:acceptJob', function(source, cb, jobId)
    local Player = QBCore.Functions.GetPlayer(source)
    local rep = GetRep(source)
    local truckerRep = rep.trucker

    local job = jobs[jobId]

    if not job then return TriggerClientEvent('QBCore:Notify', source, 'This job is not available', 'error') end

    if job.distanceLevel > truckerRep.skills.distance then return TriggerClientEvent('QBCore:Notify', source, 'This job is too far', 'error') end 

    if job.cargoLevel and job.cargoLevel > truckerRep.skills.cargo then return TriggerClientEvent('QBCore:Notify', source, 'This job has fragile and important cargo', 'error') end

    if job.timeLevel and job.timeLevel > truckerRep.skills.time then return TriggerClientEvent('QBCore:Notify', source, 'This job requires a quick delivery skill', 'error') end

    if job.active then return TriggerClientEvent('QBCore:Notify', source, 'This job is already active', 'error') end

    for k, v in pairs(jobs) do
        if v.active == source then
            return TriggerClientEvent('QBCore:Notify', source, 'You already have an active job', 'error')
        end
    end

    job.active = source
    job.time = GetGameTimer() + (300000 + (math.floor(job.distance) / 1000 * 60000)) -- add 5 minutes + 1 minute per km

    if job.timeLevel then
        job.time -= 45000 * job.timeLevel -- remove 45 seconds per timed delivery skill level
    end

    cb(jobs[jobId].active, jobs[jobId])
end)

QBCore.Functions.CreateCallback('qb-truckerjob:server:createVehicle', function(source, cb, spawnType, jobId, spawnId)
    local truckerRep = GetRep(source).trucker
    local vehicle = spawnType == 'truck' and truckerRep.activeTruck or jobs[jobId].cargo.trailer
    local vehType = QBCore.Shared.Vehicles[vehicle] and QBCore.Shared.Vehicles[vehicle].type or 'automobile'
    local veh = CreateVehicleServerSetter(joaat(vehicle), vehType, spawnType == 'truck' and Config.Coords.TruckSpawns[spawnId] or Config.Coords.TrailerSpawns[spawnId])
    local netId = NetworkGetNetworkIdFromEntity(veh)
    cb(netId)
end)

QBCore.Functions.CreateCallback('qb-truckerjob:server:completeJob', function(source, cb, jobId, success, trailer)
    local Player = QBCore.Functions.GetPlayer(source)
    local job = jobs[jobId]

    if job.active ~= source then
        TriggerClientEvent('QBCore:Notify', source, 'This job is not active', 'error')

        return cb(false)
    end

    if not success then
        TriggerClientEvent('QBCore:Notify', source, 'You have failed the job. Take your truck back to the depot.', 'error')
        job.active = false
        jobs[jobId] = nil

        return cb(false)
    end

    if not trailer then return cb(false) end

    -- Check trailer to ensure it's in the dropoff zone
    local trailer = NetworkGetEntityFromNetworkId(trailer)
    if not CheckTrailer(vector3(job.coords.x, job.coords.y, job.coords.z), job.coords.w, trailer, source) then return cb(false) end

    local late = false
    local damaged = false
    local payout = math.floor(job.distance * Config.PayPerMeter)

    if GetGameTimer() > job.time then
        payout -= math.floor(payout / Config.LateDeliveryPenalty)
        late = true
        TriggerClientEvent('QBCore:Notify', source, 'You delivered the cargo late, some pay has been deducted', 'error') -- Locale
    end

    local damage = GetEntityHealth(trailer)
    if damage / 10 <= Config.DamagePenaltyThreshold then
        payout -= math.floor(payout / Config.DamagePenalty)
        damaged = true
        TriggerClientEvent('QBCore:Notify', source, 'You damaged your trailer, some pay has been deducted', 'error') -- Locale
    end

    -- Could compact those reasons into one notify

    Player.Functions.AddMoney('cash', payout, 'trucker-completed-job')
    TriggerClientEvent('QBCore:Notify', source, string.format('You have been paid $%s. Take your truck back to the depot', payout), 'success')

    local rep = GetRep(source)
    local truckerRep = rep.trucker

    local xpReward = Config.XPReward

    -- Checks if job is skilled, and if not damaged/late for XP reward
    if job.cargoLevel > 1 and (not late and not damaged) then
        xpReward = xpReward * Config.Multipliers.FragileXPMultiplier
    end

    -- Checks if job is timed, and if not damaged/late for XP reward
    if job.timeLevel and (not late and not damaged) then
        xpReward = xpReward * Config.Multipliers.TimedXPMultiplier
    end

    -- If XP crosses thousandth add skill point
    if xpReward >= 1000 - ((truckerRep.XP) % 1000) then
        truckerRep.skillPoints += 1
        TriggerClientEvent('QBCore:Notify', source, 'You gained a skill point', 'success')
    end

    truckerRep.XP += xpReward
    Player.Functions.SetMetaData('rep', rep)

    print(json.encode(QBCore.Functions.GetPlayer(source).PlayerData.metadata.rep, {indent = true}))

    jobs[jobId] = nil
    cb(true)
end)

QBCore.Functions.CreateCallback('qb-truckerjob:server:upgradeSkill', function(source, cb, skill)
    local Player = QBCore.Functions.GetPlayer(source)
    local rep = GetRep(source)
    local truckerRep = rep.trucker

    print(truckerRep.skillPoints)

    if truckerRep.skillPoints < 1 then return cb(false) end

    if not truckerRep.skills[skill] or truckerRep.skills[skill] >= 4 then return cb(false) end

    truckerRep.skills[skill] += 1
    truckerRep.skillPoints = truckerRep.skillPoints - 1

    Player.Functions.SetMetaData('rep', rep)

    cb(true)
end)

QBCore.Functions.CreateCallback('qb-truckerjob:server:purchaseTruck', function(source, cb, spawnName)
    local truck = nil

    -- Check truck exists, get price
    for k, v in pairs(Config.Trucks) do
        if v.name == spawnName then
            truck = v
            break
        end
    end

    if not truck then return cb(false) end

    local Player = QBCore.Functions.GetPlayer(source)
    local rep = GetRep(source)

    if rep.trucker.trucks[truck.name] then return cb(false) end

    if not Player.Functions.RemoveMoney('bank', truck.price, 'trucker-purchase-truck') then return cb(false) end

    -- Should abstract rep out into shared function for standardised rep data (Done)
    print(json.encode(rep, {indent = true}))
    rep.trucker.trucks[truck.name] = true
    print(json.encode(rep, {indent = true}))
    
    Player.Functions.SetMetaData('rep', rep)
    TriggerClientEvent('QBCore:Notify', source, string.format('You purchased a truck for $%s', truck.price), 'success') -- Locale?
    cb(true)
end)

QBCore.Functions.CreateCallback('qb-truckerjob:server:useTruck', function(source, cb, spawnName)
    local truck = nil

    -- Check truck is valid
    for k, v in pairs(Config.Trucks) do
        if v.name == spawnName then
            truck = v
            break
        end
    end

    if not truck then return cb(false) end

    local Player = QBCore.Functions.GetPlayer(source)
    local rep = GetRep(source)
    -- if not owned, if not free, if not default truck
    if not rep.trucker.trucks[truck.name] and truck.price ~= 0 and truck.name ~= Config.DefaultTruck then return cb(false) end -- Check if owned

    rep.trucker.activeTruck = truck.name

    Player.Functions.SetMetaData('rep', rep)
    cb(true)
end)