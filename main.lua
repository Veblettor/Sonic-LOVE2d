

function love.load()
	love.graphics.setDefaultFilter("nearest","nearest")
	require("Libraries.math")
	Class = require("Classes.classic")
	Vector2 = require("Classes.DataTypes.vector2")
	
	Event = require("Classes.DataTypes.event")
	PriorityEvent = require("Classes.DataTypes.priorityEvent")


	Stages = require("Registry.Stages")
	TileClass = require("Classes.Terrain.tile")
	ChunkClass = require("Classes.Terrain.chunk")
	BaseOBJ = require("Classes.Objects.baseobj")
	Object = require("Classes.Objects.object")
	tick = require("Libraries.tick")
	characterList = require("Registry.Characters")
	
	
	playerClass = require("Classes.Objects.player")
	
	Camera = require("Classes.Objects.camera")--require("Libraries.gamera")
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
	
	CurrentCamera = Camera(Vector2(3585,1408),Vector2(0,0))--Camera.new(0,0,3585,1665)
	--sc = 1
	--cam:setScale(sc+1)
	
	local mountains = love.graphics.newImage("Assets/Sprites/mountains.png")
	local cities = love.graphics.newImage("Assets/Sprites/cities.png")
	local clouds = love.graphics.newImage("Assets/Sprites/clouds.png")
	
	local function DrawMountains()
		love.graphics.draw(mountains,0-(love.graphics.getWidth()/4),112+((love.graphics.getHeight()/4)-224*2),0,2,2)
	end
	
	local function DrawCities()
		love.graphics.draw(cities,0-(love.graphics.getWidth()/4),140+((love.graphics.getHeight()/4)-224*2),0,2,2)
		
	end
	
	local function DrawClouds()
		--[[local start = 0
		local minx,miny = love.graphics.inverseTransformPoint(0,0)
		local maxx,maxy = love.graphics.inverseTransformPoint(love.graphics:getDimensions())
		local dimsx,dimsy = clouds:getDimensions()
		--love.graphics.draw(clouds,0-(love.graphics.getWidth()/4),112+((love.graphics.getHeight()/4)-224*2),0,2,2)
		
		--local offset = math.floor(minx - start) / dimsx
		
		
		--start = start + (dimsx + offset)
		repeat
		love.graphics.draw(clouds,start,210+((love.graphics.getHeight()/4)-224*2),0,2,2)
		
        --love.graphics.rectangle('fill', start, 112+((love.graphics.getHeight()/4)-224*2), maxx, 50)
		
		start = start + dimsx*2
		until start > maxx--]]
		InfiniteDrawSingleAxis(clouds,Vector2(0,210+((love.graphics.getHeight()/4)-224*2)),"X",0,2,2)
	end
	
	local function DrawWorld()
		love.graphics.rectangle("line", CurrentCamera.Position.X-8,CurrentCamera.Position.Y-32,CurrentCamera.Radius.X,CurrentCamera.Radius.Y)
		local CurrentAnim = player.Animations[player.CurrentAnimation]
		if player.Facing == "Right" then
		
		love.graphics.draw(CurrentAnim.SpriteSheet,CurrentAnim.Frames[player.CurrentAnimationFrame],player.Position.X,player.Position.Y,-math.rad(player.DrawAngle),1,1,math.floor(CurrentAnim.FrameWidth/2),math.floor(CurrentAnim.FrameHeight/2))
		
		else
		love.graphics.draw(CurrentAnim.SpriteSheet,CurrentAnim.Frames[player.CurrentAnimationFrame],player.Position.X,player.Position.Y,-math.rad(player.DrawAngle),-1,1,math.floor(CurrentAnim.FrameWidth/2),math.floor(CurrentAnim.FrameHeight/2))
		end
		
	
		
		
	
		local Image = Stages[GameMap.LevelIndex].SpriteSheet
		for i,v in pairs(GameMap.Chunks) do
	
		
		local winDims = Vector2(love.graphics.getDimensions())
			
		local vec = CurrentCamera:WorldToScreen(Vector2(v.XPos,v.YPos))
		if vec.X <= winDims.X and vec.Y <= winDims.Y then
		love.graphics.draw(Image,v.Quad,v.XPos,v.YPos,0,1,1,0,0)
		end
	
		end
		
		
		
		if player.Debug.DebugTile then
			love.graphics.rectangle("line",player.Debug.DebugTile.XPos-16,player.Debug.DebugTile.YPos-16,16,16)
		end
		
		
	
			love.graphics.points(player.Debug.sensorA.X,player.Debug.sensorA.Y,player.Debug.sensorB.X,player.Debug.sensorB.Y,player.Debug.sensorC.X,player.Debug.sensorC.Y,player.Debug.sensorD.X,player.Debug.sensorD.Y,player.Debug.sensorWall.X,player.Debug.sensorWall.Y);
			
		end
		local MountainLayer = CurrentCamera:NewLayer(Vector2(0.1,0.05),-2,DrawMountains)
		local CityLayer = CurrentCamera:NewLayer(Vector2(0.25,0.1),-1,DrawCities)
		local CloudLayer = CurrentCamera:NewLayer(Vector2(1.25,0.35),1,DrawClouds)
		local GameplayLayer = CurrentCamera:NewLayer(Vector2(1,1),0,DrawWorld)
		
	
	
	player = playerClass(Vector2(128,256), characterList[1])
	CurrentCamera.Target = player
	CurrentCamera.Position = player.Position
	--GameplayLayer.OnDraw:Connect(DrawWorld)
	--MountainLayer.OnDraw:Connect(DrawMountains)
	player:UpdateStep(0)
	
end

function love.keypressed(key,scancode,isrepeat)
	if key == "return" then
		Paused = not Paused
	elseif key == "v" then
		Slowdown = not Slowdown
	elseif Paused and love.keyboard.isDown("f") then
	local mydt = 1/60
	CurrentCamera:Update(dt)
	--cam:setWindow(0,0,love.graphics.getWidth(),love.graphics.getHeight())
	if love.keyboard.isDown("=") then
	sc = math.min(2,sc+0.05)
	elseif love.keyboard.isDown("-") then
		sc = math.max(0.5,sc-0.05)
	elseif love.keyboard.isDown("0") then
		sc = 1
	end
	
	
	
	
	tick.update(mydt)
	

	player:UpdateStep(mydt)
	
	
	
	
	


	--cam:setScale(sc+1)
	end
end

local fps = 0
function love.update(dt)
	fps = fps + 1
	--cam:setWindow(0,0,love.graphics.getWidth(),love.graphics.getHeight())
	
	
		
	
	
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
	CurrentCamera:Update(dt)
	
	
	
	


	--cam:setScale(sc+1)
	--cam:lookAt(player.XPos+love.graphics.getWidth()/4,player.YPos+player.HeightRadius+love.graphics.getHeight()/4,player.WidthRadius,player.HeightRadius)
	--cam:lookAt(player.XPos,player.YPos,player.WidthRadius,player.HeightRadius)
end
end
end

function love.draw()
	--love.graphics.scale(2, 2)
	love.graphics.setBackgroundColor(0,0.5,0.5,1)

	
	

	
	
	CurrentCamera:Draw()
	
	love.graphics.print("GroundAngle: "..player.GroundAngle,0,10)
	love.graphics.print("GroundSpeed: "..player.GroundSpeed,0,30)
	love.graphics.print("Pos: "..tostring(player.Position),0,50)
	love.graphics.print("Spd: "..tostring(player.Speed),0,70)
	love.graphics.print("State: "..player.State,0,90)
	love.graphics.print("CamPos: "..tostring(CurrentCamera.Position),0,110)
end