type Array = { [number] : any }
type Dictionary = { [any] : any }

-- // Module // --
local Module : Dictionary = {}

function Module:DeepCopy(passed_table : table) : table
	local clonedTable : table = {}
	if typeof(passed_table) == "table" then
		for k,v in pairs(passed_table) do 
			clonedTable[Module:DeepCopy(k)] = Module:DeepCopy(v)
		end
	else
		clonedTable = passed_table
	end
	return clonedTable
end

-- DICTIONARY
function Module:CleanTableAndOverwrite(oldTable : table, overwriteData : table) : table
	for k : any, v : any in pairs(oldTable) do
		rawset(oldTable, k, nil)
	end
	for k : any, v : any in pairs(overwriteData) do
		rawset(oldTable, k, v)
	end
end

function Module:GetRandomDictionaryIndex(Dict : table) : any
	local indexes : Array = {}
	for i : any, _ in pairs(Dict) do
		table.insert(indexes, i)
	end
	return indexes[math.random(#indexes)]
end

function Module:GetRandDictionaryValue(Dict : table) : any?
	return Dict[ Module:GetRandDictionaryIndex(Dict) ]
end

-- Combine all tables (arrays) pasted into this function into one singular table.
function Module:CombineArrays(...) : table
	local combined : Array = {}
	local arrays : Array = {...}
	for index = 1, #arrays do
		if typeof(arrays[index]) == 'table' and #arrays[index] > 0 then
			table.move(arrays[index], 1, #arrays[index], #combined + 1, combined)
		end
	end
	return combined
end

function Module:FindValueInTable(Table : table, Value : any) : (number | nil)
	local _index : number? = table.find(Table, Value)
    if not _index then
        for index : any, value : any in pairs(Table) do 
            if value == Value then
                return index
            end
        end
    end
    return _index
end

-- OBJECTS -> TABLE // TABLE -> OBJECTS
local OT_Types : Dictionary = {
	['boolean'] = 'BoolValue',
	['string'] = 'StringValue',
	['number'] = 'NumberValue',
}

function Module:TableToObject(Tbl : table, Prnt : Instance, Ignores : table?, Nst : number?) : Instance
	if Nst and (Nst > 30) then
        return
    end
	for k : any, v : any in pairs(Tbl) do
		if (not Ignores) or (not table.find(Ignores, tostring(k))) then
			if typeof(v) == 'table' then
				local Fold : Folder = Instance.new('Folder')
				Fold.Name = tostring(k)
				Module:TableToObject(v, Fold, Ignores, (Nst or 0) + 1)
				Fold.Parent = Prnt
			elseif typeof(k) == 'number' and typeof(v) == 'string' then
				local Fold : Folder = Instance.new('Folder')
				Fold.Name = tostring(v)
				Fold.Parent = Prnt
			else
				local c : string = OT_Types[typeof(v)] or OT_Types['string']
				local val : Instance = Instance.new(c)
				val.Name = tostring(k)
				if not pcall(function() val.Value = v end) then
					val.Value = tostring(v)
				end
				val.Parent = Prnt
			end
		end
	end
    return Prnt
end

function Module:ObjectToTable(Prnt : Instance, Tbl : table) : table
	Tbl = Tbl or {}
    for index : number, child : Instance in ipairs(Prnt:GetChildren()) do
		if child:IsA('Folder') then
			Tbl[child.Name] = Module:ObjectToTable({}, child)
		else
			Tbl[child.Name] = child.Value
		end
	end
	return Tbl
end

return Module
