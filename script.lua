g_savedata = {
    errorData = { failedToLoad = false, savedataCorrupted = false, errorMessage = "" },
    gameData = { startMoney = 20000 },
    playerData = {}
}

newPlayerTableData = {
    name = "",
    steam_id = "",
    money = 0,
    moneyUiId = 0,
    tags = {}
}

owner = { "76561198346789290", "76561197976360068" }

discordServerInvite = "https://discord.gg/2pcKA74Qgb"


-- time calculation
ticksSinceLastMin = 0
minsSinceLastHour = 0
hoursSinceLastDay = 0
daysSinceServerStart = 0


function onCreate(is_world_create)
    if (is_world_create) then
        g_savedata.gameData.startMoney = tonumber(property.slider("Start Money", 20000, 200000, 10000, 20000))
    end
    newPlayerTableData.money = g_savedata.gameData.startMoney

    -- error output if something is corrupted
    if (newPlayerTableData.money ~= nil and newPlayerTableData.money > 0) then
        -- executed if all is right
        server.notify(-1, "[MarvinsAddon]", "MarvinsAddon is loaded in!", 8)
    else
        local wentWrong = {
            code = 1,
            message = "'newPlayerTableData' startMoney not set correctly."
        }
        if (g_savedata.gameData.startMoney == nil or g_savedata.gameData.startMoney == 0) then
            wentWrong = {
                code = 0,
                message = "'g_savedata' is corrupted."
            }
        end
        server.notify(-1, "[MarvinsAddon]", "Failed to load MarvinsAddon in. " .. wentWrong.message, 8)
        if (wentWrong.code == 1) then
            g_savedata.errorData.failedToLoad = true
        elseif (wentWrong.code == 0) then
            g_savedata.errorData.savedataCorrupted = true
        end
    end
end

function onDestroy()
    server.save("scriptsave")
end

function onTick(game_ticks)
    -- time calculation
    ticksSinceLastMin = ticksSinceLastMin + game_ticks
    if (ticksSinceLastMin == 3600) then
        minsSinceLastHour = minsSinceLastHour + 1
    elseif (ticksSinceLastMin > 3600) then
        ticksSinceLastMin = ticksSinceLastMin - 3600
        minsSinceLastHour = minsSinceLastHour + 1
    end
    if (minsSinceLastHour == 60) then
        minsSinceLastHour = 0
        hoursSinceLastDay = hoursSinceLastDay + 1
    end
    if (hoursSinceLastDay == 24) then
        hoursSinceLastDay = 0
        daysSinceServerStart = daysSinceServerStart + 1
    end
end

function onPlayerJoin(steam_id, name, peer_id, admin, auth)
    local steam_id = getPlayerSteamId(peer_id)
    local ui_id = server.getMapID()
    server.addAuth(peer_id)
    server.announce("[Server]", name .. " joined the game")

    -- if bank account exists
    if (g_savedata.playerData[steam_id] ~= nil) then
        g_savedata.playerData[steam_id].moneyUiId = ui_id
        server.setPopupScreen(peer_id, ui_id, "", true, " Balance: $" .. getMoney(peer_id), 0.56, 0.88)
        server.save("scriptsave")
        return
    end

    -- if new player
    g_savedata.playerData[steam_id] = newPlayerTableData
    g_savedata.playerData[steam_id].name = tostring(name)
    g_savedata.playerData[steam_id].steam_id = tostring(steam_id)
    g_savedata.playerData[steam_id].moneyUiId = ui_id

    for i, v in pairs(owner) do
        if (v == steam_id) then
            addTag(peer_id, "owner")
            addTag(peer_id, "operator")
        end
    end

    server.notify(peer_id, "[Bank]", "New bank account created!", 8)

    server.save("scriptsave")
end

function onPlayerLeave(steam_id, name, peer_id, admin, auth)
    local steam_id = getPlayerSteamId(peer_id)
    server.announce("[Server]", name .. " left the game")
    g_savedata.playerData[steam_id].moneyUiId = ""
    server.save("scriptsave")
end

