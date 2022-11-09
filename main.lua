

function love.load()
	love.graphics.setDefaultFilter("nearest","nearest")
	Object = require("Classes.classic")
	require("Libraries.math")
	
	Vector2 = require("Classes.DataTypes.vector2")

	Stages = require("Registry.Stages")
	TileClass = require("Classes.Terrain.tile")
	ChunkClass = require("Classes.Terrain.chunk")
	BaseOBJ = require("Classes.Objects.baseobj")
	tick = require("Libraries.tick")
	characterList = require("Registry.Characters")
	
	
	playerClass = require("Classes.Objects.player")
	
	Camera = require("Libraries.gamera")
	Misc = require("Libraries.misc")
	Paused = false
	Slowdown = false


	function LoadLevel(Level)
		local 	map = 
{
	Chunks = {};
	Tiles = {};
	LevelIndex = 1;
}
		for i,v in pairs(Stages) do
			if v.Name == Level.Name and v.Act == Level.Act then
				map.LevelIndex = i
			end
		end
	
		local ChunkMap = Level.GetChunkLayout()
		for cri = 1, #ChunkMap do -- chunk row index
			chunkRow = ChunkMap[cri]

			for ci = 1, #chunkRow do -- chunk index
				chunkId = chunkRow[ci]

				if chunkId ~= 0 then
					local FoundChunk = Level.ChunkSet[chunkId]
					assert(FoundChunk, "ChunkId "..chunkId.." is not defined for map "..Level.Name.." Act "..Level.Act)

					local newChunk = ChunkClass(Level.ChunkSize*(ci-1),Level.ChunkSize*cri,FoundChunk)
					table.insert(map.Chunks,newChunk)

					for rowindex = 1, #FoundChunk.Map do -- chunk
						local Row = FoundChunk.Map[rowindex]

						for tileIndex = 1, #Row do
							tileId = Row[tileIndex]

							if tileId ~= 0 then
								FoundTile = FoundChunk.TileSet[tileId]

								assert(FoundTile,"TileId "..tileId.." is not defined for chunk with id "..chunkId.." in map "..Level.Name.." Act "..Level.Act)

								local newtile = TileClass( (Level.ChunkSize*(ci-1))+(16*tileIndex),(Level.ChunkSize*cri)+(16*rowindex),tileId,chunkId,FoundTile)
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

	GameMap = LoadLevel(Stages[1])
	
	cam = Camera.new(0,0,3585,1665)
	sc = 1
	cam:setScale(sc+1)
	
	
	
	player = playerClass(9,20, characterList[1])
	
	player.XPos = 128
	player.YPos = 256
	player:UpdateStep(0)
end

function love.keypressed(key,scancode,isrepeat)
	if key == "return" then
		Paused = not Paused
	elseif key == "v" then
		Slowdown = not Slowdown
	elseif Paused and love.keyboard.isDown("f") then
	local mydt = 1/60
	cam:setWindow(0,0,love.graphics.getWidth(),love.graphics.getHeight())
	if love.keyboard.isDown("=") then
	sc = math.min(2,sc+0.05)
	elseif love.keyboard.isDown("-") then
		sc = math.max(0.5,sc-0.05)
	elseif love.keyboard.isDown("0") then
		sc = 1
	end
	
	
	
	
	tick.update(mydt)
	

	player:UpdateStep(mydt)
	
	
	
	
	


	cam:setScale(sc+1)
	end
end

local fps = 0
function love.update(dt)
	fps = fps + 1
	cam:setWindow(0,0,love.graphics.getWidth(),love.graphics.getHeight())
	
	
		
	
	
	if not Paused then
	
	if love.keyboard.isDown("=") then
	sc = math.min(2,sc+0.05)
	elseif love.keyboard.isDown("-") then
		sc = math.max(0.5,sc-0.05)
	elseif love.keyboard.isDown("0") then
		sc = 1
	end
	
	if not Slowdown or fps % 4 == 0 then
	
	
	tick.update(dt)
	

	player:UpdateStep(dt)
	
	
	
	
	


	cam:setScale(sc+1)
	--cam:lookAt(player.XPos+love.graphics.getWidth()/4,player.YPos+player.HeightRadius+love.graphics.getHeight()/4,player.WidthRadius,player.HeightRadius)
	--cam:lookAt(player.XPos,player.YPos,player.WidthRadius,player.HeightRadius)
end
end
end

function love.draw()
	--love.graphics.scale(2, 2)
	love.graphics.setBackgroundColor(0,0.5,0.5,1)

	
	
	local function DrawWorld(left,top,width,height)
		local CurrentAnim = player.Animations[player.CurrentAnimation]
	if player.Facing == "Right" then
	
	love.graphics.draw(CurrentAnim.SpriteSheet,CurrentAnim.Frames[player.CurrentAnimationFrame],player.XPos,player.YPos,-math.rad(player.DrawAngle),1,1,math.floor(CurrentAnim.FrameWidth/2),math.floor(CurrentAnim.FrameHeight/2))
	
	else
	love.graphics.draw(CurrentAnim.SpriteSheet,CurrentAnim.Frames[player.CurrentAnimationFrame],player.XPos,player.YPos,-math.rad(player.DrawAngle),-1,1,math.floor(CurrentAnim.FrameWidth/2),math.floor(CurrentAnim.FrameHeight/2))
	end
	

	
	
	
	local Image = Stages[GameMap.LevelIndex].SpriteSheet
	for i,v in pairs(GameMap.Chunks) do

	love.graphics.draw(Image,v.Quad,v.XPos,v.YPos,0,1,1,0,0)
	
	end
	
	
	
	if player.Debug.DebugTile then
		love.graphics.rectangle("line",player.Debug.DebugTile.XPos-16,player.Debug.DebugTile.YPos-16,16,16)
	end
	
	

		love.graphics.points(player.Debug.sensorA[1],player.Debug.sensorA[2],player.Debug.sensorB[1],player.Debug.sensorB[2],player.Debug.sensorC[1],player.Debug.sensorC[2],player.Debug.sensorD[1],player.Debug.sensorD[2],player.Debug.sensorWall[1],player.Debug.sensorWall[2]);
		
	end
	
	
	cam:draw(DrawWorld)
	
	love.graphics.print("GroundAngle: "..player.GroundAngle,0,10)
	love.graphics.print("GroundSpeed: "..player.GroundSpeed,0,30)
	love.graphics.print("XPos: "..player.XPos,0,50)
	love.graphics.print("YPos: "..player.YPos,0,70)
	love.graphics.print("XSpd: "..player.XSpeed,0,90)
	love.graphics.print("YSpd: "..player.YSpeed,0,110)
	love.graphics.print("State: "..player.State,0,130)
	
end