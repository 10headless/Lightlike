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
require "bullet"
require "enemy"
PROBE = require 'PROBE'

-- Profiler for drawing operations (set up in love.load()) with a sliding
-- window size of 60 cycles. Too few cycles and the visualization will be too
-- jittery to be legible; too many cycles and the visualization will lag
-- behind. 60-ish cycles is a good compromise between smoothness and
-- responsiveness.
dProbe = PROBE.new(60)

-- profiler for update operations (set up in love.load())
uProbe = PROBE.new(60)
dProbe:hookAll(_G, 'draw', {love})
	-- Same deal to profile update operations.
	uProbe:hookAll(_G, 'update', {love})
	dProbe:enable(true)
	uProbe:enable(true)


cWorld = nil
camera = {}
coll = {}
local empty = {x = 0, y = 0}

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
	uProbe:startCycle()
	camera:update(dt)
	flux.update(dt)
	player.update(dt)
	bullet.update(dt)
	enemy.update(dt)
	uProbe:endCycle()
end

function state_play:draw()
	dProbe:startCycle()
	camera:attach()
	map.draw()
	bullet.draw()
	player.draw()
	enemy.draw()
	camera:detach()
	cam2:set()
	inventory.draw()
	cam2:unset()
	dProbe:endCycle()

	love.graphics.setColor(255, 255, 255)
	dProbe:draw(20, 20, 150, 560, "DRAW CYCLE")
	uProbe:draw(630, 20, 150, 560, "UPDATE CYCLE")
end

function state_play:keypressed(key)
	if key == " " then
		map.generate()
	end
	inventory.kpressed(key) --after calling this it automatically goes to player.kpressed
end

function state_play:mousepressed(x, y, key)
	inventory.mpressed(key, x, y) --after calling this it automatically goes to player.mpressed
end