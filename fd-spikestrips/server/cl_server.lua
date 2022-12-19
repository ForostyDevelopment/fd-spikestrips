local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("spikestrip", function(source)
    TriggerClientEvent('fd-spikestrips:client:SpawnSpikeStrip', source)
end)

RegisterNetEvent('fd-spikestrips:server:SyncSpikes', function(table)
    TriggerClientEvent('fd-spikestrips:client:SyncSpikes', -1, table)
end)

RegisterNetEvent('fd-spikestrips:server:removeItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem('spikestrip', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['spikestrip'], "remove", 1)
    TriggerClientEvent('fd-spawnstrips:client:spawnSpike', source) 
end)

