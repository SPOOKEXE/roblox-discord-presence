local HttpService = game:GetService('HttpService')
local StudioService = game:GetService('StudioService')
local RunService = game:GetService('RunService')
local MarketplaceService = game:GetService('MarketplaceService')

local PluginFolder = script.Parent
local Event = require(PluginFolder.Classes.Event)
local Promise = require(PluginFolder.Classes.Promise)
local Maid = require(PluginFolder.Classes.Maid)

local StringUtil = require(PluginFolder.Utility.String)

local plugin : Plugin = plugin

local Config = require(PluginFolder.Config)

local activeOutgoing = nil
local activePromise = nil

local onDataUpdated = Event.New("onDataUpdated")

local activeSourceMaid = nil

function MakeRequestAsync(URL : string, Body : string) : (any, any)
	return HttpService:RequestAsync({
		Url = URL,
		Method = "POST",
		Body = HttpService:JSONEncode(Body),
		Headers = {["Content-Type"] = "application/json"}
	})
end

function SetupConnections(script)
	if activeSourceMaid then
		activeSourceMaid:Cleanup()
		activeSourceMaid = nil
	end
	if script then
		activeSourceMaid = Maid.new()
		local LineCount : number = StringUtil:GetLineCount(script)
		activeSourceMaid:Give(RunService.Heartbeat:Connect(function()
			local newLineCount : number = StringUtil:GetLineCount(script)
			if newLineCount ~= LineCount then
				task.spawn(UpdateData)
			end
		end))
	end
end

function UpdateData()
	Promise.try(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end):andThen(function(placeData)
		local activeScript = StudioService.ActiveScript
		SetupConnections(activeScript)
		activeOutgoing = {
			ACCESS_KEY = Config.AccessKey,
			ScriptName = activeScript and activeScript.Name or false,
			ScriptSource = activeScript and activeScript.Source or false,
			ScriptFullName = activeScript and activeScript:GetFullName() or false,
			ScriptClass = activeScript and activeScript.ClassName or false,
			PlaceName = placeData and placeData.Name or "No Place Data",
			PlaceID = game.PlaceId,
			CreatorID = game.CreatorId,
			CreatorType = game.CreatorType.Name
		}
		onDataUpdated:Fire()
	end):catch(function(_)

	end)
end

onDataUpdated:Connect(function()
	local hasResolved = false
	local errMsg : string? = nil
	if activePromise then
		activePromise:cancel()
		activePromise = nil
	end
	activePromise = Promise.try(function()
		local ReturnData = nil
		hasResolved, errMsg = pcall(function()
			ReturnData = HttpService:JSONDecode(MakeRequestAsync(Config.LocalHostIP, {activeOutgoing, "DATA FINISHED"}).Body)
		end)
		-- if (not hasResolved) and errMsg then
		-- 	--warn(errMsg)
		-- end
		return hasResolved, ReturnData or errMsg
	end):andThen(function(_)
		--print(succeeded, data)
	end)
end)

local pMaid = Maid.New()

pcall(function()
	game:BindToClose(function()
		MakeRequestAsync(Config.LocalHostIP, {{
			ACCESS_KEY = Config.AccessKey,
			ScriptName = false,
			ScriptSource = false,
			ScriptFullName = false,
			ScriptClass = false,
			PlaceName = false,
			PlaceID = false,
			CreatorID = false,
			CreatorType = false
		}, "DATA FINISHED"})
	end)
end)

pMaid:Give(StudioService:GetPropertyChangedSignal('ActiveScript'):Connect(UpdateData))
pMaid:Give(onDataUpdated)

pMaid:Give(plugin.Unloading:Connect(function()
	pMaid:Cleanup()
end))

pMaid:Give(plugin.Deactivation:Connect(function()
	pMaid:Cleanup()
end))

task.defer(function()
	while true do
		task.wait(10)
		onDataUpdated:Fire()
	end
end)

task.delay(2, UpdateData)