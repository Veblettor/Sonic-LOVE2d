function GetStageById(stageid)
local foundstage


for i,v in pairs(Stages) do

if v.StageID == stageid then
foundstage = v
end

end

return foundstage
end

function InfiniteDrawSingleAxis(img,start,axis,...)
    local min = Vector2(love.graphics.inverseTransformPoint(0,0))
    local max = Vector2(love.graphics.inverseTransformPoint(love.graphics:getDimensions()))
    local dims = Vector2(img:getDimensions())

    repeat

        love.graphics.draw(img,start.X,start.Y,...)

        start[axis] = start[axis] + dims[axis]*2
    until start[axis] > max[axis]
end