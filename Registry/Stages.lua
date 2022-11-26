



Stages = 
{

	{
		StageID = "test";
		Name = "Test Zone";
		Act = 1;
		
		ChunkSize = 128;
		SpriteSheet = love.graphics.newImage("Assets/Sprites/Stages/testchunks.png");
		ChunkSet = require("Registry.ChunkSets.test");

		GetChunkLayout = function()
			
			

			return require("Registry.StageLayouts.testLayout")
		end
	

		};--]]

		{
			StageID = "ghz";
			Name = "Evergreen Hill Zone";
			Act = 1;
			
			ChunkSize = 256;
			SpriteSheet = love.graphics.newImage("Assets/Sprites/Stages/ghz.png");
			ChunkSet = require("Registry.ChunkSets.ghz");
	
			GetChunkLayout = function()
				
				
	
				return require("Registry.StageLayouts.GHZMap")
			end
		
	
			};--]]
		
	
		
		

		
}




return Stages