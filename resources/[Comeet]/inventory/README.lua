-------------------------------------------------------------------------------------------------------------------------------
-- 																													  		 --
-- 																													  		 --
--									ALTERAÇÕES A SEREM FEITAS NO VRP -> MODULES -> INVENTORY.lUA					 		 --
--										Apenas substitua as funções da sua base, pelas funções					   		     --
--												  		que se encontram abaixo.									      	 --
-- 																													   		 --
--   																												   		 --
--										 ATENÇÃO! Algumas funções como a vRP.getBackpack podem                         		 --
--												estar no vrp -> base.lua. Fique atento!								  		 --
-- 																													  		 --
-- 																													  		 --
-------------------------------------------------------------------------------------------------------------------------------



local Proxy = module("vrp","lib/Proxy")
local items = Proxy.getInterface("vrp_inventory_items")

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
-- ITEMNAMELIST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.itemNameList(item)
	if items.getItemList()[item] ~= nil then
		return items.getItemList()[item].name
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
-- ITEMAMMOLIST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.itemAmmoList(item)
	if items.getItemList()[item] then
		return items.getItemList()[item].ammo
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


--As daqui abaixo provavelmente devem estar no base.lua da pasta RAIZ do VRP.

-----------------------------------------------------------------------------------------------------------------------------------------
-- GETINVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getInventory(user_id)
	local data = vRP.user_tables[user_id]
	if data then
		return data.inventorys
	end
	return false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- GETBACKPACK
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getBackpack(user_id)
	local data = vRP.getUserDataTable(user_id)
	if data.backpack == nil then
		data.backpack = 5
	end

	return data.backpack
end

vRP.getInventoryMaxWeight = vRP.getBackpack
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETBACKPACK
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.setBackpack(user_id,amount)
	local data = vRP.getUserDataTable(user_id)
	if data then
		data.backpack = amount
	end
end


-------------------------------------------------------------------------------------------------------------------------
-- 																													   --
--							ALTERAÇÕES MAIS SIMPLES A SEREM FEITAS NA SUA BASE					 					   --
-- 																													   --																												   --
-------------------------------------------------------------------------------------------------------------------------
#Alterar player_state client para arma puxar insta (caso utilize o método de dar arma do VRP)
#Alterar player_state server para não dar as armas antigas (caso utilize o método de dar arma do VRP)
#Retirar o bloqueio do component 2 no removehud.lua (geralmente vrp_misc ou vrp_disney) HideHudComponentThisFrame(2)
#Verificar TODOS os ".inventory" (caminhos de tabela) da base, e alterar para ".inventorys"