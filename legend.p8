pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
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

t_enemies = {
  {t_bat,t_snake,t_slime},
  {t_bat,t_snake,t_spider},
  {t_viper,t_snake,t_spider},
  {t_viper,t_spider,t_griffon}
}

t_key = {"key"}
t_gold = {"gold"}
t_weapons = {"dagger","poison dagger", "bow", "wand", "sword", "bomb"}
t_items = {"gold","ring","amulet","leather armour","chainmail", "bomb"}
t_heals = {"health potion"}

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
  {'health potion',2,true,{throw=heal, quaff=heal, qhp=2, col=8}}, -- todo
  {'teleport potion',2,true,{quaff=teleport, throw=teleport, col=12}}, -- todo
  {'dagger',19,true,{atk=2,col=6}},
  {'poison dagger',19,true,{atk=1, col=11, poison=1, throw=true, col=11}}, --rodo
  {'sword',20,false,{atk=3,col=6}},
  {'flaming sword',10,false,{col=8, atk=3, flame=1,col=9}}, --todo
  {'wand',5,false,{ratk=1,col=4}}, -- todo
  {'bow',21,false,{ratk=2,col=4}}, -- todo
  {'frost bow',21,false,{ratk=2, freeze=2, col=12}}, -- todo
  {'bomb',18,true,{throw=expode, explosion=1,col=5}}, -- todo
  {'mega bomb',18,true,{throw=expode, explosion=2,col=8}}, -- todo
  {'amulet', 36, true, {hp=4}},
  {'ring', 4, true, {hp=5}},
  {'leather armour', 52, false, {def=1}},
  {'chainmail', 52, false, {def=2}},
  {'plate armour', 52, false, {def=3}}
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

-- armoury = {
--   k1 = {
--     name = 'key',
--     spr = 3,
--     type = 'k'
--   },
--   g1 = {
--     name = 'gold',
--     spr = 35,
--     amount = 1,
--     type = 'g'
--   },
--   w1 = {
--     name = "dagger",
--     type = "w",
--     atk = 2,
--     spr = 19
--   },
--   w2 = {
--     name = "sword",
--     type = "w",
--     atk = 3,
--     spr = 20
--   },
--   w3 = {
--     name = "great sword",
--     type = "w",
--     atk = 4,
--     spr = 20
--   },
--   w4 = {
--     name = "wand",
--     type = "r",
--     ratk = 1,
--     spr = 5
--   },
--   w5 = {
--     name = "bow",
--     type = "r",
--     ratk = 2,
--     spr = 21
--   },
--   i1 = {
--     name = "ring",
--     type = "i",
--     spr = 4
--   },
--   i2 = {
--     name = "amulet",
--     type = "i",
--     spr = 36
--   },
--   i3 = {
--     name = "armour",
--     type = "a",
--     armour = 1,
--     spr = 52
--   },
--   i4 = {
--     name = "bomb",
--     type = "i",
--     spr = 18
--   },
--   i5 = {
--     name = "health potion",
--     type = "i",
--     dhp = 2,
--     spr=2
--   }
-- }

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
function item_create(pos, name)
  if (x==-1 and y==-1) return
  log("create " .. name)
  local data = armoury[name]
  if not data then
    log("no data for " .. name)
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
  local ppos = rnd_pos(zgetar())
  player.x,player.y = ppos[1],ppos[2]


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
  map(0, 0, 0,0, size, size)


  -- foreach(enviro,draw_enviro)
  foreach(items,item_draw)
  foreach(entities,entity_draw)
  clip()
  foreach(particles, draw_part)
  foreach(float, draw_float)
  if (dev) minimap_draw()

  camera()

  draw_inventory()
  draw_health()
  draw_stats()
  zel_draw()
  draw_instructions()
end

