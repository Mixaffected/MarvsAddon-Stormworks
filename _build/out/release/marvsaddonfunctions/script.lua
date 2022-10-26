-- Author: !true
-- GitHub: https://github.com/nottruenow64bit
-- Workshop: https://steamcommunity.com/id/QuestionmarkTrue/myworkshopfiles/



 
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
function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, one, two, three, four, five)
    local playerData = getPlayerData(peer_id)
    local steam_id = playerData.steam_id
    -- make command lowercase
    local command = string.lower(command)

    -- help command
    if command == "?help" or command == "?h" then
        debugMessage("In help")
        -- Help comes later aligator :)))))
        server.announce("[Help Center]", "Help not available jet!", peer_id)

        -- other way to see current balance
    elseif command == "?money" or command == "?balance" or command == "?bal" then
        debugMessage("In balance")
        if not hasBankAccount(peer_id) then
            server.notify(peer_id, "[Bank]", "You dont have a bank account! Please rejoin the server!", 9)
            return
        end
        server.notify(peer_id, "[Bank]", "Your balance is $ " .. tostring(getMoney(peer_id)), 8)

        -- send money to someone
    elseif command == "?sendmoney" or command == "?sendm" then
        debugMessage("In sendmoney")

        if not isStrNumber(one) or not isStrNumber(two) then
            debugMessage("Bad Argument")
            server.announce("[Bank]", "Bad argument! Please check your command and try again.", peer_id)
            return
        end

        local creditorPeerId = tonumber(one)

        if not isPeerIdExisting(creditorPeerId) then
            debugMessage("PeerID not existent")
            server.notify(peer_id, "[Bank]", "Bad PeerID! Please enter an existing one.", 8)
            return
        end

        if not hasBankAccount(creditorPeerId) or not hasBankAccount(peer_id) then
            debugMessage("Has no bank account")
            server.notify(peer_id, "[Bank]", "No bank account! This player has no bank account.", 8)
        end

        local amount = roundToTwoDecimalPlaces(two)
        local debtorData = playerData
        local creditorData = getPlayerData(peer_id)

        local returnCode = transferMoney(peer_id, tonumber(creditorPeerId), tonumber(amount))
        if returnCode == 0 then
            server.notify(peer_id, "[Bank]",
                "You have send $ " .. tostring(amount) .. " to " .. creditorData.name .. ".", 8)
            server.notify(creditorPeerId, "[Bank]",
                "You have got $ " .. tostring(amount) .. " from " .. debtorData.name .. ".", 8)
        end
    end

    -- admin command section
    -- this lets no not admin trough
    if not is_admin then return end

    -- set money from player to level
    if command == "?setmoney" or command == "?setm" or command == "?sm" and is_admin then
        debugMessage("In setmoney")

        if not isStrNumber(one) or not isStrNumber(two) then
            debugMessage("Bad Argument")
            server.notify(peer_id, "[Bank]", "Bad argument! Please check your command and try again.", 8)
            return
        end

        local targetPeerID = tonumber(one)

        if not isPeerIdExisting(targetPeerID) then
            debugMessage("PeerID not existent")
            server.notify(peer_id, "[Bank]", "Bad PeerID! Please enter an existing one.", 8)
            return
        end

        if not hasBankAccount(targetPeerID) then
            debugMessage("Has no bank account")
            server.notify(peer_id, "[Bank]", "No bank account! This player has no bank account.", 8)
        end

        local amount = roundToTwoDecimalPlaces(two)

        local returnCode = setMoney(targetPeerID, amount)

        if returnCode == 0 then
            server.notify(peer_id, "[bank]",
                "Balance from " .. getPlayerData(targetPeerID).name .. " set to $ " .. amount .. ".", 8)
            server.notify(targetPeerID, "[Bank]", "Your balance was set to $ " .. amount, 8)
        else
            returnCodesMessage(peer_id, returnCode, "[Bank]")
        end

        -- add money to bank account
    elseif command == "?addmoney" or command == "?addm" or command == "?am" and is_admin then
        debugMessage("In addmoney")

        if not isStrNumber(one) or not isStrNumber(two) then
            debugMessage("Bad Argument")
            server.notify(peer_id, "[Bank]", "Bad argument! Please check your command and try again.", 8)
            return
        end

        local creditorPeerId = tonumber(one)

        if not isPeerIdExisting(creditorPeerId) then
            debugMessage("PeerID not existent")
            server.notify(peer_id, "[Bank]", "Bad PeerID! Please enter an existing one.", 8)
            return
        end

        if not hasBankAccount(creditorPeerId) then
            debugMessage("Has no bank account")
            server.notify(peer_id, "[Bank]", "No bank account! This player has no bank account.", 8)
        end

        local creditorData = getPlayerData(creditorPeerId)
        local amount = roundToTwoDecimalPlaces(two)

        local returnCode = addMoney(creditorPeerId, amount)

        if returnCode == 0 then
            server.notify(peer_id, "[Bank]",
                "You added $ " .. tostring(amount) .. " to " .. creditorData.name .. " bank account."
                , 8)
            server.notify(creditorPeerId, "[Bank]", "You got $ " .. tostring(amount) .. "!", 8)
        else
            returnCodesMessage(peer_id, returnCode, "[Bank]")
        end

        -- remove money from bank account
    elseif command == "?removemoney" or command == "?removem" or command == "?remm" or command == "?rm" and is_admin then
        debugMessage("In removemoney")

        if not isStrNumber(one) or not isStrNumber(two) then
            debugMessage("Bad Argument")
            server.notify(peer_id, "[Bank]", "Bad argument! Please check your command and try again.", 8)
            return
        end

        local debitorPeerId = tonumber(one)

        if not isPeerIdExisting(debitorPeerId) then
            debugMessage("PeerID not existent")
            server.notify(peer_id, "[Bank]", "Bad PeerID! Please enter an existing one.", 8)
            return
        end

        if not hasBankAccount(debitorPeerId) then
            debugMessage("Has no bank account")
            server.notify(peer_id, "[Bank]", "No bank account! This player has no bank account.", 8)
        end

        local debitorData = getPlayerData(debitorPeerId)
        local amount = roundToTwoDecimalPlaces(two)

        if getMoney(debitorPeerId) < amount then return 2 end
        local returnCode = removeMoney(debitorPeerId, amount)

        if returnCode == 0 then
            server.notify(peer_id, "[Bank]",
                "You removed $ " .. tostring(amount) .. " from " .. debitorData.name .. " bank account."
                , 8)
            server.notify(debitorPeerId, "[Bank]", "You lost $ " .. tostring(amount) .. "!", 8)
        else
            returnCodesMessage(peer_id, returnCode, "[Bank]")
        end

        -- transfer money from one user to another
    elseif command == "?transfermoney" or command == "?transmoney" or command == "?transm" or
        command == "?tm" and is_admin then
        debugMessage("In transfermoney")

        if not isStrNumber(one) or not isStrNumber(two) or not isStrNumber(three) then
            debugMessage("Bad Argument")
            server.notify(peer_id, "[Bank]", "Bad argument! Please check your command and try again.", 8)
            return
        end

        local debitorPeerId = tonumber(two)
        local creditorPeerId = tonumber(one)

        if not isPeerIdExisting(debitorPeerId) or not isPeerIdExisting(creditorPeerId) then
            debugMessage("PeerID not existent")
            server.notify(peer_id, "[Bank]", "Bad PeerID! Please enter an existing one.", 8)
            return
        end

        if not hasBankAccount(debitorPeerId) or not hasBankAccount(creditorPeerId) then
            debugMessage("Has no bank account")
            server.notify(peer_id, "[Bank]", "No bank account! This player has no bank account.", 8)
        end

        local debitorName = getPlayerData(debitorPeerId).name
        local creditorName = getPlayerData(creditorPeerId).name
        local amount = roundToTwoDecimalPlaces(three)

        local returnCode = transferMoney(debitorPeerId, creditorPeerId, amount)
        if returnCode == 0 then
            server.notify(peer_id, "[Bank]",
                "Transfer successful! Money transfered from " .. debitorName .. " to " .. creditorName .. ".", 8)
            server.notify(debitorPeerId, "[Bank]", "You lost $ " .. amount .. "!", 8)
            server.notify(creditorPeerId, "[Bank]", "You got $ " .. amount .. "!", 8)
        else
            returnCodesMessage(peer_id, returnCode, "[Bank]")
        end

        -- let you see the balance of one player
    elseif command == "?showmoney" or command == "?showm" or command == "?showbalance" or
        command == "?showbal" and is_admin then
        if not isStrNumber(one) then
            debugMessage("Bad Argument")
            server.notify(peer_id, "[Bank]", "Bad argument! Please check your command and try again.", 8)
            return
        end

        local targetPeerID = tonumber(one)

        if not isPeerIdExisting(targetPeerID) then
            debugMessage("PeerID not existent")
            server.notify(peer_id, "[Bank]", "Bad PeerID! Please enter an existing one.", 8)
            return
        end

        if not hasBankAccount(targetPeerID) then
            debugMessage("Has no bank account")
            server.notify(peer_id, "[Bank]", "No bank account! This player has no bank account.", 8)
        end

        local balance = getMoney(targetPeerID)
    end
