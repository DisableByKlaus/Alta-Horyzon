RegisterNetEvent('codem-trade:setTrade')
AddEventHandler('codem-trade:setTrade', function(senderSource, receiverSource, senderinv, receiverinv, senderName, receiverName)
    SendNUIMessage({
        action = 'setTrade',
        senderSource = senderSource,
        source = GetPlayerServerId(PlayerId()),
        receiverSource = receiverSource,
        senderinventory = senderinv,
        receiverinventory = receiverinv,
        senderName = senderName,
        receiverName = receiverName,

    })
    SetNuiFocus(true, true)
end)


RegisterNUICallback('ItemSwapped', function(data, cb)
    TriggerServerEvent("codem-trade:server:itemSwapped", data)
end)


RegisterNUICallback('tradeCanceled', function(data, cb)
    print('daha neler karşim')
    TriggerServerEvent("codem-trade:server:tradeCanceled", data)

end)

RegisterNetEvent('codem-trade:client:tradeCanceled')
AddEventHandler('codem-trade:client:tradeCanceled', function()


    SendNUIMessage({
        action = 'close'
    })
    SetNuiFocus(false, false)

end)


RegisterNUICallback('resetNui', function(data)
    SetNuiFocus(false,false)
end)
RegisterNUICallback('confirmToggled', function(data, cb)
    TriggerServerEvent("codem-trade:server:confirmToggled", data)
end)

RegisterNUICallback('tradeConfirmed', function(data, cb)
    TriggerServerEvent("codem-trade:server:shareItems", data)
    SetNuiFocus(false, false)
end)


RegisterNetEvent('codem-trade:client:confirmedToggled')
AddEventHandler('codem-trade:client:confirmedToggled', function(toggle)
    SendNUIMessage({
        action = 'setConfirmed',
        toggle = toggle,
    })
end)




RegisterNetEvent('codem-trade:client:itemSwapped')
AddEventHandler('codem-trade:client:itemSwapped', function(data)
    SendNUIMessage({
        action = 'swapItems',
        slots = data,

    })

end)