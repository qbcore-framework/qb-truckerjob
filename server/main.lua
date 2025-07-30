local QBCore = exports['qb-core']:GetCoreObject()
local Bail = {}

local function handleMoneyDeduction(player, amount, paymentMethod, bailKey)
    player.Functions.RemoveMoney(paymentMethod, amount, 'tow-received-bail')
    TriggerClientEvent('QBCore:Notify', source, Lang:t('success.paid_with_'..paymentMethod, { value = amount }), 'success')
    Bail[player.PlayerData.citizenid] = amount
    TriggerClientEvent('qb-trucker:client:SpawnVehicle', source, vehInfo)
end

RegisterNetEvent('qb-trucker:server:DoBail', function(bool, vehInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if bool then
        local paymentMethod = Player.PlayerData.money.cash >= Config.TruckerJobTruckDeposit and 'cash' or 
                              Player.PlayerData.money.bank >= Config.TruckerJobTruckDeposit and 'bank' or nil
        if paymentMethod then
            handleMoneyDeduction(Player, Config.TruckerJobTruckDeposit, paymentMethod, 'tow-received-bail')
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t('error.no_deposit', { value = Config.TruckerJobTruckDeposit }), 'error')
        end
    else
        if Bail[Player.PlayerData.citizenid] then
            Player.Functions.AddMoney('cash', Bail[Player.PlayerData.citizenid], 'trucker-bail-paid')
            Bail[Player.PlayerData.citizenid] = nil
            TriggerClientEvent('QBCore:Notify', src, Lang:t('success.refund_to_cash', { value = Config.TruckerJobTruckDeposit }), 'success')
        end
    end
end)

RegisterNetEvent('qb-trucker:server:01101110', function(drops)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    drops = tonumber(drops)
    local bonus = 0

    if drops >= 5 then
        if Config.TruckerJobBonus < 0 then Config.TruckerJobBonus = 0 end
        bonus = (math.ceil(Config.TruckerJobDropPrice / 100) * Config.TruckerJobBonus) * drops
    end
    local payment = (Config.TruckerJobDropPrice * drops + bonus)
    payment = payment - (math.ceil(payment / 100) * Config.TruckerJobPaymentTax)
    Player.Functions.AddJobReputation(drops)
    Player.Functions.AddMoney('bank', payment, 'trucker-salary')
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.you_earned', { value = payment }), 'success')
end)

RegisterNetEvent('qb-trucker:server:nano', function()
    local chance = math.random(1, 100)
    if chance > 26 then return end
    local xPlayer = QBCore.Functions.GetPlayer(tonumber(source))
    xPlayer.Functions.AddItem('cryptostick', 1, false)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['cryptostick'], 'add')
end)
