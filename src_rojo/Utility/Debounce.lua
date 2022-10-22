
local activeDebounces = {}

-- // Module // --
local Module = {}

function Module:Debounce(debounceName, duration)
	duration = typeof(duration) == 'number' and duration or 1
	if typeof(debounceName) == 'string' then
		if activeDebounces[debounceName] then
			return false
		end
		local ID = game:GetService('HttpService'):GenerateGUID(false)
		activeDebounces[debounceName] = ID
		task.delay(duration, function()
			if activeDebounces[debounceName] == ID then
				activeDebounces[debounceName] = ID
			end
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
