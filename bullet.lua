
bullet = {}
bullet.speed = 100
bullets = {}

function bullet.load(x, y, speedx, speedy)
	table.insert(bullets, {x = x, y = y, sX = speedx, sY = speedy, w = 5, h = 5, typ = "bullet"})
end

function bullet.update(dt)
	local remBullets = {}
	for i, v in ipairs(bullets) do
		v.x = v.x + v.sX * dt
		v.y = v.y + v.sY * dt

		for j, b in ipairs(coll) do
			if checkCollision(v.x, v.y, v.w, v.h, b.x, b.y, b.w, b.h) then
				table.insert(remBullets, i)
			end
		end	
	end
	for i, v in ipairs(remBullets) do
		table.remove(bullets, v)
	end
end

function bullet.draw()
	for i, v in ipairs(bullets) do
		lg.setColor(0, 0, 255)
		lg.rectangle("fill", v.x, v.y, v.w, v.h)
	end
end



function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end