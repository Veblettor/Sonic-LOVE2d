local levels = require("Registry.Levels")
Player = BaseOBJ:extend()


function Player:new(Width,Height,CharacterProperties)

	Player.super.new(self,Width,Height)
	
	self.State = "InAir"
	self.Facing = "Right"
	self.CurrentAnimation = "Idle"
	self.CurrentAnimationFrame = 1
	self.TimeSinceLastFrame = 0
	self.FrameDelay = 0.1
	self.CollisionMode = "upright"
	self.HoldingJump = false
	
	
	self.Acc = CharacterProperties.Acceleration
	self.Dec = CharacterProperties.Deceleration
	self.Frc = CharacterProperties.Friction
	self.Top = CharacterProperties.TopSpeed
	
	self.Slp = CharacterProperties.SlopeWalkFactor
	self.Slprollup = CharacterProperties.SlopeRollUp
	self.Slprolldown = CharacterProperties.SlopeRollDown
	self.Fall = CharacterProperties.WallStickTolerance
	
	self.Air = CharacterProperties.AirAcceleration
	self.Jmp = CharacterProperties.JumpPower
	self.Grv = CharacterProperties.Gravity
	self.Animations = CharacterProperties.Animations
	
	
	
	
	for i,v in pairs(self.Animations) do
		v.Frames = {}
		
		for index = 1, v.FrameCount do
			
			v.Frames[index] = love.graphics.newQuad((index-1) * v.FrameWidth, 0,v.FrameWidth, v.FrameHeight, v.SpriteSheet:getPixelDimensions())
		end
	end
	
end

function Player:ChangeAnimation(AnimationName)
	self.CurrentAnimation = AnimationName
	self.CurrentAnimationFrame = 1
	self.TimeSinceLastFrame = 0

end

local function sign(num)
	if num > 0 then
		return 1
		elseif num < 0 then
		return -1
		else
		return 0
	end
end
		
function Player:UpdateCollisionMode()

	local mode = "upright"
	
	local ang = self.GroundAngle
	
	if sign(ang) == 1 or sign(ang) == 0 then
			if ang < 46 then
		
		
		
		mode = "upright"
		
		elseif ang > 45 and ang < 134 then
		
	
		
		
		mode = "rightwall"
		
		elseif ang > 133 and ang < 226 then
		
	
		
		
		
		mode = "ceiling"
		
		elseif ang > 225 and ang < 314 then
		
	
		
		
		mode = "leftwall"
		
		elseif ang > 313 then
		
		
		
		mode = "upright"
		
	end
		elseif sign(ang) == -1 then
		

		if ang > -46 then
	
		
		
		mode = "upright"
		
		elseif ang < -45 and ang > -134 then
		
		
		mode = "leftwall"
		
		elseif ang < -133 and ang > -226 then
		
	
		
		mode = "upright"
		
		elseif ang < -225 and ang > -314 then
		
		mode = "rightwall"
		
		elseif ang < -313 then
		
		
		mode = "ceiling"
		
	end
		
		
	end

	self.CollisionMode = mode
end

function Player:UpdateAnimations(dt)
	if self.GroundAngle == 360 then self.GroundAngle = 0 end

	

	if self.State == "Grounded" then
	
	if math.abs(self.GroundSpeed) == 0 and self.CurrentAnimation ~= "Idle" then
		self:ChangeAnimation("Idle")
		
		elseif math.abs(self.GroundSpeed) < 6 and math.abs(self.GroundSpeed) > 0 and self.CurrentAnimation ~= "Walking" then
		self:ChangeAnimation("Walking")
		
		elseif math.abs(self.GroundSpeed) >= 6 and self.CurrentAnimation ~= "Running" then
		self:ChangeAnimation("Running")
		
	end
	
	elseif self.State == "Rolling" and self.CurrentAnimation ~= "Rolling" then
		self:ChangeAnimation("Rolling")
	end
	
	if self.HoldingJump and self.CurrentAnimation ~= "Rolling" then
		self:ChangeAnimation("Rolling")
	end
end

function Player:UpdateJump(dt)



