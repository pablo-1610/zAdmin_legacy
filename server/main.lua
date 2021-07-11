local ESX = {}

TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

-- Client communication
local function registerHandle(event, ...)
    event = ("zAdmin:%s"):format(event)
    RegisterNetEvent(event)
    AddEventHandler(event, ...)
end

local function sendToClient(event, _src, ...)
    event = ("zAdmin:%s"):format(event)
    TriggerClientEvent(event, _src, ...)
end

registerHandle("requestPlayers", function()
    local _src = source
    local players = {}

    local xPlayers = ESX.GetPlayers()
    for i = 1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        table.insert(players, { group = xPlayer.getGroup(), job = xPlayer.job, sID = xPlayers[i], name = GetPlayerName(xPlayers[i]) })
    end

    sendToClient("receivePlayers", _src, players)
end)