function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, one, two, three, four, five)
    local playerData = getPlayerData(peer_id)
    local steam_id = playerData.steam_id
    if (command == "?help") then
        server.announce("[MarvinsAddon]", "Help not available")

    elseif (command == "?tags") then
        announce("[MarvinsAddon]", "Tags: " .. getTagsFromPlayer(peer_id), peer_id)
        getTagsFromPlayer(peer_id)

    elseif (command == "?addMoney" and isTagedWith(peer_id, "operator")) then
        local isSuccess = addMoney(one, tonumber(two))
        if (isSuccess) then
            notify(peer_id, "Money Printing Company", "Assignment done!", 8)
            notify(one, "Bank", "$" .. two .. " were sended to your bank account!", 8)
        end

    elseif (command == "?removeMoney" and isTagedWith(peer_id, "operator")) then
        removeMoney(one, tonumber(two))
        notify(peer_id, "Bank", "$" .. two .. " were removed from the bank account of " .. one, 8)
        notify(one, "Bank", "$" .. two .. " were removed from your bank account!", 8)

    elseif (command == "?transferMoney" and isTagedWith(peer_id, "operator")) then
        -- from someone to someone just for operators
        transferMoney(one, two, tonumber(three))
        notify(peer_id, "Bank", "$" .. two .. " were transfered from " .. one .. " to " .. two, 8)
        notify(one, "Bank", "$" .. two .. " were sended to your bank account!", 8)
        notify(two, "Bank", "$" .. two .. " were removed from your bank account!", 8)

    elseif (command == "?sendMoney") then
        -- from your self to someone for everybody
        transferMoney(peer_id, one, tonumber(two))
        notify(peer_id, "Bank", "You sended $" .. two .. " to " .. one, 8)
        notify(one, "Bank", "$" .. two .. " were sended to your bank account from " .. playerData.name .. "!", 8)

    end
end

--[[

	Functions

--]]
-- return all data about one player steam_id is converted to string
function getPlayerData(peer_id)
    local players = server.getPlayers()
    for i, v in pairs(players) do
        if (tostring(v["id"]) == tostring(peer_id)) then
            players[i].steam_id = tostring(players[i].steam_id)
            return players[i]
        end
    end
end

function getPlayerSteamId(peer_id)
    local players = server.getPlayers()
    for i, v in pairs(players) do
        if (tostring(v["id"]) == tostring(peer_id)) then
            return tostring(players[i].steam_id)
        end
    end
end

-- tag functions
function getTagsFromPlayer(peer_id)
    local steam_id = getPlayerSteamId(peer_id)
    return getStringFromTable(g_savedata.playerData[steam_id].tags)
end

function isTagedWith(peer_id, tag)
    local steam_id = getPlayerSteamId(peer_id)
    for i, v in pairs(g_savedata.playerData[steam_id].tags) do
        if (tostring(v) == tostring(tag)) then
            return true
        end
    end
    return false
end

function addTag(peer_id, tag)
    local steam_id = getPlayerSteamId(peer_id)
    for i, v in pairs(g_savedata.playerData[steam_id].tags) do
        if (tostring(v) == tostring(tag)) then
            return
        end
    end
    table.insert(g_savedata.playerData[steam_id].tags, tag)
    return true
end

function removeTag(peer_id, tag)
    local steam_id = getPlayerSteamId(peer_id)
    for i, v in pairs(g_savedata.playerData[steam_id].tags) do
        if (tostring(v) == tostring(tag)) then
            table.remove(g_savedata.playerData[steam_id].tags, i)
            return true
        end
    end
end

-- money functions
function getMoney(peer_id)
    local steam_id = getPlayerSteamId(peer_id)
    return roundToTwoDecimalPlaces(g_savedata.playerData[steam_id].money)
end

function addMoney(peer_id, amount)
    local steam_id = getPlayerSteamId(peer_id)
    if (not isNumber(amount)) then
        return
    end
    g_savedata.playerData[steam_id].money = roundToTwoDecimalPlaces(g_savedata.playerData[steam_id].money) + amount
    return true
end

function removeMoney(peer_id, amount)
    local steam_id = getPlayerSteamId(peer_id)
    if (not isNumber(amount)) then
        return
    end
    g_savedata.playerData[steam_id].money = roundToTwoDecimalPlaces(g_savedata.playerData[steam_id].money) - amount
    return true
end

