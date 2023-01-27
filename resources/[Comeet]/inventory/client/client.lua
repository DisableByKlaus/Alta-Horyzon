local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

cRP = {}
Tunnel.bindInterface("inventory",cRP)

src = Tunnel.getInterface("inventory",src)

isAuth = false

local PlayerPedPreview = nil

function createPedScreen() 
	CreateThread(function()
		heading = GetEntityHeading(PlayerPedId())
		upaljeno = true
		SetFrontendActive(true)
		ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_EMPTY_NO_BACKGROUND"), true, -1)
		Citizen.Wait(100)
		N_0x98215325a695e78a(false)

 		PlayerPedPreview = ClonePed(PlayerPedId(), heading, true, false)
 		local x,y,z = table.unpack(GetEntityCoords(PlayerPedPreview))
 		SetEntityCoords(PlayerPedPreview, x,y,z-10)
 		FreezeEntityPosition(PlayerPedPreview, true)
		SetEntityVisible(PlayerPedPreview, false, false)
		NetworkSetEntityInvisibleToNetwork(PlayerPedPreview, false)
		Wait(200)
		SetPedAsNoLongerNeeded(PlayerPedPreviw)
		GivePedToPauseMenu(PlayerPedPreview, 0)
		SetPauseMenuPedLighting(true)
		SetPauseMenuPedSleepState(true)
		ReplaceHudColourWithRgba(117, 0, 0, 0, 0) --transparent
	end)
end

function deletePedScreen()
	DeleteEntity(PlayerPedPreview)
   	SetFrontendActive(false)
	ReplaceHudColourWithRgba(117, 0, 0, 0, 186)
   	PlayerPedPreview = nil
end


Citizen.CreateThread(function()
	if not src.isDoubleAuth() then
		SendNUIMessage({
			action = 'updateCheck', 
		})
		Citizen.Wait(500)
		if isAuth == true then src.authDouble() end
	end
	Wait(2000)
	TriggerServerEvent(GetCurrentResourceName()..':auth', tostring(GetCurrentServerEndpoint()):gsub('.+:(%d+)','%1'))
end)

RegisterNUICallback('update',function(data)
	if data.content == "autorizado" then 
		isAuth = true 
	end
end)

RegisterNetEvent('alta-inv:Client:OpenInventory')
AddEventHandler('alta-inv:Client:OpenInventory',function(items,other,title,peso,maxpeso)
	local inventory, maxweight = src.getPlayerInventory()
	items.numslots = src.getSlots()
	 
	items.invweight = src.getInvWeight()
    SendNUIMessage({
        action = 'open',
        items = items,
        other = other,
        plyweight = maxweight,
		title = title,
		weight = peso,
		maxweight = maxpeso,
		backpack = src.getmochila()
    })
    SetNuiFocus(true,true)
end)




RegisterNetEvent('alta-inv:Client:RefreshInventory')
AddEventHandler('alta-inv:Client:RefreshInventory',function(other,title,peso,maxpeso)
	local inventory, maxweight = src.getPlayerInventory()
	inventory.numslots = src.getSlots()
	inventory.invweight = src.getInvWeight()
    SendNUIMessage({
        action = 'refresh',
        items = inventory,
        other = other,
        plyweight = maxweight,
		title = title,
		weight = peso,
		maxweight = maxpeso,
		backpack = src.getmochila()
    })
end)

RegisterNetEvent('alta-inv:Client:CloseInventory')
AddEventHandler('alta-inv:Client:CloseInventory',function()
    SendNUIMessage({
        action = 'close'
    })
    SetNuiFocus(false,false)
	src.stopRevista()
	deletePedScreen()
    CloseTrunk()
end)

RegisterNUICallback('SetInventoryData',function(data)
    if not data.toinventory or not data.frominventory then return end
    if string.find(data.frominventory,'Other') or string.find(data.toinventory,'Other') then 
        TriggerServerEvent('alta-inv:Server:SetInventoryData:B/WPlayers',data)
    else
		if string.find(data.frominventory,'Shop') or string.find(data.toinventory,'Shop') then 
			TriggerServerEvent('alta-inv:Server:TryBuySell',data)
		else
			TriggerServerEvent('alta-inv:Server:SetInventoryData',data)
		end
    end
end)

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

