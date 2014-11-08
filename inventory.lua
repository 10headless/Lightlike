require "lovenames"

inventory = {}
equip = {}
spaces = 6
equipped = 1
local fonty = lg.newFont(12)

function inventory.load()
	table.insert(equip, {item_name = "AK-47", item_id = 1, weapon = true, wAtr = {dmg = 10, acc = math.pi/15, ammo = 30, maxAmmo = 30, ammoWithMe = 60, bullTime = 0.1, maxBullTime = 0.1}})
end

function inventory.draw()
	lg.setColor(150, 150, 150)
	lg.rectangle("fill", 854/2-(320+spaces*11)/2, 480-(32+spaces*2)-12, 320+spaces*11, 32+spaces*2+12)
	for i = 1, 10 do
		lg.setColor(200,200,200)
		if i ~= equipped then
			lg.rectangle("line", 854/2-(320+spaces*11)/2+(32+spaces)*(i-1)+spaces, 480-(32+spaces), 32, 32)
		else
			lg.rectangle("fill", 854/2-(320+spaces*11)/2+(32+spaces)*(i-1)+spaces, 480-(32+spaces), 32, 32)
			if equip[i] ~= nil then
				lg.setColor(250,250,250)
				lg.setFont(fonty)
				lg.print(equip[i].item_name, 854/2-fonty:getWidth(equip[i].item_name)/2, 480-(32+spaces*2)-12+2)
			end
		end
	end	
	for i, v in ipairs(equip) do

	end
end

function inventory.update(dt)

end

function inventory.mpressed(key, X, Y)
	local x = X*cam2.scaleX
	local y = Y*cam2.scaleY
	if key == "wu" then
		if equipped == 1 then
			equipped = 10
		else
			equipped = equipped - 1
		end
	elseif key == "wd" then
		if equipped == 10 then
			equipped = 1
		else
			equipped = equipped + 1
		end
	end
	if key == "l" then
		if x>854/2-(320+spaces*11)/2 and x<(854/2-(320+spaces*11)/2)+(320+spaces*11) and y > 480-(32+spaces*2)-12 and y < (480-(32+spaces*2)-12) + (32+spaces*2+12) then
			for i = 1, 10 do
				if x > 854/2-(320+spaces*11)/2+(32+spaces)*(i-1)+spaces and x < 854/2-(320+spaces*11)/2+(32+spaces)*(i-1)+spaces+32 and y > 480-(32+spaces) and y < 480-(32+spaces)+32 then
					equipped = i
				end
			end	
		else
			player.mpressed(key, X, Y)
		end
	end
end

function inventory.kpressed(key)
	if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or key == "8" or key == "9" then
		equipped = (key*1000)/1000
	elseif key == "0" then
		equipped = 10
	else
		player.kpressed(key)
	end
end