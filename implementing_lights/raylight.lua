ray = {}
local vector = require "vectorl"

function ray.loadMap(m)
	for i, v in ipairs(m) do
		v.shadows = {}
	end
	ray.m = m
end

function ray.castRays(X, Y, tx, ty)
	for i, v in ipairs(ray.m) do
		v.shadows = {}
	end
	local i = 1
	local shadows = {}
	while i <= 15000 do
		local ang = (math.pi*2)/15000*i
		local x, y = vector.rotate(ang, 0, -600)
		for j, b in ipairs(ray.m) do
			if tx-12 < b.tx and b.tx < tx+12 then
				if ty-12 < b.ty and b.ty < ty+12 then
					local points = {}
					if checkIntersect({x = X, y = Y}, {x = X+x, y = Y+y}, {x = b.x, y = b.y}, {x = b.x, y = b.y+b.h}) then
						local yes = false
						local points = {{x = b.x, y = b.y}, {x = b.x, y = b.y+b.h}}
						for k, n in ipairs(shadows) do
							if n == points then
								yes = true
							end
						end
						if not yes then
							table.insert(shadows, points)
							table.insert(b.shadows, #shadows)
						end
					end
					if checkIntersect({x = X, y = Y}, {x = X+x, y = Y+y}, {x = b.x+b.w, y = b.y}, {x = b.x+b.w, y = b.y+b.h}) then
						local yes = false
						local points = {{x = b.x+b.w, y = b.y}, {x = b.x+b.w, y = b.y+b.h}}
						for k, n in ipairs(shadows) do
							if n == points then
								yes = true
							end
						end
						if not yes then
							table.insert(shadows, points)
							table.insert(b.shadows, #shadows)
						end
					end
					if checkIntersect({x = X, y = Y}, {x =X+x, y = Y+y}, {x = b.x, y = b.y}, {x = b.x+b.w, y = b.y}) then
						local yes = false
						local points = {{x = b.x, y = b.y}, {x = b.x+b.w, y = b.y}}
						for k, n in ipairs(shadows) do
							if n == points then
								yes = true
							end
						end
						if not yes then
							table.insert(shadows, points)
							table.insert(b.shadows, #shadows)
						end
					end
					if checkIntersect({x = X, y = Y}, {x = X+x, y = Y+y}, {x = b.x, y = b.y+b.h}, {x = b.x+b.w, y = b.y+b.h}) then
						local yes = false
						local points = {{x = b.x, y = b.y+b.h}, {x = b.x+b.w, y = b.y+b.h}}
						for k, n in ipairs(shadows) do
							if n == points then
								yes = true
							end
						end
						if not yes then
							table.insert(shadows, points)
							table.insert(b.shadows, #shadows)
						end
					end
				end
			end
		end
		i = i + 1
	end
	for i, v in ipairs(ray.m) do
		local drawPoly = {}
		if v.shadows ~= {} then
			for j, b in ipairs(v.shadows) do
				local o = shadows[b]
				local tmx1, tmy1 = vector.normalize(X-o[1].x, Y-o[1].y)
				local x3, y3 = vector.mul(400, vector.rotate(math.pi, tmx1, tmy1))
				local tmx2, tmy2 = vector.normalize(X-o[2].x, Y-o[2].y)
				local x4, y4 = vector.mul(400, vector.rotate(math.pi, tmx2, tmy2))
				table.insert(drawPoly, o[1].x)
				table.insert(drawPoly, o[1].y)
				table.insert(drawPoly, o[2].x)
				table.insert(drawPoly, o[2].y)
				table.insert(drawPoly, o[1].x+x3)
				table.insert(drawPoly, o[1].y+y3)
				table.insert(drawPoly, o[2].x+x4)
				table.insert(drawPoly, o[2].y+y4)
			end
			love.graphics.polygon("fill", drawPoly)
		end
	end
	return vec
end

function checkIntersect(l1p1, l1p2, l2p1, l2p2)
    local function checkDir(pt1, pt2, pt3) return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end
    return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end

function findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, seg1, seg2)
    local a1,b1,a2,b2 = l1p2y-l1p1y, l1p1x-l1p2x, l2p2y-l2p1y, l2p1x-l2p2x
    local c1,c2 = a1*l1p1x+b1*l1p1y, a2*l2p1x+b2*l2p1y
    local det,x,y = a1*b2 - a2*b1
    if det==0 then return false, "The lines are parallel." end
    x,y = (b2*c1-b1*c2)/det, (a1*c2-a2*c1)/det
    if seg1 or seg2 then
        local min,max = math.min, math.max
        if seg1 and not (min(l1p1x,l1p2x) <= x and x <= max(l1p1x,l1p2x) and min(l1p1y,l1p2y) <= y and y <= max(l1p1y,l1p2y)) or
           seg2 and not (min(l2p1x,l2p2x) <= x and x <= max(l2p1x,l2p2x) and min(l2p1y,l2p2y) <= y and y <= max(l2p1y,l2p2y)) then
            return false, "The lines don't intersect."
        end
    end
    return x,y
end

function howFarFromIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, odx, ody, seg1, seg2)
	local x, y = findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, seg1, seg2)
	print(x)
	if x ~= false then
		return math.sqrt(math.abs(x-odx)^2 + math.abs(y-ody)^2)
	else
		return -1
	end
end

function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end
return ray