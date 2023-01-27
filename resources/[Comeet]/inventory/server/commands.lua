-- /REVISTAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('revistar',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local nplayer = vRPclient.getNearestPlayer(source,2)
    local nuser_id = vRP.getUserId(nplayer)
    if nuser_id then
        TriggerClientEvent(config.blockCommands,source,true)
        TriggerClientEvent(config.blockCommands,nplayer,true)
		
		if config.revistar.enableCarry then
			TriggerClientEvent('carregar',nplayer,source)
		end

        vRPclient._playAnim(nplayer,false,{{"random@mugging3","handsup_standing_base"}},true)
        TriggerClientEvent("progress",source,config.revistar.time*1000,"revistando")
        SetTimeout(config.revistar.time*1000,function()
			
            TriggerEvent('alta-inv:Server:OpenPlayerInventory',nuser_id,user_id)

        end)
        TriggerClientEvent("Notify",nplayer,"aviso","Você está sendo <b>Revistado</b>.")
       
    end
end)