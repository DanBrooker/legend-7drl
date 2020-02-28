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

