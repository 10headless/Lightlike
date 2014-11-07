require "lovenames"
flux = require "lib/flux"
cron = require "lib/cron"
sound = require "lib/TEsound"
Camera = require "lib/camera"
bump = require "lib/bump"
require "states"
require "map"
require "player"
require "inventory"
require "lib/camera2"
cWorld = nil
camera = {}
local coll = {}
local empty = {x = 0, y = 0}
camera2 = {}
function state_play:enter()
	empty = {x = 20, y = 20}
	cWorld = bump.newWorld(32)
	camera = Camera({follow_style = 'topdown', target = player, bounds = {left = 0, top = 0, right = blockSize*mapWidth, down = blockSize*mapHeight}, zoom = 2*1280/love.window.getWidth(), zoom2 = 2*720/love.window.getHeight()})
	cam2:setScale(854/love.window.getWidth(), 480/love.window.getHeight())
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
	cam2:set()
	inventory.draw()
	cam2:unset()
end

function state_play:keypressed(key)
	if key == " " then
		map.generate()
	end
	inventory.kpressed(key)
end

function state_play:mousepressed(x, y, key)
	inventory.mpressed(key, x, y)
end