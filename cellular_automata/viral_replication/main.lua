v = require("viral")



local generation = 0

function love.load()
 -- require("mobdebug").start()
  love.filesystem.setIdentity("cave_gen")
  v.ini_grid()
end




function love.update(dt)
  --local s_per_update = math.floor((grid_w*grid_h) *0.3)
  
  v.step()
  
  generation = generation +1
end


function love.draw()
  --draw the points
  v.draw()
  

  love.graphics.print(love.timer.getFPS(),0,500)
  love.graphics.print("Actual geneeration: "..generation,0,510)
  if generation == nil    then
    love.graphics.captureScreenshot(os.time() .. ".png")
    love.keypressed(a,b)
  end
  
end


function love.keypressed(k,s)
    v.ini_grid()
    generation = 0
end
