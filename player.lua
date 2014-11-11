require "lovenames"
require "inventory"
local vector = require "lib/vector"
require "bullet"
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
	player.tx = 1
	player.ty = 1
	player.steps = {}
	player.stepT = 1
	player.maxstepT = 1
	cWorld:add(player, player.x, player.y, player.w, player.h)
	inventory.load()
end

function player.draw()
	lg.setColor(0, 255, 0)
	lg.rectangle("fill", player.x, player.y, player.w, player.h)
	local remSteps = {}
	for i, v in ipairs(player.steps) do
		lg.setColor(200, 200, 200, v.a)
		lg.circle("line", v.x, v.y, v.w)
		if v.a == 0 then
			table.insert(remSteps, i)
		end	
	end
	for i, v in ipairs(remSteps) do
		table.remove(player.steps, v)
	end
end


function player.update(dt)
	
	player.tx = math.floor((player.x+player.w/2)/32)+1
	player.ty = math.floor((player.y+player.h/2)/32)+1

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
	local truth = true
	if len > 0 then

		for i, v in ipairs(collisions) do
			if v.other.typ == "block" then
				local tl, tt, nx, ny = v:getTouch()
				truth = false
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
		
		
	end
	if truth then
		player.x = player.x + player.xvel * dt
		player.y = player.y + player.yvel * dt
		player.xvel = player.xvel * (1 - math.min(dt*player.friction, 1))
		player.yvel = player.yvel * (1 - math.min(dt*player.friction, 1))
	end
	cWorld:move(player, player.x, player.y, player.w, player.h)
	if player.xvel < -5 or player.xvel > 5 or player.yvel > 5 and player.yvel < -5 then
		player.stepT = player.stepT + dt
		if player.stepT >= player.maxstepT then
			player.step()
			player.stepT = 0
		end
	else
		player.stepT = player.maxstepT
	end

	if love.mouse.isDown("l") then
		if equip[equipped].weapon then
			if equip[equipped].wAtr.ammo > 0 then
				if equip[equipped].wAtr.bullTime >= equip[equipped].wAtr.maxBullTime then
					local miwX, miwY = camera:getMousePosition()
					local difX = miwX-player.x
					local difY = miwY-player.y
					local r = love.math.random(1, 3)-2
					local tmp = math.atan2(math.abs(difY), math.abs(difX))+(love.math.random()*equip[equipped].wAtr.acc*r)
					local yv = math.sin(tmp)*bullet.speed
					local xv1 = bullet.speed^2 - yv^2 
					local xv2 = math.sqrt(xv1) 
					if difX < 0 then
						xv2 = -xv2
					end
					if difY < 0 then
						yv = -yv
					end

					bullet.load(player.x, player.y, xv2, yv)
					equip[equipped].wAtr.bullTime = 0
					equip[equipped].wAtr.ammo = equip[equipped].wAtr.ammo - 1
				else
					equip[equipped].wAtr.bullTime = equip[equipped].wAtr.bullTime + dt
				end
			end
		end
	else
		for i, v in ipairs(equip) do
			if v.weapon then
				v.wAtr.bullTime = v.wAtr.maxBullTime
			end
		end
	end
end

function player.mpressed(key, X, Y)
	local cax, cay = camera:getScale()
	local x = X/cax
	local y = Y/cay
	if key == "l" then
		
	end		
end

function player.kpressed(key)
	if key == "r" then
		if equip[equipped].wAtr.ammoWithMe >= equip[equipped].wAtr.maxAmmo then
			if equip[equipped].wAtr.ammo > 0 then
				local tmp = equip[equipped].wAtr.maxAmmo - equip[equipped].wAtr.ammo
				equip[equipped].wAtr.ammo = equip[equipped].wAtr.maxAmmo
				equip[equipped].wAtr.ammoWithMe = equip[equipped].wAtr.ammoWithMe - tmp
			else
				equip[equipped].wAtr.ammoWithMe = equip[equipped].wAtr.ammoWithMe - equip[equipped].wAtr.maxAmmo
				equip[equipped].wAtr.ammo = equip[equipped].wAtr.maxAmmo
			end
		else
			if equip[equipped].wAtr.ammo > 0 then
				local tmp = equip[equipped].wAtr.maxAmmo - equip[equipped].wAtr.ammo
				if tmp > equip[equipped].wAtr.ammoWithMe then
					equip[equipped].wAtr.ammo = equip[equipped].wAtr.maxAmmo
					equip[equipped].wAtr.ammoWithMe = equip[equipped].wAtr.ammoWithMe - tmp
				else
					equip[equipped].wAtr.ammo = equip[equipped].wAtr.ammoWithMe
					equip[equipped].wAtr.ammoWithMe = 0
				end
			else
				equip[equipped].wAtr.ammo = equip[equipped].wAtr.ammoWithMe
				equip[equipped].wAtr.ammoWithMe = 0
			end
		end
	end	
end



function player.step()
	table.insert(player.steps, {x = player.x+player.w/2, y = player.y+player.h/2, w = 0, a = 255, max = 100})
	flux.to(player.steps[#player.steps], 0.4, {w = player.steps[#player.steps].max}):after(player.steps[#player.steps], 0.2, {a = 0})
end
