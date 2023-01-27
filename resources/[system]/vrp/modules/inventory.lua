-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("vrp","lib/Proxy")
local items = Proxy.getInterface("vrp_inventory_items")

local actived = {}
local srvData = {}
local selfReturn = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMDEFINITION
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getItemDefinition(item)
	if items.getItemList()[item] then
		return vRP.itemNameList(item),vRP.itemWeightList(item)
	end
	return nil,nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMNAMELIST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.itemNameList(item)
	if items.getItemList()[item] ~= nil then
		return items.getItemList()[item].name
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMAMMOLIST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.itemAmmoList(item)
	if items.getItemList()[item] then
		return items.getItemList()[item].ammo
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMTYPELIST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.itemTypeList(item)
	if items.getItemList()[item] ~= nil then
		return items.getItemList()[item].type
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMBODYLIST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.itemBodyList(item)
	if items.getItemList()[item] ~= nil then
		return items.getItemList()[item]
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMINDEXLIST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.itemIndexList(item)
	if items.getItemList()[item] ~= nil then
		return items.getItemList()[item].index
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMWEIGHTLIST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.itemWeightList(item)
	if items.getItemList()[item] then
		return items.getItemList()[item].weight
	end
	return 0
end

vRP.getItemWeight = vRP.itemWeightList
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETITEMBYSLOT AND GETSLOTBYITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GetItemBySlot(user_id,slot)
	local data = vRP.getInventory(user_id)
	if data then
		if slot then
			local slot  = tostring(slot)

			if data[slot] then
				return data[slot]
			end
		end
	end

	return nil
end

function vRP.GetSlotByItem(inv,item)
	local data = inv
	if data then
		if item then
			local item  = tostring(item)
			for k,v in pairs(data) do
				if v.item == item then
					return k
				end
			end
		end
	end

	return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETBACKPACK	
