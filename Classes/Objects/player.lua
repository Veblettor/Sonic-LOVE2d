
local Player = BaseOBJ:extend()


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
		sensorWall = {0,0};
		DebugTile = nil;
	}

	self.State = "InAir"
	self.Facing = "Right"
	self.ChangeCD = 0
	self.ControlLock = 0
	self.CurrentAnimation = "Idle"
	self.CurrentAnimationFrame = 1
	self.TimeSinceLastFrame = 0
	self.FrameDelay = 0.1
	self.CollisionMode = "upright"
	self.HoldingJump = false
	self.GroundSpeed = 0

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





function Player:UpdateCollisionMode()

local mode
	
if self.State ~= "InAir" and self.ChangeCD <= 0 then
	
	local ang = self.GroundAngle
	
	if math.sign(ang) == -1 then
		ang = 360 + ang
	end
	


	if ang < 46 then
		mode = "upright"
	elseif ang > 45 and ang < 135 then
		mode = "rightwall"
	elseif ang > 134 and ang < 226 then
		mode = "ceiling"
	elseif ang > 225 and ang < 315 then
		mode = "leftwall"
	elseif ang > 314 then		
		mode = "upright"
	end
	
	if mode ~= self.CollisionMode then
		--self.ChangeCD = 10
	end	
elseif self.ChangeCD <= 0 then
	mode = "upright"
end	
		
	if mode then
	self.CollisionMode = mode
	end
	
	
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
	
	if self.CurrentAnimation == "Rolling" then
		self.WidthRadius = self.RollWidth
		self.HeightRadius = self.RollHeight
		
	else
		self.WidthRadius = self.BaseWidth
		self.HeightRadius = self.BaseHeight
		
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

function Player:UpdateSlpFactor(dt)
	
	if self.CollisionMode and self.CollisionMode ~= "ceiling" and self.GroundSpeed ~= 0 then
		if self.State == "Rolling" then
			if math.sign(self.GroundSpeed) == math.sign(self.GroundAngle) then
				self.GroundSpeed = self.GroundSpeed - self.Slprollup*math.sin(math.rad(self.GroundAngle))
				else
				self.GroundSpeed = self.GroundSpeed - self.Slprolldown*math.sin(math.rad(self.GroundAngle))
			end
		elseif self.CollisionMode then
			self.GroundSpeed = self.GroundSpeed - self.Slp*math.sin(math.rad(self.GroundAngle))
		end
	end
end

function Player:ManageControlLock()
	if self.ControlLock == 0 then
		
				local ang = self.GroundAngle
				
				if math.sign(ang) == -1 then ang = 360 + ang end
		
				if math.abs(self.GroundSpeed) < 2.5 and ang > 34 and ang < 327 then
					
					
					
					self.ControlLock = 30
					
					if ang > 68 and ang < 294 then
						self.State = "InAir"
						else
						
						if ang < 180 then
							self.GroundSpeed = self.GroundSpeed - 0.5
						else
							self.GroundSpeed = self.GroundSpeed + 0.5
						end
					
					end
					
					
					
				end
			elseif self.ControlLock > 0 then
			self.ControlLock = self.ControlLock - 1
			if self.ControlLock < 0 then self.ControlLock = 0 end
		end
end

