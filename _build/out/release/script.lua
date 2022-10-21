-- Author: !true
-- GitHub: https://github.com/nottruenow64bit
-- Workshop: https://steamcommunity.com/id/QuestionmarkTrue/myworkshopfiles/



 
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

function debugMessage(message)
    server.announce("[Debug]", message)
end



g_savedata = {
    vehicleData = {},
    gameData = { startMoney = 20000 },
    playerData = {}
}

local newPlayerDataTable = {
    name = "",
    steam_id = "",
    money = 0,
    ui_id = -1
}


local admin = { "76561198346789290", "76561197976360068" }

ticks = 0
uiTicks = 0
saveTicks = 0

function onCreate(is_world_create)
    if is_world_create then
        g_savedata.gameData.startMoney = tonumber(property.slider("Start Money", 5000, 200000, 5000, 35000))
    end
    newPlayerDataTable.money = g_savedata.gameData.startMoney
end

function onDestroy()
    save()
end

function onTick(game_ticks)
    ticks = ticks + 1

    uiTicks = uiTicks + 1
    if uiTicks >= 60 then
        uiTicks = 0
        updateUIAll()
    end

    saveTicks = saveTicks + 1
    if saveTicks >= 18000 then
        saveTicks = 0
        save()
    end
end

function onPlayerJoin(stId, name, peer_id, is_admin, is_auth)
    local playerData = getPlayerData(peer_id)
    local steam_id = playerData.steam_id
    local ui_id = server.getMapID()

    server.announce("[Server]", name .. " joined the game")

    -- if admin
    for key, value in pairs(admin) do
        if tostring(value) == tostring(steam_id) then
            server.addAdmin(peer_id)
            server.announce("[Server]", "You are now Admin", peer_id)
        end
    end

    -- if bank accountexists
    if g_savedata.playerData[steam_id] ~= nil then
        debugMessage("Exists")
        g_savedata.playerData[steam_id].ui_id = ui_id
        server.addAuth(peer_id)
        updatePlayerUI(peer_id)
        save()
        return
    end

    -- if new player
    local newPlayer = copyTable(newPlayerDataTable)
    newPlayer.name = tostring(playerData.name)
    newPlayer.steam_id = tostring(steam_id)
    newPlayer.ui_id = ui_id
    g_savedata.playerData[steam_id] = newPlayer
    updatePlayerUI(peer_id)

    server.notify(peer_id, "[Bank]", "New bank account created!", 8)
    server.addAuth(peer_id)
    save()
end

function onPlayerLeave(steam_id, name, peer_id, is_admin, is_auth)
    local playerData = getPlayerData(peer_id)
    local steam_id = playerData.steam_id

    server.removeMapID(peer_id, g_savedata.playerData[steam_id].ui_id)
    g_savedata.playerData[steam_id].ui_id = -1

    server.announce("[Server]", name .. " left the game")
    save()
end


