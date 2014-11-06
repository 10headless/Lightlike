require "lovenames"
flux = require "lib/flux"
cron = require "lib/cron"
sound = require "TEsound"
Camera = require "lib/camera"
bump = require "lib/bump"
require "states"
require "map"
require "player"
cWorld = nil
local coll = {}

function state_play:enter()
	empty = {x = 20, y = 20}
	cWorld = bump.newWorld(32)
	camera = Camera({follow_style = 'topdown', target = player, bounds = {left = 0, top = 0, right = blockSize*mapWidth, down = blockSize*mapHeight}, zoom = 2*1280/love.window.getWidth(), zoom2 = 2*720/love.window.getHeight()})
	map.generate()
	for i, v in ipairs(curMap) do
		for j, b in ipairs(v) do
			if b.char == 2 then
				table.insert(coll, {typ = "block", tX = i, tY = j, x = blockSize*(i-1), y = blockSize*(j-1), w = blockSize, h = blockSize})
			end
		end
	end
	for i, v in ipairs(coll) do
		cWorld:add(v, v.x, v.y, v.w, v.h)
	end	
end

function state_play:update(dt)
	camera:update(dt)
	flux.update(dt)
	player.update(dt)
end

function state_play:draw()
	camera:attach()
	map.draw()
	player.draw()
	camera:detach()
end

function state_play:keypressed(key)
	if key == " " then
		map.generate()
	end
	
end