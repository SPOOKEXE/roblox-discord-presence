
local RunService : RunService = game:GetService('RunService')

type Dictionary = { [any] : any }

export type Signal = {
    Fire : (any) -> nil,
    Wait : (any) -> nil,
    Connect : (any) -> nil,
    Disconnect : (nil) -> nil,
}

export type Timer = {
    Active : boolean?,
    Interval : number?,
    Signal : Signal,
    _lastTick : number,
    _destroyed : boolean?,
    Destroy : (nil) -> nil
}

local SignalClass : Signal = require(script.Parent.Signal)

local Timers : { [number] : Timer } = {}

RunService.Heartbeat:Connect(function()
    local newClock : number = os.clock()
    for i : number, timerClass : Timer in pairs(Timers) do
        if timerClass._destroyed then
            table.remove(Timers, i)
            break
        end
        local deltaTime : number = (newClock - timerClass._lastTick)
        if deltaTime >= timerClass.Interval then
            timerClass._lastTick = newClock
            timerClass.Signal:Fire()
        end
    end
end)

-- // Class // --
local Class : Dictionary = {}

function Class.New(Properties : Dictionary) : Timer

    local self : Timer = {
        Active = true,
        Interval = 1,
        Signal = SignalClass.New(),

        _lastTick = -1,
        _destroyed = false,
    }

    if typeof(Properties) == 'table' then
        for propName : string, propValue : any in pairs(Properties) do
            self[propName] = propValue
        end
    end

    setmetatable(self, Class)

    table.insert(Timers, self)

    return self

end

function Class:Destroy() : nil
    self.Active = false
    self._destroyed = true
    self.Signal:Disconnect()
end

return Class

