-- Thanks @bartbes! fixes cygwin buffer
io.stdout:setvbuf("no")

states = {
  intro = require"gamestates.intro",
  main = require"gamestates.main",
}

fonts = {
  default = love.graphics.newFont("assets/fonts/CarterOne.ttf",16),
}

love.graphics.setFont(fonts.default)

libs = {
  hump = {
    gamestate = require"libs.hump.gamestate",
  },
  actions = require"libs.actionslib",
}

function love.load()
  libs.hump.gamestate.registerEvents()
  libs.hump.gamestate.switch(states.intro)
  local music = love.audio.newSource("assets/channel_your_inner_pet.mp3","stream")
  music:setLooping(true)
  music:setVolume(0.8)
  music:play()
end
