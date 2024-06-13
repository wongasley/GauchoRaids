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

ISRaidContextMenu = {}

function ISRaidContextMenu.doBuildMenu (player, context, worldobjects, test)
    print("checking if raideable")
	if test and ISWorldObjectContextMenu.Test then return true end

    local playerObj = getSpecificPlayer(player)
	if playerObj:getVehicle() then return; end

    local origSquare = worldobjects[1]:getSquare()

    -- java code is hardcoded to not emmit OnObjectRightMouseButtonUp event (and OnFillWorldObjectContextMenu)
    -- when right clicking on a safehouse square you dont belong... that prevents world context menu from being generated 
    -- so we will prompt raid context menu option when clicking on an tile adjacent to a safehouse

    local square = origSquare
    print("orig ", square)
    local safehouse = SafeHouse.getSafeHouse(square)
    if not safehouse then
        square = getSquare(origSquare:getX(), origSquare:getY() + 1, 0)
        print("1 ", square)
        safehouse = SafeHouse.getSafeHouse(square)
    end
    if not safehouse then
        local square = getSquare(origSquare:getX() + 1, origSquare:getY() + 1, 0)
        print("2 ", square)
        safehouse = SafeHouse.getSafeHouse(square)
    end
    if not safehouse then
        local square = getSquare(origSquare:getX() + 1, origSquare:getY(), 0)
        safehouse = SafeHouse.getSafeHouse(square)
    end
    if not safehouse then
        local square = getSquare(origSquare:getX() + 1, origSquare:getY() - 1, 0)
        safehouse = SafeHouse.getSafeHouse(square)
    end
    if not safehouse then
        local square = getSquare(origSquare:getX(), origSquare:getY() - 1, 0)
        safehouse = SafeHouse.getSafeHouse(square)
    end
    if not safehouse then
        local square = getSquare(origSquare:getX() - 1, origSquare:getY() - 1, 0)
        safehouse = SafeHouse.getSafeHouse(square)
    end
    if not safehouse then
        local square = getSquare(origSquare:getX() - 1, origSquare:getY(), 0)
        safehouse = SafeHouse.getSafeHouse(square)
    end
    if not safehouse then
        local square = getSquare(origSquare:getX() - 1, origSquare:getY() + 1, 0)
        safehouse = SafeHouse.getSafeHouse(square)
    end

    print("square > ", square)
    print("safehouse > ", safehouse)
    if (safehouse ~= nil and SandboxVars.GauchoRaids.Enabled) or (isAdmin() and safehouse ~= nil) then
        local playerObj = getSpecificPlayer(player)
        local playerAllowed = safehouse:playerAllowed(playerObj)
        print("player allowed > ", tostring(playerNotAllowed))
        print("players allowed list > ", tostring(safehouse:getPlayers()))
        print(safehouse:getX(), " ", safehouse:getY())

        -- safehouse
        if not playerAllowed or isAdmin() then
            print("adding raid menu!")
            context:addOption("RAID SAFEHOUSE", worldobjects, ISRaidContextMenu.onRaid, safehouse);
        end
    end
end

function ISRaidContextMenu.onRaid (worldobjects, safehouse)
    print("sending client command", tostring({ safehouse:getX(), safehouse:getY() }))
    sendClientCommand("GauchoRaids", "RaidRequest", { safehouse:getX(), safehouse:getY()})
    print("sent!!")
    local square = getSquare(safehouse:getX(), safehouse:getY(), 0)
    print(square)
    local safehouse2 = SafeHouse.getSafeHouse(square)
    print(safehouse2)
end


Events.OnFillWorldObjectContextMenu.Add(ISRaidContextMenu.doBuildMenu)