-- get all player data about one player
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

-- get table from every player
function getAllPlayer()
    local players = server.getPlayers()
    local allPlayers = {}
    local player = { id = 0, name = "", steam_id = "", auth = false, admin = false }
    for key, value in pairs(players) do
        player.id = value.id
        player.name = value.name
        player.steam_id = tostring(value.steam_id)
        player.auth = value.auth
        player.admin = value.admin
        table.insert(allPlayers, copyTable(player))
    end
    return allPlayers
end

-- update UI for one player
function updatePlayerBalanceUI(peer_id)
    local playerData = getPlayerData(peer_id)
    local ui_id = g_savedata.playerData[playerData.steam_id].ui_id
    server.setPopupScreen(peer_id, ui_id, "", true, "$ " .. getMoney(peer_id),
        0.56, 0.88)
end

-- update balance UI for every player
function updateBalanceUIAll()
    local players = server.getPlayers()
    for k, player in pairs(players) do
        updatePlayerBalanceUI(tonumber(player.id))
    end
end

-- copy a table and all its child tables
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

-- save game default "scriptsave" but also custom ones
function save(saveName)
    local saveName = saveName or "scriptsave"
    server.save(saveName)
end

-- send debug Message
function debugMessage(message)
    if not debug then return end
    server.announce("[Debug]", message)
end

-- round to two decimal places returns number
function roundToTwoDecimalPlaces(value)
    return tonumber(string.format("%.2f", tonumber(value)))
end

-- return bool if player has an bank account
function hasBankAccount(peer_id)
    local playerData = getPlayerData(peer_id)
    if g_savedata.playerData[playerData.steam_id] ~= nil then
        return true
    else
        return false
    end
end

function isStrNumber(string)
    if tonumber(string) ~= nil then
        return true
    end
    return false
end
