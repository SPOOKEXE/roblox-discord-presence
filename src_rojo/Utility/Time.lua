local Module = {}

function Module:Get()
	return os.time(os.date('!*t'))
end

return Module