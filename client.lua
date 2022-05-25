local SpawnedSpikes = {}
local spikemodel = "P_ld_stinger_s"
local nearSpikes = false
local spikesSpawned = false
local tires = {
    {bone = "wheel_lf", index = 0},
    {bone = "wheel_rf", index = 1},
    {bone = "wheel_lm", index = 2},
    {bone = "wheel_rm", index = 3},
    {bone = "wheel_lr", index = 4},
    {bone = "wheel_rr", index = 5}
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) then
            local vehicle = GetVehiclePedIsIn(GetPlayerPed(PlayerId()), false)
            if GetPedInVehicleSeat(vehicle, -1) == GetPlayerPed(PlayerId()) then
                local vehiclePos = GetEntityCoords(vehicle, false)
                local spikes = GetClosestObjectOfType(vehiclePos.x, vehiclePos.y, vehiclePos.z, 80.0, GetHashKey(spikemodel), 1, 1, 1)
                local spikePos = GetEntityCoords(spikes, false)
                local distance = Vdist(vehiclePos.x, vehiclePos.y, vehiclePos.z, spikePos.x, spikePos.y, spikePos.z)
                if spikes ~= 0 then
                    nearSpikes = true
                else
                    nearSpikes = false
                end
            else
                nearSpikes = false
            end
        else
            nearSpikes = false
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if nearSpikes then
            for a = 1, #tires do
                local vehicle = GetVehiclePedIsIn(GetPlayerPed(PlayerId()), false)
                local tirePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, tires[a].bone))
                local spike = GetClosestObjectOfType(tirePos.x, tirePos.y, tirePos.z, 15.0, GetHashKey(spikemodel), 1, 1, 1)
                local spikePos = GetEntityCoords(spike, false)
                local distance = Vdist(tirePos.x, tirePos.y, tirePos.z, spikePos.x, spikePos.y, spikePos.z)
                if distance < 1.8 then
                    if not IsVehicleTyreBurst(vehicle, tires[a].index, true) or IsVehicleTyreBurst(vehicle, tires[a].index, false) then
                        SetVehicleTyreBurst(vehicle, tires[a].index, false, 1000.0)
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)

RegisterCommand('removespikes', function()
    if spikesSpawned then
        ExecuteCommand('e kneel2')
        Citizen.Wait(2000)
        RemoveSpikes()
        ExecuteCommand('e c')
        drawNotification("Spikestrips have been ~r~removed~w~.")
        spikesSpawned = false
    else
        drawNotification("~r~There are no spikestrips to remove.")
    end
end, false)
TriggerEvent("chat:addSuggestion", "/removespikes", "Remove placed spikestrips. Usage: /removespikes")

Citizen.CreateThread(function()
    while true do
        if spikesSpawned then
            DisplayNotification("Press ~INPUT_CHARACTER_WHEEL~ + ~INPUT_CONTEXT~ to remove spikestrips.")
            if IsControlPressed(1, 19) and IsControlJustPressed(1, 51) then
                ExecuteCommand('e kneel2')
                Citizen.Wait(2000)
                RemoveSpikes()
                ExecuteCommand('e c')
                drawNotification("Spikestrips have been ~r~removed~w~.")
                spikesSpawned = false
            end
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent("Spikes:SpawnSpikes")
AddEventHandler("Spikes:SpawnSpikes", function(amount)
    if spikesSpawned ~= true then
        ExecuteCommand('e kneel2')
        Citizen.Wait(1000)
        CreateSpikes(amount)
        ExecuteCommand('e c')
        drawNotification("Spikestrips have been ~g~deployed~w~. (~r~x" .. amount .. "~w~)")
        TriggerEvent('Spikes:RemoveCheck')
    else
        drawNotification("You have ~r~already placed ~w~some spikestrips.")
    end
end)

RegisterNetEvent("Spikes:DeleteSpikes")
AddEventHandler("Spikes:DeleteSpikes", function(netid)
    Citizen.CreateThread(function()
        local spike = NetworkGetEntityFromNetworkId(netid)
        DeleteEntity(spike)
    end)
end)

function CreateSpikes(amount)
    local spawnCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 2.0, 0.0)
    for a = 1, amount do
        local spike = CreateObject(GetHashKey(spikemodel), spawnCoords.x, spawnCoords.y, spawnCoords.z, 1, 1, 1)
        local netid = NetworkGetNetworkIdFromEntity(spike)
        SetNetworkIdExistsOnAllMachines(netid, true)
        SetNetworkIdCanMigrate(netid, false)
        SetEntityHeading(spike, GetEntityHeading(GetPlayerPed(PlayerId())))
        PlaceObjectOnGroundProperly(spike)
        spawnCoords = GetOffsetFromEntityInWorldCoords(spike, 0.0, 4.0, 0.0)
        table.insert(SpawnedSpikes, netid)
    end
    spikesSpawned = true
end

RegisterNetEvent("Spikes:RemoveCheck")
AddEventHandler("Spikes:RemoveCheck", function()
    if spikesSpawned then
        Citizen.Wait(60000)
        RemoveSpikes()
        print("[removecheck] Spikestrips have been removed after 60 seconds.")
        spikesSpawned = false
    end
end)

function RemoveSpikes()
    for a = 1, #SpawnedSpikes do
        TriggerServerEvent("Spikes:TriggerDeleteSpikes", SpawnedSpikes[a])
    end
    SpawnedSpikes = {}
end

function DisplayNotification(string)
	SetTextComponentFormat("STRING")
	AddTextComponentString(string)
    DisplayHelpTextFromStringLabel(0, 0, 0, -1)
end

function drawNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end