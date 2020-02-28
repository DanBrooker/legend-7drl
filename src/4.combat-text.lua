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
