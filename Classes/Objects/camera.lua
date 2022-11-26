local Camera = Object:extend()

function Camera:new(HighestBounds,LowestBounds)
    Camera.super.new(self,Vector2(16,64),Vector2(16,32))
    self.Angle = 0
    self.OnDraw = PriorityEvent()
    self.OnUpdate = Event()
    self.Target = Vector2(0,0)
    self.LastPosition = Vector2(0,0)
    self.Scale = Vector2(2,2)
    self.Offset = Vector2(0,0)
    self.MaxSpeed = 24
    self.Highest = HighestBounds or Vector2(3585,1665)
    self.Lowest = LowestBounds or Vector2(0,0)
	self.Layers = {}
	--[[self.OnDraw:Connect(0,function()
		love.graphics.rectangle("line", self.Position.X-8,self.Position.Y-32,self.Radius.X,self.Radius.Y)
	end)--]]
end

function Camera:NewLayer(scale,index,func)

local tab = {}

tab.Scale = scale or Vector2(1,1)
tab.Index = index or 1
tab.OnDraw = func

table.insert(self.Layers,tab)
table.sort(self.Layers,function(a,b)
return a.Index < b.Index
end)

return tab
end


function Camera:Draw()



for i,v in pairs(self.Layers) do
local coords = self.Position+self.Offset
love.graphics.push()
love.graphics.scale(self.Scale.X, self.Scale.Y)  
love.graphics.translate(love.graphics.getWidth()/2 / self.Scale.X,love.graphics.getHeight()/2 / self.Scale.Y)
love.graphics.rotate(-math.rad(self.Angle))
love.graphics.translate(-(coords.X * v.Scale.X), -(coords.Y * v.Scale.Y))
v.OnDraw()
love.graphics.pop()
end

--self.OnDraw:Fire()


end

function Camera:WorldToScreen(Position)
local dist = Position - (self.Position+self.Offset)
dist = Vector2(math.cosAng(self.Angle)*dist.X - math.sinAng(self.Angle)*dist.Y,-(math.sinAng(self.Angle)*dist.X) + math.cosAng(self.Angle)*dist.Y)

local scaled = self.Scale*dist
return scaled + (Vector2(love.graphics.getDimensions())/2)
end

function Camera:ScreenToWorld(Position)
local dist = Position - (Vector2(love.graphics.getDimensions())/2)
local scaled = dist/self.Scale

scaled = Vector2(math.cosAng(self.Angle)*scaled.X - math.sinAng(self.Angle)*scaled.Y,math.sinAng(self.Angle)*scaled.X + math.cosAng(self.Angle)*scaled.Y)
return scaled + (self.Position+self.Offset)
end

function Camera:Update(dt)


if self.Target then
    self.Speed = Vector2(0,0)
if self.Target:is(Vector2) then
    if Vector2.X >= self.Position.X+(self.Radius.X/2) or Vector2.X < self.Position.X-(self.Radius.X/2) then
        self.Speed.X = math.clamp(Vector2.X - self.Position.X,-self.MaxSpeed,self.MaxSpeed)
        
    else
        self.Speed.X = 0
    end

    if Vector2.Y >= self.Position.Y+(self.Radius.Y/2) or Vector2.Y <= self.Position.Y-(self.Radius.Y/2) then
        self.Speed.Y = math.clamp(Vector2.Y - self.Position.Y,-self.MaxSpeed,self.MaxSpeed)
        
    else
        self.Speed.Y = 0
    end
elseif self.Target:is(BaseOBJ) then
    local pos = self.Target.Position
  
   

   
    if  pos.Y > self.Position.Y+(self.Radius.Y/2) or pos.Y < self.Position.Y-(self.Radius.Y/2) then
        local offsety = 0
        if pos.Y > self.Position.Y+(self.Radius.Y/2) then
            offsety = (self.Radius.Y/2)
           
        elseif pos.Y < self.Position.Y-(self.Radius.Y/2) then
            offsety = -(self.Radius.Y/2)
        end

        
      
        self.Speed.Y = (pos.Y - (self.Position.Y+offsety))
    else
        self.Speed.Y = 0
    end

    if  pos.X > self.Position.X+(self.Radius.X/2) or pos.X < self.Position.X-(self.Radius.X/2) then
        local offsetx = 0
        if pos.X > self.Position.X+(self.Radius.X/2) then
            offsetx = (self.Radius.X/2)
           
        elseif pos.X < self.Position.X-(self.Radius.X/2) then
            offsetx = -(self.Radius.X/2)
        end

        
    
        self.Speed.X = (pos.X - (self.Position.X+offsetx))
    else
        self.Speed.X = 0
    end


  

    if self.Target.State == "Grounded" or self.Target.State == "Rolling" then
       
        if self.Position.Y ~= pos.Y then
            self.Speed.Y = (pos.Y - (self.Position.Y))
        end

        if math.abs(self.Target.GroundSpeed) < 8 then
       self.Speed.Y = math.clamp(self.Speed.Y,-6,6)
       self.Speed.X = math.clamp(self.Speed.X,-6,6)
        else
            self.Speed.Y = math.clamp(self.Speed.Y,-self.MaxSpeed,self.MaxSpeed)
          self.Speed.X = math.clamp(self.Speed.X,-self.MaxSpeed,self.MaxSpeed)
        end

    else

        self.Speed.Y = math.clamp(self.Speed.Y,-self.MaxSpeed,self.MaxSpeed)
        self.Speed.X = math.clamp(self.Speed.X,-self.MaxSpeed,self.MaxSpeed)

    end
   
  
    if math.abs(self.Target.Speed.X) < 6 then
        if self.Offset.X > 0 then
            self.Offset.X = self.Offset.X - 2
        elseif self.Offset.X < 0 then
            self.Offset.X = self.Offset.X + 2
        end
    end

    if self.Target.Speed.X >= 6 and self.Offset.X < 64 then
        self.Offset.X = self.Offset.X + 2
    elseif self.Target.Speed.X <= -6 and self.Offset.X > -64 then
        self.Offset.X = self.Offset.X - 2
    end
   
    self.LastPosition = self.Position
end

end

self.OnUpdate:Fire(dt)

self.Position = self.Position + self.Speed

local middle = (Vector2(love.graphics.getDimensions())/4)
self.Position.X = math.clamp(self.Position.X,middle.X-self.Lowest.X-self.Offset.X,self.Highest.X-middle.X-self.Offset.X)
self.Position.Y = math.clamp(self.Position.Y,middle.Y-self.Lowest.Y-self.Offset.Y,self.Highest.Y-middle.Y-self.Offset.Y)



end



return Camera

