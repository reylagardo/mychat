local Framework = nil

RegisterServerEvent('chat:server:sendMessage')
AddEventHandler('chat:server:sendMessage', function(message)
    local src = source
    local coords = GetEntityCoords(GetPlayerPed(src))
    local players = GetPlayers()
    local dist = Config.LocalDistance or 20.0
    local color = Config.LocalColorHex or '#ffffff'

    for _, playerId in ipairs(players) do
        local targetCoords = GetEntityCoords(GetPlayerPed(playerId))
        if #(coords - targetCoords) < dist then
            TriggerClientEvent('chat:client:addMessage', playerId, {
                author = GetPlayerName(src),
                content = message,
                type = 'LOCAL',
                colorHex = color,
                logo = nil
            })
        end
    end
end)

RegisterCommand('ooc', function(source, args)
    if #args > 0 then
        local message = table.concat(args, " ")
        local color = (Config and Config.OOCColorHex) or '#ffffff'
        
        TriggerClientEvent('chat:client:addMessage', -1, {
            author = GetPlayerName(source),
            content = message,
            type = 'OOC GLOBAL',
            colorHex = color,
            logo = nil
        })
    end
end)

Citizen.CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        Framework = 'ESX'
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'QB'
    end
end)

local function GetPlayerJob(source)
    if Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.job.name or nil
    elseif Framework == 'QB' then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.job.name or nil
    end
    return nil
end

if Config and Config.JobCommands then
    for cmd, data in pairs(Config.JobCommands) do
        RegisterCommand(cmd, function(source, args)
            local src = source
            local playerJob = GetPlayerJob(src)
            if playerJob == data.jobName then
                if #args > 0 then
                    local message = table.concat(args, " ")
                    TriggerClientEvent('chat:client:addMessage', -1, {
                        author = GetPlayerName(src),
                        content = message,
                        type = data.label,
                        logo = data.logo,
                        colorHex = data.colorHex
                    })
                else
                    TriggerClientEvent('chat:client:addMessage', src, {
                        author = "SYSTEM",
                        content = "Gunakan: /" .. cmd .. " [pesan]",
                        type = "ERROR",
                        colorHex = "#ff4757"
                    })
                end
            else
                TriggerClientEvent('chat:client:addMessage', src, {
                    author = "SYSTEM",
                    content = "Hanya personil " .. data.label .. " yang memiliki akses!",
                    type = "ERROR",
                    colorHex = "#ff4757"
                })
            end
        end, false)
    end
end
