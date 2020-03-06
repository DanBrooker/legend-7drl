--legend
--by draconisnz


size=36

bossrooms = {
  "slime ranch",
  "viper's nest",
  "arachnid's lair",
  "griffon's cave"
}

function roomname(room)
  if room.g == "e" then
    return "depth " .. depth
  elseif room.g == "s" then
    return "secret"
  elseif room.g == "b" then
    return bossrooms[depth]
  elseif room.g == "k" then
    return "key room"
  elseif room.g == "l" then
    return "locked room"
  end
end

t_drops = {
  {"gold", "heart", "food", "health potion", "bomb", "dagger"},
  {"gold", "heart", "food", "health potion", "bomb", "dagger"},
  {"gold", "heart", "food", "health potion", "bomb", "dagger"},
  {"gold", "heart", "food", "health potion", "bomb", "dagger"}
}

t_treasure = {
  {'shield', 'dagger', 'bomb', 'wand', 'bag'},
  {'shield', 'sword', 'ring', 'bow', 'poison dagger', 'bag'},
  {'flaming sword', 'frost bow', 'blood ring', 'mega bomb', 'bag'},
  {'flaming sword', 'frost bow', 'blood ring', 'mega bomb', 'bag'}
}

t_secrets = {
  {'sword', 'poison dagger', 'teleport potion', 'flame potion'},
  {'poison dagger', 'frost bow', 'teleport potion', 'flame potion'},
  {'flaming sword', 'mega bomb', 'teleport potion'},
  {'flaming sword', 'mega bomb', 'teleport potion'}
}

