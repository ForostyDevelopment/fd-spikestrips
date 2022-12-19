local QBCore = exports['qb-core']:GetCoreObject()
local Player = PlayerPedId()
local SpawnedSpikes = {}
local spikemodel = `P_ld_stinger_s`

local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

local function openAnim()
    LoadAnimDict('pickup_object')
    TaskPlayAnim(Player,'pickup_object', 'putdown_low', 5.0, 1.5, 1.0, 48, 0.0, 0, 0, 0)
    Wait(500)
    StopAnimTask(Player, 'pickup_object', 'putdown_low', 1.0)
end

RegisterNetEvent('fd-spikestrips:client:SpawnSpikeStrip', function()
 PlayerData = QBCore.Functions.GetPlayerData()
  if #SpawnedSpikes + 1 < Config.MaxSpikes then
   if not IsPedInAnyVehicle(PlayerPedId()) then
    if Config.AllowSpikesOnlyForPolice then 
     if PlayerData.job.name == "police" then
        TriggerServerEvent('fd-spikestrips:server:removeItem')
     else 
      QBCore.Functions.Notify("Only police can use these!", 'error')
     end
     elseif not Config.AllowSpikesOnlyForPolice then 
        TriggerServerEvent('fd-spikestrips:server:removeItem')
     end
    else 
     QBCore.Functions.Notify("You can't place a spikestrip inside a vehicle!", 'error')
    end
   else
    QBCore.Functions.Notify('You have placed too many spikestrips!', 'error')
   end
end)

RegisterNetEvent('fd-spawnstrips:client:spawnSpike', function()
    -- Spawn
    openAnim()
    local spawnCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, 0.0)
    local spike = CreateObject(spikemodel, spawnCoords.x, spawnCoords.y, spawnCoords.z, 1, 1, 1)
    local netid = NetworkGetNetworkIdFromEntity(spike)
    SetNetworkIdExistsOnAllMachines(netid, true)
    SetNetworkIdCanMigrate(netid, false)
    SetEntityHeading(spike, GetEntityHeading(PlayerPedId()))
    PlaceObjectOnGroundProperly(spike)
    SpawnedSpikes[#SpawnedSpikes+1] = {
        coords = vector3(spawnCoords.x, spawnCoords.y, spawnCoords.z),
        netid = netid,
        object = spike,
    }
    TriggerServerEvent('fd-spikestrips:server:SyncSpikes', SpawnedSpikes)
    QBCore.Functions.Notify('You have placed down a spike strip', 'success')
    
    -- Delete
    Wait(Config.DeleteTime * 1000)
    NetworkRegisterEntityAsNetworked(SpawnedSpikes[ClosestSpike].object)
    NetworkRequestControlOfEntity(SpawnedSpikes[ClosestSpike].object)
    SetEntityAsMissionEntity(SpawnedSpikes[ClosestSpike].object)
    DeleteEntity(SpawnedSpikes[ClosestSpike].object)
    SpawnedSpikes[ClosestSpike] = nil
    ClosestSpike = nil
    TriggerServerEvent('fd-spikestrips:server:SyncSpikes', SpawnedSpikes)
    
end)

RegisterNetEvent('fd-spikestrips:client:SyncSpikes', function(table)
    SpawnedSpikes = table
end)

function GetClosestSpike()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil

    for id, data in pairs(SpawnedSpikes) do
        if current then
            if #(pos - vector3(SpawnedSpikes[id].coords.x, SpawnedSpikes[id].coords.y, SpawnedSpikes[id].coords.z)) < dist then
                current = id
            end
        else
            dist = #(pos - vector3(SpawnedSpikes[id].coords.x, SpawnedSpikes[id].coords.y, SpawnedSpikes[id].coords.z))
            current = id
        end
    end
    ClosestSpike = current
end

CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            GetClosestSpike()
        end
        Wait(500)
    end
end)

CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            if ClosestSpike then
                local tires = {
                    {bone = "wheel_lf", index = 0},
                    {bone = "wheel_rf", index = 1},
                    {bone = "wheel_lm", index = 2},
                    {bone = "wheel_rm", index = 3},
                    {bone = "wheel_lr", index = 4},
                    {bone = "wheel_rr", index = 5}
                }

                for a = 1, #tires do
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    local tirePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, tires[a].bone))
                    local spike = GetClosestObjectOfType(tirePos.x, tirePos.y, tirePos.z, 15.0, spikemodel, 1, 1, 1)
                    local spikePos = GetEntityCoords(spike, false)
                    local distance = #(tirePos - spikePos)

                    if distance < 1.8 then
                        if not IsVehicleTyreBurst(vehicle, tires[a].index, true) or IsVehicleTyreBurst(vehicle, tires[a].index, false) then
                            SetVehicleTyreBurst(vehicle, tires[a].index, Config.InstantlyPop, 1000.0)
                        end
                    end
                end
            end
        end

        Wait(100)
    end
end)
