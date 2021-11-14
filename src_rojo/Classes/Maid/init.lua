-- Rewritten by SPOOK_EXE
-- Other one was annoying to look at :-)

local validTypeTask = function(task) : boolean
	return (typeof(task) == 'RBXScriptConnection') or (typeof(task) == 'function') or task.Destroy
end

export type MaidTask = RBXScriptConnection | () -> nil
export type Maid = { Cleanup : (nil) -> nil, Give : (MaidTask) -> nil }

local Maid = {ClassName = 'Maid'}
Maid.__index = Maid

function Maid.new() : Maid
	return setmetatable( { _tasks = {} } , Maid )
end

function Maid:__newindex(t, index, value) : nil
	if index == '_tasks' or t == self._tasks then
		error('Cannot edit _tasks table. Use Maid:Give(task)')
	end
	if validTypeTask(value) then
		table.insert(self._tasks, value)
	end
end

function Maid:Give(task) : nil
	if validTypeTask(task) then
		table.insert(self._tasks, task)
	end
end

function Maid:Cleanup() : nil
	for _, _task in ipairs(self._tasks) do
		if typeof(_task) == 'RBXScriptConnection' then
			_task:Disconnect()
		elseif typeof(_task) == 'function' then
			task.defer(_task)
		elseif _task.Destroy then
			task.defer(pcall, _task.Destroy)
		end
	end
	setmetatable(self, nil)
end

Maid.Destroy = Maid.Cleanup

return Maid