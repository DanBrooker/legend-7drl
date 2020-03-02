--legend
--by draconisnz


size=36
-- dev=true

t_player = 16
t_bat = 32
t_snake = 48

t_key = {"k1"}
t_gold = {"g1"}
t_weapons = {"w1","w2","w3","w4","w5"}
t_items = {"i1", "i2", "i3","i4",'i5',"g1"}
t_heals = {"i5"}

t_stairs = 58
t_wall_t = 12
t_wall_b = 44
t_wall_l = 27
t_wall_r = 29
t_door_t = 7
t_door_b = 23
t_door_l = 39
t_door_r = 55
t_floor = {9,10,25,26,41} --,57, 42}

armoury = {
  k1 = {
    name = 'key',
    spr = 3,
    type = 'k'
  },
  g1 = {
    name = 'gold',
    spr = 35,
    amount = 1,
    type = 'g'
  },
  w1 = {
    name = "dagger",
    type = "w",
    atk = 2,
    spr = 19
  },
  w2 = {
    name = "sword",
    type = "w",
    atk = 3,
    spr = 20
  },
  w3 = {
    name = "great sword",
    type = "w",
    atk = 4,
    spr = 20
  },
  w4 = {
    name = "wand",
    type = "w",
    ratk = 1,
    spr = 5
  },
  w5 = {
    name = "bow",
    type = "w",
    ratk = 2,
    spr = 21
  },
  i1 = {
    name = "ring",
    type = "e",
    spr = 4
  },
  i2 = {
    name = "amulet",
    type = "e",
    spr = 36
  },
  i3 = {
    name = "armour",
    type = "e",
    armour = 1,
    spr = 52
  },
  i4 = {
    name = "bomb",
    type = "i",
    spr = 18
  },
  i5 = {
    name = "health potion",
    type = "p",
    dhp = 2,
    spr=2
  }
}

id=0
function entity_create(x, y, spr, args)
  -- log(args)
  id += 1
  local new_entity = {
   id = id,
   x = x,
   y = y,
   mov = nil,
   ox = 0,
   oy = 0,
   ai = ai_action,

   -- col = col or 10,
   outline = true,
   ani = {spr},
   flash = 0,

   stun=0,
   roots=0,
   poison=0,
   flying=false,
   stealth=0,

   hp=3,
   def=0,
   atk=1,
   ratk=0,
  }
  for k,v in pairs(args or {}) do
    -- log(k .. "=" .. to_s(v))
    new_entity[k] = v
  end
  add(entities, new_entity)
  return new_entity
end
function item_create(pos, key)
  -- log(key)
  local data = armoury[key]
  -- log(data)
  local new_item = {
   id = id,
   x = pos[1],
   y = pos[2]
  }
  for k,v in pairs(data) do
   new_item[k] = v
  end
  add(items, new_item)
  return new_item
end

function _init()
 t=0

 --dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14} -- fading

 dirs = {{-1,0}, {1,0}, {0,-1}, {0,1}}

 startgame()
end

function _update60()
 t+=1
 _upd()
 dofloats()
end

function _draw()
 _drw()
 --checkfade()

 cursor(4,4)
 color(8)
 camera()
 for txt in all(debug) do
  print(txt)
 end
end

function startgame()
  log("startgame")
  --fading
  --fadeperc=1

  debug={}
  shake=0
  shakex=0
  shakey=0

  depth=1
  gold=0

  entities={}
  mobs={}
  items={}
  float={}
  enviro={}
  inventory={}

  zel_init()

  player=entity_create(start[1] * 8 - 4, start[2] * 8 -4, t_player, {ai = noop})
  zel_spawn(zgetar())

  _upd=update_game
  _drw=draw_game
end

function noop()
end

function gameover()
  -- log('set gameover')
  _upd=update_gameover
  _drw=draw_gameover
end

function update_gameover()
  if getbutt() >= 0 then
    -- log("restart game")
    startgame()
  end
end

function draw_gameover()
  cls(0)
  color(8)
  print('gameover')
  print('')
  color(9)
  print('you died')
  color(10)
  print('on depth ' .. depth)
  color(11)
  print('with ' .. gold .. ' gold')
  color(12)
  print('and ' .. #inventory .. ' items')
  print('')
  color(13)
  print('press any key to restart')
end

function win_game()
  _upd=update_gamewin
  _drw=draw_gamewin
end

function update_gamewin()
  if getbutt() >= 0 then
    -- log("restart game")
    startgame()
  end
end

function draw_gamewin()
  cls(0)

  print 'you win!'
  print('with ' .. gold .. ' gold')
  print('')
  color(13)
  print('press any key to restart')
end
