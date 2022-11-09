Vector2 = Object:extend()

function Vector2:new(x,y)
    self.X = x or 0
    self.Y = y or 0
end

function Vector2:__tostring()
    return self.X..", "..self.Y
end

function Vector2:__unm()
    return Vector2(-self.X,-self.Y)
end

function Vector2.__add(a, b)
    if type(a) == "number" then
        local scalar,vector = a,b

        return Vector2(vector.X + scalar, vector.Y + scalar)
    elseif type(b) == "number" then
        local vector,scalar = a,b

        return Vector2(vector.X + scalar, vector.Y + scalar)
    elseif (type(a) == "table" and a:is(Vector2)) and (type(b) == "table" and b:is(Vector2)) then
        return Vector2(a.X + b.X, a.Y + b.Y)
    end
end

function Vector2.__sub(a, b)
    if type(a) == "number" then
        local scalar,vector = a,b

        return Vector2(scalar - vector.X,scalar - vector.Y)
    elseif type(b) == "number" then
        local vector,scalar = a,b

        return Vector2(vector.X - scalar, vector.Y - scalar)
    elseif (type(a) == "table" and a:is(Vector2)) and (type(b) == "table" and b:is(Vector2)) then
        return Vector2(a.X - b.X, a.Y - b.Y)
    end
end

function Vector2.__mul(a, b)
    if type(a) == "number" then
        local scalar,vector = a,b

        return Vector2(vector.X * scalar, vector.Y * scalar)
    elseif type(b) == "number" then
        local vector,scalar = a,b

        return Vector2(vector.X * scalar, vector.Y * scalar)
    elseif (type(a) == "table" and a:is(Vector2)) and (type(b) == "table" and b:is(Vector2)) then
        return Vector2(a.X * b.X, a.Y * b.Y)
    end
end

function Vector2.__div(a, b)
    if type(a) == "number" then
        local scalar,vector = a,b

        return Vector2(scalar / vector.X,scalar / vector.Y)
    elseif type(b) == "number" then
        local vector,scalar = a,b

        return Vector2(vector.X / scalar, vector.Y / scalar)
    elseif (type(a) == "table" and a:is(Vector2)) and (type(b) == "table" and b:is(Vector2)) then
        return Vector2(a.X / b.X, a.Y / b.Y)
    end
end

function Vector2.__mod(a, b)
    if type(a) == "number" then
        local scalar,vector = a,b

        return Vector2(scalar % vector.X,scalar % vector.Y)
    elseif type(b) == "number" then
        local vector,scalar = a,b

        return Vector2(vector.X % scalar, vector.Y % scalar)
    elseif (type(a) == "table" and a:is(Vector2)) and (type(b) == "table" and b:is(Vector2)) then
        return Vector2(a.X % b.X, a.Y % b.Y)
    end
end

function Vector2.__pow(a, b)
    if type(a) == "number" then
        local scalar,vector = a,b

        return Vector2(scalar^vector.X,scalar^vector.Y)
    elseif type(b) == "number" then
        local vector,scalar = a,b

        return Vector2(vector.X^scalar, vector.Y^scalar)
    elseif (type(a) == "table" and a:is(Vector2)) and (type(b) == "table" and b:is(Vector2)) then
        return Vector2(a.X^b.X, a.Y^b.Y)
    end
end






function Vector2:Magnitude()
return math.sqrt(self.X^2 + self.Y^2)
end

function Vector2:Unit()
local mag = self:Magnitude()

return Vector2(self.X/mag,self.Y/mag)
end

function Vector2:Dot(Vector)
return (self.X * Vector.X) + (self.Y * Vector.Y)
end

function Vector2:Cross(Vector)
return (self.X*Vector.Y) - (self.Y*Vector.X)
end

function Vector2:Max(Vector)
return Vector2(math.max(self.X,Vector.X),math.max(self.Y,Vector.Y))
end

function Vector2:Min(Vector)
    return Vector2(math.min(self.X,Vector.X),math.min(self.Y,Vector.Y))
end

Vector2.zero = Vector2(0,0)
Vector2.one = Vector2(1,1)
Vector2.xAxis = Vector2(1,0)
Vector2.yAxis = Vector2(0,1)


return Vector2