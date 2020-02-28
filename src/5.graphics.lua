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
 local x, y = flr(player.x / 8) * 8, flr(player.y / 8) * 8
--- x, y = x*8, y*8
 x, y = x*rs - 32, y*rs - 32

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
