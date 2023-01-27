local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")

local idgens = Tools.newIDGenerator()

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")


src = {}
Tunnel.bindInterface("inventory",src)


Ammos = {}
Attachs = {}

local revistas = {}
local revistas_second = {}
local chestOpen = {}

function src.getmochila()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local rows = vRP.query("characters/getMochila",{ id = user_id })
        if rows[1].mochila > 0 then
           return true
        else
            return false
        end
    end
end

Citizen.CreateThread(function()
	Citizen.Wait(1000)
	Citizen.CreateThread(function()
		for _, player in ipairs(GetPlayers()) do
			local user_id = vRP.getUserId(player)	
			print(_)
			if user_id then
				Ammos[user_id] = vRP.userData(user_id,"Weapons")
			end
		end
	end)

	AddEventHandler(config.events.enter,function(user_id,source)
		Ammos[user_id] = vRP.userData(user_id,"Weapons")
	end)

	AddEventHandler(config.events.leave,function(user_id)
		if chestOpen[user_id] then
			for k,v in pairs(chestOpen[user_id]) do
				chestOpen[user_id][k] = nil
			end
		end

		if Ammos[user_id] then
			vRP.userData(user_id,"Weapons")
			
			Attachs[user_id] = nil
			Ammos[user_id] = nil
		end
		
		if revistas_second[user_id] then
			local nplayer = vRP.getUserSource(revistas_second[user_id])

			TriggerClientEvent(config.blockCommands,nplayer,false)
			
			vRPclient._stopAnim(nplayer,false)

			revistas[revistas_second[user_id]] = nil
			revistas_second[user_id] = nil
		end
		
	end)
end)

function debugMessage(message)
	if config.debugMode then
		print("[DEBUG]", message)
	end
end

function src.getPlayerInventory(id)
	return GetPlayerInventoryData(id)
end

function src.getSlots(id)
	return getSlots(id)
end

function src.getInvWeight(id)
	return getInventoryWeight(id)
end

function src.getUserByRegistration(plate)
	return GetUserByRegistration(plate)
end

function src.userId()
	local src = source
	local user_id = vRP.getUserId(source)
	return user_id
end

function src.darArma(arma, municao)
	if config.giveWeaponType == "1" then
		vRPclient.giveWeapons(source,{[arma] = { ammo = municao }})
	else
		vCLIENT.darArma(source, arma, municao)
	end
end

ChestList = {}

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end


RegisterNetEvent('alta-inv:Server:OpenInventory')
AddEventHandler('alta-inv:Server:OpenInventory',function(other,data,title)
    local src = source

	local source = source
	local user_id = vRP.getUserId(source)
	local items = vRP.getInventory(user_id)
    local slots = data ~= nil and data.slots ~= nil and data.slots or 54
    if other and ChestList[other] == nil then
		stashItems = GetChestItems(other)
        ChestList[other] = {
            id = other,
            items = stashItems,
            slots = slots
        }
    end
	for k,v in pairs(items) do
		print(v)
		if GetItemName(v.item) == "" or GetItemName(v.item) == nil then
			items[k] = nil
		else
			items[k].totalweight = vRP.itemWeightList(v.item)*v.amount
			items[k].itemName = GetItemName(v.item)
			items[k].type = vRP.itemTypeList(v.item)
		end
	end
	local peso = 0;local maxpeso = 0
	
	if title then
		if not other or not string.starts(other, "trunk") and not string.starts(other, "glovebox") then
			if string.starts(other, "chest:") and data.isHouse then
				for k,v in pairs(chestOpen) do
					for a, b in pairs(v) do
						if a == other then
							TriggerClientEvent("Notify",source,"negado","Esse baú já está sendo utilizado por alguém!")
							return
						end
					end
				end
				peso = getChestWeight("chest:"..title) 
				maxpeso = data.weight
				if not chestOpen[user_id] then chestOpen[user_id] = {} end
				chestOpen[user_id][other] = true
			else
				if vRP.hasPermission(user_id, config.chests.list[title].perm) then
					for k,v in pairs(chestOpen) do
						for a, b in pairs(v) do
							if a == other then
								TriggerClientEvent("Notify",source,"negado","Esse baú já está sendo utilizado por alguém!")
								return
							end
						end
					end
					peso = getChestWeight("chest:"..title) 
					maxpeso = config.chests.list[title].weight
					if not chestOpen[user_id] then chestOpen[user_id] = {} end
					chestOpen[user_id][other] = true
				else
					TriggerClientEvent("Notify",source,"negado","Sem permissão!")
					return
				end
			end
			
		else
			local vehicle,vehNet,vehPlate,vehName,vehLock,vehBlock,vehHealth = vRPclient.vehList(source,7)
			local chestName = vehName.."-"..GetUserByRegistration(vehPlate)
			if vehicle then
				for k,v in pairs(chestOpen) do
					for a, b in pairs(v) do
						if a == chestName then
							TriggerClientEvent("Notify",source,"negado","Esse porta-malas já está sendo utilizado por alguém!")
							return
						end
					end
				end
			end
			if string.starts(other, "trunk") then
				peso = getChestWeight("trunk:"..string.match(other, ":(.*)-").."-"..string.match(other, "-(.*)")) 
				maxpeso = GetTrunkChestSize(string.match(other, ":(.*)-"))
				if not chestOpen[user_id] then chestOpen[user_id] = {} end
				chestOpen[user_id][chestName] = true
				vCLIENT.openTrunk(source)
				print("abriu")
			else
				peso = getChestWeight("glovebox:"..string.match(other, ":(.*)-").."-"..string.match(other, "-(.*)")) 
				maxpeso = GetGloveBoxSize(string.match(other, ":(.*)-"))
				if not chestOpen[user_id] then chestOpen[user_id] = {} end
				chestOpen[user_id][chestName] = true
			end
		end
	end
	
    TriggerClientEvent('alta-inv:Client:OpenInventory',src,items,ChestList[other],title,peso,maxpeso)
end)

function src.removeChestOpen(chest)
	local source = source
	local user_id = vRP.getUserId(source)
	if chestOpen[user_id][chest] then
		chestOpen[user_id][chest] = nil
	end
end

function getCustomPlayerInventory(user_id)
	local items = vRP.getInventory(user_id)

	for k,v in pairs(items) do
		if GetItemName(v.item) == "" or GetItemName(v.item) == nil then
			items[k] = nil
		else
			items[k].totalweight = vRP.itemWeightList(v.item)*v.amount
			items[k].itemName = GetItemName(v.item)
			items[k].type = vRP.itemTypeList(v.item)
			items[k].slot = k
			items[k].label = v.item
			items[k].name = v.item
			items[k].image = v.item
			items[k].amount = v.amount
		end
	end
	
	return items
