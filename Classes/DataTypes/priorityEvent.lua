PriorityEvent = Event:extend()

function PriorityEvent:new()
PriorityEvent.super.new(self)
end

local function sorting(a,b)
	return a.Priority < b.Priority
end



function PriorityEvent:Connect(priority,func)
assert(func, "Connection cannot be nil")
assert(type(priority) == "number","Priority must be a number")

local parent = self

local Connection = 
{
	Priority = priority;
    __signal = func;
    Disconnect = function(self)
        for i,v in pairs(parent.__connections) do
			if v == self then
				parent.__connections[i] = nil
			end
		end
		
		table.sort(parent.__connections,sorting)
    end
}

table.insert(parent.__connections,Connection)
table.sort(parent.__connections,sorting)

return parent.__connections[Connection]
end

function PriorityEvent:Once(priority,func)
assert(func, "Connection cannot be nil")
assert(type(priority) == "number","Priority must be a number")

local parent = self



local Connection = 
{
	Priority = priority;
	Once = true;
    __signal = func;
	
    Disconnect = function(self)
        for i,v in pairs(parent.__connections) do
			if v == self then
				parent.__connections[i] = nil
			end
		end
		
		table.sort(parent.__connections,sorting)
    end
}

table.insert(parent.__connections,Connection)
table.sort(parent.__connections,sorting)

return parent.__connections[Connection]
end

return PriorityEvent