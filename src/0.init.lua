--legend
--by draconisnz


size=36
-- dev=true

t_player = 16
t_griffon = 32
t_spider = 33
t_bat = 34
t_viper = 48
t_snake = 49
t_slime= 50

hit=0
pick=1
nope=2
ouch=3

t_enemies = {
  {t_bat,t_snake,t_slime},
  {t_bat,t_snake,t_spider},
  {t_viper,t_snake,t_spider},
  {t_viper,t_spider,t_griffon},
  {t_viper,t_spider,t_griffon},
  {t_viper,t_spider,t_griffon}
}

-- t_key = {"key"}
-- t_gold = {"gold"}
-- t_weapons = {"dagger","poison dagger", "bow", "wand", "sword", "bomb"}
-- t_items = {"gold","ring","amulet","leather armour","chainmail", "bomb"}
-- t_heals = {"health potion"}

t_drops = {
  {"gold", "heart", "food", "health potion", "bomb", "dagger"},
  {"gold", "heart", "food", "health potion", "bomb", "dagger"},
  {"gold", "heart", "food", "health potion", "bomb", "dagger"}
}

t_treasure = {
  {'shield', 'dagger', 'bomb', 'wand'},
  {'shield', 'sword', 'ring', 'bow'},
  {'shield', 'wand', 'amulet'}
}

t_secrets = {
  {'leather armour', 'poison dagger'},
  {'poison dagger', 'frost bow'},
  {'flaming sword', 'mega bomb'}
}

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

allitems={
  {'key',3},
  {'gold',35},
  {'heart',37, false, {hp=1}},
  {'shield',52, false, {def=1}},
  {'food',53, true, {quaff=heal, qhp=1, col=9}},
  {'health potion',2,true,{throw=heal, quaff=heal, qhp=2, col=9}}, -- todo
  {'teleport potion',2,true,{quaff=teleport, throw=teleport, col=12}}, -- todo
  {'dagger',19,true,{atk=2}},
  {'poison dagger',19,true,{atk=1, col=11, poison=1, throw=true, col=11}}, --rodo
  {'sword',20,false,{atk=3,col=6}},
  {'flaming sword',10,false,{col=8, atk=3, flame=1,col=9}}, --todo
  {'wand',5,false,{ratk=1, col=4, ammo=3}}, -- todo
  {'bow',21,false,{ratk=2, col=4, ammo=3}}, -- todo
  {'frost bow',21,false,{ratk=2, freeze=2, col=12, ammo=5}}, -- todo
  {'bomb',18,true,{throw=expode, explosion=1,col=5}}, -- todo
  {'mega bomb',18,true,{throw=expode, explosion=2,col=8}}, -- todo
  {'blood ring', 36, true, {hp=5}},
  {'ring', 4, true, {hp=5}},
  -- {'leather armour', 52, false, {def=1}},
  -- {'chainmail', 52, false, {def=2}},
  -- {'platemail', 52, false, {def=3}}
}

allenemies={

}

armoury = {}
for item in all(allitems) do
   new_item = {
    name=item[1],
    spr=item[2],
    stack=item[3] or false,
  }
  for k,v in pairs(item[4] or {}) do
    new_item[k] = v
  end
  armoury[item[1]] = new_item
end

function enemy_create(x, y, spr, args)
  if (x==-1 and y==-1) return
  local new_enemy = entity_create(x, y, spr, args)
  add(enemies, new_enemy)
  return new_enemy
end

function entity_create(x, y, spr, args)
  if (x==-1 and y==-1) return
  -- log(args)
  local new_entity = {
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

function item_create(pos, name, args)
  if (x==-1 and y==-1) return
  -- log("create " .. name .. " " .. to_s(args))
  local data = armoury[name]
  if not data then
    -- log("no data for " .. name)
    return
  end
  -- log(data)
  local new_item = {
   x = pos[1],
   y = pos[2]
  }
  for k,v in pairs(data) do
   new_item[k] = v
  end
  for k,v in pairs(args or {}) do
   new_item[k] = v
  end
  add(items, new_item)
  return new_item
end

function _init()
 t=0

 --dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14} -- fading

 dirs = {{-1,0}, {1,0}, {0,-1}, {0,1}}
 _pal={0,128,133,130,129,12,141,2,14,8,10,11,137,7,134,5}
 poke(0x5f2e,1)

 startgame()
end

function _update60()
 t+=1
 _upd()
 dofloats()
end

function rpal()
  pal()
  for i,c in pairs(_pal) do
   pal(i-1,c,1)
  end
end

function _draw()
  -- rpal()
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
  -- log("startgame")
  --fading
  --fadeperc=1

  debug={}
  shake=0
  shakex=0
  shakey=0

  depth=1
  gold=0

  aiming = false
  aimingi = 0
  inventory_window = false

  entities={}
  enemies={}
  items={}
  float={}
  enviro={}
  inventory={}
  particles={}

  zel_init()

  player=entity_create(start[1] * 8 - 4, start[2] * 8 -4, t_player, {ai = noop})
  zel_spawn(zgetar())
  log(zgetar())
  local ppos = rnd_pos(zgetar())
  if ppos[1] != -1 then
    player.x,player.y = ppos[1],ppos[2]
  else
    log("WHOOPS player at -1,-1")
  end

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
