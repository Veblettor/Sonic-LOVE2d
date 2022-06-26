
Player = BaseOBJ:extend()


function Player:new(X,Y,CharacterProperties)

	Player.super.new(self,CharacterProperties.Scale.BaseWidth,CharacterProperties.Scale.BaseHeight)
	
	self.Debug = 
	{
		sensorA = {0,0};
		sensorB = {0,0};
		sensorC = {0,0};
		sensorD = {0,0};
		sensorE = {0,0};
		sensorF = {0,0};
		DebugTile = nil;
	}

	self.State = "InAir"
	self.Facing = "Right"
	self.CurrentAnimation = "Idle"
	self.CurrentAnimationFrame = 1
	self.TimeSinceLastFrame = 0
	self.FrameDelay = 0.1
	self.CollisionMode = "upright"
	self.HoldingJump = false
	
	self.XPos = X
	self.YPos = Y

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
	
	self.BaseWidth = CharacterProperties.Scale.BaseWidth
	self.BaseHeight = CharacterProperties.Scale.BaseHeight
	self.RollWidth = CharacterProperties.Scale.RollWidth
	self.RollHeight = CharacterProperties.Scale.RollHeight
	


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

	if self.CurrentAnimation == "Rolling" then
		self.WidthRadius = self.RollWidth
		self.HeightRadius = self.RollHeight
	else
		self.WidthRadius = self.BaseWidth
		self.HeightRadius = self.BaseHeight
	end

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
	local canJump
if self.State == "Grounded" then
canJump = self:CheckCanJump()
else
canJump = true
end


if love.keyboard.isDown("space") and canJump then
	
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


	if love.keyboard.isDown("f") then

		if self.Facing == "Right" then
			self.GroundSpeed = 6
		else
			self.GroundSpeed = -6
		end
	end

	if love.keyboard.isDown("r") then
		self.YSpeed = self.YSpeed - 1
	end

	

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
			
			self.XSpeed = self.XSpeed - self.Air
			self.GroundSpeed = self.GroundSpeed - self.Air

		

			if self.XSpeed <= -self.Top then
				self.XSpeed = -self.Top
			end
			
			self.GroundSpeed = self.XSpeed

		end
	
	
		elseif love.keyboard.isDown("d") then
		
			self.Facing = "Right"
			
			if (self.GroundSpeed < self.Top) then
			
			self.XSpeed = self.XSpeed + self.Air
			

			if self.GroundSpeed >= self.Top then
				self.GroundSpeed = self.Top
			end

			if self.XSpeed >= self.Top then
				self.XSpeed = self.Top
			end
			
			self.GroundSpeed = self.XSpeed

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
	
	
	
	local ftile
	local rdist
	
	if mode == "upright" then
		
		for i,tile in pairs(GameMap.Tiles) do
			if tile.XPos == ogtile.XPos and tile.YPos == ogtile.YPos - 16 then
				
				
				
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
		
	elseif mode == "rightwall" then

		for i,tile in pairs(GameMap.Tiles) do

			if tile.YPos == ogtile.YPos and tile.XPos == ogtile.XPos - 16 then
				local heightmap = tile.HeightMap

				if heightmap[ogheightindex] ~= 0 then
					local point

					if tile.Flags.Flipped then
						point = tile.XPos- (16 - heightmap[ogheightindex])
						else
						point = tile.XPos - heightmap[ogheightindex]
					end

					local dist = point - sensor[1]

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





	if mode == "upright" then	
			
			
			for i,tile in pairs(GameMap.Tiles) do
		
				if  not  (self.YSpeed < 0 and tile.Flags.IgnoreCeiling) then
					
					local heightmap = tile.HeightMap
				
					local indexused = math.floor(tile.XPos - sensor[1])
					
					if  heightmap[indexused] and heightmap[indexused] ~= 0 then
						
						local point
						
						if tile.Flags.Flipped then
							
							point = tile.YPos- (12+heightmap[indexused])
							else
							point = tile.YPos - heightmap[indexused]
						end
						
						local dist =  point - sensor[2]
					
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
		
		for i,tile in pairs(GameMap.Tiles) do
			local heightmap 
			if tile.HorizontalMap then
				heightmap = tile.HorizontalMap
			else
				heightmap = tile.HeightMap
			end
			

			local indexused = math.floor(tile.YPos - sensor[2])

			if heightmap[indexused] and heightmap[indexused] ~= 0 then
				
			--[[	if tile.Flags.Flipped then
					point = tile.XPos-18 + heightmap[indexused] - (16-heightmap[indexused])
				else
					point = tile.XPos - heightmap[indexused]
				end--]]
				point = tile.XPos - heightmap[indexused]
				local dist = point - sensor[1]

				if math.abs(dist) < olddist then
					olddist = dist
					foundtile = tile
					hmindex = indexused
					hmheight = heightmap[indexused]
				end
			end
		end
			
		
		elseif mode == "ceiling" then
		
		
		
		
		
		elseif mode == "leftwall" then
		
		
			
			
		
		end
		

		
	
	
	
	if not foundtile then return nil,nil,nil,nil end
	if foundtile then return foundtile,olddist,hmindex,hmheight end
