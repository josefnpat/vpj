git_hash,git_count = "missing git.lua",-1
pcall( function() return require("git") end );

function love.conf(t)
  t.window.width = 640
  t.window.height = 360
  t.window.title = "Quibble (v"..git_count..") ["..git_hash.."]"
end
