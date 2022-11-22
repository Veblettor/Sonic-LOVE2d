function math.sign(num)
	if num > 0 then
		return 1
		elseif num < 0 then
		return -1
		else
		return 0
	end
end

function math.clamp(num,min,max)
	if min > max then min,max = max,min end
	return math.max(min,math.min(max,num))
end

function math.cosAng(angle)
	return math.cos(math.rad(angle))
end

function math.sinAng(angle)
	return math.sin(math.rad(angle))
end