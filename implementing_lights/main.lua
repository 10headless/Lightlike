require "camera2"
ray = require "raylight"
lg = love.graphics
player = {}

function love.load()
	curMap = {}
	for i = 1, 10 do
		curMap[i] = {}
		for j = 1, 10 do
			curMap[i][j] = {}
			curMap[i][j].char = 0
		end
	end
	curMap[6][4].char = 1
	coll = {}
		table.insert(coll, {tx = 6, ty = 4, x = 5*100, y = 3*100, w = 100, h = 100})
	ray.loadMap(coll)
	player = {x = 200, y = 200, w = 40}
end

function love.draw()
	player.tx = math.floor((player.x+player.w/2)/100)
	player.ty = math.floor((player.y+player.w/2)/100)
	lg.setColor(255,255,255)
	rayss = ray.castRays(player.x+player.w/2, player.y+player.w/2, player.tx, player.ty)
		for i, v in ipairs(coll) do
		lg.setColor(255,0,0)
		lg.rectangle("fill",v.x, v.y, v.w, v.h)
	end
	lg.setColor(0,255,0)
	lg.rectangle("fill", player.x, player.y, player.w, player.w)
end

function love.update(dt)
	if love.keyboard.isDown("a") then
		player.x = player.x - 100*dt
	end
	if love.keyboard.isDown("d") then
		player.x = player.x + 100*dt
	end
	if love.keyboard.isDown("w") then
		player.y = player.y - 100*dt
	end
	if love.keyboard.isDown("s") then
		player.y = player.y + 100*dt
	end
end