function drawspr(_spr,_x,_y,_c,_flip, _flash, _outline)
  rpal()
  pal(0,15)
  for i=1,15 do
    pal(i, 0)
  end

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
  --pal(7,_c)
  if _flash then
    for i=1,15 do
      pal(i, 142)
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
