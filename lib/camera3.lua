cam = {}
cam.x = 0
cam.y = 0
cam.xvel = 0
cam.yvel = 0
cam.scaleX = 1.0
cam.scaleY = 1.0
cam.speed = 10
cam.rotation = 0

function cam:set()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
  love.graphics.translate(-self.x, -self.y)
end
function cam:set2()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.scaleX + 0.5,1 / self.scaleY + 0.5)
  love.graphics.translate(-self.x, -self.y)
end
function cam.unset2()
  love.graphics.pop()
end
function cam:unset()
  love.graphics.pop()
end

function cam:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end

function cam:rotate(dr)
  self.rotation = self.rotation + dr
end

function cam:scale(sx, sy)
  sx = sx or 1
  self.scaleX = self.scaleX * sx
  self.scaleY = self.scaleY * (sy or sx)
end

function cam:setPosition(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function cam:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end
function cam:change_focuse(scale)
 self.scaleX = scale
 self.scaleY = scale
 love.graphics.pop()
 love.graphics.push()
 love.graphics.translate(-self.x, -self.y)
 love.graphics.scale(1/ self.scaleX, 1/ self.scaleY)
end
cam.width = love.graphics.getWidth() / 3.3

cam.layers = {}


function cam:newLayer(scale, func)
  table.insert(self.layers, { draw = func, scale = scale })
  table.sort(self.layers, function(a, b) return a.scale < b.scale end)
end

function cam:draw()
  local bx, by = self.x, self.y
  
  for _, v in ipairs(self.layers) do
    self.x = bx * v.scale
    self.y = by * v.scale
    cam:set()
    v.draw()
    cam:unset()
  end
end











