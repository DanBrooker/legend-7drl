pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
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
-->8
--game
function update_game()
   update_player(player)
   -- for mob in all(mobs) do
   --   update_mob(mob)
   -- end
   foreach(particles, update_part)
end

function draw_game()
  cls(0)

  do_shake()

  clip(32, 32, 128-56, 128-56)
    rpal()
  map(0, 0, 0,0, size, size)


  foreach(enviro,item_draw)
  foreach(items,item_draw)
  foreach(entities,entity_draw)
  clip()
  foreach(particles, draw_part)
  foreach(float, draw_float)
  -- if (dev) minimap_draw()

  camera()

  draw_inventory()
  draw_health()
  draw_stats()
  zel_draw()
  draw_instructions()
  if message.ticks > 0 then
    local text = message.text
    rectfill(0,60,128, 68, 5)
    print(text, hcenter(text), vcenter(text), 0)
    message.ticks -= 1
  end
end

function draw_instructions()
  cursor(3,116)
  color(13)
  if aiming then
    color(8)
    print("arrows = fire, z = next")
  elseif using then
    color(8)
    print("z = confirm, x = next")
  elseif #inventory > 0 then
    print("z = aim, x = use")
  end
end

function draw_inventory()
  local j = 0
  for item in all(inventory) do
    _item_draw(item.spr,40 + j, 106,item.col)
    j += 8
  end
  if aiming then
    rect(39 + (8*aimingi), 106, 39 + (8*aimingi) + 9, 106 + 8, 11)
  end
  if using then
    rect(39 + (8*usingi), 106, 39 + (8*usingi) + 9, 106 + 8, 11)
  end
end

function draw_stats()
  cursor(2, 20)
  print("atk " .. player.atk)
  cursor(2, 28)
  if (gold > 0) print("gold " .. gold)
end

function draw_health()
  -- rectfill(0, 0, 11, 22, 0)
  local hearts = ""
  for i=1,player.mhp do
   hearts = hearts .. "\x87"
  end
  print(hearts, 1, 1, 3)
  hearts = ""
  for i=1,player.hp do
   hearts = hearts .. "\x87"
  end
  -- debug[1] = player.hp
  print(hearts, 1, 1, 9)
  local armour = ""
  for i=1,player.def do
   armour = armour .. "\x87"
  end
  print(armour, 1, 10, 5)
end

function update_player(player)
  if (player.hp <= 0) gameover()
  local endturn = input(getbutt())

  if endturn then
    --animate()
    animate(update_end_turn)
  end
end

-- function update_mob(mob)
--
-- end

function pickup_item(item)
  -- sfx(pick)
  -- local isgold = item.name == 'gold'
  if item.name == 'gold' then
    del(items, item)
    gold += 1
    addfloat('+gold', player, 10)
    return
  elseif item.name == 'bag' then
    del(items, item)
    invsize += 1
    addfloat('+bag', player, 10)
    return
  elseif item.name == 'heart' then
    del(items, item)
    player.hp = min(player.hp + 1, player.mhp)
    addfloat('+hp', player, 10)
    return
  elseif item.name == 'shield' then
    del(items, item)
    player.def += 1
    addfloat('+def', player, 10)
    return
  end


  local match = find(inventory, "name", item.name)
  if match and not item.stack then
    return
  elseif #inventory == 5 then

    if rand(0,4) == 1 then
      addfloat("fumble", {x=player.x-1,y=player.y-1}, 9)
      inventory = shuffle(inventory)
      local drop = pop(inventory)
      -- drop_item({item.x,item.y}, drop)
      item_create({item.x,item.y}, drop.name) -- bug here, will re charge items if fumbled, maybe leave in :D
    else
      addfloat("full", {x=player.x-1,y=player.y-1}, 9)
      return
    end
  end

  del(items, item)

  addfloat(item.name, player, 10)

  add(inventory, item)
  update_stats()
end

function update_stats()
  player.atk = 1
  player.mhp = 3
  player.def = 0
  for item in all(inventory) do
    if item.atk then
      player.atk = max(player.atk, item.atk)
    elseif item.hp then
      player.mhp = max(player.mhp, item.hp)
    elseif item.def then
      player.def = max(player.def, item.def)
    end
  end
end

function update_end_turn()

 room = zgetar()
 if not room.spawn then
   -- move player in one
   player.x += lastmove[1]
   player.y += lastmove[2]

   zel_spawn(room)
 end

 item = item_at(player.x, player.y)
 if (item) pickup_item(item)

 for entity in all(entities) do
   entity.mov = nil
   local tile = mget(entity.x,entity.y)
   if tile == t_stairs and entity == player then
     depth += 1

     if depth == 5 then
       win_game()
       return
     end

     zel_generate()
     player.x, player.y = start[1] * 8 - 4, start[2] * 8 -4
   --elseif fget(tile, 5) then
    -- tip = 'watch your step'
    --if (not entity.flying) atk(entity, 2, 'the void')
   else
    local env = env_at(entity.x,entity.y)
    if env and not entity.flying then
      log(entity.name .. " stood on env")
      if (env.spr == 31 and not entity.slime) poison(entity, {})
      if (env.spr == 15) flame(entity, {})
     -- add(debug, entity.name .. "=" .. env.type)
     -- if (entity.name != env.type) atk(entity, 1, env.name)
    end
   end
  if (entity.poison > 0) then
    entity.poison -= 1
    atk(entity, 1, 'poison')
  end
  if (entity.flame > 0) then
    entity.flame -= 1
    atk(entity, 1, 'fire')
  end
  if (entity.hp <= 0) then
   on_death(entity)
  end
 end
 for env in all(enviro) do
  env.turns -= 1
  if(env.turns <= 0) del(enviro, env)
 end
 _upd = update_ai
  --_upd =
end

function on_death(ent)
  if ent != player then
    del(enemies, ent)
    del(entities, ent)
    if rand(0,10) == 1 or ent.loot then
      -- drop_item(ent.x, ent.y)
      item_create({ent.x,ent.y}, randa(t_drops[depth]))
    end
    if(zel_clear()) zel_unlock()
  end
end

-- function drop_item(x,y)
--   local random = rand(1,4)
--   local item = "health potion"
--   if random == 1 then
--     item = randa(t_items)
--   elseif random == 2 then
--     item = randa(t_weapons)
--   elseif random == 3 then
--     item = "gold"
--   end
--   -- log("drop!!!")
--   item_create({x,y}, item)
-- end