end



-- add the other files into one big chunky file
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

-- returns a bool when the peer id exists
function isPeerIdExisting(peer_id)
    local playerData = server.getPlayers()

    for k, v in pairs(playerData) do
        if tonumber(v.id) == tonumber(peer_id) then
            return true
        end
    end
    return false
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
    end
    return false
end

-- true if is a string when converted a number
function isStrNumber(string)
    if type(tonumber(string)) == "number" then
        return true
    else
        return false
    end
end

-- notifies that something got wrong
function returnCodesMessage(peer_id, returnCode, title)
    if returnCode == 1 then
        server.notify(peer_id, title, "Bank account not found!", 8)
    elseif returnCode == 2 then
        server.notify(peer_id, title, "User has not enough money!", 8)
    elseif returnCode == 10 then
        server.notify(peer_id, title, "Something went wrong! Try again.", 8)
    end
end
-- get money from peerID rounded
function getMoney(peer_id)
    local player = getPlayerData(peer_id)
    return roundToTwoDecimalPlaces(g_savedata.playerData[player.steam_id].money)
end

-- set money to the amount
function setMoney(peer_id, amount)
    local playerData = getPlayerData(peer_id)

    if not hasBankAccount(peer_id) then return 1 end

    local moneyBefore = getMoney(peer_id)

    g_savedata.playerData[playerData.steam_id].money = roundToTwoDecimalPlaces(amount)
    if getMoney(peer_id) <= 0 then
        g_savedata.playerData[playerData.steam_id].money = 0
    end

    if getMoney(peer_id) == roundToTwoDecimalPlaces(amount) then
        return 0
    else
        g_savedata.playerData[playerData.steam_id].money = moneyBefore
        return 10
    end