function Player:UpdateMovement(dt)
	--print(self.GroundSpeed)
	if self.State == "Grounded" then
		
		if love.keyboard.isDown("a") then
	
		self.Facing = "Left"
	
		if self.ControlLock == 0 then
		
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
		end
	
	
		elseif love.keyboard.isDown("d") then
		
		self.Facing = "Right"
		
		if self.ControlLock == 0 then
		
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
		
		end
		
		
		else
		
		
		
		
		if self.GroundSpeed ~= 0 then
		self.GroundSpeed = self.GroundSpeed - math.min(math.abs(self.GroundSpeed),self.Frc) * math.sign(self.GroundSpeed)
		end
	end
	
	if love.keyboard.isDown("s") then
		
		if math.abs(self.XSpeed) >= 1 then
			
			self.State = "Rolling"
			
			self:UpdateAnimations(dt)
			
		
		end
	end
	
	elseif self.State == "InAir" then
		
		
	
		if love.keyboard.isDown("a") then
	
			self.Facing = "Left"
			
			if self.ControlLock == 0 then
			
			if (self.XSpeed > -self.Top) then
			
			self.XSpeed = self.XSpeed - self.Air
			--self.GroundSpeed = self.GroundSpeed - self.Air

		

			if self.XSpeed <= -self.Top then
				self.XSpeed = -self.Top
			end
			
			--self.GroundSpeed = self.XSpeed

		end
	
		end
	
		elseif love.keyboard.isDown("d") then
		
			self.Facing = "Right"
			
			if self.ControlLock == 0 then
			
			if (self.GroundSpeed < self.Top) then
			
			self.XSpeed = self.XSpeed + self.Air
			

			if self.GroundSpeed >= self.Top then
				--self.GroundSpeed = self.Top
			end

			if self.XSpeed >= self.Top then
				self.XSpeed = self.Top
			end
			
			--self.GroundSpeed = self.XSpeed

			end

			end

	end
	
	
	elseif self.State == "Rolling" then
		
	
	
	self.GroundSpeed = self.GroundSpeed - math.min(math.abs(self.GroundSpeed),self.Frc/2) * math.sign(self.GroundSpeed)
	
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

function Player:DebugControls(dt)

if love.keyboard.isDown("z") then
self.XPos = 128
self.YPos = 256
end

if love.keyboard.isDown("x") then
self.GroundSpeed = 18
end

if love.keyboard.isDown("c") then
self.YSpeed = self.YSpeed - 0.33
end

end

function Player:SnapToNearest90Degrees()
	
	local ang = self.GroundAngle
	if math.sign(ang) == 1 then

	if ang < 46 or ang >= 315 then
		self.GroundAngle = 0
		
		elseif ang >= 46 and ang < 135 then
		
		self.GroundAngle = 90
		
		
		
		elseif ang >= 135 and ang < 225 then
		
		self.GroundAngle = 180
		
		elseif ang >= 225 and ang < 315 then
		
		self.GroundAngle = 270
		
	end
else
	if ang > -46 or ang <= -315 then
		self.GroundAngle = 0
	elseif ang <= -46 and ang > -135 then
		self.GroundAngle = -90
		

	elseif ang <= -135 and ang > -255 then
		self.GroundAngle = -180
		

	elseif ang <= -255 and ang > -315 then
		self.GroundAngle = -270
		
	end
end

if math.sign(self.TargetDrawAngle) == 1 and math.sign(self.GroundAngle) == -1 then
	self.TargetDrawAngle = 360 + self.GroundAngle
elseif math.sign(self.TargetDrawAngle) == -1 and math.sign(self.GroundAngle) == 1 then
	self.TargetDrawAngle = self.GroundAngle - 360
