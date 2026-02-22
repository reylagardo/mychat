local chatOpened = false


RegisterCommand('openChat', function()
    if not chatOpened then
        chatOpened = true
        SetNuiFocus(true, true)
        SendNUIMessage({ type = 'ON_OPEN' })
    end
end)

RegisterKeyMapping('openChat', 'Buka Chat', 'keyboard', 'T')


RegisterNUICallback('chatResult', function(data, cb)
    chatOpened = false
    SetNuiFocus(false, false)
    if data.message:sub(1, 1) == "/" then
        ExecuteCommand(data.message:sub(2))
    else
        TriggerServerEvent('chat:server:sendMessage', data.message)
    end
    cb('ok')
end)

RegisterNUICallback('closeChat', function(_, cb)
    chatOpened = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('chat:client:addMessage')
AddEventHandler('chat:client:addMessage', function(payload)
    SendNUIMessage({
        type = 'ON_MESSAGE',
        payload = payload
    })
end)

AddEventHandler('chatMessage', function(author, color, text)
    if text:sub(1, 1) ~= "/" then
        CancelEvent()
        TriggerServerEvent('chat:server:sendMessage', text)
    end
end)