end

RegisterNetEvent('alta-inv:Server:openShop')
AddEventHandler('alta-inv:Server:openShop',function(other,id)
	local source = source
	if id then
		source = vRP.getUserSource(id)
	end
    if other then	 
		local itemsOther = {}
		
		local items = vRP.getInventory(vRP.getUserId(source))
        local id = 'Shop-'..other
		
		
			
		local i = 0
		for k,v in pairs(config.shops.list[other].list) do
			i = i + 1
			itemsOther[i] = {}
			itemsOther[i].totalweight = vRP.itemWeightList(k)*v
			itemsOther[i].itemName = GetItemName(k)
			itemsOther[i].type = vRP.itemTypeList(k)
			itemsOther[i].slot = i
			itemsOther[i].label = k
			itemsOther[i].name = k
			itemsOther[i].image = k
			itemsOther[i].item = k
			itemsOther[i].amount = v
			
		end
		
		for k,v in pairs(items) do
			if GetItemName(v.item) == "" or GetItemName(v.item) == nil then
				items[k] = nil
			else
				items[k].totalweight = vRP.itemWeightList(v.item)*v.amount
				items[k].itemName = GetItemName(v.item)
				items[k].type = vRP.itemTypeList(v.item)
				items[k].slot = k
				items[k].label = v.item
				items[k].name = v.item
				items[k].image = v.item
				items[k].amount = v.amount
			end
		end
		
		if other and ChestList[id] == nil then
			ChestList[id] = {
				id = id,
				items = itemsOther,
				slots = i
			}
		end
        TriggerClientEvent('alta-inv:Client:OpenInventory',source,items,ChestList[id],other,0,0)
    end
end)


RegisterNetEvent('alta-inv:Server:ClearWeapons')
AddEventHandler('alta-inv:Server:ClearWeapons',function(user_id)
	if Ammos[user_id] then
		for k,v in pairs(Ammos[user_id]) do
			Ammos[user_id][k] = nil
		end
	end
	
	if Attachs[user_id] then
		for k,v in pairs(Attachs[user_id]) do
			for a,b in pairs(v) do
				Attachs[user_id][k][a] = nil
			end
		end
	end
	TriggerClientEvent('inventory:clearWeapons',vRP.getUserSource(user_id))
	
	local items = vRP.getInventory(user_id)
    
	for a,b in pairs(config.weapons) do
		for k,v in pairs(items) do
			
			if weaponName(v.item) ~= nil then
				if string.lower(weaponName(v.item)) == string.lower(a) then
					vRP.tryGetInventoryItem(user_id, v.item, v.amount)
				end
			end
			if b.nomeMunicao then
				if v.item == b.nomeMunicao then
					vRP.tryGetInventoryItem(user_id, v.item, v.amount)
				end
			end
		end
	end
end)

RegisterNetEvent('alta-inv:Server:OpenPlayerInventory')
AddEventHandler('alta-inv:Server:OpenPlayerInventory',function(other,asrc)
	local source = source
	if asrc then
		source = vRP.getUserSource(asrc)
	end
    if other then 
		if Ammos[other] then
			for k,v in pairs(Ammos[other]) do
				vRP.giveInventoryItem(other, config.weapons[k]["nomeMunicao"], v)
				Ammos[other][k] = nil
			end
		end
		
		if Attachs[other] then
			for k,v in pairs(Attachs[other]) do
				for a,b in pairs(v) do
					vRP.giveInventoryItem(other, a, 1)
					Attachs[other][k][a] = nil
				end
			end
		end
		
		TriggerClientEvent('inventory:clearWeapons',vRP.getUserSource(other))
		
		local itemsOther = vRP.getInventory(other)
		
		local items = vRP.getInventory(vRP.getUserId(source))
        local id = 'Other-Player-'..other

		for k,v in pairs(itemsOther) do
			itemsOther[k].totalweight = vRP.itemWeightList(v.item)*v.amount
			itemsOther[k].itemName = GetItemName(v.item)
			itemsOther[k].type = vRP.itemTypeList(v.item)
			itemsOther[k].slot = k
			itemsOther[k].label = v.item
			itemsOther[k].name = v.item
			itemsOther[k].image = v.item
			itemsOther[k].amount = v.amount
		end
		
		for k,v in pairs(items) do
			if GetItemName(v.item) == "" or GetItemName(v.item) == nil then
				items[k] = nil
			else
				items[k].totalweight = vRP.itemWeightList(v.item)*v.amount
				items[k].itemName = GetItemName(v.item)
				items[k].type = vRP.itemTypeList(v.item)
				items[k].slot = k
				items[k].label = v.item
				items[k].name = v.item
				items[k].image = v.item
				items[k].amount = v.amount
			end
		end
		
		--[[if Ammos[other] then
			for k,v in pairs(Ammos[other]) do
				local initial = 0
				local slot = vRP.GetSlotByItem(itemsOther, config.weapons[k]["nomeMunicao"])
				if slot ~= nil then
					itemsOther[slot].amount = itemsOther[slot].amount + v
				else
					repeat
						initial = initial + 1
					until itemsOther[tostring(initial)] == nil	
					initial = tostring(initial)
					if v > 0 then
						itemsOther[initial] = {}
						itemsOther[initial].totalweight = vRP.itemWeightList(config.weapons[k]["nomeMunicao"])*v
						itemsOther[initial].itemName = GetItemName(config.weapons[k]["nomeMunicao"])
						itemsOther[initial].type = vRP.itemTypeList(config.weapons[k]["nomeMunicao"])
						itemsOther[initial].slot = initial
						itemsOther[initial].label = config.weapons[k]["nomeMunicao"]
						itemsOther[initial].name = config.weapons[k]["nomeMunicao"]
						itemsOther[initial].image = config.weapons[k]["nomeMunicao"]
						itemsOther[initial].amount = v
					end
				end
			end
		end]]
		

        local targetitems = {
            id = id,
            items = itemsOther,
            slots = getSlots(other)+12
        }
        TriggerClientEvent('alta-inv:Client:OpenInventory',source,items,targetitems,"REVISTANDO "..GetUserName(other),getInventoryWeight(other),GetPlayerBackpack(other))
		revistas[other] = true
		revistas_second[vRP.getUserId(source)] = other
		TriggerClientEvent('alta-inv:Client:CloseInventory',vRP.getUserSource(other))
    end
end)



function weaponName(weapon)
	for k,v in pairs(config.weapons) do
		if v.index == weapon then
			return k
		end
	end
	return nil
end


