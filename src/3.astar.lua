
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

