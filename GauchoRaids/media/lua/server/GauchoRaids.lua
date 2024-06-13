--*****************************************************     
--**  LICENSE
--**     
--**  This program is free software: you can redistribute it and/or modify it under the terms 
--**  of the GNU General Public License as published by the Free Software Foundation, 
--**  either version 3 of the License, or any later version.
--**  
--**  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
--**  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--**  See the GNU General Public License for more details.https://www.gnu.org/licenses/
--**  
--**  You should have received a copy of the GNU General Public License along with this program. 
--**  If not, see <https://www.gnu.org/licenses/>.
--**  
--**  
--**  Joaquin D. Gomez | inhousegames.dev      
--*****************************************************

if isClient() then
    return
end

RAIDING_TIME_DEFAULT = 10
RAID_PROTECTION_TIME_DEFAULT = 10
MAX_RAIDERS_DEFAULT = 3
EXRAIDER_TIME_DEFAULT = 60



-- some helper functions+
local raidsLogFile = "raids_logs.txt"

local function saveToLogFile(...)
    local text = ""
    local args = {...}
    for i,v in ipairs(args) do
        text = text .. " " .. tostring(v)
    end
    print(text)
    local fileWriterObj = getFileWriter(raidsLogFile, true, true)
    fileWriterObj:write(text .. " \n")
    fileWriterObj:close()
end

local function getRaidingTime()
    local time = SandboxVars.GauchoRaids["RaidingTime"]
    if time then
        return time
    end
    return RAIDING_TIME_DEFAULT
end

local function getExRaidingTime()
    local time = SandboxVars.GauchoRaids["ExRaidingTime"]
    if time then
        return time
    end
    return EXRAIDER_TIME_DEFAULT
end

local function getMaxRaiders()
    local time = SandboxVars.GauchoRaids["MaxRaiders"]
    if time then
        return time
    end
    return RAIDING_TIME_DEFAULT
end

local function getRaidProtectionTime()
    local time = SandboxVars.GauchoRaids["ProtectionTime"]

    local rnd = Math.max(Math:random(), 0.5)
    if time then
        return time * rnd
    end
    return RAID_PROTECTION_TIME_DEFAULT * rnd
end

local function getExRaiders()
    return getGameTime():getModData().GauchoExRaiders
end

local function getExRaider(k)
    return getGameTime():getModData().GauchoExRaiders[k]
end

local function removeExRaider(playerName)
    getGameTime():getModData().GauchoExRaiders[playerName] = nil
end

local function addRaidedToExRaider(playerName, x, y)
    local raided = tostring(x) .. "-" .. tostring(y)
    getGameTime():getModData().GauchoExRaiders[playerName].raided[raided] = {}
    getGameTime():getModData().GauchoExRaiders[playerName].raided[raided].remainingTime = getExRaidingTime()
    getGameTime():getModData().GauchoExRaiders[playerName].raided[raided].x = x
    getGameTime():getModData().GauchoExRaiders[playerName].raided[raided].y = y
end

local function removeRaidedFromExRaider(playerName, x, y)
    local exRaider = getExRaider(playerName)
    local raided = exRaider.raided
    if #raided < 1 then
        removeExRaider(playerName)
    end
end

local function createExRaider(playerName, x, y)
    local raider = getExRaider(playerName)
    if not raider then
        raider = {}
        raider.raided = {}
        getGameTime():getModData().GauchoExRaiders[playerName] = raider
    end
    addRaidedToExRaider(playerName, x, y)
end

local function getActiveRaiders()
    return getGameTime():getModData().GauchoActiveRaiders
end

local function getActiveRaider(playerName)
    return getGameTime():getModData().GauchoActiveRaiders[playerName]
end

local function createActiveRaider(playerName, x, y)
    getGameTime():getModData().GauchoActiveRaiders[playerName] = {}
    getGameTime():getModData().GauchoActiveRaiders[playerName].x = x
    getGameTime():getModData().GauchoActiveRaiders[playerName].y = y
