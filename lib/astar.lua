local as = {}
as.map = {}
as.obst = {}
as.rooms = {}

function as.loadMap(map, obst)
	as.map = deepcopy(map)
	as.obst = obst
end

function as.loadRooms(r)
	as.rooms = deepcopy(r)
end

function as.findPath(startx, starty, endx, endy)
	local olist = {}
	local clist = {}
	local m = as.map

	table.insert(clist, {x = startx, y = starty, g=0, parent = nil})
	local lastChosen = {x = startx, y = starty, g = 0}
	repeat

		if not isListed({x = lastChosen.x-1, y = lastChosen.y}, clist) and 
			not checkIfObst(m[lastChosen.x-1][lastChosen.y].char) and 
			not isListed({x = lastChosen.x-1, y = lastChosen.y}, olist) then
			table.insert(olist, {x = lastChosen.x-1, y = lastChosen.y, parent = {x = lastChosen.x, y = lastChosen.y}})
		end
		if not isListed({x = lastChosen.x+1, y = lastChosen.y}, clist) and not checkIfObst(m[lastChosen.x+1][lastChosen.y].char) and not isListed({x = lastChosen.x+1, y = lastChosen.y}, olist) then
			table.insert(olist, {x = lastChosen.x+1, y = lastChosen.y, parent = {x = lastChosen.x, y = lastChosen.y}})
		end
		if not isListed({x = lastChosen.x, y = lastChosen.y+1}, clist) and not checkIfObst(m[lastChosen.x][lastChosen.y+1].char) and not isListed({x = lastChosen.x, y = lastChosen.y+1}, olist) then
			table.insert(olist, {x = lastChosen.x, y = lastChosen.y+1, parent = {x = lastChosen.x, y = lastChosen.y}})
		end
		if not isListed({x = lastChosen.x, y = lastChosen.y-1}, clist) and not checkIfObst(m[lastChosen.x][lastChosen.y-1].char) and not isListed({x = lastChosen.x, y = lastChosen.y-1}, olist) then
			table.insert(olist, {x = lastChosen.x, y = lastChosen.y-1, parent = {x = lastChosen.x, y = lastChosen.y}})
		end
		local smallest = {value = 1000, id = 1}
		for i, v in ipairs(olist) do
			if v.h == nil then
				for j, b in ipairs(clist) do
					if b.x == v.parent.x and b.y == v.parent.y then
						v.g = b.g+1
					end
				end
				v.h = math.abs(v.x-endx) + math.abs(v.y-endy)
				v.f = v.g + v.h

			end
			if v.f <= smallest.value then
				smallest = {value = v.f, id = i} 
			end
		end
		if #olist > 0 then
		if olist[smallest.id].h == 0 then
			lastChosen = deepcopy(olist[smallest.id])
			table.remove(olist, smallest.id)
			table.insert(clist, lastChosen)
			
			local path = {}
			local tmpStep = clist[#clist]
			repeat
				table.insert(path, tmpStep)
				local stg = deepcopy(tmpStep)
				if stg.parent ~= nil then
					for i, v in ipairs(clist) do
						
						if v.x == stg.parent.x and v.y == stg.parent.y then
							tmpStep = v
						end
					
					end
				else
					cleanUpMap()
					return path
				end
			until tmpStep == nil
				print(#path)
				cleanUpMap()
			return path
		else
			lastChosen = deepcopy(olist[smallest.id])
			table.remove(olist, smallest.id)
			table.insert(clist, lastChosen)
		end
	end
		
	until #olist == 0 
cleanUpMap()
	return nil
end







function checkIfObst(char)
	for i, v in ipairs(as.obst) do
		if v == char then
			return true
		end
	end
	return false
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function cleanUpMap()
	--[[for i, v in ipairs(as.map) do
		for j, b in ipairs(v) do
			as.map[i][j].closedListed = nil
			as.map[i][j].openListed = nil
		end
	end]]--
end

function isListed(pos, cl)
	for i, v in ipairs(cl) do
		if v.x == pos.x and v.y == pos.y then
			return true
		end
	end
	return false
end

return as


