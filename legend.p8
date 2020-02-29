pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--legend
--by draconisnz


size=36
dev=true

t_player = 16
t_bat = 32
t_snake = 48
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

function _init()
 t=0

 --dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14} -- fading

 dirs = {{-1,0}, {1,0}, {0,-1}, {0,1}}

 startgame()
end

function _update()
 t+=1
 _upd()
 dofloats()
end

function _draw()
 _drw()
 --checkfade()

 cursor(4,4)
 color(8)
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

  zel_init()

  player=entity_create(start[1] * 8 - 4, start[2] * 8 -4, t_player, 8)

  _upd=update_game
  _drw=draw_game
end
-->8
--game
function update_game()
   update_player(player)
   for mob in all(mobs) do
     update_mob(mob)
   end
  --wfc_observe()
  --wfc_propagate()
end

function draw_game()
 cls(0)
 do_shake()

 clip(32, 32, 128-56, 128-56)
 map(0, 0, 0,0, size, size)
 clip()

 foreach(entities,entity_draw)
 --foreach(enviro,draw_enviro)
 --foreach(particles,draw_part)
 -- foreach(float, draw_float)
 if dev then
  minimap_draw()
  zel_draw()
 end
end

function update_player(player)
  local endturn = input(getbutt())

  if endturn then
    --animate()
    animate(update_end_turn)
  end
end

function update_mob(mob)

end

function update_end_turn()
 for entity in all(entities) do
   entity.mov = nil
   local tile = mget(entity.x,entity.y)
   if tile == t_stairs and entity == player then
     mapgen(lvl + 1)
   --elseif fget(tile, 5) then
    -- tip = 'watch your step'
    --if (not entity.flying) dmg(entity, 2, 'the void')
   else
    --local env = env_at(entity.x,entity.y)
    --if env then
     ---- add(debug, entity.name .. "=" .. env.type)
     --if (entity.name != env.type) dmg(entity, 1, env.name)
    --end
   end
  --if (entity.hp <= 0) then
   --on_death(entity)
  --end
 end
 for env in all(enviro) do
  env.turns -= 1
  if(env.turns <= 0) del(enviro, env)
 end
 _upd = update_ai
  --_upd =
end

function update_ai()
  --buffer()

  for entity in all(entities) do
   if entity != player then
    if entity.stun > 0 then
     entity.stun -= 1
    else
     -- add(debug, "action " .. entity.name)
     --if entity.boss then
      --boss_action(entity)
     --else
      ai_action(entity)
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
   dmg(player, entity.dmg, entity.name)
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

function dmg(entity, amount, cause)
 if amount < 0 then
  addfloat('+'.. abs(amount), entity.x * 8, entity.y * 8, 11)
 else
  addfloat('-'.. amount, entity.x * 8, entity.y * 8, 8)
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
  --if aiming then
   --return fireprojectile(player, dirs[butt+1])
  --else
   return moveplayer(dirs[butt+1])
  --end
 elseif butt==4 then
  --return toogleshoot()
 elseif butt==5 then
  --if aiming then
   --return false -- maybe discharge if #enemies == 0
  --else
   --return switchitem()
  --end
 end
end

function moveplayer(dir)
 local dx, dy = dir[1], dir[2]
 local destx,desty=player.x+dx,player.y+dy
 --local tle=mget(destx,desty)

 if walkable(destx,desty, "entities") then
  -- sfx(63)
  mobwalk(player,dx,dy)
  --animate()
 else
  -- sfx(63)
  mobbump(player,dx,dy)
  --animate()
 end
 return true
end

function walkable(x, y, mode)
 if(dev) return true

 local mode = mode or ""
 local floor = not fget(mget(x,y), 0)
 -- TODO improve this
 if mode == "entities" then
  if (floor) return entity_at(x,y) == nil
 end
 if mode == "player" then
  if (floor) return player.x == x and player.y == y
 end
 return floor
end

function entity_at(x,y)
 for m in all(entities) do
  if m.x==x and m.y==y then
   return m
  end
 end
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
      cursor((i-1)*rs + 3,(j-1)*rs + 2)
      local v = gget(i,j)
      if v == 'e' then
        color(11)
      elseif v == 'b' then
        color(8)
      elseif v == 'h' then
        color(5)
      elseif v == 'k' then
        color(10)
      elseif v == 'l' then
        color(4)
      elseif v == 's' then
        color(2)
      elseif v == 't' then
        color(9)
      else
        color(12)
      end
      print(v)

      local room = zgetr(i,j)
      if room and room.index == zel_active then
        rect(room.left, room.top, room.right, room.bottom, 11)
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