-----------------------------------------------------------------------------------------------------------------------------------------	
function vRP.getBackpack(user_id)
	local dataTable = vRP.getDatatable(user_id)
	if dataTable then
		return dataTable["backpack"]
	end

	return 0
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- SETBACKPACK	
-----------------------------------------------------------------------------------------------------------------------------------------	
function vRP.setBackpack(user_id)
	local dataTable = vRP.getDatatable(user_id)
	if dataTable then
		dataTable["backpack"] = dataTable["backpack"] + 5
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SWAPSLOT	
-----------------------------------------------------------------------------------------------------------------------------------------	
function vRP.swapSlot(user_id,slot,target)
	local inventory = vRP.userInventory(user_id)
	if inventory then
		local temporary = inventory[tostring(slot)]
		inventory[tostring(slot)] = inventory[tostring(target)]
		inventory[tostring(target)] = temporary
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORYWEIGHT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.inventoryWeight(user_id)
	local totalWeight = 0
	local inventory = vRP.userInventory(user_id)

	for k,v in pairs(inventory) do
		if itemBody(v["item"]) then
			totalWeight = totalWeight + itemWeight(v["item"]) * parseInt(v["amount"])
		end
	end

	return totalWeight
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKBROKEN
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.checkBroken(nameItem)
	local splitName = splitString(nameItem,"-")
	if splitName[2] ~= nil then
		if parseInt(os.time() - splitName[2]) >= (86400 * itemDurability(nameItem)) then
			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHESTWEIGHT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.chestWeight(chestData)
	local totalWeight = 0

	for k,v in pairs(chestData) do
		if itemBody(v["item"]) then
			totalWeight = totalWeight + itemWeight(v["item"]) * parseInt(v["amount"])
		end
	end

	return totalWeight
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETINVENTORYITEMAMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getInventoryItemAmount(user_id,nameItem)
	local inventory = vRP.userInventory(user_id)

	for k,v in pairs(inventory) do
		local splitName = splitString(v["item"],"-")
		if nameItem == splitName[1] then
			return { parseInt(v["amount"]),v["item"] }
		end
	end

	return { 0,"" }
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- GETINVENTORYITEMAMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getInventoryItemAmountOnly(user_id,nameItem)
	local inventory = vRP.userInventory(user_id)

	for k,v in pairs(inventory) do
		local splitName = splitString(v["item"])
		if nameItem == splitName[1] then
			return { parseInt(v["amount"]) }
		end
	end

	return { 0 }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETINVENTORYITEMAMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getInventoryItemName(user_id,nameItem)
	local inventory = vRP.userInventory(user_id)

	for k,v in pairs(inventory) do
		local splitName = splitString(v["item"],"-")
		if nameItem == splitName[1] then
			return { parseInt(v["amount"]),v["item"] }
		end
	end

	return { "" }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMAMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.itemAmount(user_id,nameItem)
	local totalAmount = 0
	local splitName = splitString(nameItem,"-")
	local inventory = vRP.userInventory(user_id)

	for k,v in pairs(inventory) do
		if v["item"] == splitName[1] then
			totalAmount = totalAmount + v["amount"]
		end
	end

	return parseInt(totalAmount)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GIVEINVENTORYITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.giveInventoryItem(user_id,idname,amount,slot,notify)
	local data = vRP.getInventory(user_id)
	if data and parseInt(amount) > 0 then
		if type(slot) == "boolean" then 
			backupslot = notify
			slot = notify
			notify = backupslot
		end
		if not slot or slot == nil then
			local initial = 12
			
			local slot = vRP.GetSlotByItem(data, idname)
			if slot == nil then
				repeat
					initial = initial + 1
				until data[tostring(initial)] == nil or (data[tostring(initial)] and data[tostring(initial)].item == idname)
			else
				initial = tonumber(slot)
			end
			
			initial = tostring(initial)

			if data[initial] == nil then
				data[initial] = { item = idname, amount = parseInt(amount) }
			elseif data[initial] and data[initial].item == idname then
				data[initial].amount = parseInt(data[initial].amount) + parseInt(amount)
			end

			--notify
			if notify and vRP.itemBodyList(idname) then
				TriggerClientEvent("itensNotify",vRP.getUserSource(user_id),{ "RECEBEU",vRP.itemIndexList(idname),vRP.format(parseInt(amount)),vRP.itemNameList(idname) })
			end
		else
			slot = tostring(slot)

			if data[slot] then
				if data[slot].item == idname then
					local oldAmount = parseInt(data[slot].amount)
					data[slot] = { item = idname, amount = parseInt(oldAmount) + parseInt(amount) }
				end
			else
				data[slot] = { item = idname, amount = parseInt(amount) }
			end

			--notify
			if notify and vRP.itemBodyList(idname) then
				TriggerClientEvent("itensNotify",vRP.getUserSource(user_id),{ "RECEBEU",vRP.itemIndexList(idname),vRP.format(parseInt(amount)),vRP.itemNameList(idname) })
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GENERATEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.generateItem(user_id,nameItem,amount,notify,slot)
	if parseInt(amount) > 0 then
		local amount = parseInt(amount)
		local source = vRP.userSource(user_id)
		local identity = vRP.userIdentity(user_id)
		local inventory = vRP.userInventory(user_id)

		if itemDurability(nameItem) then
			if itemType(nameItem) == "Armamento" or itemType(nameItem) == "Evidência" then
				nameItem = tostring(nameItem.."-"..os.time().."-"..identity["serial"])
			else
				nameItem = tostring(nameItem.."-"..os.time())
			end
		end

		if not slot then
			local initial = 0
			repeat
				initial = initial + 1
			until inventory[tostring(initial)] == nil or (inventory[tostring(initial)] and inventory[tostring(initial)]["item"] == nameItem) or initial > vRP.getBackpack(user_id)

			if initial > vRP.getBackpack(user_id) then
				TriggerClientEvent("Notify",source,"amarelo","Limite de itens na mochila atingido.",5000)
				TriggerEvent("inventory:invExplode",source,nameItem,amount)
				return
			end

			initial = tostring(initial)

			if inventory[initial] == nil then
				inventory[initial] = { item = nameItem, amount = amount }
			elseif inventory[initial] and inventory[initial]["item"] == nameItem then
				inventory[initial]["amount"] = parseInt(inventory[initial]["amount"]) + amount
			end

			if notify and itemBody(nameItem) then
				TriggerClientEvent("itensNotify",source,{ "recebeu",itemIndex(nameItem),parseFormat(amount),itemName(nameItem) })
			end
		else
			local selectSlot = tostring(slot)

			if inventory[selectSlot] then
				if inventory[selectSlot]["item"] == nameItem then
					inventory[selectSlot]["amount"] = parseInt(inventory[selectSlot]["amount"]) + amount
				end
			else
				inventory[selectSlot] = { item = nameItem, amount = amount }
			end

			if notify and itemBody(nameItem) then
				TriggerClientEvent("itensNotify",source,{ "recebeu",itemIndex(nameItem),parseFormat(amount),itemName(nameItem) })
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKMAXITENS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.checkMaxItens(user_id,nameItem,amount)
	if itemBody(nameItem) then
		local amount = parseInt(amount)
		if itemMaxAmount(nameItem) ~= nil then
			if (vRP.itemAmount(user_id,nameItem) + amount) > itemMaxAmount(nameItem) then
				return true
			end
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKILEGALITENS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.checkIlegalItens(user_id,nameItem,amount)
	if itemBody(nameItem) then
		local amount = parseInt(amount)
		if itemIlegal(nameItem) ~= nil then
			if itemIlegal(nameItem) then
				return true
			end
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VERIFYWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.verifyWeapon(user_id,nameItem)
	local source = vRP.userSource(user_id)
	local splitName = splitString(nameItem,"-")

	if itemType(nameItem) == "Armamento" then
		TriggerClientEvent("inventory:verifyWeapon",source,nameItem,splitName[1])
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRYGETINVENTORYITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.tryGetInventoryItem(user_id,idname,amount,slot,notify)
	local data = vRP.getInventory(user_id)
	if data then
		if type(slot) == "boolean" then 
			backupslot = notify
			slot = notify
			notify = backupslot
		end
		if not slot or slot == nil then
			for k,v in pairs(data) do
				if v.item == idname and parseInt(v.amount) >= parseInt(amount) then
					v.amount = parseInt(v.amount) - parseInt(amount)

					if parseInt(v.amount) <= 0 then
						data[k] = nil
					end
					
					--notify
					if notify and vRP.itemBodyList(idname) then
						TriggerClientEvent("itensNotify",vRP.getUserSource(user_id),{ "REMOVIDO",vRP.itemIndexList(idname),vRP.format(parseInt(amount)),vRP.itemNameList(idname) })
					end
					return true
				end
			end
		else
			local slot  = tostring(slot)

			if data[slot] and data[slot].item == idname and parseInt(data[slot].amount) >= parseInt(amount) then
				data[slot].amount = parseInt(data[slot].amount) - parseInt(amount)

				if parseInt(data[slot].amount) <= 0 then
					data[slot] = nil
				end
				
				--notify
				if notify and vRP.itemBodyList(idname) then
					TriggerClientEvent("itensNotify",vRP.getUserSource(user_id),{ "REMOVIDO",vRP.itemIndexList(idname),vRP.format(parseInt(amount)),vRP.itemNameList(idname) })
				end
				return true
			end
		end
	end

	return false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- COMPUTEINVWEIGHT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.computeInvWeight(user_id)
	local weight = 0
	local inventory = vRP.getInventory(user_id)
	if inventory then
		for k,v in pairs(inventory) do
			if vRP.itemBodyList(v.item) then
				weight = weight + vRP.itemWeightList(v.item) * parseInt(v.amount)
			end
		end
		return weight
	end
	return 0
