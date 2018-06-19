
local possible_states = 5
local grid_w = 100
local grid_h = 100

local k1  = 50-- 0-100   active infection rate
local k2  = 100-- 0-9999  base rate
local k3  = 20-- 0-100   chance of cell division  / time to filly populate

local base_population = 20

local generation =0
--lookup 0 if empty
  local index_empty = {
    __index = function(t,key)
      return 0
    end
    }

local grid ={}

local rnd = love.math.random
local p_size = 5

local canv

local function ini_grid()
  --init the grid
  for i = 1, grid_h do
    grid[i] = {}
    setmetatable(grid[i],index_empty)
  end
  
  local lifing = (grid_w*grid_h) * (base_population/100)
  local cells = 0
  
  while cells ~= lifing do
    --select random map place
    local x,y = rnd(1,grid_w),rnd(1,grid_h)
    if grid[y][x]== 0 then
      
      grid[y][x] = possible_states
      cells = cells +1
    end
    
  end
  
  
  
end


function love.load()
 -- require("mobdebug").start()
  
  ini_grid()
  canv = love.graphics.newCanvas(grid_w*p_size+2,grid_h*p_size+2)
end

local dir=
{
  {x=0,y=-1},--up
  {x=0,y= 1},--down
  {x=-1,y=0},--left
  {x=1,y=0}--right
}

local dir_funct =
{
  function (x,y)   return dir[1],grid[y+dir[1].y][x+dir[1].x] end, --up
  function (x,y) return dir[2],grid[y+dir[2].y][x+dir[2].x] end,--down
  function (x,y) return dir[3],grid[y+dir[3].y][x+dir[3].x] end,--left
  function (x,y) return dir[4],grid[y+dir[4].y][x+dir[4].x]end,--right
    
  function (x,y) --top left
    local td ={x=dir[1].x+dir[3].x,y=dir[1].y+dir[3].y}
    return td,grid[y+td.y][x+td.x]
  end,
  
  function (x,y) --top right
    local td ={x=dir[1].x+dir[4].x,y=dir[1].y+dir[4].y}
    return td,grid[y+td.y][x+td.x]
  end,
  
  function (x,y)  --bottom left
    local td ={x=dir[2].x+dir[3].x,y=dir[2].y+dir[3].y}
    return td,grid[y+td.y][x+td.x]
  end,
  
  function (x,y) --bottom right
    local td ={x=dir[2].x+dir[4].x,y=dir[2].y+dir[4].y}
    return td,grid[y+td.y][x+td.x]
  end
  }
local function get_8n(x,y)
 local tn = {}
 for i=1,8 do
   tn[i] ={}
   tn[i].pos, tn[i].state = dir_funct[i](x,y)
 end
 
 return tn
end

local function get_8en(x,y)
  local tn =get_8n(x,y)
  local en = {}
  
  for i=1,8 do
    if tn[i].state == 0 then
      --is empty
      en[#en+1] ={}
      en[#en].state = 0
      en[#en].pos=tn[i].pos
    end
  end
  
  return en
end

local function get_8fn(x,y)
  local tn = get_8n(x,y)
  local fn = {}
    
  for i=1,8 do
    if tn[i].state >1 then
      --is empty
      fn[#fn+1] ={}
      fn[#fn].state = 0
      fn[#fn].pos=tn[i].pos
    end
  end
  
  return fn
end


function love.update(dt)
  local s_per_update = math.floor((grid_w*grid_h) *0.3)
  
  for i=1,100 do
    --get random location
    local x,y = rnd(2,grid_w-1),rnd(2,grid_h-1)
    local state =grid[y][x]
    if state~= 0 then
        if rnd(1,100000)<= k2  and state ==possible_states then
          grid[y][x] = grid[y][x] -1
        elseif state < possible_states then
          if state == 1 then
            grid[y][x] = 0
            
            local n = get_8fn(x,y)
            for j = 1,#n do
              if rnd(1,100)<= k1 then
                grid[y+n[j].pos.y][x+n[j].pos.x]= grid[y+n[j].pos.y][x+n[j].pos.x]-1
              end
            end
            
          else
            grid[y][x] = grid[y][x] -1
          end
          
          
        else
          if rnd(1,100)<= k3 then
          --healthy cell check for division
          --check neighbours
            local free_ = get_8en(x,y)
            if #free_ > 0 then
              --set a random one
              local idx =rnd(1,#free_)
              grid[y+free_[idx].pos.y][x+free_[idx].pos.x]= possible_states
            end
          end
        end
    end
  end
  generation = generation +1
end

local draw_time = 0
function love.draw()
  --draw the points
  
  if draw_time > 100 then
    draw_time = 0
    love.graphics.setCanvas(canv)
    love.graphics.clear()
    love.graphics.setColor(1,1,1,1)
    
    for y=1,grid_h do
      for x=1,grid_w do
        if grid[y][x] == possible_states then
          love.graphics.setColor(1,1,1,1)
          love.graphics.rectangle("fill",x*p_size+2,y*p_size+2,p_size,p_size)
        elseif grid[y][x] ~= 0 then
          love.graphics.setColor(1,0,0,1)
          love.graphics.rectangle("fill",x*p_size+2,y*p_size+2,p_size,p_size)
        end
        
      end
    end

    love.graphics.setCanvas()
    love.graphics.setColor(1,1,1,1)
 end
 love.graphics.draw(canv,0,0)
 draw_time = draw_time +1

  love.graphics.print(love.timer.getFPS(),0,500)
  love.graphics.print("Actual geneeration: "..generation,0,510)
end