end

local function removeActiveRaider(playerName)
    getGameTime():getModData().GauchoActiveRaiders[playerName] = nil
end

local function getActiveRaid(x, y)
    local k = (tostring(x) .. "-" .. tostring(y))
    return getGameTime():getModData().GauchoActiveRaids[k]
end

local function createActiveRaid(x, y)
    local k = (tostring(x) .. "-" .. tostring(y))
    getGameTime():getModData().GauchoActiveRaids[k] = {}
    getGameTime():getModData().GauchoActiveRaids[k].remainingTime = getRaidingTime()
    getGameTime():getModData().GauchoActiveRaids[k].x = x
    getGameTime():getModData().GauchoActiveRaids[k].y = y
    getGameTime():getModData().GauchoActiveRaids[k].count = 0
end

local function removeActiveRaid(x, y)
    local k = (tostring(x) .. "-" .. tostring(y))
    getGameTime():getModData().GauchoActiveRaids[k] = nil
end

local function getActiveRaids()
    return getGameTime():getModData().GauchoActiveRaids
end

local function increaseRaiderCount(x, y)
    local k = (tostring(x) .. "-" .. tostring(y))
    local current = getGameTime():getModData().GauchoActiveRaids[k].count
    getGameTime():getModData().GauchoActiveRaids[k].count = current + 1
    print("current raids increased to ", getGameTime():getModData().GauchoActiveRaids[k].count)
end

local function getRaiderCount(x, y)
    local k = (tostring(x) .. "-" .. tostring(y))
    local raid = getGameTime():getModData().GauchoActiveRaids[k]
    print("getting raider count for > ", raid)
    if raid then
        print("current raids, ", getGameTime():getModData().GauchoActiveRaids[k].count)
        return getGameTime():getModData().GauchoActiveRaids[k].count
    else
        print("current raids, ", 0)
        return 0
    end
end

local function IsProtected(x, y)
    local protectedSafeHouses = getGameTime():getModData().GauchoRaidProtectedSafehouses
    for k,protected in pairs(protectedSafeHouses) do
     if protected.position[1] == x and protected.position[2] == y then
         return true
     end
    end
 end

local function cannotRaidSafehouse(playerName, x, y)
    local activeRaider = getActiveRaider(playerName)
    if activeRaider then
        return true
    end
    local raider = getExRaider(playerName)
    if raider then
        local raided = tostring(x) .. "-" .. tostring(y)
        for k,v in pairs(raider.raided) do
            if k == raided then
                return true
            end
        end
    end
    return false
end

local function InitModData()
    local activeRaids = getGameTime():getModData().GauchoActiveRaids
    if activeRaids == nil then
        getGameTime():getModData().GauchoActiveRaids = {}
    end

    local exRaiders = getGameTime():getModData().GauchoExRaiders

    if exRaiders == nil then
        getGameTime():getModData().GauchoExRaiders = {}
    end

    local activeRaiders = getGameTime():getModData().GauchoActiveRaiders
    if activeRaiders == nil then
        getGameTime():getModData().GauchoActiveRaiders = {}
    end

    local protected = getGameTime():getModData().GauchoRaidProtectedSafehouses
    if protected == nil  then
        getGameTime():getModData().GauchoRaidProtectedSafehouses = {}
    end
end

local function ResetModData()
        getGameTime():getModData().GauchoActiveRaids = {}
        getGameTime():getModData().GauchoActiveRaiders = {}
        getGameTime():getModData().GauchoRaidProtectedSafehouses = {}
        getGameTime():getModData().GauchoExRaiders = {}
end

local function getSafeHouseRaiders(x, y)
    local p = 1
    local result = {}
    local _raiders = getActiveRaiders()

    for raider,data in pairs(_raiders) do
        if data then
            if data.x == x and data.y then
                result[p] = raider
                p = p + 1
            end
        end
    end
    return result
end

