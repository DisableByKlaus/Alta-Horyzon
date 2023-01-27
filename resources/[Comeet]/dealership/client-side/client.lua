-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("dealership",cRP)
vSERVER = Tunnel.getInterface("dealership")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local typeCars = {}
local typeBikes = {}
local typeWorks = {}
local typeRental = {}
inMenu              = true
dealership	        = true
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
locais = {
	{name='dealership', id=1, x= -55.72, y= 67.42, z= 71.95}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADFOCUS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	SetNuiFocus(false,false)
	TriggerEvent("hudActived",true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TABLET
-----------------------------------------------------------------------------------------------------------------------------------------
if dealership then
	Citizen.CreateThread(function()
		while true do
			local idle = 1000
			if nearDealer() then
				idle = 5
				if  IsControlJustPressed(1, 38) then
					inMenu = true
					SetNuiFocus(true,true)
					SetCursorLocation(0.5,0.5)
					SendNUIMessage({ action = "openSystem" })
					TriggerEvent("hudActived",false)
					if not IsPedInAnyVehicle(PlayerPedId()) then
						vRP.removeObjects()
						vRP.createObjects("amb@code_human_in_bus_passenger_idles@female@tablet@base","base","prop_cs_tablet",50,28422)
					end
				end
			end
			Citizen.Wait(idle)
		end
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSESYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("closeSystem",function(data)
	vRP.removeObjects()
	SetNuiFocus(false,false)
	SetCursorLocation(0.5,0.5)
	SendNUIMessage({ action = "closeSystem" })
	TriggerEvent("hudActived",true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEVEHICLES
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.updateVehicles(Cars,Bikes,Works,Rental)
	typeCars = Cars
	typeBikes = Bikes
	typeWorks = Works
	typeRental = Rental
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTCARROS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestCarros",function(data,cb)
	cb({ result = typeCars })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTMOTOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestMotos",function(data,cb)
	cb({ result = typeBikes })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTSERVICOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestServicos",function(data,cb)
	cb({ result = typeWorks })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTALUGUEL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestAluguel",function(data,cb)
	cb({ result = typeRental })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTPOSSUIDOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestPossuidos",function(data,cb)
	cb({ result = vSERVER.requestPossuidos() })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTBUY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestBuy",function(data,cb)
	vSERVER.requestBuy(data["name"])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTRENTAL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestRental",function(data,cb)
	vSERVER.requestRental(data["name"])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RENTALMONEY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("rentalMoney",function(data,cb)
	--vSERVER.rentalMoney(data["name"])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTTAX
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestTax",function(data,cb)
	vSERVER.requestTax(data["name"])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTSELL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestSell",function(data,cb)
	vSERVER.requestSell(data["name"])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TABLET:UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("tablet:Update")
AddEventHandler("tablet:Update",function(action)
	SendNUIMessage({ action = action })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DRIVEABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local vehDrive = nil
local benDrive = false
local benCoords = { -55.51,67.8,71.95 }
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTDRIVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestDrive",function(data,cb)
	local ped = PlayerPedId()

	if true then
		vRP.removeObjects()
		SetNuiFocus(false,false)
		SetCursorLocation(0.5,0.5)
		SendNUIMessage({ action = "closeSystem" })

		local driveIn,vehPlate = vSERVER.startDrive()
		if driveIn then
			TriggerEvent("races:insertList",true)
			TriggerEvent("player:blockCommands",true)
			TriggerEvent("Notify","azul","Teste iniciado, para finalizar saia do veículo.",5000)
			TriggerEvent("hudActived",true)
			Wait(1000)

			vehCreate(data["name"],vehPlate)

			Wait(1000)

			SetPedIntoVehicle(ped,vehDrive,-1)
			benDrive = true
		end
	else
		TriggerEvent("Notify","amarelo","Dirija-se até a <b>Benefactor</b> para efetuar o teste.",2000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHCREATE
-----------------------------------------------------------------------------------------------------------------------------------------
function vehCreate(vehName,vehPlate)
	local mHash = GetHashKey(vehName)

	RequestModel(mHash)
	while not HasModelLoaded(mHash) do
		Wait(1)
	end

	if HasModelLoaded(mHash) then
		vehDrive = CreateVehicle(mHash,-68.29,82.77,71.21,65.2,false,false)

		SetEntityInvincible(vehDrive,true)
		SetVehicleOnGroundProperly(vehDrive)
		SetVehicleNumberPlateText(vehDrive,vehPlate)
		SetEntityAsMissionEntity(vehDrive,true,true)
		SetVehicleHasBeenOwnedByPlayer(vehDrive,true)
		SetVehicleNeedsToBeHotwired(vehDrive,false)

		SetModelAsNoLongerNeeded(mHash)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADDRIVE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local timeDistance = 999
		if benDrive then
			timeDistance = 1
			DisableControlAction(1,69,false)

			local ped = PlayerPedId()
			if not IsPedInAnyVehicle(ped) then
				Wait(1000)

				benDrive = false
				vSERVER.removeDrive()
				DeleteEntity(vehDrive)
				TriggerEvent("races:insertList",false)
				TriggerEvent("player:blockCommands",false)
				SetEntityCoords(ped,benCoords[1],benCoords[2],benCoords[3],1,0,0,0)
			end
		end

		Wait(timeDistance)
	end
end)

--[ Pegar Coords  ]-------------------------------------------------------------------------------------------------------------------------

function nearDealer()
	local player = GetPlayerPed(-1)
	local playerloc = GetEntityCoords(player, 0)
	
	for _, search in pairs(locais) do
		local distance = GetDistanceBetweenCoords(search.x, search.y, search.z, playerloc['x'], playerloc['y'], playerloc['z'], true)
		
		if distance <= 1 then
			
			DrawMarker(23, search.x, search.y, search.z-0.99, 0, 0, 0, 0, 0, 0, 0.7, 0.7, 0.5, 136, 96, 240, 180, 0, 0, 0, 0)
			return true
		end
	end
end


--[ DrawText ]-------------------------------------------------------------------------------------------------------------------------


function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.005+ factor, 0.03, 41, 11, 41, 68)
end