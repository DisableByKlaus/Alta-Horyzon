-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

vCU = Tunnel.getInterface("inventory_client")
vCLIENT = Tunnel.getInterface("inventory")
vTASKBAR = Tunnel.getInterface("taskbar")

func = {}
Tunnel.bindInterface("inventory-usables", func)

local actived = {}

func.useItem = function(itemName,ramount)
	local source = source
	local user_id = vRP.getUserId(source)
	
	if ramount == nil then ramount = vRP.getInventoryItemAmount(user_id,itemName) end
	if user_id and ramount ~= nil and parseInt(ramount) >= 0 and not actived[user_id] and actived[user_id] == nil then
		local type = vRP.itemTypeList(itemName)
		if type == 'use' then
			if itemName == "mochila" then
				if vRP.getBackpack(user_id) >= 90 then
					TriggerClientEvent("Notify",source,"negado","Você não pode equipar mais mochilas.",8000)
				else
					if vRP.tryGetInventoryItem(user_id,"mochila",1) then
						
						local valor = 0
						if vRP.getBackpack(user_id) == 6 or vRP.getBackpack(user_id) == 5 or vRP.getBackpack(user_id) == 0 then
							valor = 30
						elseif vRP.getBackpack(user_id) == 30 then
							valor = 60
						elseif vRP.getBackpack(user_id) == 60 then
							valor = 90
						end
						vRP.execute("characters/setMochila",{ user_id = parseInt(user_id), mochila = 1})
						vRP.setBackpack(user_id, valor)
					end
				end
			
			elseif itemName == "colete" then
				if vRP.tryGetInventoryItem(user_id,"colete",1) then
					vRPclient.setArmour(source,100)
					NotifyItem(user_id, "USOU", itemName,1)
				end

			elseif itemName == "water" then
				local src = source
				if vRP.tryGetInventoryItem(user_id,"water",1) then
					print("bebeu")
				end
			elseif itemName == "attachsflashlight" or itemName == "attachscrosshair" or itemName == "attachssilencer" or itemName == "attachsgrip" then
				local returnWeapon = vCLIENT.returnWeapon(source)
				if returnWeapon then
					if Attachs[user_id][returnWeapon] == nil then
						Attachs[user_id][returnWeapon] = {}
					end
					if Attachs[user_id][returnWeapon][itemName] == nil then
						local checkAttachs = vCLIENT.checkAttachs(source,itemName,returnWeapon)
						if checkAttachs then
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vCLIENT.putAttachs(source,itemName,returnWeapon)
								Attachs[user_id][returnWeapon][itemName] = true
								TriggerClientEvent('alta-inv:Client:RefreshInventory',source)
								NotifyItem(user_id, "EQUIPOU ATTACH", itemName,1)
							end	
						else
							TriggerClientEvent("Notify",source,"importante","O armamento não possui suporte ao componente.",5000)
						end
					else
						TriggerClientEvent("Notify",source,"importante","O armamento já possui o componente equipado.",5000)
					end
				else
					TriggerClientEvent("Notify",source,"negado","Você não possui uma arma equipada!")
					TriggerClientEvent('alta-inv:Client:CloseInventory',source)
				end
			end
		end
	end
end

function func.giveItem(name,qtd)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.computeInvWeight(user_id) + vRP.itemWeightList(name) * qtd <= vRP.getBackpack(user_id) then
			vRP.giveInventoryItem(user_id,name,qtd)
			return true
		else
			TriggerClientEvent("Notify",source,"negado","Mochila cheia.",5000)
			return false
		end
	end
end