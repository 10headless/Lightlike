require "lovenames"
require "player"
cron = require "lib/cron"
enemy = {}
local astar = require "lib/astar"
enemies = {}

function enemy.redo()
	for i, v in ipairs(enemies) do
		if v.ai.state == "chasing" then
			local etx = math.floor((v.x+v.h/2)/32)+1
			local ety = math.floor((v.y+v.w/2)/32)+1
			local see = false
			for i, v in ipairs(curMap) do
				if player.tx-15 < i and i < player.tx+15 then
					for j, b in ipairs(v) do
						if player.ty-15 < j and j < player.ty+15 then
							if b.char == 2 then
								if checkIntersect({x = (etx-1)*blockSize, y = (ety-1)*blockSize}, {x = (player.tx-1)*blockSize, y = (player.ty-1)*blockSize}, {x = (i-1)*blockSize, y = (j-1)*blockSize+blockSize/2}, {x = i*blockSize, y = (j-1)*blockSize+blockSize/2}) or
									checkIntersect({x = (etx-1)*blockSize, y = (ety-1)*blockSize}, {x = (player.tx-1)*blockSize, y = (player.ty-1)*blockSize}, {x = (i-1)*blockSize+blockSize/2, y = (j-1)*blockSize}, {x = (i-1)*blockSize+blockSize/2, y = j*blockSize}) then
									see = true
								end
							end
						end	
					end
				end
			end
			if see then
				v.ai.path = astar.findPath(player.tx, player.ty, etx, ety)
			else
				v.ai.path = nil
			end
		end
	end
end


local cr = cron.every(0.4, enemy.redo)

