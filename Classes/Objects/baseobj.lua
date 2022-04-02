local levels = require("Registry.Levels")

BaseOBJ = Object:extend()


function BaseOBJ:new(Width,Height)
	local level = levels[GameMap.LevelIndex]


	self.PrevXPos = 0
	self.PrevYPos = 0
	self.XPos = 0
	self.YPos = 0
	self.XSpeed = 0
	self.YSpeed = 0
	self.GroundSpeed = 0
	self.GroundAngle = 0
	self.ActualAngle = 0
	self.WidthRadius = Width
	self.HeightRadius = Height
	
	--self.Collider = TileCollider.new(self.XPos-self.WidthRadius/2,self.YPos+self.HeightRadius/2,self.WidthRadius*2,self.HeightRadius*2, level.Map, level.TileSet)
	
	self.Grv = 0.21875
	self.State = "Grounded"
end

function BaseOBJ:UpdateMotion(dt)

	

	if self.ActualAngle < self.GroundAngle then
		self.ActualAngle = math.min(self.ActualAngle + 2.8125,self.GroundAngle)	
		
		elseif self.ActualAngle > self.GroundAngle then
		
		self.ActualAngle = math.max(self.ActualAngle - 2.8125,self.GroundAngle)	
	end


	if self.State == "Grounded" or self.State == "Rolling" then
		self.XSpeed = self.GroundSpeed * math.cos(math.rad(self.ActualAngle))
		self.YSpeed = self.GroundSpeed * -math.sin(math.rad(self.ActualAngle))
		
	
	
	
		self.XPos = self.XPos + self.XSpeed
		self.YPos = self.YPos + self.YSpeed
		
		elseif self.State == "InAir" then
		
	
	
	
	
		self.XPos = self.XPos + self.XSpeed
		self.YPos = self.YPos + self.YSpeed
		
		if self.YSpeed < 0 and self.YSpeed > -4 then
			self.XSpeed = self.XSpeed - (self.XSpeed/0.125)/256
		end
		
		self.YSpeed = self.YSpeed + self.Grv

		if self.YSpeed > 16 then self.YSpeed = 16 end
		
		self.GroundAngle = 0
		
	end

	
	
end

return BaseOBJ