function itemAmmo(Item)
	if config.weapons[weaponName(Item)] then
		return config.weapons[weaponName(Item)]["nomeMunicao"]
	end
end


function weaponIndex(weapon)
	for k,v in pairs(config.weapons) do
		if k == weapon then
			return v.index
		end
	end
	return nil
end

RegisterNetEvent('alta-inv:Server:SetInventoryData')
AddEventHandler('alta-inv:Server:SetInventoryData',function(data)
    local src = source
	local user_id = vRP.getUserId(source)
	
    if data.frominventory and data.toinventory then
        if data.toinventory == 'player' and data.frominventory == 'player' then
            local fromitem = vRP.GetItemBySlot(user_id, data.fromslot)
            if fromitem then
                local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or fromitem.amount
                if tonumber(fromitem.amount) >= tonumber(amount) then
                    local toitem = vRP.GetItemBySlot(user_id, data.toslot)
					if toitem and toitem ~= nil and toitem.item == fromitem.item and IsItemUnique(toitem.item) then return end
                    vRP.tryGetInventoryItem(user_id, fromitem.item, amount, data.fromslot)
                    if toitem then
                        if toitem.item ~= fromitem.item then
                            vRP.tryGetInventoryItem(user_id, toitem.item, toitem.amount, data.toslot)
                            vRP.giveInventoryItem(user_id, toitem.item, toitem.amount, data.fromslot, toitem.info)
                        end
                    end
                    vRP.giveInventoryItem(user_id, fromitem.item, amount, data.toslot, fromitem.info)
					
					if data.toslot >= 7 and data.toslot <=12 then
						local returnWeapon = vCLIENT.returnWeapon(source)
						if returnWeapon and fromitem.item == weaponIndex(returnWeapon) then
							local weaponStatus,weaponAmmo,hashItem = vCLIENT.storeWeaponHands(source,weaponName(fromitem.item))
							if weaponStatus then
								local wHash = itemAmmo(weaponIndex(hashItem))
								if wHash ~= nil then
									Ammos[user_id][hashItem] = parseInt(weaponAmmo)
								end
								--TriggerClientEvent("itensNotify",source,{ "guardou",itemIndex(hashItem),1,itemName(hashItem) })
							end
						end
					end
					
					if data.toslot >= 13 then
						if Ammos[user_id][weaponName(fromitem.item)] then
							vRP.giveInventoryItem(user_id,itemAmmo(fromitem.item),Ammos[user_id][weaponName(fromitem.item)])
							Ammos[user_id][weaponName(fromitem.item)] = nil
							TriggerClientEvent('inventory:clearWeapons',src)
						end
					end
                end
            end 
            TriggerClientEvent('alta-inv:Client:RefreshInventory',src)
            debugMessage('player to player')
            return
        elseif data.toinventory ~= 'player' and data.frominventory == 'player' then 
            local fromitem = vRP.GetItemBySlot(user_id, data.fromslot)
            if fromitem then
				if weaponName(fromitem.item) ~= nil and config.weapons[weaponName(fromitem.item)]["perm"] ~= nil and not vRP.hasPermission(user_id, config.weapons[weaponName(fromitem.item)]["perm"]) then
					TriggerClientEvent("Notify",source,"negado","Sem permissão para manusear essa arma!")
					TriggerClientEvent('alta-inv:Client:CloseInventory',source)
					return
				end
                local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or fromitem.amount
                if tonumber(fromitem.amount) >= tonumber(amount) then
                    local toitem = ChestList[data.toinventory].items[data.toslot]
					if toitem and toitem ~= nil and toitem.item == fromitem.item and IsItemUnique(toitem.item) then return end
					
					local webhook = ""
					local action = ""
					
					if string.starts(data.toinventory, "trunk") then
						if getChestWeight("trunk:"..string.match(data.toinventory, ":(.*)-").."-"..string.match(data.toinventory, "-(.*)")) + (vRP.itemWeightList(fromitem.item) * amount) > GetTrunkChestSize(string.match(data.toinventory, ":(.*)-")) then
							return
						end
						webhook = config.webhooks.portamalas
						action = "GUARDOU ITEM NO PORTA-MALAS"
					else
						if string.starts(data.toinventory, "glovebox") then
							if getChestWeight("glovebox:"..string.match(data.toinventory, ":(.*)-").."-"..string.match(data.toinventory, "-(.*)")) + (vRP.itemWeightList(fromitem.item) * amount) > GetGloveBoxSize(string.match(data.toinventory, ":(.*)-")) then
								return
							end
							webhook = config.webhooks.portaluvas
							action = "GUARDOU ITEM NO PORTA-LUVAS"
						else
							
							if config.chests.list[string.match(data.toinventory, ":(.*)")] ~= nil then
								if getChestWeight(string.lower(data.toinventory)) + (vRP.itemWeightList(fromitem.item) * amount) > config.chests.list[string.match(data.toinventory, ":(.*)")].weight then
									return
								end
								webhook = config.chests.list[string.match(data.toinventory, ":(.*)")].webhook
							else
								if getChestWeight(string.lower(data.toinventory)) + (vRP.itemWeightList(fromitem.item) * amount) > data.maxweight then
									return
								end
								webhook = config.webhooks.baucasas
							end
							action = "GUARDOU ITEM NO BAÚ"
						end
					end
					
                    vRP.tryGetInventoryItem(user_id, fromitem.item,amount,data.fromslot)
                    if toitem then 
                        if toitem.name ~= fromitem.item then
                            vRP.giveInventoryItem(user_id, toitem.name,toitem.amount,fromitem.slot)
                            RemoveItemFromChest(data.toinventory,toitem.name,toitem.amount,toitem.slot)
                        end
                    end
                    AddItemToChest(data.toinventory,fromitem.item,amount,data.toslot,fromitem.info)
					if Attachs[user_id][weaponName(fromitem.item)] then
						for k, v in pairs(Attachs[user_id][weaponName(fromitem.item)]) do
							local free = GetFreeSlot(data.toinventory)
							if free ~= nil then
								AddItemToChest(data.toinventory,k,1,free,fromitem.info)
								Attachs[user_id][weaponName(fromitem.item)][k] = nil
								TriggerClientEvent('inventory:clearWeapons',src)
							end
						end
					end
					if Ammos[user_id][weaponName(fromitem.item)] then
						local free = GetFreeSlot(data.toinventory)
						if free ~= nil then
							AddItemToChest(data.toinventory,itemAmmo(fromitem.item),Ammos[user_id][weaponName(fromitem.item)],free,fromitem.info)
							Ammos[user_id][weaponName(fromitem.item)] = nil
							TriggerClientEvent('inventory:clearWeapons',src)
						end
					end
					discordLog(user_id, action, fromitem.item, amount, webhook, data.toinventory)
                end
            end
			if not string.starts(data.toinventory, "trunk") and not string.starts(data.toinventory, "glovebox") then
				if config.chests.list[string.match(data.toinventory, ":(.*)")] ~= nil then
					TriggerClientEvent('alta-inv:Client:RefreshInventory',src,ChestList[data.toinventory],string.match(data.toinventory, ":(.*)"),getChestWeight(string.lower(data.toinventory)),config.chests.list[string.match(data.toinventory, ":(.*)")].weight)
				else
					TriggerClientEvent('alta-inv:Client:RefreshInventory',src,ChestList[data.toinventory],string.match(data.toinventory, ":(.*)"),getChestWeight(string.lower(data.toinventory)),data.maxweight)
				end
			else
				if string.starts(data.toinventory, "glovebox") then
					TriggerClientEvent('alta-inv:Client:RefreshInventory',src,ChestList[data.toinventory],"PORTA-LUVAS",getChestWeight("glovebox:"..string.match(data.toinventory, ":(.*)-").."-"..string.match(data.toinventory, "-(.*)")),GetGloveBoxSize(string.match(data.toinventory, ":(.*)-")))
				else
					TriggerClientEvent('alta-inv:Client:RefreshInventory',src,ChestList[data.toinventory],"PORTA-MALAS",getChestWeight("trunk:"..string.match(data.toinventory, ":(.*)-").."-"..string.match(data.toinventory, "-(.*)")),GetTrunkChestSize(string.match(data.toinventory, ":(.*)-")))
				end
			end
			debugMessage('player to stash')
            return
        elseif data.frominventory ~= 'player' and data.toinventory == 'player' then
            local fromitem = ChestList[data.frominventory].items[data.fromslot]
			local transferiu = false
			local webhook = ""
			local action = ""
			local item = ""
			local qtd = ""
			
            if fromitem then
				if weaponName(fromitem.name) ~= nil and config.weapons[weaponName(fromitem.name)]["perm"] ~= nil and not vRP.hasPermission(user_id, config.weapons[weaponName(fromitem.name)]["perm"]) then
					TriggerClientEvent("Notify",source,"negado","Sem permissão para manusear essa arma!")
					TriggerClientEvent('alta-inv:Client:CloseInventory',source)
					return
				end
                local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or fromitem.amount
                if tonumber(fromitem.amount) >= tonumber(amount) then
                    if(CanCarryItem(src,fromitem.name,amount)) then
                        local toitem = vRP.GetItemBySlot(user_id, data.toslot)
						
						if toitem and toitem ~= nil and toitem.item == fromitem.item and IsItemUnique(toitem.item) then return end
						
                        RemoveItemFromChest(data.frominventory,fromitem.name,amount,fromitem.slot)
                        if toitem then
                            if toitem.item ~= fromitem.name then
                                vRP.tryGetInventoryItem(user_id, toitem.item,toitem.amount,toitem.slot)
                                AddItemToChest(data.frominventory,toitem.item,toitem.amount,fromitem.slot,toitem.info)
                            end
                        end
                        vRP.giveInventoryItem(user_id, fromitem.name,amount,data.toslot)
						transferiu = true
						item = fromitem.name
						qtd = amount
                    end
                end
            end
			if not string.starts(data.frominventory, "trunk") and not string.starts(data.frominventory, "glovebox") then
				if config.chests.list[string.match(data.frominventory, ":(.*)")] ~= nil then
					TriggerClientEvent('alta-inv:Client:RefreshInventory',src,ChestList[data.frominventory],string.match(data.frominventory, ":(.*)"),getChestWeight(string.lower(data.frominventory)),config.chests.list[string.match(data.frominventory, ":(.*)")].weight)
					webhook = config.chests.list[string.match(data.frominventory, ":(.*)")].webhook
				else
					TriggerClientEvent('alta-inv:Client:RefreshInventory',src,ChestList[data.frominventory],string.match(data.frominventory, ":(.*)"),getChestWeight(string.lower(data.frominventory)),data.maxweight)
					webhook = config.webhooks.baucasas
				end
				
				action = "REMOVEU ITEM DO BAÚ"
			else
				if string.starts(data.frominventory, "glovebox") then
					webhook = config.webhooks.portaluvas
					action = "REMOVEU ITEM DO PORTA-LUVAS"
					TriggerClientEvent('alta-inv:Client:RefreshInventory',src,ChestList[data.frominventory],"PORTA-LUVAS",getChestWeight("glovebox:"..string.match(data.frominventory, ":(.*)-").."-"..string.match(data.frominventory, "-(.*)")),GetGloveBoxSize(string.match(data.frominventory, ":(.*)-")))
				else
					webhook = config.webhooks.portamalas
					action = "REMOVEU ITEM DO PORTA-MALAS"
					TriggerClientEvent('alta-inv:Client:RefreshInventory',src,ChestList[data.frominventory],"PORTA-MALAS",getChestWeight("trunk:"..string.match(data.frominventory, ":(.*)-").."-"..string.match(data.frominventory, "-(.*)")),GetTrunkChestSize(string.match(data.frominventory, ":(.*)-")))
				end	
			end
			if transferiu then
				discordLog(user_id, action, item, qtd, webhook, data.frominventory)
			end
			debugMessage('stash to player')
            return
        elseif data.frominventory ~= 'player' and data.toinventory ~= 'player' then
            local fromitem = ChestList[data.frominventory].items[data.fromslot]
            if fromitem then 
                local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or fromitem.amount
                if tonumber(fromitem.amount) >= tonumber(amount) then
			
					local toitem = ChestList[data.frominventory].items[data.toslot]
					
					if toitem and toitem ~= nil and toitem.item == fromitem.item and IsItemUnique(toitem.item) then return end
					
					RemoveItemFromChest(data.frominventory,fromitem.name,amount,fromitem.slot)
                    if toitem then
                        if toitem.name ~= fromitem.name then	
							qtd = toitem.amount
							RemoveItemFromChest(data.frominventory,toitem.name, toitem.amount, toitem.slot)
							AddItemToChest(data.frominventory,toitem.name, qtd, fromitem.slot,toitem.info)
                        end
                    end
                    AddItemToChest(data.frominventory,fromitem.name,amount,data.toslot,fromitem.info)
                end
            end
            TriggerClientEvent('alta-inv:Client:RefreshInventory',src,ChestList[data.frominventory])
            debugMessage('stash to stash')
            return 
        end
    end
end)