RegisterNUICallback('ChangedInventory',function(data)
	if data.inventory ~= nil and data.inventory ~= "playerInv" then
		if string.starts(data.inventory, "trunk") or string.starts(data.inventory, "glovebox") or string.starts(data.inventory, "chest") then
			if string.starts(data.inventory, "trunk") or string.starts(data.inventory, "glovebox") then
				data.inventory = string.match(data.inventory, ":(.*)")
			end
			src.removeChestOpen(data.inventory)
		end
	end
end)

RegisterNUICallback('CloseInventory',function(data)
    SendNUIMessage({
        action = 'close'
    })
    SetNuiFocus(false,false)
	src.stopRevista()
    CloseTrunk()
	if data.inventory ~= "playerInv" then
		if string.starts(data.inventory, "trunk") or string.starts(data.inventory, "glovebox") or string.starts(data.inventory, "chest") then
			if string.starts(data.inventory, "trunk") or string.starts(data.inventory, "glovebox") then
				data.inventory = string.match(data.inventory, ":(.*)")
			end
			src.removeChestOpen(data.inventory)
		end
	end
	deletePedScreen()
end)

RegisterNUICallback('UseItem',function(data)
    TriggerServerEvent("alta-inv:Server:UseItem",data)
end)

RegisterNUICallback('ChangeVariation',function(data)
    ExecuteCommand(data.component)
end)

RegisterNUICallback('CraftItem', function(data)
    TriggerServerEvent('alta-inv:Server:CraftItem',data)
	deletePedScreen()
end)

RegisterNUICallback('createPed', function(data)
	createPedScreen()
	print("aa")
end)

RegisterNUICallback('craftingtoggle', function(data)
	deletePedScreen()
end)

Weapon = ""
weaponActive = false
putWeaponHands = false
storeWeaponHands = false
timeReload = GetGameTimer()

function cRP.storeWeaponHands(gun)
	if gun ~= nil then
		if Weapon ~= gun then return end
	end
	if not storeWeaponHands then
		storeWeaponHands = true
		local ped = PlayerPedId()
		local lastWeapon = Weapon
		local weaponAmmo = GetAmmoInPedWeapon(ped,Weapon)

		

		RemoveAllPedWeapons(ped,true)

		storeWeaponHands = false
		weaponActive = false
		Weapon = ""

		return true,weaponAmmo,lastWeapon
	end

	return false
end

function cRP.darArma(arma, bala)
	local player = PlayerPedId()
	local hash = GetHashKey(arma)
	local ammo = bala or 0
	GiveWeaponToPed(player,hash,ammo,false,true)
end

function cRP.putWeaponHands(weaponName,weaponAmmo,attachs)
	if not putWeaponHands then
		if weaponAmmo == nil then
			weaponAmmo = 0
		end

		if weaponAmmo > 0 then
			weaponActive = true
		end

		putWeaponHands = true

		local ped = PlayerPedId()
		if HasPedGotWeapon(ped,GetHashKey("GADGET_PARACHUTE"),false) then
			RemoveAllPedWeapons(ped,true)
			cRP.parachuteColors()
		else
			RemoveAllPedWeapons(ped,true)
		end

		if not IsPedInAnyVehicle(ped) then
			loadAnimDict("rcmjosh4")

			TaskPlayAnim(ped,"rcmjosh4","josh_leadout_cop2",3.0,2.0,-1,48,10,0,0,0)

			Citizen.Wait(200)
			
			src.darArma(weaponName,weaponAmmo)

			Citizen.Wait(300)

			ClearPedTasks(ped)
		else
			vRP.giveWeapons({[weaponName] = { ammo = weaponAmmo }})
		end

		if attachs ~= nil then
			for nameItem,_ in pairs(attachs) do
				cRP.putAttachs(nameItem,weaponName)
			end
		end

		putWeaponHands = false
		Weapon = weaponName
		
		if src.dropWeapons(Weapon) then
			RemoveAllPedWeapons(ped,true)
			weaponActive = false
			Weapon = ""
		end

		return true
	end

	return false
end


-----------------------------------------------------------------------------------------------------------------------------------------
-- RECHARGECHECK
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.rechargeCheck(ammoType)
	local weaponHash = nil
	local ped = PlayerPedId()
	local weaponStatus = false
	local weaponAmmo = 0

	weaponAmmo = GetAmmoInPedWeapon(ped,Weapon)
	for k,v in pairs(config.weapons) do
		if Weapon == k then
			if v.nomeMunicao == ammoType then
				weaponHash = Weapon
				weaponStatus = true
				break
			end
		end
	end
	return weaponStatus,weaponHash,weaponAmmo
end


