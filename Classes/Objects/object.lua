local Object = Class:extend()

function Object:new(Radius,Hitbox)
    self.Position = Vector2(0,0)
	self.Speed = Vector2(0,0)
	self.Radius = Radius or Vector2(5,5)
    self.Hitbox = Hitbox or Vector2(5,5)
end

return Object

