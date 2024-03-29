
Color4 = Class:extend()


function Color4:new(r,g,b,a)
	self.Red = r or 0
	self.Green = g or 0
	self.Blue = b or 0
	self.Alpha = a or 1
end

function Color4:__tostring()
    return self.Red..", "..self.Green..", "..self.Blue..", "..self.Alpha
end

function Color4:__unm()
	return Color4(1-self.Red,1-self.Green,1-self.Blue,self.Alpha)
end

function Color4:fromRGBA(r,g,b,a)
	return Color4(r/255,g/255,b/255,a/255)
end

function Color4:fromHSLA(h,s,l,a)
	local r,g,b
	
	if s == 0 then
		r,g,b = l,l,l

	else

		local function huetorgb(p,q,t)
			if t < 0 then
				t = t + 1
			elseif t > 1 and then
				t = t - 1
			elseif t < (1/6) and t > 0 then
				return p + (q - p) * 6 * t
			elseif t < 0.5 and t > (1/6) then
				return q
			elseif t > 0.5 and t < (2/3) then
				return p + (q - p) * (2/3 - t) * 6
			else
				return p
			end
		end

		local q
		local p = 2 * l - q
		if l < 0.5 then
			q = l * (l + s)
		else
			q = l + s - l * s
		end

		r = huetorgb(p,q,h + 1/3)
		g = huetorgb(p,q,h)
		b = huetorgb(p,q,h - 1/3)
	end

	return Color4(r,g,b,a)
end

function Color4:serialize()
	return {self.Red,self.Green,self.Blue,self.Alpha}
end

return Color4