else
	self.TargetDrawAngle = self.GroundAngle
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
							
							point = tile.YPos - 15
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

				local heightmap
				if tile.HorizontalMap then
					heightmap = tile.HorizontalMap
				else
					heightmap = tile.HeightMap
				end
				

				if heightmap[ogheightindex] ~= 0 then
					local point

					if tile.Flags.FlippedHorizontal then
						point = tile.XPos - 15
						else
						point = tile.XPos - heightmap[ogheightindex]
					end

					local dist = point - sensor[1]

					ftile = tile
					rdist = dist
				end

			end

		end
	elseif mode == "ceiling" then
		
		for i,tile in pairs(GameMap.Tiles) do
			if tile.XPos == ogtile.XPos and tile.YPos == ogtile.YPos + 16 then
				
				local ohi = ogheightindex

				
				local heightmap = tile.HeightMap
				
				if heightmap[ohi] ~= 0 then
					
					local point
					
					if tile.Flags.Flipped then
						
						point = tile.YPos-(16-heightmap[ohi])
				
					else
						point = tile.YPos
					end
					
					local dist = sensor[2] - point 

					ftile = tile
					rdist = dist
						
					
				end
				
			end
		end

	elseif mode == "leftwall" then

		for i,tile in pairs(GameMap.Tiles) do
			if tile.XPos == ogtile.XPos + 16 and tile.YPos == ogtile.YPos then
				
		
				
				
				local heightmap
				if tile.HorizontalMap then
					heightmap = tile.HorizontalMap
				else
					heightmap = tile.HeightMap
				end

				if heightmap[ohi] ~= 0 then
					
					local point
					
					if tile.Flags.FlippedHorizontal then
						
						point = tile.XPos-(16-heightmap[ogheightindex])
					else
						point = tile.XPos
					end
					
					local dist = sensor[1] - point 

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
local olddist2 = olddist
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
						
						point = tile.YPos - 15
						else
						point = tile.YPos - heightmap[indexused]
					end
					
					local dist =  point - sensor[2]
					local dist2 =  point - self.YPos
					--math.abs(dist) < olddist
					if math.abs(dist2) < olddist2  and point > self.YPos then
						
						
						
						olddist = dist
						olddist2 = dist2
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
				
				if tile.Flags.FlippedHorizontal then
					point = tile.XPos - 15
				else
					point = tile.XPos - heightmap[indexused]
				end
				
				local dist = point - sensor[1]
				local dist2 =  point - self.XPos

				if math.abs(dist2) < olddist2 and point > self.XPos then
					olddist = dist
					olddist2 = dist2
					foundtile = tile
					hmindex = indexused
					hmheight = heightmap[indexused]
				end
			end
		end
			
		
		elseif mode == "ceiling" then
		
		
			for i,tile in pairs(GameMap.Tiles) do
		
				if  not  (self.YSpeed < 0 and tile.Flags.IgnoreCeiling) then
					
					local heightmap = tile.HeightMap
				
					local indexused = math.floor(tile.XPos - sensor[1])
					
					

					if  heightmap[indexused] and heightmap[indexused] ~= 0 then
						
						local point
						
						if tile.Flags.Flipped then
							
							point = tile.YPos-(16-heightmap[indexused])
							else
							point = tile.YPos
							

							
						end
						
						local dist =  sensor[2] - point
					
						if  math.abs(dist) < olddist and point < self.YPos then
							
							
							
							olddist = dist
							foundtile = tile
							hmindex = indexused
							hmheight = heightmap[indexused]
						end
					end
					
				end
			
			end
		
		
		
		elseif mode == "leftwall" then
		
		
			for i,tile in pairs(GameMap.Tiles) do
		
				
					
				local heightmap 
				if tile.HorizontalMap then
					heightmap = tile.HorizontalMap
				else
					heightmap = tile.HeightMap
				end
				
					local indexused = math.floor(tile.YPos - sensor[2])
					
					
					if  heightmap[indexused] and heightmap[indexused] ~= 0 then
						
						local point
						
						if tile.Flags.FlippedHorizontal then
							
							point = tile.XPos-(16-heightmap[indexused])
							else
							point = tile.XPos
							
							

							
						end
						
						local dist =  sensor[1] - point
					
						if  math.abs(dist) < olddist then
							
							
							
							olddist = dist
							foundtile = tile
							hmindex = indexused
							hmheight = heightmap[indexused]
						end
					end
					
				
			
			end
			
		
		end
		

		
	
	
	
	if not foundtile then return nil,nil,nil,nil end
	if foundtile then return foundtile,olddist,hmindex,hmheight end
end





function Player:GetNearestWall(sensor,maxdist,mode,facing)
local foundtile
local olddist = maxdist + 1
local hmindex
local hmheight


	if mode == "upright" or mode == "ceiling" then
	
	
	
		
			for i,tile in pairs(GameMap.Tiles) do
				if not tile.Flags.IgnoreWall then
					local heightmap 
					if tile.HorizontalMap then
						heightmap = tile.HorizontalMap
					else
						heightmap = tile.HeightMap
					end
				
	
					local indexused = math.floor(tile.YPos - sensor[2])
					
				

					if heightmap[indexused] and heightmap[indexused] ~= 0 then
					
							if tile.Flags.FlippedHorizontal then
								if facing == "Right" then
									point = tile.XPos - 15
								else
									point = tile.XPos-(15-heightmap[indexused])
								end
						else
							if facing == "Right" then
								point = tile.XPos - heightmap[indexused]
							else
								point = tile.XPos
							end
						end
					
						local dist = point - sensor[1]
						
						if facing == "Left" then
							dist = sensor[1] - point
						end

						local touse = self.BaseHeight
						local touse2 = self.BaseWidth
						if self.CurrentAnimation == "Rolling" then
							touse = self.RollHeight
							touse2 = self.RollWidth
						end

						if math.abs(dist) < olddist and ((facing == "Right" and point > self.XPos-touse2) or (facing == "Left" and point < self.XPos+touse2))  and tile.YPos < self.YPos+touse then
							olddist = dist
							foundtile = tile
							hmindex = indexused
							hmheight = heightmap[indexused]
						end
					end
				end

			
		end

	elseif mode == "rightwall" or mode == "leftwall" then

		

	end
		
	return foundtile,olddist,hmindex,hmheight
