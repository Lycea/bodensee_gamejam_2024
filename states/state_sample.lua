local sample_state =class_base:extend()



local main_ui ={
  plants ={}
}

local id_to_plant ={
  
}

local plant_to_id ={
  
}
local plant_unlocked ={
  grass = true,
  flower = false,
  shrub = false,
  tree = false,
  NaN = true
}

local plant_counter ={
  grass=0,
  flower=0,
  shrub=0,
  tree=0
}

local water = 0.5
local water_per_second = 0

local global_boni = 1


local plant=class_base:extend()

function plant:new(base_cost,base_cost_inc,base_health,base_water_gen,size)
  self.base_cost = base_cost
  self.base_cost_inc = base_cost_inc
  self.base_max_health = base_health
  self.base_water_gen = base_water_gen

  self.size = size

  self.cur_cost = self.base_cost
  self.cur_cost_inc = self.base_cost_inc
  self.cur_max_health = self.base_max_health
  self.cur_health = self.cur_max_health
  self.cur_water_gen = self.base_water_gen
end

local plant_objects ={
  grass ={},
  flower = {},
  shrub ={},
  tree = {}
}

local plant_unlock ={
  grass = "flower",
  flower = "shrub",
  shrub = "tree",
  tree = "NaN"
}

local plant_info ={
  grass  =plant(0.3, 1.7 , --cost, cost inc
                5 , 0.2,   --health, water/s
                {w=32,h=16} --size
           ),
  flower =plant(3  ,1.3 , 10, 0.5, {w=20,h=40}),
  shrub  =plant(10 ,1.5 , 15, 3, {w=20,h=20}),
  tree   =plant(20 ,1.4 , 20, 5, {w=20,h=60})
}

local plants_unlocked = 0

function recalculate_plants()
  local plant_sum = 0

  plant_sum = plant_sum + plant_info.grass.cur_water_gen * plant_counter["grass"]
  plant_sum = plant_sum + plant_info.flower.cur_water_gen * plant_counter["flower"]
  plant_sum = plant_sum + plant_info.shrub.cur_water_gen * plant_counter["shrub"]
  plant_sum = plant_sum + plant_info.tree.cur_water_gen * plant_counter["tree"]

  return plant_sum
end

function recalculate_water()
  water_per_second = recalculate_plants() * global_boni
end

function rounded_num(num)
  return tonumber(string.format("%.2f", num))
end

function unlock_plant(name)
  main_ui.plants[name] = glib.ui.AddButton(name,
                                           gvar.scr_h / 2 + -50 + plants_unlocked * 80,
                                           gvar.scr_w / 2 - 50  ,
                                           50, 50)
  id_to_plant[main_ui.plants[name]] = name
  plant_to_id[name]=main_ui.plants[name]

  glib.ui.SetSpecialCallback(main_ui.plants[name], add_plant)


  local btn_obj = glib.ui.GetObject(main_ui.plants[name])
  btn_obj.txt = name .. "\n" .. rounded_num(plant_info[name].cur_cost)

  plants_unlocked= plants_unlocked+1
end

local plant_id = 0



function add_plant(id)
  print("adding plant",id, id_to_plant[id])
  
  local plant_name = id_to_plant[id]
  plant_counter[plant_name] = plant_counter[plant_name]+1
  water = water - plant_info[plant_name].cur_cost
  plant_info[plant_name].cur_cost =  plant_info[plant_name].cur_cost * plant_info[plant_name].cur_cost_inc

  local cur_id = plant_name.."_"..plant_id
  plant_id=plant_id+1

  plant_objects[plant_name][cur_id] =
                 {
                   w=plant_info[plant_name].size.w, h=plant_info[plant_name].size.h,
                  x= love.math.random(0,gvar.scr_w- 20),y= gvar.scr_h/2,
                  max_health = plant_info[plant_name].cur_max_health,
                  health = plant_info[plant_name].cur_max_health,
                  id=cur_id, plant_type=plant_name
                 }

  if plant_counter[plant_name] >=5 and plant_unlocked[ plant_unlock[plant_name]  ]  == false then
    local next_plant = plant_unlock[plant_name]
    unlock_plant(next_plant)
    plant_unlocked[next_plant]=true
  end
  
  local btn_obj = glib.ui.GetObject(id)
  btn_obj.txt = plant_name.."\n".. rounded_num(plant_info[plant_name].cur_cost)
  recalculate_water()