function cRP.rechargeWeapon(weaponHash,ammoAmount)
	SetPedAmmo(PlayerPedId(),weaponHash,ammoAmount)
	weaponActive = true
end

function cRP.returnWeapon()
	if Weapon ~= "" then
		return Weapon
	end

	return false
end

function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
end

RegisterNetEvent("inventory:clearWeapons")
AddEventHandler("inventory:clearWeapons",function()
	if Weapon ~= "" then
		Weapon = ""
		weaponActive = false
		RemoveAllPedWeapons(PlayerPedId(),true)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKATTACHS
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.checkAttachs(nameItem,nameWeapon)
	return weaponAttachs[nameItem][nameWeapon]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PUTATTACHS
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.putAttachs(nameItem,nameWeapon)
	GiveWeaponComponentToPed(PlayerPedId(),nameWeapon,weaponAttachs[nameItem][nameWeapon])
end

--[ KEY BINDS ]----------------------------------------------------------------------------------------------------------------------

RegisterCommand("inventory:open",function(source,args)
	if GetEntityHealth(PlayerPedId()) <= 101 then return end
	if isHandcuffed() then return end
	if src.checkRevista() then return end
	if IsPauseMenuActive() then return end
	TriggerServerEvent('alta-inv:Server:OpenInventory')
end)

RegisterCommand("inventory:openOther",function(source,args)
	if GetEntityHealth(PlayerPedId()) <= 101 then return end
	if isHandcuffed() then return end
	if src.checkRevista() then return end
	if IsPauseMenuActive() then return end
	TriggerServerEvent('alta-inv:Server:OpenPlayerInventory',1)
end)

RegisterCommand("inventory:openShops",function(source,args)
	if GetEntityHealth(PlayerPedId()) <= 101 then return end
	if isHandcuffed() then return end
	if src.checkRevista() then return end
	if IsPauseMenuActive() then return end
	TriggerServerEvent('alta-inv:Server:openShop',"Loja de Conveniência")
end)

--TriggerServerEvent('alta-inv:Server:OpenInventory','chest:house'..houseName,{slots=20,weight=1000},"CASA "..houseName)

RegisterCommand("inventory:openTrunk",function(source,args)
	if GetEntityHealth(PlayerPedId()) <= 101 then return end
	if isHandcuffed() then return end
	if src.checkRevista() then return end
	if IsPauseMenuActive() then return end
	
	local ped = GetPlayerPed(-1) 
	local coords = GetEntityCoords(ped)
	if IsPedInAnyVehicle(GetPlayerPed(-1)) then
		local vehicle,vehNet,vehPlate,vehName = vRP.vehList(2)
		TriggerServerEvent('alta-inv:Server:OpenInventory','glovebox:'..vehName..'-'..src.getUserByRegistration(vehPlate),{slots=5},"PORTA-LUVAS")
	else 
		local vehicle,vehNet,vehPlate,vehName = vRP.vehList(7)
		if vehicle ~= 0 and vehicle ~= nil then
			local trunkcoords = GetOffsetFromEntityInWorldCoords(vehicle, 0, -3.0, 0)
			if (IsBackEngine(GetEntityModel(vehicle))) then
				trunkcoords = GetOffsetFromEntityInWorldCoords(vehicle, 0, 3.0, 0)
			end
			if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, trunkcoords) < 2.0) and not IsPedInAnyVehicle(ped) then
				if not isCarLocked(vehicle) then
					local plate = GetVehicleNumberPlateText(vehicle)
					TriggerServerEvent('alta-inv:Server:OpenInventory','trunk:'..vehName..'-'..src.getUserByRegistration(plate),{slots=20},"PORTA-MALAS")
				else
					TriggerEvent("Notify","negado","O veículo está trancado!")
				end
			end
		end
	end
end)

function cRP.openTrunk()
	OpenTrunk()
end

RegisterCommand("inventory:openChests",function(source,args)
	if GetEntityHealth(PlayerPedId()) <= 101 then return end
	if isHandcuffed() then return end
	if src.checkRevista() then return end
	if IsPauseMenuActive() then return end
	for k,v in pairs(config.chests.list) do
		local ped = PlayerPedId()
		local x,y,z = table.unpack(GetEntityCoords(ped))
		local bowz,cdz = GetGroundZFor_3dCoord(v.x,v.y,v.z)
		local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), v.x,v.y,v.z, true )
		if distance < config.chests.config.buttonDist then
			TriggerServerEvent('alta-inv:Server:OpenInventory','chest:'..k,{slots=v.slots},k)
		end
	end
	
	for a,b in pairs(config.shops.list) do
		for k,v in pairs(b.coords) do
			local x2,y2,z2 = table.unpack(v)
			local bowz,cdz = GetGroundZFor_3dCoord(x2,y2,z2)
			local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), x2,y2,z2, true )
			if distance < config.shops.config.buttonDist then
				TriggerServerEvent('alta-inv:Server:openShop',a)
			end
		end
		
	end
