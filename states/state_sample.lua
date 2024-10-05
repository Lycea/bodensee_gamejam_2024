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
                {w=10,h=8} --size
           ),
  flower =plant(3  ,1.3 , 10, 0.5, {w=5,h=10}),
  shrub  =plant(10 ,1.5 , 15, 3, {w=10,h=10}),
  tree   =plant(20 ,1.4 , 20, 5, {w=15,h=20})
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
  glib.ui.SetSpecialCallback(main_ui.plants[name], add_plant)

  plants_unlocked= plants_unlocked+1
end

function add_plant(id)
  print("adding plant",id, id_to_plant[id])

  local plant_name = id_to_plant[id]
  plant_counter[plant_name] = plant_counter[plant_name]+1
  water = water - plant_info[plant_name].cur_cost
  plant_info[plant_name].cur_cost =  plant_info[plant_name].cur_cost * plant_info[plant_name].cur_cost_inc

    table.insert(plant_objects[plant_name],
                 {
                   w=plant_info[plant_name].size.w, h=plant_info[plant_name].size.h,
                  x= love.math.random(0,gvar.scr_w- 20),y= gvar.scr_h/2
                 }
                )

  if plant_counter[plant_name] >=5 and plant_unlocked[ plant_unlock[plant_name]  ]  == false then
    local next_plant = plant_unlock[plant_name]
    unlock_plant(next_plant)
    plant_unlocked[next_plant]=true
  end
  
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
    unlock_plant("grass")

    ui_initialised = true
  end
end

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

  --plants !
  for name, available_plants in pairs(plant_objects) do
    for _, planted_plant in pairs(available_plants) do
      love.graphics.rectangle("line",
                              planted_plant.x ,planted_plant.y -planted_plant.h,
                              planted_plant.w ,planted_plant.h)
    end
  end
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