function transferMoney(peer_id, target_peer_id, amount)
    local payerSteam_id = getPlayerSteamId(peer_id)
    local targetSteam_id = getPlayerSteamId(target_peer_id)
    if (not isNumber(amount)) then
        return
    end
    if (g_savedata.playerData[payerSteam_id] == nil or g_savedata.playerData[targetSteam_id] == nil) then
        notify(peer_id, "Bank", "Transfer in the amount of $" .. amount ..
            " canceled! Recipient or sender are not found!", 8)
        notify(target_peer_id, "Bank", "Transfer canceled! Recipient or sender are not found!", 8)
        return
    end
    if (roundToTwoDecimalPlaces(g_savedata.playerData[payerSteam_id].money) < roundToTwoDecimalPlaces(amount)) then
        notify(peer_id, "Bank", "Transfer in the amount of $" .. amount .. " canceled! Not enough money!", 8)
        return
    end
    if (peer_id == target_peer_id) then
        notify(peer_id, "Bank", "You cant send your self money!", 8)
    end

    local payingBalanceBeforeTransfer = roundToTwoDecimalPlaces(g_savedata.playerData[payerSteam_id].money)
    local targetBalanceBeforeTransfer = roundToTwoDecimalPlaces(g_savedata.playerData[targetSteam_id].money)

    g_savedata.playerData[payerSteam_id].money = roundToTwoDecimalPlaces(g_savedata.playerData[payerSteam_id].money) -
        roundToTwoDecimalPlaces(amount)
    if ((payingBalanceBeforeTransfer - g_savedata.playerData[payerSteam_id].money) ~= amount) then
        g_savedata.playerData[payerSteam_id].money = payingBalanceBeforeTransfer
        notify(peer_id, "Bank", "Something went wrong! Try again.", 8)
        addErrorMessage("Transfer between " .. payerSteam_id .. " and " ..
            targetSteam_id .. " Payment by payer has failed!")
    end
    g_savedata.playerData[targetSteam_id].money = roundToTwoDecimalPlaces(g_savedata.playerData[targetSteam_id].money) +
        roundToTwoDecimalPlaces(amount)
    if ((g_savedata.playerData[targetSteam_id].money - targetBalanceBeforeTransfer) ~= amount) then
        notify(peer_id, "Bank", "Something went wrong! Try again.", 8)
        addErrorMessage("Transfer between " .. payerSteam_id ..
            " and " .. targetSteam_id .. ". Payment by target has failed!")
    end
end

--[[

	functional functions
	
--]]
-- get complete table lengt
function tableLen(T)
    local c = 0
    for _ in pairs(T) do c = c + 1 end
    return c
end

function isNumber(v)
    if (type(v) == type(0)) then
        return true
    end
    return false
end

function isString(v)
    if (type(v) == type("")) then
        return true
    end
    return false
end

function notify(peer_id, title, message, NOTIFICATION_TYPE)
    server.notify(peer_id, title, message, NOTIFICATION_TYPE)
end

function announce(name, message, peer_id)
    if (peer_id == nil) then
        server.annnounce(name, message)
    elseif (peer_id ~= nil and isNumber(peer_id)) then
        server.announce(name, message, peer_id)
    end
end

function addErrorMessage(message)
    g_savedata.errorData.errorMessage = g_savedata.errorData.errorMessage .. "|" .. message .. "| "
end

function getPlayerSaveData(peer_id)
    local steam_id = getPlayerSteamId(peer_id)
    return g_savedata.playerData[steam_id]
end

function getStringFromTable(T)
    local out = ""
    for i, v in pairs(T) do
        out = out .. tostring(i) .. ": " .. tostring(v) .. "; "
    end
    return out
end

function roundToTwoDecimalPlaces(v)
    return tonumber(string.format("%.2f", v))
end

function updateUIForPlayer(peer_id)
    local steam_id = getPlayerSteamId(peer_id)
    server.setPopupScreen(peer_id, g_savedata.playerData[steam_id].moneyUiId, "", true, "Balance: $" .. getMoney(peer_id)
        , 0.56, 0.88)
end

function updateUIAll()
    local player = server.getPlayers()
    for k, peer_id in pairs(player.id) do
        updateUIForPlayer(peer_id)
    end
end