RegisterNetEvent('alta-inv:Server:SetInventoryData:B/WPlayers')
AddEventHandler('alta-inv:Server:SetInventoryData:B/WPlayers',function(data)
    if not data.frominventory or not data.toinventory then return end
    local src = source
	local user_id = vRP.getUserId(source)

    local Target = GetNumberFromString(data.frominventory) ~= nil and GetNumberFromString(data.frominventory) or GetNumberFromString(data.toinventory) ~= nil and GetNumberFromString(data.toinventory)
	
    local TargetPlayer = vRP.getUserSource(Target)
    if not TargetPlayer then return end
    if data.frominventory == 'player' and data.toinventory ~= 'player' then 
        local fromitem = vRP.GetItemBySlot(user_id, data.fromslot)
        if fromitem then
			if data.fromslot <= 12 then 	
				TriggerClientEvent("Notify",source,"negado","Você não pode mover itens do bolso ou hotbar para outro player!")
				return
			end
            local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or fromitem.amount
            if tonumber(fromitem.amount) >= tonumber(amount) then
                local toitem = vRP.GetItemBySlot(Target, data.toslot)
				
				if toitem and toitem ~= nil and toitem.item == fromitem.item and IsItemUnique(toitem.item) then return end

				vRP.tryGetInventoryItem(user_id, fromitem.item, amount, data.fromslot)
                if toitem then
                    if toitem.item ~= fromitem.item then
						vRP.tryGetInventoryItem(Target, toitem.item, toitem.amount, data.toslot)
						vRP.giveInventoryItem(user_id, toitem.item, toitem.amount, data.fromslot, toitem.info)
                    end
                end
				vRP.giveInventoryItem(Target, fromitem.item, amount, data.toslot, fromitem.info)
				
				discordLog(user_id, "PEGOU ITEM DO PLAYER "..Target, fromitem.item, amount, config.webhooks.revistar)
            end
        end 
        debugMessage('Player to OtherPlayer')
        TriggerClientEvent('alta-inv:Client:RefreshInventory',src,{id = data.toinventory,items = getCustomPlayerInventory(Target),slots = getSlots(Target)+12},"REVISTANDO "..GetUserName(Target),getInventoryWeight(Target),GetPlayerBackpack(Target))
    elseif data.frominventory ~= 'player' and data.toinventory == 'player' then 
        local fromitem = vRP.GetItemBySlot(Target, data.fromslot)
        if fromitem then
            local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or fromitem.amount
            if tonumber(fromitem.amount) >= tonumber(amount) then
                local toitem = vRP.GetItemBySlot(user_id, data.toslot)
				
				if toitem and toitem ~= nil and toitem.item == fromitem.item and IsItemUnique(toitem.item) then return end
				
				vRP.tryGetInventoryItem(Target, fromitem.item, amount, data.fromslot)
                if toitem then
                    if toitem.item ~= fromitem.item then
						vRP.tryGetInventoryItem(user_id, toitem.item, toitem.amount, data.toslot)
						vRP.giveInventoryItem(Target, toitem.item, toitem.amount, data.fromslot, toitem.info)
                    end
                end
				vRP.giveInventoryItem(user_id, fromitem.item, amount, data.toslot, fromitem.info)
				
				discordLog(user_id, "PASSOU ITEM PRO PLAYER "..Target, fromitem.item, amount, config.webhooks.revistar)
            end
        end 
        debugMessage('OtherPlayer to Player')
		
		--TriggerClientEvent('alta-inv:Client:RefreshInventory',src,ChestList[data.toinventory],string.match(data.toinventory, ":(.*)"),getChestWeight(string.lower(data.toinventory)),config.chests.list[string.match(data.toinventory, ":(.*)")].weight)
		
        TriggerClientEvent('alta-inv:Client:RefreshInventory',src,{id = data.frominventory,items = getCustomPlayerInventory(Target),slots = getSlots(Target)+12},"REVISTANDO "..GetUserName(Target),getInventoryWeight(Target),GetPlayerBackpack(Target))
    elseif data.frominventory ~= 'player' and data.toinventory ~= 'player' then 
        local fromitem = vRP.GetItemBySlot(Target, data.fromslot)
        if fromitem then
            local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or fromitem.amount
            if tonumber(fromitem.amount) >= tonumber(amount) then
                local toitem = vRP.GetItemBySlot(Target, data.toslot)
				
				if toitem and toitem ~= nil and toitem.item == fromitem.item and IsItemUnique(toitem.item) then return end
				
				vRP.tryGetInventoryItem(Target, fromitem.item, amount, data.fromslot)
                if toitem then
                    if toitem.item ~= fromitem.item then
						vRP.tryGetInventoryItem(Target, toitem.item, toitem.amount, data.toslot)
						vRP.giveInventoryItem(Target, toitem.item, toitem.amount, data.fromslot, toitem.info)
                    end
                end
				vRP.giveInventoryItem(Target, fromitem.item, amount, data.toslot, fromitem.info)
            end
        end 
        debugMessage('Other-Inv to Other-Inv')
		
        TriggerClientEvent('alta-inv:Client:RefreshInventory',src,{id = data.frominventory,items = getCustomPlayerInventory(Target),slots = getSlots(Target)+12},"REVISTANDO "..GetUserName(Target),getInventoryWeight(Target),GetPlayerBackpack(Target))
    end
end)

