Chunk = Object:extend()


function Chunk:new(XPos,YPos,ChunkProperties)
	self.XPos = XPos
	self.YPos = YPos
	self.Quad = ChunkProperties.Quad
end



return Chunk