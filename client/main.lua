local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = {}
local JobsDone = 0
local LocationsDone = {}
local CurrentLocation = nil
local CurrentBlip = nil
local hasBox = false
local isWorking = false
local currentCount = 0
local CurrentPlate = nil
local selectedVeh = nil
local TruckVehBlip = nil
local Delivering = false
local showMarker = false
local markerLocation

-- Functions

local function hasDoneLocation(locationId)
    local retval = false
    if LocationsDone ~= nil and next(LocationsDone) ~= nil then
        for _, v in pairs(LocationsDone) do
            if v == locationId then
                retval = true
            end
        end
    end
    return retval
end

local function getNextClosestLocation()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = 0
    local dist = nil

    for k, _ in pairs(Config.Locations["stores"]) do
        if current ~= 0 then
            if #(pos - vector3(Config.Locations["stores"][k].coords.x, Config.Locations["stores"][k].coords.y, Config.Locations["stores"][k].coords.z)) < dist then
                if not hasDoneLocation(k) then
                    current = k
                    dist = #(pos - vector3(Config.Locations["stores"][k].coords.x, Config.Locations["stores"][k].coords.y, Config.Locations["stores"][k].coords.z))
                end
            end
        else
            if not hasDoneLocation(k) then
                current = k
                dist = #(pos - vector3(Config.Locations["stores"][k].coords.x, Config.Locations["stores"][k].coords.y, Config.Locations["stores"][k].coords.z))
            end
        end
    end

    return current
end

local function isTruckerVehicle(vehicle)
    local retval = false
    for k in pairs(Config.Vehicles) do
        if GetEntityModel(vehicle) == GetHashKey(k) then
            retval = true
        end
    end
    return retval
end

local function RemoveTruckerBlips()
    if TruckVehBlip ~= nil then
        RemoveBlip(TruckVehBlip)
	    ClearAllBlipRoutes()
        TruckVehBlip = nil
    end

    if CurrentBlip ~= nil then
        RemoveBlip(CurrentBlip)
	    ClearAllBlipRoutes()
        CurrentBlip = nil
    end
end

local function MenuGarage()
    local truckMenu = {
        {
            header = Lang:t("menu.header"),
            isMenuHeader = true
        }
    }
    for k in pairs(Config.Vehicles) do
        truckMenu[#truckMenu+1] = {
            header = Config.Vehicles[k],
            params = {
                event = "qb-trucker:client:TakeOutVehicle",
                args = {
                    vehicle = k
                }
            }
        }
    end

    truckMenu[#truckMenu+1] = {
        header = Lang:t("menu.close_menu"),
        txt = "",
        params = {
            event = "qb-menu:client:closeMenu"
        }

    }
    exports['qb-menu']:openMenu(truckMenu)
end


local function CloseMenuFull()
    exports['qb-menu']:closeMenu()
end

local function CreateZone(type, number)
    local coords
    local heading
    local boxName
    local event
    local label
    local size

    if type == "main" then
        event = "qb-truckerjob:client:PaySlip"
        label = "Payslip"
        coords = vector3(Config.Locations[type].coords.x, Config.Locations[type].coords.y, Config.Locations[type].coords.z)
        heading = Config.Locations[type].coords.h
        boxName = Config.Locations[type].label
        size = 3
    elseif type == "vehicle" then
        event = "qb-truckerjob:client:Vehicle"
        label = "Vehicle"
        coords = vector3(Config.Locations[type].coords.x, Config.Locations[type].coords.y, Config.Locations[type].coords.z)
        heading = Config.Locations[type].coords.h
        boxName = Config.Locations[type].label
        size = 5
    elseif type == "stores" then
        event = "qb-truckerjob:client:Store"
        label = "Store"
        coords = vector3(Config.Locations[type][number].coords.x, Config.Locations[type][number].coords.y, Config.Locations[type][number].coords.z)
        heading = Config.Locations[type][number].coords.h
        boxName = Config.Locations[type][number].name
        size = 40
    end

    if Config.UseTarget and type == "main"then
        exports['qb-target']:AddBoxZone(boxName, coords, size, size, {
            minZ = coords.z - 5.0,
            maxZ = coords.z + 5.0,
            name = boxName,
            heading = heading,
            debugPoly = false,
        }, {
            options = {
                {
                    type = "client",
                    event = event,
                    label = label,
                },
            },
            distance = 2
        })
    else
        local zone = BoxZone:Create(
            coords, size, size, {
                minZ = coords.z - 5.0,
                maxZ = coords.z + 5.0,
                name = boxName,
                debugPoly = false,
                heading = heading,
            })
    
        local zoneCombo = ComboZone:Create({zone}, {name = boxName, debugPoly = false})
        zoneCombo:onPlayerInOut(function(isPointInside)
            if isPointInside then
                if type == "main" then
                    TriggerEvent('qb-truckerjob:client:PaySlip')
                elseif type == "vehicle" then
                    TriggerEvent('qb-truckerjob:client:Vehicle')
                elseif type == "stores" then
                    markerLocation = coords
                    QBCore.Functions.Notify(Lang:t("mission.store_reached"))
                    TriggerEvent('qb-truckerjob:client:ShowMarker', true)
                    TriggerEvent('qb-truckerjob:client:SetDelivering', true)
                end
            else
                if type == "stores" then
                    TriggerEvent('qb-truckerjob:client:ShowMarker', false)
                    TriggerEvent('qb-truckerjob:client:SetDelivering', false)
                end
            end
        end)
        if type == "vehicle" then
            local zonedel = BoxZone:Create(
                coords, 40, 40, {
                    minZ = coords.z - 5.0,
                    maxZ = coords.z + 5.0,
                    name = boxName,
                    debugPoly = false,
                    heading = heading,
                })
        
            local zoneCombodel = ComboZone:Create({zonedel}, {name = boxName, debugPoly = false})
            zoneCombodel:onPlayerInOut(function(isPointInside)
                if isPointInside then
                    markerLocation = coords
                    TriggerEvent('qb-truckerjob:client:ShowMarker', true)
                else
                    TriggerEvent('qb-truckerjob:client:ShowMarker', false)
                end
            end)
        elseif type == "stores" then
            CurrentLocation.zoneCombo = zoneCombo
        end
    end
