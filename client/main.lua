isLoggedIn = true
local PlayerJob = {}
local JobsDone = 0
local LocationsDone = {}
local CurrentLocation = nil
local CurrentBlip = nil
local hasBox = false
local isWorking = false
local currentCount = 0
local CurrentPlate = nil
local CurrentTow = nil

local selectedVeh = nil
local TruckVehBlip = nil

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerJob = QBCore.Functions.GetPlayerData().job
    CurrentLocation = nil
    CurrentBlip = nil
    hasBox = false
    isWorking = false
    JobsDone = 0

    if PlayerJob.name == "trucker" then
        TruckVehBlip = AddBlipForCoord(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)
        SetBlipSprite(TruckVehBlip, 326)
        SetBlipDisplay(TruckVehBlip, 4)
        SetBlipScale(TruckVehBlip, 0.6)
        SetBlipAsShortRange(TruckVehBlip, true)
        SetBlipColour(TruckVehBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Config.Locations["vehicle"].label)
        EndTextCommandSetBlipName(TruckVehBlip)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    RemoveTruckerBlips()
    CurrentLocation = nil
    CurrentBlip = nil
    hasBox = false
    isWorking = false
    JobsDone = 0
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    local OldlayerJob = PlayerJob.name
    PlayerJob = JobInfo

    if PlayerJob.name == "trucker" then
        TruckVehBlip = AddBlipForCoord(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)
        SetBlipSprite(TruckVehBlip, 326)
        SetBlipDisplay(TruckVehBlip, 4)
        SetBlipScale(TruckVehBlip, 0.6)
        SetBlipAsShortRange(TruckVehBlip, true)
        SetBlipColour(TruckVehBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Config.Locations["vehicle"].label)
        EndTextCommandSetBlipName(TruckVehBlip)
    elseif OldlayerJob == "trucker" then
        RemoveTruckerBlips()
    end
end)