if love.keyboard.isDown("space") then
	
			if not self.HoldingJump and (self.State == "Grounded" or self.State == "Rolling")  then
			
			self.XSpeed = self.XSpeed - self.Jmp * math.sin(math.rad(self.GroundAngle))
			self.YSpeed = self.YSpeed - self.Jmp * math.cos(math.rad(self.GroundAngle))
			self.HoldingJump = true
			self.State = "InAir"
			end
	
			
		else
		
		self.HoldingJump = false
	

	
	
	
end

if self.HoldingJump == false and self.YSpeed < -4 then
			self.YSpeed = -4
		elseif self.HoldingJump == true then
			
			
	end
	
if self.State == "Grounded"	 then

self.HoldingJump = false

end

end

function Player:UpdateMovement(dt)



	if self.State == "Grounded" then
		
		self.GroundSpeed = self.GroundSpeed - self.Slp*math.sin(self.GroundAngle)
	
		if love.keyboard.isDown("a") then
	
		self.Facing = "Left"
	
		if self.GroundSpeed > 0 then
			
			self.GroundSpeed = self.GroundSpeed - self.Dec
			
			if self.GroundSpeed <= 0 then
				self.GroundSpeed = -0.5
			end
			
			elseif (self.GroundSpeed > -self.Top) then
			
			self.GroundSpeed = self.GroundSpeed - self.Acc
			
			if self.GroundSpeed <= -self.Top then
				self.GroundSpeed = -self.Top
			end
			
		end
	
	
		elseif love.keyboard.isDown("d") then
		
		self.Facing = "Right"
		
		if self.GroundSpeed < 0 then
			
			self.GroundSpeed = self.GroundSpeed + self.Dec
			
			if self.GroundSpeed >= 0 then
				self.GroundSpeed = 0.5
			end
			
			elseif (self.GroundSpeed < self.Top) then
			
			self.GroundSpeed = self.GroundSpeed + self.Acc
			
			if self.GroundSpeed >= self.Top then
				self.GroundSpeed = self.Top
			end
			
		end
		
		
		
		else
		
		
		self.GroundSpeed = self.GroundSpeed - math.min(math.abs(self.GroundSpeed),self.Frc) * sign(self.GroundSpeed)
	end
	
	if love.keyboard.isDown("s") then
		
		if math.abs(self.XSpeed) >= 1 then
			self.State = "Rolling"
		end
	end
	
	elseif self.State == "InAir" then
		
		
	
		if love.keyboard.isDown("a") then
	
			self.Facing = "Left"
			
			if (self.XSpeed > -self.Top) then
			
			self.XSpeed = self.XSpeed - self.Acc
			
			if self.XSpeed <= -self.Top then
				self.XSpeed = -self.Top
			end
			
		end
	
	
		elseif love.keyboard.isDown("d") then
		
			self.Facing = "Right"
			
			if (self.GroundSpeed < self.Top) then
			
			self.XSpeed = self.XSpeed + self.Acc
			
			if self.XSpeed >= self.Top then
				self.XSpeed = self.Top
			end
			
			end

		

	end
	
	
	elseif self.State == "Rolling" then
	
	
	if sign(self.GroundSpeed) == sign(self.GroundAngle) then
		self.GroundSpeed = self.GroundSpeed - self.Slprollup*math.sin(self.GroundAngle)
		else
		self.GroundSpeed = self.GroundSpeed - self.Slprolldown*math.sin(self.GroundAngle)
	end
	self.GroundSpeed = self.GroundSpeed - math.min(math.abs(self.GroundSpeed),self.Frc/2) * sign(self.GroundSpeed)
	
	if love.keyboard.isDown("a") then
	
	
	
		
		self.Facing = "Left"
	
		
	
		if self.GroundSpeed > 0 then
			
			
			
			--self.GroundSpeed = self.GroundSpeed - self.Dec
			
			if self.GroundSpeed == 0 then
				self.GroundSpeed = -0.5
			end
			
			else
			
			
			
		end
	
	
		elseif love.keyboard.isDown("d") then
		
		self.Facing = "Right"
		
		if self.GroundSpeed < 0 then
			
			--self.GroundSpeed = self.GroundSpeed + self.Dec
			
			if self.GroundSpeed == 0 then
				self.GroundSpeed = 0.5
			end
			
		
		
		
			
		end
	
	
		
	end	
	

	
	if self.GroundSpeed == 0 or love.keyboard.isDown("w") then
		self.State = "Grounded"
	end
	
	end
	
	
