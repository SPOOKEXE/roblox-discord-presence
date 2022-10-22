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
		activeSourceMaid = Maid.New()
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
		--warn(err)
	end)
end

onDataUpdated:Connect(function()
	if activePromise then
		activePromise:cancel()
	end
	activePromise = nil
	activePromise = Promise.try(function()
		local ReturnData = HttpService:JSONDecode(MakeRequestAsync(Config.LocalHostIP, {activeOutgoing, "DATA FINISHED"}).Body)
		return hasResolved, ReturnData
	end):andThen(function(_, _)
		--print(succeeded, data)
	end):timeout(5):catch(function(errMsg)
		warn(errMsg)
	end)
end)

local pMaid = Maid.New()

local function OnGameClosed()
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
end

pcall(function()
	game:BindToClose(OnGameClosed)
end)

local PluginActive = true

pMaid:Give(StudioService:GetPropertyChangedSignal('ActiveScript'):Connect(UpdateData))
pMaid:Give(onDataUpdated)

pMaid:Give(function()
	PluginActive = false
	OnGameClosed()
end)

pMaid:Give(plugin.Unloading:Connect(function()
	pMaid:Cleanup()
end))

pMaid:Give(plugin.Deactivation:Connect(function()
	pMaid:Cleanup()
end))

task.defer(function()
	while PluginActive do
		task.wait(6)
		onDataUpdated:Fire()
	end
end)

task.delay(1.5, UpdateData)