end

-- add money to an bank account
function addMoney(peer_id, amount)
    local player = getPlayerData(peer_id)
    local amount = tonumber(amount)

    if not hasBankAccount(peer_id) then return 1 end

    local balPlayer = getMoney(peer_id)

    g_savedata.playerData[player.steam_id].money = roundToTwoDecimalPlaces(g_savedata.playerData[player.steam_id].money +
        amount)
    local balTwoPlayer = roundToTwoDecimalPlaces(balPlayer + amount)

    if g_savedata.playerData[player.steam_id].money == balTwoPlayer then
        return 0
    end
    return 10
end

-- remove money from an bank account
function removeMoney(peer_id, amount, respectMoneyLimit)
    local player = getPlayerData(peer_id)
    local amount = tonumber(amount)
    local respectMoneyLimit = respectMoneyLimit or false

    if not hasBankAccount(peer_id) then return 1 end
    if getMoney(peer_id) >= amount and respectMoneyLimit then return 2 end

    local balPlayer = getMoney(peer_id)

    g_savedata.playerData[player.steam_id].money = roundToTwoDecimalPlaces(g_savedata.playerData[player.steam_id].money -
        amount)
    local balTwoPlayer = roundToTwoDecimalPlaces(balPlayer - amount)

    if g_savedata.playerData[player.steam_id].money <= 0 then g_savedata.playerData[player.steam_id].money = 0 end
    if balPlayer <= 0 then balPlayer = 0 end

    if getMoney(peer_id) == balTwoPlayer then
        return 0
    end
    return 10
end

-- transfer money between two bank accounts
function transferMoney(debtorPeerId, creditorPeerId, amount)
    local debtorData = getPlayerData(debtorPeerId)
    local creditorData = getPlayerData(creditorPeerId)
    local balDebitor = getMoney(debtorPeerId)
    local balCreditor = getMoney(creditorPeerId)
    local amount = roundToTwoDecimalPlaces(amount)

    if g_savedata.playerData[debtorData.steam_id].money < amount then
        server.notify(debtorPeerId, "[Bank]", "Your order has been canceled due to insufficient funds.", 8)
        return 2
    elseif not hasBankAccount(debtorPeerId) and not hasBankAccount(creditorPeerId) then
        server.notify(debtorPeerId, "[Bank]", "The opposite of your transaction or you don't have a bank account.", 8)
        return 1
    end

    local returnCodeDebitor = removeMoney(debtorPeerId, amount, true)
    local returnCodeCreditor = 10
    if returnCodeDebitor == 0 and balDebitor - amount == getMoney(debtorPeerId) then
        local returnCodeCreditor = addMoney(creditorPeerId, amount)
        if returnCodeCreditor == 0 and balCreditor + amount == getMoney(creditorPeerId) then
            return 0
        else
            setMoney(creditorPeerId, balCreditor)
            return 10
        end
    else
        setMoney(debtorPeerId, balDebitor)
        return 10
    end
end




