-- Thanks @bartbes! fixes cygwin buffer
io.stdout:setvbuf("no")

states = {
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
  libs.hump.gamestate.switch(states.main)
end
