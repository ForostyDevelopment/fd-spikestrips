local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("spikestrip", function(source)
    TriggerClientEvent('fd-spikestrips:client:SpawnSpikeStrip', source)
end)

RegisterNetEvent('fd-spikestrips:server:SyncSpikes', function(table)
    TriggerClientEvent('fd-spikestrips:client:SyncSpikes', -1, table)
end)