end


function Player.UpdateWallCollision(self,dt)
	local sensorE
	local sensorF
	local newgrnd = self.GroundSpeed
	local mode = self.CollisionMode
	
	local yFactor = 0

	if self.GroundAngle == 0 and (self.State == "Grounded" or self.State == "Rolling") then
		yFactor = 8
	end

	
	local addy = self.YSpeed
	local addx = self.XSpeed
	
	if self.State == "InAir" then
		addy = 0
		addx = 0
	end

	if mode == "upright" then
		
		

		sensorE = {self.XPos+addx-11, self.YPos+addy+yFactor}
		sensorF = {self.XPos+addx+11, self.YPos+addy+yFactor}
		
		
		
	elseif mode == "rightwall" then
		sensorE = {self.XPos+addx+yFactor, self.YPos+addy - 11}
		sensorF = {self.XPos+addx+yFactor, self.YPos+addy + 11}
		
	elseif mode == "ceiling" then
	
	sensorE = {self.XPos+addx + 11, self.YPos+addy-yFactor}
	sensorF = {self.XPos+addx - 11, self.YPos+addy-yFactor}
	
	elseif mode == "leftwall" then
		
		sensorE = {self.XPos+addx+yFactor, self.YPos+addy + 11}
		sensorF = {self.XPos+addx+yFactor, self.YPos+addy + 11}
		
	end

	self.Debug.sensorE = sensorE
	self.Debug.sensorF = sensorF

	local sensor
	
	local face = "Left"
	if self.State ~= "InAir" then
	
		if math.sign(self.GroundSpeed) == -1 then
			sensor = sensorE
		else	
			sensor = sensorF
			face = "Right"
		end
	else

	if mode == "upright" or mode == "ceiling" then
		if math.sign(self.XSpeed) == -1 then
			sensor = sensorE
		else	
			sensor = sensorF
			face = "Right"
		end
	else
		if math.sign(self.YSpeed) == -1 then
			sensor = sensorE
		else	
			sensor = sensorF
			face = "Right"
		end
	end
end
	self.Debug.sensorWall = sensor
	local detectedtile,dist,hmindex,hmheight = self:GetNearestWall(sensor,32,mode,face)
	
	
	
	if detectedtile then
		
		--self.Debug.DebugTile = detectedtile
		
		
			
		
		  
		
		

			if dist <= 0 then
			
				
				if mode == "upright" or mode == "ceiling" then
					newgrnd = 0
					if self.State == "InAir" then
						if math.sign(self.XSpeed) == -1 then
							self.XPos =  self.XPos - dist
						else
							self.XPos =  self.XPos +  dist
						end
					else
						if math.sign(self.GroundSpeed) == -1 then
						
						self.XSpeed = self.XSpeed + dist
						else
						
						self.XSpeed = self.XSpeed - dist
						end
					end
					

					newgrnd = 0
					
					--self.XSpeed = 0
				else
				
					if self.State == "InAir" then
						if math.sign(self.YSpeed) == -1 then
							self.YPos =  self.YPos - dist
						else
							self.YPos =  self.YPos +  dist
						end
					else
						if math.sign(self.GroundSpeed) == -1 then
							self.YPos =  self.YPos + (self.YSpeed - dist)
						else
							self.YPos =  self.YPos + (self.YSpeed + dist)
						end
					end
					
					
					self.YSpeed = 0
					
			 	end

				 
				 newgrnd = 0
				
			end
		end
	
	
	self.GroundSpeed = newgrnd
	
