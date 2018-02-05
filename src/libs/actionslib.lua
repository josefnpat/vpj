local actions = {}

function actions.new(init)
  local self = {}

  self.draw = actions.draw
  self.update = actions.update
  self.add = actions.add
  self.mouseArea = actions.mouseArea
  self.mouseInArea = actions.mouseInArea
  self.allButLast = actions.allButLast

  self.x = 0
  self.y = 0
  self.padding = 4

  self._data = {}

  return self
end

function actions:add(image,exe)
  table.insert(self._data,{
    image=image,
    exe=exe,
  })
end

function actions:draw()
  for i,v in pairs(self._data) do
    local tx,ty,tw,th = self:mouseArea(i)
    love.graphics.draw(v.image,tx,ty)
    if v.selected then
      love.graphics.setColor(0,0,0)
      love.graphics.rectangle("line",tx,ty,tw,th)
      love.graphics.setColor(255,255,255)
    end
  end
end

function actions:mouseArea(i)
  return (i-1)*(64+self.padding)+self.x,self.y,64,64
end

function actions:allButLast()
  return (#self._data-1)*(64+self.padding)
end

function actions:mouseInArea(i)
  local mx,my = love.mouse.getPosition()
  local x,y,w,h = self:mouseArea(i)
  return mx > x and mx < x + w and my > y and my < y + h
end

function actions:update(dt)
  for i,v in pairs(self._data) do
    v.selected = self:mouseInArea(i)
    if v.selected and love.mouse.isDown(1) then
      self.wait_for_release = i
    end
    if self.wait_for_release and not love.mouse.isDown(1) then
      self._data[self.wait_for_release].exe( self._data[self.wait_for_release] )
      self.wait_for_release = nil
    end
  end
end

return actions
