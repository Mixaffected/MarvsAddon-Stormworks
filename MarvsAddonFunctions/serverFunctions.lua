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
    local ui_id = g_savedata.playerData[playerData.steam_id].ui_id
    server.setPopupScreen(peer_id, ui_id, "", true, "$ " .. tostring(g_savedata.playerData[playerData.steam_id].money),
        0.56, 0.88)
end

function updateUIAll()
    local players = server.getPlayers()
    for k, player in pairs(players) do
        updatePlayerUI(tonumber(player.id))
    end
end

function copyTable(table, seen)
    if type(table) ~= "table" then
        return
    end
    if seen and seen[table] then
        return seen[table]
    end

    local s = {}
    local res = setmetatable({}, getmetatable(table))

    s[table] = res

    for k, v in pairs(table) do
        res[copyTable(k, s)] = copyTable(v, s)
    end

    return res
end

function save()
    server.save("scriptsave")
end