end

function Player:CheckCanJump(dt)
	local sensorC
	local sensorD
	
	local mode = self.CollisionMode
	local ang = self.GroundAngle


	local flippedmode = "ceiling"

	if mode == "upright" then
		sensorC = {self.XPos - self.WidthRadius, self.YPos - self.HeightRadius}
		sensorD = {self.XPos + self.WidthRadius, self.YPos - self.HeightRadius}
		
		
		
		
		elseif mode == "rightwall" then
		
		
		sensorC = {self.XPos - self.HeightRadius, self.YPos + self.WidthRadius}
		sensorD = {self.XPos - self.HeightRadius,self.YPos - self.WidthRadius}
		
		flippedmode = "leftwall"
		
		elseif mode == "ceiling" then
		
	
		
		sensorC = {self.XPos - self.WidthRadius, self.YPos + self.HeightRadius}
		sensorD = {self.XPos + self.WidthRadius, self.YPos + self.HeightRadius}
		
		flippedmode = "upright"
		
		
		
		elseif 	mode == "leftwall" then
		
	
		sensorC = {self.XPos + self.HeightRadius, self.YPos + self.WidthRadius}
		sensorD = {self.XPos + self.HeightRadius,self.YPos - self.WidthRadius}
	
		flippedmode = "rightwall"
	end
	

	local ceiltile1,ceildist1,hmindex1,hmheight1,totaldist1 = self:GetNearestFloor(sensorC,25,flippedmode)
	local ceiltile2,ceildist2,hmindex2,hmheight2,totaldist2 = self:GetNearestFloor(sensorD,25,flippedmode)

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
	local flippedmode = "ceiling"

	if mode == "upright" then
		sensorC = {self.XPos - self.WidthRadius, self.YPos - self.HeightRadius}
		sensorD = {self.XPos + self.WidthRadius, self.YPos - self.HeightRadius}
		
		
		
		
		elseif mode == "rightwall" then
		
		
		sensorC = {self.XPos - self.HeightRadius, self.YPos + self.WidthRadius}
		sensorD = {self.XPos - self.HeightRadius,self.YPos - self.WidthRadius}
		
		flippedmode = "leftwall"
		
		elseif mode == "ceiling" then
		
	
		
		sensorC = {self.XPos - self.WidthRadius, self.YPos + self.HeightRadius}
		sensorD = {self.XPos + self.WidthRadius, self.YPos + self.HeightRadius}
		
		flippedmode = "upright"
		
		
		
		elseif 	mode == "leftwall" then
		
	
		sensorC = {self.XPos + self.HeightRadius, self.YPos + self.WidthRadius}
		sensorD = {self.XPos + self.HeightRadius,self.YPos - self.WidthRadius}
	
		flippedmode = "rightwall"
	end
		
	self.Debug.sensorC = sensorC
	self.Debug.sensorD = sensorD

	local ceiltile1,ceildist1,hmindex1,hmheight1,totaldist1 = self:GetNearestFloor(sensorC,16,flippedmode)
	local ceiltile2,ceildist2,hmindex2,hmheight2,totaldist2 = self:GetNearestFloor(sensorD,16,flippedmode)

	local winnertile,winnerdist,winnersensor,winnerh
	
	if hmheight1 == 16 then
		local newtile,newdist = self:RegressTile(sensorC,flippedmode,ceiltile1,hmindex1)
		
		if newtile then
			ceiltile1 = newtile
			ceildist1 = newdist
			totaldist1 = newdist
		end
	end
	
	if hmheight2 == 16 then
		local newtile,newdist = self:RegressTile(sensorD,flippedmode,ceiltile2,hmindex2)
		
		if newtile then
			ceiltile2 = newtile
			ceildist2 = newdist
			totaldist2= newdist
		end
	end

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
					--self.Debug.DebugTile = winnertile
				
				end
				
				if winnerdist and winnerdist < 0 then
				if mode == "upright" or mode == "ceiling" then
					self.YSpeed = 0
				else
					self.XSpeed = 0
				end

				if mode == "upright" then
					self.YPos = self.YPos - winnerdist
				elseif mode == "ceiling" then
					self.YPos = self.YPos + winnerdist
				elseif mode == "rightwall" then
					self.XPos = self.XPos - winnerdist
				elseif mode == "leftwall" then
					self.XPos = self.XPos + winnerdist
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
	
		
		
		
		
		elseif mode == "rightwall" then
		
		sensorA = {self.XPos + self.HeightRadius, self.YPos + self.WidthRadius}
		sensorB = {self.XPos + self.HeightRadius,self.YPos - self.WidthRadius}
		
		
		
		
		elseif mode == "ceiling" then
		
		sensorA = {self.XPos + self.WidthRadius, self.YPos - self.HeightRadius}
		sensorB = {self.XPos - self.WidthRadius, self.YPos - self.HeightRadius}
		
	
		
		
		
		
		
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
	
	
	

	if self.State == "InAir" then
	
	
		
		
		
		if winnertile then
		
				if winnerdist then
			--print(winnerdist)
			--print('th: '..threshold)
		end
		
		if winnerdist <= 0 then
			
			local moving = "horizontal"

			if math.sign(self.YSpeed) == 1 and math.abs(self.YSpeed) > math.abs(self.XSpeed) then
				moving = "down"
			elseif math.abs(self.YSpeed) < math.abs(self.XSpeed) then
				moving = "horizontal"
			elseif math.sign(self.YSpeed) == -1 and math.abs(self.YSpeed) > math.abs(self.XSpeed) then
				moving = "up"
			end

			if (moving == "down" and winnerdist >= -(self.YSpeed+8)) or ((moving == "horizontal" and self.YSpeed >= 0))  then
			--	print(moving)
			--	print(winnerdist)
			--	print(-(self.YSpeed+8))
				if not winnertile.GroundAngle or winnertile.GroundAngle == 0 then
					--self:SnapToNearest90Degrees()
					self.GroundAngle = 0
					else
					
					self.GroundAngle = winnertile.GroundAngle
					self.TargetDrawAngle = winnertile.GroundAngle
					
				end
					
				local absangle = math.abs(self.GroundAngle)
				if (absangle <= 23) or (absangle > 338 and absangle < 361) then
					self.GroundSpeed = self.XSpeed
				elseif (absangle > 23 and absangle < 46) or (absangle > 270 and absangle < 315) then
					if moving == "horizontal" then
						self.GroundSpeed = self.XSpeed
					else
						self.GroundSpeed = self.YSpeed * 0.5 * -(math.sign(math.sin(math.rad(self.GroundAngle))))
					end
				elseif (absangle > 45 and absangle < 91) or (absangle > 271 and absangle < 315) then
					if moving == "horizontal" then
						self.GroundSpeed = self.XSpeed
					else
						
						self.GroundSpeed = self.YSpeed * -(math.sign(math.sin(math.rad(self.GroundAngle))))
						
					end
				end
					
					self.YPos = self.YPos + winnerdist
					local anim = self.CurrentAnimation
					self.State = "Grounded"
					self:UpdateAnimations(dt)
					
					if anim == "Rolling" then
					self.YPos = self.YPos - 5
					end
			end

		end
		
		end
		
		elseif self.State == "Grounded" or self.State == "Rolling" then
		
		if not winnertile then
			self.State = "InAir"
			
			else
				self.Debug.DebugTile = winnertile
				
				local calc

				if mode == "upright" or mode == "ceiling" then
					--calc = (winnerdist < math.min(math.abs(self.XSpeed)+4,14) and winnerdist > -14)
					calc = winnerdist < 14 and winnerdist > -14
				else
					--calc = (winnerdist < math.min(math.abs(self.YSpeed)+4,14) and winnerdist > -14)
					calc = winnerdist < 14 and winnerdist > -14
				end

			if calc then
			
			
			
			if mode == "upright" then
			
				self.YPos = self.YPos + winnerdist
			
			elseif mode == "rightwall" then
			
 				self.XPos = self.XPos + winnerdist

			elseif mode == "ceiling" then

				self.YPos = self.YPos - winnerdist
			
			elseif mode == "leftwall" then
				self.XPos = self.XPos - winnerdist
			end
			
			local calcangle

			--[[if math.sign(self.GroundAngle) == 1 and math.sign(winnertile.GroundAngle) == -1 then
				calcangle = 360 + winnertile.GroundAngle
			elseif math.sign(self.GroundAngle) == -1 and math.sign(winnertile.GroundAngle) == 1 then
				calcangle = winnertile.GroundAngle - 360
			else
				calcangle = winnertile.GroundAngle
			end--]]

			if  math.sign(winnertile.GroundAngle) == -1 then
				calcangle = 360 + winnertile.GroundAngle
			else
				calcangle = winnertile.GroundAngle
			end

			if not winnertile.GroundAngle or winnertile.GroundAngle == 0 then
				self:SnapToNearest90Degrees()
				
				else
				
				self.GroundAngle = winnertile.GroundAngle
				
				if math.sign(self.TargetDrawAngle) == 1 and math.sign(winnertile.GroundAngle) == -1 then
					self.TargetDrawAngle = 360 + winnertile.GroundAngle
				elseif math.sign(self.TargetDrawAngle) == -1 and math.sign(winnertile.GroundAngle) == 1 then
					self.TargetDrawAngle = winnertile.GroundAngle - 360
				else
					self.TargetDrawAngle = self.GroundAngle
				end
				
				
			end

			else
			
			self.State = "InAir"
			
			end
		
		end
		
		
		
	end
	
