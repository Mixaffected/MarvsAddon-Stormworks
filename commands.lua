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
        debugMessage("In bal")
        if g_savedata.playerData[steam_id] == nil then
            server.notify(peer_id, "[Bank]", "You dont have a bank account! Please rejoin the server!", 9)
            return
        end
        server.notify(peer_id, "[Bank]", "Your balance is $ " .. tostring(getMoney(peer_id)), 8)

        -- send money to someone
    elseif command == "?sendmoney" or command == "?sm" then
        debugMessage("In sendmoney")
        local creditorPeerId = tonumber(one)
        local amount = tonumber(roundToTwoDecimalPlaces(two))
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

    -- add money to bank account
    if command == "?addmoney" or command == "?addm" or command == "?am" and is_admin then
        debugMessage("In addm")
        local creditorPeerId = tonumber(one)
        local creditorData = getPlayerData(creditorPeerId)
        local amount = tonumber(roundToTwoDecimalPlaces(two))
        local returnCode = addMoney(creditorPeerId, amount)

        if returnCode == 0 then
            server.notify(peer_id, "[Bank]",
                "You added $ " .. tostring(amount) .. " to " .. creditorData.name .. " bank account."
                , 8)
            server.notify(creditorPeerId, "[Bank]", "You got $ " .. tostring(amount) .. "!", 8)
        elseif returnCode == 1 then
            server.notify(peer_id, "[Bank]", creditorData.name .. " has no bank account!", 8)
        end

    elseif command == "?removemoney" or command == "?remmo" or command == "?rm" and is_admin then
        debugMessage("In remm")
        local debitorPeerId = tonumber(one)
        local debitorData = getPlayerData(debitorPeerId)
        local amount = tonumber(roundToTwoDecimalPlaces(two))
        local returnCode = removeMoney(debitorPeerId, amount)

        if returnCode == 0 then
            server.notify(peer_id, "[Bank]",
                "You removed $ " .. tostring(amount) .. " from " .. debitorData.name .. " bank account."
                , 8)
            server.notify(debitorData, "[Bank]", "You lost $ " .. tostring(amount) .. "!", 8)
        elseif returnCode == 1 then
            server.notify(peer_id, "[Bank]", debitorData.name .. " has no bank account!", 8)
        end
    end
end
