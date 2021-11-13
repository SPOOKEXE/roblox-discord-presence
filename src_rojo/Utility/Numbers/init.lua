type Dictionary = { [any] : any }
type Array = { [number] : any }

local Module : Dictionary = {}

-- from number A to B with alpha t (0 -> 1)
function Module:LinearInterpolation(v0 : number, v1 : number, t : number) : number
	return (1 - t) * v0 + t * v1
end

-- Processing equilivant of map(number, oldMinA, oldMaxB, newMinA, newMaxB)
function Module:MapValue(n : number, start : number, stop : number, newStart : number, newStop : number) : number
	return ((n - start) / (stop - start)) * (newStop - newStart) + newStart
end

-- Returns the % value of the decimal (0 -> 1) (000.00)
function Module:FormatPercent(decimal : number) : string
	return string.format("%3.2f", decimal * 100) .. "%"
end

-- Round the given number between the given decimal places
function Module:RoundN(number : number, decimal_places : number) : number
	decimal_places = (decimal_places or 0)
	if decimal_places == 0 then
		return math.round(number)
	end
	local e : number = math.pow(10, decimal_places)
	return math.round(number * e) / e
end

-- Clamp the given value between 0 and 1
function Module:Clamp01(value : number) : number
	return math.clamp(value, 0, 1)
end

-- Add Commas to Number, 1000 = 1,000
function Module:NumberCommas(value : number, useAltCommas : number) : string
	local wholeComponent : string = tostring(math.floor(math.abs(value)))
	local decimalComponent : string = tostring(value - math.floor(value))
	local comma : string = useAltCommas and "." or ","
	local period : string = useAltCommas and "," or "."
	local newString : string = ""
	local digits : number = 0
	for idx = #wholeComponent, 1, -1 do
		newString = wholeComponent:sub(idx, idx) .. newString
		digits += 1
		if digits == 3 and idx ~= 1 then
			newString = comma .. newString
			digits = 0
		end
	end
	if decimalComponent ~= "0" and #decimalComponent > 2 then
		newString = newString .. period .. decimalComponent:sub(3)
	end
	if math.sign(value) == -1 then
		newString = "-" .. newString
	end
	return newString
end

-- 300 -> (00:05:00)
function Module:FormatForTimer(seconds : number) : string
	seconds = math.floor(seconds)
	local minutes : number = (seconds/60)
	local hours : number = math.floor(minutes/60)
	hours = (hours < 0 and 0 or hours)
	minutes = math.floor(minutes) - (hours * 60)
	minutes = (minutes < 0 and 0 or minutes)
	seconds = seconds - (minutes*60) - (hours * 60 * 60)
	seconds = (seconds < 0 and 0 or seconds)
	return (hours>9 and hours or '0'..hours)..':'..(minutes>9 and minutes or '0'..minutes)..':'..(seconds>9 and seconds or '0'..seconds)
end

local NUMBER_SUFFIXES : Array = {"k","M","B","T","qd","Qn","sx","Sp","O","N","de","Ud","DD","tdD","qdD","QnD","sxD","SpD","OcD","NvD","Vgn","UVg","DVg","TVg","qtV","QnV","SeV","SPG","OVG","NVG","TGN","UTG","DTG","tsTG","qtTG","QnTG","ssTG","SpTG","OcTG","NoTG","QdDR","uQDR","dQDR","tQDR","qdQDR","QnQDR","sxQDR","SpQDR","OQDDr","NQDDr","qQGNT","uQGNT","dQGNT","tQGNT","qdQGNT","QnQGNT","sxQGNT","SpQGNT", "OQQGNT","NQQGNT","SXGNTL"}

