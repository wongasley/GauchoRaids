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

if not isClient() then
    return
end


GauchoRaidClientState = {}
GauchoRaidClientState.raidedBy = {}
GauchoRaidClientState.isRaiding = false


function OnServerCommandGauchoRaid(module, command, params)
    if SandboxVars.GauchoRaids.Enabled then
        if module ~= "GauchoRaids" then
            return
        end

        if command == "RaiderAccepted" then
            print("RAID ACCEPTED!!")
            local safehouse = GauchoRaidsUtils.GetSafeHouse(params[1], params[2])
            print("safe > ", safehouse)
            if safehouse then
                safehouse:addPlayer(getPlayer():getUsername())
                local players = safehouse:getPlayers()
                print("current players > ", tostring(players))
            end
            GauchoRaidClientState.isRaiding = true
        end

        if command == "RaiderActive" then
            GauchoRaidClientState.isRaiding = true
            print("raider active!!")
            for i,raiderName in pairs(params[3]) do
                print("adding raider ", raiderName)
                local safehouse = GauchoRaidsUtils.GetSafeHouse(params[1], params[2])
                local player = GauchoRaidsUtils.GetPlayerByUsername(raiderName)
                if player and safehouse then
                    local _isInSafe = GauchoRaidsUtils.IsInSafe(raiderName, safehouse)
                    if not _isInSafe then
                        print("raider was not in safe!!")
                        safehouse:addPlayer(player:getUsername())
                    end
                end
            end
        end

        if command == "RaiderFinished" then
            print("RAID FINISHED!!")
            local safehouse = GauchoRaidsUtils.GetSafeHouse(params[1], params[2])
            print("safe > ", safehouse)
            if safehouse then
                safehouse:removePlayer(getPlayer():getUsername())
                local raiders = params[3]
                for k,raiderName in pairs(raiders) do
                    safehouse:removePlayer(raiderName)
                end
                local players = safehouse:getPlayers()
                print("current players > ", tostring(players))
                GauchoRaidsUtils.KickOutFromSafeHouse(getPlayer(), safehouse)
            end
            GauchoRaidClientState.isRaiding = false
        end


        if command == "RaidedBy" then
            print("You are being raided!!")
            GauchoRaidClientState.raidedBy = params[3]
            local safehouse = GauchoRaidsUtils.GetSafeHouse(params[1], params[2])
            if safehouse then
                print(params)
                for i,_raiderName in ipairs(params[3]) do
                    safehouse:addPlayer(_raiderName)
                end
            end
        end


        if command == "RaidedFinished" then
            print("Raid finished!!")
            GauchoRaidClientState.raidedBy = {}
            print("raid finished!!")
            GauchoRaidClientState.raidedBy = params[3]
            local safehouse = GauchoRaidsUtils.GetSafeHouse(params[1], params[2])
            for i,_raiderName in ipairs(params[3]) do
                safehouse:removePlayer(_raiderName)
            end
        end


        if command == "DefaultRemoveFromSafehouse" then
            local safehouse = GauchoRaidsUtils.GetSafeHouse(params[1], params[2])
            if safehouse then
                print("kicked from safehouse!!")
                safehouse:removePlayer(getPlayer():getUsername())
                GauchoRaidsUtils.KickOutFromSafeHouse(getPlayer(), safehouse)
            end
        end
    end
end

Events.OnServerCommand.Add(OnServerCommandGauchoRaid)
