local PaymentTax = 15
local Bail = {}
local WorkingLocations = {}

RegisterServerEvent('qb-trucker:server:DoBail')
AddEventHandler('qb-trucker:server:DoBail', function(bool, vehInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if bool then
        if Player.PlayerData.money.cash >= Config.BailPrice then
            Bail[Player.PlayerData.citizenid] = Config.BailPrice
            Player.Functions.RemoveMoney('cash', Config.BailPrice, "tow-received-bail")
            TriggerClientEvent('QBCore:Notify', src, '$250 Deposit Paid With Cash', 'success')
            TriggerClientEvent('qb-trucker:client:SpawnVehicle', src, vehInfo, WorkingLocations)
        elseif Player.PlayerData.money.bank >= Config.BailPrice then
            Bail[Player.PlayerData.citizenid] = Config.BailPrice
            Player.Functions.RemoveMoney('bank', Config.BailPrice, "tow-received-bail")
            TriggerClientEvent('QBCore:Notify', src, '$250 Deposit Paid From Bank', 'success')
            TriggerClientEvent('qb-trucker:client:SpawnVehicle', src, vehInfo, WorkingLocations)
        else
            TriggerClientEvent('QBCore:Notify', src, '$250 Deposit Required', 'error')
        end
    else
        if Bail[Player.PlayerData.citizenid] ~= nil then
            Player.Functions.AddMoney('cash', Bail[Player.PlayerData.citizenid], "trucker-bail-paid")
            Bail[Player.PlayerData.citizenid] = nil
            TriggerClientEvent('QBCore:Notify', src, '$250 Deposit Refunded To Cash', 'success')
        end
    end
end)

RegisterNetEvent('qb-trucker:server:workingLocation')
AddEventHandler('qb-trucker:server:workingLocation', function (location)
    WorkingLocations[source] = location;
    TriggerClientEvent("qb-trucker:client:updateWorkingLocations", -1, WorkingLocations);
end)

RegisterNetEvent('qb-trucker:server:getWorkingLocation')
AddEventHandler('qb-trucker:server:getWorkingLocation', function()
    TriggerClientEvent("qb-trucker:client:updateWorkingLocations", source, WorkingLocations);
end)

RegisterNetEvent('qb-trucker:server:01101110')
AddEventHandler('qb-trucker:server:01101110', function(drops)
    local Player = QBCore.Functions.GetPlayer(source)
    local itemCount = 1
    local drops = tonumber(drops)
    
    for i = 1, itemCount, 1 do
        local randomItem = Config.Rewards["delivery"][math.random(1, #Config.Rewards["delivery"])]

            if randomItem == "iron" then
                itemAmount = math.random(10, 25)
            elseif randomItem == "metalscrap" then
                itemAmount = math.random(10, 25)
            end
            Player.Functions.AddItem(randomItem, itemAmount)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[randomItem], 'add')
    end
    TriggerClientEvent('QBCore:Notify', source, 'received some awards ')
end)

RegisterNetEvent('qb-trucker:server:01101110')
AddEventHandler('qb-trucker:server:01101110', function(drops)
    local src = source 
    local Player = QBCore.Functions.GetPlayer(src)
    local drops = tonumber(drops)
    local bonus = 0
    local DropPrice = math.random(100, 120)
    if drops > 5 then 
        bonus = math.ceil((DropPrice / 10) * 5) + 100
    elseif drops > 10 then
        bonus = math.ceil((DropPrice / 10) * 7) + 300
    elseif drops > 15 then
        bonus = math.ceil((DropPrice / 10) * 10) + 400
    elseif drops > 20 then
        bonus = math.ceil((DropPrice / 10) * 12) + 500
    end
    local price = (DropPrice * drops) + bonus
    local taxAmount = math.ceil((price / 100) * PaymentTax)
    local payment = price - taxAmount
    Player.Functions.AddJobReputation(drops)
    local payslips = Player.PlayerData.metadata["payslips"];
    payslips["trucker"] = payslips["trucker"] + payment;
    Player.Functions.SetMetaData("payslips",payslips)
    TriggerClientEvent('qb-trucker:client:payslipsUpdate',source,payslips["trucker"])
end)

RegisterNetEvent('qb-trucker:server:nano')
AddEventHandler('qb-trucker:server:nano', function()
	local xPlayer = QBCore.Functions.GetPlayer(tonumber(source))
	xPlayer.Functions.AddItem("cryptostick", 1, false)
	TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["cryptostick"], "add")
end)

RegisterNetEvent('qb-trucker:server:payslips')
AddEventHandler('qb-trucker:server:payslips', function(amount)
    local Player = QBCore.Functions.GetPlayer(source)
    local payslips = Player.PlayerData.metadata["payslips"];
    payslips["trucker"] = 0;
    Player.Functions.SetMetaData("payslips",payslips)
    Player.Functions.AddMoney("bank", amount, "trucker-salary")
    TriggerClientEvent('QBCore:Notify', source, 'Has been transferred '..amount..'$ to your bank account')
end)
