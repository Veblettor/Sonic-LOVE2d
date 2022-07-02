Tile = Object:extend()


function Tile:new(XPos,YPos,TileId,ChunkId,TileProperties)
	self.XPos = XPos
	self.YPos = YPos
	self.HeightMap = TileProperties.HeightMap
	self.HorizontalMap = TileProperties.HorizontalMap
	self.GroundAngle = TileProperties.GroundAngle or 0
	self.ChunkId = ChunkId
	self.TileId = TileId
	self.Quad = TileProperties.Quad
	
	self.Flags = {}

	self.Flags.Flipped = TileProperties.Flipped or false
	self.Flags.FlippedHorizontal = TileProperties.FlippedHorizontal or false
	self.Flags.IgnoreCeiling = TileProperties.IgnoreCeiling or false
	self.Flags.IgnoreWall = TileProperties.IgnoreWall or false
end



return Tile