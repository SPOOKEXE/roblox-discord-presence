type Dictionary = { [string] : any }

local Module : Dictionary = {}

function Module:Get() : number
    return os.time(os.date('!*t'))
end

return Module