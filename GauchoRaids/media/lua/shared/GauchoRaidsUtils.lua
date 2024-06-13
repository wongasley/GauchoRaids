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

GauchoRaidsUtils = {}

GauchoRaidsUtils.GetPlayerByUsername = function (username)
    local onlinePlayers = getOnlinePlayers()
    for p=0, onlinePlayers:size() - 1, 1 do
        local _player = onlinePlayers:get(p)
        if _player:getUsername() == username then
            return _player
        end
    end
end

GauchoRaidsUtils.GetSafeHouse = function (x, y)
    local safehouseList = SafeHouse.getSafehouseList()
    for i=0, safehouseList:size() - 1, 1 do
        local safehouse =  safehouseList:get(i)
        if safehouse:getX() == x and safehouse:getY() == y then
            return safehouse
        end
    end
end

GauchoRaidsUtils.getOwnedSafeHouse = function (player)
    local safehouseList = SafeHouse.getSafehouseList()
    local playerName = player:getUsername()
    for i=0, safehouseList:size() - 1, 1 do
        local safehouse =  safehouseList:get(i)
        if safehouse:getOwner() == safehouseList then
            return safehouse
        end
    end
end


GauchoRaidsUtils.IsInSafe = function (x, y)
    local safehouseList = SafeHouse.getSafehouseList()
    for i=0, safehouseList:size() - 1, 1 do
        local safehouse =  safehouseList:get(i)
        if safehouse:getX() == x and safehouse:getY() == y then
            return safehouse
        end
    end
end


-- when player belogns to a more than one safehouse, kickOutOfSafehouse does not work as expected...
-- the player is teleported outside the first safehouse returned by hasSafehouse method and not the raided safehouse
-- those are java methods, so we will mimic kickOutOfSafehouse in lua, and kick out of the right safehouse
GauchoRaidsUtils.KickOutFromSafeHouse = function (player, safehouse)
    if GauchoRaidsUtils.CheckIfPlayerInsideSafe(player, safehouse) then
        GauchoRaidsUtils.RepositionPlayer(
            player, safehouse:getX() - 2, safehouse:getY() - 2, 0
        )
    end
end

GauchoRaidsUtils.RepositionPlayer = function (player, x, y, z)
	print("going to ", x, y, z)
	player:setX(tonumber(x));
	player:setY(tonumber(y));
	player:setZ(tonumber(z));
	player:setLx(tonumber(x));
	player:setLy(tonumber(y));
	player:setLz(tonumber(z));
end


GauchoRaidsUtils.CheckIfPlayerInsideSafe = function (player, safehouse)
    print("check if raider ", player, " is inside ", safehouse)
    local pX = player:getX()
    local pY = player:getY()
    local sX = safehouse:getX()
    local sY = safehouse:getY()
    local sX2 = safehouse:getX2()
    local sY2 = safehouse:getY2()
    local inside = pX >= sX and pX < sX2 and pY >= sY and pY < sY2
    print("raider is inside > ", inside)
    return inside
end