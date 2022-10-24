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
