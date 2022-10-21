function getPlayerData(peer_id)
    local players = server.getPlayers()
    local player = { id = 0, name = "", steam_id = "", auth = false, admin = false }
    for i, v in pairs(players) do
        if (tostring(v["id"]) == tostring(peer_id)) then
            player.id = v.id
            player.name = v.name
            player.steam_id = tostring(v.steam_id)
            player.auth = v.auth
            player.admin = v.admin
            return player
        end
    end
end

function updatePlayerUI(peer_id)
    local playerData = getPlayerData(peer_id)
    local steam_id = playerData.steam_id
    local ui_id = g_savedata.playerData[steam_id].ui_id
    server.setPopupScreen(peer_id, ui_id, "", true, "$ " .. tostring(g_savedata.playerData[playerData.steam_id].money),
        0.56, 0.88)
end

function updateUIAll()
    local players = server.getPlayers()
    for k, player in pairs(players) do
        updatePlayerUI(tonumber(player.id))
    end
end

function copyTable(table)
    if type(table) ~= "table" then return nil end
    local copiedTable = {}
    for key, value in pairs(table) do
        if type(value) ~= "table" then
            copiedTable[key] = value
        else
            copiedTable[key] = copyTable(value)
        end
    end
    return copiedTable
end

function save()
    server.save("scriptsave")
end
