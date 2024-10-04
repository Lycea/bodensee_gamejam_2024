local sample_state =class_base:extend()



local main_ui ={
  plants ={}
}

local id_to_plant ={
  
}
local plant_unlocked ={
  grass = true,
  flower = false,
  shrub = false,
  tree = false
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

function plant:new(base_cost,base_cost_inc,base_health,base_water_gen)
  self.base_cost = base_cost
  self.base_cost_inc = base_cost_inc
  self.base_max_health = base_health
  self.base_water_gen = base_water_gen

  self.cur_cost = self.base_cost
  self.cur_cost_inc = self.base_cost_inc
  self.cur_max_health = self.base_max_health
  self.cur_health = self.cur_max_health
  self.cur_water_gen = self.base_water_gen
end


local plant_info ={
  grass  =plant(0.3,2.5 , 5 , 0.2),
  flower =plant(3  ,1.3 , 10, 0.5),
  shrub  =plant(10 ,1.5 , 15, 3),
  tree   =plant(20 ,1.4 , 20, 5)
}
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

function add_plant(id)
  print("adding plant",id, id_to_plant[id])

  local plant_name = id_to_plant[id]
  plant_counter[plant_name] = plant_counter[plant_name]+1
  water = water - plant_info[plant_name].cur_cost
  plant_info[plant_name].cur_cost =  plant_info[plant_name].cur_cost * plant_info[plant_name].cur_cost_inc

  local btn_obj = glib.ui.GetObject(id)
  btn_obj.txt = plant_name.."\n".. rounded_num(plant_info[plant_name].cur_cost)
  recalculate_water()
end

local ui_initialised = false

function sample_state:new()
  print("initialised!!")
end

function sample_state:startup()
  print("startup")

  if ui_initialised == false then
    main_ui.plants.plant_1 = glib.ui.AddButton("Plant A", gvar.scr_h / 2 + gvar.scr_h / 5, gvar.scr_w / 2 - 50, 50, 50)
    id_to_plant[main_ui.plants.plant_1] = "grass"
    glib.ui.SetSpecialCallback(main_ui.plants.plant_1, add_plant)


    ui_initialised = true
  end
end

function sample_state:draw()
  love.graphics.setColor(0, 0, 255)
  love.graphics.rectangle("fill", 0, 0, gvar.scr_w, gvar.scr_h / 2)

  love.graphics.setColor(0, 150, 0)
  love.graphics.rectangle("fill", 0, gvar.scr_h / 2, gvar.scr_w, gvar.scr_h / 2)

  love.graphics.setColor(0, 0, 0)
  love.graphics.print(water_per_second .. " w/s", 20, 20)
  love.graphics.print(tonumber(string.format("%.2f", water)) .. " water", 20, 40)
end

function sample_state:update(dt)
  water = water + water_per_second * dt

  for plant_id, plant_name in pairs(id_to_plant) do
    if plant_info[plant_name].cur_cost < water then
      glib.ui.GetObject(plant_id).color["default_color"] = { 0, 255, 0, 255 }
      glib.ui.SetEnabled(plant_id, true)
    else
      glib.ui.GetObject(plant_id).color["default_color"] = { 255, 0, 0, 255 }
      glib.ui.SetEnabled(plant_id,false)
     end
   end
end

function sample_state:shutdown()
    
end





return sample_state()