end

--------------------------------------
--   FIRE stuff
--------------------------------------

local total_fire_countdown = 20
local current_countdown = 0

local fire_elements ={}
local elementa_amount = 3

local to_delete_btns = {}

function clicked_fire(id)
  for _, fire in pairs(fire_elements) do
    if fire.btn_id == id then
      water = water - fire.cost
      glib.ui.SetEnabled(id,false)

      fire_elements[_].hooked_plant.obj.burning = false
      table.insert(to_delete_btns,id)
      fire_elements[_] = nil
    end
  end
end

local wave_count = 1

function add_fire()
  
end

function spawn_fire()

  local available_types = {}
  for p_type, count in pairs(plant_counter) do
    if count >0 then
      print("avail "..p_type)
      table.insert(available_types,p_type)
    end
  end
  print("elements: "..math.ceil(elementa_amount))
  for i=0, math.floor(elementa_amount +0.5) do
    retries = 3

    while retries > 0 do
      --print("types: "..#available_types)
      type__ = love.math.random(1,#available_types)
      --print("type selected: "..type__.." ,"..available_types[type__])
      
      local p_type = available_types[type__]
      local key_list ={}
      for ids_ ,_ in pairs(plant_objects[p_type]) do
        table.insert(key_list,ids_)
        print("avail id"..ids_)
      end

      local idx = key_list[love.math.random(1,  #key_list)]
      print("selected_id",idx)

      if plant_objects[p_type][idx].burning ~= true  then
        plant_objects[p_type][idx].burning = true

        local fire_btn_id = glib.ui.AddButton("f", plant_objects[p_type][idx].x, plant_objects[p_type][idx].y - plant_objects[p_type][idx].h  ,20,20)
        glib.ui.SetSpecialCallback(fire_btn_id,clicked_fire)
       
        glib.ui.SetVisibiliti(fire_btn_id,false)
        table.insert(fire_elements,{
                       hooked_plant = {
                         obj = plant_objects[p_type][idx],
                         p_type=p_type},
                       pos = {x= plant_objects[p_type][idx].x,y=0 },
                       fire_tick = 1 * wave_count,
                       cost = 5 * wave_count,
                       btn_id = fire_btn_id
        })
        break
      end

      retries = retries -1
    end
  end

  wave_count= wave_count+1
  elementa_amount=elementa_amount+1.5
  
end

-----------------
-- base functions
local ui_initialised = false
local images ={}
local image_list={}
local function recursiveEnumerate(folder, fileTree)
  local lfs = love.filesystem
  local filesTable = lfs.getDirectoryItems(folder)
  for i, v in ipairs(filesTable) do
    local file = folder .. "/" .. v
    if lfs.isFile(file) and file:find(".png") then
      
      image_list[#image_list + 1] = file

    elseif lfs.isDirectory(file) then
      fileTree = fileTree .. "\n" .. file .. " (DIR)"
      fileTree = recursiveEnumerate(file, fileTree)
    end
  end
  return fileTree
end

local function load_icons()
  --load all the modules
  recursiveEnumerate("assets", "")

  for _, img in pairs(image_list) do
    path      = img
    type_name = img:gsub(".png", ""):gsub("assets/","")
    print("   loading icon:  " .. type_name.."  "..path)
    images[type_name] = love.graphics.newImage(path)
  end
end




function sample_state:new()
  print("initialised!!")
  load_icons()
end

function sample_state:startup()
  print("startup")

  if ui_initialised == false then
    unlock_plant("grass")

    ui_initialised = true
  end
end

local game_over = false

function sample_state:draw()

  --background
  love.graphics.setColor(0, 0, 255)
  love.graphics.rectangle("fill", 0, 0, gvar.scr_w, gvar.scr_h / 2)

  love.graphics.setColor(0, 150, 0)
  love.graphics.rectangle("fill", 0, gvar.scr_h / 2, gvar.scr_w, gvar.scr_h / 2)

  --water stats
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(water_per_second .. " w/s", 20, 20)
  love.graphics.print(tonumber(string.format("%.2f", water)) .. " water", 20, 40)


if game_over then

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(images["game_over"], 200, 50)
    return
  end


  --plants !

  love.graphics.setColor(255, 255, 255)
  for name, available_plants in pairs(plant_objects) do
    for _, planted_plant in pairs(available_plants) do
      -- love.graphics.rectangle("line",
      --   planted_plant.x, planted_plant.y - planted_plant.h,
      --   planted_plant.w, planted_plant.h)
      love.graphics.draw(images[name],
        planted_plant.x, planted_plant.y - planted_plant.h)
    end
  end

  for _, info in pairs(fire_elements) do
    --love.graphics.rectangle("line", info.pos.x, info.pos.y, 20, 20)
    love.graphics.draw(images["fire"], info.pos.x, info.pos.y)
  end

  --fire stuff
  love.graphics.setColor(0, 0, 0)
  love.graphics.print("NEXT FIRE:\n ".. math.floor(total_fire_countdown - current_countdown +0.5 ).." s",
  gvar.scr_w/2 -gvar.scr_w/5 ,0)

end



function sample_state:update(dt)
  if game_over then
    return
  end

  water = water + water_per_second * dt

  --fire updater
  current_countdown= current_countdown +dt

  if current_countdown >= total_fire_countdown then
    spawn_fire()
    current_countdown = 0
    total_fire_countdown = math.max( total_fire_countdown -3,10)
  end

  local fire_pix_per_sec = 400
  local fire_to_remove={}
  for _,fire in pairs(fire_elements) do
    if fire.pos.y < fire.hooked_plant.obj.y -fire.hooked_plant.obj.h then
      fire.pos.y = fire.pos.y + fire_pix_per_sec * dt
    else
      fire.hooked_plant.obj.health = fire.hooked_plant.obj.health - fire.fire_tick*dt
      glib.ui.SetEnabled(fire.btn_id)
      
      if fire.cost < water then
        glib.ui.GetObject(fire.btn_id).color["default_color"] = { 20, 20, 255, 255 }
        glib.ui.SetEnabled(fire.btn_id, true)
      else
        glib.ui.GetObject(fire.btn_id).color["default_color"] = { 255, 0, 0, 255 }
        glib.ui.SetEnabled(fire.btn_id, false)
      end

      if fire.hooked_plant.obj.health<= 0 then
        local plant_name = fire.hooked_plant.p_type
        plant_objects[plant_name][fire.hooked_plant.obj.id]=nil
        plant_counter[plant_name] = plant_counter[plant_name] - 1
        recalculate_water()
        
        plant_info[plant_name].cur_cost =  plant_info[plant_name].cur_cost / plant_info[plant_name].cur_cost_inc

        local btn_obj = glib.ui.GetObject(plant_to_id[plant_name])
        btn_obj.txt = plant_name .. "\n" .. rounded_num(plant_info[plant_name].cur_cost)

        if water_per_second <= 0 then
          game_over =  true
        end

        table.insert(fire_to_remove ,1, _)
      end
    end
  end

  for _,fire_id in pairs(fire_to_remove) do
    glib.ui.RemoveComponent(fire_elements[fire_id].btn_id)
    fire_elements[fire_id] = nil
  end
  

  --plant purchase handler
  for plant_id, plant_name in pairs(id_to_plant) do
    if plant_info[plant_name].cur_cost < water then
      glib.ui.GetObject(plant_id).color["default_color"] = { 0, 255, 0, 255 }
      glib.ui.SetEnabled(plant_id, true)
    else
      glib.ui.GetObject(plant_id).color["default_color"] = { 255, 0, 0, 255 }
      glib.ui.SetEnabled(plant_id,false)
     end
   end

  for _,btn in pairs(to_delete_btns) do
    glib.ui.RemoveComponent(btn)
  end
  to_delete_btns = {}
end

function sample_state:shutdown()
    
end





return sample_state()