end

local function getNewLocation()
    local location = getNextClosestLocation()
    if location ~= 0 then
        CurrentLocation = {}
        CurrentLocation.id = location
        CurrentLocation.dropcount = math.random(1, 3)
        CurrentLocation.store = Config.Locations["stores"][location].name
        CurrentLocation.x = Config.Locations["stores"][location].coords.x
        CurrentLocation.y = Config.Locations["stores"][location].coords.y
        CurrentLocation.z = Config.Locations["stores"][location].coords.z
        CreateZone("stores", location)

        CurrentBlip = AddBlipForCoord(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z)
        SetBlipColour(CurrentBlip, 3)
        SetBlipRoute(CurrentBlip, true)
        SetBlipRouteColour(CurrentBlip, 3)
    else
        QBCore.Functions.Notify(Lang:t("success.payslip_time"))
        if CurrentBlip ~= nil then
            RemoveBlip(CurrentBlip)
	        ClearAllBlipRoutes()
            CurrentBlip = nil
        end
    end
end

local function CreateElements()
    TruckVehBlip = AddBlipForCoord(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)
    SetBlipSprite(TruckVehBlip, 326)
    SetBlipDisplay(TruckVehBlip, 4)
    SetBlipScale(TruckVehBlip, 0.6)
    SetBlipAsShortRange(TruckVehBlip, true)
    SetBlipColour(TruckVehBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Locations["vehicle"].label)
    EndTextCommandSetBlipName(TruckVehBlip)

    local TruckerBlip = AddBlipForCoord(Config.Locations["main"].coords.x, Config.Locations["main"].coords.y, Config.Locations["main"].coords.z)
    SetBlipSprite(TruckerBlip, 479)
    SetBlipDisplay(TruckerBlip, 4)
    SetBlipScale(TruckerBlip, 0.6)
    SetBlipAsShortRange(TruckerBlip, true)
    SetBlipColour(TruckerBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Locations["main"].label)
    EndTextCommandSetBlipName(TruckerBlip)

    CreateZone("main")
    CreateZone("vehicle")
end

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    CurrentLocation = nil
    CurrentBlip = nil
    hasBox = false
    isWorking = false
    JobsDone = 0
    if PlayerJob.name == "trucker" then
        CreateElements()
    end

end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    RemoveTruckerBlips()
    CurrentLocation = nil
    CurrentBlip = nil
    hasBox = false
    isWorking = false
    JobsDone = 0
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    local OldPlayerJob = PlayerJob.name
    PlayerJob = JobInfo

    if PlayerJob.name == "trucker" then
        CreateElements()
    end
    if OldPlayerJob == "trucker" then
        RemoveTruckerBlips()
    end
end)

RegisterNetEvent('qb-truckerjob:client:ShowMarker', function(active)
    if PlayerJob.name == "trucker" then
        showMarker = active
    end
end)

RegisterNetEvent('qb-truckerjob:client:SetDelivering', function(active)
    if PlayerJob.name == "trucker" then
        Delivering = active
    end
end)




