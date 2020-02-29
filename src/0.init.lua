--legend
--by draconisnz


size=36
-- dev=true

t_player = 16
t_bat = 32
t_snake = 48

t_key = {"k1"}
t_gold = {"g1"}
t_weapons = {"w1","w2","w3"}
t_items = {"i1", "i2", "i3"}

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
    dmg = 2,
    spr = 19
  },
  w2 = {
    name = "sword",
    type = "w",
    dmg = 3,
    spr = 20
  },
  w3 = {
    name = "great sword",
    type = "w",
    dmg = 4,
    spr = 20
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
  i3 = {
    name = "bomb",
    type = "i",
    spr = 18
  }
}

id=0
function entity_create(x, y, spr, col, args)
  id += 1
  local new_entity = {
   id = id,
   name = "ent" .. x .. "x" .. y,
   x = x,
   y = y,
   mov = nil,
   --w = 8,
   --h = 8,
   ox = 0,
   oy = 0,
   hp = 3,
   flip = false,
   col = col or 10,
   outline = false,
   ani = {spr, spr+1},
   attackani = { spr+2, spr+3 },
   range = 8,
   sight = 64,
   flash = 0,
   stun=0,
   roots=0,
   dmg=1,
   --speed = .2,
   flying = false,
   attack = 1,
   --attackcooldown = 30,
   --animation = 'idle'
  }
  for k,v in pairs(args or {}) do
   new_entity[k] = v
  end
  add(entities, new_entity)
  return new_entity
end
function item_create(x, y, key)
  -- log(key)
  local data = armoury[key]
  -- log(data)
  local new_item = {
   id = id,
   x = x,
   y = y
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
  --fading
  --fadeperc=1

  debug={}
  shake=0
  shakex=0
  shakey=0

  entities={}
  mobs={}
  items={}
  float={}
  enviro={}
  inventory={}

  zel_init()

  player=entity_create(start[1] * 8 - 4, start[2] * 8 -4, t_player, 8)
  zel_spawn(zgetar())

  _upd=update_game
  _drw=draw_game
end