RegisterNetEvent('alta-inv:Server:TryBuySell')
AddEventHandler('alta-inv:Server:TryBuySell',function(data)
    if not data.frominventory or not data.toinventory then return end
    local src = source
	local user_id = vRP.getUserId(source)

    if data.frominventory ~= 'player' and data.toinventory == 'player' then 
		if string.lower(config.shops.list[string.gsub(data.frominventory, "Shop--", "")]["mode"]) == "buy" or string.lower(config.shops.list[string.gsub(data.frominventory, "Shop--", "")]["mode"]) == "both" then
			local fromitem = ChestList[data.frominventory].items[data.fromslot]
			local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or 1
			if fromitem then
				if(CanCarryItem(src,fromitem.item,amount)) then
					if config.shops.list[string.gsub(data.frominventory, "Shop--", "")]["perm"] ~= nil then
						if not vRP.hasPermission(user_id,config.shops.list[string.gsub(data.frominventory, "Shop--", "")]["perm"]) then
							TriggerClientEvent("Notify",source,"negado","Sem permissão!")
							return false
						end
					end
					local payItem = config.shops.list[string.gsub(data.frominventory, "Shop--", "")]["payment"]["item"]
					if (payItem ~= "internalcash" and vRP.tryGetInventoryItem(user_id, payItem, fromitem.amount * amount)) or (payItem == "internalcash" and vRP.tryPayment(user_id, fromitem.amount * amount)) then
						vRP.giveInventoryItem(user_id, fromitem.item, amount)
						discordLog(user_id, "COMPROU ITEM DA "..string.upper(string.gsub(data.frominventory, "Shop--", "")), fromitem.item, amount, config.shops.list[string.gsub(data.frominventory, "Shop--", "")]["webhook"])
					else
						TriggerClientEvent("Notify",source,"negado","Dinheiro insuficiente!")
						TriggerClientEvent('alta-inv:Client:CloseInventory',source)
					end	
				else
					TriggerClientEvent("Notify",source,"negado","Você não possui espaço no inventário!")
					TriggerClientEvent('alta-inv:Client:CloseInventory',source)
				end
			end 
			debugMessage('Shop to Player')
			
			TriggerClientEvent('alta-inv:Client:RefreshInventory',src,ChestList[data.frominventory],string.gsub(data.frominventory, "Shop--", ""),0,0)
        end
    elseif data.frominventory == 'player' and data.toinventory ~= 'player' then
		if string.lower(config.shops.list[string.gsub(data.toinventory, "Shop--", "")]["mode"]) == "sell" or string.lower(config.shops.list[string.gsub(data.toinventory, "Shop--", "")]["mode"]) == "both" then
			local fromitem = vRP.GetItemBySlot(user_id, data.fromslot)
			
			if fromitem then
			
				if data.fromslot <= 12 then 	
					TriggerClientEvent("Notify",source,"negado","Você não pode vender itens do bolso ou hotbar!")
					TriggerClientEvent('alta-inv:Client:CloseInventory',source)
					return
				end
				local amount = (data.amount ~= nil and data.amount ~= 0) and data.amount or 1
				if tonumber(fromitem.amount) >= tonumber(amount) then
					if config.shops.list[string.gsub(data.toinventory, "Shop--", "")]["perm"] ~= nil then
						if not vRP.hasPermission(user_id,config.shops.list[string.gsub(data.toinventory, "Shop--", "")]["perm"]) then
							TriggerClientEvent("Notify",source,"negado","Sem permissão!")
							return false
						end
					end
					if config.shops.list[string.gsub(data.toinventory, "Shop--", "")]["list"][fromitem.item] ~= nil then
						if vRP.tryGetInventoryItem(user_id, fromitem.item, amount) then
							vRP.giveInventoryItem(user_id, config.shops.list[string.gsub(data.toinventory, "Shop--", "")]["payment"]["item"], (amount * tonumber(config.shops.list[string.gsub(data.toinventory, "Shop--", "")]["list"][fromitem.item])) * config.shops.list[string.gsub(data.toinventory, "Shop--", "")]["payment"]["tax"])
							discordLog(user_id, "VENDEU ITEM NA "..string.upper(string.gsub(data.toinventory, "Shop--", "")), fromitem.item, amount, config.shops.list[string.gsub(data.toinventory, "Shop--", "")]["webhook"])
						end
					end
				end
			end 
			
			TriggerClientEvent('alta-inv:Client:RefreshInventory',src,ChestList[data.toinventory],string.gsub(data.toinventory, "Shop--", ""),0,0)
			debugMessage('Player to Shop')
		end
	end
end)


