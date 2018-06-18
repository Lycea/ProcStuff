local g =require("gen")
c = require("console")
  
function love.load()
  
  require("mobdebug").start()
  
  g.init()
  
end

local timer = 0
function love.update(dt)
  timer = timer +dt
  if timer > 0.1 then
    timer = 0
  g.update(dt)
  end
end


function love.draw()
  g.draw()
  
  c.draw()
  love.graphics.print(love.timer.getFPS(),0,0)
end
