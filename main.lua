

function love.load()
	love.graphics.setDefaultFilter("nearest","nearest")
	


	
	
	Object = require("Classes.classic")
	TileClass = require("Classes.Terrain.tile")
	ChunkClass = require("Classes.Terrain.chunk")
	BaseOBJ = require("Classes.Objects.baseobj")
	tick = require("Libraries.tick")
	characterList = require("Registry.Characters")
	SSheets = require("Registry.SpriteSheets")
	Levels = require("Registry.Levels")
	playerClass = require("Classes.Objects.player")
	Camera = require("Libraries.Camera")
	
	
	

	function LoadLevel(Level)
		local 	map = 
{
	Chunks = {};
	Tiles = {};
	LevelIndex = 1;
}
		for i,v in pairs(Levels) do
			if v.Name == Level.Name and v.Act == Level.Act then
				map.LevelIndex = i
			end
		end
	

		for cri = 1, #Level.ChunkMap do -- chunk row index
			chunkRow = Level.ChunkMap[cri]

			for ci = 1, #chunkRow do -- chunk index
				chunkId = chunkRow[ci]

				if chunkId ~= 0 then
					local FoundChunk = Level.ChunkSet[chunkId]
					assert(FoundChunk, "ChunkId "..chunkId.." is not defined for map "..Level.Name.." Act "..Level.Act)

					local newChunk = ChunkClass(256*(ci-1),256*cri,FoundChunk)
					table.insert(map.Chunks,newChunk)

					for rowindex = 1, #FoundChunk.Map do -- chunk
						local Row = FoundChunk.Map[rowindex]

						for tileIndex = 1, #Row do
							tileId = Row[tileIndex]

							if tileId ~= 0 then
								FoundTile = FoundChunk.TileSet[tileId]

								assert(FoundTile,"TileId "..tileId.." is not defined for chunk with id "..chunkId.." in map "..Level.Name.." Act "..Level.Act)

								local newtile = TileClass( (256*(ci-1))+(16*tileIndex),(256*cri)+(16*rowindex),tileId,chunkId,FoundTile)
								table.insert(map.Tiles,newtile)

							end

						end
				end
			end
			end
		end


		--[[for i = 1, #Level.Map do
			rows = Level.Map[i]
			
			for o = 1, #rows do
			
			id = rows[o]
			
			if id ~= 0 then
				FoundTile = Level.TileSet[id]
				
				assert(FoundTile,"TileId "..id.." is not defined for map "..Level.Name.." Act "..Level.Act)
				
				local newtile = TileClass(16*o,16*i,id,FoundTile)
				table.insert(map.Tiles,newtile)
			end
			
			end
			
			
		end--]]
		


		return map
	end

	GameMap = LoadLevel(Levels[1])
	
	cam = Camera()
	
	
	
	
	player = playerClass(9,20, characterList[1])
	
	player.XPos = 100
	player.YPos = 100
end


local TilesToDraw = {}
function love.update(dt)
	tick.update(dt)
	
	
	player:UpdateMovement(dt)
	player:UpdateAnimations(dt)
	player:UpdateWallCollision(dt)
	player:UpdateJump(dt)
	player:UpdateMotion(dt)
	player:UpdateCollision(dt)
	if player.State == "InAir" then
		player:UpdateCeilingCollision(dt)
	end

	player.TimeSinceLastFrame = player.TimeSinceLastFrame + dt
	
	if player.CurrentAnimation == "Walking" or player.CurrentAnimation == "Running" then
		player.FrameDelay = math.floor(math.max(0,8-math.abs(player.GroundSpeed))) / 60
		--player.FrameDelay = 1
		elseif player.CurrentAnimation == "Rolling" then
		
		player.FrameDelay = math.floor(math.max(0,4-math.abs(player.GroundSpeed))) / 60
	end
	
	if player.TimeSinceLastFrame >= player.FrameDelay then
		player.TimeSinceLastFrame = player.TimeSinceLastFrame - player.FrameDelay
		
		if player.CurrentAnimationFrame + 1 > player.Animations[player.CurrentAnimation].FrameCount then
			player.CurrentAnimationFrame = 1
			else
			player.CurrentAnimationFrame = player.CurrentAnimationFrame + 1
		end
		
		
	end
	
	
	
	cam:lookAt(player.XPos+love.graphics.getWidth()/4,player.YPos+player.HeightRadius+love.graphics.getHeight()/4,player.WidthRadius,player.HeightRadius)
	--cam:lookAt(player.XPos,player.YPos,player.WidthRadius,player.HeightRadius)
end

function love.draw()
	love.graphics.scale(2, 2)
	
	cam:attach()
	
	
	
	local CurrentAnim = player.Animations[player.CurrentAnimation]
	if player.Facing == "Right" then
	
	love.graphics.draw(CurrentAnim.SpriteSheet,CurrentAnim.Frames[player.CurrentAnimationFrame],player.XPos,player.YPos,-math.rad(player.ActualAngle),1,1,math.floor(CurrentAnim.FrameWidth/2),math.floor(CurrentAnim.FrameHeight/2))
	
	else
	love.graphics.draw(CurrentAnim.SpriteSheet,CurrentAnim.Frames[player.CurrentAnimationFrame],player.XPos,player.YPos,-math.rad(player.ActualAngle),-1,1,math.floor(CurrentAnim.FrameWidth/2),math.floor(CurrentAnim.FrameHeight/2))
	end
	

	
	
	
	local Image = SSheets[GameMap.LevelIndex]
	for i,v in pairs(GameMap.Chunks) do

	love.graphics.draw(Image,v.Quad,v.XPos,v.YPos,0,1,1,0,0)
	
	end
	
	
	
	if player.DebugTile then
		love.graphics.rectangle("line",player.DebugTile.XPos-16,player.DebugTile.YPos-16,16,16)
	end
	
		if player.CollisionMode == "upright" then
		love.graphics.points(player.XPos - player.WidthRadius, player.YPos + player.HeightRadius,player.XPos + player.WidthRadius, player.YPos + player.HeightRadius)
		love.graphics.points(player.XPos+player.XSpeed - 10, player.YPos,player.XPos+player.XSpeed + 10, player.YPos)
		love.graphics.points(player.XPos - player.WidthRadius, player.YPos - player.HeightRadius,player.XPos + player.WidthRadius, player.YPos - player.HeightRadius)
		elseif player.CollisionMode == "rightwall"  then
		
		love.graphics.points(player.XPos + player.HeightRadius, player.YPos + player.WidthRadius,player.XPos + player.HeightRadius, player.YPos - player.WidthRadius)
		
		elseif player.CollisionMode == "ceiling" then
		
		love.graphics.points(player.XPos - player.WidthRadius, player.YPos - player.HeightRadius,player.XPos + player.WidthRadius, player.YPos - player.HeightRadius)
		
		elseif player.CollisionMode == "leftwall" then
			love.graphics.points(player.XPos - player.HeightRadius, player.YPos + player.WidthRadius,player.XPos - player.HeightRadius, player.YPos - player.WidthRadius)
	end
	
	
	cam:detach()
	love.graphics.print("GroundAngle: "..player.GroundAngle,0,10)
	love.graphics.print("GroundSpeed: "..player.GroundSpeed,0,30)
	love.graphics.print("XPos: "..player.XPos,0,50)
	love.graphics.print("YPos: "..player.YPos,0,70)
end