end

function Player:SnapToNearest90Degrees()
	
	local ang = math.abs(self.GroundAngle)
	if ang < 46 or ang >= 315 then
		self.GroundAngle = 0
		
		elseif ang >= 46 and ang < 135 then
		
		self.GroundAngle = 90
		
		
		
		elseif ang >= 135 and ang < 225 then
		
		self.GroundAngle = 180*sign(self.GroundAngle)
		
		elseif ang >= 225 and ang < 315 then
		
		self.GroundAngle = 270*sign(self.GroundAngle)
	end
end



function Player:RegressTile(sensor,mode,ogtile,ogheightindex)
	
	local level = levels[GameMap.LevelIndex]
	
	local ftile
	local rdist
	
	if mode == "upright" then
		
		for i,tile in pairs(GameMap.Tiles) do
			if tile.XPos == ogtile.XPos and tile.YPos == ogtile.YPos - 16 then
				
				local tileid = tile.TileId
				
				--local tiledata = level.TileSet[tileid]
				
				local heightmap = tile.HeightMap
				
				if heightmap[ogheightindex] ~= 0 then
					
					local point
					
					if tile.Flags.Flipped then
							
							point = tile.YPos-18 + heightmap[ogheightindex] - (16-heightmap[ogheightindex])
							else
							point = tile.YPos - heightmap[ogheightindex]
						end
					
					local dist = point - sensor[2]

					ftile = tile
					rdist = dist
						
					
				end
				
			end
		end
		
	end
	
	
	return ftile,rdist
end

function Player:GetNearestFloor(sensor,maxdist,mode)
local foundtile
local olddist = maxdist + 1

local hmindex
local hmheight



local level = levels[GameMap.LevelIndex]

	if mode == "upright" then	
			
			
			for i,tile in pairs(GameMap.Tiles) do
		
				if tile.CanCollide then
					
					--local tileid = tile.TileId
				
					--local tiledata = level.TileSet[tileid]
				
					local heightmap = tile.HeightMap
				
					local indexused = math.floor(tile.XPos - sensor[1] )
					
					--indexused = indexused +1
					
					
					if  heightmap[indexused] and heightmap[indexused] ~= 0 then
						
						local point
						if tile.Flags.Flipped then
							
							point = tile.YPos-18 + heightmap[indexused] - (16-heightmap[indexused])
							else
							point = tile.YPos - heightmap[indexused]
						end
						
						
						
						local dist
						
						
						dist =  point - sensor[2]
						
						
						
					
						if  math.abs(dist) < olddist then
							
							
							
							olddist = dist
							foundtile = tile
							hmindex = indexused
							hmheight = heightmap[indexused]
						end
					end
					
				end
			
			end
			
			

			
			
		
	
		elseif mode == "rightwall" then
		
		
			
		
		elseif mode == "ceiling" then
		
		
		
		
		
		elseif mode == "leftwall" then
		
		
			
			
		
		end
		

		
	
	
	
	if not foundtile then return nil,nil,nil,nil end
	if foundtile then return foundtile,olddist,hmindex,hmheight end
end

function Player:GetNearestWall(sensor,maxdist,mode)
local foundtile
local olddist = maxdist + 1
local hmindex
local hmheight

local level = levels[GameMap.LevelIndex]

	if mode == "upright" then
		
		for i,tile in pairs(GameMap.Tiles) do
		
		if tile.CanCollide then
			
			local tileid = tile.TileId
				
					--local tiledata = level.TileSet[tileid]
				
					local heightmap = tile.HeightMap
				
					local indexused = math.floor(tile.XPos - sensor[1] )
					
					if  heightmap[indexused] and heightmap[indexused] ~= 0 then
						
					
						
						local point = tile.XPos + indexused
						local ypoint = tile.YPos - heightmap[indexused]
						
						local dist
						
						
						dist =  point - sensor[1] 
						
						
						
					
						if  math.abs(dist) < olddist and sensor[2] >= ypoint and sensor[2] < tile.YPos  then
							
						
							
							
							
							olddist = dist
							foundtile = tile
							hmindex = indexused
							hmheight = heightmap[indexused]
						end
					end
			
			
			
		end
		
		end
		
	end
	
	
	
	return foundtile,olddist,hmindex,hmheight
