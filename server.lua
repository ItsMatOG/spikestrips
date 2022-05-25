RegisterCommand("setspikes", function(source, args, raw)
    local src = source
	if args[1] == nil then
		args[1] = 2
	end
    if tonumber(args[1]) <= 4 then
        SpawnSpikestrips(src, args[1])
    end
end)

function SpawnSpikestrips(src, amount)
    TriggerClientEvent("Spikes:SpawnSpikes", src, amount)
end

RegisterServerEvent("Spikes:TriggerDeleteSpikes")
AddEventHandler("Spikes:TriggerDeleteSpikes", function(netid)
    TriggerClientEvent("Spikes:DeleteSpikes", -1, netid)
end)