function enemy.load(x, y, w, h)
	table.insert(enemies, {x = x, y = y, w = w, h = h, ai = {state = "random", dir = nil, path = nil, lastDir = nil, lookDis = 160, seeTime = 0, maxSeeTime = 1.5}, typ = "enemy", xvel = 0, yvel = 0, speed = 80, ranSpeed = 30})
	cWorld:add(enemies[#enemies], x, y, w, h)
	astar.loadMap(curMap, {2})
end


function enemy.draw()
	for i, v in ipairs(enemies) do
		lg.setColor(200, 200, 0)
		lg.rectangle("fill", v.x, v.y, v.w, v.h)
		if v.ai.path ~= nil then
			for j, b in ipairs(v.ai.path) do
				lg.setColor(0,0,255)
				lg.rectangle("fill", (b.x-1)*32, (b.y-1)*32, 32, 32)
			end
		end
	end
end

function enemy.update(dt)
	cr:update(dt)
	enemy.AI(dt)
	enemy.collision(dt)
end

function enemy.collision(dt)
	for i, v in ipairs(enemies)do
		local collisions, len = cWorld:check(v)
		local truth = true
		if len > 0 then
			for j, b in ipairs(collisions) do
				if b.other.typ == "block" then
					local tl, tt, nx, ny = b:getTouch()
					if math.abs((b.other.x+b.other.w/2) - (v.x+v.w/2)) > math.abs((b.other.y+b.other.h/2) - (v.y+v.h/2)) then
						v.xvel = 0
						v.x = tl
					else
						v.yvel = 0
						v.y = tt
					end
					local d1 = nil
					local d2 = nil
					if v.ai.dir ~= nil then
						if v.ai.lastDir ~= nil then
							if v.ai.lastDir == "r" then
								d2 = 1
							elseif v.ai.lastDir == "l" then
								d2 = 2
							elseif v.ai.lastDir == "u" then
								d2 = 3
							elseif v.ai.lastDir == "d" then
								d2 = 4
							end
						end	
						if v.ai.dir == "r" then
							d1 = 1
						elseif v.ai.dir == "l" then
							d1 = 2
						elseif v.ai.dir == "u" then
							d1 = 3
						elseif v.ai.dir == "d" then
							d1 = 4
						end
					end
					local r = 0
					if d1 ~= nil then
						if d2 ~= nil then
							repeat
								r = love.math.random(1, 4)
							until r ~= d1 and r ~= d2
						else
							repeat
								r = love.math.random(1, 4)
							until r ~= d1
						end
					end
					v.ai.lastDir = v.ai.dir
					if r == 1 then
						v.ai.dir = "r"					
					elseif r == 2 then
						v.ai.dir = "l"
					elseif r == 3 then
						v.ai.dir = "u"
					elseif r == 4 then
						v.ai.dir = "d"
					end
				end
			end
		end
		v.x = v.x + v.xvel * dt
		v.y = v.y + v.yvel * dt
		cWorld:move(v, v.x, v.y)
	end
end

function enemy.AI(dt)
	for i, v in ipairs(enemies) do	
		if v.ai.state == "random" then
			if v.ai.dir ~= nil then
				if v.ai.dir == "r" then
					v.xvel = v.ranSpeed
				elseif v.ai.dir == "l" then
					v.xvel = -v.ranSpeed
				elseif v.ai.dir == "u" then
					v.yvel = -v.ranSpeed
				elseif v.ai.dir == "d" then
					v.yvel = v.ranSpeed
				end
				v.x = v.x + v.xvel * dt
				v.y = v.y + v.yvel * dt
				cWorld:move(v, v.x, v.y)
			else
				local r = love.math.random(1, 4)
				if r == 1 then
					v.ai.dir = "r"					
				elseif r == 2 then
					v.ai.dir = "l"
				elseif r == 3 then
					v.ai.dir = "u"
				elseif r == 4 then
					v.ai.dir = "d"
				end
			end


			local see = false
			if math.sqrt(math.abs(v.x-player.x)^2+math.abs(v.y-player.y)^2) < v.ai.lookDis then
				local etx = math.floor((v.x+v.h/2)/32)+1
				local ety = math.floor((v.y+v.w/2)/32)+1
				for i, v in ipairs(curMap) do
					if player.tx-15 < i and i < player.tx+15 then
						for j, b in ipairs(v) do
							if player.ty-15 < j and j < player.ty+15 then
								if b.char == 2 then
									if not checkIntersect({x = (etx-1)*blockSize, y = (ety-1)*blockSize}, {x = (player.tx-1)*blockSize, y = (player.ty-1)*blockSize}, {x = (i-1)*blockSize, y = (j-1)*blockSize+blockSize/2}, {x = i*blockSize, y = (j-1)*blockSize+blockSize/2}) or
										not checkIntersect({x = (etx-1)*blockSize, y = (ety-1)*blockSize}, {x = (player.tx-1)*blockSize, y = (player.ty-1)*blockSize}, {x = (i-1)*blockSize+blockSize/2, y = (j-1)*blockSize}, {x = (i-1)*blockSize+blockSize/2, y = j*blockSize}) then
										see = true
									end
								end
							end	
						end
					end
				end
			end
			if see then
				v.ai.seeTime = v.ai.seeTime + dt
				if v.ai.seeTime >= v.ai.maxSeeTime then
					v.ai.seeTime = 0
					v.ai.state = "chasing"
				end
			else
				v.ai.seeTime = 0
			end
		end
		if v.ai.state == "chasing" then
			local etx = math.floor((v.x+v.h/2)/32)+1
			local ety = math.floor((v.y+v.w/2)/32)+1
			if v.ai.path ~= nil then
				if v.x+v.w/2 > (v.ai.path[2].x-0.5)*blockSize then
					v.xvel = -v.speed
				else
					v.xvel = v.speed
				end
				if v.y+v.h/2 > (v.ai.path[2].y-0.5)*blockSize then
					v.yvel = -v.speed
				else
					v.yvel = v.speed
				end
			else
				if player.tx > etx then
					v.xvel = v.speed
				else
					v.xvel = -v.speed
				end
				if player.ty > ety then
					v.yvel = v.speed
				else
					v.yvel = -v.speed
				end
			end
		end
		if v.ai.state == "lookforplayer" then

		end
	end
end


function checkIntersect(l1p1, l1p2, l2p1, l2p2)
    local function checkDir(pt1, pt2, pt3) return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end
    return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end