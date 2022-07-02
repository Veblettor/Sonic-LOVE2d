



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
		
	
		
		

		
}




return Stages