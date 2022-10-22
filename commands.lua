function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, one, two, three, four, five)
    local playerData = getPlayerData(peer_id)
    local steam_id = playerData.steam_id
    -- make command lowercase
    local command = string.lower(command)

    -- help command
    if command == "?help" or "?h" then
        -- Help comes later aligator :)))))
        server.announce("[Help Center]", "Help not available jet!", peer_id)
    end

    -- other way to see current ballance
    if command == "?money" or "?ballance" or "?bal" then
        if g_savedata.playerData[steam_id] == nil then
            server.notify(peer_id, "[Bank]", "You dont have a bank account! Please rejoin the server!", 9)
            return
        end
        server.notify(peer_id, "[Bank]", "Your ballance is $ " .. getMoney(peer_id), 8)
    end

    -- send money to someone
    if command == "?sendmoney" or "?sm" then
        local creditorPeerId = tonumber(one)
        local amount = roundToTwoDecimalPlaces(tonumber(two))
        local debtorData = playerData
        local creditorData = getPlayerData(peer_id)

        local returnCode = transferMoney(peer_id, tonumber(creditorPeerId), tonumber(amount))
        if returnCode == 0 then
            server.notify(peer_id, "[Bank]",
                "You have send $ " .. roundToTwoDecimalPlaces(two) .. " to " .. creditorData.name .. ".", 8)
            server.notify(creditorPeerId, "[Bank]",
                "You have got $ " .. roundToTwoDecimalPlaces(amount) .. " from " .. debtorData.name .. ".", 8)
        end
    end

    -- admin command section
    -- this lets no not admin trough
    if not is_admin then return end

    -- add money to bank account
    if command == "?addmoney" or "?addm" or "?am" and is_admin then
        local creditorPeerId = tonumber(one)
        local creditorData = getPlayerData(creditorPeerId)
        local amount = roundToTwoDecimalPlaces(tonumber(two))
        local returnCode = addMoney(creditorPeerId, amount)

        if returnCode == 0 then
            server.notify(peer_id, "[Bank]", "You added $ " .. amount .. " to " .. creditorData.name .. " bank account."
                , 8)
            server.notify(creditorPeerId, "[Bank]", "You got $ " .. amount .. "!", 8)
        elseif returnCode == 1 then
            server.notify(peer_id, "[Bank]", creditorData.name .. " has no bank account!", 8)
        end
    end

    if command == "?removemoney" or "?removem" or "?remmoney" or "?rm" and is_admin then
        local debitorPeerId = tonumber(one)
        local debitorData = getPlayerData(debitorPeerId)
        local amount = roundToTwoDecimalPlaces(tonumber(two))
        local returnCode = addMoney(debitorPeerId, amount)

        if returnCode == 0 then
            server.notify(peer_id, "[Bank]", "You added $ " .. amount .. " to " .. debitorData.name .. " bank account."
                , 8)
            server.notify(debitorData, "[Bank]", "You got $ " .. amount .. "!", 8)
        elseif returnCode == 1 then
            server.notify(peer_id, "[Bank]", debitorData.name .. " has no bank account!", 8)
        end
    end
end