end

vRP.getInventoryWeight = vRP.computeInvWeight
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEINVENTORYITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.removeInventoryItem(user_id,nameItem,amount,notify)
	local amount = parseInt(amount)
	local source = vRP.userSource(user_id)
	local inventory = vRP.userInventory(user_id)

	for k,v in pairs(inventory) do
		if v["item"] == nameItem and parseInt(v["amount"]) >= amount then
			v["amount"] = parseInt(v["amount"]) - amount

			if parseInt(v["amount"]) <= 0 then
				inventory[k] = nil
			end

			if notify and itemBody(nameItem) then
				TriggerClientEvent("itensNotify",source,{ "removeu",itemIndex(nameItem),parseFormat(amount),itemName(nameItem) })
			end

			break
		end
	end

	vRP.verifyWeapon(user_id,nameItem)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- GETINVENTORYITEMAMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getInventoryItemAmount(user_id,idname)
	local data = vRP.getInventory(user_id)
	if data then
		for k,v in pairs(data) do
			if v.item == idname then
				return parseInt(v.amount)
			end
		end
	end
	return 0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETSRVDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getSrvdata(key)
	if srvData[key] == nil then
		local rows = vRP.query("entitydata/getData",{ dkey = key })
		if parseInt(#rows) > 0 then
			srvData[key] = { data = json.decode(rows[1]["dvalue"]), timer = 10 }
		else
			srvData[key] = { data = {}, timer = 10 }
		end
	end

	return srvData[key]["data"]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETSRVDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.setSrvdata(key,data)
	srvData[key] = { data = data, timer = 10 }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMSRVDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.remSrvdata(key)
	srvData[key] = { data = {}, timer = 10 }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SRVSYNC
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		for k,v in pairs(srvData) do
			if v["timer"] > 0 then
				v["timer"] = v["timer"] - 1

				if v["timer"] <= 0 then
					vRP.execute("entitydata/setData",{ dkey = k, value = json.encode(v["data"]) })
					srvData[k] = nil
				end
			end
		end

		Citizen.Wait(60000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN:KICKALL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("admin:KickAll")
AddEventHandler("admin:KickAll",function()
	for k,v in pairs(srvData) do
		if json.encode(v["data"]) == "[]" or json.encode(v["data"]) == "{}" then
			vRP.execute("entitydata/removeData",{ dkey = k })
		else
			vRP.execute("entitydata/setData",{ dkey = k, value = json.encode(v["data"]) })
		end
	end

	print("Save no banco de dados terminou, ja pode reiniciar o servidor.")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVUPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.invUpdate(user_id,slot,target,amount)
	selfReturn[user_id] = true

	if actived[user_id] == nil and parseInt(amount) > 0 then
		local amount = parseInt(amount)
		local selectSlot = tostring(slot)
		local targetSlot = tostring(target)
		local inventory = vRP.userInventory(user_id)

		if inventory[selectSlot] then
			actived[user_id] = true
			local nameItem = inventory[selectSlot]["item"]

			if inventory[targetSlot] then
				if inventory[selectSlot] and inventory[targetSlot] then
					if nameItem == inventory[targetSlot]["item"] then
						if parseInt(inventory[selectSlot]["amount"]) >= amount then
							inventory[selectSlot]["amount"] = parseInt(inventory[selectSlot]["amount"]) - amount
							inventory[targetSlot]["amount"] = parseInt(inventory[targetSlot]["amount"]) + amount

							if parseInt(inventory[selectSlot]["amount"]) <= 0 then
								inventory[selectSlot] = nil
							end

							selfReturn[user_id] = false
						end
					else
						local temporary = inventory[selectSlot]
						inventory[selectSlot] = inventory[targetSlot]
						inventory[targetSlot] = temporary

						selfReturn[user_id] = false
					end
				end
			else
				if inventory[selectSlot] then
					if parseInt(inventory[selectSlot]["amount"]) >= amount then
						inventory[targetSlot] = { item = nameItem, amount = amount }
						inventory[selectSlot]["amount"] = parseInt(inventory[selectSlot]["amount"]) - amount

						if parseInt(inventory[selectSlot]["amount"]) <= 0 then
							inventory[selectSlot] = nil
						end

						selfReturn[user_id] = false
					end
				end
			end

			actived[user_id] = nil
		end
	end

	return selfReturn[user_id]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRYCHEST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.tryChest(user_id,chestData,amount,slot,target)
	selfReturn[user_id] = true

	if actived[user_id] == nil and parseInt(amount) > 0 then
		local amount = parseInt(amount)
		local selectSlot = tostring(slot)
		local targetSlot = tostring(target)
		local source = vRP.userSource(user_id)
		local consult = vRP.getSrvdata(chestData)

		if consult[selectSlot] then
			local nameItem = consult[selectSlot]["item"]
			local inventory = vRP.userInventory(user_id)
			actived[user_id] = true

			if vRP.checkMaxItens(user_id,nameItem,amount) then
				TriggerClientEvent("Notify",source,"amarelo","Limite atingido.",3000)
				actived[user_id] = nil

				return selfReturn[user_id]
			end

			if (vRP.inventoryWeight(user_id) + (itemWeight(nameItem) * amount)) <= vRP.getBackpack(user_id) then
				if inventory[targetSlot] and consult[selectSlot] then
					if inventory[targetSlot]["item"] == nameItem then
						if parseInt(consult[selectSlot]["amount"]) >= amount then
							inventory[targetSlot]["amount"] = parseInt(inventory[targetSlot]["amount"]) + amount
							consult[selectSlot]["amount"] = parseInt(consult[selectSlot]["amount"]) - amount

							if parseInt(consult[selectSlot]["amount"]) <= 0 then
								consult[selectSlot] = nil
							end

							selfReturn[user_id] = false
						end
					end
				else
					if consult[selectSlot] then
						if parseInt(consult[selectSlot]["amount"]) >= amount then
							inventory[targetSlot] = { item = nameItem, amount = amount }
							consult[selectSlot]["amount"] = parseInt(consult[selectSlot]["amount"]) - amount

							if parseInt(consult[selectSlot]["amount"]) <= 0 then
								consult[selectSlot] = nil
							end

							selfReturn[user_id] = false
						end
					end
				end
			end

			actived[user_id] = nil
		end
	end

	return selfReturn[user_id]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORECHEST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.storeChest(user_id,chestData,amount,dataWeight,slot,target)
	selfReturn[user_id] = true

	if actived[user_id] == nil and parseInt(amount) > 0 then
		local amount = parseInt(amount)
		local selectSlot = tostring(slot)
		local targetSlot = tostring(target)
		local inventory = vRP.userInventory(user_id)

		if inventory[selectSlot] then
			actived[user_id] = true
			local consult = vRP.getSrvdata(chestData)
			local nameItem = inventory[selectSlot]["item"]

			if (vRP.chestWeight(consult) + (itemWeight(nameItem) * amount)) <= dataWeight then
				if consult[targetSlot] and inventory[selectSlot] then
					if nameItem == consult[targetSlot]["item"] then
						if parseInt(inventory[selectSlot]["amount"]) >= amount then
							consult[targetSlot]["amount"] = parseInt(consult[targetSlot]["amount"]) + amount
							inventory[selectSlot]["amount"] = parseInt(inventory[selectSlot]["amount"]) - amount

							if parseInt(inventory[selectSlot]["amount"]) <= 0 then
								inventory[selectSlot] = nil
							end

							selfReturn[user_id] = false
						end
					end
				else
					if inventory[selectSlot] then
						if parseInt(inventory[selectSlot]["amount"]) >= amount then
							consult[targetSlot] = { item = nameItem, amount = amount }
							inventory[selectSlot]["amount"] = parseInt(inventory[selectSlot]["amount"]) - amount

							if parseInt(inventory[selectSlot]["amount"]) <= 0 then
								inventory[selectSlot] = nil
							end

							selfReturn[user_id] = false
						end
					end
				end
			end

			vRP.verifyWeapon(user_id,nameItem)
			actived[user_id] = nil
		end
	end

	return selfReturn[user_id]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATECHEST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.updateChest(user_id,chestData,slot,target,amount)
	selfReturn[user_id] = true

	if actived[user_id] == nil and parseInt(amount) > 0 then
		local amount = parseInt(amount)
		local selectSlot = tostring(slot)
		local targetSlot = tostring(target)
		local consult = vRP.getSrvdata(chestData)

		if consult[selectSlot] then
			actived[user_id] = true

			if consult[targetSlot] and consult[selectSlot] then
				if consult[selectSlot]["item"] == consult[targetSlot]["item"] then
					if parseInt(consult[selectSlot]["amount"]) >= amount then
						consult[selectSlot]["amount"] = parseInt(consult[selectSlot]["amount"]) - amount

						if parseInt(consult[selectSlot]["amount"]) <= 0 then
							consult[selectSlot] = nil
						end

						consult[targetSlot]["amount"] = parseInt(consult[targetSlot]["amount"]) + amount
						selfReturn[user_id] = false
					end
				else
					local temporary = consult[selectSlot]
					consult[selectSlot] = consult[targetSlot]
					consult[targetSlot] = temporary

					selfReturn[user_id] = false
				end
			else
				if consult[selectSlot] then
					if parseInt(consult[selectSlot]["amount"]) >= amount then
						consult[selectSlot]["amount"] = parseInt(consult[selectSlot]["amount"]) - amount
						consult[targetSlot] = { item = consult[selectSlot]["item"], amount = amount }

						if parseInt(consult[selectSlot]["amount"]) <= 0 then
							consult[selectSlot] = nil
						end

						selfReturn[user_id] = false
					end
				end
			end

			actived[user_id] = nil
		end
	end

	return selfReturn[user_id]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOREPOLICE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.storePolice(amount)
	local amount = parseInt(amount)
	local consult = vRP.getSrvdata("stackChest:Police")
	if consult["100"] then
		if consult["100"]["item"] == "dollars" then
			consult["100"]["amount"] = parseInt(consult["100"]["amount"]) + amount
		else
			consult["100"] = { item = "dollars", amount = amount }
		end
	else
		consult["100"] = { item = "dollars", amount = amount }
	end
end
