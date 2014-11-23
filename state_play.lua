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
require "lib/camera3"
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

function state_play:enter()
	cWorld = bump.newWorld(32)
	cam:setScale(640/love.window.getWidth(), 360/love.window.getHeight())
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
	flux.update(dt)
	player.update(dt)
	bullet.update(dt)
	enemy.update(dt)

	cam.x, cam.y = player.x-(love.window.getWidth()*cam.scaleX)/2, player.y-(love.window.getHeight()*cam.scaleY)/2
	uProbe:endCycle()
end

function state_play:draw()
	dProbe:startCycle()
	cam:set()
	map.draw()
	player.draw()
	bullet.draw()
	enemy.draw()
	cam:unset()
	love.graphics.setBlendMode("alpha")
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