end


function Player:GetNearestCeiling(sensor,maxdist,mode)
	local foundtile
	local olddist = maxdist + 1
	
	local hmindex
	local hmheight
	
	
	

	
		if mode == "upright" then	
				
				
				for i,tile in pairs(GameMap.Tiles) do
			
					if not tile.Flags.IgnoreCeiling then
						

					
						local heightmap = tile.HeightMap
					
						local indexused = math.floor(tile.XPos - sensor[1] )
						
						--indexused = indexused +1
						
						
						if  heightmap[indexused] and heightmap[indexused] ~= 0 then
							
							local point
						
								
							--point = tile.YPos-18 + heightmap[indexused] - (16-heightmap[indexused])

							
							if heightmap[indexused] == 16 then
								point = tile.YPos
							else
								--point = tile.YPos-16 + heightmap[indexused] - (16-heightmap[indexused])
								--point = tile.YPos - (16+heightmap[indexused])
								--point = tile.YPos+16 - (16+heightmap[indexused])
								point = tile.YPos - (heightmap[indexused]+4)
								--point = tile.YPos - 14 + (16-heightmap[indexused])
								
							end
							--point = tile.YPos-16 + heightmap[indexused]
							
							
							local dist
							
							
							dist =  sensor[2] - point
							
							
							
						
							if  math.abs(dist) < olddist and point < self.YPos then
								
								
								
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



	if mode == "upright" then
		
		for i,tile in pairs(GameMap.Tiles) do
		
		if not tile.Flags.IgnoreWall then
			
		
			local heightmap = tile.HeightMap

				

					
				
					local indexused = math.floor(tile.XPos - sensor[1] )
					
					if  heightmap[indexused] and heightmap[indexused] ~= 0 then
						
					
						
						local point = tile.XPos + indexused
						local ypoint

						if tile.Flags.Flipped then
							ypoint = tile.YPos - 16 + heightmap[indexused]
						else
							ypoint = tile.YPos - heightmap[indexused]
						end
						
						local dist
						
						
						dist =   sensor[1] - tile.XPos
						
						
						
					
						if  math.abs(dist) < olddist and sensor[2] >= ypoint and sensor[2] < tile.YPos  then
							
						
							
							
							
							olddist = dist
							foundtile = tile
							hmindex = indexused
							hmheight = heightmap[indexused]
						end
					end
			
			
			
		end
		
		end
		
		elseif mode == "rightwall" then

			for i,tile in pairs(GameMap.Tiles) do
		
				if not tile.Flags.IgnoreWall then
					
				
						
						
						
							local heightmap
						
							if tile.HorizontalMap then
								heightmap = tile.HorizontalMap
							else
								heightmap = tile.HeightMap
							end

							local indexused = math.floor( sensor[2] - tile.YPos)
							
							if  heightmap[indexused] and heightmap[indexused] ~= 0 then
								
							
								
								local point = tile.YPos - indexused
								local ypoint
		
								if tile.Flags.Flipped then
									ypoint = tile.XPos + 16 - heightmap[indexused]
								else
									ypoint = tile.XPos + heightmap[indexused]
								end
								
								local dist
								
								
								dist =   sensor[1] - tile.YPos
								
								
								
							
								if  math.abs(dist) < olddist and sensor[1] >= ypoint and sensor[1] < tile.XPos  then
									
								
									
									
									
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
	
	local yFactor = 5

	if self.GroundAngle == 0 and (self.State == "Grounded") then
		yFactor = -8

	elseif self.GroundAngle == 0 and (self.State == "Rolling") or self.State == "InAir" then
		yFactor = 0
	end

	if mode == "upright" then
		
		

		sensorE = {self.XPos+(self.XSpeed)-11, self.YPos-yFactor}
		sensorF = {self.XPos+(self.XSpeed)+11, self.YPos-yFactor}
		
		
		
	elseif mode == "rightwall" then
		sensorE = {self.XPos-yFactor, self.YPos-(self.YSpeed) - 11}
		sensorF = {self.XPos-yFactor, self.YPos-(self.YSpeed) + 11}
		
	elseif mode == "ceiling" then
	
	sensorE = {self.XPos + 10, self.YPos}
	sensorF = {self.XPos - 10, self.YPos}
	
	elseif mode == "leftwall" then
		
		sensorE = {self.XPos, self.YPos + 10}
		sensorF = {self.XPos, self.YPos - 10}
		
	end
	
	self.Debug.sensorE = sensorE
	self.Debug.sensorF = sensorF

	local sensor
	
	
	if sign(self.GroundSpeed) == -1 then
			sensor = sensorE
		else	
			sensor = sensorF
	end
	
	local detectedtile,dist,hmindex,hmheight = self:GetNearestWall(sensor,64,mode)
	
	
	
	if detectedtile then
		

				if dist < 0 then

				if mode == "upright" or mode == "ceiling" then
				self.XSpeed = 0
				else
				self.YSpeed = 0
				end

				self.GroundSpeed = 0
		
			
		  end

	end
	
	
