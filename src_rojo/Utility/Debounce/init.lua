
type Dictionary = { [string] : any }

local activeDebounces : Dictionary = {}

-- // Module // --
local Module = {}

function Module:Debounce(debounceName : string?, duration : number?)
	duration = typeof(duration) == 'number' and duration or 1
	if typeof(debounceName) == 'string' then
		if activeDebounces[debounceName] then
			return false
		end
		activeDebounces[debounceName] = true
		task.delay(duration, function()
			activeDebounces[debounceName] = nil
		end)
		return true
	end
	return false
end

Module.__call = function(_, ...)
	return Module:Debounce(...)
end

setmetatable(Module, Module)
return Module
