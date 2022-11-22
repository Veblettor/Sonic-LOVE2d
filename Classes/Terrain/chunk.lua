Chunk = Class:extend()
require("Libraries.misc")

function Chunk:new(XPos,YPos,ChunkProperties)
	self.XPos = XPos
	self.YPos = YPos
	local stage = GetStageById(ChunkProperties.StageID)
	
	self.Quad = love.graphics.newQuad(ChunkProperties.ChunkX,ChunkProperties.ChunkY,stage.ChunkSize,stage.ChunkSize,stage.SpriteSheet:getDimensions())
end



return Chunk