end


function Player:UpdateStep(dt)
	if self.ChangeCD > 0 then self.ChangeCD = self.ChangeCD - 1 end
	self:DebugControls()
	self:UpdateAnimations()
	self:UpdateCollisionMode()
	if not self.GroundSpeed then self.GroundSpeed = 0 end
	if self.State == "Grounded" or self.State == "Rolling" then
	if self.GroundSpeed > 16 then self.GroundSpeed = 16 end
		self:UpdateSlpFactor(dt)
		self:UpdateJump(dt)
		self:UpdateMovement(dt)
		
		self.UpdateWallCollision(self,dt)
		--print(new)
		
		cam:setPosition(self.XPos,self.YPos)
		self:UpdateMotion(dt,self.GroundSpeed)
		self:ManageControlLock()
		self:UpdateCollision(dt)
	elseif self.State == "InAir" then
		self:UpdateJump(dt)
		self:UpdateMovement(dt)
		self:UpdateMotion(dt,self.GroundSpeed)
		
		self:UpdateWallCollision(dt)
		if math.abs(self.XSpeed) >= math.abs(self.YSpeed) then
			if self.XSpeed > 0 then
				--  mostly right
				self:UpdateCollision(dt)
				self:UpdateCeilingCollision(dt)
				
			else
				-- mostly left
				self:UpdateCollision(dt)
				self:UpdateCeilingCollision(dt)
				
			end

		else
			if self.YSpeed > 0 then
				--mostly down
				self:UpdateCollision(dt)
			else
				-- mostly up
				self:UpdateCeilingCollision(dt)
			end
			
		end
		cam:setPosition(self.XPos,self.YPos)
		
	end
	
	
	
	

	self.TimeSinceLastFrame = self.TimeSinceLastFrame + dt
	
	if self.CurrentAnimation == "Walking" or self.CurrentAnimation == "Running" then
		self.FrameDelay = math.floor(math.max(0,8-math.abs(self.GroundSpeed))) / 60
		--player.FrameDelay = 1
		elseif self.CurrentAnimation == "Rolling" then
		
			self.FrameDelay = math.floor(math.max(0,4-math.abs(self.GroundSpeed))) / 60
	end
	
	if self.TimeSinceLastFrame >= self.FrameDelay then
		self.TimeSinceLastFrame = self.TimeSinceLastFrame - self.FrameDelay
		
		if self.CurrentAnimationFrame + 1 > self.Animations[self.CurrentAnimation].FrameCount then
			self.CurrentAnimationFrame = 1
			else
			self.CurrentAnimationFrame = self.CurrentAnimationFrame + 1
		end
		
		
	end
end



return Player