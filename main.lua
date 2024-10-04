gr = love.graphics


class_base= require("helper.classic")
console =require("helper.console")
timer =require("helper.timer")


g = require("globals")
gvar = g.vars
glib = g.libs


game = require("game")


local maj, min, rev = love.getVersion()
if maj >= 11 then
  require("helper.cindy").applyPatch()
end



last_axis_1_angle = 0
last_axis_2_angle = 0


function love.load(args)
  
  for idx, arg in pairs(args) do
      if arg == "-debug" then
        debuger = require("mobdebug")
        debuger.start()
        debuger.off()
        break
      end
  end
  
  
  gvar.scr_w,gvar.scr_h =love.graphics.getDimensions()
  print("hi")
  print("sizes",gvar.scr_h, gvar.scr_w)
  print("what")
  glib.ui.init()

  --love.window.setMode(80*tile_size,50*tile_size)
  game.load()
  
  --love.keyboard.setKeyRepeat(true)
end


function love.update(dt)
  game.update(dt)
end

function love.draw()
  game.draw()
end


function love.keypressed(k,s,r)
  game.keyHandle(k,s,r,true)
  if key == "escape" then
    love.event.quit()
  end
end

function love.keyreleased(k)
    game.keyHandle(k,0,0,false)
end

function love.mousepressed(x,y,btn,t)
  game.MouseHandle(x,y,btn,t)
end

function love.mousemoved(x,y,dx,dy)
    game.MouseMoved(x,y)
end

function love.joystickpressed(j,b)
    b_to_k ={        [1] ="x"
    }
    if b_to_k[b]~= nil then
        print(j,b)
        game.joy_handle(j,b_to_k[b],true)
    end
end

function love.joystickreleased(j,b)
    b_to_k ={
        [1] ="x"
    }
    if b_to_k[b]~= nil then
        print(j,b)
        game.joy_handle(j,b_to_k[b],false)
    end
end



function love.joystickaxis(j,a,v)
    print("------------------------------")
    print(j:getName(),a,v)
    print(j:getAxis(a))
    --print(j)
    
    --print(j.getGamepadAxis(j,2))
    
    game.joy_move(j,a,v)
    

end


function love.resize(w,h)
        gvar.scr_h=h
        gvar.scr_w=w
end