RegisterServerEvent("alta-inv:Server:UseItem")
AddEventHandler('alta-inv:Server:UseItem', function(data)
	local src = source
	
	local user_id = vRP.getUserId(src)
	if data.inventory == "player" then
		local itemdata = vRP.GetItemBySlot(user_id, data.item)
		if itemdata ~= nil then
			if vRP.itemTypeList(itemdata.item) == "use" then
				func.useItem(itemdata.item, data.qtd)
				TriggerClientEvent('alta-inv:Client:RefreshInventory',src)
			elseif vRP.itemTypeList(itemdata.item) == "ammo" then
				local returnWeapon,weaponHash,weaponAmmo = vCLIENT.rechargeCheck(src,itemdata.item)
				if returnWeapon then
					if config.weapons[weaponHash]["perm"] ~= nil and not vRP.hasPermission(user_id, config.weapons[weaponHash]["perm"]) then
						TriggerClientEvent("Notify",source,"negado","Sem permissão para recarregar essa arma!")
						TriggerClientEvent('alta-inv:Client:CloseInventory',source)
						return
					end
					if nameItem ~= itemAmmo(weaponHash) then return end
					if data.qtd == nil then data.qtd = vRP.getInventoryItemAmount(user_id,itemdata.item) end
					if data.qtd + weaponAmmo > 250 then data.qtd = 250 - weaponAmmo end

					if vRP.tryGetInventoryItem(user_id,itemdata.item,data.qtd) then
						Ammos[user_id][weaponHash] = parseInt(weaponAmmo) + data.qtd
						--TriggerClientEvent("itensNotify",source,{ "equipou",itemIndex(totalName),Amount,itemName(totalName) })
						vCLIENT.rechargeWeapon(source,weaponHash,Ammos[user_id][weaponHash])
						TriggerClientEvent('alta-inv:Client:RefreshInventory',src)
						NotifyItem(user_id, "RECARREGOU", weaponIndex(weaponHash),data.qtd)
						
					end		
				else
					TriggerClientEvent("Notify",source,"negado","Você não possui uma arma equipada!")
					TriggerClientEvent('alta-inv:Client:CloseInventory',source)
				end
			end
            if config.itemList[itemdata.item]['shouldClose'] then 
                TriggerClientEvent('alta-inv:Client:CloseInventory',src)
            end
		end
	end
end)

function src.dropWeapons(Item)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local consultItem = vRP.getInventoryItemAmount(user_id,weaponIndex(Item))
		if consultItem <= 0 then
			return true
		end
	end

	return false
end

function src.updateAmmo(gun, amount)
	local source = source
	local user_id = vRP.getUserId(source)
	if Ammos[user_id][gun] then
		Ammos[user_id][gun] = amount
	end
end

function src.preventWeapon(Item,Ammo)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local wHash = itemAmmo(weaponIndex(Item))

		if wHash ~= nil then
			if Ammos[user_id][wHash] then
				if Ammo > 0 then
					Ammos[user_id][wHash] = Ammo
				else
					Ammos[user_id][wHash] = nil
				end
			end
		end
	end
end