end

function Player:CheckCanJump(dt)
	local sensorC
	local sensorD
	
	local mode = self.CollisionMode
	local ang = self.GroundAngle


	if mode == "upright" then
		sensorC = {self.XPos - self.WidthRadius, self.YPos - self.HeightRadius}
		sensorD = {self.XPos + self.WidthRadius, self.YPos - self.HeightRadius}
		

		elseif mode == "rightwall" then
		
		
		sensorC = {self.XPos - self.HeightRadius, self.YPos + self.WidthRadius}
		sensorD = {self.XPos - self.HeightRadius,self.YPos - self.WidthRadius}
		
		mode = "rightwall"
		
		elseif mode == "ceiling" then
		
	
		
		sensorC = {self.XPos - self.WidthRadius, self.YPos + self.HeightRadius}
		sensorD = {self.XPos + self.WidthRadius, self.YPos + self.HeightRadius}
		
		
		
		
		
		elseif 	mode == "leftwall" then
		
	
		sensorC = {self.XPos + self.HeightRadius, self.YPos + self.WidthRadius}
		sensorD = {self.XPos + self.HeightRadius,self.YPos - self.WidthRadius}
	
	
	end

	

	local ceiltile1,ceildist1,hmindex1,hmheight1,totaldist1 = self:GetNearestCeiling(sensorC,25,mode)
	local ceiltile2,ceildist2,hmindex2,hmheight2,totaldist2 = self:GetNearestCeiling(sensorD,25,mode)

	local winnertile,winnerdist,winnersensor,winnerh
	
	if ceiltile1 == nil and ceiltile2 then
		winnertile = ceiltile2
		winnerdist = ceildist2
		winnersensor = sensorB
		winnerh = hmheight2
		elseif ceiltile2 == nil and ceiltile1 then
		winnertile = ceiltile1
		winnerdist = ceildist1
		winnersensor = sensorA
		winnerh = hmheight1
		elseif ceiltile2 == nil and ceiltile1 == nil then
		
		
		winnersensor = nil
		winnertile = nil
		winnerdist = nil
		elseif ceiltile1 and ceiltile2 and ceildist1 > ceildist2 then
		winnertile = ceiltile2
		winnerdist = ceildist2
		winnersensor = sensorB
		winnerh = hmheight2
		elseif ceiltile1 and ceiltile2 and ceildist2 > ceildist1 then
		winnertile = ceiltile1
		winnerdist = ceildist1
		winnersensor = sensorA
		winnerh = hmheight1
		elseif ceiltile1 and ceiltile2 and ceildist1 == ceildist2 then
		
		if self.Facing == "Left" then
			winnertile = ceiltile1
		winnerdist = ceildist1
		winnersensor = sensorA
		winnerh = hmheight2
			
			else
			
			winnertile = ceiltile2
		winnerdist = ceildist2
		winnersensor = sensorB
		winnerh = hmheight2
		end
		
		
	end

	if winnerdist then
		return false
	else
		return true
	end
