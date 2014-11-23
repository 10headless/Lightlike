require "lovenames"
require "lib/tablefunc"
local astar = require "lib/astar"
require "player"
require "enemy"
map = {}
curMap = {}
rooms = {}
walkable = 1

mapWidth = 80
mapHeight = 80
howManyRooms = 25
roomMaxHeight = 15
roomMaxWidth = 15
blockSize = 32
roomMinHeight = 8
roomMinWidth = 8

function map.draw()
	for i, v in ipairs(curMap) do
		if player.tx-12 < i and i < player.tx+12 then
			for j, b in ipairs(v) do
				if player.ty-12 < j and j < player.ty+12 then
					if b.char == 0 then
						lg.setColor(200, 0, 0)
						lg.rectangle("fill", blockSize*(i-1), blockSize*(j-1), blockSize, blockSize)
					end
					if b.char == 2 then
						lg.setColor(0, 0, 200)
						lg.rectangle("fill", blockSize*(i-1), blockSize*(j-1), blockSize, blockSize)
					end
					if b.char == 1 then
						lg.setColor(0, 0, 0)
						lg.rectangle("fill", blockSize*(i-1), blockSize*(j-1), blockSize, blockSize)
					end
				end
			end
		end
	end
end

function map.generate()
	local startTime = os.clock()
	local gener = true
	while gener do
		
		curMap = {}
		for i = 1, mapWidth do
			curMap[i] = {}
			for j = 1, mapHeight do
				curMap[i][j] = {}
				curMap[i][j].char = 0
			end
		end
		rooms = {}
		local corridors = {}
		local lastRoom = {}
		for i = 1, howManyRooms do
			local found = true

			while found do
				local rx = love.math.random(2, mapWidth-roomMaxWidth-2)
				local ry = love.math.random(2, mapHeight-roomMaxHeight-2)
				local rw = love.math.random(roomMinWidth, roomMaxWidth)
				local rh = love.math.random(roomMinHeight, roomMaxHeight)

				local is = true
				for j, b in ipairs(rooms) do
					if checkCollision(rx, ry, rw, rh, b.x, b.y, b.w, b.h) then
						is = false
					end
				end
				if is then
					found = false
					table.insert(rooms, {x = rx, y = ry, w = rw, h = rh, cx = math.floor(rx+rw/2), cy = math.floor(ry+rh/2)})
				end
			end
		end
		for i, v in ipairs(rooms) do
			local closestRoom = {}
			local secondClosest = {}
			for j, b in ipairs(rooms) do
				if i~=j then
					if closestRoom.cx ~= nil then
						if calcDis(b.cx, b.cy, v.cx, v.cy) < calcDis(closestRoom.cx, closestRoom.cy, v.cx, v.cy) then
							if v.connectedWith == nil or (v.connectedWith[1] ~= j and v.connectedWith[2] ~= j) then
								secondClosest = deepcopy(closestRoom)
								secondClosest.id = j
								closestRoom = deepcopy(b)
								closestRoom.id = j
							end
						else
							if secondClosest.cx ~= nil then
								if calcDis(b.cx, b.cy, v.cx, v.cy) < calcDis(secondClosest.cx, secondClosest.cy, v.cx, v.cy) then
									secondClosest = deepcopy(b)
									secondClosest.id = j
								end
							else
								secondClosest = deepcopy(b)
								secondClosest.id = j
							end
						end
					else
						closestRoom = deepcopy(b)
						closestRoom.id = j
					end
				end
			end

			if closestRoom.cy-v.cy > 0 then
				table.insert(corridors, {x = v.cx, y = v.cy, w = 2, h = closestRoom.cy-v.cy+1})
			else
				table.insert(corridors, {x = v.cx, y = v.cy, w = 2, h = closestRoom.cy-v.cy})
			end
			table.insert(corridors, {x = v.cx, y = closestRoom.cy, h = 2, w = closestRoom.cx-v.cx})
			if secondClosest.cy-v.cy > 0 then
				table.insert(corridors, {x = v.cx, y = v.cy, w = 2, h = secondClosest.cy-v.cy+1})
			else
				table.insert(corridors, {x = v.cx, y = v.cy, w = 2, h = secondClosest.cy-v.cy})
			end
			table.insert(corridors, {x = v.cx, y = secondClosest.cy, h = 2, w = secondClosest.cx-v.cx})
			rooms[closestRoom.id].connectedWith = {}
			rooms[secondClosest.id].connectedWith = {}
			rooms[closestRoom.id].connectedWith[1] = i
			rooms[secondClosest.id].connectedWith[2] = i
		end
		for i, v in ipairs(rooms) do
			for j = 1, v.w do
				for k = 1, v.h do
					curMap[j+v.x][k+v.y].char = 1
				end
			end	
		end
		
		for i, v in ipairs(corridors) do
			for j = 0, math.abs(v.w)-1 do
				for k = 0, math.abs(v.h)-1 do
					curMap[v.x + j * math.sign(v.w)][v.y + k * math.sign(v.h)].char = 1
				end
			end
		end
		local connected = true
		astar.loadMap(curMap, {0})
		for i, v in ipairs(rooms) do
			if i~=1 then
				local path = astar.findPath(rooms[1].cx, rooms[1].cy, v.cx, v.cy)
				if path == nil then
					connected = false
				end
			end	
		end
		
		if connected then
			gener = false
		end
		
	end
	local endTime = os.clock()
	print(endTime-startTime)
	for x, v in ipairs(curMap) do
		for y, n in ipairs(v) do
			if n.char == 0 then
				if x>1 and y>1 and x<mapWidth and y<mapHeight then
					if (curMap[x-1][y].char ~= 0 and curMap[x-1][y].char ~= 2) then
						curMap[x][y].char = 2
					end
					if (curMap[x+1][y].char ~= 0 and curMap[x+1][y].char ~= 2) then
						curMap[x][y].char = 2
					end
					if (curMap[x][y+1].char ~= 0 and curMap[x][y+1].char ~= 2) then
						curMap[x][y].char = 2
					end
					if (curMap[x][y-1].char ~= 0 and curMap[x][y-1].char ~= 2) then
						curMap[x][y].char = 2
					end
				end
			end
		end
	end

	--RANDOM STTTUUUUUUUFFF
	local rand_player = 0
	local rand_end = 0
	repeat
		rand_player = love.math.random(1, #rooms)
		rand_end = love.math.random(1, #rooms)
	until rand_player ~= rand_end

	player.load(blockSize*(rooms[rand_player].cx-1), blockSize*(rooms[rand_player].cy-1))
	enemy.load(blockSize*(rooms[rand_player].cx+1), blockSize*(rooms[rand_player].cy+1), blockSize-5, blockSize-5)
end


function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function calcDis(x1, y1, x2, y2)
	return math.sqrt(math.abs(x1-x2)^2+math.abs(y1-y2)^2)
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

 function math.sign(x)
   if x<0 then
     return -1
   elseif x>0 then
     return 1
   else
     return 0
   end
end