function zgetr(i,j)
  return rooms[zindex(i,j)]
end

function zinr(x,y)

end

function zindex(i,j)
  return (i-1)*s+(j-1)+1
end

grid = {}
rooms = {}
zel_active = -1
function zel_generate()
  grid = {}
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

  --valid_grid = function()
    --local zero = 0
    --local required = { "k", "l", "b", "e" }
    --for i = 1,s do
      --for j = 1,s do
        --del(required, grid[i][j])
        --if (grid[i][j] == 0) zero += 1
      --end
    --end
    --log("required")
    --log(required)

    --return #required == 0 and zero <= 3
  --end

  empty = function(n)
    return ggetp(n) == 0
  end

  randp = function()
    return {rand(1,s), rand(1,s)}
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

  --log_grid("start")

  -- end room (boss)
  repeat
    boss = randp()
  until empty(boss) and distancep(boss, start) > 3
  --grid[boss[1]][boss[2]] = 'b'
  gsetp(boss, 'b')

  for i = 1,rand(3) do
    local h = {0,0}
    repeat
      h = randp()
    until empty(h) and distancep(boss, h) > 1
    --grid[h[1]][h[2]] = 'h'
    gsetp(h, 'h')
  end

  --log_grid("boss")

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

    if emp then
      add(keys, p)
    end


    k += 1

    --pop(expand)

  end

  log_grid("")
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
  gsetp(hidden, 's')

  --grid[boss[1]][boss[2]] = 'b'
  gsetp(boss, 'b')
  --grid[start[1]][start[2]] = 'e'
  gsetp(start, 'e')

  --if not valid_grid() then
    --zel_generate()
    --return
  --end

  function draw_room(x,y, g)
    --log('room')

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
        -- elseif rand(1,20) == 1 then
        --   -- entity_create(x+i, y+j, 1)
        end
        mset(x+i, y+j, tile)
      end
    end
  end

  log_grid("end")

  function add_door(a,b)
    local dx,dy = normalise(b[1]-a[1], b[2]-a[2])

    local mrs = flr(rs/2)

    for i = mrs, mrs+1 do
      --i = flr(rs/2)
      x = a[1] * rs - rs/2 + (i*dx)
      y = a[2] * rs - rs/2 + (i*dy)

      --if i == flr(rs/2) then
        door = 1
        if ggetp(a) == 'l' then
          door = 8
        elseif ggetp(b) == 's' then
          -- mset(x,y, 1)
        else
          if dx == 1 then
            door = t_door_r
          elseif dx == -1 then
            door = t_door_l
          elseif dy == 1 then
            door = t_door_b
          else -- dy == -1
            door = t_door_t
          end
        end
        mset(x,y, door)
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
        index=zindex(i,j)
      }
      add(rooms, room)
      if g != 'h' and g != 0 then

        if g == 'e' then
          zel_active = room.index
          log("player room")
          log(zel_active)
          log(i .. ',' .. j)
          log(room)
        end

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
--combat text
function addfloat(_txt,_x,_y,_c)
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

function drawfloat(f)
  oprint8(f.txt,f.x,f.y,f.c,0)
end
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

 local i, j = flr(player.x / 9) + 1, flr(player.y / 9) + 1
 debug[1] = i .. "," .. j
 room = zgetr(i,j)
 debug[2] = to_s(room)

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
 return flr(rnd(max)+min)
end

function randf(min, max)
 return rnd(max)+min
end

