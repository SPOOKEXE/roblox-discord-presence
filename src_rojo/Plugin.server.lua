
type Dictionary = { [string] : any }
type Array = { [number] : any }

local HttpService : HttpService = game:GetService('HttpService')
local SelectionService : Selection = game:GetService('Selection')
local StudioService : StudioService = game:GetService('StudioService')
local RunService : RunService = game:GetService('RunService')
local MarketplaceService : MarketplaceService = game:GetService('MarketplaceService')

local PluginFolder : Folder = script.Parent
local Signal : Dictionary = require(PluginFolder.Classes.Signal)
local Promise : Dictionary = require(PluginFolder.Classes.Promise)
local Maid : Dictionary = require(PluginFolder.Classes.Maid)

local plugin : Plugin = plugin

local Config : Dictionary = require(PluginFolder.Config)

local activeOutgoing : Dictionary? = nil
local activePromise : Promise? = nil

local onDataUpdated : Signal.SignalClass = Signal.New("onDataUpdated")

local activeSourceMaid : Dictionary = nil

function getLines(s : string) : number
    local lines : Array = {}
    local str : string = ""
    for i = 1, string.len(s.Source) do
    	if (string.sub(s.Source, i, i) == "\n") then
	    	table.insert(lines, str)
	    	str = ""
    	else
	    	str = str..string.sub(s.Source, i, i)
    	end
    end
	if (str ~= "") then
        table.insert(lines, str)
	end
	return #lines
end

function MakeRequestAsync(URL : string, Body : string) : (any, any)
    return HttpService:RequestAsync({
        Url = URL,
        Method = "POST",
        Body = HttpService:JSONEncode(Body),
        Headers = {["Content-Type"] = "application/json"}
    })
end

function SetupConnections(script : LuaSourceContainer) : nil
    if activeSourceMaid then
        activeSourceMaid:Cleanup()
        activeSourceMaid = nil
    end
    if script then
        activeSourceMaid = Maid.new()
        local LineCount : number = getLines(script)
        activeSourceMaid:Give(RunService.Heartbeat:Connect(function()
            local newLineCount : number = getLines(script)
            if newLineCount ~= LineCount then
                task.spawn(UpdateData)
            end
        end))
    end
end

function UpdateData() : nil
    task.wait()

    local placeInfo : Dictionary? = nil
    Promise.try(function()
        placeInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    end)

    local activeScript : LuaSourceContainer = StudioService.ActiveScript
    SetupConnections(activeScript)
    print(activeScript)
    activeOutgoing = {
        ACCESS_KEY = Config.AccessKey,
        ScriptName = activeScript and activeScript.Name or false,
        ScriptSource = activeScript and activeScript.Source or false,
        ScriptFullName = activeScript and activeScript:GetFullName() or false,
        ScriptClass = activeScript and activeScript.ClassName or false,
        PlaceName = placeInfo and placeInfo.Name or "No Place Data",
        PlaceID = game.PlaceId,
        CreatorID = game.CreatorId,
        CreatorType = game.CreatorType.Name
    }
    onDataUpdated:Fire()
end

onDataUpdated:Connect(function()
    local hasResolved : boolean = false
    local errMsg : string? = nil
    if activePromise then
        activePromise:cancel()
        activePromise = nil
    end
    activePromise = Promise.try(function()
        local ReturnData : Dictionary? = nil
        hasResolved, errMsg = pcall(function()
            ReturnData = HttpService:JSONDecode(MakeRequestAsync(Config.LocalHostIP, {activeOutgoing, "DATA FINISHED"}).Body)
        end)
        if (not hasResolved) and errMsg then
           --warn(errMsg)
        end
        return hasResolved, ReturnData or errMsg
    end):andThen(function(succeeded : boolean, data : Dictionary | string)
        --print(succeeded, data)
    end)
end)

local pMaid = Maid.new()

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
task.delay(2, UpdateData)
