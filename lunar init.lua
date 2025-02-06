--!native
--!optimize 2

local _require = require

if script.Name ~= "LuaSocialLibrariesDeps" and script.Name ~= "JestGlobals" and script.Name ~= "Url" then
	script.Parent=nil;
end

task.spawn(function(...) 
	repeat wait() until game:IsLoaded()

	local proxiedServices = {
		LinkingService = {{
			"OpenUrl"
		}, game:GetService("LinkingService")},
		ScriptContext = {{
			"SaveScriptProfilingData", 
			"AddCoreScriptLocal",
			"ScriptProfilerService"
		}, game:GetService("ScriptContext")},
		--[[
		MessageBusService = {{
			"Call",
			"GetLast",
			"GetMessageId",
			"GetProtocolMethodRequestMessageId",
			"GetProtocolMethodResponseMessageId",
			"MakeRequest",
			"Publish",
			"PublishProtocolMethodRequest",
			"PublishProtocolMethodResponse",
			"Subscribe",
			"SubscribeToProtocolMethodRequest",
			"SubscribeToProtocolMethodResponse"
		}, game:GetService("MessageBusService")},
		GuiService = {{
			"OpenBrowserWindow",
			"OpenNativeOverlay"
		}, game:GetService("GuiService")},
		MarketplaceService = {{
			"GetRobuxBalance",
			"PerformPurchase",
			"PerformPurchaseV2",
		}, game:GetService("MarketplaceService")},
		HttpRbxApiService = {{
			"GetAsyncFullUrl",
			"PostAsyncFullUrl",
			"GetAsync",
			"PostAsync",
			"RequestAsync"
		}, game:GetService("HttpRbxApiService")},
		CoreGui = {{
			"TakeScreenshot",
			"ToggleRecording"
		}, game:GetService("CoreGui")},
		Players = {{
			"ReportAbuse",
			"ReportAbuseV3"
		}, game:GetService("Players")},
		HttpService = {{
			"RequestInternal"
		}, game:GetService("HttpService")},
		BrowserService = {{
			"ExecuteJavaScript",
			"OpenBrowserWindow",
			"ReturnToJavaScript",
			"OpenUrl",
			"SendCommand",
			"OpenNativeOverlay"
		}, game:GetService("BrowserService")},
		CaptureService = {{
			"DeleteCapture"
		}, game:GetService("CaptureService")},
		OmniRecommendationsService = {{
			"MakeRequest"
		}, game:GetService("OmniRecommendationsService")},
		OpenCloudService = {{
			"HttpRequestAsync"
		}, game:GetService("OpenCloudService")}
		]]
	}
	
	local ENV = {}

	local HttpService = game:GetService("HttpService")
	
	local rs = game:GetService("RunService")
	local players = game:GetService("Players")

	local twait = task.wait
	
	local _fetch_stubmodule do
		local current_module = 1
		local modules_list = {}
		local in_use_modules = {}
	
		for _, obj in game:FindService("CoreGui").RobloxGui.Modules:GetDescendants() do
			if not obj:IsA("ModuleScript") then
				if obj.Name:match("AvatarExperience") 
				then
					for _, o in obj:GetDescendants() do
						if o.Name == "Flags" or o.Name == "Test" then
							for _, oa in o:GetDescendants() do
								if not oa:IsA("ModuleScript") then continue end
								table.insert(modules_list, oa:Clone())
							end
						end
					end
				else
					if 
					obj.Name:match("ReportAnything") 
					or obj.Name:match("TestHelpers")
					then
						for _, o in obj:GetDescendants() do
							if not o:IsA("ModuleScript") then continue end
							table.insert(modules_list, o:Clone())
						end
					end
				end
				
				continue 
			end
		end
	
		local function find_new_module()
			local idx = math.random(1, #modules_list)
			while idx == current_module or in_use_modules[idx] do
				idx = math.random(1, #modules_list)
			end
			return idx
		end
	
		function _fetch_stubmodule()
			local idx = find_new_module()
	
			in_use_modules[current_module] = nil
			current_module = idx
			in_use_modules[current_module] = true
	
			return modules_list[idx]
		end

		function Length(Table)
			local counter = 0 
			for _, v in pairs(Table) do
				counter =counter + 1
			end
			return counter
		end
	end
	
	local fetch_stubmodule = _fetch_stubmodule

	local setaddressholder = Instance.new("ObjectValue")
	local setaddressholder_bool = Instance.new("BoolValue")
	
	setaddressholder.Name = "setaddressholder"
	setaddressholder.Parent = game.CoreGui
	
	setaddressholder_bool.Name = "setaddressholder_bool"
	setaddressholder_bool.Parent = game.CoreGui
	
	local justcalledlocal = false
	local setfenv = setfenv
	
	local mt = {
		__newindex = function(t, key, value)
			rawset(t, key, value)
			_G[key] = value
			rawset(getfenv(), key, value)
		end,
		__index = function(t, key)
			local resp = rawget(_G, key)
			if resp == nil then
				return false
			end
			return resp
		end
	}
	setmetatable(ENV, mt)
	
	function getgenv()
		return ENV
	end
	
	local renv = {print, warn, error, assert, collectgarbage, load, require, select, tonumber, tostring, type, xpcall, pairs, next, ipairs, newproxy, rawequal, rawget, rawset, rawlen, setmetatable, PluginManager, coroutine.create, coroutine.resume, coroutine.running, coroutine.status, coroutine.wrap, coroutine.yield, bit32.arshift, bit32.band, bit32.bnot, bit32.bor, bit32.btest, bit32.extract, bit32.lshift, bit32.replace, bit32.rshift, bit32.xor, math.abs, math.acos, math.asin, math.atan, math.atan2, math.ceil, math.cos, math.cosh, math.deg, math.exp, math.floor, math.fmod, math.frexp, math.ldexp, math.log, math.log10, math.max, math.min, math.modf, math.pow, math.rad, math.random, math.randomseed, math.sin, math.sinh, math.sqrt, math.tan, math.tanh, string.byte, string.char, string.find, string.format, string.gmatch, string.gsub, string.len, string.lower, string.match, string.pack, string.packsize, string.rep, string.reverse, string.sub, string.unpack, string.upper, table.concat, table.insert, table.pack, table.remove, table.sort, table.unpack, utf8.char, utf8.charpattern, utf8.codepoint, utf8.codes, utf8.len, utf8.nfdnormalize, utf8.nfcnormalize, os.clock, os.date, os.difftime, os.time, delay, elapsedTime, require, spawn, tick, time, typeof, UserSettings, version, wait, task.defer, task.delay, task.spawn, task.wait, debug.traceback, debug.profilebegin, debug.profileend}
	
	getgenv().getrenv = function()
		return renv
	end
	
	-- objects
	local hidden_ui_container = Instance.new("Folder")
	hidden_ui_container.Name = "\0nx-hui"
	hidden_ui_container.RobloxLocked = true
	hidden_ui_container.Parent = game:FindService("CoreGui"):FindFirstChild("RobloxGui")
	
	-- variables
	instances_reg = setmetatable({ [game] = true }, { __mode = "ks" })
	touchers_reg = setmetatable({}, { __mode = "ks" })
	
	-- functions
	local _loaded_saveinstance
	
	local function addToInstancesReg(descendant: Instance)
		if instances_reg[descendant] then
			return
		end
		instances_reg[descendant] = true
	end
	
	local function filterAllInstances(filter)
		local result = {}
		local idx = 1
	
		for instance in instances_reg do
			if not (filter(instance)) then
				continue
			end
			result[idx] = instance
			idx += 1
		end
		return result
	end
	
	-- init
	game.DescendantAdded:Connect(addToInstancesReg)
	game.DescendantRemoving:Connect(addToInstancesReg)
	
	for _, instance in game:GetDescendants() do
		addToInstancesReg(instance)
	end
	
	-- main
	
	-- * general instance functions
	
	function getinstances()
		return filterAllInstances(function()
			return true
		end)
	end
	
	function getnilinstances()
		return filterAllInstances(function(instance)
			return instance.Parent == nil
		end)
	end
	
	function getscripts()
		return filterAllInstances(function(instance)
			return instance:IsA("LocalScript") or instance:IsA("ModuleScript")
		end)
	end
	
	function getsenv(src)
		if scr == nil then return getfenv() end
		return filterAllInstances(function(instance)
			if type(instance) == "function" and getfenv(instance).script == scr then
				return getfenv(instance)
			end
		end)
	end
	
	getrunningscripts = getscripts
	
	function getmodules()
		return filterAllInstances(function(instance)
			return instance:IsA("ModuleScript")
		end)
	end
	
	getloadedmodules = getmodules
	getrunningmodules = getmodules
	
	-- * other instance functions
	
	function gethui()
		return hidden_ui_container
	end
	
	function isscriptable(instance, property_name)
		local ok, Result = xpcall(instance.GetPropertyChangedSignal, function(result)
			return result
		end, instance, property_name)
	
		return ok or not string.find(Result, "scriptable", nil, true)
	end
	
	function fireclickdetector(clickdetector, distance)
		assert(typeof(clickdetector) == "Instance" and clickdetector:IsA("ClickDetector"), `arg #1 must be ClickDetector`)
		if distance ~= nil then
			assert(type(distance) == "number", `arg #2 must be type number`)
		end
		local oldCDMaxActivationDistance = clickdetector.MaxActivationDistance
		local oldCDParent = clickdetector.Parent
		local tmpPart = Instance.new("Part")
		tmpPart.Parent = workspace
		tmpPart.CanCollide = false
		tmpPart.Anchored = true
		tmpPart.Transparency = 1
		tmpPart.Size = Vector3.new(30, 30, 30)
		clickdetector.Parent = tmpPart
		clickdetector.MaxActivationDistance = 9e9
	
		local hb
		hb = game:GetService("RunService").Heartbeat:Connect(function()
			tmpPart.CFrame = workspace.Camera.CFrame
				* CFrame.new(0, 0, -20)
				* CFrame.new(
					workspace.Camera.CFrame.LookVector.X,
					workspace.Camera.CFrame.LookVector.Y,
					workspace.Camera.CFrame.LookVector.Z
				)
			game:GetService("VirtualUser")
				:ClickButton1(Vector2.new(20, 20), workspace:FindFirstChildOfClass("Camera").CFrame)
		end)
	
		clickdetector.MouseClick:Once(function()
			hb:Disconnect()
			clickdetector.MaxActivationDistance = oldCDMaxActivationDistance
			clickdetector.Parent = oldCDParent
			tmpPart:Destroy()
		end)
	end
	
	function fireproximityprompt(proximityprompt, amount, skip)
		assert(
			typeof(proximityprompt) == "Instance" and proximityprompt:IsA("ProximityPrompt"),
			`arg #1 must be ProximityPrompt`
		)
	
		if amount ~= nil then
			assert(type(amount) == "number", `arg #2 must be type number`)
			if skip ~= nil then
				assert(type(skip) == "boolean", `arg #3 must be type boolean`)
			end
		end
	
		local oldHoldDuration = proximityprompt.HoldDuration
		local oldMaxDistance = proximityprompt.MaxActivationDistance
	
		proximityprompt.MaxActivationDistance = 9e9
		proximityprompt:InputHoldBegin()
	
		for i = 1, amount or 1 do
			if skip then
				proximityprompt.HoldDuration = 0
			else
				task.wait(proximityprompt.HoldDuration + 0.01)
			end
		end
	
		proximityprompt:InputHoldEnd()
		proximityprompt.MaxActivationDistance = oldMaxDistance
		proximityprompt.HoldDuration = oldHoldDuration
	end
	
	local Bridge = {
		main_container = Instance.new("Folder"),
	
		module_holder = Instance.new("ObjectValue"),
		executing_script = nil,
	
		channels_container = Instance.new("Folder"),
	
		sessions = {},
		queued_datas = {},
	
		recieved_actions_list = {},
		action_callbacks = {},
	}

	local bridge_parent = game:GetService("RobloxReplicatedStorage")

	Bridge.module_holder.Name = "ModuleHolder"
	Bridge.module_holder.Parent = Bridge.main_container

	Bridge.channels_container.Name = "Channels"
	Bridge.channels_container.Parent = Bridge.main_container

	Bridge.main_container.Name = "Bridge"
	Bridge.main_container.Parent = bridge_parent

	local bridge = table.create(0)
	
	bridge.main_container = Instance.new("Folder")
	bridge.module_holder = Instance.new("ObjectValue")
	bridge.loadstring_holder = Instance.new("ObjectValue")
	bridge.execution = Instance.new("BoolValue")
	bridge.players = Instance.new("StringValue")

	bridge.executing_script = nil
	bridge.loadstring_script = nil
	
	bridge.main_container.Name = "Bridge"
	bridge.main_container.Parent = game:FindService("CoreGui")

	--[[
		if script.Name == "LuaSocialLibrariesDeps" or script.Name == "PolicyService" then
		bridge.main_container.Parent = game:FindService("CoreGui").RobloxGui.Modules.CoreUtility
		else
			bridge.main_container.Parent = game:FindService("CoreGui")
		end
	]]

	bridge.execution.Name = "Execution"
	bridge.execution.Parent = bridge.main_container

	bridge.players.Name = "LunaPlayers"
	bridge.players.Parent = bridge.main_container
	bridge.players.Value = players.LocalPlayer.Name

	bridge.module_holder.Name = "ModuleHolder"
	bridge.module_holder.Parent = bridge.main_container
	
	bridge.loadstring_holder.Name = "LoadstringHolder"
	bridge.loadstring_holder.Parent = bridge.main_container

	bridge.executing_script = fetch_stubmodule():Clone()
	bridge.module_holder.Value = bridge.executing_script
	
	bridge.loadstring_script = fetch_stubmodule():Clone()
	bridge.loadstring_holder.Value = bridge.loadstring_script
	
	local indicator = Instance.new("BoolValue")
	indicator.Name = "Initialized"
	indicator.Parent = script
	
	function bridge:post(action, data)
		local success, res = pcall(function()
			local url = "http://localhost:3000/bridge?action=" .. action
			local requestBody = HttpService:JSONEncode(data)
			local params = {
				Url = url,
				Method = "POST",
				Body = requestBody,
				Headers = {
					["Content-Type"] = "application/json"
				}
			}
	
			local request = HttpService:RequestInternal(params)

			local response = nil

			request:Start(function(success, result)

				if success then
					response = result
				else
					response = {}
				end

			end)

			while (response == nil) do 
				task.wait() 
			end

			if response.StatusMessage == "OK" then 
				return HttpService:JSONDecode(response.Body) 
			end

		end)
		if not success then
			return "ERROR: " .. tostring(res)
		else
			return res
		end
	end
	
	function bridge:request(data, from)
		local success, res = pcall(function()
			if data.Method then data.Method = data.Method:upper() end
			local heads
			for t, v in data do
				if t:lower() == "headers" then
					heads = v
					break
				end
			end
	
			if not heads then
				heads = table.create(0)
			end
	
			data.Headers = heads
			data.Headers["Roblox-Place-Id"] = tostring(game.PlaceId)
			data.Headers["Roblox-Game-Id"] = tostring(game.JobId)
			data.Headers["Roblox-Session-Id"] = HttpService:JSONEncode({
				["GameId"] = tostring(game.JobId),
				["PlaceId"] = tostring(game.PlaceId)
			})
	
			if from then
				data.Headers["User-Agent"] = "Roblox/WinInet"
			end
	
			local url = "http://localhost:3000/bridge?action=request"
	
			local request = HttpService:RequestInternal({
				Url = url,
				Method = "POST",
				Body = HttpService:JSONEncode({
					source=source,
					type="request",
					body=HttpService:JSONEncode(data)
				}),
				Headers = {
					["Content-Type"] = "application/json",
				}
			})
	
			local response = nil

			request:Start(function(success, result)

				--print(success, result)

				if success then
					response = result
				else
					response = {}
				end

			end)

			while (response == nil) do 
				task.wait() 
			end

			return HttpService:JSONDecode(response.Body)
		end)
		if not success then
			return "ERROR: " .. tostring(res)
		else
			return res
		end
	end
	
	function bridge:json(response)
		local success, res = pcall(function()
			return HttpService:JSONDecode(response.Body) 
		end)
		return res
	end
	
	function bridge:send(action, ...) 
		local args = {...}
		local success, res = pcall(function()
			local url = "http://localhost:3000/bridge?action=" .. action
			for i, arg in ipairs(args) do
				url = url .. "&" .. arg.arg .. "=" .. HttpService:UrlEncode(tostring(arg.value))
			end
	
			local PlaceId = game.PlaceId
			local GameId = game.JobId
	
			local params = {
				Url = url,
				Method = "GET",
				Headers = {
					["Content-Type"] = "application/json",
				}
			}

			local request = HttpService:RequestInternal(params)
			local response = nil

			request:Start(function(success, result)

				if success then
					response = result
				else
					response = {}
				end

			end)

			while (response == nil) do  
				task.wait() 
			end

			return HttpService:JSONDecode(tostring(response.Body))
		end)
		if not success then
			return "ERROR: " .. tostring(res)
		else
			return res
		end
	end
	
	function getobjects(assetid)
		if type(assetid) == "number" then
			assetid = "rbxassetid://" .. assetid
		end
		return { game:GetService("InsertService"):LoadLocalAsset(assetid) }
	end
	
	local httpContentTypeToHeader
	do
		-- * Keep this updated https://github.com/MaximumADHD/Roblox-Client-Tracker/blob/roblox/LuaPackages/Packages/_Index/HttpServiceMock/HttpServiceMock/httpContentTypeToHeader.lua
		-- * https://create.roblox.com/docs/reference/engine/enums/HttpContentType
		local httpContentTypeToHeaderLookup = {
			[Enum.HttpContentType.ApplicationJson] = "application/json",
			[Enum.HttpContentType.ApplicationUrlEncoded] = "application/x-www-form-urlencoded",
			[Enum.HttpContentType.ApplicationXml] = "application/xml",
			[Enum.HttpContentType.TextPlain] = "text/plain",
			[Enum.HttpContentType.TextXml] = "text/xml",
		}
	
		httpContentTypeToHeader = function(httpContentType: Enum.HttpContentType): string
			local value = httpContentTypeToHeaderLookup[httpContentType]
			assert(value, "Unable to map Enum.HttpContentType to Content-Type. Use a Content-Type string instead")
			return value
		end
	end

	local function find(t, x)
		x = string.gsub(tostring(x), '\0', '') -- sometimes people will use null chars to bypass
		for i, v in t do
			if v:lower() == x:lower() then
				return true
			end
		end
	end

	local function setupBlockedServiceFuncs(serviceTable)
		serviceTable.proxy = newproxy(true)
		local proxyMt = getmetatable(serviceTable.proxy)
	
		proxyMt.__index = function(self, index)
			index = string.gsub(tostring(index), '\0', '')
			if find(serviceTable[1], index) then
				return function(self, ...)
					error("Attempt to call a blocked function: " .. index, 2)
				end
			end
	
			if index == "Parent" then
				return game
			end
	
			if type(serviceTable[2][index]) == "function" then
				return function(self, ...)
					return serviceTable[2][index](serviceTable[2], ...)
				end
			else
				return serviceTable[2][index]
			end
		end
	
		proxyMt.__newindex = function(self, index, value)
			serviceTable[2][index] = value
		end
	
		proxyMt.__tostring = function(self)
			return serviceTable[2].Name
		end
	
		proxyMt.__metatable = getmetatable(serviceTable[2])
	end

	for i, serviceTable in proxiedServices do
		setupBlockedServiceFuncs(serviceTable)
	end
	
	local real = {}

	--[[
	local WRAPPED = setmetatable({}, { __mode = "k" })
	local REAL_OBJECT = setmetatable({}, { __mode = "k" })
	local oldInstanceNew = Instance.new
	local TS = game:GetService("TweenService")
	local oldCreate = TS.Create

	local function unwrapIfProxy(value)
		return REAL_OBJECT[value] or value
	end

	local SpecialHooks = {
		HttpGet = function(url, arg2, arg3)
			assert(type(url) == "string", "arg #1 must be type string")
			assert(url ~= "",            "arg #1 cannot be empty")

			local args = {
				Method = "GET",
				Url = url,
			}

			local arg3_type = typeof(arg3)
			if arg3_type == "table" then
				args.Headers = arg3
			elseif arg3_type == "EnumItem" and arg3.EnumType == Enum.HttpRequestType then
				arg2 = arg3
			end
			if typeof(arg2) == "boolean" and arg2 then
				args.Headers = args.Headers or {}
				args.Headers["Cache-Control"] = "no-cache"
			end

			return bridge:request(args, true).Body
		end,

		HttpPost = function(url, data, arg3, arg4, arg5)
			assert(type(url) == "string",  "arg #1 must be type string")
			assert(url ~= "",             "arg #1 cannot be empty")

			local args = {
				Method = "POST",
				Url = url,
				Body = data,
			}
			if type(arg3) == "boolean" then
				arg3, arg4, arg5 = arg4, arg5, nil
			end
			if arg5 then
				args.Headers = arg3
			end
			if arg3 then
				args.Headers = args.Headers or {}
				args.Headers["Content-Type"] =
					(type(arg3) == "string")
					and arg3
					or httpContentTypeToHeader(arg3)
			end
			if typeof(arg4) == "boolean" and arg4 then
				args.Headers = args.Headers or {}
				args.Headers["Content-Encoding"] = "gzip"
			end

			return bridge:request(args, true).Body
		end,

		GetObjects = function(assetid)
			return getobjects(assetid)
		end,

		Create = function(self, tweenInfo, properties)
			print("tween service...")
			return oldCreate(self, unwrapIfProxy(tweenInfo), unwrapIfProxy(properties))
		end,
	}

	SpecialHooks.HttpGetAsync  = SpecialHooks.HttpGet
	SpecialHooks.HttpPostAsync = SpecialHooks.HttpPost

	local function wrapIfNeeded(obj)
		local luaType = type(obj)
		local robloxType = typeof(obj)

		if luaType ~= "userdata" and robloxType ~= "Instance" and obj ~= Instance and obj ~= game.TweenService then
			--return obj
		end

		local existingProxy = WRAPPED[obj]
		if existingProxy then
			return existingProxy
		end

		local proxy = newproxy(true)
		local meta = getmetatable(proxy)

		WRAPPED[obj] = proxy
		REAL_OBJECT[proxy] = obj

		meta.__index = function(t, index)
			local hookFunc = SpecialHooks[index]
			if hookFunc then
				return function(_, ...)
					return hookFunc(...)
				end
			end

			local real = REAL_OBJECT[t]
			local rawValue = real[index]

			if type(rawValue) == "function" then

				if index == "new" then
					return function(className, parent)
						local realObj = oldInstanceNew(className)
						local proxy = wrapIfNeeded(realObj)
						if parent then
							proxy.Parent = parent
						end
						return proxy
					end
				end

				return function(self, ...)

					if index == "GetService" or index == "FindService" then
						local args = {...}
						if proxiedServices and proxiedServices[string.gsub(tostring(args[1]), '\0', '')] then
							return proxiedServices[string.gsub(args[1], '\0', '')].proxy
						end
					end

					if find({
						"Load",
						"OpenScreenshotsFolder",
						"OpenVideosFolder"
					}, index) then
						error("Attempt to call a blocked function: " .. tostring(index), 2)
					end

					local results = { rawValue(real, ...) }

					for i = 1, #results do
						results[i] = unwrapIfProxy(results[i])
					end

					return table.unpack(results)

					--return towrap[index](towrap, ...)
				end
			end

			if type(rawValue) == "userdata" or typeof(rawValue) == "Instance" then
				return wrapIfNeeded(rawValue)
			end

			return rawValue
		end

		meta.__newindex = function(t, index, newVal)
			local real = REAL_OBJECT[t]
			real[index] = unwrapIfProxy(newVal)
		end

		meta.__tostring = function()
			return tostring(REAL_OBJECT[proxy])
		end

		meta.__metatable = getmetatable(REAL_OBJECT[proxy])

		return proxy
	end

	-- Wrap core globals
	getgenv().game = wrapIfNeeded(game)
	getgenv().Game = wrapIfNeeded(Game)
	getgenv().Workspace = wrapIfNeeded(Workspace)
	getgenv().workspace = wrapIfNeeded(workspace)
	getgenv().Instance = wrapIfNeeded(Instance)
	getgenv().TweenService = wrapIfNeeded(TS)
	]]

	local SpecialHooks = {
		HttpGet = function(url, arg2, arg3)
			assert(type(url) == "string", "arg #1 must be type string")
			assert(url ~= "",            "arg #1 cannot be empty")

			local args = {
				Method = "GET",
				Url = url,
			}

			local arg3_type = typeof(arg3)
			if arg3_type == "table" then
				args.Headers = arg3
			elseif arg3_type == "EnumItem" and arg3.EnumType == Enum.HttpRequestType then
				arg2 = arg3
			end
			if typeof(arg2) == "boolean" and arg2 then
				args.Headers = args.Headers or {}
				args.Headers["Cache-Control"] = "no-cache"
			end

			return bridge:request(args, true).Body
		end,

		HttpPost = function(url, data, arg3, arg4, arg5)
			assert(type(url) == "string",  "arg #1 must be type string")
			assert(url ~= "",             "arg #1 cannot be empty")

			local args = {
				Method = "POST",
				Url = url,
				Body = data,
			}
			if type(arg3) == "boolean" then
				arg3, arg4, arg5 = arg4, arg5, nil
			end
			if arg5 then
				args.Headers = arg3
			end
			if arg3 then
				args.Headers = args.Headers or {}
				args.Headers["Content-Type"] =
					(type(arg3) == "string")
					and arg3
					or httpContentTypeToHeader(arg3)
			end
			if typeof(arg4) == "boolean" and arg4 then
				args.Headers = args.Headers or {}
				args.Headers["Content-Encoding"] = "gzip"
			end

			return bridge:request(args, true).Body
		end,

		GetObjects = function(assetid)
			return getobjects(assetid)
		end,
	}

	SpecialHooks.HttpGetAsync  = SpecialHooks.HttpGet
	SpecialHooks.HttpPostAsync = SpecialHooks.HttpPost

	local function wrapInstance(instance)
		if typeof(instance) ~= "Instance" then
			return instance
		end
		return setmetatable({
			__instance = instance,
			__proxied = true
		}, {
			__index = function(_, key)
				local hookFunc = SpecialHooks[key]
				if hookFunc then
					return function(_, ...)
						return hookFunc(...)
					end
				end
				local value = instance[key]
				if typeof(value) == "function" then
					return function(self, ...)
						if key == "GetService" or key == "FindService" then
							local args = {...}
							if proxiedServices[string.gsub(tostring(args[1]), '\0', '')] then
								return proxiedServices[string.gsub(args[1], '\0', '')].proxy
							end
						end
						if find({"Load","OpenScreenshotsFolder","OpenVideosFolder"}, key) then
							error("Attempt to call a blocked function: " .. tostring(key), 2)
						end
						return table.unpack({ value(instance, ...) })
					end
				end
				if proxiedServices[key] then
					return proxiedServices[key].proxy
				end
				return value
			end,
			__newindex = function(_, key, value) instance[key] = value end,
			__metatable = getmetatable(instance),
			__tostring = function() return tostring(instance) end
		})
	end

	getgenv().game = wrapInstance(game)
	getgenv().Game = wrapInstance(Game)
	
	function isscriptable(instance, property_name)
		local ok, Result = xpcall(instance.GetPropertyChangedSignal, function(result)
			return result
		end, instance, property_name)

		return ok or not string.find(Result, "scriptable", nil, true)
	end
	
	function setscriptable(instance, property_name, scriptable)
		assert(typeof(instance) == "Instance", `arg #1 must be type Instance`)
		assert(type(property_name) == "string", `arg #2 must be type string`)
		assert(type(scriptable) == "boolean", `arg #3 must be type bolean`)
		if isscriptable(instance, property_name) then
			return false
		end
		setaddressholder.Value = instance
		setaddressholder_bool.Value = scriptable
		local data = bridge:send("setscriptable", {arg="value",value=property_name})
		return data.status
	end
	
	function getproperties(instance)
		assert(typeof(instance) == "Instance", `arg #1 must be type Instance`)
		setaddressholder.Value = instance
	
		local data = bridge:send("getproperties", {arg="value",value="1"})
	
		local container = table.create(0)
	
		for name, value in data.content do
			if string.match(value, ":") then
				local name, value = unpack((value):split(":"))
				container[name] = (value == "true")
			else
				container[value] = "STUB_VALUE"
			end
		end
	
		return container
	end
	
	function gethiddenproperties(instance)
		assert(typeof(instance) == "Instance", `arg #1 must be type Instance`)
	
		local hidden_properties = {}
	
		for property_name, value in getproperties(instance) do
			if not isscriptable(instance, property_name) then
				hidden_properties[property_name] = value
			end
		end
	
		return hidden_properties
	end
	
	function gethiddenproperty(instance, property_name)
		assert(typeof(instance) == "Instance", `arg #1 must be type Instance`)
		assert(type(property_name) == "string", `arg #2 must be type string`)
		if isscriptable(instance, property_name) then
			return instance[property_name]
		end
	
		return gethiddenproperties(instance)[property_name]
	end
	
	function sethiddenproperty(instance, property_name, value)
		assert(typeof(instance) == "Instance", `arg #1 must be type Instance`)
		assert(type(property_name) == "string", `arg #2 must be type string`)
	
		local was_scriptable = setscriptable(instance, property_name, true)
		local o, err = pcall(function()
			instance[property_name] = value
		end)
		if not was_scriptable then
			setscriptable(instance, property_name, was_scriptable)
		end
		if o then
			return was_scriptable
		else
			error(err, 2)
		end
	end
	
	function iscclosure(func)
		assert(type(func) == "function", `arg #1 must be type function`)
		return debug.info(func, "s") == "[C]"
	end
	
	function islclosure(func)
		assert(type(func) == "function", `arg #1 must be type function`)
		return debug.info(func, "s") ~= "[C]"
	end
	
	function getscripthash(src)
		return src:GetHash()
	end
	
	function getcallingscript(stackCount: number)
		stackCount = stackCount or 3
	
		for stackLvl = stackCount, 0, -1 do
			local func = debug.info(stackLvl, "f")
			stackLvl -= 1
			if not func then
				continue
			end
	
			local script = rawget(getfenv(func), "script")
	
			if typeof(script) == "Instance" and script:IsA("BaseScript") then
				return script
			end
		end
	end
	
	local function newWrappedCClosure(func)
		if iscclosure(func) then
			return func
		end
	
		return coroutine.wrap(function(...)
			local args = { ... }
	
			while true do
				args = { coroutine.yield(func(unpack(args))) }
			end
		end)
	end
	
	function newcclosure(func)
		assert(type(func) == "function", `arg #1 must be type function`)
		return newWrappedCClosure(func)
	end
	
	function newlclosure(func)
		return function(...)
			return func(...)
		end
	end
	
	function isexecutorclosure(func)
		if iscclosure(func) then
			return debug.info(func, "n") == "" -- * Hopefully there aren't any false positives
		end
		local f_env = getfenv(func)
		return f_env.script.Parent == nil or f_env == getfenv(0) -- TODO The second part can be fooled if isexecutorclosure(HijackedModule.Function)
	end
	
	function clonefunction(func)
		return if iscclosure(func) then newcclosure(func) else newlclosure(func)
	end
	
	function securecall(func, scriptOrEnv, ...): ...any
		assert(type(func) == "function", `arg #1 must be type function`)
	
		local type_scriptOrEnv = typeof(scriptOrEnv)
		local virtual_env
		do
			if type_scriptOrEnv == "Instance" and scriptOrEnv:IsA("LuaScriptContainer") then
				virtual_env = setmetatable({}, { __index = getrenv() })
				virtual_env.script = scriptOrEnv
			elseif type_scriptOrEnv == "table" then
				virtual_env = scriptOrEnv
			else
				return error(`invalid argument #2 (LuaSourceContainer | table expected, got {type_scriptOrEnv})`, 2)
			end
		end
	
		return coroutine.wrap(function(...)
			setfenv(0, virtual_env)
			setfenv(1, virtual_env)
	
			return func(...)
		end)(...)
	end
	
	getthread = coroutine.running
	checkclosure = isexecutorclosure
	isourclosure = isexecutorclosure

	local calledexec = false

	coroutine.wrap(function()
		while true do
			if bridge.execution.Value == true then

				while calledexec do
					task.wait()
				end

				local script_load = bridge.module_holder.Value
				local original = script_load.Name

				script_load.Name = "NX"
	
				local s, func = pcall(_require, script_load)

				script_load.Name = original

				bridge.execution.Value = false
				calledexec = false

				local new_module = fetch_stubmodule():Clone()
				bridge.module_holder.Value = new_module
				bridge.executing_script = new_module
				script_load:Destroy()

				if s and type(func) == "function" then
					setfenv(func,  setmetatable({}, {__index = getfenv()}))
					task.defer(function()
						local success, err = pcall(func)
						if not success then
							warn(err)
						end
					end)
				end
			end
			wait(0.005)
		end
	end)()
	
	loadstring = (function(source, chunkname)

		if chunkname == nil then chunkname = "NX" end
		if chunkname == "" then chunkname = "NX" end
		
		while justcalledlocal do
			task.wait()
		end
	
		justcalledlocal = true
	
		bridge:post("loadstring", {source=source,type="loadstring"})
	
		local script_load = bridge.loadstring_holder.Value
		local original = script_load.Name
		script_load.Name = chunkname
	
		local s, func = pcall(require, script_load)
		script_load.Name = original

		justcalledlocal = false

		local new_module = fetch_stubmodule():Clone()
		bridge.loadstring_holder.Value = new_module
		bridge.loadstring_script = new_module
		script_load:Destroy()
	
		if s and type(func) == "function" then
			setfenv(func,  setmetatable({}, {__index = getfenv()}))
	
			return func
		end
	end)

	function require(moduleScript)
		assert(typeof(moduleScript) == "Instance", "Attempted to call require with invalid argument(s). ", 2)
		assert(moduleScript.ClassName == "ModuleScript", "Attempted to call require with invalid argument(s). ", 2)
	
		local objectValue = Instance.new("ObjectValue", game.CoreGui)
		objectValue.Name = "requireThis"
		objectValue.Value = moduleScript
	
		local data = bridge:post("require", {type="require"})

		if type(data) == "table" then
			if data.status == false then
				error(data.content)
			end
		end

		objectValue:Destroy()
	
		return _require(moduleScript)
	end
	
	identifyexecutor = function()
		return "NX", "1.0"
	end
	getexecutorname = identifyexecutor
	
	http = {}
	request = (function(data)
		return bridge:request(data)
	end)
	
	setclipboard = function(text)
		bridge:send("setclipboard", {arg="value",value=text})
	end
	
	toclipboard = setclipboard

	function setreadonly(t, lock)
		if table.isfrozen(t) then
			if lock then
				return
			end
			-- unlock code here
		else
			if not lock then
				return
			end
			table.freeze(t)
		end
	end

	isreadonly = table.isfrozen
	
	--[[
	ADVANCED ENCRYPTION STANDARD (AES)
	
	Implementation of secure symmetric-key encryption specifically in Luau
	Includes ECB, CBC, PCBC, CFB, OFB and CTR modes without padding.
	Made by @RobloxGamerPro200007 (verify the original asset)
	
	MORE INFORMATION: https://devforum.roblox.com/t/advanced-encryption-standard-in-luau/2009120
	]]
	-- Taken from https://devforum.roblox.com/t/advanced-encryption-standard-in-luau/ WITH PATCHES
	
	-- SUBSTITUTION BOXES
	local s_box 	= { 99, 124, 119, 123, 242, 107, 111, 197,  48,   1, 103,  43, 254, 215, 171, 118, 202,
		130, 201, 125, 250,  89,  71, 240, 173, 212, 162, 175, 156, 164, 114, 192, 183, 253, 147,  38,  54,
		63, 247, 204,  52, 165, 229, 241, 113, 216,  49,  21,   4, 199,  35, 195,  24, 150,   5, 154,   7,
		18, 128, 226, 235,  39, 178, 117,   9, 131,  44,  26,  27, 110,  90, 160,  82,  59, 214, 179,  41,
		227,  47, 132,  83, 209,   0, 237,  32, 252, 177,  91, 106, 203, 190,  57,  74,  76,  88, 207, 208,
		239, 170, 251,  67,  77,  51, 133,  69, 249,   2, 127,  80,  60, 159, 168,  81, 163,  64, 143, 146,
		157,  56, 245, 188, 182, 218,  33,  16, 255, 243, 210, 205,  12,  19, 236,  95, 151,  68,  23, 196,
		167, 126,  61, 100,  93,  25, 115,  96, 129,  79, 220,  34,  42, 144, 136,  70, 238, 184,  20, 222,
		94,  11, 219, 224,  50,  58,  10,  73,   6,  36,  92, 194, 211, 172,  98, 145, 149, 228, 121, 231,
		200,  55, 109, 141, 213,  78, 169, 108,  86, 244, 234, 101, 122, 174,   8, 186, 120,  37,  46,  28,
		166, 180, 198, 232, 221, 116,  31,  75, 189, 139, 138, 112,  62, 181, 102,  72,   3, 246,  14,  97,
		53,  87, 185, 134, 193,  29, 158, 225, 248, 152,  17, 105, 217, 142, 148, 155,  30, 135, 233, 206,
		85,  40, 223, 140, 161, 137,  13, 191, 230,  66, 104,  65, 153,  45,  15, 176,  84, 187,  22}
	local inv_s_box	= { 82,   9, 106, 213,  48,  54, 165,  56, 191,  64, 163, 158, 129, 243, 215, 251, 124,
		227,  57, 130, 155,  47, 255, 135,  52, 142,  67,  68, 196, 222, 233, 203,  84, 123, 148,  50, 166,
		194,  35,  61, 238,  76, 149,  11,  66, 250, 195,  78,   8,  46, 161, 102,  40, 217,  36, 178, 118,
		91, 162,  73, 109, 139, 209,  37, 114, 248, 246, 100, 134, 104, 152,  22, 212, 164,  92, 204,  93,
		101, 182, 146, 108, 112,  72,  80, 253, 237, 185, 218,  94,  21,  70,  87, 167, 141, 157, 132, 144,
		216, 171,   0, 140, 188, 211,  10, 247, 228,  88,   5, 184, 179,  69,   6, 208,  44,  30, 143, 202,
		63,  15,   2, 193, 175, 189,   3,   1,  19, 138, 107,  58, 145,  17,  65,  79, 103, 220, 234, 151,
		242, 207, 206, 240, 180, 230, 115, 150, 172, 116,  34, 231, 173,  53, 133, 226, 249,  55, 232,  28,
		117, 223, 110,  71, 241,  26, 113,  29,  41, 197, 137, 111, 183,  98,  14, 170,  24, 190,  27, 252,
		86,  62,  75, 198, 210, 121,  32, 154, 219, 192, 254, 120, 205,  90, 244,  31, 221, 168,  51, 136,
		7, 199,  49, 177,  18,  16,  89,  39, 128, 236,  95,  96,  81, 127, 169,  25, 181,  74,  13,  45,
		229, 122, 159, 147, 201, 156, 239, 160, 224,  59,  77, 174,  42, 245, 176, 200, 235, 187,  60, 131,
		83, 153,  97,  23,  43,   4, 126, 186, 119, 214,  38, 225, 105,  20,  99,  85,  33,  12, 125}
	
	-- ROUND CONSTANTS ARRAY
	local rcon = {  0,   1,   2,   4,   8,  16,  32,  64, 128,  27,  54, 108, 216, 171,  77, 154,  47,  94,
		188,  99, 198, 151,  53, 106, 212, 179, 125, 250, 239, 197, 145,  57}
	-- MULTIPLICATION OF BINARY POLYNOMIAL
	local function xtime(x)
		local i = bit32.lshift(x, 1)
		return if bit32.band(x, 128) == 0 then i else bit32.bxor(i, 27) % 256
	end
	
	-- TRANSFORMATION FUNCTIONS
	local function subBytes		(s, inv) 		-- Processes State using the S-box
		inv = if inv then inv_s_box else s_box
		for i = 1, 4 do
			for j = 1, 4 do
				s[i][j] = inv[s[i][j] + 1]
			end
		end
	end
	local function shiftRows		(s, inv) 	-- Processes State by circularly shifting rows
		s[1][3], s[2][3], s[3][3], s[4][3] = s[3][3], s[4][3], s[1][3], s[2][3]
		if inv then
			s[1][2], s[2][2], s[3][2], s[4][2] = s[4][2], s[1][2], s[2][2], s[3][2]
			s[1][4], s[2][4], s[3][4], s[4][4] = s[2][4], s[3][4], s[4][4], s[1][4]
		else
			s[1][2], s[2][2], s[3][2], s[4][2] = s[2][2], s[3][2], s[4][2], s[1][2]
			s[1][4], s[2][4], s[3][4], s[4][4] = s[4][4], s[1][4], s[2][4], s[3][4]
		end
	end
	local function addRoundKey	(s, k) 			-- Processes Cipher by adding a round key to the State
		for i = 1, 4 do
			for j = 1, 4 do
				s[i][j] = bit32.bxor(s[i][j], k[i][j])
			end
		end
	end
	local function mixColumns	(s, inv) 		-- Processes Cipher by taking and mixing State columns
		local t, u
		if inv then
			for i = 1, 4 do
				t = xtime(xtime(bit32.bxor(s[i][1], s[i][3])))
				u = xtime(xtime(bit32.bxor(s[i][2], s[i][4])))
				s[i][1], s[i][2] = bit32.bxor(s[i][1], t), bit32.bxor(s[i][2], u)
				s[i][3], s[i][4] = bit32.bxor(s[i][3], t), bit32.bxor(s[i][4], u)
			end
		end
	
		local i
		for j = 1, 4 do
			i = s[j]
			t, u = bit32.bxor		(i[1], i[2], i[3], i[4]), i[1]
			for k = 1, 4 do
				i[k] = bit32.bxor	(i[k], t, xtime(bit32.bxor(i[k], i[k + 1] or u)))
			end
		end
	end
	
	-- BYTE ARRAY UTILITIES
	local function bytesToMatrix	(t, c, inv) -- Converts a byte array to a 4x4 matrix
		if inv then
			table.move		(c[1], 1, 4, 1, t)
			table.move		(c[2], 1, 4, 5, t)
			table.move		(c[3], 1, 4, 9, t)
			table.move		(c[4], 1, 4, 13, t)
		else
			for i = 1, #c / 4 do
				table.clear	(t[i])
				table.move	(c, i * 4 - 3, i * 4, 1, t[i])
			end
		end
	
		return t
	end
	local function xorBytes		(t, a, b) 		-- Returns bitwise XOR of all their bytes
		table.clear		(t)
	
		for i = 1, math.min(#a, #b) do
			table.insert(t, bit32.bxor(a[i], b[i]))
		end
		return t
	end
	local function incBytes		(a, inv)		-- Increment byte array by one
		local o = true
		for i = if inv then 1 else #a, if inv then #a else 1, if inv then 1 else - 1 do
			if a[i] == 255 then
				a[i] = 0
			else
				a[i] += 1
				o = false
				break
			end
		end
	
		return o, a
	end
	
	-- MAIN ALGORITHM
	local function expandKey	(key) 				-- Key expansion
		local kc = bytesToMatrix(if #key == 16 then {{}, {}, {}, {}} elseif #key == 24 then {{}, {}, {}, {}
			, {}, {}} else {{}, {}, {}, {}, {}, {}, {}, {}}, key)
		local is = #key / 4
		local i, t, w = 2, {}, nil
	
		while #kc < (#key / 4 + 7) * 4 do
			w = table.clone	(kc[#kc])
			if #kc % is == 0 then
				table.insert(w, table.remove(w, 1))
				for j = 1, 4 do
					w[j] = s_box[w[j] + 1]
				end
				w[1]	 = bit32.bxor(w[1], rcon[i])
				i 	+= 1
			elseif #key == 32 and #kc % is == 4 then
				for j = 1, 4 do
					w[j] = s_box[w[j] + 1]
				end
			end
	
			table.clear	(t)
			xorBytes	(w, table.move(w, 1, 4, 1, t), kc[#kc - is + 1])
			table.insert(kc, w)
		end
	
		table.clear		(t)
		for i = 1, #kc / 4 do
			table.insert(t, {})
			table.move	(kc, i * 4 - 3, i * 4, 1, t[#t])
		end
		return t
	end
	local function encrypt	(key, km, pt, ps, r) 	-- Block cipher encryption
		bytesToMatrix	(ps, pt)
		addRoundKey		(ps, km[1])
	
		for i = 2, #key / 4 + 6 do
			subBytes	(ps)
			shiftRows	(ps)
			mixColumns	(ps)
			addRoundKey	(ps, km[i])
		end
		subBytes		(ps)
		shiftRows		(ps)
		addRoundKey		(ps, km[#km])
	
		return bytesToMatrix(r, ps, true)
	end
	local function decrypt	(key, km, ct, cs, r) 	-- Block cipher decryption
		bytesToMatrix	(cs, ct)
	
		addRoundKey		(cs, km[#km])
		shiftRows		(cs, true)
		subBytes		(cs, true)
		for i = #key / 4 + 6, 2, - 1 do
			addRoundKey	(cs, km[i])
			mixColumns	(cs, true)
			shiftRows	(cs, true)
			subBytes	(cs, true)
		end
	
		addRoundKey		(cs, km[1])
		return bytesToMatrix(r, cs, true)
	end
	
	-- INITIALIZATION FUNCTIONS
	local function convertType	(a) 					-- Converts data to bytes if possible
		if type(a) == "string" then
			local r = {}
	
			for i = 1, string.len(a), 7997 do
				table.move({string.byte(a, i, i + 7996)}, 1, 7997, i, r)
			end
			return r
		elseif type(a) == "table" then
			for _, i in a do
				assert(type(i) == "number" and math.floor(i) == i and 0 <= i and i < 256,
					"Unable to cast value to bytes")
			end
			return a
		else
			error("Unable to cast value to bytes")
		end
	end
	local function deepCopy(Original)
		local copy = {}
		for key, val in Original do
			local Type = typeof(val)
			if Type == "table" then
				val = deepCopy(val)
			end
			copy[key] = val
		end
		return copy
	end
	local function init			(key, txt, m, iv, s) 	-- Initializes functions if possible
		key = convertType(key)
		assert(#key == 16 or #key == 24 or #key == 32, "Key must be either 16, 24 or 32 bytes long")
		txt = convertType(txt)
		assert(#txt % (s or 16) == 0, "Input must be a multiple of " .. (if s then "segment size " .. s
			else "16") .. " bytes in length")
		if m then
			if type(iv) == "table" then
				iv = table.clone(iv)
				local l, e 		= iv.Length, iv.LittleEndian
				assert(type(l) == "number" and 0 < l and l <= 16,
					"Counter value length must be between 1 and 16 bytes")
				iv.Prefix 		= convertType(iv.Prefix or {})
				iv.Suffix 		= convertType(iv.Suffix or {})
				assert(#iv.Prefix + #iv.Suffix + l == 16, "Counter must be 16 bytes long")
				iv.InitValue 	= if iv.InitValue == nil then {1} else table.clone(convertType(iv.InitValue
				))
				assert(#iv.InitValue <= l, "Initial value length must be of the counter value")
				iv.InitOverflow = if iv.InitOverflow == nil then table.create(l, 0) else table.clone(
				convertType(iv.InitOverflow))
				assert(#iv.InitOverflow <= l,
					"Initial overflow value length must be of the counter value")
				for _ = 1, l - #iv.InitValue do
					table.insert(iv.InitValue, 1 + if e then #iv.InitValue else 0, 0)
				end
				for _ = 1, l - #iv.InitOverflow do
					table.insert(iv.InitOverflow, 1 + if e then #iv.InitOverflow else 0, 0)
				end
			elseif type(iv) ~= "function" then
				local i, t = if iv then convertType(iv) else table.create(16, 0), {}
				assert(#i == 16, "Counter must be 16 bytes long")
				iv = {Length = 16, Prefix = t, Suffix = t, InitValue = i,
					InitOverflow = table.create(16, 0)}
			end
		elseif m == false then
			iv 	= if iv == nil then  table.create(16, 0) else convertType(iv)
			assert(#iv == 16, "Initialization vector must be 16 bytes long")
		end
		if s then
			s = math.floor(tonumber(s) or 1)
			assert(type(s) == "number" and 0 < s and s <= 16, "Segment size must be between 1 and 16 bytes"
			)
		end
	
		return key, txt, expandKey(key), iv, s
	end
	type bytes = {number} -- Type instance of a valid bytes object
	
	-- CIPHER MODES OF OPERATION
	local aes = {
		-- Electronic codebook (ECB)
		encrypt_ECB = function(key : bytes, plainText : bytes, initVector : bytes?) 									: bytes
			local km
			key, plainText, km, initVector = init(key, plainText, false, initVector)
	
			local iv = deepCopy(initVector)
			local b, k, s, t = {}, {}, {{}, {}, {}, {}}, {}
			for i = 1, #plainText, 16 do
				table.move(plainText, i, i + 15, 1, k)
				table.move(encrypt(key, km, k, s, t), 1, 16, i, b)
			end
	
			return b, iv
		end,
		decrypt_ECB = function(key : bytes, cipherText : bytes, initVector : bytes?) 								: bytes
			local km
			key, cipherText, km = init(key, cipherText, false, initVector)
	
			local b, k, s, t = {}, {}, {{}, {}, {}, {}}, {}
			for i = 1, #cipherText, 16 do
				table.move(cipherText, i, i + 15, 1, k)
				table.move(decrypt(key, km, k, s, t), 1, 16, i, b)
			end
	
			return b
		end,
		-- Cipher block chaining (CBC)
		encrypt_CBC = function(key : bytes, plainText : bytes, initVector : bytes?) 			: bytes
			local km
			key, plainText, km, initVector = init(key, plainText, false, initVector)
			local iv = deepCopy(initVector)
			local b, k, p, s, t = {}, {}, initVector, {{}, {}, {}, {}}, {}
			for i = 1, #plainText, 16 do
				table.move(plainText, i, i + 15, 1, k)
				table.move(encrypt(key, km, xorBytes(t, k, p), s, p), 1, 16, i, b)
			end
	
			return b, iv
		end,
		decrypt_CBC = function(key : bytes, cipherText : bytes, initVector : bytes?) 			: bytes
			local km
			key, cipherText, km, initVector = init(key, cipherText, false, initVector)
	
			local b, k, p, s, t = {}, {}, initVector, {{}, {}, {}, {}}, {}
			for i = 1, #cipherText, 16 do
				table.move(cipherText, i, i + 15, 1, k)
				table.move(xorBytes(k, decrypt(key, km, k, s, t), p), 1, 16, i, b)
				table.move(cipherText, i, i + 15, 1, p)
			end
	
			return b
		end,
		-- Propagating cipher block chaining (PCBC)
		encrypt_PCBC = function(key : bytes, plainText : bytes, initVector : bytes?) 			: bytes
			local km
			key, plainText, km, initVector = init(key, plainText, false, initVector)
			local iv = deepCopy(initVector)
			local b, k, c, p, s, t = {}, {}, initVector, table.create(16, 0), {{}, {}, {}, {}}, {}
			for i = 1, #plainText, 16 do
				table.move(plainText, i, i + 15, 1, k)
				table.move(encrypt(key, km, xorBytes(k, xorBytes(t, c, k), p), s, c), 1, 16, i, b)
				table.move(plainText, i, i + 15, 1, p)
			end
	
			return b, iv
		end,
		decrypt_PCBC = function(key : bytes, cipherText : bytes, initVector : bytes?) 			: bytes
			local km
			key, cipherText, km, initVector = init(key, cipherText, false, initVector)
	
			local b, k, c, p, s, t = {}, {}, initVector, table.create(16, 0), {{}, {}, {}, {}}, {}
			for i = 1, #cipherText, 16 do
				table.move(cipherText, i, i + 15, 1, k)
				table.move(xorBytes(p, decrypt(key, km, k, s, t), xorBytes(k, c, p)), 1, 16, i, b)
				table.move(cipherText, i, i + 15, 1, c)
			end
	
			return b
		end,
		-- Cipher feedback (CFB)
		encrypt_CFB = function(key : bytes, plainText : bytes, initVector : bytes?, segmentSize : number?)
			: bytes
			local km
			key, plainText, km, initVector, segmentSize = init(key, plainText, false, initVector,
				if segmentSize == nil then 1 else segmentSize)
			local iv = deepCopy(initVector)
			local b, k, p, q, s, t = {}, {}, initVector, {}, {{}, {}, {}, {}}, {}
			for i = 1, #plainText, segmentSize do
				table.move(plainText, i, i + segmentSize - 1, 1, k)
				table.move(xorBytes(q, encrypt(key, km, p, s, t), k), 1, segmentSize, i, b)
				for j = 16, segmentSize + 1, - 1 do
					table.insert(q, 1, p[j])
				end
				table.move(q, 1, 16, 1, p)
			end
	
			return b, iv
		end,
		decrypt_CFB = function(key : bytes, cipherText : bytes, initVector : bytes, segmentSize : number?)
			: bytes
			local km
			key, cipherText, km, initVector, segmentSize = init(key, cipherText, false, initVector,
				if segmentSize == nil then 1 else segmentSize)
	
			local b, k, p, q, s, t = {}, {}, initVector, {}, {{}, {}, {}, {}}, {}
			for i = 1, #cipherText, segmentSize do
				table.move(cipherText, i, i + segmentSize - 1, 1, k)
				table.move(xorBytes(q, encrypt(key, km, p, s, t), k), 1, segmentSize, i, b)
				for j = 16, segmentSize + 1, - 1 do
					table.insert(k, 1, p[j])
				end
				table.move(k, 1, 16, 1, p)
			end
	
			return b
		end,
		-- Output feedback (OFB)
		encrypt_OFB = function(key : bytes, plainText : bytes, initVector : bytes?) 			: bytes
			local km
			key, plainText, km, initVector = init(key, plainText, false, initVector)
			local iv = deepCopy(initVector)
			local b, k, p, s, t = {}, {}, initVector, {{}, {}, {}, {}}, {}
			for i = 1, #plainText, 16 do
				table.move(plainText, i, i + 15, 1, k)
				table.move(encrypt(key, km, p, s, t), 1, 16, 1, p)
				table.move(xorBytes(t, k, p), 1, 16, i, b)
			end
	
			return b, iv
		end,
		-- Counter (CTR)
		encrypt_CTR = function(key : bytes, plainText : bytes, counter : ((bytes) -> bytes) | bytes | { [
			string]: any }?) : bytes
			local km
			key, plainText, km, counter = init(key, plainText, true, counter)
			local iv = deepCopy(counter)
			local b, k, c, s, t, r, n = {}, {}, {}, {{}, {}, {}, {}}, {}, type(counter) == "table", nil
			for i = 1, #plainText, 16 do
				if r then
					if i > 1 and incBytes(counter.InitValue, counter.LittleEndian) then
						table.move(counter.InitOverflow, 1, 16, 1, counter.InitValue)
					end
					table.clear	(c)
					table.move	(counter.Prefix, 1, #counter.Prefix, 1, c)
					table.move	(counter.InitValue, 1, counter.Length, #c + 1, c)
					table.move	(counter.Suffix, 1, #counter.Suffix, #c + 1, c)
				else
					n = convertType(counter(c, (i + 15) / 16))
					assert		(#n == 16, "Counter must be 16 bytes long")
					table.move	(n, 1, 16, 1, c)
				end
				table.move(plainText, i, i + 15, 1, k)
				table.move(xorBytes(c, encrypt(key, km, c, s, t), k), 1, 16, i, b)
			end
	
			return b, iv
		end
	} -- Returns the library
	
	--!native
	--!optimize 2
	-- Credits @Reselim
	
	local lookupValueToCharacter = buffer.create(64)
	local lookupCharacterToValue = buffer.create(256)
	
	local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local padding = string.byte("=")
	
	for index = 1, 64 do
		local value = index - 1
		local character = string.byte(alphabet, index)
		
		buffer.writeu8(lookupValueToCharacter, value, character)
		buffer.writeu8(lookupCharacterToValue, character, value)
	end
	
	local function encode(input: buffer): buffer
		local inputLength = buffer.len(input)
		local inputChunks = math.ceil(inputLength / 3)
		
		local outputLength = inputChunks * 4
		local output = buffer.create(outputLength)
		
		-- Since we use readu32 and chunks are 3 bytes large, we can't read the last chunk here
		for chunkIndex = 1, inputChunks - 1 do
			local inputIndex = (chunkIndex - 1) * 3
			local outputIndex = (chunkIndex - 1) * 4
			
			local chunk = bit32.byteswap(buffer.readu32(input, inputIndex))
			
			-- 8 + 24 - (6 * index)
			local value1 = bit32.rshift(chunk, 26)
			local value2 = bit32.band(bit32.rshift(chunk, 20), 0b111111)
			local value3 = bit32.band(bit32.rshift(chunk, 14), 0b111111)
			local value4 = bit32.band(bit32.rshift(chunk, 8), 0b111111)
			
			buffer.writeu8(output, outputIndex, buffer.readu8(lookupValueToCharacter, value1))
			buffer.writeu8(output, outputIndex + 1, buffer.readu8(lookupValueToCharacter, value2))
			buffer.writeu8(output, outputIndex + 2, buffer.readu8(lookupValueToCharacter, value3))
			buffer.writeu8(output, outputIndex + 3, buffer.readu8(lookupValueToCharacter, value4))
		end
		
		local inputRemainder = inputLength % 3
		
		if inputRemainder == 1 then
			local chunk = buffer.readu8(input, inputLength - 1)
			
			local value1 = bit32.rshift(chunk, 2)
			local value2 = bit32.band(bit32.lshift(chunk, 4), 0b111111)
	
			buffer.writeu8(output, outputLength - 4, buffer.readu8(lookupValueToCharacter, value1))
			buffer.writeu8(output, outputLength - 3, buffer.readu8(lookupValueToCharacter, value2))
			buffer.writeu8(output, outputLength - 2, padding)
			buffer.writeu8(output, outputLength - 1, padding)
		elseif inputRemainder == 2 then
			local chunk = bit32.bor(
				bit32.lshift(buffer.readu8(input, inputLength - 2), 8),
				buffer.readu8(input, inputLength - 1)
			)
	
			local value1 = bit32.rshift(chunk, 10)
			local value2 = bit32.band(bit32.rshift(chunk, 4), 0b111111)
			local value3 = bit32.band(bit32.lshift(chunk, 2), 0b111111)
			
			buffer.writeu8(output, outputLength - 4, buffer.readu8(lookupValueToCharacter, value1))
			buffer.writeu8(output, outputLength - 3, buffer.readu8(lookupValueToCharacter, value2))
			buffer.writeu8(output, outputLength - 2, buffer.readu8(lookupValueToCharacter, value3))
			buffer.writeu8(output, outputLength - 1, padding)
		elseif inputRemainder == 0 and inputLength ~= 0 then
			local chunk = bit32.bor(
				bit32.lshift(buffer.readu8(input, inputLength - 3), 16),
				bit32.lshift(buffer.readu8(input, inputLength - 2), 8),
				buffer.readu8(input, inputLength - 1)
			)
	
			local value1 = bit32.rshift(chunk, 18)
			local value2 = bit32.band(bit32.rshift(chunk, 12), 0b111111)
			local value3 = bit32.band(bit32.rshift(chunk, 6), 0b111111)
			local value4 = bit32.band(chunk, 0b111111)
	
			buffer.writeu8(output, outputLength - 4, buffer.readu8(lookupValueToCharacter, value1))
			buffer.writeu8(output, outputLength - 3, buffer.readu8(lookupValueToCharacter, value2))
			buffer.writeu8(output, outputLength - 2, buffer.readu8(lookupValueToCharacter, value3))
			buffer.writeu8(output, outputLength - 1, buffer.readu8(lookupValueToCharacter, value4))
		end
		
		return output
	end
	
	local function decode(input: buffer): buffer
		local inputLength = buffer.len(input)
		local inputChunks = math.ceil(inputLength / 4)
		
		-- TODO: Support input without padding
		local inputPadding = 0
		if inputLength ~= 0 then
			if buffer.readu8(input, inputLength - 1) == padding then inputPadding += 1 end
			if buffer.readu8(input, inputLength - 2) == padding then inputPadding += 1 end
		end
	
		local outputLength = inputChunks * 3 - inputPadding
		local output = buffer.create(outputLength)
		
		for chunkIndex = 1, inputChunks - 1 do
			local inputIndex = (chunkIndex - 1) * 4
			local outputIndex = (chunkIndex - 1) * 3
			
			local value1 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, inputIndex))
			local value2 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, inputIndex + 1))
			local value3 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, inputIndex + 2))
			local value4 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, inputIndex + 3))
			
			local chunk = bit32.bor(
				bit32.lshift(value1, 18),
				bit32.lshift(value2, 12),
				bit32.lshift(value3, 6),
				value4
			)
			
			local character1 = bit32.rshift(chunk, 16)
			local character2 = bit32.band(bit32.rshift(chunk, 8), 0b11111111)
			local character3 = bit32.band(chunk, 0b11111111)
			
			buffer.writeu8(output, outputIndex, character1)
			buffer.writeu8(output, outputIndex + 1, character2)
			buffer.writeu8(output, outputIndex + 2, character3)
		end
		
		if inputLength ~= 0 then
			local lastInputIndex = (inputChunks - 1) * 4
			local lastOutputIndex = (inputChunks - 1) * 3
			
			local lastValue1 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, lastInputIndex))
			local lastValue2 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, lastInputIndex + 1))
			local lastValue3 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, lastInputIndex + 2))
			local lastValue4 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, lastInputIndex + 3))
	
			local lastChunk = bit32.bor(
				bit32.lshift(lastValue1, 18),
				bit32.lshift(lastValue2, 12),
				bit32.lshift(lastValue3, 6),
				lastValue4
			)
			
			if inputPadding <= 2 then
				local lastCharacter1 = bit32.rshift(lastChunk, 16)
				buffer.writeu8(output, lastOutputIndex, lastCharacter1)
				
				if inputPadding <= 1 then
					local lastCharacter2 = bit32.band(bit32.rshift(lastChunk, 8), 0b11111111)
					buffer.writeu8(output, lastOutputIndex + 1, lastCharacter2)
					
					if inputPadding == 0 then
						local lastCharacter3 = bit32.band(lastChunk, 0b11111111)
						buffer.writeu8(output, lastOutputIndex + 2, lastCharacter3)
					end
				end
			end
		end
		
		return output
	end
	
	base64 = {
		encode = encode,
		decode = decode,
	}
	
	local bit32_band = bit32.band -- 2 arguments
	local bit32_bor = bit32.bor -- 2 arguments
	local bit32_bxor = bit32.bxor -- 2..5 arguments
	local bit32_lshift = bit32.lshift -- second argument is integer 0..31
	local bit32_rshift = bit32.rshift -- second argument is integer 0..31
	local bit32_lrotate = bit32.lrotate -- second argument is integer 0..31
	local bit32_rrotate = bit32.rrotate -- second argument is integer 0..31
	
	--------------------------------------------------------------------------------
	-- CREATING OPTIMIZED INNER LOOP
	--------------------------------------------------------------------------------
	-- Arrays of SHA2 "magic numbers" (in "INT64" and "FFI" branches "*_lo" arrays contain 64-bit values)
	local sha2_K_lo, sha2_K_hi, sha2_H_lo, sha2_H_hi, sha3_RC_lo, sha3_RC_hi = {}, {}, {}, {}, {}, {}
	local sha2_H_ext256 = {
		[224] = {};
		[256] = sha2_H_hi;
	}
	
	local sha2_H_ext512_lo, sha2_H_ext512_hi = {
		[384] = {};
		[512] = sha2_H_lo;
	}, {
		[384] = {};
		[512] = sha2_H_hi;
	}
	
	local md5_K, md5_sha1_H = {}, {0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0}
	local md5_next_shift = {0, 0, 0, 0, 0, 0, 0, 0, 28, 25, 26, 27, 0, 0, 10, 9, 11, 12, 0, 15, 16, 17, 18, 0, 20, 22, 23, 21}
	local HEX64, XOR64A5, lanes_index_base -- defined only for branches that internally use 64-bit integers: "INT64" and "FFI"
	local common_W = {} -- temporary table shared between all calculations (to avoid creating new temporary table every time)
	local K_lo_modulo, hi_factor, hi_factor_keccak = 4294967296, 0, 0
	
	local TWO_POW_NEG_56 = 2 ^ -56
	local TWO_POW_NEG_17 = 2 ^ -17
	
	local TWO_POW_2 = 2 ^ 2
	local TWO_POW_3 = 2 ^ 3
	local TWO_POW_4 = 2 ^ 4
	local TWO_POW_5 = 2 ^ 5
	local TWO_POW_6 = 2 ^ 6
	local TWO_POW_7 = 2 ^ 7
	local TWO_POW_8 = 2 ^ 8
	local TWO_POW_9 = 2 ^ 9
	local TWO_POW_10 = 2 ^ 10
	local TWO_POW_11 = 2 ^ 11
	local TWO_POW_12 = 2 ^ 12
	local TWO_POW_13 = 2 ^ 13
	local TWO_POW_14 = 2 ^ 14
	local TWO_POW_15 = 2 ^ 15
	local TWO_POW_16 = 2 ^ 16
	local TWO_POW_17 = 2 ^ 17
	local TWO_POW_18 = 2 ^ 18
	local TWO_POW_19 = 2 ^ 19
	local TWO_POW_20 = 2 ^ 20
	local TWO_POW_21 = 2 ^ 21
	local TWO_POW_22 = 2 ^ 22
	local TWO_POW_23 = 2 ^ 23
	local TWO_POW_24 = 2 ^ 24
	local TWO_POW_25 = 2 ^ 25
	local TWO_POW_26 = 2 ^ 26
	local TWO_POW_27 = 2 ^ 27
	local TWO_POW_28 = 2 ^ 28
	local TWO_POW_29 = 2 ^ 29
	local TWO_POW_30 = 2 ^ 30
	local TWO_POW_31 = 2 ^ 31
	local TWO_POW_32 = 2 ^ 32
	local TWO_POW_40 = 2 ^ 40
	
	local TWO56_POW_7 = 256 ^ 7
	
	-- Implementation for Lua 5.1/5.2 (with or without bitwise library available)
	local function sha256_feed_64(H, str, offs, size)
		-- offs >= 0, size >= 0, size is multiple of 64
		local W, K = common_W, sha2_K_hi
		local h1, h2, h3, h4, h5, h6, h7, h8 = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
		for pos = offs, offs + size - 1, 64 do
			for j = 1, 16 do
				pos = pos + 4
				local a, b, c, d = string.byte(str, pos - 3, pos)
				W[j] = ((a * 256 + b) * 256 + c) * 256 + d
			end
	
			for j = 17, 64 do
				local a, b = W[j - 15], W[j - 2]
				W[j] = bit32_bxor(bit32_rrotate(a, 7), bit32_lrotate(a, 14), bit32_rshift(a, 3)) + bit32_bxor(bit32_lrotate(b, 15), bit32_lrotate(b, 13), bit32_rshift(b, 10)) + W[j - 7] + W[j - 16]
			end
	
			local a, b, c, d, e, f, g, h = h1, h2, h3, h4, h5, h6, h7, h8
			for j = 1, 64 do
				local z = bit32_bxor(bit32_rrotate(e, 6), bit32_rrotate(e, 11), bit32_lrotate(e, 7)) + bit32_band(e, f) + bit32_band(-1 - e, g) + h + K[j] + W[j]
				h = g
				g = f
				f = e
				e = z + d
				d = c
				c = b
				b = a
				a = z + bit32_band(d, c) + bit32_band(a, bit32_bxor(d, c)) + bit32_bxor(bit32_rrotate(a, 2), bit32_rrotate(a, 13), bit32_lrotate(a, 10))
			end
	
			h1, h2, h3, h4 = (a + h1) % 4294967296, (b + h2) % 4294967296, (c + h3) % 4294967296, (d + h4) % 4294967296
			h5, h6, h7, h8 = (e + h5) % 4294967296, (f + h6) % 4294967296, (g + h7) % 4294967296, (h + h8) % 4294967296
		end
	
		H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8] = h1, h2, h3, h4, h5, h6, h7, h8
	end
	
	local function sha512_feed_128(H_lo, H_hi, str, offs, size)
		-- offs >= 0, size >= 0, size is multiple of 128
		-- W1_hi, W1_lo, W2_hi, W2_lo, ...   Wk_hi = W[2*k-1], Wk_lo = W[2*k]
		local W, K_lo, K_hi = common_W, sha2_K_lo, sha2_K_hi
		local h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo = H_lo[1], H_lo[2], H_lo[3], H_lo[4], H_lo[5], H_lo[6], H_lo[7], H_lo[8]
		local h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi = H_hi[1], H_hi[2], H_hi[3], H_hi[4], H_hi[5], H_hi[6], H_hi[7], H_hi[8]
		for pos = offs, offs + size - 1, 128 do
			for j = 1, 16 * 2 do
				pos = pos + 4
				local a, b, c, d = string.byte(str, pos - 3, pos)
				W[j] = ((a * 256 + b) * 256 + c) * 256 + d
			end
	
			for jj = 34, 160, 2 do
				local a_lo, a_hi, b_lo, b_hi = W[jj - 30], W[jj - 31], W[jj - 4], W[jj - 5]
				local tmp1 = bit32_bxor(bit32_rshift(a_lo, 1) + bit32_lshift(a_hi, 31), bit32_rshift(a_lo, 8) + bit32_lshift(a_hi, 24), bit32_rshift(a_lo, 7) + bit32_lshift(a_hi, 25)) % 4294967296 +
					bit32_bxor(bit32_rshift(b_lo, 19) + bit32_lshift(b_hi, 13), bit32_lshift(b_lo, 3) + bit32_rshift(b_hi, 29), bit32_rshift(b_lo, 6) + bit32_lshift(b_hi, 26)) % 4294967296 +
					W[jj - 14] + W[jj - 32]
	
				local tmp2 = tmp1 % 4294967296
				W[jj - 1] = bit32_bxor(bit32_rshift(a_hi, 1) + bit32_lshift(a_lo, 31), bit32_rshift(a_hi, 8) + bit32_lshift(a_lo, 24), bit32_rshift(a_hi, 7)) +
					bit32_bxor(bit32_rshift(b_hi, 19) + bit32_lshift(b_lo, 13), bit32_lshift(b_hi, 3) + bit32_rshift(b_lo, 29), bit32_rshift(b_hi, 6)) +
					W[jj - 15] + W[jj - 33] + (tmp1 - tmp2) / 4294967296
	
				W[jj] = tmp2
			end
	
			local a_lo, b_lo, c_lo, d_lo, e_lo, f_lo, g_lo, h_lo = h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo
			local a_hi, b_hi, c_hi, d_hi, e_hi, f_hi, g_hi, h_hi = h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi
			for j = 1, 80 do
				local jj = 2 * j
				local tmp1 = bit32_bxor(bit32_rshift(e_lo, 14) + bit32_lshift(e_hi, 18), bit32_rshift(e_lo, 18) + bit32_lshift(e_hi, 14), bit32_lshift(e_lo, 23) + bit32_rshift(e_hi, 9)) % 4294967296 +
					(bit32_band(e_lo, f_lo) + bit32_band(-1 - e_lo, g_lo)) % 4294967296 +
					h_lo + K_lo[j] + W[jj]
	
				local z_lo = tmp1 % 4294967296
				local z_hi = bit32_bxor(bit32_rshift(e_hi, 14) + bit32_lshift(e_lo, 18), bit32_rshift(e_hi, 18) + bit32_lshift(e_lo, 14), bit32_lshift(e_hi, 23) + bit32_rshift(e_lo, 9)) +
					bit32_band(e_hi, f_hi) + bit32_band(-1 - e_hi, g_hi) +
					h_hi + K_hi[j] + W[jj - 1] +
					(tmp1 - z_lo) / 4294967296
	
				h_lo = g_lo
				h_hi = g_hi
				g_lo = f_lo
				g_hi = f_hi
				f_lo = e_lo
				f_hi = e_hi
				tmp1 = z_lo + d_lo
				e_lo = tmp1 % 4294967296
				e_hi = z_hi + d_hi + (tmp1 - e_lo) / 4294967296
				d_lo = c_lo
				d_hi = c_hi
				c_lo = b_lo
				c_hi = b_hi
				b_lo = a_lo
				b_hi = a_hi
				tmp1 = z_lo + (bit32_band(d_lo, c_lo) + bit32_band(b_lo, bit32_bxor(d_lo, c_lo))) % 4294967296 + bit32_bxor(bit32_rshift(b_lo, 28) + bit32_lshift(b_hi, 4), bit32_lshift(b_lo, 30) + bit32_rshift(b_hi, 2), bit32_lshift(b_lo, 25) + bit32_rshift(b_hi, 7)) % 4294967296
				a_lo = tmp1 % 4294967296
				a_hi = z_hi + (bit32_band(d_hi, c_hi) + bit32_band(b_hi, bit32_bxor(d_hi, c_hi))) + bit32_bxor(bit32_rshift(b_hi, 28) + bit32_lshift(b_lo, 4), bit32_lshift(b_hi, 30) + bit32_rshift(b_lo, 2), bit32_lshift(b_hi, 25) + bit32_rshift(b_lo, 7)) + (tmp1 - a_lo) / 4294967296
			end
	
			a_lo = h1_lo + a_lo
			h1_lo = a_lo % 4294967296
			h1_hi = (h1_hi + a_hi + (a_lo - h1_lo) / 4294967296) % 4294967296
			a_lo = h2_lo + b_lo
			h2_lo = a_lo % 4294967296
			h2_hi = (h2_hi + b_hi + (a_lo - h2_lo) / 4294967296) % 4294967296
			a_lo = h3_lo + c_lo
			h3_lo = a_lo % 4294967296
			h3_hi = (h3_hi + c_hi + (a_lo - h3_lo) / 4294967296) % 4294967296
			a_lo = h4_lo + d_lo
			h4_lo = a_lo % 4294967296
			h4_hi = (h4_hi + d_hi + (a_lo - h4_lo) / 4294967296) % 4294967296
			a_lo = h5_lo + e_lo
			h5_lo = a_lo % 4294967296
			h5_hi = (h5_hi + e_hi + (a_lo - h5_lo) / 4294967296) % 4294967296
			a_lo = h6_lo + f_lo
			h6_lo = a_lo % 4294967296
			h6_hi = (h6_hi + f_hi + (a_lo - h6_lo) / 4294967296) % 4294967296
			a_lo = h7_lo + g_lo
			h7_lo = a_lo % 4294967296
			h7_hi = (h7_hi + g_hi + (a_lo - h7_lo) / 4294967296) % 4294967296
			a_lo = h8_lo + h_lo
			h8_lo = a_lo % 4294967296
			h8_hi = (h8_hi + h_hi + (a_lo - h8_lo) / 4294967296) % 4294967296
		end
	
		H_lo[1], H_lo[2], H_lo[3], H_lo[4], H_lo[5], H_lo[6], H_lo[7], H_lo[8] = h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo
		H_hi[1], H_hi[2], H_hi[3], H_hi[4], H_hi[5], H_hi[6], H_hi[7], H_hi[8] = h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi
	end
	
	local function md5_feed_64(H, str, offs, size)
		-- offs >= 0, size >= 0, size is multiple of 64
		local W, K, md5_next_shift = common_W, md5_K, md5_next_shift
		local h1, h2, h3, h4 = H[1], H[2], H[3], H[4]
		for pos = offs, offs + size - 1, 64 do
			for j = 1, 16 do
				pos = pos + 4
				local a, b, c, d = string.byte(str, pos - 3, pos)
				W[j] = ((d * 256 + c) * 256 + b) * 256 + a
			end
	
			local a, b, c, d = h1, h2, h3, h4
			local s = 25
			for j = 1, 16 do
				local F = bit32_rrotate(bit32_band(b, c) + bit32_band(-1 - b, d) + a + K[j] + W[j], s) + b
				s = md5_next_shift[s]
				a = d
				d = c
				c = b
				b = F
			end
	
			s = 27
			for j = 17, 32 do
				local F = bit32_rrotate(bit32_band(d, b) + bit32_band(-1 - d, c) + a + K[j] + W[(5 * j - 4) % 16 + 1], s) + b
				s = md5_next_shift[s]
				a = d
				d = c
				c = b
				b = F
			end
	
			s = 28
			for j = 33, 48 do
				local F = bit32_rrotate(bit32_bxor(bit32_bxor(b, c), d) + a + K[j] + W[(3 * j + 2) % 16 + 1], s) + b
				s = md5_next_shift[s]
				a = d
				d = c
				c = b
				b = F
			end
	
			s = 26
			for j = 49, 64 do
				local F = bit32_rrotate(bit32_bxor(c, bit32_bor(b, -1 - d)) + a + K[j] + W[(j * 7 - 7) % 16 + 1], s) + b
				s = md5_next_shift[s]
				a = d
				d = c
				c = b
				b = F
			end
	
			h1 = (a + h1) % 4294967296
			h2 = (b + h2) % 4294967296
			h3 = (c + h3) % 4294967296
			h4 = (d + h4) % 4294967296
		end
	
		H[1], H[2], H[3], H[4] = h1, h2, h3, h4
	end
	
	local function sha1_feed_64(H, str, offs, size)
		-- offs >= 0, size >= 0, size is multiple of 64
		local W = common_W
		local h1, h2, h3, h4, h5 = H[1], H[2], H[3], H[4], H[5]
		for pos = offs, offs + size - 1, 64 do
			for j = 1, 16 do
				pos = pos + 4
				local a, b, c, d = string.byte(str, pos - 3, pos)
				W[j] = ((a * 256 + b) * 256 + c) * 256 + d
			end
	
			for j = 17, 80 do
				W[j] = bit32_lrotate(bit32_bxor(W[j - 3], W[j - 8], W[j - 14], W[j - 16]), 1)
			end
	
			local a, b, c, d, e = h1, h2, h3, h4, h5
			for j = 1, 20 do
				local z = bit32_lrotate(a, 5) + bit32_band(b, c) + bit32_band(-1 - b, d) + 0x5A827999 + W[j] + e -- constant = math.floor(TWO_POW_30 * sqrt(2))
				e = d
				d = c
				c = bit32_rrotate(b, 2)
				b = a
				a = z
			end
	
			for j = 21, 40 do
				local z = bit32_lrotate(a, 5) + bit32_bxor(b, c, d) + 0x6ED9EBA1 + W[j] + e -- TWO_POW_30 * sqrt(3)
				e = d
				d = c
				c = bit32_rrotate(b, 2)
				b = a
				a = z
			end
	
			for j = 41, 60 do
				local z = bit32_lrotate(a, 5) + bit32_band(d, c) + bit32_band(b, bit32_bxor(d, c)) + 0x8F1BBCDC + W[j] + e -- TWO_POW_30 * sqrt(5)
				e = d
				d = c
				c = bit32_rrotate(b, 2)
				b = a
				a = z
			end
	
			for j = 61, 80 do
				local z = bit32_lrotate(a, 5) + bit32_bxor(b, c, d) + 0xCA62C1D6 + W[j] + e -- TWO_POW_30 * sqrt(10)
				e = d
				d = c
				c = bit32_rrotate(b, 2)
				b = a
				a = z
			end
	
			h1 = (a + h1) % 4294967296
			h2 = (b + h2) % 4294967296
			h3 = (c + h3) % 4294967296
			h4 = (d + h4) % 4294967296
			h5 = (e + h5) % 4294967296
		end
	
		H[1], H[2], H[3], H[4], H[5] = h1, h2, h3, h4, h5
	end
	
	local function keccak_feed(lanes_lo, lanes_hi, str, offs, size, block_size_in_bytes)
		-- This is an example of a Lua function having 79 local variables :-)
		-- offs >= 0, size >= 0, size is multiple of block_size_in_bytes, block_size_in_bytes is positive multiple of 8
		local RC_lo, RC_hi = sha3_RC_lo, sha3_RC_hi
		local qwords_qty = block_size_in_bytes / 8
		for pos = offs, offs + size - 1, block_size_in_bytes do
			for j = 1, qwords_qty do
				local a, b, c, d = string.byte(str, pos + 1, pos + 4)
				lanes_lo[j] = bit32_bxor(lanes_lo[j], ((d * 256 + c) * 256 + b) * 256 + a)
				pos = pos + 8
				a, b, c, d = string.byte(str, pos - 3, pos)
				lanes_hi[j] = bit32_bxor(lanes_hi[j], ((d * 256 + c) * 256 + b) * 256 + a)
			end
	
			local L01_lo, L01_hi, L02_lo, L02_hi, L03_lo, L03_hi, L04_lo, L04_hi, L05_lo, L05_hi, L06_lo, L06_hi, L07_lo, L07_hi, L08_lo, L08_hi, L09_lo, L09_hi, L10_lo, L10_hi, L11_lo, L11_hi, L12_lo, L12_hi, L13_lo, L13_hi, L14_lo, L14_hi, L15_lo, L15_hi, L16_lo, L16_hi, L17_lo, L17_hi, L18_lo, L18_hi, L19_lo, L19_hi, L20_lo, L20_hi, L21_lo, L21_hi, L22_lo, L22_hi, L23_lo, L23_hi, L24_lo, L24_hi, L25_lo, L25_hi = lanes_lo[1], lanes_hi[1], lanes_lo[2], lanes_hi[2], lanes_lo[3], lanes_hi[3], lanes_lo[4], lanes_hi[4], lanes_lo[5], lanes_hi[5], lanes_lo[6], lanes_hi[6], lanes_lo[7], lanes_hi[7], lanes_lo[8], lanes_hi[8], lanes_lo[9], lanes_hi[9], lanes_lo[10], lanes_hi[10], lanes_lo[11], lanes_hi[11], lanes_lo[12], lanes_hi[12], lanes_lo[13], lanes_hi[13], lanes_lo[14], lanes_hi[14], lanes_lo[15], lanes_hi[15], lanes_lo[16], lanes_hi[16], lanes_lo[17], lanes_hi[17], lanes_lo[18], lanes_hi[18], lanes_lo[19], lanes_hi[19], lanes_lo[20], lanes_hi[20], lanes_lo[21], lanes_hi[21], lanes_lo[22], lanes_hi[22], lanes_lo[23], lanes_hi[23], lanes_lo[24], lanes_hi[24], lanes_lo[25], lanes_hi[25]
	
			for round_idx = 1, 24 do
				local C1_lo = bit32_bxor(L01_lo, L06_lo, L11_lo, L16_lo, L21_lo)
				local C1_hi = bit32_bxor(L01_hi, L06_hi, L11_hi, L16_hi, L21_hi)
				local C2_lo = bit32_bxor(L02_lo, L07_lo, L12_lo, L17_lo, L22_lo)
				local C2_hi = bit32_bxor(L02_hi, L07_hi, L12_hi, L17_hi, L22_hi)
				local C3_lo = bit32_bxor(L03_lo, L08_lo, L13_lo, L18_lo, L23_lo)
				local C3_hi = bit32_bxor(L03_hi, L08_hi, L13_hi, L18_hi, L23_hi)
				local C4_lo = bit32_bxor(L04_lo, L09_lo, L14_lo, L19_lo, L24_lo)
				local C4_hi = bit32_bxor(L04_hi, L09_hi, L14_hi, L19_hi, L24_hi)
				local C5_lo = bit32_bxor(L05_lo, L10_lo, L15_lo, L20_lo, L25_lo)
				local C5_hi = bit32_bxor(L05_hi, L10_hi, L15_hi, L20_hi, L25_hi)
	
				local D_lo = bit32_bxor(C1_lo, C3_lo * 2 + (C3_hi % TWO_POW_32 - C3_hi % TWO_POW_31) / TWO_POW_31)
				local D_hi = bit32_bxor(C1_hi, C3_hi * 2 + (C3_lo % TWO_POW_32 - C3_lo % TWO_POW_31) / TWO_POW_31)
	
				local T0_lo = bit32_bxor(D_lo, L02_lo)
				local T0_hi = bit32_bxor(D_hi, L02_hi)
				local T1_lo = bit32_bxor(D_lo, L07_lo)
				local T1_hi = bit32_bxor(D_hi, L07_hi)
				local T2_lo = bit32_bxor(D_lo, L12_lo)
				local T2_hi = bit32_bxor(D_hi, L12_hi)
				local T3_lo = bit32_bxor(D_lo, L17_lo)
				local T3_hi = bit32_bxor(D_hi, L17_hi)
				local T4_lo = bit32_bxor(D_lo, L22_lo)
				local T4_hi = bit32_bxor(D_hi, L22_hi)
	
				L02_lo = (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_20) / TWO_POW_20 + T1_hi * TWO_POW_12
				L02_hi = (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_20) / TWO_POW_20 + T1_lo * TWO_POW_12
				L07_lo = (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_19) / TWO_POW_19 + T3_hi * TWO_POW_13
				L07_hi = (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_19) / TWO_POW_19 + T3_lo * TWO_POW_13
				L12_lo = T0_lo * 2 + (T0_hi % TWO_POW_32 - T0_hi % TWO_POW_31) / TWO_POW_31
				L12_hi = T0_hi * 2 + (T0_lo % TWO_POW_32 - T0_lo % TWO_POW_31) / TWO_POW_31
				L17_lo = T2_lo * TWO_POW_10 + (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_22) / TWO_POW_22
				L17_hi = T2_hi * TWO_POW_10 + (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_22) / TWO_POW_22
				L22_lo = T4_lo * TWO_POW_2 + (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_30) / TWO_POW_30
				L22_hi = T4_hi * TWO_POW_2 + (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_30) / TWO_POW_30
	
				D_lo = bit32_bxor(C2_lo, C4_lo * 2 + (C4_hi % TWO_POW_32 - C4_hi % TWO_POW_31) / TWO_POW_31)
				D_hi = bit32_bxor(C2_hi, C4_hi * 2 + (C4_lo % TWO_POW_32 - C4_lo % TWO_POW_31) / TWO_POW_31)
	
				T0_lo = bit32_bxor(D_lo, L03_lo)
				T0_hi = bit32_bxor(D_hi, L03_hi)
				T1_lo = bit32_bxor(D_lo, L08_lo)
				T1_hi = bit32_bxor(D_hi, L08_hi)
				T2_lo = bit32_bxor(D_lo, L13_lo)
				T2_hi = bit32_bxor(D_hi, L13_hi)
				T3_lo = bit32_bxor(D_lo, L18_lo)
				T3_hi = bit32_bxor(D_hi, L18_hi)
				T4_lo = bit32_bxor(D_lo, L23_lo)
				T4_hi = bit32_bxor(D_hi, L23_hi)
	
				L03_lo = (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_21) / TWO_POW_21 + T2_hi * TWO_POW_11
				L03_hi = (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_21) / TWO_POW_21 + T2_lo * TWO_POW_11
				L08_lo = (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_3) / TWO_POW_3 + T4_hi * TWO_POW_29 % TWO_POW_32
				L08_hi = (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_3) / TWO_POW_3 + T4_lo * TWO_POW_29 % TWO_POW_32
				L13_lo = T1_lo * TWO_POW_6 + (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_26) / TWO_POW_26
				L13_hi = T1_hi * TWO_POW_6 + (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_26) / TWO_POW_26
				L18_lo = T3_lo * TWO_POW_15 + (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_17) / TWO_POW_17
				L18_hi = T3_hi * TWO_POW_15 + (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_17) / TWO_POW_17
				L23_lo = (T0_lo % TWO_POW_32 - T0_lo % TWO_POW_2) / TWO_POW_2 + T0_hi * TWO_POW_30 % TWO_POW_32
				L23_hi = (T0_hi % TWO_POW_32 - T0_hi % TWO_POW_2) / TWO_POW_2 + T0_lo * TWO_POW_30 % TWO_POW_32
	
				D_lo = bit32_bxor(C3_lo, C5_lo * 2 + (C5_hi % TWO_POW_32 - C5_hi % TWO_POW_31) / TWO_POW_31)
				D_hi = bit32_bxor(C3_hi, C5_hi * 2 + (C5_lo % TWO_POW_32 - C5_lo % TWO_POW_31) / TWO_POW_31)
	
				T0_lo = bit32_bxor(D_lo, L04_lo)
				T0_hi = bit32_bxor(D_hi, L04_hi)
				T1_lo = bit32_bxor(D_lo, L09_lo)
				T1_hi = bit32_bxor(D_hi, L09_hi)
				T2_lo = bit32_bxor(D_lo, L14_lo)
				T2_hi = bit32_bxor(D_hi, L14_hi)
				T3_lo = bit32_bxor(D_lo, L19_lo)
				T3_hi = bit32_bxor(D_hi, L19_hi)
				T4_lo = bit32_bxor(D_lo, L24_lo)
				T4_hi = bit32_bxor(D_hi, L24_hi)
	
				L04_lo = T3_lo * TWO_POW_21 % TWO_POW_32 + (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_11) / TWO_POW_11
				L04_hi = T3_hi * TWO_POW_21 % TWO_POW_32 + (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_11) / TWO_POW_11
				L09_lo = T0_lo * TWO_POW_28 % TWO_POW_32 + (T0_hi % TWO_POW_32 - T0_hi % TWO_POW_4) / TWO_POW_4
				L09_hi = T0_hi * TWO_POW_28 % TWO_POW_32 + (T0_lo % TWO_POW_32 - T0_lo % TWO_POW_4) / TWO_POW_4
				L14_lo = T2_lo * TWO_POW_25 % TWO_POW_32 + (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_7) / TWO_POW_7
				L14_hi = T2_hi * TWO_POW_25 % TWO_POW_32 + (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_7) / TWO_POW_7
				L19_lo = (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_8) / TWO_POW_8 + T4_hi * TWO_POW_24 % TWO_POW_32
				L19_hi = (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_8) / TWO_POW_8 + T4_lo * TWO_POW_24 % TWO_POW_32
				L24_lo = (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_9) / TWO_POW_9 + T1_hi * TWO_POW_23 % TWO_POW_32
				L24_hi = (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_9) / TWO_POW_9 + T1_lo * TWO_POW_23 % TWO_POW_32
	
				D_lo = bit32_bxor(C4_lo, C1_lo * 2 + (C1_hi % TWO_POW_32 - C1_hi % TWO_POW_31) / TWO_POW_31)
				D_hi = bit32_bxor(C4_hi, C1_hi * 2 + (C1_lo % TWO_POW_32 - C1_lo % TWO_POW_31) / TWO_POW_31)
	
				T0_lo = bit32_bxor(D_lo, L05_lo)
				T0_hi = bit32_bxor(D_hi, L05_hi)
				T1_lo = bit32_bxor(D_lo, L10_lo)
				T1_hi = bit32_bxor(D_hi, L10_hi)
				T2_lo = bit32_bxor(D_lo, L15_lo)
				T2_hi = bit32_bxor(D_hi, L15_hi)
				T3_lo = bit32_bxor(D_lo, L20_lo)
				T3_hi = bit32_bxor(D_hi, L20_hi)
				T4_lo = bit32_bxor(D_lo, L25_lo)
				T4_hi = bit32_bxor(D_hi, L25_hi)
	
				L05_lo = T4_lo * TWO_POW_14 + (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_18) / TWO_POW_18
				L05_hi = T4_hi * TWO_POW_14 + (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_18) / TWO_POW_18
				L10_lo = T1_lo * TWO_POW_20 % TWO_POW_32 + (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_12) / TWO_POW_12
				L10_hi = T1_hi * TWO_POW_20 % TWO_POW_32 + (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_12) / TWO_POW_12
				L15_lo = T3_lo * TWO_POW_8 + (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_24) / TWO_POW_24
				L15_hi = T3_hi * TWO_POW_8 + (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_24) / TWO_POW_24
				L20_lo = T0_lo * TWO_POW_27 % TWO_POW_32 + (T0_hi % TWO_POW_32 - T0_hi % TWO_POW_5) / TWO_POW_5
				L20_hi = T0_hi * TWO_POW_27 % TWO_POW_32 + (T0_lo % TWO_POW_32 - T0_lo % TWO_POW_5) / TWO_POW_5
				L25_lo = (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_25) / TWO_POW_25 + T2_hi * TWO_POW_7
				L25_hi = (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_25) / TWO_POW_25 + T2_lo * TWO_POW_7
	
				D_lo = bit32_bxor(C5_lo, C2_lo * 2 + (C2_hi % TWO_POW_32 - C2_hi % TWO_POW_31) / TWO_POW_31)
				D_hi = bit32_bxor(C5_hi, C2_hi * 2 + (C2_lo % TWO_POW_32 - C2_lo % TWO_POW_31) / TWO_POW_31)
	
				T1_lo = bit32_bxor(D_lo, L06_lo)
				T1_hi = bit32_bxor(D_hi, L06_hi)
				T2_lo = bit32_bxor(D_lo, L11_lo)
				T2_hi = bit32_bxor(D_hi, L11_hi)
				T3_lo = bit32_bxor(D_lo, L16_lo)
				T3_hi = bit32_bxor(D_hi, L16_hi)
				T4_lo = bit32_bxor(D_lo, L21_lo)
				T4_hi = bit32_bxor(D_hi, L21_hi)
	
				L06_lo = T2_lo * TWO_POW_3 + (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_29) / TWO_POW_29
				L06_hi = T2_hi * TWO_POW_3 + (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_29) / TWO_POW_29
				L11_lo = T4_lo * TWO_POW_18 + (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_14) / TWO_POW_14
				L11_hi = T4_hi * TWO_POW_18 + (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_14) / TWO_POW_14
				L16_lo = (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_28) / TWO_POW_28 + T1_hi * TWO_POW_4
				L16_hi = (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_28) / TWO_POW_28 + T1_lo * TWO_POW_4
				L21_lo = (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_23) / TWO_POW_23 + T3_hi * TWO_POW_9
				L21_hi = (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_23) / TWO_POW_23 + T3_lo * TWO_POW_9
	
				L01_lo = bit32_bxor(D_lo, L01_lo)
				L01_hi = bit32_bxor(D_hi, L01_hi)
				L01_lo, L02_lo, L03_lo, L04_lo, L05_lo = bit32_bxor(L01_lo, bit32_band(-1 - L02_lo, L03_lo)), bit32_bxor(L02_lo, bit32_band(-1 - L03_lo, L04_lo)), bit32_bxor(L03_lo, bit32_band(-1 - L04_lo, L05_lo)), bit32_bxor(L04_lo, bit32_band(-1 - L05_lo, L01_lo)), bit32_bxor(L05_lo, bit32_band(-1 - L01_lo, L02_lo))
				L01_hi, L02_hi, L03_hi, L04_hi, L05_hi = bit32_bxor(L01_hi, bit32_band(-1 - L02_hi, L03_hi)), bit32_bxor(L02_hi, bit32_band(-1 - L03_hi, L04_hi)), bit32_bxor(L03_hi, bit32_band(-1 - L04_hi, L05_hi)), bit32_bxor(L04_hi, bit32_band(-1 - L05_hi, L01_hi)), bit32_bxor(L05_hi, bit32_band(-1 - L01_hi, L02_hi))
				L06_lo, L07_lo, L08_lo, L09_lo, L10_lo = bit32_bxor(L09_lo, bit32_band(-1 - L10_lo, L06_lo)), bit32_bxor(L10_lo, bit32_band(-1 - L06_lo, L07_lo)), bit32_bxor(L06_lo, bit32_band(-1 - L07_lo, L08_lo)), bit32_bxor(L07_lo, bit32_band(-1 - L08_lo, L09_lo)), bit32_bxor(L08_lo, bit32_band(-1 - L09_lo, L10_lo))
				L06_hi, L07_hi, L08_hi, L09_hi, L10_hi = bit32_bxor(L09_hi, bit32_band(-1 - L10_hi, L06_hi)), bit32_bxor(L10_hi, bit32_band(-1 - L06_hi, L07_hi)), bit32_bxor(L06_hi, bit32_band(-1 - L07_hi, L08_hi)), bit32_bxor(L07_hi, bit32_band(-1 - L08_hi, L09_hi)), bit32_bxor(L08_hi, bit32_band(-1 - L09_hi, L10_hi))
				L11_lo, L12_lo, L13_lo, L14_lo, L15_lo = bit32_bxor(L12_lo, bit32_band(-1 - L13_lo, L14_lo)), bit32_bxor(L13_lo, bit32_band(-1 - L14_lo, L15_lo)), bit32_bxor(L14_lo, bit32_band(-1 - L15_lo, L11_lo)), bit32_bxor(L15_lo, bit32_band(-1 - L11_lo, L12_lo)), bit32_bxor(L11_lo, bit32_band(-1 - L12_lo, L13_lo))
				L11_hi, L12_hi, L13_hi, L14_hi, L15_hi = bit32_bxor(L12_hi, bit32_band(-1 - L13_hi, L14_hi)), bit32_bxor(L13_hi, bit32_band(-1 - L14_hi, L15_hi)), bit32_bxor(L14_hi, bit32_band(-1 - L15_hi, L11_hi)), bit32_bxor(L15_hi, bit32_band(-1 - L11_hi, L12_hi)), bit32_bxor(L11_hi, bit32_band(-1 - L12_hi, L13_hi))
				L16_lo, L17_lo, L18_lo, L19_lo, L20_lo = bit32_bxor(L20_lo, bit32_band(-1 - L16_lo, L17_lo)), bit32_bxor(L16_lo, bit32_band(-1 - L17_lo, L18_lo)), bit32_bxor(L17_lo, bit32_band(-1 - L18_lo, L19_lo)), bit32_bxor(L18_lo, bit32_band(-1 - L19_lo, L20_lo)), bit32_bxor(L19_lo, bit32_band(-1 - L20_lo, L16_lo))
				L16_hi, L17_hi, L18_hi, L19_hi, L20_hi = bit32_bxor(L20_hi, bit32_band(-1 - L16_hi, L17_hi)), bit32_bxor(L16_hi, bit32_band(-1 - L17_hi, L18_hi)), bit32_bxor(L17_hi, bit32_band(-1 - L18_hi, L19_hi)), bit32_bxor(L18_hi, bit32_band(-1 - L19_hi, L20_hi)), bit32_bxor(L19_hi, bit32_band(-1 - L20_hi, L16_hi))
				L21_lo, L22_lo, L23_lo, L24_lo, L25_lo = bit32_bxor(L23_lo, bit32_band(-1 - L24_lo, L25_lo)), bit32_bxor(L24_lo, bit32_band(-1 - L25_lo, L21_lo)), bit32_bxor(L25_lo, bit32_band(-1 - L21_lo, L22_lo)), bit32_bxor(L21_lo, bit32_band(-1 - L22_lo, L23_lo)), bit32_bxor(L22_lo, bit32_band(-1 - L23_lo, L24_lo))
				L21_hi, L22_hi, L23_hi, L24_hi, L25_hi = bit32_bxor(L23_hi, bit32_band(-1 - L24_hi, L25_hi)), bit32_bxor(L24_hi, bit32_band(-1 - L25_hi, L21_hi)), bit32_bxor(L25_hi, bit32_band(-1 - L21_hi, L22_hi)), bit32_bxor(L21_hi, bit32_band(-1 - L22_hi, L23_hi)), bit32_bxor(L22_hi, bit32_band(-1 - L23_hi, L24_hi))
				L01_lo = bit32_bxor(L01_lo, RC_lo[round_idx])
				L01_hi = L01_hi + RC_hi[round_idx] -- RC_hi[] is either 0 or 0x80000000, so we could use fast addition instead of slow XOR
			end
	
			lanes_lo[1] = L01_lo
			lanes_hi[1] = L01_hi
			lanes_lo[2] = L02_lo
			lanes_hi[2] = L02_hi
			lanes_lo[3] = L03_lo
			lanes_hi[3] = L03_hi
			lanes_lo[4] = L04_lo
			lanes_hi[4] = L04_hi
			lanes_lo[5] = L05_lo
			lanes_hi[5] = L05_hi
			lanes_lo[6] = L06_lo
			lanes_hi[6] = L06_hi
			lanes_lo[7] = L07_lo
			lanes_hi[7] = L07_hi
			lanes_lo[8] = L08_lo
			lanes_hi[8] = L08_hi
			lanes_lo[9] = L09_lo
			lanes_hi[9] = L09_hi
			lanes_lo[10] = L10_lo
			lanes_hi[10] = L10_hi
			lanes_lo[11] = L11_lo
			lanes_hi[11] = L11_hi
			lanes_lo[12] = L12_lo
			lanes_hi[12] = L12_hi
			lanes_lo[13] = L13_lo
			lanes_hi[13] = L13_hi
			lanes_lo[14] = L14_lo
			lanes_hi[14] = L14_hi
			lanes_lo[15] = L15_lo
			lanes_hi[15] = L15_hi
			lanes_lo[16] = L16_lo
			lanes_hi[16] = L16_hi
			lanes_lo[17] = L17_lo
			lanes_hi[17] = L17_hi
			lanes_lo[18] = L18_lo
			lanes_hi[18] = L18_hi
			lanes_lo[19] = L19_lo
			lanes_hi[19] = L19_hi
			lanes_lo[20] = L20_lo
			lanes_hi[20] = L20_hi
			lanes_lo[21] = L21_lo
			lanes_hi[21] = L21_hi
			lanes_lo[22] = L22_lo
			lanes_hi[22] = L22_hi
			lanes_lo[23] = L23_lo
			lanes_hi[23] = L23_hi
			lanes_lo[24] = L24_lo
			lanes_hi[24] = L24_hi
			lanes_lo[25] = L25_lo
			lanes_hi[25] = L25_hi
		end
	end
	
	do
		local function mul(src1, src2, factor, result_length)
			local result, carry, value, weight = table.create(result_length), 0, 0, 1
			for j = 1, result_length do
				for k = math.max(1, j + 1 - #src2), math.min(j, #src1) do
					carry = carry + factor * src1[k] * src2[j + 1 - k] -- "int32" is not enough for multiplication result, that's why "factor" must be of type "double"
				end
	
				local digit = carry % TWO_POW_24
				result[j] = math.floor(digit)
				carry = (carry - digit) / TWO_POW_24
				value = value + digit * weight
				weight = weight * TWO_POW_24
			end
	
			return result, value
		end
	
		local idx, step, p, one, sqrt_hi, sqrt_lo = 0, {4, 1, 2, -2, 2}, 4, {1}, sha2_H_hi, sha2_H_lo
		repeat
			p = p + step[p % 6]
			local d = 1
			repeat
				d = d + step[d % 6]
				if d * d > p then
					-- next prime number is found
					local root = p ^ (1 / 3)
					local R = root * TWO_POW_40
					R = mul(table.create(1, math.floor(R)), one, 1, 2)
					local _, delta = mul(R, mul(R, R, 1, 4), -1, 4)
					local hi = R[2] % 65536 * 65536 + math.floor(R[1] / 256)
					local lo = R[1] % 256 * 16777216 + math.floor(delta * (TWO_POW_NEG_56 / 3) * root / p)
	
					if idx < 16 then
						root = math.sqrt(p)
						R = root * TWO_POW_40
						R = mul(table.create(1, math.floor(R)), one, 1, 2)
						_, delta = mul(R, R, -1, 2)
						local hi = R[2] % 65536 * 65536 + math.floor(R[1] / 256)
						local lo = R[1] % 256 * 16777216 + math.floor(delta * TWO_POW_NEG_17 / root)
						local idx = idx % 8 + 1
						sha2_H_ext256[224][idx] = lo
						sqrt_hi[idx], sqrt_lo[idx] = hi, lo + hi * hi_factor
						if idx > 7 then
							sqrt_hi, sqrt_lo = sha2_H_ext512_hi[384], sha2_H_ext512_lo[384]
						end
					end
	
					idx = idx + 1
					sha2_K_hi[idx], sha2_K_lo[idx] = hi, lo % K_lo_modulo + hi * hi_factor
					break
				end
			until p % d == 0
		until idx > 79
	end
	
	-- Calculating IVs for SHA512/224 and SHA512/256
	for width = 224, 256, 32 do
		local H_lo, H_hi = {}, nil
		if XOR64A5 then
			for j = 1, 8 do
				H_lo[j] = XOR64A5(sha2_H_lo[j])
			end
		else
			H_hi = {}
			for j = 1, 8 do
				H_lo[j] = bit32_bxor(sha2_H_lo[j], 0xA5A5A5A5) % 4294967296
				H_hi[j] = bit32_bxor(sha2_H_hi[j], 0xA5A5A5A5) % 4294967296
			end
		end
	
		sha512_feed_128(H_lo, H_hi, "SHA-512/" .. tostring(width) .. "\128" .. string.rep("\0", 115) .. "\88", 0, 128)
		sha2_H_ext512_lo[width] = H_lo
		sha2_H_ext512_hi[width] = H_hi
	end
	
	-- Constants for MD5
	do
		for idx = 1, 64 do
			-- we can't use formula math.floor(abs(sin(idx))*TWO_POW_32) because its result may be beyond integer range on Lua built with 32-bit integers
			local hi, lo = math.modf(math.abs(math.sin(idx)) * TWO_POW_16)
			md5_K[idx] = hi * 65536 + math.floor(lo * TWO_POW_16)
		end
	end
	
	-- Constants for SHA3
	do
		local sh_reg = 29
		local function next_bit()
			local r = sh_reg % 2
			sh_reg = bit32_bxor((sh_reg - r) / 2, 142 * r)
			return r
		end
	
		for idx = 1, 24 do
			local lo, m = 0, nil
			for _ = 1, 6 do
				m = m and m * m * 2 or 1
				lo = lo + next_bit() * m
			end
	
			local hi = next_bit() * m
			sha3_RC_hi[idx], sha3_RC_lo[idx] = hi, lo + hi * hi_factor_keccak
		end
	end
	
	--------------------------------------------------------------------------------
	-- MAIN FUNCTIONS
	--------------------------------------------------------------------------------
	local function sha256ext(width, message)
		-- Create an instance (private objects for current calculation)
		local Array256 = sha2_H_ext256[width] -- # == 8
		local length, tail = 0, ""
		local H = table.create(8)
		H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8] = Array256[1], Array256[2], Array256[3], Array256[4], Array256[5], Array256[6], Array256[7], Array256[8]
	
		local function partial(message_part)
			if message_part then
				local partLength = #message_part
				if tail then
					length = length + partLength
					local offs = 0
					local tailLength = #tail
					if tail ~= "" and tailLength + partLength >= 64 then
						offs = 64 - tailLength
						sha256_feed_64(H, tail .. string.sub(message_part, 1, offs), 0, 64)
						tail = ""
					end
	
					local size = partLength - offs
					local size_tail = size % 64
					sha256_feed_64(H, message_part, offs, size - size_tail)
					tail = tail .. string.sub(message_part, partLength + 1 - size_tail)
					return partial
				else
					error("Adding more chunks is not allowed after receiving the result", 2)
				end
			else
				if tail then
					local final_blocks = table.create(10) --{tail, "\128", string.rep("\0", (-9 - length) % 64 + 1)}
					final_blocks[1] = tail
					final_blocks[2] = "\128"
					final_blocks[3] = string.rep("\0", (-9 - length) % 64 + 1)
	
					tail = nil
					-- Assuming user data length is shorter than (TWO_POW_53)-9 bytes
					-- Anyway, it looks very unrealistic that someone would spend more than a year of calculations to process TWO_POW_53 bytes of data by using this Lua script :-)
					-- TWO_POW_53 bytes = TWO_POW_56 bits, so "bit-counter" fits in 7 bytes
					length = length * (8 / TWO56_POW_7) -- convert "byte-counter" to "bit-counter" and move decimal point to the left
					for j = 4, 10 do
						length = length % 1 * 256
						final_blocks[j] = string.char(math.floor(length))
					end
	
					final_blocks = table.concat(final_blocks)
					sha256_feed_64(H, final_blocks, 0, #final_blocks)
					local max_reg = width / 32
					for j = 1, max_reg do
						H[j] = string.format("%08x", H[j] % 4294967296)
					end
	
					H = table.concat(H, "", 1, max_reg)
				end
	
				return H
			end
		end
	
		if message then
			-- Actually perform calculations and return the SHA256 digest of a message
			return partial(message)()
		else
			-- Return function for chunk-by-chunk loading
			-- User should feed every chunk of input data as single argument to this function and finally get SHA256 digest by invoking this function without an argument
			return partial
		end
	end
	
	local function sha512ext(width, message)
	
		-- Create an instance (private objects for current calculation)
		local length, tail, H_lo, H_hi = 0, "", table.pack(table.unpack(sha2_H_ext512_lo[width])), not HEX64 and table.pack(table.unpack(sha2_H_ext512_hi[width]))
	
		local function partial(message_part)
			if message_part then
				local partLength = #message_part
				if tail then
					length = length + partLength
					local offs = 0
					if tail ~= "" and #tail + partLength >= 128 then
						offs = 128 - #tail
						sha512_feed_128(H_lo, H_hi, tail .. string.sub(message_part, 1, offs), 0, 128)
						tail = ""
					end
	
					local size = partLength - offs
					local size_tail = size % 128
					sha512_feed_128(H_lo, H_hi, message_part, offs, size - size_tail)
					tail = tail .. string.sub(message_part, partLength + 1 - size_tail)
					return partial
				else
					error("Adding more chunks is not allowed after receiving the result", 2)
				end
			else
				if tail then
					local final_blocks = table.create(3) --{tail, "\128", string.rep("\0", (-17-length) % 128 + 9)}
					final_blocks[1] = tail
					final_blocks[2] = "\128"
					final_blocks[3] = string.rep("\0", (-17 - length) % 128 + 9)
	
					tail = nil
					-- Assuming user data length is shorter than (TWO_POW_53)-17 bytes
					-- TWO_POW_53 bytes = TWO_POW_56 bits, so "bit-counter" fits in 7 bytes
					length = length * (8 / TWO56_POW_7) -- convert "byte-counter" to "bit-counter" and move floating point to the left
					for j = 4, 10 do
						length = length % 1 * 256
						final_blocks[j] = string.char(math.floor(length))
					end
	
					final_blocks = table.concat(final_blocks)
					sha512_feed_128(H_lo, H_hi, final_blocks, 0, #final_blocks)
					local max_reg = math.ceil(width / 64)
	
					if HEX64 then
						for j = 1, max_reg do
							H_lo[j] = HEX64(H_lo[j])
						end
					else
						for j = 1, max_reg do
							H_lo[j] = string.format("%08x", H_hi[j] % 4294967296) .. string.format("%08x", H_lo[j] % 4294967296)
						end
	
						H_hi = nil
					end
	
					H_lo = string.sub(table.concat(H_lo, "", 1, max_reg), 1, width / 4)
				end
	
				return H_lo
			end
		end
	
		if message then
			-- Actually perform calculations and return the SHA512 digest of a message
			return partial(message)()
		else
			-- Return function for chunk-by-chunk loading
			-- User should feed every chunk of input data as single argument to this function and finally get SHA512 digest by invoking this function without an argument
			return partial
		end
	end
	
	local function md5(message)
	
		-- Create an instance (private objects for current calculation)
		local H, length, tail = table.create(4), 0, ""
		H[1], H[2], H[3], H[4] = md5_sha1_H[1], md5_sha1_H[2], md5_sha1_H[3], md5_sha1_H[4]
	
		local function partial(message_part)
			if message_part then
				local partLength = #message_part
				if tail then
					length = length + partLength
					local offs = 0
					if tail ~= "" and #tail + partLength >= 64 then
						offs = 64 - #tail
						md5_feed_64(H, tail .. string.sub(message_part, 1, offs), 0, 64)
						tail = ""
					end
	
					local size = partLength - offs
					local size_tail = size % 64
					md5_feed_64(H, message_part, offs, size - size_tail)
					tail = tail .. string.sub(message_part, partLength + 1 - size_tail)
					return partial
				else
					error("Adding more chunks is not allowed after receiving the result", 2)
				end
			else
				if tail then
					local final_blocks = table.create(3) --{tail, "\128", string.rep("\0", (-9 - length) % 64)}
					final_blocks[1] = tail
					final_blocks[2] = "\128"
					final_blocks[3] = string.rep("\0", (-9 - length) % 64)
					tail = nil
					length = length * 8 -- convert "byte-counter" to "bit-counter"
					for j = 4, 11 do
						local low_byte = length % 256
						final_blocks[j] = string.char(low_byte)
						length = (length - low_byte) / 256
					end
	
					final_blocks = table.concat(final_blocks)
					md5_feed_64(H, final_blocks, 0, #final_blocks)
					for j = 1, 4 do
						H[j] = string.format("%08x", H[j] % 4294967296)
					end
	
					H = string.gsub(table.concat(H), "(..)(..)(..)(..)", "%4%3%2%1")
				end
	
				return H
			end
		end
	
		if message then
			-- Actually perform calculations and return the MD5 digest of a message
			return partial(message)()
		else
			-- Return function for chunk-by-chunk loading
			-- User should feed every chunk of input data as single argument to this function and finally get MD5 digest by invoking this function without an argument
			return partial
		end
	end
	
	local function sha1(message)
		-- Create an instance (private objects for current calculation)
		local H, length, tail = table.pack(table.unpack(md5_sha1_H)), 0, ""
	
		local function partial(message_part)
			if message_part then
				local partLength = #message_part
				if tail then
					length = length + partLength
					local offs = 0
					if tail ~= "" and #tail + partLength >= 64 then
						offs = 64 - #tail
						sha1_feed_64(H, tail .. string.sub(message_part, 1, offs), 0, 64)
						tail = ""
					end
	
					local size = partLength - offs
					local size_tail = size % 64
					sha1_feed_64(H, message_part, offs, size - size_tail)
					tail = tail .. string.sub(message_part, partLength + 1 - size_tail)
					return partial
				else
					error("Adding more chunks is not allowed after receiving the result", 2)
				end
			else
				if tail then
					local final_blocks = table.create(10) --{tail, "\128", string.rep("\0", (-9 - length) % 64 + 1)}
					final_blocks[1] = tail
					final_blocks[2] = "\128"
					final_blocks[3] = string.rep("\0", (-9 - length) % 64 + 1)
					tail = nil
	
					-- Assuming user data length is shorter than (TWO_POW_53)-9 bytes
					-- TWO_POW_53 bytes = TWO_POW_56 bits, so "bit-counter" fits in 7 bytes
					length = length * (8 / TWO56_POW_7) -- convert "byte-counter" to "bit-counter" and move decimal point to the left
					for j = 4, 10 do
						length = length % 1 * 256
						final_blocks[j] = string.char(math.floor(length))
					end
	
					final_blocks = table.concat(final_blocks)
					sha1_feed_64(H, final_blocks, 0, #final_blocks)
					for j = 1, 5 do
						H[j] = string.format("%08x", H[j] % 4294967296)
					end
	
					H = table.concat(H)
				end
	
				return H
			end
		end
	
		if message then
			-- Actually perform calculations and return the SHA-1 digest of a message
			return partial(message)()
		else
			-- Return function for chunk-by-chunk loading
			-- User should feed every chunk of input data as single argument to this function and finally get SHA-1 digest by invoking this function without an argument
			return partial
		end
	end
	
	local function keccak(block_size_in_bytes, digest_size_in_bytes, is_SHAKE, message)
		-- "block_size_in_bytes" is multiple of 8
		if type(digest_size_in_bytes) ~= "number" then
			-- arguments in SHAKE are swapped:
			--    NIST FIPS 202 defines SHAKE(message,num_bits)
			--    this module   defines SHAKE(num_bytes,message)
			-- it's easy to forget about this swap, hence the check
			error("Argument 'digest_size_in_bytes' must be a number", 2)
		end
	
		-- Create an instance (private objects for current calculation)
		local tail, lanes_lo, lanes_hi = "", table.create(25, 0), hi_factor_keccak == 0 and table.create(25, 0)
		local result
	
		--~     pad the input N using the pad function, yielding a padded bit string P with a length divisible by r (such that n = len(P)/r is integer),
		--~     break P into n consecutive r-bit pieces P0, ..., Pn-1 (last is zero-padded)
		--~     initialize the state S to a string of b 0 bits.
		--~     absorb the input into the state: For each block Pi,
		--~         extend Pi at the end by a string of c 0 bits, yielding one of length b,
		--~         XOR that with S and
		--~         apply the block permutation f to the result, yielding a new state S
		--~     initialize Z to be the empty string
		--~     while the length of Z is less than d:
		--~         append the first r bits of S to Z
		--~         if Z is still less than d bits long, apply f to S, yielding a new state S.
		--~     truncate Z to d bits
		local function partial(message_part)
			if message_part then
				local partLength = #message_part
				if tail then
					local offs = 0
					if tail ~= "" and #tail + partLength >= block_size_in_bytes then
						offs = block_size_in_bytes - #tail
						keccak_feed(lanes_lo, lanes_hi, tail .. string.sub(message_part, 1, offs), 0, block_size_in_bytes, block_size_in_bytes)
						tail = ""
					end
	
					local size = partLength - offs
					local size_tail = size % block_size_in_bytes
					keccak_feed(lanes_lo, lanes_hi, message_part, offs, size - size_tail, block_size_in_bytes)
					tail = tail .. string.sub(message_part, partLength + 1 - size_tail)
					return partial
				else
					error("Adding more chunks is not allowed after receiving the result", 2)
				end
			else
				if tail then
					-- append the following bits to the message: for usual SHA3: 011(0*)1, for SHAKE: 11111(0*)1
					local gap_start = is_SHAKE and 31 or 6
					tail = tail .. (#tail + 1 == block_size_in_bytes and string.char(gap_start + 128) or string.char(gap_start) .. string.rep("\0", (-2 - #tail) % block_size_in_bytes) .. "\128")
					keccak_feed(lanes_lo, lanes_hi, tail, 0, #tail, block_size_in_bytes)
					tail = nil
	
					local lanes_used = 0
					local total_lanes = math.floor(block_size_in_bytes / 8)
					local qwords = {}
	
					local function get_next_qwords_of_digest(qwords_qty)
						-- returns not more than 'qwords_qty' qwords ('qwords_qty' might be non-integer)
						-- doesn't go across keccak-buffer boundary
						-- block_size_in_bytes is a multiple of 8, so, keccak-buffer contains integer number of qwords
						if lanes_used >= total_lanes then
							keccak_feed(lanes_lo, lanes_hi, "\0\0\0\0\0\0\0\0", 0, 8, 8)
							lanes_used = 0
						end
	
						qwords_qty = math.floor(math.min(qwords_qty, total_lanes - lanes_used))
						if hi_factor_keccak ~= 0 then
							for j = 1, qwords_qty do
								qwords[j] = HEX64(lanes_lo[lanes_used + j - 1 + lanes_index_base])
							end
						else
							for j = 1, qwords_qty do
								qwords[j] = string.format("%08x", lanes_hi[lanes_used + j] % 4294967296) .. string.format("%08x", lanes_lo[lanes_used + j] % 4294967296)
							end
						end
	
						lanes_used = lanes_used + qwords_qty
						return string.gsub(table.concat(qwords, "", 1, qwords_qty), "(..)(..)(..)(..)(..)(..)(..)(..)", "%8%7%6%5%4%3%2%1"), qwords_qty * 8
					end
	
					local parts = {} -- digest parts
					local last_part, last_part_size = "", 0
	
					local function get_next_part_of_digest(bytes_needed)
						-- returns 'bytes_needed' bytes, for arbitrary integer 'bytes_needed'
						bytes_needed = bytes_needed or 1
						if bytes_needed <= last_part_size then
							last_part_size = last_part_size - bytes_needed
							local part_size_in_nibbles = bytes_needed * 2
							local result = string.sub(last_part, 1, part_size_in_nibbles)
							last_part = string.sub(last_part, part_size_in_nibbles + 1)
							return result
						end
	
						local parts_qty = 0
						if last_part_size > 0 then
							parts_qty = 1
							parts[parts_qty] = last_part
							bytes_needed = bytes_needed - last_part_size
						end
	
						-- repeats until the length is enough
						while bytes_needed >= 8 do
							local next_part, next_part_size = get_next_qwords_of_digest(bytes_needed / 8)
							parts_qty = parts_qty + 1
							parts[parts_qty] = next_part
							bytes_needed = bytes_needed - next_part_size
						end
	
						if bytes_needed > 0 then
							last_part, last_part_size = get_next_qwords_of_digest(1)
							parts_qty = parts_qty + 1
							parts[parts_qty] = get_next_part_of_digest(bytes_needed)
						else
							last_part, last_part_size = "", 0
						end
	
						return table.concat(parts, "", 1, parts_qty)
					end
	
					if digest_size_in_bytes < 0 then
						result = get_next_part_of_digest
					else
						result = get_next_part_of_digest(digest_size_in_bytes)
					end
	
				end
	
				return result
			end
		end
	
		if message then
			-- Actually perform calculations and return the SHA3 digest of a message
			return partial(message)()
		else
			-- Return function for chunk-by-chunk loading
			-- User should feed every chunk of input data as single argument to this function and finally get SHA3 digest by invoking this function without an argument
			return partial
		end
	end
	
	local function HexToBinFunction(hh)
		return string.char(tonumber(hh, 16))
	end
	
	local function hex2bin(hex_string)
		return (string.gsub(hex_string, "%x%x", HexToBinFunction))
	end
	
	local base64_symbols = {
		["+"] = 62, ["-"] = 62, [62] = "+";
		["/"] = 63, ["_"] = 63, [63] = "/";
		["="] = -1, ["."] = -1, [-1] = "=";
	}
	
	local symbol_index = 0
	for j, pair in {"AZ", "az", "09"} do
		for ascii = string.byte(pair), string.byte(pair, 2) do
			local ch = string.char(ascii)
			base64_symbols[ch] = symbol_index
			base64_symbols[symbol_index] = ch
			symbol_index = symbol_index + 1
		end
	end
	
	local function bin2base64(binary_string)
		local stringLength = #binary_string
		local result = table.create(math.ceil(stringLength / 3))
		local length = 0
	
		for pos = 1, #binary_string, 3 do
			local c1, c2, c3, c4 = string.byte(string.sub(binary_string, pos, pos + 2) .. '\0', 1, -1)
			length = length + 1
			result[length] =
				base64_symbols[math.floor(c1 / 4)] ..
				base64_symbols[c1 % 4 * 16 + math.floor(c2 / 16)] ..
				base64_symbols[c3 and c2 % 16 * 4 + math.floor(c3 / 64) or -1] ..
				base64_symbols[c4 and c3 % 64 or -1]
		end
	
		return table.concat(result)
	end
	
	local function base642bin(base64_string)
		local result, chars_qty = {}, 3
		for pos, ch in string.gmatch(string.gsub(base64_string, "%s+", ""), "()(.)") do
			local code = base64_symbols[ch]
			if code < 0 then
				chars_qty = chars_qty - 1
				code = 0
			end
	
			local idx = pos % 4
			if idx > 0 then
				result[-idx] = code
			else
				local c1 = result[-1] * 4 + math.floor(result[-2] / 16)
				local c2 = (result[-2] % 16) * 16 + math.floor(result[-3] / 4)
				local c3 = (result[-3] % 4) * 64 + code
				result[#result + 1] = string.sub(string.char(c1, c2, c3), 1, chars_qty)
			end
		end
	
		return table.concat(result)
	end
	
	local block_size_for_HMAC -- this table will be initialized at the end of the module
	--local function pad_and_xor(str, result_length, byte_for_xor)
	--	return string.gsub(str, ".", function(c)
	--		return string.char(bit32_bxor(string.byte(c), byte_for_xor))
	--	end) .. string.rep(string.char(byte_for_xor), result_length - #str)
	--end
	
	-- For the sake of speed of converting hexes to strings, there's a map of the conversions here
	local BinaryStringMap = {}
	for Index = 0, 255 do
		BinaryStringMap[string.format("%02x", Index)] = string.char(Index)
	end
	
	-- Update 02.14.20 - added AsBinary for easy GameAnalytics replacement.
	local function hmac(hash_func, key, message, AsBinary)
		-- Create an instance (private objects for current calculation)
		local block_size = block_size_for_HMAC[hash_func]
		if not block_size then
			error("Unknown hash function", 2)
		end
	
		local KeyLength = #key
		if KeyLength > block_size then
			key = string.gsub(hash_func(key), "%x%x", HexToBinFunction)
			KeyLength = #key
		end
	
		local append = hash_func()(string.gsub(key, ".", function(c)
			return string.char(bit32_bxor(string.byte(c), 0x36))
		end) .. string.rep("6", block_size - KeyLength)) -- 6 = string.char(0x36)
	
		local result
	
		local function partial(message_part)
			if not message_part then
				result = result or hash_func(
					string.gsub(key, ".", function(c)
						return string.char(bit32_bxor(string.byte(c), 0x5c))
					end) .. string.rep("\\", block_size - KeyLength) -- \ = string.char(0x5c)
					.. (string.gsub(append(), "%x%x", HexToBinFunction))
				)
	
				return result
			elseif result then
				error("Adding more chunks is not allowed after receiving the result", 2)
			else
				append(message_part)
				return partial
			end
		end
	
		if message then
			-- Actually perform calculations and return the HMAC of a message
			local FinalMessage = partial(message)()
			return AsBinary and (string.gsub(FinalMessage, "%x%x", BinaryStringMap)) or FinalMessage
		else
			-- Return function for chunk-by-chunk loading of a message
			-- User should feed every chunk of the message as single argument to this function and finally get HMAC by invoking this function without an argument
			return partial
		end
	end
	
	sha = {
		md5 = md5,
		sha1 = sha1,
		-- SHA2 hash functions:
		sha224 = function(message)
			return sha256ext(224, message)
		end;
	
		sha256 = function(message)
			return sha256ext(256, message)
		end;
	
		sha512_224 = function(message)
			return sha512ext(224, message)
		end;
	
		sha512_256 = function(message)
			return sha512ext(256, message)
		end;
	
		sha384 = function(message)
			return sha512ext(384, message)
		end;
	
		sha512 = function(message)
			return sha512ext(512, message)
		end;
	
		-- SHA3 hash functions:
		sha3_224 = function(message)
			return keccak((1600 - 2 * 224) / 8, 224 / 8, false, message)
		end;
	
		sha3_256 = function(message)
			return keccak((1600 - 2 * 256) / 8, 256 / 8, false, message)
		end;
	
		sha3_384 = function(message)
			return keccak((1600 - 2 * 384) / 8, 384 / 8, false, message)
		end;
	
		sha3_512 = function(message)
			return keccak((1600 - 2 * 512) / 8, 512 / 8, false, message)
		end;
	
		shake128 = function(message, digest_size_in_bytes)
			return keccak((1600 - 2 * 128) / 8, digest_size_in_bytes, true, message)
		end;
	
		shake256 = function(message, digest_size_in_bytes)
			return keccak((1600 - 2 * 256) / 8, digest_size_in_bytes, true, message)
		end;
	
		-- misc utilities:
		hmac = hmac; -- HMAC(hash_func, key, message) is applicable to any hash function from this module except SHAKE*
		hex_to_bin = hex2bin; -- converts hexadecimal representation to binary string
		base64_to_bin = base642bin; -- converts base64 representation to binary string
		bin_to_base64 = bin2base64; -- converts binary string to base64 representation
		--base64_encode = Base64.Encode;
		--base64_decode = Base64.Decode;
	}
	
	block_size_for_HMAC = {
		[sha.md5] = 64;
		[sha.sha1] = 64;
		[sha.sha224] = 64;
		[sha.sha256] = 64;
		[sha.sha512_224] = 128;
		[sha.sha512_256] = 128;
		[sha.sha384] = 128;
		[sha.sha512] = 128;
		[sha.sha3_224] = (1600 - 2 * 224) / 8;
		[sha.sha3_256] = (1600 - 2 * 256) / 8;
		[sha.sha3_384] = (1600 - 2 * 384) / 8;
		[sha.sha3_512] = (1600 - 2 * 512) / 8;
	}
	
	local hashlib = sha
	
	--!strict
	-- metatablecat 2022
	
	lz4 = {}
	
	type Streamer = {
		Offset: number,
		Source: string,
		Length: number,
		IsFinished: boolean,
		LastUnreadBytes: number,
	
		read: (Streamer, len: number?, shiftOffset: boolean?) -> string,
		seek: (Streamer, len: number) -> (),
		append: (Streamer, newData: string) -> (),
		toEnd: (Streamer) -> ()
	}
	
	type BlockData = {
		[number]: {
			Literal: string,
			LiteralLength: number,
			MatchOffset: number?,
			MatchLength: number?
		}
	}
	
	local function plainFind(str, pat)
		return string.find(str, pat, 0, true)
	end
	
	local function streamer(str): Streamer
		local Stream = {}
		Stream.Offset = 0
		Stream.Source = str
		Stream.Length = string.len(str)
		Stream.IsFinished = false	
		Stream.LastUnreadBytes = 0
	
		function Stream.read(self: Streamer, len: number?, shift: boolean?): string
			local len = len or 1
			local shift = if shift ~= nil then shift else true
			local dat = string.sub(self.Source, self.Offset + 1, self.Offset + len)
	
			local dataLength = string.len(dat)
			local unreadBytes = len - dataLength
	
			if shift then
				self:seek(len)
			end
	
			self.LastUnreadBytes = unreadBytes
			return dat
		end
	
		function Stream.seek(self: Streamer, len: number)
			local len = len or 1
	
			self.Offset = math.clamp(self.Offset + len, 0, self.Length)
			self.IsFinished = self.Offset >= self.Length
		end
	
		function Stream.append(self: Streamer, newData: string)
			-- adds new data to the end of a stream
			self.Source ..= newData
			self.Length = string.len(self.Source)
			self:seek(0) --hacky but forces a recalculation of the isFinished flag
		end
	
		function Stream.toEnd(self: Streamer)
			self:seek(self.Length)
		end
	
		return Stream
	end
	
	function lz4.compress(str: string): string
		local blocks: BlockData = {}
		local iostream = streamer(str)
	
		if iostream.Length > 12 then
			local firstFour = iostream:read(4)
	
			local processed = firstFour
			local lit = firstFour
			local match = ""
			local LiteralPushValue = ""
			local pushToLiteral = true
	
			repeat
				pushToLiteral = true
				local nextByte = iostream:read()
	
				if plainFind(processed, nextByte) then
					local next3 = iostream:read(3, false)
	
					if string.len(next3) < 3 then
						--push bytes to literal block then break
						LiteralPushValue = nextByte .. next3
						iostream:seek(3)
					else
						match = nextByte .. next3
	
						local matchPos = plainFind(processed, match)
						if matchPos then
							iostream:seek(3)
							repeat
								local nextMatchByte = iostream:read(1, false)
								local newResult = match .. nextMatchByte
	
								local repos = plainFind(processed, newResult) 
								if repos then
									match = newResult
									matchPos = repos
									iostream:seek(1)
								end
							until not plainFind(processed, newResult) or iostream.IsFinished
	
							local matchLen = string.len(match)
							local pushMatch = true
	
							if iostream.Length - iostream.Offset <= 5 then
								LiteralPushValue = match
								pushMatch = false
								--better safe here, dont bother pushing to match ever
							end
	
							if pushMatch then
								pushToLiteral = false
	
								-- gets the position from the end of processed, then slaps it onto processed
								local realPosition = string.len(processed) - matchPos
								processed = processed .. match
	
								table.insert(blocks, {
									Literal = lit,
									LiteralLength = string.len(lit),
									MatchOffset = realPosition + 1,
									MatchLength = matchLen,
								})
								lit = ""
							end
						else
							LiteralPushValue = nextByte
						end
					end
				else
					LiteralPushValue = nextByte
				end
	
				if pushToLiteral then
					lit = lit .. LiteralPushValue
					processed = processed .. nextByte
				end
			until iostream.IsFinished
			table.insert(blocks, {
				Literal = lit,
				LiteralLength = string.len(lit)
			})
		else
			local str = iostream.Source
			blocks[1] = {
				Literal = str,
				LiteralLength = string.len(str)
			}
		end
	
		-- generate the output chunk
		-- %s is for adding header
		local output = string.rep("\x00", 4)
		local function write(char)
			output = output .. char
		end
		-- begin working through chunks
		for chunkNum, chunk in blocks do
			local litLen = chunk.LiteralLength
			local matLen = (chunk.MatchLength or 4) - 4
	
			-- create token
			local tokenLit = math.clamp(litLen, 0, 15)
			local tokenMat = math.clamp(matLen, 0, 15)
	
			local token = bit32.lshift(tokenLit, 4) + tokenMat
			write(string.pack("<I1", token))
	
			if litLen >= 15 then
				litLen = litLen - 15
				--begin packing extra bytes
				repeat
					local nextToken = math.clamp(litLen, 0, 0xFF)
					write(string.pack("<I1", nextToken))
					if nextToken == 0xFF then
						litLen = litLen - 255
					end
				until nextToken < 0xFF
			end
	
			-- push raw lit data
			write(chunk.Literal)
	
			if chunkNum ~= #blocks then
				-- push offset as u16
				write(string.pack("<I2", chunk.MatchOffset))
	
				-- pack extra match bytes
				if matLen >= 15 then
					matLen = matLen - 15
	
					repeat
						local nextToken = math.clamp(matLen, 0, 0xFF)
						write(string.pack("<I1", nextToken))
						if nextToken == 0xFF then
							matLen = matLen - 255
						end
					until nextToken < 0xFF
				end
			end
		end
		--append chunks
		local compLen = string.len(output) - 4
		local decompLen = iostream.Length
	
		return string.pack("<I4", compLen) .. string.pack("<I4", decompLen) .. output
	end
	
	function lz4.decompress(lz4data: string): string
		local inputStream = streamer(lz4data)
	
		local compressedLen = string.unpack("<I4", inputStream:read(4))
		local decompressedLen = string.unpack("<I4", inputStream:read(4))
		local reserved = string.unpack("<I4", inputStream:read(4))
	
		if compressedLen == 0 then
			return inputStream:read(decompressedLen)
		end
	
		local outputStream = streamer("")
	
		repeat
			local token = string.byte(inputStream:read())
			local litLen = bit32.rshift(token, 4)
			local matLen = bit32.band(token, 15) + 4
	
			if litLen >= 15 then
				repeat
					local nextByte = string.byte(inputStream:read())
					litLen += nextByte
				until nextByte ~= 0xFF
			end
	
			local literal = inputStream:read(litLen)
			outputStream:append(literal)
			outputStream:toEnd()
			if outputStream.Length < decompressedLen then
				--match
				local offset = string.unpack("<I2", inputStream:read(2))
				if matLen >= 19 then
					repeat
						local nextByte = string.byte(inputStream:read())
						matLen += nextByte
					until nextByte ~= 0xFF
				end
	
				outputStream:seek(-offset)
				local pos = outputStream.Offset
				local match = outputStream:read(matLen)
				local unreadBytes = outputStream.LastUnreadBytes
				local extra
				if unreadBytes then
					repeat
						outputStream.Offset = pos
						extra = outputStream:read(unreadBytes)
						unreadBytes = outputStream.LastUnreadBytes
						match ..= extra
					until unreadBytes <= 0
				end
	
				outputStream:append(match)
				outputStream:toEnd()
			end
	
		until outputStream.Length >= decompressedLen
	
		return outputStream.Source
	end
	
	local lz4 = lz4
	
	crypt = {}
	
	do
		local b64 = {
			encode = function(input)
				local Type = type(input)
				if Type ~= "string" and Type ~= "number" then
					return error("arg #1 must be type string or number", 2)
				end
	
				return if input == "" then input else buffer.tostring(base64.encode(buffer.fromstring(input)))
			end,
			decode = function(input)
				local Type = type(input)
				if Type ~= "string" and Type ~= "number" then
					return error("arg #1 must be type string or number", 2)
				end
	
				return if input == "" then input else buffer.tostring(base64.decode(buffer.fromstring(input)))
			end,
		}
		crypt.base64 = b64
	
		crypt.base64encode = b64.encode
		crypt.base64_encode = b64.encode
	
		crypt.base64decode = b64.decode
		crypt.base64_decode = b64.decode
	end
	
	do
		local modes = {}
	
		for _, ciphermode in { "ECB", "CBC", "PCBC", "CFB", "OFB", "CTR" } do -- Missing: GCM (important)
			local encrypt = aes["encrypt_" .. ciphermode]
			local decrypt = aes["decrypt_" .. ciphermode]
	
			modes[string.lower(ciphermode)] = { encrypt = encrypt, decrypt = decrypt or encrypt }
		end
	
		-- Function to add PKCS#7 padding to a string
		local function PKCS7_unpad(inputString)
			local blockSize = 16
			local length = (#inputString % blockSize)
	
			-- Only add padding if needed
			if 0 == length then
				return inputString
			end
	
			local paddingSize = blockSize - length
	
			local padding = string.rep(string.char(paddingSize), paddingSize)
			return inputString .. padding
		end
	
		-- Function to remove PKCS#7 padding from a padded string
		local function PKCS7_pad(paddedString)
			local lastByte = string.byte(paddedString, -1)
	
			-- Check if padding is present
			if lastByte <= 16 and 0 < lastByte then
				return string.sub(paddedString, 1, -lastByte - 1)
			else
				return paddedString
			end
		end
	
		local function table_type(t)
			local ct = 1
			for i in t do
				if i ~= ct then
					return "dictionary"
				end
				ct += 1
			end
			return "array"
		end
	
		local function bytes_to_char(t)
			return string.char(unpack(t))
		end
	
		local function crypt_generalized(action: string?)
			return function(data: string, key: string, iv: string?, mode: string?): (string, string)
				if mode and type(mode) == "string" then
					mode = string.lower(mode)
					mode = modes[mode]
				else
					mode = modes.cbc -- Default
				end
	
				if iv then
					iv = crypt.base64decode(iv)
					pcall(function()
						iv = game:GetService("HttpService"):JSONDecode(iv)
					end)
					if 16 < #iv then
						iv = string.sub(iv, 1, 16)
					elseif #iv < 16 then
						iv = PKCS7_unpad(iv)
					end
				end
	
				pcall(function()
					key = crypt.base64decode(key)
				end)
	
				-- TODO This code below is even worse
				local crypt_f = mode[action]
				data, iv = crypt_f(key, if action == "encrypt" then PKCS7_unpad(data) else crypt.base64decode(data), iv)
	
				data = bytes_to_char(data)
	
				if action == "decrypt" then
					data = PKCS7_pad(data)
				else
					if table_type(iv) == "array" then
						iv = bytes_to_char(iv)
					else
						iv = game:GetService("HttpService"):JSONEncode(iv)
					end
					iv = crypt.base64encode(iv)
					data = crypt.base64encode(data)
				end
	
				return data, iv
			end
		end
	
		crypt.encrypt = crypt_generalized("encrypt")
		crypt.decrypt = crypt_generalized("decrypt")
	
		-- * Tests
		-- for mode in { "ECB", "CBC", "PCBC", "CFB", "OFB", "CTR" } do
		--     local key = "10syfhOVeMW[F#Ojbqjv[)R7,Ad=diNB"
		--     local data = "test lorem ips\1" -- "xtest lorem ips\1" breaks our padding algorithm sadly lol
		--     local encrypted, iv = crypt.encrypt(data, key, nil, mode)
	
		--     assert(iv, "crypt.encrypt should return an IV")
		--     local decrypted = crypt.decrypt(encrypted, key, iv, mode)
	
		--     assert(decrypted == data, "Failed to decrypt raw string from encrypted data")
		-- end
	end
	
	function crypt.generatebytes(size: number): string
		local randomBytes = table.create(size)
		for i = 1, size do
			randomBytes[i] = string.char(math.random(0, 255))
		end
	
		return crypt.base64encode(table.concat(randomBytes))
	end
	
	function crypt.generatekey()
		return crypt.generatebytes(32)
	end
	
	function crypt.hash(data: string, algorithm: string): string
		return hashlib[string.gsub(algorithm, "-", "_")](data)
	end
	
	function crypt.hmac(data: string, key: string, asBinary: boolean): string
		--* sha512_256 because synapse uses it - https://web.archive.org/web/20231030192906/https://synllc.github.io/synapse-x-documentation/reference/namespace/syn.crypt.html#hmac - https://libsodium.gitbook.io/doc/secret-key_cryptography/secret-key_authentication#algorithm-details
	
		return hashlib.hmac(hashlib.sha512_256, data, key, asBinary)
	end
	
	crypt.lz4 = lz4
	crypt.lz4compress = lz4.compress
	crypt.lz4decompress = lz4.decompress
	lz4compress = lz4.compress
	lz4decompress = lz4.decompress
	base64_encode = base64.encode
	base64_decode = base64.decode
	local RunService = game:GetService("RunService")
	local Capped, FractionOfASecond
	local Heartbeat = RunService.Heartbeat
	
	function setfpscap(fps_cap)
		if fps_cap == 0 or fps_cap == nil or 1e4 <= fps_cap then -- ~7k fps is the highest people have gotten; --?maybe compare to getfpsmax instead? (but we have to ensure getfpsmax is accurate first)
			if Capped then
				task.cancel(Capped)
				Capped = nil
				FractionOfASecond = nil
			end
			return
		end
	
		FractionOfASecond = 1 / fps_cap
		if Capped then
			return
		end
		local function Capper()
			-- * Modified version of https://github.com/MaximumADHD/Super-Nostalgia-Zone/blob/540221bc945a8fc3a45baf51b40e02272a21329d/Client/FpsCap.client.lua#
			local t0 = os.clock()
			Heartbeat:Wait()
			-- repeat until t0 + t1 < tick()
			-- local count = 0
			while os.clock() <= t0 + FractionOfASecond do -- * not using repeat to avoid unreasonable extra iterations
				-- count+=1
			end
			-- task.spawn(print,count)
		end
		Capper() -- Yield until it kicks in basically
		Capped = task.spawn(function()
			-- capping = true -- * this works too
			while true do
				Capper()
			end
		end)
	end
	
	
	local debug_lib = table.clone(debug)
	
	debug_lib.getinfo = function(f, options)
		if type(options) == "string" then
			options = string.lower(options) -- if someone adds "L" for activelines and "l" for currentline then thats on them (it will just slow down this function because duplicate debug.infos)
		else
			options = "sflnu"
		end
	
		local result = {}
	
		for index = 1, #options do
			local option = string.sub(options, index, index)
			if "s" == option then
				local short_src = debug.info(f, "s")
	
				result.short_src = short_src
				result.source = "@" .. short_src
				result.what = if short_src == "[C]" then "C" else "Lua"
			elseif "f" == option then
				result.func = debug.info(f, "f")
			elseif "l" == option then
				result.currentline = debug.info(f, "l")
			elseif "n" == option then
				result.name = debug.info(f, "n")
			elseif "u" == option or option == "a" then
				local numparams, is_vararg = debug.info(f, "a")
				result.numparams = numparams
				result.is_vararg = if is_vararg then 1 else 0
	
				if "u" == option then
					result.nups = -1 --#debug.getupvalues(f)
				end
			end
		end
	
		return result
	end
	
	debug_lib.getmetatable = function(table_or_userdata)
		local result = getmetatable(table_or_userdata)
		if result == nil then -- No meta
			return
		end
		if type(result) == "table" and pcall(setmetatable, table_or_userdata, result) then
			return result
		end
		local real_metamethods = {}
		xpcall(function()
			return table_or_userdata._
		end, function()
			real_metamethods.__index = debug.info(2, "f")
		end)
		xpcall(function()
			table_or_userdata._ = table_or_userdata
		end, function()
			real_metamethods.__newindex = debug.info(2, "f")
		end)
		xpcall(function()
			return table_or_userdata:___()
		end, function()
			real_metamethods.__namecall = debug.info(2, "f")
		end)
		xpcall(function()
			table_or_userdata()
		end, function()
			real_metamethods.__call = debug.info(2, "f")
		end)
		xpcall(function() -- * LUAU
			for _ in table_or_userdata do
			end
		end, function()
			real_metamethods.__iter = debug.info(2, "f")
		end)
		xpcall(function()
			return #table_or_userdata
		end, function()
			real_metamethods.__len = debug.info(2, "f")
		end)
		local type_check_semibypass = {}
		xpcall(function()
			return table_or_userdata == table_or_userdata
		end, function()
			real_metamethods.__eq = debug.info(2, "f")
		end)
		xpcall(function()
			return table_or_userdata + type_check_semibypass
		end, function()
			real_metamethods.__add = debug.info(2, "f")
		end)
		xpcall(function()
			return table_or_userdata - type_check_semibypass
		end, function()
			real_metamethods.__sub = debug.info(2, "f")
		end)
		xpcall(function()
			return table_or_userdata * type_check_semibypass
		end, function()
			real_metamethods.__mul = debug.info(2, "f")
		end)
		xpcall(function()
			return table_or_userdata / type_check_semibypass
		end, function()
			real_metamethods.__div = debug.info(2, "f")
		end)
		xpcall(function() -- * LUAU
			return table_or_userdata // type_check_semibypass
		end, function()
			real_metamethods.__idiv = debug.info(2, "f")
		end)
		xpcall(function()
			return table_or_userdata % type_check_semibypass
		end, function()
			real_metamethods.__mod = debug.info(2, "f")
		end)
		xpcall(function()
			return table_or_userdata ^ type_check_semibypass
		end, function()
			real_metamethods.__pow = debug.info(2, "f")
		end)
		xpcall(function()
			return -table_or_userdata
		end, function()
			real_metamethods.__unm = debug.info(2, "f")
		end)
		xpcall(function()
			return table_or_userdata < type_check_semibypass
		end, function()
			real_metamethods.__lt = debug.info(2, "f")
		end)
		xpcall(function()
			return table_or_userdata <= type_check_semibypass
		end, function()
			real_metamethods.__le = debug.info(2, "f")
		end)
		xpcall(function()
			return table_or_userdata .. type_check_semibypass
		end, function()
			real_metamethods.__concat = debug.info(2, "f")
		end)
		real_metamethods.__type = typeof(table_or_userdata)
		real_metamethods.__metatable = getmetatable(game)
		real_metamethods.__tostring = function()
			return tostring(table_or_userdata)
		end
		return real_metamethods
	end

	debug_lib.setmetatable = setmetatable
	
	
	debug = debug_lib

	function getrawmetatable(object)
		assert(type(object) == "table" or type(object) == "userdata", "invalid argument #1 to 'getrawmetatable' (table or userdata expected, got " .. type(object) .. ")", 2)
		local raw_mt = debug.getmetatable(object)
		if raw_mt and raw_mt.__metatable then
			raw_mt.__metatable = nil 
			local result_mt = debug.getmetatable(object)
			raw_mt.__metatable = "Locked!"
			return result_mt
		end
		return raw_mt
	end

	function setrawmetatable(object, newmetatbl)
		assert(type(object) == "table" or type(object) == "userdata", "invalid argument #1 to 'setrawmetatable' (table or userdata expected, got " .. type(object) .. ")", 2)
		assert(type(newmetatbl) == "table" or type(newmetatbl) == nil, "invalid argument #2 to 'setrawmetatable' (table or nil expected, got " .. type(object) .. ")", 2)
		local raw_mt = debug.getmetatable(object)
		if raw_mt and raw_mt.__metatable then
			local old_metatable = raw_mt.__metatable
			raw_mt.__metatable = nil  
			local success, err = pcall(setmetatable, object, newmetatbl)
			raw_mt.__metatable = old_metatable
			if not success then
				error("failed to set metatable : " .. tostring(err), 2)
			end
			return true  
		end
		setmetatable(object, newmetatbl)
		return true
	end
	
	cache = {}
	
	local CloneRefs = { Clones = setmetatable({}, { __mode = "ks" }), Originals = setmetatable({}, { __mode = "vs" }) } --*s means shrinkable, weak keys for Clones because structure is {Clone = Originals[OriginalInstance]} so when clone gets garbage collected the only ref to value inside Originals table is garbage collected too because Originals has weak values
	
	do
		local function ReturnOriginal(instance) --! This function might be needed to call in other functions (testing required)
			local CloneInfo = CloneRefs.Clones[instance] -- *Checks if its a clone and not a real instance
	
			if CloneInfo then
				return CloneInfo.Original -- *Grabs the original instance then
			end
		end
	
		
	
		function cache.cloneref(instance)
			local Original = ReturnOriginal(instance)
			if Original then
				instance = Original
			end
	
			local Clone = newproxy(true)
			local Mt_Clone = getmetatable(Clone)
			local Mt_Real = getrawmetatable(instance)
	
			local CloneInfo = CloneRefs.Originals[instance] --* If this exists then Instance has already been cloned at least once
			if not CloneInfo then
				CloneInfo = { Original = instance, __type = Mt_Real.__type }
				CloneRefs.Originals[instance] = CloneInfo
			end
	
			CloneRefs.Clones[Clone] = CloneInfo --* All clones of the same instance point to the same table
	
			for Metamethod, Value in Mt_Real do
				Mt_Clone[Metamethod] = type(Value) == "function"
						and function(self, ...)
							return Value(instance, ...)
						end
					or Value
			end
	
			return Clone --, if Mt_Clone then Mt_Clone else nil -- Make sure this only works inside init script
		end
		function cache.compareinstances(instance, instance2)
			-- assert(typeof(instance) == "Instance", `arg #1 must be type Instance`) -- Uncomment when we start hooking typeof
			-- assert(typeof(instance2) == "Instance", `arg #2 must be type Instance`) -- Uncomment when we start hooking typeof
	
			local CloneInfo = CloneRefs.Clones[instance] -- *Checks if its a clone and not a real instance
			local CloneInfo2 = CloneRefs.Clones[instance2] -- *Checks if its a clone and not a real instance
			if CloneInfo then
				instance = CloneInfo.Original
			end
			if CloneInfo2 then
				instance2 = CloneInfo2.Original
			end
	
			return instance == instance2
		end
	
		cache.iscached = function(thing)
			if cache[thing] == 'REMOVE' then return false end
			return typeof(thing) == "Instance"
		end
		cache.invalidate = function(thing)
			cache[thing] = 'REMOVE'
			thing.Parent = nil
		end
		cache.replace = function(a, b)
			if cache[a] then
				cache[a] = b
			end
			local n, p = a.Name, a.Parent -- name, parent
			b.Parent = p
			b.Name = n
			a.Parent = nil
		end
	
		iscached = cache.iscached
		cloneref = cache.cloneref
		invalidate = cache.invalidate
		replace = cache.replace
		compareinstances = cache.compareinstances
	
	end
	
	-- objects
	local camera = workspace.CurrentCamera
	
	drawing_container = Instance.new("ScreenGui")
	drawing_container.Name = "Drawing"
	drawing_container.IgnoreGuiInset = true
	drawing_container.DisplayOrder = 0x7fffffff
	
	local wedge_template = Instance.new("ImageLabel")
	wedge_template.BackgroundTransparency = 1
	wedge_template.AnchorPoint = Vector2.one / 2
	wedge_template.BorderSizePixel = 0
	wedge_template.Image = "rbxassetid://0"
	wedge_template.ImageColor3 = Color3.new()
	wedge_template.ZIndex = 0
	
	-- variables
	local vect2_half = Vector2.one / 2
	local drawing_idx = 0
	
	drawing_obj_reg = {}
	
	local base_drawing_obj = setmetatable({
		Visible = true,
		ZIndex = 0,
		Transparency = 1,
		Color = Color3.new(),
		Remove = function(self)
			setmetatable(self, nil)
	
			local obj_idx = table.find(drawing_obj_reg, self)
			if obj_idx then
				table.remove(drawing_obj_reg, obj_idx)
			end
		end,
	}, {
		__add = function(t1, t2)
			local result = table.clone(t1)
	
			for index, value in t2 do
				result[index] = value
			end
			return result
		end,
	})
	
	local drawing_fonts_list = {
		[0] = Font.fromEnum(Enum.Font.BuilderSans),
		Font.fromEnum(Enum.Font.Arial),
		Font.fromEnum(Enum.Font.Nunito),
		Font.fromEnum(Enum.Font.RobotoMono),
	}
	
	local triangle_assets = {
		left = "rbxassetid://319692171",
		right = "rbxassetid://319692151",
	}
	
	-- function
	local function get_font_from_idx(font_idx: number): Font
		return drawing_fonts_list[font_idx]
	end
	
	local function convert_dtransparency(transparency: number): number
		return math.clamp(1 - transparency, 0, 1)
	end
	
	-- from egomoose: https://github.com/EgoMoose/Articles/blob/master/2d%20triangles/2d%20triangles.md
	local function new_2d_triangle(parent)
		local wedges = {
			w1 = wedge_template:Clone(),
			w2 = wedge_template:Clone(),
		}
		local is_destroyed = false
	
		wedges.w1.Parent = parent
		wedges.w2.Parent = parent
	
		local function construct_triangle(point_a, point_b, point_c)
			if not (wedges.w1.Visible and wedges.w2.Visible) then
				return
			end
	
			if is_destroyed then
				return
			end
	
			local ab, ac, bc = point_b - point_a, point_c - point_a, point_c - point_b
			local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
	
			if abd > acd and abd > bcd then
				point_c, point_a = point_a, point_c
			elseif acd > bcd and acd > abd then
				point_a, point_b = point_b, point_a
			end
	
			ab, ac, bc = (point_b - point_a), (point_c - point_a), (point_c - point_b)
	
			local unit = bc.Unit
			local height = unit:Cross(ab)
			local flip = (height >= 0)
			local theta = math.deg(math.atan2(unit.y, unit.x)) + (if flip then 0 else 180)
	
			local m1 = (point_a + point_b) / 2
			local m2 = (point_a + point_c) / 2
	
			wedges.w1.Image = (if flip then triangle_assets.right else triangle_assets.left)
			wedges.w1.AnchorPoint = vect2_half
			wedges.w1.Size = UDim2.fromOffset(math.abs(unit:Dot(ab)), height)
			wedges.w1.Position = UDim2.fromOffset(m1.x, m1.y)
			wedges.w1.Rotation = theta
	
			wedges.w2.Image = (if flip then triangle_assets.left else triangle_assets.right)
			wedges.w2.AnchorPoint = vect2_half
			wedges.w2.Size = UDim2.fromOffset(math.abs(unit:Dot(ac)), height)
			wedges.w2.Position = UDim2.fromOffset(m2.x, m2.y)
			wedges.w2.Rotation = theta
		end
	
		local function destroy_triangle()
			is_destroyed = true
	
			for _, obj in wedges do
				obj:Destroy()
			end
			table.clear(wedges)
		end
		return construct_triangle, destroy_triangle, wedges
	end
	-- main
	local drawing_lib = {}
	drawing_lib.Fonts = {
		["UI"] = 0,
		["System"] = 1,
		["Plex"] = 2,
		["Monospace"] = 3,
	}
	do
		local function new(drawing_type)
			drawing_idx += 1
			local drawing_obj = {}
	
			if drawing_type == "Line" then
				local drawing_info = (
					{
						From = Vector2.zero,
						To = Vector2.zero,
						Thickness = 1,
					} + base_drawing_obj
				)
	
				local lineFrame = Instance.new("Frame")
				lineFrame.Name = drawing_idx
				lineFrame.AnchorPoint = (Vector2.one * 0.5)
				lineFrame.BorderSizePixel = 0
	
				lineFrame.BackgroundColor3 = drawing_info.Color
				lineFrame.Visible = drawing_info.Visible
				lineFrame.ZIndex = drawing_info.ZIndex
				lineFrame.BackgroundTransparency = convert_dtransparency(drawing_info.Transparency)
	
				lineFrame.Size = UDim2.new()
	
				lineFrame.Parent = drawing_container
	
				return setmetatable(drawing_obj, {
					__newindex = function(_, index, value)
						if type(drawing_info[index]) == "nil" then
							return
						end
	
						if index == "From" then
							local direction = (drawing_info.To - value)
							local center = (drawing_info.To + value) / 2
							local distance = direction.Magnitude
							local theta = math.deg(math.atan2(direction.Y, direction.X))
	
							lineFrame.Position = UDim2.fromOffset(center.X, center.Y)
							lineFrame.Rotation = theta
							lineFrame.Size = UDim2.fromOffset(distance, drawing_info.Thickness)
						elseif index == "To" then
							local direction = (value - drawing_info.From)
							local center = (value + drawing_info.From) / 2
							local distance = direction.Magnitude
							local theta = math.deg(math.atan2(direction.Y, direction.X))
	
							lineFrame.Position = UDim2.fromOffset(center.X, center.Y)
							lineFrame.Rotation = theta
							lineFrame.Size = UDim2.fromOffset(distance, drawing_info.Thickness)
						elseif index == "Thickness" then
							local distance = (drawing_info.To - drawing_info.From).Magnitude
	
							lineFrame.Size = UDim2.fromOffset(distance, value)
						elseif index == "Visible" then
							lineFrame.Visible = value
						elseif index == "ZIndex" then
							lineFrame.ZIndex = value
						elseif index == "Transparency" then
							lineFrame.BackgroundTransparency = convert_dtransparency(value)
						elseif index == "Color" then
							lineFrame.BackgroundColor3 = value
						end
						drawing_info[index] = value
					end,
					__index = function(self, index)
						if index == "Remove" or index == "Destroy" then
							return function()
								lineFrame:Destroy()
								drawing_info.Remove(self)
								return drawing_info:Remove()
							end
						end
						return drawing_info[index]
					end,
				})
			elseif drawing_type == "Text" then
				local drawing_info = (
					{
						Text = "",
						Font = drawing_lib.Fonts.UI,
						Size = 0,
						Position = Vector2.zero,
						Center = false,
						Outline = false,
						OutlineColor = Color3.new(),
					} + base_drawing_obj
				)
	
				local textLabel, uiStroke = Instance.new("TextLabel"), Instance.new("UIStroke")
				textLabel.Name = drawing_idx
				textLabel.AnchorPoint = (Vector2.one * 0.5)
				textLabel.BorderSizePixel = 0
				textLabel.BackgroundTransparency = 1
	
				textLabel.Visible = drawing_info.Visible
				textLabel.TextColor3 = drawing_info.Color
				textLabel.TextTransparency = convert_dtransparency(drawing_info.Transparency)
				textLabel.ZIndex = drawing_info.ZIndex
	
				textLabel.FontFace = get_font_from_idx(drawing_info.Font)
				textLabel.TextSize = drawing_info.Size
	
				textLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
					local textBounds = textLabel.TextBounds
					local offset = textBounds / 2
	
					textLabel.Size = UDim2.fromOffset(textBounds.X, textBounds.Y)
					textLabel.Position = UDim2.fromOffset(
						drawing_info.Position.X + (if not drawing_info.Center then offset.X else 0),
						drawing_info.Position.Y + offset.Y
					)
				end)
	
				uiStroke.Thickness = 1
				uiStroke.Enabled = drawing_info.Outline
				uiStroke.Color = drawing_info.Color
	
				textLabel.Parent, uiStroke.Parent = drawing_container, textLabel
				return setmetatable(drawing_obj, {
					__newindex = function(_, index, value)
						if type(drawing_info[index]) == "nil" then
							return
						end
	
						if index == "Text" then
							textLabel.Text = value
						elseif index == "Font" then
							value = math.clamp(value, 0, 3)
							textLabel.FontFace = get_font_from_idx(value)
						elseif index == "Size" then
							textLabel.TextSize = value
						elseif index == "Position" then
							local offset = textLabel.TextBounds / 2
	
							textLabel.Position = UDim2.fromOffset(
								value.X + (if not drawing_info.Center then offset.X else 0),
								value.Y + offset.Y
							)
						elseif index == "Center" then
							local position = (if value then camera.ViewportSize / 2 else drawing_info.Position)
	
							textLabel.Position = UDim2.fromOffset(position.X, position.Y)
						elseif index == "Outline" then
							uiStroke.Enabled = value
						elseif index == "OutlineColor" then
							uiStroke.Color = value
						elseif index == "Visible" then
							textLabel.Visible = value
						elseif index == "ZIndex" then
							textLabel.ZIndex = value
						elseif index == "Transparency" then
							local transparency = convert_dtransparency(value)
	
							textLabel.TextTransparency = transparency
							uiStroke.Transparency = transparency
						elseif index == "Color" then
							textLabel.TextColor3 = value
						end
						drawing_info[index] = value
					end,
					__index = function(self, index)
						if index == "Remove" or index == "Destroy" then
							return function()
								textLabel:Destroy()
								drawing_info.Remove(self)
								return drawing_info:Remove()
							end
						elseif index == "TextBounds" then
							return textLabel.TextBounds
						end
						return drawing_info[index]
					end,
				})
			elseif drawing_type == "Circle" then
				local drawing_info = (
					{
						Radius = 150,
						Position = Vector2.zero,
						Thickness = 0.7,
						Filled = false,
					} + base_drawing_obj
				)
	
				local circleFrame, uiCorner, uiStroke =
					Instance.new("Frame"), Instance.new("UICorner"), Instance.new("UIStroke")
				circleFrame.Name = drawing_idx
				circleFrame.AnchorPoint = (Vector2.one * 0.5)
				circleFrame.BorderSizePixel = 0
	
				circleFrame.BackgroundTransparency = (
					if drawing_info.Filled then convert_dtransparency(drawing_info.Transparency) else 1
				)
				circleFrame.BackgroundColor3 = drawing_info.Color
				circleFrame.Visible = drawing_info.Visible
				circleFrame.ZIndex = drawing_info.ZIndex
	
				uiCorner.CornerRadius = UDim.new(1, 0)
				circleFrame.Size = UDim2.fromOffset(drawing_info.Radius, drawing_info.Radius)
	
				uiStroke.Thickness = drawing_info.Thickness
				uiStroke.Enabled = not drawing_info.Filled
				uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	
				circleFrame.Parent, uiCorner.Parent, uiStroke.Parent = drawing_container, circleFrame, circleFrame
				return setmetatable(drawing_obj, {
					__newindex = function(_, index, value)
						if type(drawing_info[index]) == "nil" then
							return
						end
	
						if index == "Radius" then
							local radius = value * 2
							circleFrame.Size = UDim2.fromOffset(radius, radius)
						elseif index == "Position" then
							circleFrame.Position = UDim2.fromOffset(value.X, value.Y)
						elseif index == "Thickness" then
							value = math.clamp(value, 0.6, 0x7fffffff)
							uiStroke.Thickness = value
						elseif index == "Filled" then
							circleFrame.BackgroundTransparency = (
								if value then convert_dtransparency(drawing_info.Transparency) else 1
							)
							uiStroke.Enabled = not value
						elseif index == "Visible" then
							circleFrame.Visible = value
						elseif index == "ZIndex" then
							circleFrame.ZIndex = value
						elseif index == "Transparency" then
							local transparency = convert_dtransparency(value)
	
							circleFrame.BackgroundTransparency = (if drawing_info.Filled then transparency else 1)
							uiStroke.Transparency = transparency
						elseif index == "Color" then
							circleFrame.BackgroundColor3 = value
							uiStroke.Color = value
						end
						drawing_info[index] = value
					end,
					__index = function(self, index)
						if index == "Remove" or index == "Destroy" then
							return function()
								circleFrame:Destroy()
								drawing_info.Remove(self)
								return drawing_info:Remove()
							end
						end
						return drawing_info[index]
					end,
				})
			elseif drawing_type == "Square" then
				local drawing_info = (
					{
						Size = Vector2.zero,
						Position = Vector2.zero,
						Thickness = 0.7,
						Filled = false,
					} + base_drawing_obj
				)
	
				local squareFrame, uiStroke = Instance.new("Frame"), Instance.new("UIStroke")
				squareFrame.Name = drawing_idx
				squareFrame.BorderSizePixel = 0
	
				squareFrame.BackgroundTransparency = (
					if drawing_info.Filled then convert_dtransparency(drawing_info.Transparency) else 1
				)
				squareFrame.ZIndex = drawing_info.ZIndex
				squareFrame.BackgroundColor3 = drawing_info.Color
				squareFrame.Visible = drawing_info.Visible
	
				uiStroke.Thickness = drawing_info.Thickness
				uiStroke.Enabled = not drawing_info.Filled
				uiStroke.LineJoinMode = Enum.LineJoinMode.Miter
	
				squareFrame.Parent, uiStroke.Parent = drawing_container, squareFrame
				return setmetatable(drawing_obj, {
					__newindex = function(_, index, value)
						if type(drawing_info[index]) == "nil" then
							return
						end
	
						if index == "Size" then
							squareFrame.Size = UDim2.fromOffset(value.X, value.Y)
						elseif index == "Position" then
							squareFrame.Position = UDim2.fromOffset(value.X, value.Y)
						elseif index == "Thickness" then
							value = math.clamp(value, 0.6, 0x7fffffff)
							uiStroke.Thickness = value
						elseif index == "Filled" then
							squareFrame.BackgroundTransparency = (
								if value then convert_dtransparency(drawing_info.Transparency) else 1
							)
							uiStroke.Enabled = not value
						elseif index == "Visible" then
							squareFrame.Visible = value
						elseif index == "ZIndex" then
							squareFrame.ZIndex = value
						elseif index == "Transparency" then
							local transparency = convert_dtransparency(value)
	
							squareFrame.BackgroundTransparency = (if drawing_info.Filled then transparency else 1)
							uiStroke.Transparency = transparency
						elseif index == "Color" then
							uiStroke.Color = value
							squareFrame.BackgroundColor3 = value
						end
						drawing_info[index] = value
					end,
					__index = function(self, index)
						if index == "Remove" or index == "Destroy" then
							return function()
								squareFrame:Destroy()
								drawing_info.Remove(self)
								return drawing_info:Remove()
							end
						end
						return drawing_info[index]
					end,
				})
			elseif drawing_type == "Image" then
				local drawing_info = (
					{
						Data = "",
						DataURL = "rbxassetid://0",
						Size = Vector2.zero,
						Position = Vector2.zero,
					} + base_drawing_obj
				)
	
				local imageFrame = Instance.new("ImageLabel")
				imageFrame.Name = drawing_idx
				imageFrame.BorderSizePixel = 0
				imageFrame.ScaleType = Enum.ScaleType.Stretch
				imageFrame.BackgroundTransparency = 1
	
				imageFrame.Visible = drawing_info.Visible
				imageFrame.ZIndex = drawing_info.ZIndex
				imageFrame.ImageTransparency = convert_dtransparency(drawing_info.Transparency)
				imageFrame.ImageColor3 = drawing_info.Color
	
				imageFrame.Parent = drawing_container
				return setmetatable(drawing_obj, {
					__newindex = function(_, index, value)
						if type(drawing_info[index]) == "nil" then
							return
						end
	
						if index == "DataURL" then -- temporary property
							imageFrame.Image = value
						elseif index == "Size" then
							imageFrame.Size = UDim2.fromOffset(value.X, value.Y)
						elseif index == "Position" then
							imageFrame.Position = UDim2.fromOffset(value.X, value.Y)
						elseif index == "Visible" then
							imageFrame.Visible = value
						elseif index == "ZIndex" then
							imageFrame.ZIndex = value
						elseif index == "Transparency" then
							imageFrame.ImageTransparency = convert_dtransparency(value)
						elseif index == "Color" then
							imageFrame.ImageColor3 = value
						end
						drawing_info[index] = value
					end,
					__index = function(self, index)
						if index == "Remove" or index == "Destroy" then
							return function()
								imageFrame:Destroy()
								drawing_info.Remove(self)
								return drawing_info:Remove()
							end
						end
						return drawing_info[index]
					end,
				})
			elseif drawing_type == "Quad" then
				local drawing_info = (
					{
						PointA = Vector2.zero,
						PointB = Vector2.zero,
						PointC = Vector2.zero,
						PointD = Vector2.zero,
						Thickness = 1,
						Filled = false,
					} + base_drawing_obj
				)
	
				local line_points = {}
				line_points.A = drawing_lib.new("Line")
				line_points.B = drawing_lib.new("Line")
				line_points.C = drawing_lib.new("Line")
				line_points.D = drawing_lib.new("Line")
	
				local construct_tri1, remove_tri1, wedges1 = new_2d_triangle(drawing_container)
				local construct_tri2, remove_tri2, wedges2 = new_2d_triangle(drawing_container)
	
				construct_tri1(drawing_info.PointA, drawing_info.PointB, drawing_info.PointC)
				construct_tri2(drawing_info.PointA, drawing_info.PointC, drawing_info.PointD)
				wedges1.w1.Visible = drawing_info.Filled
				wedges1.w2.Visible = drawing_info.Filled
				wedges2.w1.Visible = drawing_info.Filled
				wedges2.w2.Visible = drawing_info.Filled
	
				return setmetatable(drawing_obj, {
					__newindex = function(_, index, value)
						if type(drawing_info[index]) == "nil" then
							return
						end
	
						if index == "PointA" then
							line_points.A.From = value
							line_points.B.To = value
							construct_tri1(value, drawing_info.PointB, drawing_info.PointC)
							construct_tri2(value, drawing_info.PointC, drawing_info.PointD)
						elseif index == "PointB" then
							line_points.B.From = value
							line_points.C.To = value
							construct_tri1(drawing_info.PointA, value, drawing_info.PointC)
						elseif index == "PointC" then
							line_points.C.From = value
							line_points.D.To = value
							construct_tri1(drawing_info.PointA, drawing_info.PointB, value)
							construct_tri2(drawing_info.PointA, value, drawing_info.PointD)
						elseif index == "PointD" then
							line_points.D.From = value
							line_points.A.To = value
							construct_tri2(drawing_info.PointA, drawing_info.PointC, value)
						elseif
							index == "Thickness"
							or index == "Visible"
							or index == "Color"
							or index == "Transparency"
							or index == "ZIndex"
						then
							for _, line_obj in line_points do
								line_obj[index] = value
							end
	
							if index == "Visible" then
								wedges1.w1.Visible = (drawing_info.Filled and value)
								wedges1.w2.Visible = (drawing_info.Filled and value)
								wedges2.w1.Visible = (drawing_info.Filled and value)
								wedges2.w2.Visible = (drawing_info.Filled and value)
							elseif index == "ZIndex" then
								wedges1.w1.ZIndex = value
								wedges1.w2.ZIndex = value
								wedges2.w1.ZIndex = value
								wedges2.w2.ZIndex = value
							elseif index == "Color" then
								wedges1.w1.ImageColor3 = value
								wedges1.w2.ImageColor3 = value
								wedges2.w1.ImageColor3 = value
								wedges2.w2.ImageColor3 = value
							elseif index == "Transparency" then
								wedges1.w1.ImageTransparency = convert_dtransparency(value)
								wedges1.w2.ImageTransparency = convert_dtransparency(value)
								wedges2.w1.ImageTransparency = convert_dtransparency(value)
								wedges2.w2.ImageTransparency = convert_dtransparency(value)
							end
						elseif index == "Filled" then
							wedges1.w1.Visible = (drawing_info.Visible and value)
							wedges1.w2.Visible = (drawing_info.Visible and value)
							wedges2.w1.Visible = (drawing_info.Visible and value)
							wedges2.w2.Visible = (drawing_info.Visible and value)
						end
						drawing_info[index] = value
					end,
					__index = function(self, index)
						if index == "Remove" or index == "Destroy" then
							return function()
								for _, line_obj in line_points do
									line_obj:Remove()
								end
	
								remove_tri1()
								remove_tri2()
								drawing_info.Remove(self)
								return drawing_info:Remove()
							end
						end
						return drawing_info[index]
					end,
				})
			elseif drawing_type == "Triangle" then
				local drawing_info = (
					{
						PointA = Vector2.zero,
						PointB = Vector2.zero,
						PointC = Vector2.zero,
						Thickness = 1,
						Filled = false,
					} + base_drawing_obj
				)
	
				local line_points = {}
				line_points.A = drawing_lib.new("Line")
				line_points.B = drawing_lib.new("Line")
				line_points.C = drawing_lib.new("Line")
	
				local construct_tri1, remove_tri1, wedges1 = new_2d_triangle(drawing_container)
	
				construct_tri1(drawing_info.PointA, drawing_info.PointB, drawing_info.PointC)
				wedges1.w1.Visible = drawing_info.Filled
				wedges1.w2.Visible = drawing_info.Filled
	
				return setmetatable(drawing_obj, {
					__newindex = function(_, index, value)
						if type(drawing_info[index]) == "nil" then
							return
						end
	
						if index == "PointA" then
							line_points.A.From = value
							line_points.B.To = value
							construct_tri1(value, drawing_info.PointB, drawing_info.PointC)
						elseif index == "PointB" then
							line_points.B.From = value
							line_points.C.To = value
							construct_tri1(drawing_info.PointA, value, drawing_info.PointC)
						elseif index == "PointC" then
							line_points.C.From = value
							line_points.A.To = value
							construct_tri1(drawing_info.PointA, drawing_info.PointB, value)
						elseif
							index == "Thickness"
							or index == "Visible"
							or index == "Color"
							or index == "Transparency"
							or index == "ZIndex"
						then
							for _, line_obj in line_points do
								line_obj[index] = value
							end
	
							if index == "Visible" then
								wedges1.w1.Visible = (drawing_info.Filled and value)
								wedges1.w2.Visible = (drawing_info.Filled and value)
							elseif index == "ZIndex" then
								wedges1.w1.ZIndex = value
								wedges1.w2.ZIndex = value
							elseif index == "Color" then
								wedges1.w1.ImageColor3 = value
								wedges1.w2.ImageColor3 = value
							elseif index == "Transparency" then
								wedges1.w1.ImageTransparency = convert_dtransparency(value)
								wedges1.w2.ImageTransparency = convert_dtransparency(value)
							end
						elseif index == "Filled" then
							wedges1.w1.Visible = (drawing_info.Visible and value)
							wedges1.w2.Visible = (drawing_info.Visible and value)
						end
						drawing_info[index] = value
					end,
					__index = function(self, index)
						if index == "Remove" or index == "Destroy" then
							return function()
								for _, line_obj in line_points do
									line_obj:Remove()
								end
	
								remove_tri1()
								drawing_info.Remove(self)
								return drawing_info:Remove()
							end
						end
						return drawing_info[index]
					end,
				})
			end
			return error(`Drawing object "{drawing_type}" doesn't exist`, 2)
		end
	
		function drawing_lib.new(...)
			local drawing_obj = new(...)
			table.insert(drawing_obj_reg, drawing_obj)
			return drawing_obj
		end
	end
	-- * misc drawing funcs
	
	local function clearDrawCache()
		drawing_container:ClearAllChildren()
		for _, drawing_obj in drawing_obj_reg do
			if not drawing_obj then
				continue
			end
			drawing_obj:Remove()
		end
		table.clear(drawing_obj_reg)
	end
	
	local function isRenderObject(object): boolean
		local objPos = table.find(drawing_obj_reg, object)
	
		return (if objPos then (type(drawing_obj_reg[objPos]) == "table") else false)
	end
	
	local function getRenderProperty(object, property: string): any
		local objPos = table.find(drawing_obj_reg, object)
		if not objPos then
			return error(`arg #1 not a valid render object`)
		end
	
		return object[property]
	end
	
	local function setRenderProperty(object, property: string, value: any)
		local objPos = table.find(drawing_obj_reg, object)
		if not objPos then
			return error(`arg #1 not a valid render object`)
		end
	
		if type(object[property]) == "nil" then
			return error(`'{property}' is not a valid render property`)
		end
	
		object[property] = value
	end
	
	drawing_container.Parent = gethui()
	Drawing = drawing_lib
	Drawing.clear = clearDrawCache
	cleardrawcache = clearDrawCache
	isrenderobj = isRenderObject
	getrenderproperty = getRenderProperty
	setrenderproperty = setRenderProperty
	
	local UserInputService = game:GetService("UserInputService")
	local VirtualInputManager = Instance.new("VirtualInputManager")
	
	input, alias =
		{}, {
			["isrbxactive"] = { "isgameactive", "iswindowactive" },
			["keyclick"] = { "hitkey" },
		}
	
	do -- IsFocused
		local window_focused = true -- TODO Find a better way instead of Assuming (Maybe we could force focus)
	
		UserInputService.WindowFocusReleased:Connect(function()
			window_focused = false
		end)
		UserInputService.WindowFocused:Connect(function()
			window_focused = true
		end)
	
		function isrbxactive()
			return window_focused
		end
	end
	
	isgameactive = isrbxactive
	iswindowactive = isrbxactive
	
	-- QuotedDouble Hash Dollar Percent Ampersand LeftParenthesis RightParenthesis Asterisk Underscore Tilde Colon Plus Pipe LessThan GreaterThan Question At Caret LeftCurly RightCurly are all deprecated
	
	-- basic virtual key code -> roblox KeyCode map (for backwards compatibility)
	-- https://docs.microsoft.com/en-us/windows/desktop/inputdev/virtual-key-codes
	-- https://developer.roblox.com/api-reference/enum/KeyCode
	
	--[[ --TODO Map these to mouse functions?
	
	VK_LBUTTON 	0x01 	Left mouse button
	VK_RBUTTON 	0x02 	Right mouse button
	
	VK_MBUTTON 	0x04 	Middle mouse button
	VK_XBUTTON1 	0x05 	X1 mouse button
	VK_XBUTTON2 	0x06 	X2 mouse button
	
	]]
	
	local map = {
		-- [0x03] = Enum.KeyCode.LeftControl + Enum.KeyCode.Break
	
		[0x10] = Enum.KeyCode.LeftShift, -- Ambiguation Shift
		[0x11] = Enum.KeyCode.LeftControl, -- Ambiguation Ctrl
		[0x12] = Enum.KeyCode.LeftAlt, -- Ambiguation Alt
	
		-- TODO These need to only appear once (it will be a problem if we move some keycode from beginning to end, currently we only need to do the opposite luckily)
		[0x14] = Enum.KeyCode.CapsLock,
	
		[0x1F] = Enum.KeyCode.Mode,
	
		[0x21] = Enum.KeyCode.PageUp,
		[0x22] = Enum.KeyCode.PageDown,
		[0x23] = Enum.KeyCode.End,
		[0x24] = Enum.KeyCode.Home,
		[0x25] = Enum.KeyCode.Left,
		[0x26] = Enum.KeyCode.Up,
		[0x27] = Enum.KeyCode.Right,
		[0x28] = Enum.KeyCode.Down,
		[0x29] = false,
		[0x2A] = Enum.KeyCode.Print, -- Not sure
		[0x2B] = false,
		[0x2C] = Enum.KeyCode.Print,
		[0x2D] = Enum.KeyCode.Insert,
		[0x2E] = Enum.KeyCode.Delete,
		[0x2F] = Enum.KeyCode.Help,
	
		[0x5B] = Enum.KeyCode.LeftSuper,
		[0x5C] = Enum.KeyCode.RightSuper,
		[0x5D] = Enum.KeyCode.Menu, -- Not sure
		[0x5E] = false,
		[0x5F] = false,
	
		[0x6A] = Enum.KeyCode.KeypadMultiply,
		[0x6B] = Enum.KeyCode.KeypadPlus,
		[0x6C] = false,
		[0x6D] = Enum.KeyCode.KeypadMinus,
		[0x6E] = Enum.KeyCode.KeypadPeriod,
		[0x6F] = Enum.KeyCode.KeypadDivide,
	
		[0x7F] = false,
	
		[0x90] = Enum.KeyCode.NumLock,
		[0x91] = Enum.KeyCode.ScrollLock,
	
		[0xA0] = Enum.KeyCode.LeftShift,
		[0xA1] = Enum.KeyCode.RightShift,
		[0xA2] = Enum.KeyCode.LeftControl,
		[0xA3] = Enum.KeyCode.RightControl,
		[0xA4] = Enum.KeyCode.LeftAlt,
		[0xA5] = Enum.KeyCode.RightAlt,
	
		[0xBA] = Enum.KeyCode.Semicolon,
		[0xBB] = Enum.KeyCode.Plus,
		[0xBC] = Enum.KeyCode.Comma,
		[0xBD] = Enum.KeyCode.Minus,
		[0xBE] = Enum.KeyCode.Period,
		[0xBF] = Enum.KeyCode.Slash,
	
		[0xC0] = Enum.KeyCode.Backquote,
	
		[0xDB] = Enum.KeyCode.LeftBracket,
		[0xDC] = Enum.KeyCode.BackSlash,
		[0xDD] = Enum.KeyCode.RightBracket,
		[0xDE] = Enum.KeyCode.Quote,
	
		[0xE2] = Enum.KeyCode.LessThan,
	
		[0xFE] = Enum.KeyCode.Clear, -- Not sure
	}
	do -- Map Virtual Keys to KeyCode Enum
		local function virtual_to_keycode(value)
			for i, v in Enum.KeyCode:GetEnumItems() do
				if v.Value == value then
					return v
				end
			end
		end
		-- Re-Map
		for i = 0, 25 do
			map[i + 0x41] = virtual_to_keycode(i + 97)
		end -- A-Z
		for i = 0, 9 do
			map[i + 0x60] = virtual_to_keycode(i + 256)
		end -- Keypad 0-9
		for i = 0, 14 do
			map[i + 0x70] = virtual_to_keycode(i + 282)
		end -- Function 1-15
	
		for i, v in Enum.KeyCode:GetEnumItems() do -- ? Maybe blacklist Enum's containing "World" in the name
			local Override = map[v.Value]
	
			if Override == nil then
				if string.find(v.Name, "World", nil, true) then
					continue
				end
				map[v.Value] = v
			elseif Override == false then
				map[v.Value] = nil
			end
		end
	end
	
	do -- Keyboard
		local function get_keycode(key)
			local Type = typeof(key)
			if Type ~= "EnumItem" then
				if Type == "string" then
					key = tonumber(key)
				end
				key = map[key]
				assert(key, "Unable to map key to Enum.KeyCode. Use a Enum.KeyCode instead") -- ? We could also return Unknown keycode instead of this
			end
			return key
		end
	
		function keypress(key, isRepeatedKey)
			VirtualInputManager:SendKeyEvent(true, get_keycode(key), isRepeatedKey or false, nil)
		end
	
		function keyrelease(key, isRepeatedKey)
			VirtualInputManager:SendKeyEvent(false, get_keycode(key), isRepeatedKey or false, nil)
		end
	
		function keyclick(...)
			input.keypress(...)
			input.keyrelease(...)
		end
	end
	
	
	
	local Input = {
		KeyPress = keyclick,
		KeyDown = keypress,
		KeyUp = keyrelease,
	}
	
	hitkey = keyclick
	
	do -- Mouse
		-- VirtualInputManager is typed to disallow a nil window, but it does not
		-- throw errors and tests rely on it `nil` being allowed
		local function mouse_generalized(mouseButton, isDown)
			return function(x, y, repeatCount)
				VirtualInputManager:SendMouseButtonEvent(
					x or UserInputService:GetMouseLocation().X,
					y or UserInputService:GetMouseLocation().Y,
					mouseButton,
					isDown,
					nil,
					repeatCount or 0
				)
			end
		end
	
		local mouse_map = { "LeftClick", "RightClick", "MiddleClick" }
	
		for i = 0, 2 do
			local lua_index = i + 1
			local base_name = "mouse" .. lua_index
			local press, release = mouse_generalized(i, true), mouse_generalized(i, false)
	
			local function click(...)
				press(...)
				release(...)
			end
	
			local up_name, down_name = base_name .. "press", base_name .. "release"
			input[up_name] = press
			input[down_name] = release
			input[base_name .. "click"] = click
	
			Input[mouse_map[lua_index]] = function(action)
				if 1 == action then
					press()
				elseif 2 == action then
					release()
				else
					click()
				end
			end
	
			alias[up_name] = { base_name .. "up" }
			alias[down_name] = { base_name .. "down" }
		end
	
		function mousemoveabs(x, y)
			VirtualInputManager:SendMouseMoveEvent(
				x or UserInputService:GetMouseLocation().X,
				y or UserInputService:GetMouseLocation().Y,
				nil
			)
		end
	
		function mousemoverel(x, y)
			-- x,y need to be specified here or we need a fallback (0)
			mousemoveabs(
				x and UserInputService:GetMouseLocation().X + x,
				y and UserInputService:GetMouseLocation().Y + y
			)
		end
	
		function mousescroll(pixels, x, y)
			if type(pixels) == "boolean" then
				pixels = pixels and 120 or -120
			end
	
			local isForwardScroll = pixels >= 0 -- input.Position.Z is 1 when forward, -1 otherwise
	
			for i = 1, math.abs(pixels // 120) do
				VirtualInputManager:SendMouseWheelEvent(
					x or UserInputService:GetMouseLocation().X,
					y or UserInputService:GetMouseLocation().Y,
					isForwardScroll,
					nil
				)
				VirtualInputManager:WaitForInputEventsProcessed()
			end
		end
	end
	
	--
	
	
	function readfile(file)
		data = bridge:send("readfile", {arg="file", value=file})
		if data == nil then
			return ""
		end
		if not data.status then
			error(data.content)
		end
		return data.content
	end
	
	function listfiles(file)
		data = bridge:send("listfiles", {arg="file", value=file})
		if data == nil then
			return {}
		end
		if typeof(data.content)  == "table" then
			return data.content
		else
			return {}
		end
	end
	
	function isfile(path)
		data = bridge:post("isfile", {type="isfile",filename=path})
		if data == nil then
			return false
		end
		return data.status
	end
	
	function getcustomasset(assetName)
		data = bridge:post("getcustomasset", {type="getcustomasset",filename=assetName})
		if data == nil then
			return false
		end
		return data.content
	end

	delfolder = function(path)
		data = bridge:post("delfolder", {type="delfolder",filename=path})
	end
	
	function delfile(path)
		data = bridge:post("delfile", {type="delfile",filename=path})
		if data == nil then
			return false
		end
		return data.status
	end
	
	function gethwid()
		data = bridge:send("gethwid", {arg="gethwid", value="1"})
		if data == nil then
			return ""
		end
		return data.content
	end
	
	function writefile(file, data)
		data = bridge:post("writefile", {source=data,type="writefile",filename=file})
		if data == nil then
			return false
		end
		return data.status
	end
	
	--
	
	function lrm_load_script(script_id)
		local code = [[
	
	ce_like_loadstring_fn = loadstring;
	loadstring = nil;
	
	]] .. game:HttpGet("https://api.luarmor.net/files/v3/l/" .. script_id .. ".lua")
		return loadstring(code)({ Origin = "NX" })
	end
	
	function makefolder(file)
		data = bridge:send("makefolder", {arg="file", value=file})
		if data == nil then
			return false
		end
		return data.status
	end
	
	function appendfile(path, data)
		data = bridge:post("appendfile", {source=data,type="appendfile",filename=path})
		if data == nil then
			return false
		end
		return data.status
	end
	
	function isfolder(path)
		data = bridge:send("isfolder", {arg="file", value=path})
		if data == nil then
			return false
		end
		return data.status
	end
	
	function getexecutioncontext()
		local RunService = game:GetService("RunService")
		return if RunService:IsClient()
			then "Client"
			elseif RunService:IsServer() then "Server"
			else if RunService:IsStudio() then "Studio" else "Unknown"
	end

	local getscript = Instance.new("ObjectValue")

	getscript.Name = "getbytecodeobject"
	getscript.Parent = game.CoreGui

	function getscriptbytecode(instance)
		assert(typeof(instance) == "Instance" and instance:IsA("LuaSourceContainer"), `arg #1 must be LuaSourceContainer`)
	
		getscript.Value = instance
	
		data = bridge:send("getscriptbytecode", {arg="getscriptbytecode", value="wow"})
		if data == nil then
			return ""
		end
		return data.content
	end

	dumpstring = getscriptbytecode
	
	function getscripthash(instance)
		assert(typeof(instance) == "Instance" and instance:IsA("LuaSourceContainer"), `arg #1 must be LuaSourceContainer`)
	
		return if instance:IsA("Script") then instance:GetHash() else instance:GetDebugId(0)
	end
	
	-- main
	
	if game.Players.LocalPlayer then
		bridge:send("gameentered", {arg="name", value=game.Players.LocalPlayer.Name})
	end
	
	--------------------------------------------------------------------------------
	--               Batched Yield-Safe Signal Implementation                     --
	-- This is a Signal class which has effectively identical behavior to a       --
	-- normal RBXScriptSignal, with the only difference being a couple extra      --
	-- stack frames at the bottom of the stack trace when an error is thrown.     --
	-- This implementation caches runner coroutines, so the ability to yield in   --
	-- the signal handlers comes at minimal extra cost over a naive signal        --
	-- implementation that either always or never spawns a thread.                --
	--                                                                            --
	-- API:                                                                       --
	--   local Signal = require(THIS MODULE)                                      --
	--   local sig = Signal.new()                                                 --
	--   local connection = sig:Connect(function(arg1, arg2, ...) ... end)        --
	--   sig:Fire(arg1, arg2, ...)                                                --
	--   connection:Disconnect()                                                  --
	--   sig:DisconnectAll()                                                      --
	--   local arg1, arg2, ... = sig:Wait()                                       --
	--                                                                            --
	-- Licence:                                                                   --
	--   Licenced under the MIT licence.                                          --
	--                                                                            --
	-- Authors:                                                                   --
	--   stravant - July 31st, 2021 - Created the file.                           --
	--------------------------------------------------------------------------------
	
	-- The currently idle thread to run the next handler on
	local freeRunnerThread = nil
	
	-- Function which acquires the currently idle handler runner thread, runs the
	-- function fn on it, and then releases the thread, returning it to being the
	-- currently idle one.
	-- If there was a currently idle runner thread already, that's okay, that old
	-- one will just get thrown and eventually GCed.
	local function acquireRunnerThreadAndCallEventHandler(fn, ...)
		local acquiredRunnerThread = freeRunnerThread
		freeRunnerThread = nil
		fn(...)
		-- The handler finished running, this runner thread is free again.
		freeRunnerThread = acquiredRunnerThread
	end
	
	-- Coroutine runner that we create coroutines of. The coroutine can be 
	-- repeatedly resumed with functions to run followed by the argument to run
	-- them with.
	local function runEventHandlerInFreeThread()
		-- Note: We cannot use the initial set of arguments passed to
		-- runEventHandlerInFreeThread for a call to the handler, because those
		-- arguments would stay on the stack for the duration of the thread's
		-- existence, temporarily leaking references. Without access to raw bytecode
		-- there's no way for us to clear the "..." references from the stack.
		while true do
			acquireRunnerThreadAndCallEventHandler(coroutine.yield())
		end
	end
	
	-- Connection class
	local Connection = {}
	Connection.__index = Connection
	
	function Connection.new(signal, fn)
		return setmetatable({
			_connected = true,
			_signal = signal,
			_fn = fn,
			_next = false,
		}, Connection)
	end
	
	function Connection:Disconnect()
		self._connected = false
	
		-- Unhook the node, but DON'T clear it. That way any fire calls that are
		-- currently sitting on this node will be able to iterate forwards off of
		-- it, but any subsequent fire calls will not hit it, and it will be GCed
		-- when no more fire calls are sitting on it.
		if self._signal._handlerListHead == self then
			self._signal._handlerListHead = self._next
		else
			local prev = self._signal._handlerListHead
			while prev and prev._next ~= self do
				prev = prev._next
			end
			if prev then
				prev._next = self._next
			end
		end
	end
	
	-- Make Connection strict
	setmetatable(Connection, {
		__index = function(tb, key)
			error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(key)), 2)
		end,
		__newindex = function(tb, key, value)
			error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(key)), 2)
		end
	})
	
	-- Signal class
	local Signal = {}
	Signal.__index = Signal
	
	function Signal.new()
		return setmetatable({
			_handlerListHead = false,
		}, Signal)
	end
	
	function Signal:Connect(fn)
		local connection = Connection.new(self, fn)
		if self._handlerListHead then
			connection._next = self._handlerListHead
			self._handlerListHead = connection
		else
			self._handlerListHead = connection
		end
		return connection
	end
	
	-- Disconnect all handlers. Since we use a linked list it suffices to clear the
	-- reference to the head handler.
	function Signal:DisconnectAll()
		self._handlerListHead = false
	end
	
	-- Signal:Fire(...) implemented by running the handler functions on the
	-- coRunnerThread, and any time the resulting thread yielded without returning
	-- to us, that means that it yielded to the Roblox scheduler and has been taken
	-- over by Roblox scheduling, meaning we have to make a new coroutine runner.
	function Signal:Fire(...)
		local item = self._handlerListHead
		while item do
			if item._connected then
				if not freeRunnerThread then
					freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
					-- Get the freeRunnerThread to the first yield
					coroutine.resume(freeRunnerThread)
				end
				task.spawn(freeRunnerThread, item._fn, ...)
			end
			item = item._next
		end
	end
	
	-- Implement Signal:Wait() in terms of a temporary connection using
	-- a Signal:Connect() which disconnects itself.
	function Signal:Wait()
		local waitingCoroutine = coroutine.running()
		local cn;
		cn = self:Connect(function(...)
			cn:Disconnect()
			task.spawn(waitingCoroutine, ...)
		end)
		return coroutine.yield()
	end
	
	-- Implement Signal:Once() in terms of a connection which disconnects
	-- itself before running the handler.
	function Signal:Once(fn)
		local cn;
		cn = self:Connect(function(...)
			if cn._connected then
				cn:Disconnect()
			end
			fn(...)
		end)
		return cn
	end
	
	-- Make signal strict
	setmetatable(Signal, {
		__index = function(tb, key)
			error(("Attempt to get Signal::%s (not a valid member)"):format(tostring(key)), 2)
		end,
		__newindex = function(tb, key, value)
			error(("Attempt to set Signal::%s (not a valid member)"):format(tostring(key)), 2)
		end
	})
	
	goodsignal = Signal
	
	do -- Websockets
		WebSocket = { connect = nil }
	
		local websocket_mt = {
			__index = function(self, index)
				if not rawget(self, "__OBJECT_ACTIVE") then
					error("WebSocket is closed.")
				end
	
				if index == "OnMessage" then
					if not rawget(self, "__OBJECT_ACTIVE") then
						error("WebSocket is closed.")
					end
	
					return rawget(self, "__OBJECT_MESSAGE")
				end
	
				if index == "OnClose" then
					if not rawget(self, "__OBJECT_ACTIVE") then
						error("WebSocket is closed.")
					end
	
					return rawget(self, "__OBJECT_CLOSE")
				end
	
				if index == "Send" then
					return function(_, message, is_binary)
						if not rawget(self, "__OBJECT_ACTIVE") then
							error("WebSocket is closed.")
						end
						bridge:post("websocketsend", {type="websocketsend",websocket={
							url=rawget(self, "__OBJECT"),
							message=message,
							binary=is_binary,
							closure=false
						}})
					end
				end
	
				if index == "Close" then
					return function(_)
						if not rawget(self, "__OBJECT_ACTIVE") then
							error("WebSocket is closed.")
						end
						rawset(self, "__OBJECT_ACTIVE", false)
						bridge:post("websocketclose", {type="websocketclose",websocket={
							url=rawget(self, "__OBJECT"),
							closure=true
						}})
					end
				end
			end,
			__newindex = function()
				error("WebSocket is readonly.")
			end,
			__type = "WebSocket",
		}
	
		function WebSocket.connect(url: string)
	
			local data = bridge:post("websocket", {type="websocket",websocket={
				url=url,
				message=message,
				binary=is_binary,
				closure=false
			}})
			
			local success = data.status
			if not success then
				error(data.content, 2)
			end
	
			local websocket_connection = setmetatable({
				ClassName = "WebSocket",
				__OBJECT = url,
				__OBJECT_ACTIVE = true,
				__OBJECT_MESSAGE = goodsignal.new(),
				__OBJECT_CLOSE = goodsignal.new(),
			}, websocket_mt)
	
			websocket_connection.__OBJECT_CLOSE:Connect(function()
				websocket_connection.__OBJECT_ACTIVE = false
			end)
	
			game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(teleportState)
				if teleportState == Enum.TeleportState.Started and websocket_connection.__OBJECT_ACTIVE then
					websocket_connection:Close()
				end
			end)
	
			coroutine.wrap(function()
				while true do
					task.wait(0.100)
					if websocket_connection.__OBJECT_ACTIVE == false then
						break
					end
					local resp = game:HttpGet("http://localhost:3000/bridge?action=".. url .. "_message")
					if resp then
						local data = HttpService:JSONDecode(resp)
						if data.status == true then
							for _, value in data.content do
								websocket_connection.__OBJECT_MESSAGE:Fire(value)
							end
						end
					else
						break
					end
				end
			end)()
	
			coroutine.wrap(function()
				while true do
					task.wait(0.100)
					if websocket_connection.__OBJECT_ACTIVE == false then
						break
					end
					local resp = game:HttpGet("http://localhost:3000/bridge?action=".. url .. "_close")
					if resp then
						local data = HttpService:JSONDecode(resp)
						if data.status == true then
							websocket_connection.__OBJECT_CLOSE:Fire("")
							break
						end
					else
						websocket_connection.__OBJECT_CLOSE:Fire("")
						break
					end
				end
			end)()
			return websocket_connection
		end
	end
	
	http.request = request
	http_request = request

	--[[
	sha384 = sha.sha384
	base64encode = crypt.base64encode
	
	local disassemble = loadstring(game:HttpGet("https://raw.githubusercontent.com/suffz/luna/refs/heads/main/decompile.luau"))()
	decompile = function(a1) 
		return disassemble(a1)
	end
	
	local Params = {
		RepoURL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/",
		SSI = "saveinstance",
	}
	local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
	
	saveinstance = function(Options)
		return synsaveinstance(Options)
	end
	savegame = function()
		return synsaveinstance(game)
	end
	]]

	getconnections = function() return {} end
	
	hookmetamethod = (function(self, method, func)
		local o = t
		local mt = debug.getmetatable(t)
		mt[index] = func
		t = mt
		return o
	end)

	getcallbackvalue = (function(bindable, oninvoke)
        return function(text, ...)
            return bindable:Invoke(text, ...)
        end
	end)

	loadfile = (function(filename)
		return loadstring(readfile(filename))
	end)

	function getthreadidentity()
		data = bridge:send("getthreadidentity", {arg="identity", value="1"})
		if data == nil then
			return false
		end
		return data.content
	end

	getidentity = getthreadidentity
	getthreadcontext = getthreadidentity

	function checkcaller()
		return 3 <= getthreadidentity()
	end

	function setthreadidentity(identity)
		data = bridge:send("setthreadidentity", {arg="identity", value=identity})
		if data == nil then
			return false
		end
		return data.status
	end

	setidentity = setthreadidentity

	local last_call = 0
	local function konst_call(konstantType: string, scriptPath: Script | ModuleScript | LocalScript): string
		local success: boolean, bytecode: string = pcall(getscriptbytecode, scriptPath)

		if (not success) then
			return `-- Failed to get script bytecode, error:\n\n--[[\n{bytecode}\n--]]`
		end

		local time_elapsed = os.clock() - last_call
		if time_elapsed <= .5 then
			task.wait(.5 - time_elapsed)
		end
		local httpResult = request({
			Url = "http://api.plusgiant5.com" .. konstantType,
			Body = bytecode,
			Method = "POST",
			Headers = {
				["Content-Type"] = "text/plain"
			},
		})
		last_call = os.clock()

		if (httpResult.StatusCode ~= 200) then
			return `-- Error occured while requesting the API, error:\n\n--[[\n{httpResult.Body}\n--]]`
		else
			return httpResult.Body
		end
	end

	function Decompile(script_instance)
		if typeof(script_instance) ~= "Instance" then
			return "-- invalid argument #1 to 'Decompile' (Instance expected, got " .. typeof(script_instance) .. ")"
		end
		if script_instance.ClassName ~= "LocalScript" and script_instance.ClassName ~= "ModuleScript" then
			return "-- Only LocalScript and ModuleScript is supported but got \"" .. script_instance.ClassName .. "\""
		end
		return tostring(konst_call("/konstant/decompile", script_instance)):gsub("\t", "    ")
	end
	decompile = decompile

	function __Disassemble(script_instance)
		if typeof(script_instance) ~= "Instance" then
			return "-- invalid argument #1 to 'disassemble' (Instance expected, got " .. typeof(script_instance) .. ")"
		end
		if script_instance.ClassName ~= "LocalScript" and script_instance.ClassName ~= "ModuleScript" then
			return "-- Only LocalScript and ModuleScript is supported but got \"" .. script_instance.ClassName .. "\""
		end
		return tostring(konst_call("/konstant/disassemble", script_instance)):gsub("\t", "    ")
	end
	__disassemble = __Disassemble

	bridge:post("joinedgame", {source=game.PlaceId,type="joinedgame"})
end)

wait()

if script.Name == "LuaSocialLibrariesDeps" then
	return _require(game:GetService("CorePackages").Workspace.Packages.LuaSocialLibrariesDeps)
end

if script.Name == "JestGlobals" then
	return _require(script)
end
if script.Name == "Url" then
	local a={}
	local b=game:GetService("ContentProvider")
	local function c(d)
		local e,f=d:find("%.")
		local g=d:sub(f+1)
		if g:sub(-1)~="/"then
			g=g.."/"
		end;
		return g
	end;
	local d=b.BaseUrl
	local g=c(d)
	local h=string.format("https://games.%s",g)
	local i=string.format("https://apis.rcs.%s",g)
	local j=string.format("https://apis.%s",g)
	local k=string.format("https://accountsettings.%s",g)
	local l=string.format("https://gameinternationalization.%s",g)
	local m=string.format("https://locale.%s",g)
	local n=string.format("https://users.%s",g)
	local o={GAME_URL=h,RCS_URL=i,APIS_URL=j,ACCOUNT_SETTINGS_URL=k,GAME_INTERNATIONALIZATION_URL=l,LOCALE_URL=m,ROLES_URL=n}setmetatable(a,{__newindex=function(p,q,r)end,__index=function(p,r)return o[r]end})
	return a
end

while wait(9e9) do 
	wait(9e9)
end
