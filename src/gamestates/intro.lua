local intro = {}

function intro:init()
  self.potato = love.graphics.newImage("assets/intro.png")
end

function intro:draw()
  love.graphics.draw(self.potato)
end

function intro:mousepressed()
  libs.hump.gamestate.switch(states.main)
end

return intro
