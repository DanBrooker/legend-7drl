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
