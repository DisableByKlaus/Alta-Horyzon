local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

rfx = Tunnel.getInterface(GetCurrentResourceName())

BancoAberto = false


local sServer = Tunnel.getInterface(GetCurrentResourceName())


CreateThread(function()
    Wait(2000)
    loadScripts()
end)

function loadScripts()
    CreateThread(function()

        while true do
            sleep = 1000
            local ped = PlayerPedId()
            local pCDS = GetEntityCoords(ped)
            for k,v in pairs(Agencias) do 
                local distance = #(pCDS - vector3(v.x,v.y,v.z))
                if distance <= 3 then
                    sleep = 4
                end
            end
            Wait(sleep)
        end
    end)
end

--[[
RegisterNetEvent("bank:open")
AddEventHandler("bank:open",function()
    for k,v in pairs(Agencias) do
        local ped = PlayerPedId()
        local pCDS = GetEntityCoords(ped)
        local distance = #(pCDS - vector3(v.x,v.y,v.z))
        if distance <= 1.5 then
          
                if BancoAberto == false then
                    BancoAberto = true
                    local carteira,banco = rfx.GetMoneySystem()
                    local carteira2,banco2 = rfx.ConsultPlayer()

                    local infos,gemas = rfx.PlayerSystem()
                    if carteira == nil then
                        carteira = 0
                    end
                    
                    SendNUIMessage({ action = 'opensystem', banco = banco, carteira = carteira, infos = infos, gemas = gemas })
                    SetNuiFocus(true, true)
                    TransitionToBlurred(true)
                end
            end
    end
end)
]]
RegisterKeyMapping('abrirbanco','Abrir o Banco','keyboard', 'E')

RegisterCommand('abrirbanco', function()
    TriggerEvent("hudActived",false)
    for k,v in pairs(Agencias) do
        local ped = PlayerPedId()
        local pCDS = GetEntityCoords(ped)
        local distance = #(pCDS - vector3(v.x,v.y,v.z))
        if distance <= 1.5 then
          
                if BancoAberto == false then
                    BancoAberto = true
                    local carteira,banco = rfx.GetMoneySystem()
                    local carteira2,banco2 = rfx.ConsultPlayer()

                    local infos,gemas = rfx.PlayerSystem()
                    if carteira == nil then
                        carteira = 0
                    end
                    
                    SendNUIMessage({ action = 'opensystem', banco = banco, carteira = carteira, infos = infos, gemas = gemas })
                    SetNuiFocus(true, true)
                    TransitionToBlurred(true)
                end

        end
    end
end)


RegisterNUICallback('fecharbanco',function(data,cb)
    TriggerEvent("hudActived",true)
    BancoAberto = false
    SendNUIMessage({ action = 'closesystem'})
    SetNuiFocus(false, false)

    TransitionFromBlurred(1000)
end)



RegisterNUICallback('money', function(data, cb)
	if data.type == "drop" then 
        if data.param or data.param > 0 then
            if rfx.DropMoney(data.param) then
                local carteira,banco = rfx.GetMoneySystem()
                SendNUIMessage({action = 'updateaccount', wallet = carteira, bank = banco})
                cb({retorno = 'sucesso', valor = data.param})
            end
        end

	elseif data.type == "deposit" then 
        if data.param  or data.param > 0 then
            if rfx.DepositMoney(data.param) then
                local carteira,banco = rfx.GetMoneySystem()
                SendNUIMessage({action = 'updateaccount', wallet = carteira, bank = banco})
                cb({retorno = 'depositar', valor = data.param})
            end
        end

	elseif data.type == "express" then 
        if rfx.ExpressMoney() then
            local carteira,banco = rfx.GetMoneySystem()
            SendNUIMessage({action = 'updateaccount', wallet = carteira, bank = banco})
            cb({retorno = '1000'})
        end
    elseif data.type == "send" then
        if data.id then
            if rfx.Send(data.id,data.value) then
                local carteira,banco = rfx.GetMoneySystem()
                SendNUIMessage({action = 'updateaccount', wallet = carteira, bank = banco})
                cb({retorno = 'ted', valor = data.value})
            end
        else
            TriggerClientEvent("Notify",source,"vermelho","Você não expecificou o passaporte!.",5000)
        end
    end
end)






RegisterNUICallback("clearTrans", function(data,cb)
    if rfx.ClearTrans() then
        cb({retorno = 'sucesso'})
    end
end)

RegisterNUICallback("getGraphic",function(data,cb)
    local dados = rfx.getExtract()
    SendNUIMessage({action = 'Graphic', dados = rfx.getExtract()})
end)




RegisterNetEvent("bank:saidas")
AddEventHandler("bank:saidas",function(valor)
    SendNUIMessage({action = 'saidas', valor = valor})
end)

function DrawText3Ds(x,y,z,text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z)
	SetTextFont(4)
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,150)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text))/370
	DrawRect(_x,_y+0.0125,0.01+factor,0.03,0,0,0,80)
end