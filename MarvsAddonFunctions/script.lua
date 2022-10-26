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

-- all admins steam IDs
local admin = { "76561198346789290", "76561197976360068" }

ingameTime = { ticks = 0, minutes = 0, hour = 0, day = 0, week = 0, month = 0, jear = 0 }
timeCalcs = { uiTicks = 0, saveTicks = 0 }

-- if debug messages should be send
debug = true


function onCreate(is_world_create)
    -- get the value from the property slider as start money when world is created
    if is_world_create then
        g_savedata.gameData.startMoney = tonumber(property.slider("Start Money", 5000, 200000, 5000, 35000))
    end
    newPlayerDataTable.money = g_savedata.gameData.startMoney
end

function onDestroy()
    save("on_destroy_save")
end

function onTick(game_ticks)
    -- does time calculations
    ingameTime.ticks = ingameTime.ticks + 1
    if ingameTime.ticks >= 60 then
        ingameTime.ticks = 0
        ingameTime.minutes = ingameTime.minutes + 1
    end
    if ingameTime.minutes >= 60 then
        ingameTime.minutes = 0
        ingameTime.hour = ingameTime.minutes + 1
    end
    if ingameTime.hour >= 24 then
        ingameTime.hour = 0
        ingameTime.day = ingameTime.minutes + 1
    end
    if ingameTime.day >= 7 then
        ingameTime.day = 0
        ingameTime.week = ingameTime.minutes + 1
    end
    if ingameTime.week >= 30 then
        ingameTime.week = 0
        ingameTime.month = ingameTime.minutes + 1
    end
    if ingameTime.month >= 12 then
        ingameTime.month = 0
        ingameTime.jear = ingameTime.minutes + 1
    end

    -- update of balanceUI
    timeCalcs.uiTicks = timeCalcs.uiTicks + 1
    if timeCalcs.uiTicks >= 60 then
        timeCalcs.uiTicks = 0
        updateBalanceUIAll()
    end

    -- save after 5 minutes
    timeCalcs.saveTicks = timeCalcs.saveTicks + 1
    if timeCalcs.saveTicks >= 18000 then
        timeCalcs.saveTicks = 0
        save()
    end
end

function onPlayerJoin(stId, name, peer_id, is_admin, is_auth)
    local playerData = getPlayerData(peer_id)
    local steam_id = playerData.steam_id
    local ui_id = server.getMapID()

    server.announce("[Server]", name .. " joined the game")

    -- if admin make admin
    for key, value in pairs(admin) do
        if tostring(value) == tostring(steam_id) then
            server.addAdmin(peer_id)
            server.announce("[Server]", "You are now Admin", peer_id)
        end
    end

    -- if bank accountexists then update UiId, addAuth, update balanceUI and save game
    if g_savedata.playerData[steam_id] ~= nil then
        g_savedata.playerData[steam_id].ui_id = ui_id
        server.addAuth(peer_id)
        updatePlayerBalanceUI(peer_id)
        save()
        return
    end

    -- if new player create new bank account and update balanceUI save after that
    local newPlayer = copyTable(newPlayerDataTable)
    newPlayer.name = tostring(playerData.name)
    newPlayer.steam_id = tostring(steam_id)
    newPlayer.ui_id = ui_id
    g_savedata.playerData[steam_id] = newPlayer
    updatePlayerBalanceUI(peer_id)

    server.notify(peer_id, "[Bank]", "New bank account created!", 8)
    server.addAuth(peer_id)
    save()
end

-- remove MapID so hpeful no bugs occure and reset UIID
function onPlayerLeave(steam_id, name, peer_id, is_admin, is_auth)
    local playerData = getPlayerData(peer_id)
    local steam_id = playerData.steam_id

    server.removeMapID(peer_id, g_savedata.playerData[steam_id].ui_id)
    g_savedata.playerData[steam_id].ui_id = -1

    server.announce("[Server]", name .. " left the game")
    save()
end

-- onCustomCommand
require("commands")

-- add the other files into one big chunky file
require("MarvsAddonFunctions.serverFunctions")
require("MarvsAddonFunctions.moneyFunctions")
