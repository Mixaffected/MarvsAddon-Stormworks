-- insert own steam ids
adminsSteamIds = { 76561198346789290 }


g_savedata = {
    ["gameData"] = {
        ["startBalance"] = 0
    },
    ["playerData"] = {}
}

_startPlayerData = {
    ["peer_id"] = -1,
    ["steam_id"] = "",
    ["name"] = "",
    ["balance"] = 0,
    ["ui_id"] = -1,
    ["vehicles"] = {}
}

function onCreate(is_world_create)
    if is_world_create then
        g_savedata["gameData"]["startBalance"] = property.slider("Start Balance", 0, 250000, 5000, 25000)
    end
    _startPlayerData["balance"] = g_savedata["gameData"]["startBalance"]
end

function onDestroy()
    saveGame("onDestroySave")
end

local guiTicks = 0
local saveTicks = 0
function onTick()
    guiTicks = guiTicks + 1
    saveTicks = saveTicks + 1

    if guiTicks >= 30 then
        guiTicks = 0
        updateAllBalances()
    end

    -- save every 5 mins
    if saveTicks >= 300 then
        saveTicks = 0
        saveGame()
    end
end

function onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
    local playerData = getPlayerData(peer_id)
    local steamId = playerData["steam_id"]
    local ui_id = server.getMapID()

    server.announce("[Server]", name .. " joined the game!")

    -- check for admin
    for key, adminSteamId in pairs(adminsSteamIds) do
        if adminSteamId == steamId then
            server.addAdmin(peer_id)
            server.notify(peer_id, "[SERVER]", "You are now admin!", 8)
        end
    end

    -- if player already exists in g_savedata
    if g_savedata["playerData"][steamId] ~= nil then
        local player = g_savedata["playerData"][steamId]
        player["ui_id"] = ui_id
        player["name"] = name
        player["peer_id"] = peer_id
        server.addAuth(peer_id)
        updatePlayerBalance(peer_id)
        return
    end

    -- create new player data
    local newPlayer = copyTable(_startPlayerData)
    newPlayer["steam_id"] = steamId
    newPlayer["name"] = name
    newPlayer["peer_id"] = peer_id
    newPlayer["ui_id"] = ui_id
    g_savedata["playerData"][steamId] = newPlayer

    server.notify(peer_id, "[Bank]", "New bank account created!", 8)
    server.addAuth(peer_id)
end

function onPlayerLeave(steam_id, name, peer_id, is_admin, is_auth)
    local playerData = getPlayerData(peer_id)
    local steamId = playerData["steam_id"]
    local player = g_savedata["playerData"][steamId]

    -- remove not constant stuff
    server.removeMapID(peer_id, player["ui_id"])
    player["ui_id"] = -1
    player["peer_id"] = -1

    server.announce("[Server]", name .. " left the game!")
end

require("commands")

require("functions.serverFunctions")
require("functions.moneyFunctions")