function draw_instructions()
  cursor(3,116)
  color(13)
  if aiming then
    color(8)
    print("arrows to fire, x to change")
  elseif player.ratk > 0 then
    print("z to aim, x for inventory")
  elseif #inventory > 0 then
    print("x for inventory")
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
  for i=1,player.hp do
   hearts = hearts .. "\x87"
  end
  print(hearts, 1, 1, 8)
  local armour = ""
  for i=1,player.def do
   armour = armour .. "\x87"
  end
  print(armour, 1, 10, 6)
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
  local isgold = item.name == 'gold'
  local match = find(inventory, "name", item.name)
  if match and not item.stack then
    return
  elseif #inventory == 5 and not isgold then
    addfloat("fumble", {x=player.x-1,y=player.y-1}, 9)
    inventory = shuffle(inventory)
    local drop = pop(inventory)
    -- drop_item({item.x,item.y}, drop)
    item_create({item.x,item.y}, drop.name)
    -- return
  end

  del(items, item)

  if isgold then
    gold += 1
    addfloat("+" .. 1 .. ' gold', player, 9)
    return
  elseif item.atk then
    player.atk = item.atk or player.atk
  elseif item.ratk then
    player.ratk = item.ratk or player.ratk
  elseif item.hp then
    player.hp = item.hp or player.hp
  elseif item.def then
    player.def = item.def or player.def
  end
  addfloat(item.name, player, 7)

  add(inventory, item)
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
     zel_generate()
     player.x, player.y = start[1] * 8 - 4, start[2] * 8 -4
   --elseif fget(tile, 5) then
    -- tip = 'watch your step'
    --if (not entity.flying) atk(entity, 2, 'the void')
   else
    --local env = env_at(entity.x,entity.y)
    --if env then
     ---- add(debug, entity.name .. "=" .. env.type)
     --if (entity.name != env.type) atk(entity, 1, env.name)
    --end
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
    if rand(0,10) == 1 or dev then
      drop_item(ent.x, ent.y)
    end
    if(zel_clear()) zel_unlock()
  end
end

function drop_item(x,y)
  local random = rand(1,4)
  local item = "health potion"
  if random == 1 then
    item = randa(t_items)
  elseif random == 2 then
    item = randa(t_weapons)
  elseif random == 3 then
    item = "gold"
  end
  -- log("drop!!!")
  item_create({x,y}, item)
end

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
  elseif walkable(x, y, "entities") then
   if (entity.roots > 0) return
   if (mget(x,y) != 81 or entity.stupid) insert(moves, dir, dist)
  end
 end

 if #moves > 0 then
  local move = pop(moves)[1]
  -- add(debug, "move " .. move[1])
  if (entity.trail) add_enviro(entity.x, entity.y, entity.trail, 2)
  mobwalk(entity, move[1], move[2])
 end
end

function atk(entity, amount, cause)
  amount -= entity.def
 if amount <= 0 then
   return
  -- addfloat('+'.. abs(amount), entity, 11)
 else
  addfloat('-'.. amount, entity, 8)
 end
 entity.hp -= amount
 entity.flash = 10
 shake=.5
 if (entity == player) killer = cause or "something"
end

function entity_draw(self)
 local col = self.col
 if self.flash>0 then
  self.flash-=1
  col=7
 end
 local frame = self.stun != 0 and self.ani[1] or getframe(self.ani)
 local x, y = self.x*8+self.ox, self.y*8+self.oy
 drawspr(frame, x, y, col, self.flp, self.flash > 0, self.outline)

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
  pal()
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
  else
   return moveplayer(dirs[butt+1])
  end
elseif butt==4 and #inventory > 0 then
  aiming = not aiming
  aimingi = aimingi % #inventory
  return false
 elseif butt==5 then
  if aiming then
    aimingi += 1
    aimingi = aimingi % #inventory
  end
   --return false -- maybe discharge if #enemies == 0
  --else
   --return switchitem()
  --end
 end
end