end

function Player:UpdateCeilingCollision(dt)
	local sensorC
	local sensorD
	
	local mode = self.CollisionMode
	local ang = self.GroundAngle


	if mode == "upright" then
		sensorC = {self.XPos - self.WidthRadius, self.YPos - self.HeightRadius}
		sensorD = {self.XPos + self.WidthRadius, self.YPos - self.HeightRadius}
		
		
		
		
		elseif mode == "rightwall" then
		
		
		sensorC = {self.XPos - self.HeightRadius, self.YPos + self.WidthRadius}
		sensorD = {self.XPos - self.HeightRadius,self.YPos - self.WidthRadius}
		
		mode = "rightwall"
		
		elseif mode == "ceiling" then
		
	
		
		sensorC = {self.XPos - self.WidthRadius, self.YPos + self.HeightRadius}
		sensorD = {self.XPos + self.WidthRadius, self.YPos + self.HeightRadius}
		
		
		
		
		
		elseif 	mode == "leftwall" then
		
	
		sensorC = {self.XPos + self.HeightRadius, self.YPos + self.WidthRadius}
		sensorD = {self.XPos + self.HeightRadius,self.YPos - self.WidthRadius}
	
	
	end
		
	self.Debug.sensorC = sensorC
	self.Debug.sensorD = sensorD

	local ceiltile1,ceildist1,hmindex1,hmheight1,totaldist1 = self:GetNearestCeiling(sensorC,32,mode)
	local ceiltile2,ceildist2,hmindex2,hmheight2,totaldist2 = self:GetNearestCeiling(sensorD,32,mode)

	local winnertile,winnerdist,winnersensor,winnerh
	
	if ceiltile1 == nil and ceiltile2 then
		winnertile = ceiltile2
		winnerdist = ceildist2
		winnersensor = sensorB
		winnerh = hmheight2
		elseif ceiltile2 == nil and ceiltile1 then
		winnertile = ceiltile1
		winnerdist = ceildist1
		winnersensor = sensorA
		winnerh = hmheight1
		elseif ceiltile2 == nil and ceiltile1 == nil then
		
		
		winnersensor = nil
		winnertile = nil
		winnerdist = nil
		elseif ceiltile1 and ceiltile2 and ceildist1 > ceildist2 then
		winnertile = ceiltile2
		winnerdist = ceildist2
		winnersensor = sensorB
		winnerh = hmheight2
		elseif ceiltile1 and ceiltile2 and ceildist2 > ceildist1 then
		winnertile = ceiltile1
		winnerdist = ceildist1
		winnersensor = sensorA
		winnerh = hmheight1
		elseif ceiltile1 and ceiltile2 and ceildist1 == ceildist2 then
		
		if self.Facing == "Left" then
			winnertile = ceiltile1
		winnerdist = ceildist1
		winnersensor = sensorA
		winnerh = hmheight2
			
			else
			
			winnertile = ceiltile2
		winnerdist = ceildist2
		winnersensor = sensorB
		winnerh = hmheight2
		end
		
		
	end
	
		local threshold = -(self.YSpeed+48)
		
		
		
			
				
				if winnerdist then
					print(winnerdist)
				
				end
				
				if winnerdist and winnerdist < 0 then
				
				self.YPos = self.YPos - winnerdist
				self.YSpeed = 0
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
	
		
		
		
		
		elseif mode == "rightwall" then
		
		sensorA = {self.XPos + self.HeightRadius, self.YPos + self.WidthRadius}
		sensorB = {self.XPos + self.HeightRadius,self.YPos - self.WidthRadius}
		
		
		
		
		elseif mode == "ceiling" then
		
		sensorA = {self.XPos - self.WidthRadius, self.YPos - self.HeightRadius}
		sensorB = {self.XPos + self.WidthRadius, self.YPos - self.HeightRadius}
		
	
		
		
		
		
		
		elseif 	mode == "leftwall"then
		
		sensorA = {self.XPos - self.HeightRadius, self.YPos + self.WidthRadius}
		sensorB = {self.XPos - self.HeightRadius,self.YPos - self.WidthRadius}
	
	
		
		
		
	end
		
		
	self.Debug.sensorA = sensorA
	self.Debug.sensorB = sensorB
	
	
	
	
	
	
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
	
	self.Debug.DebugTile = winnertile
	
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