-- 50000 -> 50k
function Module:NumberSuffix(Input : number) : string
	local Negative : number = (Input < 0)
	Input = math.abs(Input)
	local Paired : boolean = false
	for i : number, v : string in pairs(NUMBER_SUFFIXES) do
		if not (Input >= 10^(3*i)) then
			Input = Input / 10^(3*(i-1))
			local isComplex : boolean = (string.find(tostring(Input),".") and string.sub(tostring(Input),4,4) ~= ".")
			Input = string.sub(tostring(Input),1,(isComplex and 4) or 3)..(NUMBER_SUFFIXES[i-1] or "")
			Paired = true
			break
		end
	end
	if not Paired then
		local Rounded : number = math.floor(Input)
		Input = tostring(Rounded)
	end
	if Negative then
		return "-"..Input
	end
	return Input
end

-- Module:ToNumeral(5) - "V"
function Module:ToRomanNumeral(Number) : string
	local Numbers : number = {1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1,}
	local Numerals : string = {"M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I",}
	local Result : string = ""
	if Number < 0 or Number >= 4000 then
		return nil
	elseif Number == 0 then
		return "N"
	else
		for Index = 1, 13 do
			while Number >= Numbers[Index] do
				Number = Number - Numbers[Index]
				Result = Result..Numerals[Index]
			end
		end
	end
	return Result
end

local RomanDigit : Dictionary = {["I"] = 1, ["V"] = 5, ["X"] = 10, ["L"] = 50, ["C"] = 100, ["D"] = 500, ["M"] = 1000}
local SpecialRomanDigit : Dictionary = {["I"] = 1, ["X"] = 10, ["C"] = 100,}
local function CheckNumOfCharacterInString(TheString : string, Character : string)
	local Number : number = 0
	for ID in string.gmatch(TheString, Character) do
		Number = Number + 1
	end
	return Number
end

-- GetRomanNumeral("XII")
function Module:FromRomanNumeral(Numeral : string) : number?
	Numeral = string.upper(Numeral)
	local Result : number = 0
	if Numeral == "N" then 
		return 0
	elseif CheckNumOfCharacterInString(Numeral, "V") >= 2 or CheckNumOfCharacterInString(Numeral, "L") >= 2 or CheckNumOfCharacterInString(Numeral, "D") >= 2 then --(#{string.find(Numeral, "V*.V")} >= 2) or (#{string.find(Numeral, "L*.L")} >= 2) or (#{string.find(Numeral, "D*.D")} >= 2) then
		return nil
	end
	local Last : string = "Z"
	local Count : number = 1
	for i=1, #Numeral do
		local Numeral : string = string.sub(Numeral, i, i)
		if not RomanDigit[Numeral] then
			return nil
		end
		if Numeral == Last then
			Count = Count + 1
			if Count >= 4 then
				return nil
			end
		else
			Count = 1
		end
		Last = Numeral
	end
	local Pointer : number = 1
	local Values : Array = {}
	local MaxDigit : number = 1000
	while Pointer <= #Numeral do
		local Numeral : string = string.sub(Numeral, Pointer, Pointer)
		local Digit : number = RomanDigit[Numeral]
		if Digit > MaxDigit then
			return nil
		end
		local NextDigit : number = 0
		if Pointer <= #Numeral - 1 then
			local NextNumeral : string = string.sub(Numeral, Pointer+1, Pointer+1)
			NextDigit = RomanDigit[NextNumeral]
			if NextDigit > Digit then
				if (not SpecialRomanDigit[Numeral]) or NextDigit > (Digit * 10) or CheckNumOfCharacterInString(Numeral, Numeral) > 3 then
					return nil
				end
				MaxDigit = Digit - 1
				Digit = NextDigit - Digit
				Pointer = Pointer + 1
			end
		end
		table.insert(Values, Digit)
		Pointer = Pointer + 1
	end
	for Index = 1, #Values-1 do
		if Values[Index] < Values[Index + 1] then
			return nil
		end
	end
	local Total : number = 0
	for Index : number, Digit : string in pairs(Values) do
		Total = Total + Digit
	end
	return Total
end

return Module