function fireprojectile(entity, dir)
  mobflip(entity, dir[1])
  aiming = false
  -- charges[item] -= 1
  local hx, hy = throwtile(dir[1], dir[2]) -- max distance???

  local item = inventory[aimingi+1]
  log("fire item")
  log(item)

  local hit = entity_at(hx, hy)
  local amount = 1

  if item.ratk then
    amount = item.ratk
  else
   if not hit then
     hx -= dir[1]
     hy -= dir[2]
     item_create({hx,hy}, item.name)
   end

   del(inventory, item)
  end

  if item.throw then

  elseif hit then
    atk(hit, amount)
    for i=1,4 do
      -- different colours??
      create_part(hx*8+4, hy*8+4,(rnd(16)-8)/16,(rnd(16)-8)/16, 0, rnd(30)+10,rnd(sz)+3, 8)
    end
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
    key = find(inventory, "name", "key")
    del(inventory, key)
    mset(destx, desty, mget(destx,desty)-1)
    -- mobwalk(player,dx,dy)
  elseif entity_at(destx,desty) then
    entity = entity_at(destx,desty)
    atk(entity, player.atk, player.name)
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
 -- if(dev) return true

 local mode = mode or ""
 local floor = not fget(mget(x,y), 0)
 -- TODO improve this
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
      -- cursor((i-1)*rs + 3,(j-1)*rs + 2)
      -- local v = gget(i,j)
      -- if v == 'e' then
      --   color(11)
      -- elseif v == 'b' then
      --   color(8)
      -- elseif v == 'h' then
      --   color(5)
      -- elseif v == 'k' then
      --   color(10)
      -- elseif v == 'l' then
      --   color(4)
      -- elseif v == 's' then
      --   color(2)
      -- elseif v == 't' then
      --   color(9)
      -- else
      --   color(12)
      -- end
      -- -- if (dev) print(v)
      -- print(v)

      local room = zgetr(i,j)
      if room == zgetar() then
        rect(room.left+1 + 50, room.top+1, room.right-2 + 50, room.bottom-2, 11)
      elseif room.spawn then
        rect(room.left+1 + 50, room.top+1, room.right-2 + 50, room.bottom-2, 7)
      end
    end
  end
end

-- tokens 2817
--        2715
--        2709

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
  until (walkable(x,y, "entities") and walkable(x,y, "items") and (distance(player.x, player.y, x, y) > 2)) or i > 10
  -- log("room")
  log("player " .. player.x .. ',' .. player.y)
  log("spawn " .. x .. ',' .. y)
  log('dist ' .. distance(player.x, player.x, x, y))
  if(i>10) x,y=-1,-1
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
  local room = zgetar()
  iter_room(room, function(i,j)
    local t = mget(i,j)
    if (t == t_door_r+1) t -= 1
    if (t == t_door_l+1) t -= 1
    if (t == t_door_t+1) t -= 1
    if (t == t_door_b+1) t -= 1

    mset(i,j,t)
  end)
end

function zel_clear()
  local room = zgetar()
  local enemies = false

  iter_room(room, function(i,j)
    if (enemy_at(i,j)) enemies = true
  end)
  -- debug[1] = enemies
  return not enemies
end

