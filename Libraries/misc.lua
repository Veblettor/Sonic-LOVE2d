function GetStageById(stageid)
local foundstage


for i,v in pairs(Stages) do

if v.StageID == stageid then
foundstage = v
end

end

return foundstage
end

function InfiniteDrawSingleAxis(img,scale,start,axis,...)
    local min = Vector2(love.graphics.inverseTransformPoint(0,0))
    local max = Vector2(love.graphics.inverseTransformPoint(love.graphics:getDimensions()))
    local dims = Vector2(img:getDimensions())


   local maxa,mina,dimsa,starta,scalea

   if axis == "X" then
        maxa = max.X
        mina = min.X
        dimsa = dims.X
        starta = start.X
        scalea = scale.X
   else
        maxa = max.Y
        mina = min.Y
        dimsa = dims.Y
        starta = start.Y
        scalea = scale.Y
   end

   --[[local offset = math.floor(mina - starta) / (dimsa)

  if axis == "X" then
        start.X = start.X + dimsa * offset
    else
        start.Y = start.Y + dimsa * offset
    end--]]
    local comparison = false
    repeat

      
        love.graphics.draw(img,start.X,start.Y,...)
        if axis == "X" then
            start.X = start.X + dims.X*scale.X
            comparison = start.X > max.X
        elseif axis == "Y" then
            start.Y = start.Y + dims.Y*scale.Y
            comparison = start.Y > max.Y
        end
        
    until comparison
end