function update_ai()
  --buffer()

  for entity in all(entities) do
   if entity != player and entity.hp > 0 then
    if entity.stun > 0 then
     entity.stun -= 1
    else
     -- add(debug, "action " .. entity.name)
     --if entity.boss then
      --boss_action(entity)
     --else
      if entity.ai then
        entity.ai(entity)
      end
     --end
    end
    if (entity.roots > 0) entity.roots -= 1
   end
  end

  animate()
end

function ai_action(entity)
 if (distance(entity.x, entity.y, player.x, player.y) > 10) return
 move_towards(entity)
end

function move_towards(entity)
 local shuffled = shuffle({1,2,3,4})
 local moves = {}
 for i in all(shuffled) do
  local dir = dirs[i]
  local dx,dy = dir[1], dir[2]
  local x, y = entity.x + dx, entity.y + dy
  local dist = distance(x, y, player.x, player.y)
  if dist == 0 then
   mobbump(entity, dx, dy)
   atk(player, entity.atk, entity.name)
   return
 elseif walkable(x, y, "entities") or (entity.flying and not enemy_at(x, y)) then
   -- if (entity.roots > 0) return
   insert(moves, dir, dist)
  end
 end

 if #moves > 0 then
  local move = pop(moves)[1]
  -- add(debug, "move " .. move[1])
  -- if (entity.trail) add_enviro(entity.x, entity.y, entity.trail, 2)
  mobwalk(entity, move[1], move[2])
 end
end

function atk(entity, amount, cause)

  local def = entity.def
  if def and def > 0 then
    unblocked = max(amount - def, 0)
    blocked =  amount - unblocked
    entity.def -= blocked
    amount = unblocked
  end
 if amount <= 0 then
   return
  -- addfloat('+'.. abs(amount), entity, 11)
 else
  addfloat('-'.. amount, entity, 8)
 end

 entity.hp -= amount
 entity.flash = 10
 -- sfx(hit)
 shake=.5

 if(entity == player) reason = cause
 log(cause .. " hit " .. entity.name .. " " .. amount)
end

function entity_draw(self)
 local col = self.col
 if self.flash>0 then
  self.flash-=1
  col=13
  elseif self.poison > 0 then
    col=11
  elseif self.flame > 0 then
    col=12
  elseif self.stun > 0 then
    col=7
 end
 local frame = self.stun != 0 and self.ani[1] or getframe(self.ani)
 local x, y = self.x*8+self.ox, self.y*8+self.oy
 drawspr(frame, x, y, col, self.flp, self.flash > 0 or col!=self.col, self.outline)

 --if (self.stun !=0) draws(10, x, y, 0, false)
 --if (self.roots !=0) draws(11, x, y, 0, false)
 --if (self.linked) draws(12, x, y, 0, false)
end

function item_draw(self)
 _item_draw(self.spr, self.x*8, self.y*8, self.col)
end

function _item_draw(s,x,y,col)
  pal(15,col or 10)
  spr(s,x,y)
  rpal()
end