function zel_spawn(room)
  -- log("zel_spawn")
  room.spawn = true

  local mobcount = #enemies

  if room.g == 'e' then
    -- do nothing
    item_create(rnd_pos(room), 'dagger')
    item_create(rnd_pos(room), 'wand')
    item_create(rnd_pos(room), 'leather armour')
    item_create(rnd_pos(room), 'health potion')
    -- item_create(room.left+4, room.top+4, randa(t_items))
    -- item_create(room.left+5, room.top+5, randa(t_key))
  elseif room.g == 'b' then
    local boss = rnd_pos(room)
    enemy_create(boss[1],boss[2], 48)
    local down = rnd_pos(room)
    mset(down[1], down[2], t_stairs)
  elseif room.g == 't' then
    if rand(0,1) == 0 then
      item_create(rnd_pos(room), randa(t_weapons))
    else
      item_create(rnd_pos(room), randa(t_items))
    end
  elseif room.g == 's' then
    item_create(rnd_pos(room), randa(t_items))
  elseif room.g == 'k' then
    item_create(rnd_pos(room), randa(t_key))
    -- chance of mini boss??
  elseif room.g == 'l' then
    -- item_create(room.left+2, room.top+2, randa(t_key))
    -- chance of mini boss??
  else
    for i = 1,(room.g+0) do
      local pos = rnd_pos(room)
      enemy_create(pos[1], pos[2], randa(t_enemies[depth]), {hp=depth})
    end
  end

  if (#enemies > mobcount) zel_lock(room)

  -- random add heal or food
  if (rand(0,3) == 0) item_create(rnd_pos(room), randa(t_heals))
  if (rand(0,2) == 0) item_create(rnd_pos(room), randa(t_gold))
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

  -- log_grid = function(name)
  --   log("\n--"..name.."--")
  --   for j = 1,s do
  --     str = ""
  --     for i = 1,s do
  --       str = str .. grid[i][j]
  --     end
  --     log(str)
  --   end
  -- end

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
      log("h" .. to_s(h))
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
              entity_create(x+i, y+j, 42, {def = 5, ai=noop, outline=false})
            else
              tile = 57
            end
          end
        end
        mset(x+i, y+j, tile)
      end
    end

    -- random vases

    -- random rocks

  end

  -- log_grid("end")

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
      door += 1
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

        -- if g == 'e' then
        --   zel_active = room.index
        --   log("player room")
        --   log(zel_active)
        --   log(i .. ',' .. j)
        --   log(room)
        -- end

        draw_room(x, y)
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
  pal(0,15)
  for i=1,15 do
    pal(i, 0)
  end

  if _outline then
    for dx=-1,1 do
      for dy=-1,1 do
        spr(_spr,_x + dx ,_y + dy,1,1,_flip)
      end
    end
  end

  -- reset palette
  pal()
  palt()

  --palt(0,true)
  --pal(7,_c)
  if _flash then
    for i=1,15 do
      pal(i, 142)
    end
  end
  spr(_spr,_x,_y,1,1,_flip)
  pal()
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
000000008090a0b000000000000000000000000000000000dddddd5ddddddd5ddddddd5d11111111111111115ddddd5ddddddd5d5ddddd550000000000000000
00000000090a0b0300000000000000000000000000000000dddddd5dddd00d5dddd44d5d1555555115515551d5ddddd5dddddd5dd5dddd550000000000000000
0000000090a0b0300004400000aaa0000000000000000f00dddddd5ddd00005ddd44445d1555555115111551dd5ddddddddddd5ddd5dd5dd0000000000000000
000000000a0b03010007700000a0a000000000000000f0005555555550000005544444451555555111111151ddd5d55555555555ddd555550000000000000000
00000000a0b03010000ff00000aa0000000f0000000f0000ddd5ddddd000000dd446666d1555555111111111dddd5dddddd5ddddddd55ddd0000000000000000
000000000b03010200ffff00000aa0000060600000f00000ddd5d5ddd000000dd444444d1155555115511111ddd5d5ddddd5dddddd55d5dd0000000000000000
00000000b030102000ffff00000a00000006000000000000dddd5dddd000000dd446666d11155551155511115dd5dd5dddd5dddd55d5dd5d0000000000000000
0000000003010205000ff000000aa00000000000000000005555555550000005544444451111111111111111d5d5ddd55555555555d5ddd50000000000000000
0000000000000000000000000000000000000000000000005555555550000005d666644d1111111111111111ddd5ddd5000000005ddd5ddd0000000000000000
0000cc0000004400000000000000000000000000000f0000ddd5d55dd000000dd444444d1111111111551111ddd5ddd5000000005ddd5ddd0000000000000000
0000ff000000ff000000070000000000000f00000070f000dddd5d5dd000000dd666644d11111111155551115555ddd50000000055555ddd0000000000000000
00088800000333000000700000000000000f000000700f00ddd5d55dd000000d544444451111111115555111ddd5ddd5000000005ddd5ddd0000000000000000
0080880000303300000ff000000f0000000f000000700f005555555555000055dd4444dd1111111111551111ddd5ddd5000000005ddd5ddd0000000000000000
00f022f000f044f000ffff00000f0000000f000000700f00ddd5dddddd0000dddd4444dd1111111111111551ddd55555000000005ddd55550000000000000000
000202000004040000ffff0000666000006660000070f000ddd5dddddd500dddddd44ddd1111111111111551ddd5ddd5000000005ddd5ddd0000000000000000
0020020000400400000ff0000006000000060000000f0000ddd5dddddd5ddddd555555551111111111111111ddd5ddd5000000005ddd5ddd0000000000000000
000000000000000000000000000000000000000000000000ddd5ddd5ddd5ddd5ddd5ddd5111111110000d0005ddddd55555555555ddd5d5d0000000000000000
006605000000000000000000000000000007000000000000ddd5ddd5ddd50000ddd544441313111100dddd00d5dddd55dddddd5dd5dd5dd50000000000000000
0660005000000000100000100000000000707000000000005555ddd55550000055544444131311110dddddd0dd5dd5dddddddd5ddd5d5ddd0000000000000000
606060600005522011000110000aa0000700070000000000ddd5ddd5dd000000dd444444111111110dddddd5ddd55555dddddd5dddd5dddd0000000000000000
00608680050525500181810000aaaa000070700000000000ddd55d55dd000000dd444646111111110dd5d5ddddd55ddd55555555555d5ddd0000000000000000
00d6d6605055565600111000000aa0000007ff0000000000ddd5d5d5ddd00000ddd446461111313105dd5d50dd55d5ddddd5ddddddddd5dd0000000000000000
0dddd0005075060600010000000000000000ff0000000000ddd55d55ddd50000ddd546461111313100d5d5005585dd5dddd5dddd5ddddd5d0000000000000000
066d55505000060600000000000000000000000000000000ddd5ddd5ddd5ddd5ddd5ddd5111111110000000055d5ddd5ddd5ddddd5ddddd50000000000000000
0000000000000000000000000000000000000000000000005ddd5ddd5ddd5ddd5ddd5ddd1111d111551111110000000000000000000000000000000000000000
00bbb00000000000000000000000000000000000000000005ddd5ddd00005ddd64645ddd11dddd11551611110000000000000000000000000000000000000000
00bb83000222720c0000000000000000000000000000000055555ddd000000dd646444dd1dddddd1551616110000000000000000000000000000000000000000
00033300020222c000bbb0000000000000000000000000005ddd5ddd000000dd646444dd1ddddddd551616170444444009999990000000000000000000000000
003330000200000c0bbb3b000000000000000000000000005dd5d5dd000000dd444444dd15dddddd5516161704566540095aa590000000000000000000000000
0bb300b002eeee00bbbb3b000000000000ffff00000000005ddd5d55000000554444445511dd5dd1551616110444444009999990000000000000000000000000
00bb000300002e00bbbbb3b0000000000f0ff0f0000000005dd5d5dd00005ddd44445ddd11111111551611110455554009555590000000000000000000000000
000bbb330e22e200bbbbbbb000000000000ff000000000005ddd5ddd5ddd5ddd5ddd5ddd11111111551111110444444009999990000000000000000000000000
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
__gff__
0000000000000000050000010101000000000000000000000500000100010000000000000000000005000101010100000000000000000000050100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000019550195501955019550175501655015550145501455013550135501355013550125501255011550105500f5500f5500f5500e550125500e5500e550125500e5500e5500f5500f5500f5500f5500f550
000100000c5530c0510d0510f0410f040100401103012030130201402015030160501706018070190701a0701b0701c0701d0701e070200602105022040240302502027020290112c0512e051310523505239053
0001000023150211501f150236501c1501b1501915019150191501f7501915019150191501915018150181501715017150161501c750141501b7501315012150101500f1500d1500d1500c1500b1500b1500a150
0001000026450244502345021450204401d4301a4501843016430144200f4200c420084200541003410014100e400194000a400074000640005400154000d500124000f4000d4000d5000940007400074000e500
00080000035000350004500055000550006500065000850009500095000a5000c5000d5000e5001050011500135001450017500195001a5001c5001e5001f500215002350025500265002a5002d5002f50033500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000000000000000000100501f0501f0701d050240500000019050290502a05015050110502c0500e0502e0500a050080502e0502e0500000000000000000000000000000000000000000000000000000000
__music__
00 01424344
00 57424344

