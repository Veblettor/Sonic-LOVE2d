

local BaseOBJ = Object:extend()


function BaseOBJ:new(Width,Height)
	


	self.Position = Vector2(0,0)
	self.Speed = Vector2(0,0)
	self.Radius = Vector2(Width,Height)
	self.XPos = 0
	self.YPos = 0
	self.XSpeed = 0
	self.YSpeed = 0
	
	self.GroundAngle = 0
	self.DrawAngle = 0
	self.TargetDrawAngle = 0
	self.WidthRadius = Width
	self.HeightRadius = Height
	
	print("Radius: "..tostring(self.Radius))
	print("Radius Mag: "..tostring(self.Radius:Magnitude()))
	print("Radius Unit: "..tostring(self.Radius:Unit()))
	print(tostring(-self.Radius))
	self.Grv = 0.21875
	self.State = "Grounded"
end

function BaseOBJ:UpdateMotion(dt,grnd)

	local speedcalc

	if self.State == "InAir" then
		speedcalc = math.max(math.abs(self.XSpeed/2),0.5)
	else
		speedcalc = math.max(math.abs(grnd/2),0.5)
	end

	if math.sign(self.DrawAngle) == -1 and self.TargetDrawAngle == 0 and math.abs(self.DrawAngle - self.TargetDrawAngle) > 180 then
		self.TargetDrawAngle = -360
	end

	if self.DrawAngle == -360 then
		self.DrawAngle = 0
		self.TargetDrawAngle = 0
	end

	if math.abs(self.DrawAngle - self.TargetDrawAngle) > 180 then
		self.DrawAngle = self.TargetDrawAngle
	end

	if self.DrawAngle < self.TargetDrawAngle then
		self.DrawAngle = math.min(self.TargetDrawAngle, self.DrawAngle + 2.8125*speedcalc)
	elseif self.DrawAngle > self.TargetDrawAngle then
		self.DrawAngle = math.max(self.TargetDrawAngle, self.DrawAngle - 2.8125*speedcalc)
	end


	if self.State == "Grounded" or self.State == "Rolling" then
			
			local a = self.GroundAngle
			
			if a < 0 then
				a = 360 + self.GroundAngle
			end
			
			self.XSpeed = grnd * math.cos(math.rad(a))
			self.YSpeed = grnd * -math.sin(math.rad(a))
	
			
	
			self.XPos = self.XPos + self.XSpeed
			self.YPos = self.YPos + self.YSpeed
		
		elseif self.State == "InAir" then
			self.TargetDrawAngle = 0
			self.XPos = self.XPos + self.XSpeed
			self.YPos = self.YPos + self.YSpeed
		
			if self.YSpeed < 0 and self.YSpeed > -4 then
				self.XSpeed = self.XSpeed - (self.XSpeed/0.125)/256
			end
		
			self.YSpeed = self.YSpeed + self.Grv

			if self.YSpeed > 16 then self.YSpeed = 16 end
			
			if self.GroundAngle < 0 then
				self.GroundAngle = math.min(self.GroundAngle + 2.8125,0)
			elseif self.GroundAngle > 0 then
				self.GroundAngle = math.max(self.GroundAngle - 2.8125,0)
			end

			
	end

end

return BaseOBJ