Citizen.CreateThread(function()
    local TruckerBlip = AddBlipForCoord(Config.Locations["main"].coords.x, Config.Locations["main"].coords.y, Config.Locations["main"].coords.z)
    SetBlipSprite(TruckerBlip, 479)
    SetBlipDisplay(TruckerBlip, 4)
    SetBlipScale(TruckerBlip, 0.6)
    SetBlipAsShortRange(TruckerBlip, true)
    SetBlipColour(TruckerBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Locations["main"].label)
    EndTextCommandSetBlipName(TruckerBlip)
    while true do 
        Citizen.Wait(1)
        if isLoggedIn and QBCore ~= nil then
            if PlayerJob.name == "trucker" then
                if IsControlJustReleased(0, 178) then
                    if IsPedInAnyVehicle(PlayerPedId()) and isTruckerVehicle(GetVehiclePedIsIn(PlayerPedId(), false)) then
                        getNewLocation()
                        CurrentPlate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false))
                    end
                end
                local pos = GetEntityCoords(PlayerPedId())
                if #(pos - vector3(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)) < 10.0 then
                    DrawMarker(2, Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                    if #(pos - vector3(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)) < 1.5 then
                        if IsPedInAnyVehicle(PlayerPedId(), false) then
                            DrawText3D(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, "~g~E~w~ - Store Vehicle")
                        else
                            DrawText3D(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, "~g~E~w~ - Vehicle")
                        end
                        if IsControlJustReleased(0, 38) then
                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId() then
                                    if isTruckerVehicle(GetVehiclePedIsIn(PlayerPedId(), false)) then
                                        DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                        TriggerServerEvent('qb-trucker:server:DoBail', false)
                                    else
                                        QBCore.Functions.Notify('This is not a commercial vehicle!', 'error')
                                    end
                                else
                                    QBCore.Functions.Notify('You must be the driver to do this..')
                                end
                            else
                                MenuGarage()
                                Menu.hidden = not Menu.hidden
                            end
                        end
                        Menu.renderGUI()
                    end 
                end
    
                if #(pos - vector3(Config.Locations["main"].coords.x, Config.Locations["main"].coords.y, Config.Locations["main"].coords.z)) < 4.5 then
                    if #(pos - vector3(Config.Locations["main"].coords.x, Config.Locations["main"].coords.y, Config.Locations["main"].coords.z)) < 1.5 then
                        DrawText3D(Config.Locations["main"].coords.x, Config.Locations["main"].coords.y, Config.Locations["main"].coords.z, "~g~E~w~ - Payslip")
                        if IsControlJustReleased(0, 38) then
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
                                QBCore.Functions.Notify("You haven't done any work yet..", "error")
                            end
                        end
                    elseif #(pos - vector3(Config.Locations["main"].coords.x, Config.Locations["main"].coords.y, Config.Locations["main"].coords.z)) < 2.5 then
                        DrawText3D(Config.Locations["main"].coords.x, Config.Locations["main"].coords.y, Config.Locations["main"].coords.z, "Payslip")
                    end  
                end
    
                if CurrentLocation ~= nil  and currentCount < CurrentLocation.dropcount then
                    if #(pos - vector3(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z)) < 40.0 then
                        if not IsPedInAnyVehicle(PlayerPedId()) then
                            if not hasBox then
                                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                                if isTruckerVehicle(vehicle) and CurrentPlate == GetVehicleNumberPlateText(vehicle) then
                                    local trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)
                                    if #(pos - vector3(trunkpos.x, trunkpos.y, trunkpos.z)) < 1.5 and not isWorking then
                                        DrawText3D(trunkpos.x, trunkpos.y, trunkpos.z, "~g~E~w~ - Pick Up Products")
                                        if IsControlJustReleased(0, 38) then
                                            isWorking = true
                                            QBCore.Functions.Progressbar("work_carrybox", "Take A Box Of Products", 2000, false, true, {
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
                                                QBCore.Functions.Notify("Canceled", "error")
                                            end)
                                        end
                                    else
                                        DrawText3D(trunkpos.x, trunkpos.y, trunkpos.z, "Pick Up Products")
                                    end
                                end
                            elseif hasBox then
                                if #(pos - vector3(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z)) < 1.5 and not isWorking then
                                    DrawText3D(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z, "~g~E~w~ - Deliver Products")
                                    if IsControlJustReleased(0, 38) then
                                        isWorking = true
                                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                                        Citizen.Wait(500)
                                        TriggerEvent('animations:client:EmoteCommandStart', {"bumbin"})
                                        QBCore.Functions.Progressbar("work_dropbox", "Deliver Box Of Products", 2000, false, true, {
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
                                                table.insert(LocationsDone, CurrentLocation.id)
                                                TriggerServerEvent("qb-shops:server:RestockShopItems", CurrentLocation.store)
                                                QBCore.Functions.Notify("You Have Delivered All Products, To The Next Point")
                                                local chance = math.random(1,100)
                                                if chance < 26 then
                                                    TriggerServerEvent('qb-trucker:server:nano')
                                                end
                                                if CurrentBlip ~= nil then
                                                    RemoveBlip(CurrentBlip)
						    ClearAllBlipRoutes()
                                                    CurrentBlip = nil
                                                end
                                                CurrentLocation = nil
                                                currentCount = 0
                                                JobsDone = JobsDone + 1
                                                getNewLocation()
                                            end
                                        end, function() -- Cancel
                                            isWorking = false
                                            ClearPedTasks(PlayerPedId())
                                            QBCore.Functions.Notify("Canceled", "error")
                                        end)
                                    end
                                else
                                    DrawText3D(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z, "Deliver Products")
                                end
                            end
                        end
                    end
                end
            else
                Citizen.Wait(1000)
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

function getNewLocation()
    local location = getNextClosestLocation()
    if location ~= 0 then
        CurrentLocation = {}
        CurrentLocation.id = location
        CurrentLocation.dropcount = math.random(1, 3)
        CurrentLocation.store = Config.Locations["stores"][location].name
        CurrentLocation.x = Config.Locations["stores"][location].coords.x
        CurrentLocation.y = Config.Locations["stores"][location].coords.y
        CurrentLocation.z = Config.Locations["stores"][location].coords.z

        CurrentBlip = AddBlipForCoord(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z)
        SetBlipColour(CurrentBlip, 3)
        SetBlipRoute(CurrentBlip, true)
        SetBlipRouteColour(CurrentBlip, 3)
    else
        QBCore.Functions.Notify("You Went To All The Shops .. Time For Your Payslip!")
        if CurrentBlip ~= nil then
            RemoveBlip(CurrentBlip)
	    ClearAllBlipRoutes()
            CurrentBlip = nil
        end
    end
end

function getNextClosestLocation()
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

function hasDoneLocation(locationId)
    local retval = false
    if LocationsDone ~= nil and next(LocationsDone) ~= nil then 
        for k, v in pairs(LocationsDone) do
            if v == locationId then
                retval = true
            end
        end
    end
    return retval
end

function isTruckerVehicle(vehicle)
    local retval = false
    for k, v in pairs(Config.Vehicles) do
        if GetEntityModel(vehicle) == GetHashKey(k) then
            retval = true
        end
    end
    return retval
end

function MenuGarage()
    ped = PlayerPedId();
    MenuTitle = "Garage"
    ClearMenu()
    Menu.addButton("Vehicles", "VehicleList", nil)
    Menu.addButton("Close Menu", "closeMenuFull", nil) 
end

function VehicleList(isDown)
    ped = PlayerPedId();
    MenuTitle = "Vehicles:"
    ClearMenu()
    for k, v in pairs(Config.Vehicles) do
        Menu.addButton(Config.Vehicles[k], "TakeOutVehicle", k, "Garage", " Motor: 100%", " Body: 100%", " Fuel: 100%")
    end
        
    Menu.addButton("Back", "MenuGarage",nil)
end

function TakeOutVehicle(vehicleInfo)
    TriggerServerEvent('qb-trucker:server:DoBail', true, vehicleInfo)
    selectedVeh = vehicleInfo
end

function RemoveTruckerBlips()
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

RegisterNetEvent('qb-trucker:client:SpawnVehicle')
AddEventHandler('qb-trucker:client:SpawnVehicle', function()
    local vehicleInfo = selectedVeh
    local coords = Config.Locations["vehicle"].coords
    QBCore.Functions.SpawnVehicle(vehicleInfo, function(veh)
        SetVehicleNumberPlateText(veh, "TRUK"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.w)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        closeMenuFull()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetEntityAsMissionEntity(veh, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
        CurrentPlate = GetVehicleNumberPlateText(veh)
        getNewLocation()
    end, coords, true)
end)

function closeMenuFull()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end
