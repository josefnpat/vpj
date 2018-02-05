local main = {}

function main:init()
  self.actions = libs.actions.new()
  self.actions:add(
    love.graphics.newImage("assets/actions/play.png"),
    function()
      self.pet.happy = math.min(1,self.pet.happy + 0.125)
      self.pet.state = "play"
      self.state_dt = 0
      self:play_state_sound()
    end)
  self.actions:add(
    love.graphics.newImage("assets/actions/heal.png"),
    function()
      self.pet.hurt = math.max(0,self.pet.hurt - 0.125)
      self.pet.state = "heal"
      self.state_dt = 0
      self:play_state_sound()
    end)
  self.actions:add(
    love.graphics.newImage("assets/actions/feed.png"),
    function()
      self.pet.hungry = math.max(0,self.pet.hungry - 0.125)
      self.pet.state = "feed"
      self.state_dt = 0
      self:play_state_sound()
    end)

  self.actions:add(
    love.graphics.newImage("assets/actions/leave.png"),
    function()
      if self.location == self.inside then
        self.location = self.outside
      else
        self.location = self.inside
      end
    end)

  local img_close = love.graphics.newImage("assets/actions/close.png")
  local img_open = love.graphics.newImage("assets/actions/open.png")

  self.actions:add(
    img_close,
    function(s)
      if self.action_x == self.action_opened then
        self.action_x = self.action_closed
        s.image = img_close
      else
        self.action_x = self.action_opened
        s.image = img_open
      end
    end)

  self.inside = love.graphics.newImage("assets/inside.png")
  self.outside = love.graphics.newImage("assets/outside.png")
  self.outside_night = love.graphics.newImage("assets/outside_night.png")
  self.location = self.inside

  self.events = {
    function()
      self.pet.hurt = math.min(1,self.pet.hurt + 0.5)
      self.pet.state = "fall"
      self.state_dt = 0
    end,
  }

  self.time = 0

  self.pet = {
    state = "normal",
    x = 320,
    y = 240,
    dt = 0,
    scale = 1/2,
    states = {
      happy = {
        check = function(pet)
          return self.pet.happy > 0.5
        end,
      },
      hungry = {
        check = function(pet)
          return self.pet.hungry > 0.75
        end,
      },
      hurt = {
        check = function(pet)
          return self.pet.hurt > 0
        end,
      },
      normal = {
        check = function(pet)
          return self.pet.happy > 0 and self.pet.hungry < 1 and self.pet.hurt == 0
        end,
      },
      unhappy = {
        check = function(pet)
          return self.pet.happy == 0
        end,
      },
      roll = {
        check = function(pet)
          return self.pet.happy > 0.5 and self.pet.hungry < 0.5 and self.pet.hurt == 0
        end,
      },
      run = {
        check = function(pet)
          return self.pet.happy > 0.5 and self.pet.hungry < 0.5 and self.pet.hurt == 0
        end,
      },
      fall = {},
      heal = {},
      feed = {},
      play = {},
    },
    happy = 1, -- 30 seconds
    hungry = 0, -- 45 
    hurt = 0,
  }

  for name,state in pairs(self.pet.states) do
    state.frames = {}
    for i,v in pairs(love.filesystem.getDirectoryItems("assets/states/"..name)) do
      table.insert(state.frames,love.graphics.newImage("assets/states/"..name.."/"..v))
    end
    state.sounds = {}
    for i,v in pairs(love.filesystem.getDirectoryItems("assets/sounds/"..name)) do
      table.insert(state.sounds,love.audio.newSource("assets/sounds/"..name.."/"..v))
    end
  end

end

function main:enter()
  self.action_x = 0
  self.action_opened = -self.actions:allButLast()
  self.action_closed = 0
  self.action_speed = 250
  self.state_t = 5
  self.state_dt = 0
  self.event_min = 120
  self.event_max = 160
  self.event_dt = math.random(self.event_min,self.event_max)
end

function main:draw()
  if self.location == self.outside and self.time > 0.5 then
    love.graphics.draw(self.outside_night)
  else
    love.graphics.draw(self.location)
  end
  self.actions:draw()
  local pet_state = self.pet.states[self.pet.state]
  local frame_index = math.floor(self.pet.dt % #pet_state.frames) + 1
  local frame = pet_state.frames[frame_index]
  love.graphics.draw(frame,self.pet.x,self.pet.y,0,
    self.pet.scale,self.pet.scale,
    frame:getWidth()/2,frame:getHeight()/2)

  for i,v in pairs({
    {name="Happiness",value=self.pet.happy},
    {name="Hunger",value=self.pet.hungry},
    {name="Hurt",value=self.pet.hurt},
  }) do
    local bh = 24
    local x,y,w,h = 32,64+(bh+2)*i,128,bh
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill",x,y,w,h)
    love.graphics.setColor(127,127,127)
    love.graphics.rectangle("fill",x+2,y+2,(w-4)*v.value,h-4)
    love.graphics.setColor(255,255,255)
    love.graphics.printf(v.name,x,y-2,w,"center")
  end

  if debug_mode then
    love.graphics.print(
      "happy:"..self.pet.happy.."\n"..
      "hungry:"..self.pet.hungry.."\n"..
      "hurt:"..self.pet.hurt.."\n"..
      "state:"..self.pet.state.."\n"..
      "time:"..self.time.."\n"..
      "",32,96)
  end
end

function main:keypressed(key)

  if key == "`" and love.keyboard.isDown("lshift") then
    debug_mode = not debug_mode
  end

  if debug_mode and key == "tab" then
    local get_next = false
    local state_next = nil
    for i,v in pairs(self.pet.states) do
      if state_next == nil then
        state_next = i
      end
      if get_next then
        state_next = i
        break
      end
      if self.pet.state == i then
        get_next = true
      end
    end
    self.pet.state = state_next
    self.state_dt = 0
  end

end

function main:play_state_sound()
  local pet_state = self.pet.states[self.pet.state]
  if #pet_state.sounds > 0 then
    local sound = pet_state.sounds[math.random(#pet_state.sounds)]
    sound:play()
  end
end

function main:update(dt)

  self.time = (self.time + dt/(3*60) ) % 1 -- day lasts three minutes

  self.event_dt = self.event_dt - dt
  if self.event_dt < 0 then
    self.event_dt = math.random(self.event_min,self.event_max)
    -- do an event
    local event = self.events[math.random(#self.events)]
    event()
  end

  self.state_dt = self.state_dt + dt
  if self.state_dt > self.state_t then
    self.state_dt = 0
    -- find new state
    local valid = {}
    for i,v in pairs(self.pet.states) do
      if v.check and v.check() then
        table.insert(valid,i)
      end
    end
    self.pet.state = valid[math.random(#valid)]
    self:play_state_sound()
  end
  self.pet.dt = self.pet.dt + dt

  if self.location == self.inside then
    self.pet.happy = math.max(0,self.pet.happy - dt/30)
  else
    if self.time > 0.5 then -- dark
      self.pet.happy = math.max(0,self.pet.happy - dt/15)
    else
      self.pet.happy = math.min(1,self.pet.happy + dt/30)
    end
  end

  self.pet.hungry = math.min(1,self.pet.hungry + dt/45)

  if self.actions.x < self.action_x then
    self.actions.x = math.min(self.action_closed,self.actions.x + self.action_speed*dt)
  elseif self.actions.x > self.action_x then
    self.actions.x = math.max(self.action_opened,self.actions.x - self.action_speed*dt)
  else -- ==
    --nop
  end
  self.actions:update(dt)
end

return main