end


function Player:UpdateWallCollision(dt)
	local sensorE
	local sensorF
	
	
	
	self:UpdateCollisionMode()
	
	local mode = self.CollisionMode
	
	if mode == "upright" then
		sensorE = {self.XPos+self.XSpeed-10, self.YPos}
		sensorF = {self.XPos+self.XSpeed+10, self.YPos}
		
		
		
	elseif mode == "rightwall" then
		sensorE = {self.XPos, self.YPos - 10}
		sensorF = {self.XPos, self.YPos + 10}
		
	elseif mode == "ceiling" then
	
	sensorE = {self.XPos + 10, self.YPos}
	sensorF = {self.XPos - 10, self.YPos}
	
	elseif mode == "leftwall" then
		
		sensorE = {self.XPos, self.YPos + 10}
		sensorF = {self.XPos, self.YPos - 10}
		
	end
	
	local sensor
	
	
	if sign(self.GroundSpeed) == -1 then
			sensor = sensorE
		else	
			sensor = sensorF
	end
	
	local detectedtile,dist,hmindex,hmheight = self:GetNearestWall(sensor,32,mode)
	
	if mode == "upright" then
	
	if detectedtile then
		
		
		if self.State == "Grounded" or self.State == "Rolling" then
		
				if dist > 0 then
			
			
			
			if sign(self.GroundSpeed) == -1 then
				self.XSpeed = self.XSpeed - dist
				self.GroundSpeed = 0
				
					
				
				
				else
				
				
					
				
				
				self.XSpeed = self.XSpeed - dist
				self.GroundSpeed = 0
			end
		
		
			
		end
		
			elseif self.State == "InAir" then
		
			print("Wall Dist: "..dist)
		
			if dist > 0 then
				if sign(self.GroundSpeed) == -1 then
					self.XSpeed = self.XSpeed - dist/16
					self.GroundSpeed = 0
					
						
					
					
					else
					
					
						
					
					
					self.XSpeed = self.XSpeed - dist/16
					self.GroundSpeed = 0
				end
			end
		
			
			
		end
	
		
		
		self.DebugTile = detectedtile
		
	
	end
	
	end
end

