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
            server.notify(creditorName, "[Bank]", "You got $ " .. amount .. "!", 8)
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
