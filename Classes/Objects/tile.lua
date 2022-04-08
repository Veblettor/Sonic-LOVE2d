Tile = Object:extend()


function Tile:new(XPos,YPos,TileId,ChunkId,TileProperties)
	self.XPos = XPos
	self.YPos = YPos
	self.HeightMap = TileProperties.HeightMap
	self.GroundAngle = TileProperties.GroundAngle or 0
	self.ChunkId = ChunkId
	self.TileId = TileId
	self.Quad = TileProperties.Quad
	self.CanCollide = true
	
	self.Flags = {}

	self.Flags.Flipped = TileProperties.Flipped or false

end



return Tile