local function finishRaiders(x, y)
    saveToLogFile("finishing raiders -------------")
    local k = (tostring(x) .. "-" .. tostring(y))
    local safehouse = GauchoRaidsUtils.GetSafeHouse(x, y)

    local _raiders = getActiveRaiders()
    local this_raiders = getSafeHouseRaiders(x,y)
    saveToLogFile("raider count >", #_raiders)

    for raiderName,raidData in pairs(_raiders) do
        if raidData.x == x and raidData.y == y then
            if safehouse then
                saveToLogFile("removing from safe >", raiderName)
                safehouse:removePlayer(raiderName)
                safehouse:syncSafehouse()
            end

            createExRaider(raiderName, x, y)
            removeActiveRaider(raiderName)

            local raiderPlayerObj = GauchoRaidsUtils.GetPlayerByUsername(raiderName)
            if raiderPlayerObj then
                sendServerCommand(raiderPlayerObj, "GauchoRaids", "RaiderFinished", {x, y, this_raiders})
                if safehouse then
                    GauchoRaidsUtils.KickOutFromSafeHouse(raiderPlayerObj, safehouse)
                end
            end
        end
    end
end

local function notifyRaidees()
    local raids = getActiveRaids()
    for coordK,raidData in pairs(raids) do
        if raidData then
            local safehouse = GauchoRaidsUtils.GetSafeHouse(raidData.x, raidData.y)
            if safehouse then
                local safehousePlayers = safehouse:getPlayers()

                local raiders = getSafeHouseRaiders(raidData.x, raidData.y)

                for p=0, safehousePlayers:size() - 1, 1 do
                    local _playerName = safehousePlayers:get(p)
                    local _isRaider = false

                    local _activeRaiders = getActiveRaiders()
                    local _rc = 0
                    for raiderName,raiderData in pairs(_activeRaiders) do
                        _rc = _rc + 1
                        if raiderName == _playerName and raiderData then _isRaider = true end
                    end
                    if not _isRaider then
                        local safehousePlayerObj = GauchoRaidsUtils.GetPlayerByUsername(_playerName)
                        sendServerCommand(safehousePlayerObj, "GauchoRaids", "RaidedBy", {raidData.x, raidData.y, raiders})
                    end
                end

                local _safeOwner = safehouse:getOwner()
                local ownerObj = GauchoRaidsUtils.GetPlayerByUsername(_safeOwner)
                if ownerObj then
                    sendServerCommand(ownerObj, "GauchoRaids", "RaidedBy", {raidData.x, raidData.y, raiders})
                end
            end
        end
    end

end

local function sendActiveRaider()
    local _activeRaiders = getActiveRaiders()
    local _activeRaids = getActiveRaids()
    local _raidersInRaids = {}

    for coord,raid in pairs(_activeRaids) do
        _raidersInRaids[coord] = getSafeHouseRaiders(raid.x, raid.y)
    end

    for raiderName,raidData in pairs(_activeRaiders) do
        local raiderObj = GauchoRaidsUtils.GetPlayerByUsername(raiderName)
        if raiderObj then
            local otherRaiders = getSafeHouseRaiders(raidData.x, raidData.y)
            sendServerCommand(raiderObj, "GauchoRaids", "RaiderActive", {raidData.x, raidData.y, otherRaiders})
        end
    end
end

local function requestRaid(player, x, y)
    saveToLogFile("REQUEST RAID -------------------")
    local playerName = player:getUsername()
    saveToLogFile("Requester >", playerName, "\n", "Safehouse location >", x, y)

    if cannotRaidSafehouse(playerName, x, y) then
        saveToLogFile("EX RAIDER denied!")
        return
    end

    local raiderCount = getRaiderCount(x, y)
    local maxRaiders = getMaxRaiders()
    saveToLogFile("Current raiders", raiderCount, "/ max", maxRaiders)

    if raiderCount >= maxRaiders then
        saveToLogFile("maximum raiders reached, denied!")
        return
    end

    if not IsProtected(x, y) then
        local safehouse = GauchoRaidsUtils.GetSafeHouse(x, y)
        if safehouse then

            local activeRaid = getActiveRaid(x, y)
            local activeRaider = getActiveRaider(playerName)

            if not activeRaider then
                if not activeRaid then
                    saveToLogFile("NEW RAID started by", playerName)
                    createActiveRaid(x, y)
                    increaseRaiderCount(x, y)
                else
                    saveToLogFile("Adding", playerName, "to the raid")
                    increaseRaiderCount(x, y)
                end

                createActiveRaider(playerName, x, y)

                safehouse:addPlayer(playerName)
                sendServerCommand(player, "GauchoRaids", "RaiderAccepted", {x, y})

                notifyRaidees()
                sendActiveRaider()
            end
        end
    else
        saveToLogFile("safe is protected at >", x, y)
        sendServerCommand(player, "GauchoRaids", "RaiderRejected", {x, y})
    end
end

local function addProtection(x, y)
    local k = (tostring(x) .. "-" .. tostring(y))
    saveToLogFile("adding protection to", k)
    getGameTime():getModData().GauchoRaidProtectedSafehouses[k] = {}
    getGameTime():getModData().GauchoRaidProtectedSafehouses[k].remainingTime = getRaidProtectionTime()
    getGameTime():getModData().GauchoRaidProtectedSafehouses[k].position = {x, y}
end

-- minute/hour functions
local function checkRaidsTime()
    local _raiders = getActiveRaiders()
    local _raids = getActiveRaids()
    if #_raiders > 0 then
        saveToLogFile("checkRaidsTime --- current raids", #_raids)
    end

    for coordStr,raidData in pairs(_raids) do
        if raidData then
            local safehouse = GauchoRaidsUtils.GetSafeHouse(raidData.x, raidData.y)
            if not safehouse then
                finishRaiders(raidData.x, raidData.y)
                removeActiveRaid(raidData.x, raidData.y)
                notifyRaidees()
            else
                if raidData.remainingTime <= 0 then

                    saveToLogFile("stop raid at >", raidData.x, raidData.y, "\n",
                                  "raiders count >", getRaiderCount(raidData.x, raidData.y))
                    finishRaiders(raidData.x, raidData.y)
                    removeActiveRaid(raidData.x, raidData.y)
                    notifyRaidees()

                    addProtection(raidData.x, raidData.y)

                    local safehousePlayers = safehouse:getPlayers()

                else
                    raidData.remainingTime = raidData.remainingTime - 1
                    saveToLogFile("raid active at >", raidData.x, raidData.y, "time remaining", raidData.remainingTime, "raiders", raidData.count)
                    notifyRaidees()
                    sendActiveRaider()
                end
            end
        end
    end
end

local function checkProtectionTime()
    local protectedSafeHouses = getGameTime():getModData().GauchoRaidProtectedSafehouses
    for k,protected in pairs(protectedSafeHouses) do
        local  _remtime = protected.remainingTime
        saveToLogFile("checking", k, "remaining time > ", _remtime)
        if protected then
            if _remtime <= 0 then
                getGameTime():getModData().GauchoRaidProtectedSafehouses[k] = nil
                saveToLogFile("protection safehouse", k, "FINISHED!")
                return
            end
            protected.remainingTime = protected.remainingTime - 1
            saveToLogFile("protection safehouse", k, "time remaining", protected.remainingTime)
        end
    end
end

local function checkExRaiders()
    local exraiders = getExRaiders()
    for raiderName,data in pairs(exraiders) do
        if data then
            for key,raid in pairs(data.raided) do
                local  _remtime = raid.remainingTime
                saveToLogFile("checking", raiderName, "remaining time > ", _remtime)
                if _remtime <= 0 then
                    removeRaidedFromExRaider(raiderName, raid.x, raid.y)
                    saveToLogFile(raiderName, " can now raid ", tostring(raid.x) .. "-" .. tostring(raid.y))
                    return
                end
                raid.remainingTime = raid.remainingTime - 1
                saveToLogFile("exraider", raiderName, "time remaining", raid.remainingTime)

                local safehouse = GauchoRaidsUtils.GetSafeHouse(raid.x, raid.y)
                if safehouse then
                    safehouse:removePlayer(raiderName)
                    safehouse:syncSafehouse()
                end

                local raiderPlayerObj = GauchoRaidsUtils.GetPlayerByUsername(raiderName)
                if raiderPlayerObj then
                    sendServerCommand(raiderPlayerObj, "GauchoRaids", "RaiderFinished", {raid.x, raid.y, {}})
                end
            end
        end
    end
end

local function CheckProtectionPerMinute()
    if SandboxVars.GauchoRaids.MeasuredIn == 1  and SandboxVars.GauchoRaids.Enabled then
        checkProtectionTime()
    end
end

local function CheckRaidersPerMinute()
    if SandboxVars.GauchoRaids.MeasuredIn == 1  and SandboxVars.GauchoRaids.Enabled then
        print("Raid per minute check...")
        checkRaidsTime()
    end
end

local function CheckExRaidersPerMinute()
    if SandboxVars.GauchoRaids.MeasuredIn == 1  and SandboxVars.GauchoRaids.Enabled then
        checkExRaiders()
    end
end

local function CheckProtectionPerHour()
    if SandboxVars.GauchoRaids.MeasuredIn == 3  and SandboxVars.GauchoRaids.Enabled then
        checkProtectionTime()
    end
end

local function CheckRaidersPerHour()
    if SandboxVars.GauchoRaids.MeasuredIn == 3  and SandboxVars.GauchoRaids.Enabled then
        print("Raid per hour check...")
        checkRaidsTime()
    end
end

local function CheckExRaidersPerHour()
    if SandboxVars.GauchoRaids.MeasuredIn == 3  and SandboxVars.GauchoRaids.Enabled then
        checkExRaiders()
    end
end

local function CheckResetModData()
    if SandboxVars.GauchoRaids.ResetRaids then
        saveToLogFile("RAID DATA RESETED!")
        ResetModData()
        SandboxVars.GauchoRaids["ResetRaids"] = false
    end
end



Events.EveryOneMinute.Add(CheckProtectionPerMinute)
Events.EveryOneMinute.Add(CheckRaidersPerMinute)
Events.EveryOneMinute.Add(CheckExRaidersPerMinute)
Events.EveryHours.Add(CheckProtectionPerHour)
Events.EveryHours.Add(CheckRaidersPerHour)
Events.EveryHours.Add(CheckExRaidersPerHour)

Events.OnServerStarted.Add(InitModData)
Events.EveryOneMinute.Add(CheckResetModData)



-- client commands handling
function OnClientCommandGauchoRaid(module, command, player, params)
    if SandboxVars.GauchoRaids.Enabled then
        if module ~= "GauchoRaids" then
            return
        end

        if command == "RaidRequest" then
            print("RaidRequest received!")
            requestRaid(player, params[1], params[2])
        end

        if command == "RaidCheck" then
            raidCheck(player, params[1], params[2])
        end

        if command == "DefaultRemoveFromSafehouse" then
            saveToLogFile("Received remove safehouse")
            local removedPlayerName = params[3]
            local safehouse = GauchoRaidsUtils.GetSafeHouse(params[1], params[2])
            if safehouse then
                saveToLogFile("REMOVING", removedPlayerName, "from", params[1], params[2], safehouse)
                safehouse:removePlayer(removedPlayerName)
                safehouse:syncSafehouse()
                local removedPlayer = GauchoRaidsUtils.GetPlayerByUsername(removedPlayerName)
                if removedPlayer then
                    GauchoRaidsUtils.KickOutFromSafeHouse(removedPlayer, safehouse)
                    sendServerCommand(removedPlayer, "GauchoRaids", "DefaultRemoveFromSafehouse", {params[1], params[2], removedPlayerName})
                end
            end
        end
    end
end

Events.OnClientCommand.Add(OnClientCommandGauchoRaid)