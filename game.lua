require("key_handle")
require("renderer.renderer")

require("states.game_states")
sample_state=require("states.state_sample")

local game ={} 


--------------------------- 
--preinit functions? 
--------------------------- 
 
 
local base={} 
------------------------------------------------------------ 
--Base data fields 
------------------------------------------------------------ 
 

constants = nil


------------------------ 
-- dynamic data 



--game state
game_state = GameStates.MAIN_MENUE
previous_game_state = game_state



mouse_coords={0,0}


exit_timer =0

show_main_menue =true
main_menue_item = 1

selected_state_idx = 1


----------------------------------------------------------- 
-- special data fields for debugging / testing only 
----------------------------------------------------------- 
local ui = {
  start_button = nil,
  exit_button = nil
}


function start_btn()
 show_main_menue = false
  game_state = GameStates.PLAYING
  game.new()

  for k, id in pairs(ui) do
    glib.ui.SetVisibiliti(id, false)
    glib.ui.SetEnabled(id, false)
  end
  glib.ui.UnsetFocus()
end

function exit_btn()

end


function update_menue()
	for key,v in pairs(key_list) do
      print("Key pressed",key)
    local action=handle_main_menue(key)--get key callbacks
        if action["menue_idx_change"] ~= nil then
          if key_timer+0.2 < love.timer.getTime() then
            
            main_menue_item = main_menue_item+ action["menue_idx_change"][2] 
            if main_menue_item <1 then main_menue_item = 1 end
            if main_menue_item>4 then main_menue_item = 4 end
            print(main_menue_item)
          
            key_timer = love.timer.getTime()
          
          end
          
        end
        
        -- main menu action handling
        if action["selected_item"]~= nil then
          show_main_menue = false
          --menue item switcher
          if main_menue_item == 1 then--new game
            game_state=GameStates.PLAYING
            game.new()
          elseif main_menue_item == 2 then--load game
            love.event.quit()
          end
        end
        
        if action["exit"]~= nil then
            love.event.quit()
        end
	end
end



--loading a game
function game.load()
  print("load")
  ui.start_button = glib.ui.AddButton("start",10,10, 50,20)
  ui.exit_button = glib.ui.AddButton("exit", 10, 40, 50,20)

  glib.ui.SetSpecialCallback(ui.start_button,start_btn)
  glib.ui.SetSpecialCallback(ui.exit_button,start_btn)
end 
 
 
 --new game
function game.new()
   sample_state:startup()
end

 

function game.play(dt) 
  glib.ui.update()


  sample_state:update()

end 
 





--main loop
function game.update(dt) 
  
  --handle game stuff
  if show_main_menue == false then
    game.play(dt)
    glib.ui.update()
    return
  end
  
    glib.ui.update()
  --handle menue
end

 
function game.draw() 
    if show_main_menue ==true then
        glib.ui.draw()
        return
    end

    glib.ui.draw()
end 
 
 

function game.keyHandle(key,s,r,pressed_) 
  if pressed_ == true then
    key_list[key] = true
    last_key=key
  else
    key_list[key] = nil
  end
end 
 
 


function game.MouseHandle(x,y,btn) 
   
end 
 
function game.MouseMoved(mx,my) 
  mouse_coords={mx,my}
end 
 
 

return game
