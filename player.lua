require "lovenames"
require "inventory"

player = {}

function player.load(X, Y)
	if cWorld:hasItem(player) then
		cWorld:remove(player)
	end
	player.typ = "player"
	player.x = X
	player.y = Y
	player.w = 20
	player.h = 20
	player.xvel = 0
	player.yvel = 0
	player.speed = 750
	player.friction = 6
	cWorld:add(player, player.x, player.y, player.w, player.h)
	inventory.load()
end

function player.draw()
	lg.setColor(0, 255, 0)
	lg.rectangle("fill", player.x, player.y, player.w, player.h)
end


function player.update(dt)
	


	if love.keyboard.isDown("a") then
		player.xvel = player.xvel - player.speed*dt
	end
	if love.keyboard.isDown("d") then
		player.xvel = player.xvel + player.speed*dt
	end
	if love.keyboard.isDown("w") then
		player.yvel = player.yvel - player.speed*dt
	end
	if love.keyboard.isDown("s") then
		player.yvel = player.yvel + player.speed*dt
	end
	
	local collisions, len = cWorld:check(player, player.x + player.xvel*dt, player.y + player.yvel*dt)
	if len > 0 then

		for i, v in ipairs(collisions) do
			if v.other.typ == "block" then
				local tl, tt, nx, ny = v:getTouch()
				
				if math.abs((v.other.x+v.other.w/2) - (player.x+player.w/2)) > math.abs((v.other.y+v.other.h/2) - (player.y+player.h/2)) then
					player.xvel = 0
					player.x = tl
					player.y = player.y + player.yvel * dt
					player.yvel = player.yvel * (1 - math.min(dt*player.friction, 1))
				else
					player.yvel = 0
					player.y = tt
					player.x = player.x + player.xvel * dt
					player.xvel = player.xvel * (1 - math.min(dt*player.friction, 1))
				end
			end
		end
	else
		player.x = player.x + player.xvel * dt
		player.y = player.y + player.yvel * dt
		player.xvel = player.xvel * (1 - math.min(dt*player.friction, 1))
		player.yvel = player.yvel * (1 - math.min(dt*player.friction, 1))
		
	end
	cWorld:move(player, player.x, player.y, player.w, player.h)
end
