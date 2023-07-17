-- If peer_id is nil then all palyers will be returned
-- return { ["id"] = peer_id, ["name"] = name, ["admin"] = is_admin, ["auth"] = is_auth, ["steam_id"] = steam_id }
function getPlayerData(peer_id)
    local players = server.getPlayers()
    local player = {
        ["id"] = -1,
        ["steam_id"] = "",
        ["name"] = "",
        ["admin"] = false,
        ["auth"] = false,
    }
    local allPlayers = {}

    for key, value in pairs(players) do
        player["id"] = value["id"]
        player["steam_id"] = tostring(value["steam_id"])
        player["name"] = value["name"]
        player["is_admin"] = value["is_admin"]
        player["auth"] = value["is_auth"]

        if peer_id ~= nil then
            if players[key]["id"] == peer_id then
                return player
            end
        else
            table.insert(allPlayers, copyTable(player))
        end
    end
    return allPlayers
end

function updatePlayerBalance(peer_id)

end

function updateAllBalances()

end

-- Copy a table and all its child tables
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

function getLen(t)
    local len = 0
    for k, v in pairs(t) do
        len = len + 1
    end

    return len
end

function saveGame(saveName)
    local saveName = saveName or "scriptsave"
    server.save(saveName)
end
