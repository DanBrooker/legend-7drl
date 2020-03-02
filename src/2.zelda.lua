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
  until walkable(x,y, "entities") or i > 10
  -- log("room")
  -- log(room)
  if(i>10) x,y=-1,-1
  -- log(x .. ',' .. y)
  return {x,y}
end

function zel_spawn(room)
  -- log("zel_spawn")
  room.spawn = true

  if room.g == 'e' then
    -- do nothing
    item_create(rnd_pos(room), randa(t_weapons))
    -- item_create(room.left+4, room.top+4, randa(t_items))
    -- item_create(room.left+5, room.top+5, randa(t_key))
  elseif room.g == 'b' then
    local boss = rnd_pos(room)
    entity_create(boss[1],boss[2], 48)
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
      entity_create(pos[1], pos[2], randa(t_enemies[depth]), {hp=1})
    end
  end

  -- random add heal or food
  item_create(rnd_pos(room), randa(t_heals))
  item_create(rnd_pos(room), randa(t_gold))
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
