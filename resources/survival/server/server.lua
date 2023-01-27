local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')
vRPclient = Tunnel.getInterface('vRP')

rfxS = {}
Tunnel.bindInterface('survival',rfxS)
rfxC = Tunnel.getInterface('survival')



RegisterCommand("re",function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.hasPermission(user_id,'ems') or vRP.hasPermission(user_id,'policia') then
			local nplayer = vRPclient.nearestPlayer(source,2)
			if nplayer then
				if rfxC.deadPlayer(nplayer) then
					TriggerClientEvent('Progress',source,10000,'Retirando...')
					TriggerClientEvent('cancelando',source,true)
					vRPclient._playAnim(source,false,{'mini@cpr@char_a@cpr_str','cpr_pumpchest'},true)
					SetTimeout(10000,function()
						vRPclient._removeObjects(source)
						rfxC._revivePlayer(nplayer,110)
						TriggerClientEvent('resetBleeding',nplayer)
						TriggerClientEvent('cancelando',source,false)
					end)
					TriggerClientEvent('zSurvival:PlayerRevive',nplayer)
				end
			end
		end
	end
end)

function rfxS.ResetPedToHospital()
	local source = source
	local user_id = vRP.getUserId(source)
	local identifier = vRP.getUserId(source)
	if user_id then
		if rfxC.deadPlayer(source) then
			rfxC.finishDeath(source)
			TriggerClientEvent('resetHandcuff',source)
			TriggerClientEvent('resetBleeding',source)
			TriggerClientEvent('resetDiagnostic',source)
			TriggerClientEvent('zSurvival:FadeOutIn',source)
			vRP.execute("characters/setMochilas",{ user_id = parseInt(user_id), mochila = 0  })
			vRPclient._clearWeapons(source)
			Wait(2000)
			vRPclient.teleport(source,359.87,-585.34,43.29)
			Wait(1000)
			rfxC.SetPedInBed(source)
		end
	end
end

RegisterServerEvent('upgradeStress')
AddEventHandler('upgradeStress',function(number)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		vRP.upgradeStress(user_id,parseInt(number))
	end
end)