function randa(array)
 return array[rand(1, #array)]
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
000000008090a0b00000000000000000000000000000000000000000dddddd5ddddddd5d11111111111111115ddddd5ddddddd5d5ddddd550000000000000000
00000000090a0b030000000000000000000000000000000000000000ddd00d5dddd44d5d1555555115515551d5ddddd5dddddd5dd5dddd550000000000000000
0000000090a0b0300000000000000000000000000000000000000000dd00005ddd44445d1555555115111551dd5ddddddddddd5ddd5dd5dd0000000000000000
000000000a0b0301000000000000000000000000000000000000000050000005544444451555555111111151ddd5d55555555555ddd555550000000000000000
00000000a0b030100000000000000000000000000000000000000000d000000dd446666d1555555111111111dddd5dddddd5ddddddd55ddd0000000000000000
000000000b0301020000000000000000000000000000000000000000d000000dd444444d1155555115511111ddd5d5ddddd5dddddd55d5dd0000000000000000
00000000b03010200000000000000000000000000000000000000000d000000dd446666d11155551155511115dd5dd5dddd5dddd55d5dd5d0000000000000000
0000000003010205000000000000000000000000000000000000000050000005544444451111111111111111d5d5ddd55555555555d5ddd50000000000000000
00000000000000000000000000000000000000000000000000000000d000000dd666644d1111111111111111ddd5ddd5000000005ddd5ddd0000000000000000
00004400000044000000000000000000000000000000000000000000d000000dd444444d1111111111551111ddd5ddd5000000005ddd5ddd0000000000000000
0000ff000000ff000000000000000000000000000000000000000000d000000dd666644d11111111155551115555ddd50000000055555ddd0000000000000000
0003330000033300000000000000000000000000000000000000000050000005544444451111111115555111ddd5ddd5000000005ddd5ddd0000000000000000
00303300003033000000000000000000000000000000000000000000dd0000dddd4444dd1111111111551111ddd5ddd5000000005ddd5ddd0000000000000000
00f044f000f044f00000000000000000000000000000000000000000dd0000dddd4444dd1111111111111551ddd55555000000005ddd55550000000000000000
00040400000404000000000000000000000000000000000000000000ddd00dddddd44ddd1111111111111551ddd5ddd5000000005ddd5ddd0000000000000000
0545545005455450000000000000000000000000000000000000000055555555555555551111111111111111ddd5ddd5000000005ddd5ddd0000000000000000
00000000000000000000000000000000000000000000000000000000ddd5ddd5ddd5ddd5111111111110d0115ddddd55dddddd5d5ddd5d5d0000000000000000
00660500006605000000000000000000000000000000000000000000ddd50000ddd544441313111110dddd01d5dddd55dddddd5dd5dd5dd50000000000000000
066000500660005000000000000000000000000000000000000000005550000055544444131311110dddddd0dd5dd5dddddddd5ddd5d5ddd0000000000000000
60606060606060600000000000000000000000000000000000000000dd000000dd444444111111110dddddddddd5555555555555ddd5dddd0000000000000000
00608680006086800000000000000000000000000000000000000000dd000000dd444646111111110dd0d0ddddd55dddddd5dddd555d5ddd0000000000000000
00d6d66000d6d6600000000000000000000000000000000000000000ddd00000ddd44646111131310ddd0dd0dd55d5ddddd5ddddddddd5dd0000000000000000
0dddd0000dddd0000000000000000000000000000000000000000000ddd50000ddd546461111313110d0d0115585dd5dddd5dddd5ddddd5d0000000000000000
055d5550055d55500000000000000000000000000000000000000000ddd5ddd5ddd5ddd5111111111111111155d5ddd555555555d5ddddd50000000000000000
000000000000000000000000000000000000000000000000000000005ddd5ddd5ddd5ddd1110d011551111110000000000000000000000000000000000000000
00bbb00000bbb000000000000000000000000000000000000000000000005ddd64645ddd10dddd01551611110000000000000000000000000000000000000000
00bb830000bb83000000000000000000000000000000000000000000000000dd646444dd0dddddd0551616110000000000000000000000000000000000000000
00033300000333000000000000000000000000000000000000000000000000dd646444dd0ddddddd551616170000000000000000000000000000000000000000
00333000003330000000000000000000000000000000000000000000000000dd444444dd0ddddddd551616170000000000000000000000000000000000000000
0bb350b00bb350b00000000000000000000000000000000000000000000000554444445510ddddd0551616110000000000000000000000000000000000000000
00bb505300bb5053000000000000000000000000000000000000000000005ddd44445ddd11000001551611110000000000000000000000000000000000000000
055bbb33055bbb3300000000000000000000000000000000000000005ddd5ddd5ddd5ddd11111111551111110000000000000000000000000000000000000000
__gff__
0000000000000000010000010101000000000000000000000100000100010000000000000000000001000101010100000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

