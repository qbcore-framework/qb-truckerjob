local QBCore = exports['qb-core']:GetCoreObject()
local PaymentTax = 15
local Bail = {}

RegisterNetEvent('qb-trucker:server:DoBail', function(bool, vehInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if bool then
        if Player.PlayerData.money.cash >= Config.BailPrice then
            Bail[Player.PlayerData.citizenid] = Config.BailPrice
            Player.Functions.RemoveMoney('cash', Config.BailPrice, "tow-received-bail")
            TriggerClientEvent('QBCore:Notify', src, Lang:t("success.paid_with_cash", {value = Config.BailPrice}), 'success')
            TriggerClientEvent('qb-trucker:client:SpawnVehicle', src, vehInfo)
        elseif Player.PlayerData.money.bank >= Config.BailPrice then
            Bail[Player.PlayerData.citizenid] = Config.BailPrice
            Player.Functions.RemoveMoney('bank', Config.BailPrice, "tow-received-bail")
            TriggerClientEvent('QBCore:Notify', src, Lang:t("success.paid_with_bank", {value = Config.BailPrice}), 'success')
            TriggerClientEvent('qb-trucker:client:SpawnVehicle', src, vehInfo)
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.no_deposit", {value = Config.BailPrice}), 'error')
        end
    else
        if Bail[Player.PlayerData.citizenid] ~= nil then
            Player.Functions.AddMoney('cash', Bail[Player.PlayerData.citizenid], "trucker-bail-paid")
            Bail[Player.PlayerData.citizenid] = nil
            TriggerClientEvent('QBCore:Notify', src, Lang:t("success.refund_to_cash", {value = Config.BailPrice}), 'success')
        end
    end
end)

RegisterNetEvent('qb-trucker:server:01101110', function(drops)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    drops = tonumber(drops)
    local bonus = 0
    local DropPrice = math.random(100, 120)

    if drops >= 5 then
        bonus = math.ceil((DropPrice / 10) * 5) + 100
    elseif drops >= 10 then
        bonus = math.ceil((DropPrice / 10) * 7) + 300
    elseif drops >= 15 then
        bonus = math.ceil((DropPrice / 10) * 10) + 400
    elseif drops >= 20 then
        bonus = math.ceil((DropPrice / 10) * 12) + 500
    end

    local price = (DropPrice * drops) + bonus
    local taxAmount = math.ceil((price / 100) * PaymentTax)
    local payment = price - taxAmount
    Player.Functions.AddJobReputation(drops)
    Player.Functions.AddMoney("bank", payment, "trucker-salary")
    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.you_earned", {value = payment}), 'success')
end)

RegisterNetEvent('qb-trucker:server:nano', function()
    local chance = math.random(1,100)
    if chance < 26 then
        local xPlayer = QBCore.Functions.GetPlayer(tonumber(source))
        xPlayer.Functions.AddItem("cryptostick", 1, false)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["cryptostick"], "add")
    end

end)