RegisterNetEvent('qb-trucker:client:SpawnVehicle', function()
    local vehicleInfo = selectedVeh
    local coords = Config.Locations["vehicle"].coords
    coords = vector3(coords.x, coords.y, coords.z)
    QBCore.Functions.SpawnVehicle(vehicleInfo, function(veh)
        SetVehicleNumberPlateText(veh, "TRUK"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.w)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        CloseMenuFull()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetEntityAsMissionEntity(veh, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
        CurrentPlate = QBCore.Functions.GetPlate(veh)
        getNewLocation()
    end, coords, true)
end)

RegisterNetEvent('qb-trucker:client:TakeOutVehicle', function(data)
    local vehicleInfo = data.vehicle
    TriggerServerEvent('qb-trucker:server:DoBail', true, vehicleInfo)
    selectedVeh = vehicleInfo
end)

RegisterNetEvent('qb-truckerjob:client:Vehicle', function()
    if IsPedInAnyVehicle(PlayerPedId()) and isTruckerVehicle(GetVehiclePedIsIn(PlayerPedId(), false)) then
        if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId() then
            if isTruckerVehicle(GetVehiclePedIsIn(PlayerPedId(), false)) then
                DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                TriggerServerEvent('qb-trucker:server:DoBail', false)
                if CurrentBlip ~= nil then
                    RemoveBlip(CurrentBlip)
                    ClearAllBlipRoutes()
                    CurrentBlip = nil
                end
            else
                QBCore.Functions.Notify(Lang:t("error.vehicle_not_correct"), 'error')
            end
        else
            QBCore.Functions.Notify(Lang:t("error.no_driver"))
        end
    else
        MenuGarage()
    end
end)

RegisterNetEvent('qb-truckerjob:client:PaySlip', function()
    if JobsDone > 0 then
        TriggerServerEvent("qb-trucker:server:01101110", JobsDone)
        JobsDone = 0
        if #LocationsDone == #Config.Locations["stores"] then
            LocationsDone = {}
        end
        if CurrentBlip ~= nil then
            RemoveBlip(CurrentBlip)
            ClearAllBlipRoutes()
            CurrentBlip = nil
        end
    else
        QBCore.Functions.Notify(Lang:t("error.no_work_done"), "error")
    end

end)

RegisterNetEvent('qb-trucker:client:GetInTrunk', function()
    if not IsPedInAnyVehicle(PlayerPedId()) then
        local pos = GetEntityCoords(PlayerPedId(), true)
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
        if isTruckerVehicle(vehicle) and CurrentPlate == QBCore.Functions.GetPlate(vehicle) then
            local trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)
            if #(pos - vector3(trunkpos.x, trunkpos.y, trunkpos.z)) < 1.5 and not isWorking then
                isWorking = true
                QBCore.Functions.Progressbar("work_carrybox", Lang:t("mission.take_box"), 2000, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = "anim@gangops@facility@servers@",
                    anim = "hotwire",
                    flags = 16,
                }, {}, {}, function() -- Done
                    isWorking = false
                    StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                    TriggerEvent('animations:client:EmoteCommandStart', {"box"})
                    hasBox = true
                end, function() -- Cancel
                    isWorking = false
                    StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                    QBCore.Functions.Notify(Lang:t("error.cancelled"), "error")
                end)
            end
        end
    end
end)

RegisterNetEvent('qb-trucker:client:Deliver', function()
    isWorking = true
    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    Wait(500)
    TriggerEvent('animations:client:EmoteCommandStart', {"bumbin"})
    QBCore.Functions.Progressbar("work_dropbox", Lang:t("mission.deliver_box"), 2000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        isWorking = false
        ClearPedTasks(PlayerPedId())
        hasBox = false
        currentCount = currentCount + 1
        if currentCount == CurrentLocation.dropcount then
            LocationsDone[#LocationsDone+1] = CurrentLocation.id
            TriggerServerEvent("qb-shops:server:RestockShopItems", CurrentLocation.store)
            QBCore.Functions.Notify(Lang:t("mission.goto_next_point"))
            exports['qb-core']:HideText()
            Delivering = false
            showMarker = false
            TriggerServerEvent('qb-trucker:server:nano')
            if CurrentBlip ~= nil then
                RemoveBlip(CurrentBlip)
                ClearAllBlipRoutes()
                CurrentBlip = nil
            end
            CurrentLocation.zoneCombo:destroy()
            CurrentLocation = nil
            currentCount = 0
            JobsDone = JobsDone + 1
            getNewLocation()
        else
            QBCore.Functions.Notify(Lang:t("mission.another_box"))
        end
    end, function() -- Cancel
        isWorking = false
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify(Lang:t("error.cancelled"), "error")
    end)

end)

-- Threads
CreateThread(function()
    local sleep
    while true do
        sleep = 1000
        if showMarker then
            DrawMarker(2, markerLocation.x, markerLocation.y, markerLocation.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
            sleep = 0
        end
        if Delivering then
            if IsControlJustReleased(0, 38) then
                if not hasBox then
                    TriggerEvent('qb-trucker:client:GetInTrunk')
                else
                    TriggerEvent('qb-trucker:client:Deliver')
                end
            end
            sleep = 0
        end
        Wait(sleep)
    end
end)