t_enemies = {
  {"bat","slime","baby slime","baby slime"},
  {"slime", "bat", "bat", "snake", "snake"},
  {"snake","spider", "spider", "slime", "mimic"},
  {"viper","spider", "slime", "bat", "mimic"}
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

heal = function(entity, item)
  if (not entity.hp) return
  local health = item.qhp or 1
  log("healing " .. health)
  entity.hp = min(entity.hp + health, entity.mhp)
  addfloat("+" .. health, entity, 9)
  for i=1,3 do
    create_part(entity.x*8+4, entity.y*8+4, rnd(1)-0.5,rnd(0.5)-1,0,rnd(30)+10,rnd(2)+1, 9)
  end
  -- del(inventory, item)
end

teleport = function(entity, item)
  if entity.hp then
    --move to random room
    local room = randa(rooms)
    local pos = rnd_pos(room)
    entity.x,entity.y = pos[1],pos[2]
  else
    player.x,player.y = entity.x,entity.y
  end
  -- del(inventory, item)
  if(zel_clear()) zel_unlock()
end

poison = function(entity, item)
  if entity.hp then
    entity.poison = 2
  else
    add(enviro, {x=entity.x,y=entity.y, turns=9, spr=31})
  end
  for i=1,5 do
    create_part(entity.x*8+4, entity.y*8+4, rnd(1)-0.5,rnd(0.5)-1,0,rnd(30)+10,rnd(2)+1, 11)
  end
  -- del(inventory, item)
end

stun = function(entity, item)
  if entity.hp then
    entity.stun = 3
  end
end

flame = function(entity, item)
  if entity.hp then
    entity.flame = 2
  end
  add(enviro, {x=entity.x,y=entity.y, turns=5, spr=15}) -- todo
  for i=1,5 do
    create_part(entity.x*8+4, entity.y*8+4, rnd(1)-0.5,rnd(0.5)-1,0,rnd(30)+10,rnd(2)+1, 12)
  end
  -- del(inventory, item)
end

function boom(x,y,item)
  local ent = entity_at(x,y)
  if (ent) atk(ent, item.explosion or 2, item.name)
  if (fget(mget(x,y), 1)) mset(x,y, 25)
  create_part(x*8+4, y*8+4, rnd(1)-0.5,rnd(0.5)-1,0,rnd(30)+10,rnd(2)+1, 12)
end

explode = function(entity, item)
  boom(entity.x,entity.y, item)
  for i = 1,4 do
    local dir = dirs[i]
    local x, y = entity.x + dir[1], entity.y + dir[2]
    boom(x,y, item)
  end
end

allitems={
  {'key',3},
  {'gold',35},
  {'heart',37, false, {hp=1}},
  {'shield',52, false, {def=1}},
  {'bag', 28, false, {bag=1}},
  {'food',53, true, {use=heal, qhp=1, col=9}},
  {'health potion',2,true,{throw=heal, use=heal, qhp=2, col=9}},
  {'teleport potion',2,true,{throw=teleport, use=teleport, col=5}},
  {'poison potion',2,true,{throw=poison, use=poison, col=11}},
  {'fire potion',2,true,{throw=flame, use=flame, col=12}},
  {'dagger',19,true,{atk=2}},
  {'poison dagger',19,true,{atk=1, col=11, hit=poison, col=11}}, --rodo
  {'sword',20,false,{atk=3}},
  {'flaming sword',20,false,{col=8, atk=3,col=9, hit=flame}}, --todo
  {'wand',5,false,{ratk=1, col=4, ammo=5}}, -- todo
  {'bow',21,false,{ratk=2, col=4, ammo=10}}, -- todo
  {'frost bow',21,false,{ratk=2, col=5, ammo=10, throw=stun}}, -- todo
  {'bomb',18,true,{throw=explode,use=explode}}, -- todo
  {'mega bomb',18,true,{throw=explode,use=explode, explosion=4,col=7}}, -- todo
  {'blood ring', 36, true, {hp=5}},
  {'ring', 4, true, {hp=4}},
  -- {'leather armour', 52, false, {def=1}},
  -- {'chainmail', 52, false, {def=2}},
  -- {'platemail', 52, false, {def=3}}
}

function slime_ai(entity)
  local dist = distance(entity.x, entity.y, player.x, player.y)
  if (dist > 10) return
  if dist <= 2 then
   move_towards(entity)
  else
   local shuffled = shuffle({1,2,3,4})
   for i in all(shuffled) do
      local dir = dirs[i]
      local dx,dy = dir[1], dir[2]
      local x, y = entity.x + dx, entity.y + dy
      if walkable(x, y, "entities") then
        mobwalk(entity, dx,dy)
        return
      end
    end
  end
end

function mimic_ai(entity)
  -- log("mimic ai")
 local dist = distance(entity.x, entity.y, player.x, player.y)
 if (dist > 10) return
 if (dist == 1) then
   entity.triggered = true
   move_towards(entity)
 elseif entity.triggered then
   -- log("mimic move")
   move_towards(entity)
 end
end

allenemies={
  {'baby slime',17, {hp=1, ai=slime_ai, slime=true}},
  {'slime',50, {hp=2, ai=slime_ai,slime=true}},
  {'bat',34, {flying=true}},
  {'snake',49, {hit=poison}},

  {'viper',48, {atk=2, hp=3, hit=poison}},
  {'spider',33, {hp=4, flying=true}},

  {'griffon',32, {hp=5, hit=stun}},
  {'mimic',51, {hp=3, ai=mimic_ai}},
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

bestiary = {}
for enemy in all(allenemies) do
  bestiary[enemy[1]] = enemy
end

function enemy_create(x, y, name)
  if (x==-1 and y==-1) return

  local data = bestiary[name]
  local new_enemy = entity_create(x, y, data[2], data[3])
  new_enemy["name"] = name
  add(enemies, new_enemy)
  return new_enemy
end

function entity_create(x, y, spr, args)
  if (x==-1 and y==-1) return
  -- log(args)
  local new_entity = {
   name = "lnk",
   x = x,
   y = y,
   mov = nil,
   ox = 0,
   oy = 0,
   ai = ai_action,

   -- col = col or 10,
   outline = false,
   ani = {spr},
   flash = 0,

   stun=0,
   roots=0,
   poison=0,
   flying=false,
   flame=0,

   hp=1,
   def=0,
   atk=1,
   ratk=0,
  }
  new_entity.mhp = new_entity.hp
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
 dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}
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
 checkfade()

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
  fadeperc=0
  reason = "not sending link"

  debug={}
  shake=0
  shakex=0
  shakey=0

	message = { text="", ticks=0 }

  depth=1
  gold=0
  invsize=5

  aiming = false
  aimingi = 0
  using = false
  usingi = 0

  entities={}
  enemies={}
  items={}
  float={}
  enviro={}
  inventory={}
  particles={}

  zel_init()

  player=entity_create(start[1] * 8 - 4, start[2] * 8 -4, 16, {ai = noop, mhp=3, hp=3, name="player"})
  zel_spawn(zgetar())
  log(zgetar())
  local ppos = rnd_pos(zgetar())
  if ppos[1] != -1 then
    player.x,player.y = ppos[1],ppos[2]
  end


  _upd=update_game
  _drw=draw_game
end

function noop()
end

function gameover()
  -- log('set gameover')
  fadeout(0.02)
  _upd=update_gameover
  _drw=draw_gameover

end

function update_gameover()
  -- if (fadeperc == 0) fadeperc=0
  if getbutt() >= 0 then
    -- log("restart game")
    startgame()
  end
end

function draw_gameover()
  cls(0)
  cursor(16,16)
  color(8)
  print('gameover')
  print('')
  color(9)
  print('death by ' .. reason)
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
  fadeout(0.01)
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