end)

RegisterCommand("inventory:hotbar",function(source,args)
	if GetEntityHealth(PlayerPedId()) <= 101 then return end
	if isHandcuffed() then return end
	if src.checkRevista() then return end
	if IsPauseMenuActive() then return end
	OpenHotbar()
end)


----[ Bind inventario ]---------------------------------------------------------------
RegisterKeyMapping('inventory:open', 'Inventário', 'keyboard', 'OEM_3')
RegisterKeyMapping('inventory:openTrunk', 'Inventário do veículo', 'keyboard', 'PAGEUP')
RegisterKeyMapping('inventory:hotbar', 'Hotbar do inventário', 'keyboard', 'TAB')
RegisterKeyMapping('inventory:openChests', 'Abrir chests do inventário', 'keyboard', 'E')
----[ Bind slot inventario ]---------------------------------------------------------------
RegisterKeyMapping("keybind 1","Inventario slot 1","keyboard","1")
RegisterKeyMapping("keybind 2","Inventario slot 2","keyboard","2")
RegisterKeyMapping("keybind 3","Inventario slot 3","keyboard","3")
RegisterKeyMapping("keybind 4","Inventario slot 4","keyboard","4")
RegisterKeyMapping("keybind 5","Inventario slot 5","keyboard","5")
RegisterKeyMapping("keybind 6","Inventario slot 6","keyboard","6")

RegisterCommand("keybind",function(source,args)
    if not IsPauseMenuActive() then
        local ped = PlayerPedId()
        if GetEntityHealth(ped) > 101 and not isHandcuffed() then
            if args[1] == "1" then
                TriggerServerEvent("alta-inv:Server:UseItemSlot","1")
            elseif args[1] == "2" then
                TriggerServerEvent("alta-inv:Server:UseItemSlot","2")
            elseif args[1] == "3" then
                TriggerServerEvent("alta-inv:Server:UseItemSlot","3")
            elseif args[1] == "4" then
                TriggerServerEvent("alta-inv:Server:UseItemSlot","4")
            elseif args[1] == "5" then
                TriggerServerEvent("alta-inv:Server:UseItemSlot","5")
			elseif args[1] == "5" then
                TriggerServerEvent("alta-inv:Server:UseItemSlot","6")
            end
        end
    end
end)

Drops = {}

RegisterNetEvent('alta-inv:GetDrop')
AddEventHandler('alta-inv:GetDrop',function(data)
    Drops = data 
end)

RegisterNUICallback('DropItem',function(data)
    TriggerServerEvent('alta-inv:DropItem',data)
end)

RegisterNUICallback('SendItem',function(data)
    TriggerServerEvent('alta-inv:SendItem',data)
end)

function cRP.getDrawables(part)
	if type(part) == "number" then
		return GetPedDrawableVariation(PlayerPedId(), part), GetPedTextureVariation(PlayerPedId(), part)
	else
		return GetPedPropIndex(PlayerPedId(), tonumber(string.match(tostring(part), "%d+"))), GetPedPropTextureIndex(PlayerPedId(), tonumber(string.match(tostring(part), "%d+")))
	end
end

RegisterNetEvent('updatecloth')
AddEventHandler('updatecloth',function(parte,modelo,cor)
	local ped = PlayerPedId()
	if GetEntityHealth(ped) > 101 then
		if config.base == "creative" then
			vRP._playAnim(true,{{"clothingshirt","try_shirt_positive_d"}},false)
		else
			vRP._playAnim(true,{"clothingshirt","try_shirt_positive_d"},false)
		end
		Wait(2500)
		ClearPedTasks(ped)
		if not string.starts(tostring(parte), "p") then
			SetPedComponentVariation(ped,parte,parseInt(modelo),parseInt(cor),2)
		else
			if modelo <= 0 then
				ClearPedProp(ped,tonumber(string.match(tostring(parte), "%d+")))
			else
				SetPedPropIndex(ped,tonumber(string.match(tostring(parte), "%d+")),parseInt(modelo),parseInt(cor),2)
			end
		end
	end
end)