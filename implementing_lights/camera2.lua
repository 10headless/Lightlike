cam2 = {}
cam2.x = 0
cam2.y = 0
cam2.xvel = 0
cam2.yvel = 0
cam2.scaleX = 1.0
cam2.scaleY = 1.0
cam2.speed = 10
cam2.rotation = 0

function cam2:set()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
  love.graphics.translate(-self.x, -self.y)
end
function cam2:set2()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.scaleX + 0.5,1 / self.scaleY + 0.5)
  love.graphics.translate(-self.x, -self.y)
end
function cam2.unset2()
  love.graphics.pop()
end
function cam2:unset()
  love.graphics.pop()
end

function cam2:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end

function cam2:rotate(dr)
  self.rotation = self.rotation + dr
end

function cam2:scale(sx, sy)
  sx = sx or 1
  self.scaleX = self.scaleX * sx
  self.scaleY = self.scaleY * (sy or sx)
end

function cam2:setPosition(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function cam2:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end
function cam2:change_focuse(scale)
 self.scaleX = scale
 self.scaleY = scale
 love.graphics.pop()
 love.graphics.push()
 love.graphics.translate(-self.x, -self.y)
 love.graphics.scale(1/ self.scaleX, 1/ self.scaleY)
end
cam2.width = love.graphics.getWidth() / 3.3

cam2.layers = {}


function cam2:newLayer(scale, func)
  table.insert(self.layers, { draw = func, scale = scale })
  table.sort(self.layers, function(a, b) return a.scale < b.scale end)
end

function cam2:draw()
  local bx, by = self.x, self.y
  
  for _, v in ipairs(self.layers) do
    self.x = bx * v.scale
    self.y = by * v.scale
    cam2:set()
    v.draw()
    cam2:unset()
  end
end











