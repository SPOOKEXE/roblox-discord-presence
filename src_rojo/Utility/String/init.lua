
type Dictionary = { [any] : any }
type Array = { [number] : any }

local Module : Dictionary = {
    Compression = require(script.Compression) 
}

function Module:ConvertToBytesTable(str) : Array
	local bytes : Array = {}
	for strIndex = 1, #str do
		local character : string = string.sub(str, strIndex, strIndex)
		local byte : number = string.byte(character)
		table.insert(bytes, byte)
	end
	return bytes
end

function Module:ConvertToTotalBytes(str) : number
	local total : number = 0
	for _ : number, n : number in ipairs(Module:ConvertToBytesTable(str)) do
		total += n
	end
	return total
end

function Module:SpaceStringByPrimary(str) : string -- splits string at the start of a new capital or at the end of a number sequence
	local regions : Array = {}
	local currentIndex : number = 1
	local hasNumber : boolean = false
	local function Split(Index : number) : nil
		local leftRegion : string = string.sub(str, 1, Index - 1)
		local rightRegion : string = string.sub(str, Index, #str)
		table.insert(regions, leftRegion)
		str = rightRegion
	end
	while true do
		currentIndex += 1
		if currentIndex > #str then
			table.insert(regions, str)
			break
		end
		local char : string = string.sub(str, currentIndex, currentIndex)
		if string.byte(char) > 64 and string.byte(char) < 91 then -- capital letters
			hasNumber = false
			Split(currentIndex)
			currentIndex = 1
		elseif string.byte(char) > 48 and string.byte(char) < 57 and not hasNumber then -- numbers
			hasNumber = true
			Split(currentIndex)
			currentIndex = 1
		end
	end
	return table.concat(regions, ' ')
end

return Module
