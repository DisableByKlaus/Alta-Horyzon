local Tunnel = module('vrp', 'lib/Tunnel')
local Proxy = module('vrp', 'lib/Proxy')
vRP = Proxy.getInterface('vRP')

rfxC = {}
Tunnel.bindInterface('survival', rfxC)
rfxS = Tunnel.getInterface('survival')

local deadPlayer = false
local deathtimer = 50
local blockControls = false
local cure = false


function drawTxt(text, font, x, y, scale, r, g, b, a)
	SetTextFont(font)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry('STRING')
	AddTextComponentString(text)
	DrawText(x, y)
end

function rfxC.finishDeath()
	local ped = PlayerPedId()
	if GetEntityHealth(ped) <= 101 then
		deadPlayer = false
		ClearPedBloodDamage(ped)
		SetEntityHealth(ped, 400)
		SetEntityInvincible(ped, false)
	end
end

function rfxC.deadPlayer()
	return deadPlayer
end

function rfxC.revivePlayer(health)
	SetPedMaxHealth(PlayerPedId(), 400)
	SetEntityHealth(PlayerPedId(), health)
	SetEntityInvincible(PlayerPedId(), false)
	ClearPedTasks(PlayerPedId())
	if deadPlayer then
		deadPlayer = false
		ClearPedTasks(PlayerPedId())
	end
end

function rfxC.startCure()
	local ped = PlayerPedId()
	if cure then
		return
	end
	cure = true
	TriggerEvent('Notify', 'sucesso', 'O tratamento começou, espere o paramédico libera-lo.', 3000)
	if cure then
		repeat
			Citizen.Wait(1000)
			if GetEntityHealth(ped) > 101 then
				SetEntityHealth(ped, GetEntityHealth(ped)+1)
			end
		until GetEntityHealth(ped) >= 400 or GetEntityHealth(ped) <= 101
			TriggerEvent('Notify', 'sucesso', 'Tratamento concluído.', 3000)
			cure = false
			blockControls = false
	end
end

function rfxC.SetPedInBed()
	local ped = PlayerPedId()
	SetEntityCoords(ped, vector3(-448.7 + 0.0001, -340.65 + 0.0001, 34.51 + 0.0001) + 0.20, 1, 0, 0, 1)
	SetEntityHeading(ped, 87.63)
	vRP.playAnim(false, {'dead', 'dead_a'}, true)
	SetTimeout(7000, function()
		TriggerEvent('ax-inv:Client:CloseInventory')
	end)
end

RegisterNetEvent('zSurvival:CheckIn')
AddEventHandler('zSurvival:CheckIn', function()
	SetEntityHealth(PlayerPedId(), 102)
	SetEntityInvincible(PlayerPedId(), false)
	Citizen.Wait(500)
	deadPlayer = false
	blockControls = true
end)


RegisterNetEvent('updatePrison')
AddEventHandler('updatePrison', function()
	SetEntityHealth(PlayerPedId(), 110)
	SetEntityInvincible(PlayerPedId(), false)
	if deadPlayer then
		deadPlayer = false
		blockControls = true
		ClearPedTasks(PlayerPedId())
		TriggerEvent('resetBleeding')
		TriggerEvent('resetDiagnostic')
	end
end)

RegisterNetEvent('zSurvival:FadeOutIn')
AddEventHandler('zSurvival:FadeOutIn', function()
	DoScreenFadeOut(1000)
	Citizen.Wait(5000)
	DoScreenFadeIn(1000)
end)

RegisterNetEvent('zSurvival:PlayerRevive')
AddEventHandler('zSurvival:PlayerRevive',function()
	deadPlayer = false
	SetNuiFocus(false,false)
	TransitionFromBlurred(1000)

	SendNUIMessage({
		setDisplay = false,
		setDisplayDead = false,
		deathtimer = deathtimer
	})
end)

RegisterNetEvent('zSurvival:notShow')
AddEventHandler('zSurvival:notShow',function()
	SetNuiFocus(false,false)
	TransitionFromBlurred(1000)
	SendNUIMessage({
		setDisplay = false,
		setDisplayDead = false,
		deathtimer = deathtimer
	})
end)


Citizen.CreateThread(function()
	while true do
		local timeDistance = 100
		local ped = PlayerPedId()
		if GetEntityHealth(ped) <= 101 and deathtimer >= 0 then
			if not deadPlayer then
				timeDistance = 100
				deadPlayer = true
				local coords = GetEntityCoords(ped)
				NetworkResurrectLocalPlayer(coords, true, true, false)
				deathtimer = 1200
				if not IsEntityPlayingAnim(ped, 'dead', 'dead_a', 3) and not IsPedInAnyVehicle(ped) then
					vRP.playAnim(false, {'dead', 'dead_a'}, true)
				end
				SetEntityHealth(ped, 101)
				SetEntityInvincible(ped, true)
				TriggerEvent('ax-inv:Client:CloseInventory')
			else
				if deathtimer > 0 then
					timeDistance = 4
					SetEntityHealth(ped, 101)
					SetNuiFocus(true,true)
					TransitionToBlurred(1000)
					SendNUIMessage({
						setDisplay = true,
						setDisplayDead = false,
						deathtimer = deathtimer
					})
					if not IsEntityPlayingAnim(ped, 'dead', 'dead_a', 3) and not IsPedInAnyVehicle(ped) then
						vRP.playAnim(false, {'dead', 'dead_a'}, true)
					end
					TriggerEvent('zHud:changeHudOnOff', false)
				else
					timeDistance = 4
					SetNuiFocus(true,true)
					TransitionToBlurred(1000)
					SendNUIMessage({
						setDisplay = false,
						setDisplayDead = true,
						deathtimer = deathtimer
					})
					if not IsEntityPlayingAnim(ped, 'dead', 'dead_a', 3) and not IsPedInAnyVehicle(ped) then
						vRP.playAnim(false, {'dead', 'dead_a'}, true)
					end
					TriggerEvent('zHud:changeHudOnOff', false)
				end
			end
		end
		Citizen.Wait(timeDistance)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if deadPlayer and deathtimer > 0 then
			deathtimer = deathtimer - 1
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		SetPlayerHealthRechargeMultiplier(PlayerId(), 0)
		Citizen.Wait(100)
	end
end)

Citizen.CreateThread(function()
	while true do
		local timeDistance = 100
		local ped = PlayerPedId()
		if blockControls or deadPlayer then
			timeDistance = 4
			DisablePlayerFiring(ped, true)
			DisableControlAction(1, 22, true)
			DisableControlAction(1, 73, true)
			DisableControlAction(1, 167, true)
			DisableControlAction(1, 29, true)
			DisableControlAction(1, 182, true)
			DisableControlAction(1, 187, true)
			DisableControlAction(1, 189, true)
			DisableControlAction(1, 190, true)
			DisableControlAction(1, 188, true)
			DisableControlAction(1, 311, true)
		end

		Citizen.Wait(timeDistance)
	end
end)