RegisterServerEvent("alta-inv:Server:UseItemSlot")
AddEventHandler('alta-inv:Server:UseItemSlot', function(slot)
	local src = source
	
	local user_id = vRP.getUserId(src)
	local itemdata = vRP.GetItemBySlot(user_id, slot)
	if itemdata ~= nil then
		if vRP.itemTypeList(itemdata.item) == "use" then
			func.useItem(itemdata.item, 1)
		elseif vRP.itemTypeList(itemdata.item) == "weapon" then
			local returnWeapon = vCLIENT.returnWeapon(src)
			if returnWeapon then
				if config.weapons[weaponName(itemdata.item)]["perm"] == nil or vRP.hasPermission(user_id, config.weapons[weaponName(itemdata.item)]["perm"]) then
					local weaponStatus,weaponAmmo,hashItem = vCLIENT.storeWeaponHands(src)
					if weaponStatus then
						if config.weapons[weaponName(itemdata.item)]["nomeMunicao"] ~= nil then
							local wHash = itemAmmo(weaponIndex(hashItem))
							if wHash ~= nil then
								Ammos[user_id][hashItem] = parseInt(weaponAmmo)
								NotifyItem(user_id, "GUARDOU", weaponIndex(hashItem),1)
							end
						end
					end
				else
					TriggerClientEvent("Notify",src,"negado","Sem permissão para manusear essa arma!")
				end
			else
				if weaponName(itemdata.item) ~= nil and config.weapons[weaponName(itemdata.item)]["perm"] == nil or vRP.hasPermission(user_id, config.weapons[weaponName(itemdata.item)]["perm"]) then
					if config.weapons[weaponName(itemdata.item)]["nomeMunicao"] ~= nil then
						local wHash = itemAmmo(itemdata.item)
						if wHash ~= nil then
							if Ammos[user_id][weaponName(itemdata.item)] == nil then
								Ammos[user_id][weaponName(itemdata.item)] = 0
							end
						end
					end
					if vCLIENT.putWeaponHands(src,weaponName(itemdata.item),Ammos[user_id][weaponName(itemdata.item)] or 0 or nil) then
						NotifyItem(user_id, "EQUIPOU", itemdata.item,1)
					end
				else
					TriggerClientEvent("Notify",src,"negado","Sem permissão para manusear essa arma!")
				end
			end
		end
	end
end)


RegisterNetEvent('alta-inv:Server:CraftItem')
AddEventHandler('alta-inv:Server:CraftItem',function(data)
    local source = source 
    local user_id = vRP.getUserId(source)
    local retval = true
	local temperm = true
    if data then 
        if data.item and data.recipe then 
            for k,v in pairs(data.recipe) do
				if not v.perm then
					if vRP.getInventoryItemAmount(user_id,v.name) < v.amount then
						retval = false 
					end
				else
					if not vRP.hasPermission(user_id, v.perm) then
						temperm = false
					end
				end
            end
        end
    end
    if retval and data.item then
		if not temperm then
			TriggerClientEvent("Notify",source,"negado","Você não possui permissão para craftar isso!")
		else
			for k,v in pairs(data.recipe) do vRP.tryGetInventoryItem(user_id, v.name,v.amount) end
			vRP.giveInventoryItem(user_id, data.item,1)
			NotifyItem(user_id, "PRODUZIU", data.item,1)
			TriggerClientEvent("Notify",source,"sucesso","Item produzido!")
		end
    else
		TriggerClientEvent("Notify",source,"negado","Você não possui materiais para produzir esse item!")
	end
	TriggerClientEvent('alta-inv:Client:CloseInventory',source)
end)

function src.stopRevista()
	local source = source
	if revistas_second[vRP.getUserId(source)] ~= nil and revistas[revistas_second[vRP.getUserId(source)]] == true then
		local nplayer = vRP.getUserSource(revistas_second[vRP.getUserId(source)])
		vRPclient._stopAnim(nplayer,false)
		TriggerClientEvent(config.blockCommands,source,false)
		TriggerClientEvent(config.blockCommands,nplayer,false)
		if config.revistar.enableCarry then
			TriggerClientEvent('carregar',nplayer,source)
		end
		revistas[revistas_second[vRP.getUserId(source)]] = nil
		revistas_second[vRP.getUserId(source)] = nil
	end
end

function src.checkRevista()
	local source = source
	return revistas[vRP.getUserId(source)]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------

function src.reloadAmmos()
	local source = source
	local user_id = vRP.getUserId(source)	
	Ammos[user_id] = json.decode(vRP.userData(user_id,"Weapons")) or {}
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- DROPS
-----------------------------------------------------------------------------------------------------------------------------------------

Drops = {}
IDs = {}

RegisterNetEvent('alta-inv:SendItem')
AddEventHandler('alta-inv:SendItem',function(data)
    local source = source
    local user_id = vRP.getUserId(source)
    if data then
		if tonumber(data.item) >= 13 then
			if data.inventory == 'player' then 
				local item = vRP.GetItemBySlot(user_id, data.item)
				if not data.qtd then data.qtd = item.amount end
				local nplayer = GetNearestPlayer(source)
				local nuser_id = vRP.getUserId(nplayer)
				
				if nplayer then
					if CanCarryItem(nplayer,item.item,data.qtd) then
						if vRP.tryGetInventoryItem(user_id,item.item,data.qtd,item.slot) then
							TriggerClientEvent('alta-inv:Client:CloseInventory',source)
							
							if config.base == "vrpex" then
								vRPclient._playAnim(source,true,{{"mp_common","givetake1_a"}},false)
								vRPclient._playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)
							else
								vRPclient._playAnim(source,true,{"mp_common","givetake1_a"},false)
								vRPclient._playAnim(nplayer,true,{"mp_common","givetake1_a"},false)
							end

							Citizen.Wait(750)

							vRP.giveInventoryItem(nuser_id, item.item,data.qtd)
							
							TriggerClientEvent('alta-inv:Client:RefreshInventory',nplayer)
							
							NotifyItem(user_id, "ENVIOU", item.item,data.qtd)
							NotifyItem(nuser_id, "RECEBEU", item.item,data.qtd)
						end
					else
						TriggerClientEvent("Notify",source,"negado","Mochila cheia.")
					end
				end
			end
		else
			TriggerClientEvent("Notify",source,"negado","Você não pode enviar um item do bolso ou hotbar!")
			TriggerClientEvent('alta-inv:Client:CloseInventory',source)
		end
    end
end)

