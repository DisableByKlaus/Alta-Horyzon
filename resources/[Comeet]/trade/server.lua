local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local Tools = module("vrp", "lib/Tools")

vRPclient = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")

local trades = {}

RegisterCommand('trade', function(source, args)
	if args[1] then
		local src = source
		local Player = vRP.getUserId(source)
		local TargetId = vRP.getUserSource(tonumber(args[1]))
		local Target = vRP.getUserId(TargetId)
		local senderplayer = GetPlayerPed(source)
		local receiverPlayer = GetPlayerPed(TargetId)
		local sendercoords = GetEntityCoords(senderplayer)
		local receiverCoords = GetEntityCoords(receiverPlayer)
		local dist = #(sendercoords - receiverCoords)

		local identifier = vRP.getUserIdentity(Player)
		local identifier2 = vRP.getUserIdentity(Target)
		--local dist = #(vector3(sendercoords.x,sendercoords.y, sendercoords.z) - vector3(receiverCoords.x,receiverCoords.y , receiverCoords.z))


		
		if dist <= 3 then 
			if Target ~= nil then
				if TargetId ~= source  then
					if vRP.request(TargetId,"Você deseja aceitar a troca de "..identifier.name.." "..identifier.name2.."?",30) then
						TriggerEvent('codem-trade:tradeRequestAccepted', TargetId, src)
					else
						TriggerClientEvent("Notify",source,"negado","O "..identifier2.name.." "..identifier2.name2.." não aceitou a negociação!",4)
					end
				else
					TriggerClientEvent("Notify",source,"negado","Não encontrado.",4)
				end
			else
				TriggerClientEvent("Notify",source,"negado","Não encontrado.",4)
			end
		else
			TriggerClientEvent("Notify",source,"negado","Não encontrado.",4)
		end
	end
end)



RegisterServerEvent('codem-trade:tradeRequestAccepted')
AddEventHandler('codem-trade:tradeRequestAccepted', function(sender, source)
	local senderid = sender
	local receiverid = source
	local senderidd = vRP.getUserId(senderid)
	local receiveridd = vRP.getUserId(receiverid)
	local newsenderinventory = {}
	local newreceiverinventory = {}
	--local sender_inventory = ESX.GetPlayerFromId(senderid).getInventory();
	local datasender = vRP.getInventory(senderidd)
	local datareceiver = vRP.getInventory(receiveridd)

	--local receiver_inventory = ESX.GetPlayerFromId(receiverid).getInventory();
	local identifier = vRP.getUserIdentity(receiveridd)
	local identifier2 = vRP.getUserIdentity(senderidd)
	local receiver_name = identifier.name.." "..identifier.name2
	if datasender then
		for k,v in pairs(datasender) do 
			if vRP.itemBodyList(v.item) then
				v.count = v.amount
				v.label = vRP.itemNameList(v.item)
				v.name = vRP.itemIndexList(v.item)
				table.insert(newsenderinventory, v) 
			end
		end
	end
	if datareceiver then
		for k,v in pairs(datareceiver) do 
			if vRP.itemBodyList(v.item) then
				v.count = v.amount
				v.label = vRP.itemNameList(v.item)
				v.name = vRP.itemIndexList(v.item)
				table.insert(newreceiverinventory, v) 
			end 
		end
	end

	local sender_name = identifier2.name.." "..identifier2.name2

	TriggerClientEvent('codem-trade:setTrade', senderid, senderid, receiverid, newsenderinventory, newreceiverinventory, sender_name, receiver_name)
	TriggerClientEvent('codem-trade:setTrade', receiverid, senderid,receiverid,  newsenderinventory, newreceiverinventory, sender_name, receiver_name)
    table.insert(trades, { sender_id = senderid, receiver_id = receiverid})

end)


RegisterServerEvent('codem-trade:server:itemSwapped')
AddEventHandler('codem-trade:server:itemSwapped', function(data)
	local sender_id = data.sender
	local receiver_id = data.receiver
	local toInv = data.toInventory
	local toSlot = data.toSlot
	local fromSlot = data.fromSlot
	local fromInv = data.fromInventory
	local count = data.count
	local senderPlayer = vRP.getUserId(sender_id)
	local receiverPlayer = vRP.getUserId(receiver_id)
	
	if(sender_id == source) then
		TriggerClientEvent('codem-trade:client:itemSwapped', receiver_id, { toInv = toInv, toSlot = toSlot, fromInv = fromInv, fromSlot = fromSlot, count = count })
	end

	if receiver_id == source then
		TriggerClientEvent('codem-trade:client:itemSwapped', sender_id, { toInv = toInv, toSlot = toSlot, fromInv = fromInv, fromSlot = fromSlot, count = count })
	end

end)

RegisterServerEvent('codem-trade:server:shareItems')
AddEventHandler('codem-trade:server:shareItems', function(data)
	local sender_id = data.sender
	local receiver_id = data.receiver
	local senderPlayer = vRP.getUserId(sender_id)
	local receiverPlayer = vRP.getUserId(receiver_id)
	local receiver_items = data.receiverOfferItems
	local sender_items = data.senderOfferItems


	if(source == sender_id) then


	
	
		for k,v in pairs(sender_items) do
			vRP.giveInventoryItem(receiverPlayer, v.name, v.count, true)
			vRP.tryGetInventoryItem(senderPlayer, v.name, v.count, true)
		--	senderPlayer.removeInventoryItem(v.name, v.count)
			--receiverPlayer.addInventoryItem(v.name, v.count)
		end

		for k,v in pairs(receiver_items) do
			vRP.giveInventoryItem(senderPlayer, v.name, v.count, true)
			--senderPlayer.addInventoryItem(v.name, v.count)
			vRP.tryGetInventoryItem(receiverPlayer, v.name, v.count, true)
			--receiverPlayer.removeInventoryItem(v.name, v.count)
		end
	end
end)


RegisterServerEvent('codem-trade:server:confirmToggled')
AddEventHandler('codem-trade:server:confirmToggled', function(data)
	local sender_id = data.sender
	local receiver_id = data.receiver
	local toggled = data.toggle

	if(sender_id == source) then
		TriggerClientEvent('codem-trade:client:confirmedToggled', receiver_id, toggled)
	end

	if(receiver_id == source) then
		TriggerClientEvent('codem-trade:client:confirmedToggled', sender_id, toggled)
	end

end)


RegisterServerEvent('codem-trade:server:tradeCanceled')
AddEventHandler("codem-trade:server:tradeCanceled", function(data)
	local sender_id = data.sender
	local receiver_id = data.receiver

	if sender_id == source then 
		TriggerClientEvent('codem-trade:client:tradeCanceled', receiver_id)
	end
	if receiver_id == source then 
		TriggerClientEvent('codem-trade:client:tradeCanceled', sender_id)
	end
end)


