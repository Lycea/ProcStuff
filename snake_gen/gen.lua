local gen ={}

local map={}
local points={}
local rooms={}

local branch_stack = {}

local rnd = love.math.random


local f ={}


local function s_push(item)
  table.insert(branch_stack,1,item)
end

local function s_pop()
    local tmp_ = branch_stack[1]
    table.remove(branch_stack,1)
    return tmp_
end

local function s_size()
  return #branch_stack
end



local directions =
{
  left  = 2,
  right = 1,
  up    = 4,
  down  = 3,
  {x=1,y=0},
  {x=-1,y=0},
  {x=0,y=1},
  {x=0,y=-1}
}

--meta map for returning 0 if not available
  local map_empty = {
    __index = function(t,key)
      return 0
    end
    }

local pos = {}

local change_dir  = 100
local make_branch = 200
local end_branch  = 70
local make_room   = 100

local actual_dir = 3
local step_since_turn = 0
local min_steps       = 5

local room_w = 7
local room_h = 7

function gen.init()
  
  for i = 1, 10000 do
    map[i] = {}
    setmetatable(map[i],map_empty)
  end
  
  --set to 5k/5k ... because ther is enough space then :P
  pos.x = 5000
  pos.y = 5000
  
  points[#points+1] = {pos.x,pos.y}
  map[pos.y][pos.x] = 1
end


local function gen_left()
  local w_max =50
  local h_max =50
  -- check from left to right
  local start = {x=pos.x-1,y=pos.y}
  
  for i=0,room_w do
    local h_arr= {}
    for j=0,room_h do
      if map[start.y-j][start.x-i] == 0 then
          table.insert(h_arr,1,start.y-j)
      else
        break
      end
      --
      if math.max(unpack(h_arr)) <  h_max then
        h_max = math.max(unpack(h_arr))
      end
    end
       
  end
  
end

local function gen_right()
  local w_max =0
  local h_max =0
end

local function gen_up()
  local w_max =0
  local h_max =0
end

local function gen_down()
  local w_max =0
  local h_max =0
end


local function gen_room()
  --check direction
  local w_check
  local h_check
  

  
  --right,left,down,up
  
  if actual_dir > 2 then
    -- is moving up /down so make room left /right
    
    if  rnd(1,2) == 1 then
      gen_right()
    else
      gen_left()
    end
  else
    --is moving left/right so make room up down
    if rnd(3,4) == 3 then
      gen_down()
    else
      gen_up()
    end
  end
end




local function check_step(x,y)
  if  map[pos.y+y][pos.x + x] == 0 then
    return true
  else
    return false
  end
end


local function dir_change()
   local dir
  --random change left /right
  if actual_dir >2 then
    dir =rnd(1,2)
  else
     dir = rnd(3,4)
  end
  actual_dir = dir
end

--local history = {}
--local h_max = 5

--check if stuck somehow
local function is_stuck()
  --get the 4 neighbours
  local tmp = {}
  tmp[1] = map[pos.y][pos.x+1]
  tmp[2] = map[pos.y][pos.x-1]
  tmp[3] = map[pos.y+1][pos.x]
  tmp[4] = map[pos.y-1][pos.x]
  
  local ways = 0
  for i=1,4 do
    if tmp[i] == 0 then
      ways = ways+1
    end
  end
  
  if ways == 0 then
    return true
  else
    return false
  end
end


local function get_op_dir()
  
 if actual_dir == 1 then
   return 2
 elseif actual_dir == 2 then
   return 1
 elseif actual_dir == 3 then
   return 4
 elseif actual_dir == 4 then
   return 3
 end
 
end



function gen.update(dt)
  --check if special condition should happen
  -- change dirs ?
  if rnd(0,1000)<= make_room then
    gen_room()
    c.log("gen_room")
  end
  if rnd(0,1000) <= change_dir and step_since_turn >min_steps then
    dir_change()
    c.log("changed direction ..")
    step_since_turn = 0
    
  elseif rnd(0,1000)<= make_branch and step_since_turn >1 then
    dir_change()
    c.log("branching.. "..s_size())
    local tmp = {}
    tmp.pos={}
    tmp.pos.x = pos.x -- actual position
    tmp.pos.y = pos.y -- actual position
    
    tmp.dir = get_op_dir() -- the actual direction to move on
    
    s_push(tmp)
    step_since_turn = 0
  elseif rnd(0,1000)<= end_branch and s_size()>=1 then
      c.log("close branch.."..s_size())
     local tmp =s_pop()
     pos.x = tmp.pos.x
     pos.y = tmp.pos.y
     
     actual_dir = tmp.dir
     step_since_turn = 0
  else
    --move forward
    if check_step(directions[actual_dir].x,directions[actual_dir].y) == true then 
      pos.x = pos.x +directions[actual_dir].x
      pos.y = pos.y +directions[actual_dir].y
      
      points[#points+1] = {pos.x,pos.y}
      map[pos.y][pos.x] = 1
      
      step_since_turn = step_since_turn +1
    else
      if is_stuck() == true then
       local tmp =s_pop()
       if tmp ~= nil then
         
         pos.x = tmp.pos.x
         pos.y = tmp.pos.y
         
         actual_dir = tmp.dir
         c.log("got stuck... return")
         step_since_turn = 0
       else
         
       end
       
     
      else
        dir_change()
        --step_since_turn = 0
      end
      
    end
    
  end
  
  
end
local size_rect = 5
function gen.draw()
    love.graphics.translate(pos.x*size_rect*-1 + 100,pos.y*size_rect*-1 + 100)
  --love.graphics.translate(points[1][1]*size_rect*-1 + 100,points[1][2]*size_rect*-1 +100)
  for i,p in ipairs(points) do
      
      love.graphics.rectangle("fill",p[1]*size_rect,p[2]*size_rect,size_rect,size_rect)
  end
  
  love.graphics.setColor(1,0,0,1)
  love.graphics.rectangle("fill",pos.x*size_rect,pos.y*size_rect,size_rect,size_rect)
  love.graphics.setColor(1,1,1,1)
  love.graphics.origin()
end






return gen