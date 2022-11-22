

local BaseOBJ = Class:extend()


function BaseOBJ:new(Width,Height)
	

	self.Radius = Vector2(Width,Height)
	self.Position = Vector2(0,0)
	
	self.Speed = Vector2(0,0)
	
	self.XPos = 0
	self.YPos = 0
	self.XSpeed = 0
	self.YSpeed = 0
	
	self.GroundAngle = 0
	self.DrawAngle = 0
	self.TargetDrawAngle = 0
	self.WidthRadius = Width
	self.HeightRadius = Height
	self.GroundSpeed = 0

	self.Grv = 0.21875
	self.State = "Grounded"
	print(self.Radius)
end

function BaseOBJ:UpdateMotion(dt)

	local speedcalc

	if self.State == "InAir" then
		speedcalc = math.max(math.abs(self.Speed.X/2),0.5)
	else
		speedcalc = math.max(math.abs(self.GroundSpeed/2),0.5)
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
			
		
	
			
			self.Position = self.Position + self.Speed
		--	self.XPos = self.XPos + self.XSpeed
		--	self.YPos = self.YPos + self.YSpeed
		
		elseif self.State == "InAir" then
			self.TargetDrawAngle = 0
			self.Position = self.Position + self.Speed
		--	self.XPos = self.XPos + self.XSpeed
		--	self.YPos = self.YPos + self.YSpeed
		
			if self.Speed.Y < 0 and self.Speed.Y > -4 then
				self.Speed.X = self.Speed.X - (self.Speed.X/0.125)/256
			end
		
			self.Speed.Y = self.Speed.Y + self.Grv

			if self.Speed.Y > 16 then self.Speed.Y = 16 end
			
			if self.GroundAngle < 0 then
				self.GroundAngle = math.min(self.GroundAngle + 2.8125,0)
			elseif self.GroundAngle > 0 then
				self.GroundAngle = math.max(self.GroundAngle - 2.8125,0)
			end

			
	end
	
end

return BaseOBJ