function Player:UpdateCollision(dt)
	local sensorA
	local sensorB
	local sensorC
	local sensorD
	
	
	
	local mode = self.CollisionMode
	
	local ang = self.GroundAngle
	
	
			if mode == "upright" then
		sensorA = {self.XPos - self.WidthRadius, self.YPos + self.HeightRadius}
		sensorB = {self.XPos + self.WidthRadius, self.YPos + self.HeightRadius}
		sensorC = {self.XPos - self.WidthRadius, self.YPos - self.HeightRadius}
		sensorD = {self.XPos + self.WidthRadius, self.YPos - self.HeightRadius}
		
		
		
		
		elseif mode == "rightwall" then
		
		sensorA = {self.XPos + self.HeightRadius, self.YPos + self.WidthRadius}
		sensorB = {self.XPos + self.HeightRadius,self.YPos - self.WidthRadius}
		sensorC = {self.XPos - self.HeightRadius, self.YPos + self.WidthRadius}
		sensorD = {self.XPos - self.HeightRadius,self.YPos - self.WidthRadius}
		
		mode = "rightwall"
		
		elseif mode == "ceiling" then
		
		sensorA = {self.XPos - self.WidthRadius, self.YPos - self.HeightRadius}
		sensorB = {self.XPos + self.WidthRadius, self.YPos - self.HeightRadius}
		
		sensorC = {self.XPos - self.WidthRadius, self.YPos + self.HeightRadius}
		sensorD = {self.XPos + self.WidthRadius, self.YPos + self.HeightRadius}
		
		
		
		
		
		elseif 	mode == "leftwall"then
		
		sensorA = {self.XPos - self.HeightRadius, self.YPos + self.WidthRadius}
		sensorB = {self.XPos - self.HeightRadius,self.YPos - self.WidthRadius}
		sensorC = {self.XPos + self.HeightRadius, self.YPos + self.WidthRadius}
		sensorD = {self.XPos + self.HeightRadius,self.YPos - self.WidthRadius}
	
	
		
		
		
	end
		
		
		
	
	
	
	
	
	
	local floortile1,floordist1,hmindex1,hmheight1,totaldist1 = self:GetNearestFloor(sensorA,32,mode)
	local floortile2,floordist2,hmindex2,hmheight2,totaldist2 = self:GetNearestFloor(sensorB,32,mode)
	
	if hmheight1 == 16 then
		local newtile,newdist = self:RegressTile(sensorA,mode,floortile1,hmindex1)
		
		if newtile then
			floortile1 = newtile
			floordist1 = newdist
			totaldist1 = newdist
		end
	end
	
	if hmheight2 == 16 then
		local newtile,newdist = self:RegressTile(sensorB,mode,floortile2,hmindex2)
		
		if newtile then
			floortile2 = newtile
			floordist2 = newdist
			totaldist2= newdist
		end
	end
	
	
	local winnertile,winnerdist,winnersensor,winnerh
	
	if floortile1 == nil and floortile2 then
		winnertile = floortile2
		winnerdist = floordist2
		winnersensor = sensorB
		winnerh = hmheight2
		elseif floortile2 == nil and floortile1 then
		winnertile = floortile1
		winnerdist = floordist1
		winnersensor = sensorA
		winnerh = hmheight1
		elseif floortile2 == nil and floortile1 == nil then
		
		
		winnersensor = nil
		winnertile = nil
		winnerdist = nil
		elseif floortile1 and floortile2 and floordist1 > floordist2 then
		winnertile = floortile2
		winnerdist = floordist2
		winnersensor = sensorB
		winnerh = hmheight2
		elseif floortile1 and floortile2 and floordist2 > floordist1 then
		winnertile = floortile1
		winnerdist = floordist1
		winnersensor = sensorA
		winnerh = hmheight1
		elseif floortile1 and floortile2 and floordist1 == floordist2 then
		
		if self.Facing == "Left" then
			winnertile = floortile1
		winnerdist = floordist1
		winnersensor = sensorA
		winnerh = hmheight2
			
			else
			
			winnertile = floortile2
		winnerdist = floordist2
		winnersensor = sensorB
		winnerh = hmheight2
		end
		
		
	end
	
	--self.DebugTile = winnertile
	
	if self.State == "InAir" then
	
	
		
		local threshold = -(self.YSpeed+48)
		
		if winnertile then
		
				if winnerdist then
			--print(winnerdist)
			--print('th: '..threshold)
		end
		
			if winnerdist >= threshold and math.floor(winnerdist) < -4 then
				
				if not winnertile.GroundAngle or winnertile.GroundAngle == 0 then
				self:SnapToNearest90Degrees()
				
				else
				
				self.GroundAngle = winnertile.GroundAngle
			end
				
				--self:CollideWithTile(winnertile)
				
				self.YPos = self.YPos + winnerdist
				
				self.State = "Grounded"
			end
		end
		
		elseif self.State == "Grounded" or self.State == "Rolling" then
		
		if not winnertile then
			self.State = "InAir"
			
			else
			
			
			if winnerdist > -32 and  winnerdist < 16 then
			
			if not winnertile.GroundAngle or winnertile.GroundAngle == 0 then
				self:SnapToNearest90Degrees()
				
				else
				
				self.GroundAngle = winnertile.GroundAngle
			end
			
			if mode == "upright" then
			
			self.YPos = self.YPos + winnerdist
			
			elseif mode == "rightwall" then
			
 			self.XPos = self.XPos + winnerdist
			
			end
			
			else
			
			self.State = "InAir"
			
			end
		
		end
		
		
		
	end
	
end






return Player