Tile = Object:extend()


function Tile:new(XPos,YPos,TileId,TileProperties)
	self.XPos = XPos
	self.YPos = YPos
	self.GroundAngle = TileProperties.GroundAngle or 0
	self.TileId = TileId
	self.Quad = TileProperties.Quad
	self.CanCollide = true
	
end



return Tile