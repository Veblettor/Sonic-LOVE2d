Event = Object:extend()

function Event:new()
Event.__connections = {}
end

function Event:Connect(func)
assert(func, "Connection cannot be nil")

local parent = self

local Connection = 
{
    __signal = func;
    Disconnect = function(self)
        parent.__connections[self] = nil
    end
}

parent.__connections[Connection] = Connection

return parent.__connections[Connection]
end

function Event:Once(func)
    assert(func, "Connection cannot be nil")

    local parent = self
    
    local Connection = 
    {
        __signal = func;
        Once = true;
        Disconnect = function(self)
            parent.__connections[self] = nil
        end
    }
    
    parent.__connections[Connection] = Connection
    
    return parent.__connections[Connection]
end

function Event:Fire(...)

for i,signal in pairs(self.__connections) do
    local success,reason = pcall(signal.__signal,...)
   

    if not success then
        print("Event Failure: "..reason)
    end

    if signal.Once then
        signal:Disconnect()
    end
end

end