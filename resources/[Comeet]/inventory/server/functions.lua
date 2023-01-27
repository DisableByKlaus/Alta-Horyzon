-------------------------------------------------------------------------------------------------------------------------
-- LISTA DAS ROUPAS "PADRÃO" (roupas que serão colocadas ao interagir com a nui na intenção de "remover a roupa"
-------------------------------------------------------------------------------------------------------------------------
defaults = {
    [1885233650] = {
		[1] = { 0,0,"mascara" }, -- mascara
		[3] = { 15,0 }, -- mãos	
		[4] = { 14,0 }, -- calça
		[6] = { 34,0 }, -- sapatos
		[7] = { 0,0 }, -- acessórios
		[8] = { 0,0 }, -- blusa
		[9] = { 0,0 }, -- colete
		[11] = { 1,0 }, -- jaqueta
		["p0"] = {-1,-1}, -- chapeu
		["p1"] = {-1,-1}, -- oculos
		["p2"] = {-1,-1}, -- brincos
		["p6"] = {-1,-1}, -- relógio

    },
    [-1667301416] = {
        [1] = { 0,0,"mascara" }, -- mascara	
		[3] = { 15,0 }, -- mãos
		[4] = { 16,0 }, -- calça
		[6] = { 35,0 }, -- sapatos
		[7] = { 0,0 }, -- acessórios
		[8] = { 2,0 }, -- blusa
		[9] = { 0,0 }, -- colete
		[11] = { 5,0 }, -- jaqueta
		["p0"] = {-1,-1}, -- chapeu
		["p1"] = {-1,-1}, -- oculos
		["p2"] = {-1,-1}, -- brincos
		["p6"] = {-1,-1}, -- relógio
    }
}

-------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES GERAIS SERVER-SIDE
-------------------------------------------------------------------------------------------------------------------------
AddItemToChest = function(id,item,amount,slot,info)
    local iteminfo = config.itemList[item:lower()]
    if ChestList[id] then 
		if config.itemList[item].index ~= nil and config.itemList[item].index ~= "" then
			if slot then
				if ChestList[id].items[slot] and ChestList[id].items[slot].name == item then 
					if iteminfo.unique or iteminfo.type == 'weapon' then 
						local freeslot = GetFreeSlot(id)
						ChestList[id].items[freeslot] = {
							name = item,
							slot = freeslot,
							image = config.itemList[item].index,
							amount = tonumber(amount),
							info = info,
							type = config.itemList[item:lower()]['type'],
							label = config.itemList[item:lower()]['index'],
							totalweight = vRP.itemWeightList(item:lower())*tonumber(amount),
							itemName = GetItemName(item:lower())
						}
					else
						ChestList[id].items[slot].amount = ChestList[id].items[slot].amount + amount 
					end
				else
					ChestList[id].items[slot] = {
						name = item,
						slot = slot,
						image = config.itemList[item].index,
						amount = tonumber(amount),
						info = info,
						type = config.itemList[item:lower()]['type'],
						label = config.itemList[item:lower()]['index'],
						totalweight = vRP.itemWeightList(item:lower())*tonumber(amount),
						itemName = GetItemName(item:lower())
					}
				end
			else 
				table.insert(ChestList[id].items,{
					name = item,
					slot = slot,
					image = config.itemList[item].index,
					amount = tonumber(amount),
					info = info,
					label = config.itemList[item:lower()]['index'],
					totalweight = vRP.itemWeightList(item:lower())*tonumber(amount),
					itemName = GetItemName(item:lower()),
				})
			end
			SaveChest(id,ChestList[id].items)
		end
    end
end

RemoveItemFromChest = function(id,item,amount,slot)
    if ChestList[id] then 
		if config.itemList[item].index ~= nil and config.itemList[item].index ~= "" then
			if slot then 
				if ChestList[id].items[slot] and ChestList[id].items[slot].name == item then 
					ChestList[id].items[slot].amount = ChestList[id].items[slot].amount - amount 
					if ChestList[id].items[slot].amount <= 0 then 
						ChestList[id].items[slot] = nil 
					end
				else
					ChestList[id].items[slot] = nil
				end
			end
			SaveChest(id,ChestList[id].items)
		end
    end
end

SaveChest = function(id,items)
    if items and id then 
        if ChestList[id] then
			vRP.setSData(string.lower(id),json.encode(items))
        end
    end
end

GetChestItems = function(id) 
    local items = {}
	local data = vRP.getSData(id)
	local sdata = json.decode(data) or {}
	if data and sdata ~= nil then
		for k,v in pairs(sdata) do 
			items[v.slot] = v 
		end
    end
    return items 
end

GetFreeSlot = function(id)
    if ChestList[id] then
        for i=1,ChestList[id].slots do
            if ChestList[id].items[i] == nil then 
                return i
            end
        end
    end
	return nil
end

GetTrunkChestSize = function(carname)
    return math.floor(vRP.vehicleChest(carname))
end

GetGloveBoxSize = function(carname)
    return math.floor(vRP.vehicleChest(carname) / 3)
end

GetNumberFromString = function(string)
    return tonumber(string.match(string, "%d+"))
end

CanCarryItem = function(src,item,amount)
    local retval = false
	
	local source = src

	local inventory = vRP.getInventory(vRP.getUserId(source))
	
	local weight = 0
	for k,v in pairs(inventory) do
		weight = weight + (vRP.itemWeightList(v.item)*v.amount)
	end
	local itemweight = (config.itemList[item].weight)*amount
	if (weight+itemweight) <= vRP.getBackpack(vRP.getUserId(source)) then
		retval = true
    end

    return retval
end

GetPlayerBackpack = function(id)
	local user_id = nil
	if id then user_id = id else user_id = vRP.getUserId(source) end
	return vRP.getBackpack(user_id)
end

GetPlayerInventoryData = function(id)
	local user_id = nil
	if id then user_id = id else user_id = vRP.getUserId(source) end
	local inventory = vRP.getInventory(user_id)
	for k,v in pairs(inventory) do
		if GetItemName(v.item) == "" or GetItemName(v.item) == nil then
			inventory[k] = nil
		else
			inventory[k].totalweight = vRP.itemWeightList(v.item)*v.amount
			inventory[k].itemName = GetItemName(v.item)
			inventory[k].type = vRP.itemTypeList(v.item)
		end
	end
	return inventory, vRP.getBackpack(user_id)
end

getSlots = function(id)
	local user_id = nil
	if id then user_id = id else user_id = vRP.getUserId(source) end
	if vRP.getBackpack(user_id) == 90 then
		return 54
	elseif vRP.getBackpack(user_id) == 60 then
		return 36
	elseif vRP.getBackpack(user_id) == 55 then
		return 18
	elseif vRP.getBackpack(user_id) <= 50 then
		return 10
	else
		return 6
	end
end

GetItemName = function(item)
	return vRP.itemNameList(item)
end

getInventoryWeight = function(id)
	local user_id = nil
	if id then user_id = id else user_id = vRP.getUserId(source) end
	return vRP.computeInvWeight(user_id)
end

getChestWeight = function(chest)
	local inv = json.decode(vRP.getSData(chest))
	if inv then
		local weight = 0
		for k,v in pairs(inv) do
			if vRP.itemBodyList(v.name) then
				weight = weight + vRP.itemWeightList(v.name) * parseInt(v.amount)
			end
		end
		return weight
	end
	return 0
end

IsItemUnique = function(item)
	return item and config.itemList[item:lower()]['unique'] ~= nil and config.itemList[item:lower()]['unique']
end

GetUserIdentity = function(user_id)
	return vRP.getUserIdentity(user_id)
end

GetUserByRegistration = function(plate)
	return vRP.getUserByRegistration(plate)
end

GetUserName = function(user_id)
	local identity = GetUserIdentity(user_id)
	if config.base == "vrpex" then return identity.name.." "..identity.firstname else return identity.name.." "..identity.name2 end
end

GetNearestPlayer = function(source)
	return vRPclient.getNearestPlayer(source,3)
end

--Altere a função de acordo com a sua base
NotifyItem = function(user_id, tipo, item, amount)
	TriggerClientEvent("itensNotify",vRP.getUserSource(user_id), {tipo, vRP.itemIndexList(item), vRP.format(parseInt(amount)), vRP.itemNameList(item)})
end

RegisterNetEvent('alta-inv:Server:ClearInventory')
AddEventHandler('alta-inv:Server:ClearInventory',function(user_id)
	if Ammos[user_id] then
		for k,v in pairs(Ammos[user_id]) do
			vRP.giveInventoryItem(user_id, config.weapons[k]["nomeMunicao"], v)
			Ammos[user_id][k] = nil
		end
	end
	
	if Attachs[user_id] then
		for k,v in pairs(Attachs[user_id]) do
			for a,b in pairs(v) do
				vRP.giveInventoryItem(user_id, a, 1)
				Attachs[user_id][k][a] = nil
			end
		end
	end
	TriggerClientEvent('inventory:clearWeapons',vRP.getUserSource(user_id))
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