function getframe(ani)
 return ani[flr(t/15)%#ani+1]
end

function getbutt()
 for i=0,5 do
  if (btnp(i)) return i
 end
 return -1
end

function input(butt)
 if butt<0 then return false end
 if butt<4 then
  if aiming then
   return fireprojectile(player, dirs[butt+1])
  elseif using then
    return use()
  else
   return moveplayer(dirs[butt+1])
  end
elseif butt==4 and #inventory > 0 then
  if aiming then
    aimingi += 1
    if aimingi >= #inventory then
      aiming = false
      aimingi = 0
    end
  elseif using then
    return use()
  else
    aiming = true
  end
  return false
 elseif butt==5 and #inventory > 0 then
   if using then
     usingi += 1
     if usingi >= #inventory then
       using = false
       usingi = 0
     end
   else
     using = true
   end
   --return false -- maybe discharge if #enemies == 0
  --else
   --return switchitem()
  --end
 end
end

function use()
  using = false
  local item = inventory[usingi+1]
  -- log("use")
  -- log(item)
  if item.use then
    item.use(player, item)
    del(inventory, item)
    return true
  else
    addfloat('?', player, 9)
    return false
  end
end

function fireprojectile(entity, dir)
  mobflip(entity, dir[1])
  aiming = false
  -- charges[item] -= 1
  local hx, hy = throwtile(dir[1], dir[2]) -- max distance???

  local item = inventory[aimingi+1]
  -- log("fire item")
  -- log(item)

  if item.ammo then
    if item.ammo == 0 then
      addfloat("out of charges", player, 9)
      item.ammo = -1
      item.ratk = nil
      return false
    else
      item.ammo -= 1
    end
  end

  local hit = entity_at(hx, hy)
  local amount = 1

  if item.ratk then
    amount = item.ratk
  else
   if not hit or item.name == 'key' then
     hx -= dir[1]
     hy -= dir[2]
     amount = 0
     -- item_create({hx,hy}, item.name, {ammo=item.ammo})
     item.x, item.y = hx, hy

     if (not item.throw) add(items, item)
   end

   del(inventory, item)
   update_stats()
  end

  if item.throw then
    item.throw(hit or {x=hx,y=hy}, item)
    del(inventory, item)
  elseif hit then
    atk(hit, amount, item.name)
  end

  for i=1,4 do
    -- different colours??
    create_part(hx*8+4, hy*8+4,(rnd(16)-8)/16,(rnd(16)-8)/16, 0, rnd(30)+10,rnd(2)+3, 8)
  end

  -- create_part(hx,hy,rnd(1)-0.5,rnd(0.5)-1,0,rnd(30)+10,rnd(4)+2)
  -- create_part(hx*8+4, hy*8+4, rnd(1)-0.5,rnd(0.5)-1,0,rnd(30)+10,rnd(4)+2,5)


  -- debug[1]= magics[stored[item]]
  -- effects[m](hx, hy, hit, entity)
  return true
end

function aimtile(entity, dx, dy)
 local tx,ty,i = entity.x,entity.y,0
 repeat
  tx += dx
  ty += dy
  i += 1
 until not walkable(tx,ty, "player") or i >= 8
 return tx,ty
end

function throwtile(dx, dy)
 local tx,ty,i = player.x,player.y,0
 repeat
  tx += dx
  ty += dy
  i += 1
 until not walkable(tx,ty, "entities") or i >= 8
 return tx,ty
end

function find(array, key, value)
  for m in all(array) do
   if m[key] == value then
    return m
   end
  end
end

function moveplayer(dir)
  lastmove = dir
  local dx, dy = dir[1], dir[2]
  local destx,desty=player.x+dx,player.y+dy
  --local tle=mget(destx,desty)

  if walkable(destx, desty, "entities") then
  -- sfx(63)
    mobwalk(player,dx,dy)
  --animate()
elseif locked(destx,desty) and find(inventory, "name", "key") then
    -- log("unlocked")
    local key = find(inventory, "name", "key")
    del(inventory, key)
    mset(destx, desty, mget(destx,desty)-7)
    -- mobwalk(player,dx,dy)
  elseif entity_at(destx,desty) then
    entity = entity_at(destx,desty)
    atk(entity, player.atk, player.name)

    -- check inventory for item with hit
    for item in all(inventory) do
      if (item.hit) then
        log("item.hit")
        item.hit(entity, item)
      end
    end

    mobbump(player,dx,dy)
  else
  -- sfx(63)
    mobbump(player,dx,dy)
    return false
  end
  return true
end

function locked(x, y)
  local locked = fget(mget(x,y), 2)
  -- log("locked " .. to_s(locked))
  return locked
end

function walkable(x, y, mode)
 local mode = mode or ""
 local floor = not fget(mget(x,y), 0)

 if mode == "entities" then
  if (floor) return entity_at(x,y) == nil
 end
 if mode == "items" then
  if (floor) return item_at(x,y) == nil
 end
 if mode == "player" then
  if (floor) return player.x == x and player.y == y
 end
 return floor
end

function blank_at(x,y, array)
  for m in all(array) do
   if m.x==x and m.y==y then
    return m
   end
  end
end

function entity_at(x,y)
  return blank_at(x,y, entities)
end

function enemy_at(x,y)
  return blank_at(x,y, enemies)
end

function item_at(x,y)
  return blank_at(x,y, items)
end

function env_at(x,y)
  return blank_at(x,y, enviro)
end

function mobwalk(mb,dx,dy)
 mb.x+=dx --?
 mb.y+=dy

 mobflip(mb,dx)
 mb.sox,mb.soy=-dx*8,-dy*8
 mb.ox,mb.oy=mb.sox,mb.soy
 mb.mov=mov_walk
end

function mobbump(mb,dx,dy)
 mobflip(mb,dx)
 mb.sox,mb.soy=dx*8,dy*8
 mb.ox,mb.oy=0,0
 mb.mov=mov_bump
end

function mobflip(mb,dx)
 mb.flp = dx==0 and mb.flp or dx<0
end

function mov_walk(self)
 local tme=1-p_t
 self.ox=self.sox*tme
 self.oy=self.soy*tme
end

function mov_bump(self)
 local tme= p_t>0.5 and 1-p_t or p_t
 self.ox=self.sox*tme
 self.oy=self.soy*tme
end

function update_animate()
 --buffer()
 p_t=min(p_t+0.6,1)  -- 0.125

 for entity in all(entities) do
  if entity.mov then
   entity:mov()
  end
 end

 if p_t==1 then
    if (_push_wait) wait(_push_wait)
    _upd=_push_upd or update_game
  end
end

function animate(push_upd)
 p_t=0
 _push_upd = push_upd
 _upd=update_animate
end
-->8
--zelda
function zel_init()
  clear_map()
  zel_generate()
end

function zel_draw()
  local rs = flr(size/s)
  for i = 1,s do
    for j = 1,s do
      local room = zgetr(i,j)
      if room == zgetar() then
        rect(50 + (i*5), (j*5), 50 + (i*5) + 4, (j*5)+4, 5)
      elseif room.spawn or dev then
        col = 2
        if room.g == 'e' then
          col = 11
        elseif room.g == 'b' then
          col = 10
        elseif room.g == 'l' then
          col = 9
        elseif room.g == 'k' and dev then
          col = 12
        end
        rect(50 + (i*5), (j*5), 50 + (i*5) + 4, (j*5)+4, col)
      end
    end
  end
end


function gget(x,y)
  return grid[x][y]
end

function gset(x,y, val)
  grid[x][y] = val
end

function ggetp(point)
  return gget(point[1], point[2])
end

function gsetp(point, val)
  gset(point[1], point[2], val)
end

function zgetar()
  local i, j = flr(player.x / 9) + 1, flr(player.y / 9) + 1
  -- debug[1] = i .. "," .. j
  return zgetr(i,j)
end

function zgetr(i,j)
  return rooms[zindex(i,j)]
end

function zinr(x,y)

end

function zindex(i,j)
  return (i-1)*s+(j-1)+1
end

function rnd_pos(room)
  local l,r,t,b = room.left+1,room.right-2,room.top+1,room.bottom-2
  local x, y
  local i = 0
  repeat
    x, y = rand(l,r), rand(t,b)
    i += 1
    -- log(i)
  until (walkable(x,y, "entities") and walkable(x,y, "items") and (distance(player.x, player.y, x, y) > 2)) or i > 20
  -- log("room")
  -- log("player " .. player.x .. ',' .. player.y)
  -- log("spawn " .. x .. ',' .. y)
  -- log('dist ' .. distance(player.x, player.x, x, y))
  if(i>20) x,y=-1,-1
  -- log(x .. ',' .. y)
  return {x,y}
end

function iter_room(room, func)
  for i=room.left,room.right do
    for j=room.top,room.bottom do
      func(i,j)
    end
  end
end

function zel_lock(room)
  zel_unlock()
  zel_last_locked = room
  iter_room(room, function(i,j)
    local t = mget(i,j)
    if (t == t_door_r) t += 1
    if (t == t_door_l) t += 1
    if (t == t_door_t) t += 1
    if (t == t_door_b) t += 1

    mset(i,j,t)
  end)
end

function zel_unlock()
  local room = zel_last_locked
  if (not room) return

  iter_room(room, function(i,j)
    local t = mget(i,j)
    if (t == t_door_r+1) t -= 1
    if (t == t_door_l+1) t -= 1
    if (t == t_door_t+1) t -= 1
    if (t == t_door_b+1) t -= 1

    mset(i,j,t)
  end)

  if room.g == 'b' then
    local down = rnd_pos(room)
    mset(down[1], down[2], t_stairs)
  end
end

function zel_clear()
  local room = zel_last_locked or zgetar()
  local enemies = false

  iter_room(room, function(i,j)
    if (enemy_at(i,j)) enemies = true
  end)
  -- debug[1] = enemies
  return not enemies
end

function banner(text)
	message = { text=text, ticks=30 }
end

function hcenter(s)
	return (64)-flr((#s*4)/2)
end

function vcenter(s)
	return (64)-flr(5/2)
end

function zel_spawn(room)
  -- log("zel_spawn")
  room.spawn = true
  local rname = roomname(room)
  if (rname) banner(rname)

  local mobcount = #enemies

  if room.g == 'e' then
    -- do nothing
    -- item_create(rnd_pos(room), 'bag')
    -- item_create(rnd_pos(room), 'wand')
    -- item_create(rnd_pos(room), 'leather armour')
    -- item_create(rnd_pos(room), 'health potion')
    -- item_create(rnd_pos(room), 'poison potion')
    -- item_create(rnd_pos(room), 'poison dagger')
    -- item_create(rnd_pos(room), 'teleport potion')
    -- item_create(rnd_pos(room), 'frost bow')
    -- item_create(rnd_pos(room), 'flaming sword')
    -- item_create(rnd_pos(room), 'bomb')

    -- local pos = rnd_pos(room)
    -- local boss = enemy_create(pos[1],pos[2], "slime")
    -- boss.outline = true
    -- boss.hp += 2
    -- boss.mhp += 2

    -- item_create(rnd_pos(room), 'shield')
    -- item_create(room.left+4, room.top+4, randa(t_items))
    -- item_create(room.left+5, room.top+5, randa(t_key))
    if (rand(0,1) == 0) item_create(rnd_pos(room), randa(t_drops[depth]))

  elseif room.g == 'b' then
    local bss
    if depth == 1 then
      local pos = rnd_pos(room)
      bss = enemy_create(pos[1],pos[2], "slime")

      for i=1,4 do
        pos = rnd_pos(room)
        local baby = enemy_create(pos[1],pos[2], "baby slime")
      end
      for i=1,4 do
        pos = rnd_pos(room)
        add(enviro, {x=pos[1],y=pos[2], turns=12, spr=31})
      end
    elseif depth == 2 then
      for i=1,3 do
        pos = rnd_pos(room)
        bss = enemy_create(pos[1],pos[2], "viper")
      end
    elseif depth == 3 then

        pos = rnd_pos(room)
        bss = enemy_create(pos[1],pos[2], "spider")
        boss.flying = true
        bss.hp += 1

      -- replace rocks with webs
      iter_room(room, function(i,j)
        if (mget(i,j)==57) mset(i,j, 60)
      end)
    elseif depth == 4 then
      pos = rnd_pos(room)
      bss = enemy_create(pos[1],pos[2], "griffon")
    end

    bss.outline = true
    bss.hp += 1
    bss.mhp += 2
    bss.loot = true

  elseif room.g == 't' then
    if rand(0,3) == 0 then
      for i = 0,3 do
        item_create(rnd_pos(room), 'gold')
      end
    else
      item_create(rnd_pos(room), randa(t_treasure[depth]))
    end
  elseif room.g == 's' then
    item_create(rnd_pos(room), randa(t_secrets[depth]))
  elseif room.g == 'k' then
    item_create(rnd_pos(room), 'key')
    -- chance of mini boss??
  elseif room.g == 'l' then
    -- item_create(room.left+2, room.top+2, randa(t_key))
    -- chance of mini boss??
  else
    for i = 1,(room.g+0) do
      local pos = rnd_pos(room)
      -- TODO: this should be better
      enemy_create(pos[1], pos[2], randa(t_enemies[depth]))
    end
  end

  if (#enemies > mobcount) zel_lock(room)

  -- random add heal or food
  if (rand(0,3) == 0) item_create(rnd_pos(room), randa(t_drops[depth]))
  if (rand(0,2) == 0) item_create(rnd_pos(room), 'gold')
  if (rand(0,2) == 0) item_create(rnd_pos(room), 'gold')
end

grid = {}
rooms = {}
-- zel_active = -1
function zel_generate()
  grid = {}
  rooms = {}
  edges = {}
  s = 4
  rs = flr(size/s)

  log_grid = function(name)
    log("\n--"..name.."--")
    for j = 1,s do
      str = ""
      for i = 1,s do
        str = str .. grid[i][j]
      end
      log(str)
    end
  end

  valid_grid = function()
    local zero = 0
    local required = { "k", "l", "b", "e" }
    for i = 1,s do
      for j = 1,s do
        del(required, grid[i][j])
        if (grid[i][j] == 0) zero += 1
      end
    end
    -- log("required")
    -- log(required)

    return #required == 0 and zero <= 3
  end

  empty = function(n)
    return ggetp(n) == 0
  end

  randp = function()
    return {rand(1,s+1), rand(1,s+1)}
  end

  for i = 1,s do
    grid[i] = {}
    for j = 1,s do
      gset(i,j, 0)
    end
  end

  --start room
  start = randp()
  --grid[start[1]][start[2]] = 1
  gsetp(start, 1)

  -- log_grid("start")

  -- end room (boss)
  repeat
    boss = randp()
    -- log("h" .. to_s(h))
  until empty(boss) and distancep(boss, start) > 3
  --grid[boss[1]][boss[2]] = 'b'
  gsetp(boss, 'b')

  for i = 1,rnd(3) do
    local h = {0,0}
    repeat
      h = randp()
      -- log("h" .. to_s(h))
    until empty(h) and distancep(boss, h) > 1
    --grid[h[1]][h[2]] = 'h'
    gsetp(h, 'h')
  end

  -- log_grid("boss")

  local bounds_func = function(n)
    return n[1] > 0 and n[1] <= s and n[2] > 0 and n[2] <= s
     --return n[1] % (s+1) != 0 and n[2] % (s+1) != 0
  end

  -- path
  local cost_func = function(a,b)
    return rnd(5)
  end
  local path = astar(start, boss, cost_func, bounds_func)

  local i = 1
  --for point in all(path) do
    --grid[point[1]][point[2]] = i
    --i += 1
  --end
  for i = 1,#path do
    local point = path[i]
    --grid[point[1]][point[2]] = i
    gsetp(point, i)

    if (i != #path) add(edges, {point, path[i+1]})
  end

  --log_grid("path")
  --log(edges)

  -- add lock to main path

  lock = path[#path-1]
  lock_score = ggetp(lock) -- grid[lock[1]][lock[2]]
  --grid[lock[1]][lock[2]] = 'l'
  gsetp(lock, 'l')

  --log_grid("lock")

  -- add side path

  expand = {}
  keys = {}
  for i = 1, lock_score-1 do
    add(expand, path[i])
  end

  k = 0
  while #expand > 0 and k < 20 do

    expand = shuffle(expand)
    local p = pop(expand)

    local neighbours = shuffle(adjacent(p, bounds_func))
    emp=true
    for n in all(neighbours) do
      if empty(n) then
        emp=false
        --grid[n[1]][n[2]] = grid[p[1]][p[2]] + 1
        gsetp(n, ggetp(p) + 1)
        add(edges, {p, n})
        add(expand, n)
      end
    end

    if emp and not contains(path, p) then
      add(keys, p)
    end


    k += 1

    --pop(expand)

  end

  -- log_grid("")
  --
  --log("keys")
  for t in all(keys) do
    --log(t[1] .. "," .. t[2])
    --grid[t[1]][t[2]] = 't'
    gsetp(t, 't')
  end

  key = randa(keys)
  del(keys, key)
  --grid[key[1]][key[2]] = 'k'
  gsetp(key, 'k')

  hidden = randa(keys)
  del(keys, hidden)
  --grid[hidden[1]][hidden[2]] = 's'
  if (hidden) gsetp(hidden, 's')

  --grid[boss[1]][boss[2]] = 'b'
  gsetp(boss, 'b')
  --grid[start[1]][start[2]] = 'e'
  gsetp(start, 'e')

  if not valid_grid() then
    log("regen!!")
    zel_generate()
    return
  end

  function draw_room(x,y, g)
    --log('room')
    local once = false
    for i = 1,rs do
      for j = 1,rs do
        --if i == 0 or i == rs or j == 0 or j == rs then
          --mset(x+i, y+j, 16)
        --end
        tile = randa(t_floor)
        if i == 1 then
          tile = t_wall_l
        elseif i == rs then
          tile = t_wall_r
        elseif j == 1 then
          tile = t_wall_t
        elseif j == rs then
          tile = t_wall_b
        elseif i > 2 and i < rs-2 and j > 2 and j < rs-2 then
          local random = rand(0,5)
          if random > 0 and random < 3 then

            if (random == 2 and not once) then
              once = true
              entity_create(x+i, y+j, 42, {def = 5, ai=noop, outline=false, loot=true})
            else
              tile = 57
            end
          end
        elseif g != 'e' then
          if rand(1,8) == 1 then
            entity_create(x+i, y+j, 43, {hp = 1, ai=noop})
          end
        end
        mset(x+i, y+j, tile)
      end
    end

    -- random vases

    -- random rocks

  end

  log_grid("end")

  function add_door(a,b)
    local dx,dy = normalise(b[1]-a[1], b[2]-a[2])

    local mrs = flr(rs/2)

    door = 1
    opp = 1
    if dx == 1 then
      door = t_door_r
      opp = t_door_l
    elseif dx == -1 then
      door = t_door_l
      opp = t_door_r
    elseif dy == 1 then
      door = t_door_b
      opp = t_door_t
    else -- dy == -1
      door = t_door_t
      opp = t_door_b
    end

    if ggetp(a) == 'l' then
      door += 7
    elseif ggetp(b) == 's' then
      door -= 1
    end

    for i = mrs, mrs+1 do
      --i = flr(rs/2)
      x = a[1] * rs - rs/2 + (i*dx)
      y = a[2] * rs - rs/2 + (i*dy)

      --if i == flr(rs/2) then

      mset(x,y, door)
      door=opp

      --else
        --mset(y,x, 17)
      --end
    end
  end

  for i = 1,s do
    for j = 1,s do
      local x = (i-1)*rs -1
      local y = (j-1)*rs - 1
      local g = gget(i,j)
      room = {
        left=x+1,
        top=y+1,
        bottom=y+rs,
        right=x+rs,
        g=g,
        spawn=false,
        clear=false,
        index=zindex(i,j)
      }
      add(rooms, room)
      if g != 'h' and g != 0 then
        draw_room(x, y, g)
      end
    end
  end
  for e in all(edges) do
    add_door(e[1],e[2])
  end

end

function clear_map()
  for i = 0,32 do
    for j = 0,32 do
      mset(i,j, 0)
    end
  end
end
-->8
--astar

--function push(stack,item)
	--stack[#stack+1]=item
--end

function pop(stack)
	local r = stack[#stack]
	stack[#stack]=nil
	return r
end

function insert(t, val, p)
	if #t >= 1 then
		add(t, {})
		for i=(#t),2,-1 do
			local next = t[i-1]
		 	if p < next[2] then
		  	t[i] = {val, p}
		  	return
		 	else
		  	t[i] = next
		 	end
		end
		t[1] = {val, p}
	else
		add(t, {val, p})
	end
end


function distance(ax, ay, bx, by)
  return abs(ax - bx) + abs(ay - by)
end

function distancep(a, b)
  return distance(a[1], a[2], b[1], b[2])
end


function adjacent(point, bounds)
	local x, y = point[1], point[2]

	local adj = {}
	local v = {{x-1,y},{x,y-1},{x+1,y},{x,y+1}}
	for i in all(v) do
		if bounds(i) then
			add(adj,{i[1],i[2],mget(i[1],i[2])})
		end
	end
	return adj
end

function astar(start, goal, cost, bounds)
	-- printh("astar " .. start[1] .. "," .. start[2] .. " -> " .. goal[1] .. "," .. goal[2] ,"debug.txt")
 if vec(start)==vec(goal) then
  return {start}
 end

 local frontier = {}
	insert(frontier, start, 0)
	local came_from = {}
	came_from[vec(start)] = nil
	local cost_so_far = {}
	cost_so_far[vec(start)] = 0

	while (#frontier > 0 and #frontier < 1000) do
		local popped = pop(frontier)
		local current = popped[1]

	 	if vec(current) == vec(goal) then
	 		break
	 	end

	 	local neighbours = adjacent(current, bounds)
	 	for next in all(neighbours) do

	  	local nextindex = vec(next)

		  local new_cost = cost_so_far[vec(current)] + cost(current, next)

		  if (cost_so_far[nextindex] == nil) or (new_cost < cost_so_far[nextindex]) then
				cost_so_far[nextindex] = new_cost
				local priority = new_cost + heuristic(current, next) -- heuristic(goal, next)
				insert(frontier, next, priority)

				came_from[nextindex] = current
		  end

	  end
	end
 -- printh("building path" ,"debug.txt")
	current = came_from[vec(goal)]
	path = {}
	local cindex = vec(current)
	local sindex = vec(start)

	add(path, goal)

	while cindex != sindex do
	 add(path, current)
	 current = came_from[cindex]
	 cindex = vec(current)
	end
	add(path, start)
	reverse(path)
 -- printh("path " .. #path ,"debug.txt")

	return path
end

function reverse(t)
	for i=1,(#t/2) do
		local temp = t[i]
		local oppindex = #t-(i-1)
		t[i] = t[oppindex]
		t[oppindex] = temp
	end
end

--function prefer_walkable(a, b)
	--if walkable(b[1],b[2]) then
		--return 1
	--elseif mget(b[1],b[2]) == 81 then
		--return 2
	--end
	--return rand(2,4)
--end

function heuristic(a, b)
	return distancep(a, b)
end

function vec(point)
	return flr(point[2])*256+flr(point[1])%256
end

function vec2xy(v)
	local y = flr(v/256)
	local x = v-flr(y*256)
	return {x,y}
end

--function floodfill(x,y,comp,action)
	--local queue = {vec(x,y)}
	--local seen = {}
	--while #queue > 0 do
		--local v = pop(queue)
		--local x,y = vec2xy(v)
		--if not (x <= 0 or x >= size or y <= 0 or y >= size) then
			--add(seen,v)
			--if action(x,y) == true then break end
			--for adj in all(adjacent(x,y)) do
				--local ax,ay = adj[1],adj[2]
				--local av = vec(ax,ay)
				--if not contains(seen,av) and comp(ax,ay) then
					--add(queue,av)
				--end
			--end
		--end
	--end
--end
-->8
--graphics
function drawspr(_spr,_x,_y,_c,_flip, _flash, _outline)
  rpal()
  -- pal(0,15)
  -- for i=1,15 do
  --   pal(i, 13)
  -- end
  --
  -- if _outline then
  --   for dx=-1,1 do
  --     for dy=-1,1 do
  --       spr(_spr,_x + dx ,_y + dy,1,1,_flip)
  --     end
  --   end
  -- end

  -- reset palette
  rpal()
  palt()

  palt(0,false)
  -- pal(9,_c)
  -- pal(5,_c)
  if _flash then
    for i=1,15 do
      pal(i, _c)
    end
  end
  spr(_spr,_x,_y,1,1,_flip)
  rpal()
  palt()
end

function addfloat(_txt,ent,_c)
  local _x,_y = ent.x*8,ent.y*8
  add(float,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0})
end

function dofloats()
  for f in all(float) do
    f.y+=(f.ty-f.y)/10
    f.t+=1
    if f.t>70 then
      del(float,f)
    end
  end
end

function draw_float(f)
  oprint8(f.txt,f.x,f.y,f.c,0)
end

function dofade()
 local p,kmax,col,k=flr(mid(0,fadeperc,1)*100)
 for j=1,15 do
  col = j
  kmax=flr((p+j*1.46)/22)
  for k=1,kmax do
   col=dpal[col]
  end
  pal(j,col,1)
 end
end

function checkfade()
 if fadeperc>0 then
  fadeperc=max(fadeperc-0.04,0)
  dofade()
 end
end

function wait(_wait)
 repeat
  _wait-=1
  flip()
 until _wait<0
end

function fadeout(spd,_wait)
 if (spd==nil) spd=0.04
 if (_wait==nil) _wait=0
 repeat
  fadeperc=min(fadeperc+spd,1)
  dofade()
  flip()
 until fadeperc==1
 wait(_wait)
end

function create_part(x,y,dx,dy,sprite,life,sz,col)
 local p = {
  x=x,
  y=y,
  dx=dx,
  dy=dy,
  sprite=sprite,
  life=life,
  sz=sz,
  col=col
 }
 -- log("added particle")
 add(particles,p)
 return p
end

function update_part(p)
 if(p.life<=0)del(particles,p)

 if p.sz !=nil then
  p.sz-=0.2
 end

 p.x+=p.dx
 p.y+=p.dy

 p.life-=1
end

function draw_part(p)
  if p.sprite != 0 then
    _item_draw(p.sprite, p.x, p.y, p.col)
  -- spr(p.sprite,p.x,p.y)
  else
    circfill(p.x,p.y,p.sz,p.col)
  end
end

function oprint8(_t,_x,_y,_c)
  for dx=-1,1 do
    for dy=-1,1 do
      print(_t,_x+dx,_y+dy,0)
    end
  end
  print(_t,_x,_y,_c)
end

function do_shake()
 shakex=8-rnd(16)
 shakey=8-rnd(16)

 shakex*=shake
 shakey*=shake

 --local rs = size/s
 --local x, y = flr(player.x / rs) * rs, flr(player.y / rs) * rs


 -- local x, y = flr(player.x / 8) * 8, flr(player.y / 8) * 8

 -- local i, j = flr(player.x / 9) + 1, flr(player.y / 9) + 1
 -- debug[1] = i .. "," .. j
 room = zgetar()
 -- debug[2] = to_s(room)

 if room then
   x, y = room.left , room.top
  end

 x, y = x*8 - 32, y*8 - 32

 --x,y = x%8
 camera(x + shakex, y + shakey)

 shake*=0.8
 if(shake<=0.05) shake=0
end

function minimap_draw()
  camera()
  for x=0, size-1 do
    for y=0, size-1 do
			  if mget(x,y) then
	      pset(x, y, mget(x,y) % 15 + 1)
			  end
    end
  end

	foreach(entities, function(entity)
		pset(entity.x,entity.y,8)
	end)

  pset(player.x,player.y,8)
end
-->8
-- Util Functions
--
function to_s(any)
	if type(any)=="function" then return "function" end
	if any==nil then return "nil" end
	if type(any)=="string" then return any end
	if type(any)=="boolean" then return any and "true" or "false" end
	if type(any)=="number" then return ""..any end
	if type(any)=="table" then -- recursion
		local str = "{ "
		for k,v in pairs(any) do
			str=str..to_s(k).."->"..to_s(v).." "
		end
		return str.."}"
	end
	return "unkown" -- should never show
end

function rand(min, max)
 return flr(rnd(max-min)+min)
end

function randf(min, max)
 return rnd(max)+min
end

function randa(array)
 return array[rand(1, #array+1)]
end

function shuffle(a)
	local n = count(a)
	for i=1,n do
		local k = -flr(-rnd(n))
		a[i],a[k] = a[k],a[i]
	end
	return a
end

function contains(array, element)
  for e in all(array) do
    if e == element then
      return true
     end
  end
  return false
end

function normalise(dx, dy)
 if dx > 0 then
  return 1, 0
 elseif dx < 0 then
  return -1, 0
 elseif dy > 0 then
  return 0, 1
 elseif dy < 0 then
  return 0, -1
 end
end

-- Debug

function log(thing)
  printh(to_s(thing))
end
__gfx__
000000000000000000000000000000000000000000000000ffffff0fffffff0ff777777f000000000000000000000000ffffff0f00000000f777777f00000000
000000000000000000000000000000000000000000000000ffffff0ffff00f0ff070707f011111100110111000000000ffffff0f00000000f070707f00000c00
0000000000000000000aa00000aaa0000000000000000a00ffffff0fff00000ff070707f011111100100011000000000ffffff0f00000000f070707f000c0c00
0000000000000000000aa00000a0a000000000000000a0000000000000000000007070700111111000000010000000000000000000000000007aaa700c0c0c00
0000000000000000000aa00000aa0000000f0000000a0000fff0fffff000000ff070707f011111100000000000000000fff0ffff00000000f07a0a7f0cccccc0
000000000000000000affa00000aa00000a0a00000a00000fff0f0fff000000ff070707f001111100110000000000000fff0ffff00000000f07aaa7f0cccccc0
000000000000000000affa00000a0000000a000000000000ffff0ffff000000ff070707f000111100111000000000000fff0ffff00000000f070707f00cccc00
0000000000000000000aa000000aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff0fff0000000000fff0fff00000000000000b0
0000bb0000000000000000000000000000000000000f0000fff0f00ff000000ff070707f0000000000110000fff0fff0000000000fff0ffff070707f00b00bb0
000b55000000000000000c0000000000000f000000a0f000ffff0f0ff000000ff070707f00000000011110000000fff000aaaa0000000ffffaaa707f00000b00
00b05500000000000000c00000000000000f000000a00f00fff0f00ff000000f007070700000000001111000fff0fff00a0a00a00fff0fff0a0a707000000000
0005550000000000000ff000000f0000000f000000a00f000000000000000000f070707f0000000000110000fff0fff00a0aaaa00fff0ffffaaa707f00bb0bb0
005055500009900000ffff00000f0000000f000000a00f00fff0ffffff0000fff070707f0000000000000110fff0000000aaaaa00fff0000f070707f0bbbbbb0
000505000090990000ffff0000aaa00000aaa00000a0f000fff0ffffff000ffff070707f0000000000000110fff0fff0000aaaa00fff0ffff070707f00bbbb00
0050050000999900000ff000000a0000000a0000000f0000fff0ffffff0ffffff777777f0000000000000000fff0fff0000000000fff0ffff777777f00000000
000000000000000000000000000000000000000000000000fff0fff0fff0fff0fff0fff00000000000000000000000000000000000000000fff0fff000000000
00990900000000000000000000000000000a000000000000fff0fff0fff0000070000000040400000077770000055000ffffff0f000000007000000000000000
0990009000000000900000900000000000a0a000000000000000fff00000000077777770040400000777777000500500ffffff0f00000000777aaa7000000000
909090900009999099000990000aa0000a000a000aa0aa00fff0fff0ff00000070000000000000000777777000055000ffffff0f00000000700a0a0000000000
00909990090999900999990000aaaa0000a0a0000aaaaa00fff00f00ff000000777777700000000007707070005555000000000000000000777aaa7000000000
009999909099999900999000000aa000000aff000aaaaa00fff0f0f0fff0000070000000000040400077070005555550fff0ffff000000007000000000000000
099990009099090900090000000000000000ff0000aaa000fff00f00fff0000077777770000040400070700005555550fff0ffff000000007777777000000000
0999999090000909000000000000000000000000000a0000fff0fff0fff0fff0fff0fff0000000000000000000555500fff0ffff00000000fff0fff000000000
0000000000000000000000000000000000000000000000000fff0fff0fff0fff0fff0fff00007000033333330000000000d07000000000000fff0fff00000000
0099800000000000000000000000000000000000000000a00fff0fff00000fff0000000700777700031611110000000000dd7700000000000000000700000000
0099990009998908000000000055550000aaaa00000000aa00000fff000000ff077777770777777003161f1100555500077dd7dd00000000077aaa7700000000
0009990009099980009990000505505000aaaa00000aaaa00fff0fff000000ff000000070777777703161f1e05055050dd77ddd700000000000a0a0700000000
0099800009000008099909000500005000aaaa0000aaaaa00ff0f0ff000000ff077777770077777703161f1e050000500d77ddd700000000077aaa7700000000
0998009009999900999909000555555000aaaa000a0aaa000fff0f0000000000000000070077077003161f1e055555500d77d7dd000000000000000700000000
00990089000099009999909005000050000aa0000aaaa0000ff0f0ff00000fff077777770000000003161f1e050000500dddd00d000000000777777700000000
0009999909999900999999900555555000000000000a00000fff0fff0fff0fff0fff0fff00000000033333330555555000d00000000000000fff0fff00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60008006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00494000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0804a480060806000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60080006060006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66000066000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00880880008808800088088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888880008888800088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888880008888800088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088800000888000008880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008000000080000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000cccccbbbbb000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000c000cb000b000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000c000cb000b000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000c000cb000b000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000cccccbbbbb000000000000000000000000000000000000000000000000000000000000000
00ccc0ccc0c0c00000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c0c00c00c0c000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ccc00c00cc0000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c0c00c00c0c000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c0c00c00c0c00000ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000555055505555550555555505555555055222222555555505555555055555550505550555000000000000000000000000
00000000000000000000000000000000555055505555550555555505555555055020202555555505555555055555550505550555000000000000000000000000
00000000000000000000000000000000000055505555550555555505555555055020202555555505555555055555550500000555000000000000000000000000
00000000000000000000000000000000555055500000000000000000000000000020202000000000000000000000000005550555000000000000000000000000
00000000000000000000000000000000555055505550555555505555555055555020202555505555555055555550555505550555000000000000000000000000
00000000000000000000000000000000555000005550555555505555555055555020202555505555555055555550555505550000000000000000000000000000
00000000000000000000000000000000555055505550555555505555555055555020202555505555555055555550555505550555000000000000000000000000
00000000000000000000000000000000555055500000000000000000000000000000000000000000000000000000000005550555000000000000000000000000
00000000000000000000000000000000555055500000000000000000000000000000000000000000000000000000000005550555000000000000000000000000
00000000000000000000000000000000555055500ffffff00ff0fff0000cc00000ff000000ff0000000cc0000f0f000005550555000000000000000000000000
00000000000000000000000000000000000055500ffffff00f000ff000c00c000ffff0000ffff00000c00c000f0f000000000555000000000000000000000000
00000000000000000000000000000000555055500ffffff0000000f0000cc0000ffaa0000ffff000000cc0000000000005550555000000000000000000000000
00000000000000000000000000000000555055500ffffff00000000000cccc0000aaaa0000ff000000cccc000000000005550555000000000000000000000000
000000000000000000000000000000005550000000fffff00ff000000cccccc0000aaff000000ff00cccccc00000f0f005550000000000000000000000000000
0000000000000000000000000000000055505550000ffff00fff00000cccccc000000ff000000ff00cccccc00000f0f005550555000000000000000000000000
0000000000000000000000000000000055505550000000000000000000cccc00000000000000000000cccc000000000005550555000000000000000000000000
00000000000000000000000000000000555055500000000000000000000000000000000000000000000000000000000005550555000000000000000000000000
0000000000000000000000000000000055505550000000000f0f000000ff0000000000000f0f0000000cc0000ff0fff005550555000000000000000000000000
0000000000000000000000000000000000005550000000000f0f00000ffff000000000000f0f000000c00c000f000ff000000555000000000000000000000000
000000000000000000000000000000005550555000000000000000000ffff0000000000000000000000cc000000000f005550555000000000000000000000000
0000000000000000000000000000000055505550000000000000000000ff0000000000000000000000cccc000000000005550555000000000000000000000000
0000000000000000000000000000000055500000000000000000f0f000000ff0000000000000f0f00cccccc00ff0000005550000000000000000000000000000
0000000000000000000000000000000055505550000000000000f0f000000ff0000000000000f0f00cccccc00fff000005550555000000000000000000000000
0000000000000000000000000000000055505550000000000000000000000000000000000000000000cccc000000000005550555000000000000000000000000
00000000000000000000000000000000555055500000000000000000000020000000000000000000000000000000000005550555000000000000000000000000
00000000000000000000000000000000555055500000000000222200002222000ffffff00ff0fff00ffffff00000000005550555000000000000000000000000
00000000000000000000000000000000000055500000000002222220022222200ffffff00f000ff00ffffff00000000000000555000000000000000000000000
00000000000000000000000000000000555055500000000002222220022222220ffffff0000000f00ffffff00000000005550555000000000000000000000000
00000000000000000000000000000000555055500000000002202020002222220ffffff0000000000ffffff00000000005550555000000000000000000000000
000000000000000000000000000000005550000000088000002202000022022000fffff00ff0000000fffff00000000005550000000000000000000000000000
0000000000000000000000000000000055505550008088000020200000000000000ffff00fff0000000ffff00000000005550555000000000000000000000000
00000000000000000000000000000000555055500088880000000000000000000000000000000000000000000000000005550555000000000000000000000000
00000000000000000000000000000000555055500000000000002000000000000000200000000000000000000000000005550555000000000000000000000000
00000000000000000000000000000000555055500ffffff0002222000ff0fff0002222000ffffff00000000000bb000000000002000000000000000000000000
00000000000000000000000000000000000055500ffffff0022222200f000ff0022222200ffffff00000000000ccb00002222222000000000000000000000000
00000000000000000000000000000000555055500ffffff002222222000000f0022222220ffffff00000000000cc0b0000000002000000000000000000000000
00000000000000000000000000000000555055500ffffff00022222200000000002222220ffffff00000000000ccc00002222222000000000000000000000000
000000000000000000000000000000005550000000fffff0002202200ff000000022022000fffff0000000000ccc0c0000000002000000000000000000000000
0000000000000000000000000000000055505550000ffff0000000000fff000000000000000ffff00000000000c0c00002222222000000000000000000000000
000000000000000000000000000000005550555000000000000000000000000000000000000000000000000000c00c0005550555000000000000000000000000
00000000000000000000000000000000555055500000000000000000000020000000200000002000000000000000000005550555000000000000000000000000
00000000000000000000000000000000555055500000000000000000002222000022220000222200000cc00000ff000005550555000000000000000000000000
0000000000000000000000000000000000005550000000000000000002222220022222200222222000c00c000ffff00000000555000000000000000000000000
00000000000000000000000000000000555055500088800000000000022222220222222202222222000cc0000ffff00005550555000000000000000000000000
0000000000000000000000000000000055505550088808000000000000222222002222220022222200cccc0000ff000005550555000000000000000000000000
000000000000000000000000000000005550000088880800000000000022022000220220002202200cccccc000000ff005550000000000000000000000000000
000000000000000000000000000000005550555088888080000000000000000000000000000000000cccccc000000ff005550555000000000000000000000000
0000000000000000000000000000000055505550888888800000000000000000000000000000000000cccc000000000005550555000000000000000000000000
00000000000000000000000000000000555055500000000000000000000000000000000000000000000000000000000005550555000000000000000000000000
0000000000000000000000000000000055505550000cc00000ff00000ffffff000ff0000000cc0000ff0fff00f0f000005550555000000000000000000000000
000000000000000000000000000000000000555000c00c000ffff0000ffffff00ffff00000c00c000f000ff00f0f000000000555000000000000000000000000
0000000000000000000000000000000055505550000cc0000ffff0000ffffff00ffff000000cc000000000f00000000005550555000000000000000000000000
000000000000000000000000000000005550555000cccc0000ff00000ffffff000ff000000cccc00000000000000000005550555000000000000000000000000
00000000000000000000000000000000555000000cccccc000000ff000fffff000000ff00cccccc00ff000000000f0f005550000000000000000000000000000
00000000000000000000000000000000555055500cccccc000000ff0000ffff000000ff00cccccc00fff00000000f0f005550555000000000000000000000000
000000000000000000000000000000005550555000cccc0000000000000000000000000000cccc00000000000000000005550555000000000000000000000000
00000000000000000000000000000000555055500000000000000000000000000000000000000000000000000000000005550555000000000000000000000000
000000000000000000000000000000005550555000ff00000f0f00000ff0fff00f0f00000f0f000000000000000cc00005550555000000000000000000000000
00000000000000000000000000000000000055500ffff0000f0f00000f000ff00f0f00000f0f00000000000000c00c0000000555000000000000000000000000
00000000000000000000000000000000555055500ffff00000000000000000f0000000000000000000000000000cc00005550555000000000000000000000000
000000000000000000000000000000005550555000ff0000000000000000000000000000000000000000000000cccc0005550555000000000000000000000000
000000000000000000000000000000005550000000000ff00000f0f00ff000000000f0f00000f0f0000000000cccccc005550000000000000000000000000000
000000000000000000000000000000005550555000000ff00000f0f00fff00000000f0f00000f0f0000000000cccccc005550555000000000000000000000000
000000000000000000000000000000005550555000000000000000000000000000000000000000000000000000cccc0005550555000000000000000000000000
00000000000000000000000000000000555055500000000000000000000000000000000000000000000000000000000005550555000000000000000000000000
00000000000000000000000000000000555055505555550555555505555555055020202555555505555555055555550505550555000000000000000000000000
00000000000000000000000000000000000055505555550555555505555555055020202555555505555555055555550500000555000000000000000000000000
00000000000000000000000000000000555055505555550555555505555555050020202055555505555555055555550505550555000000000000000000000000
00000000000000000000000000000000555055500000000000000000000000005020202500000000000000000000000005550555000000000000000000000000
00000000000000000000000000000000555000005550555555505555555055555020202555505555555055555550555505550000000000000000000000000000
00000000000000000000000000000000555055505550555555505555555055555020202555505555555055555550555505550555000000000000000000000000
00000000000000000000000000000000555055505550555555505555555055555222222555505555555055555550555505550555000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000010000000100050000000000000000000100000100010500000000000000000001000300010005000000000000000000010300000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