RegisterNetEvent('alta-inv:DropItem')
AddEventHandler('alta-inv:DropItem',function(data)
    local src = source
    local user_id = vRP.getUserId(source)
    if data then
		if tonumber(data.item) >= 13 then
			if data.inventory == 'player' then 
				local item = vRP.GetItemBySlot(user_id, data.item)
				if not data.qtd then data.qtd = item.amount end
				if vRP.tryGetInventoryItem(user_id, item.item,data.qtd,item.slot) then
					local id = idgens:gen()
					if item then
						Drops[id] = {
							coords = GetEntityCoords(GetPlayerPed(source)),
							item = item.item,
							amount = data.qtd,
							info = item.info
						}
						TriggerClientEvent('alta-inv:GetDrop',-1,Drops)
						TriggerClientEvent('alta-inv:Client:RefreshInventory',src)
						if config.base == "vrpex" then
							vRPclient._playAnim(source,true,{{"pickup_object","pickup_low"}},false)
						else
							vRPclient._playAnim(source,true,{"pickup_object","pickup_low"},false)
						end
						
						NotifyItem(user_id, "DROPOU", item.item,data.qtd)
						discordLog(user_id, "DROPOU ITEM NO CHÃO", item.item,data.qtd, config.webhooks.dropItem, GetEntityCoords(GetPlayerPed(source)))
					end
				end
			end
		else
			TriggerClientEvent("Notify",source,"negado","Você não pode dropar um item do bolso ou hotbar!")
			TriggerClientEvent('alta-inv:Client:CloseInventory',source)
		end
    end
end)

RegisterNetEvent('alta-inv:RemoveDrop')
AddEventHandler('alta-inv:RemoveDrop',function(id)
    local src = source
	local user_id = vRP.getUserId(source)
	
    if Drops[id] then 
        local item = Drops[id]
		if CanCarryItem(src,item.item,item.amount) then
			vRP.giveInventoryItem(user_id, item.item,item.amount)
			Drops[id] = nil
			idgens:free(id)
			TriggerClientEvent('alta-inv:Client:RefreshInventory',src)
			NotifyItem(user_id, "PEGOU", item.item,item.amount)
			discordLog(user_id, "PEGOU ITEM DO CHÃO", item.item,item.amount, config.webhooks.pickupItem, GetEntityCoords(GetPlayerPed(source)))
		end
    end
    TriggerClientEvent('alta-inv:GetDrop',-1,Drops)
end)

src.GetDrops = function()
    return Drops
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ROUPAS
-----------------------------------------------------------------------------------------------------------------------------------------

local savecloths = {}

RegisterCommand('clothupdate',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local data = vRP.getUserDataTable(user_id)
	local index = nil
	
	TriggerClientEvent('alta-inv:Client:CloseInventory',source)
	
	if not savecloths[user_id] then savecloths[user_id] = {} end
	
	if args[1] == "hat" then
		index = "p0"
	elseif args[1] == "mask" then
		index = 1
	elseif args[1] == "glasses" then
		index = "p1"
	elseif args[1] == "shirt" then
		index = 11
	elseif args[1] == "vest" then
		index = 9
	elseif args[1] == "top" then
		index = 8
	elseif args[1] == "pants" then
		index = 4
	elseif args[1] == "shoes" then
		index = 6
	elseif args[1] == "acessories" then
		index = 7
	elseif args[1] == "watches" then
		index = "p6"
	elseif args[1] == "hands" then
		index = 3
	elseif args[1] == "earring" then
		index = "p2"
	end
	
	local numero,cor = vCLIENT.getDrawables(source, index)
	if config.customizationPath == 1 then
		if defaults[data.customization.modelhash][index][3] ~= nil and defaults[data.customization.modelhash][index][3] ~= "" and vRP.getInventoryItemAmount(user_id,defaults[data.customization.modelhash][index][3]) < 1 then
			TriggerClientEvent("Notify",source,"negado","Você precisa do item "..GetItemName(defaults[data.customization.modelhash][index][3]).." para fazer isso!")
			return
		end
		if numero == defaults[data.customization.modelhash][index][1] and cor == defaults[data.customization.modelhash][index][2] then
			if savecloths[user_id][index] and savecloths[user_id][index] ~= nil then
				TriggerClientEvent("updatecloth",source,index,savecloths[user_id][index][1],savecloths[user_id][index][2])
			else
				TriggerClientEvent("Notify",source,"negado","Nenhuma roupa antiga encontrada.")
			end
		else
			savecloths[user_id][index] = {numero, cor}
			TriggerClientEvent("updatecloth",source,index,defaults[data.customization.modelhash][index][1],defaults[data.customization.modelhash][index][2])
		end
	else
		if defaults[data.skin][index][3] ~= nil and defaults[data.skin][index][3] ~= "" and vRP.getInventoryItemAmount(user_id,defaults[data.skin][index][3]) < 1 then
			TriggerClientEvent("Notify",source,"negado","Você precisa do item "..GetItemName(defaults[data.skin][index][3]).." para fazer isso!")
			return
		end
		if numero == defaults[data.skin][index][1] and cor == defaults[data.skin][index][2] then
			if savecloths[user_id][index] and savecloths[user_id][index] ~= nil then
				TriggerClientEvent("updatecloth",source,index,savecloths[user_id][index][1],savecloths[user_id][index][2])
			else
				TriggerClientEvent("Notify",source,"negado","Nenhuma roupa antiga encontrada.")
			end
		else
			savecloths[user_id][index] = {numero, cor}
			TriggerClientEvent("updatecloth",source,index,defaults[data.skin][index][1],defaults[data.skin][index][2])
		end
	end
end)


function discordLog(user, action, item, amount, hook, chest, alvo)
	if hook ~= nil and hook ~= "" then
		local autor = "#"..user.." "..GetUserName(user)
		
		
		local texto = "```"..action.."``` ```ini\n[USUÁRIO]: " ..autor.."\n"
		
		if alvo and alvo ~= nil then
			texto = texto.. "[ALVO]: " .. "#"..user.." ".. GetUserName(alvo) .. "\n"
		end
		
		if item and amount then
			texto = texto.."[ITEM]: "..amount.."x " .. item.. "\n"
		end
		if chest and chest ~= nil then
			if string.starts(chest, "vector3") then
				texto = texto.."[LOCAL]: " .. chest.. "\n"
			else
				texto = texto.."[BAÚ]: " .. chest.. "\n"
			end
		end
		texto = texto.."```"
		
		PerformHttpRequest(hook, function(err, text, headers) end, "POST", json.encode( { 
					username = "Player",
					embeds = {
						{
							["color"] = 2123412,
							["author"] = {
								["name"] = "🌐 REGISTRO DE AÇÃO INVENTÁRIO 🌐",
								["icon_url"] = ""
							},
							["description"] = "\n"..texto,
							["footer"] = {
								["text"] = "© ld_inventory - RebornShop [" .. os.date("%x %X]"),
								["icon_url"] = ""
							}
						}
					},
					avatar_url = ""
				}
			),
			{
				["Content-Type"] = "application/json"
			}
		)
	end
end