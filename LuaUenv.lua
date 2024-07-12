task.spawn(function()
	repeat task.wait(0.5) until game:IsLoaded()
	task.wait(2)
	local solaramode = false
	local NotifLib = Instance.new("ScreenGui")
	local Center = Instance.new("Frame")
	local Holder = Instance.new("Frame")
	local Template = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local Main = Instance.new("TextLabel")
	local Secondary = Instance.new("TextLabel")
	local Y = Instance.new("TextButton")
	local UICorner_2 = Instance.new("UICorner")
	local N = Instance.new("TextButton")
	local UICorner_3 = Instance.new("UICorner")
	local UIListLayout = Instance.new("UIListLayout")

	NotifLib.Name = "NotifLib"
	NotifLib.Parent = game:GetService("CoreGui")
	NotifLib.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Center.Name = "Center"
	Center.Parent = NotifLib
	Center.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Center.BackgroundTransparency = 1
	Center.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Center.BorderSizePixel = 0
	Center.Position = UDim2.new(0.5, 0, 0, 0)
	Center.Size = UDim2.new(0, 1, 0, 1)

	Holder.Name = "Holder"
	Holder.Parent = Center
	Holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Holder.BackgroundTransparency = 1
	Holder.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Holder.BorderSizePixel = 0
	Holder.Position = UDim2.new(-124, 0, 16, 0)
	Holder.Size = UDim2.new(0, 250, 0, 300)

	Template.Name = "Template"
	Template.Parent = Holder
	Template.BackgroundColor3 = Color3.fromRGB(25, 29, 38)
	Template.BackgroundTransparency = 0.400
	Template.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Template.BorderSizePixel = 0
	Template.Position = UDim2.new(0, -124, 0, 16)
	Template.Size = UDim2.new(0, 250, 0, 100)
	Template.Visible = false

	UICorner.Parent = Template

	Main.Name = "Main"
	Main.Parent = Template
	Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Main.BackgroundTransparency = 1
	Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Main.BorderSizePixel = 0
	Main.Position = UDim2.new(0.200000003, 0, 0.0900000036, 0)
	Main.Size = UDim2.new(0, 150, 0, 25)
	Main.Font = Enum.Font.Unknown
	Main.Text = "Lorem Ipsum"
	Main.TextColor3 = Color3.fromRGB(255, 255, 255)
	Main.TextScaled = true
	Main.TextSize = 14.000
	Main.TextWrapped = true

	Secondary.Name = "Secondary"
	Secondary.Parent = Template
	Secondary.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Secondary.BackgroundTransparency = 1
	Secondary.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Secondary.BorderSizePixel = 0
	Secondary.Position = UDim2.new(0.100000001, 0, 0.340000004, 0)
	Secondary.Size = UDim2.new(0, 200, 0, 40)
	Secondary.Font = Enum.Font.Unknown
	Secondary.Text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam placerat velit arcu, vitae bibendum risus fringilla ac."
	Secondary.TextColor3 = Color3.fromRGB(255, 255, 255)
	Secondary.TextScaled = true
	Secondary.TextSize = 14.000
	Secondary.TextWrapped = true

	Y.Name = "Y"
	Y.Parent = Template
	Y.BackgroundColor3 = Color3.fromRGB(25, 29, 38)
	Y.BackgroundTransparency = 0.500
	Y.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Y.BorderSizePixel = 0
	Y.Position = UDim2.new(0.699999988, 0, 0.74000001, 0)
	Y.Size = UDim2.new(0, 50, 0, 20)
	Y.Font = Enum.Font.Unknown
	Y.Text = "Yes"
	Y.TextColor3 = Color3.fromRGB(255, 255, 255)
	Y.TextScaled = true
	Y.TextSize = 14.000
	Y.TextWrapped = true

	UICorner_2.CornerRadius = UDim.new(0, 5)
	UICorner_2.Parent = Y

	N.Name = "N"
	N.Parent = Template
	N.BackgroundColor3 = Color3.fromRGB(25, 29, 38)
	N.BackgroundTransparency = 0.500
	N.BorderColor3 = Color3.fromRGB(0, 0, 0)
	N.BorderSizePixel = 0
	N.Position = UDim2.new(0.100000001, 0, 0.74000001, 0)
	N.Size = UDim2.new(0, 50, 0, 20)
	N.Font = Enum.Font.Unknown
	N.Text = "No"
	N.TextColor3 = Color3.fromRGB(255, 255, 255)
	N.TextScaled = true
	N.TextSize = 14.000
	N.TextWrapped = true

	UICorner_3.CornerRadius = UDim.new(0, 5)
	UICorner_3.Parent = N

	UIListLayout.Parent = Holder
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 5)

	Main.FontFace = Font.new("rbxassetid://11702779409")
	Secondary.FontFace = Font.new("rbxassetid://11702779409")
	Y.FontFace = Font.new("rbxassetid://11702779409")
	N.FontFace = Font.new("rbxassetid://11702779409")

	local notiflib = {}
	local temp = Template
	local core = Holder

	notiflib.Notify = function(header,details,time,callback,data)
		if not header then error("No Header Text...") end
		if typeof(header) ~= "string" then error("Header Text MUST be a string!") end
		if not details then error("No Detail Text...") end
		if typeof(details) ~= "string" then error("Detail Text MUST be a string!") end
		local notif = temp:Clone()
		notif.Name = "Notification"
		notif.Parent = core
		if not data then
			notif.Y.Visible = false
			notif.N.Visible = false
		end
		local script = Instance.new("LocalScript", notif)
		notif.Transparency = 1
		notif.Y.Transparency = 1
		notif.N.Transparency = 1
		notif.Y.TextTransparency = 1
		notif.N.TextTransparency = 1
		notif.Main.TextTransparency = 1
		notif.Secondary.TextTransparency = 1
		notif.Main.Text = header
		notif.Secondary.Text = details
		local stroke = Instance.new("UIStroke", notif)
		stroke.Color = Color3.fromRGB(255,255,255)
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.LineJoinMode = Enum.LineJoinMode.Round
		stroke.Transparency = 0.9
		local s2 = stroke:Clone()
		s2.Parent = notif.Y
		s2.Transparency = 0.8
		local s3 = s2:Clone()
		s3.Parent = notif.N
		notif.Visible = true
		local sound = Instance.new("Sound", workspace)
		sound.SoundId = "rbxassetid://4612373884"
		sound.Volume = 2
		sound.Looped = false
		sound.Playing = true
		game:GetService("TweenService"):Create(notif,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {Transparency=0.4}):Play()
		game:GetService("TweenService"):Create(notif.Y,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {Transparency=0.5}):Play()
		game:GetService("TweenService"):Create(notif.N,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {Transparency=0.5}):Play()
		game:GetService("TweenService"):Create(notif.Y,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=0}):Play()
		game:GetService("TweenService"):Create(notif.N,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=0}):Play()
		game:GetService("TweenService"):Create(notif.Main,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=0}):Play()
		game:GetService("TweenService"):Create(notif.Secondary,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=0}):Play()
		local function dest()
			game:GetService("TweenService"):Create(notif,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {Transparency=1}):Play()
			game:GetService("TweenService"):Create(notif.Y,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {Transparency=1}):Play()
			game:GetService("TweenService"):Create(notif.N,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {Transparency=1}):Play()
			game:GetService("TweenService"):Create(notif.Y,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=1}):Play()
			game:GetService("TweenService"):Create(notif.N,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=1}):Play()
			game:GetService("TweenService"):Create(notif.Main,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=1}):Play()
			game:GetService("TweenService"):Create(notif.Secondary,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=1}):Play()
			wait(0.3)
			wait(0.1)
			notif:Destroy()
			sound:Destroy()
		end
		if data then
			notif.N.Text = data[1]
			notif.Y.Text = data[2]
			local h = false
			notif.N.Activated:Connect(function()
				if h == false then
					h = true
					callback(false)
					dest()
				end
			end)
			notif.Y.Activated:Connect(function()
				if h == false then
					h = true
					callback(true)
					dest()
				end
			end)
		end
		delay(time,dest)
	end
	notiflib.Notify("Injected!", "Injected", 5)
	local cevery = true
	local env = nil
	local wrapped = table.create(0)
	local cachedi = {}
	local wrap = nil
	local vim = Instance.new("VirtualInputManager")
	local execname = "Unnamed executor"
	local indexable = game.HttpService:GenerateGUID(false) --to prevent easily unwrapping our own shit yk to break out of the wrap
	local blockedmethods = {"PromptBundlePurchase","PerformPurchaseV2", "PromptGamePassPurchase", "PromptProductPurchase", "PromptPurchase", "PromptRobloxPurchase", "PromptThirdPartyPurchase", "OpenBrowserWindow", "OpenNativeOverlay", "HttpRequestAsync", "AddCoreScriptLocal", "EmitHybridEvent", "ExecuteJavaScript", "OpenBrowserWindow", "OpenNativeOverlay", "ReturnToJavaScript", "SendCommand", "Call", "GetLast", "GetMessageId", "GetProtocolMethodRequestMessageId", "GetProtocolMethodResponseMessageId", "MakeRequest", "Publish", "PublishProtocolMethodRequest", "PublishProtocolMethodResponse", "Subscribe", "SubscribeToProtocolMethodRequest","SubscribeToProtocolMethodResponse","MakeRequest","ReportAbuse","ReportAbuseV3"} --put your blocked methods as strings capitals dont matter lmao
	local unwrap = nil
	local debuginstance = false
	local debuginstancebutnotlaggyasshit = false
	local raped = table.create(0)
	local game = game
	if solaramode == true then
		game = getfenv(loadfile).unwrap(game)
	end
	local bridge_parent = game:GetService("RobloxReplicatedStorage")
	local http_service = game:GetService("HttpService")

	local data_maxlen = 199998
	local PAYLOAD_MATCH = "^%x+"
	local PAYLOAD_TEMPLATE = "%08X|%s"

	local step_sim = game:GetService("RunService").PreSimulation
	local sending_value_whitelist = { "string", "number", "Instance", "boolean", "table" }

	local channel_template
	do
		channel_template = Instance.new("Folder")

		local peer0_container = Instance.new("Folder") -- roblox container
		peer0_container.Name = "Peer0"
		peer0_container.Parent = channel_template

		local peer1_container = Instance.new("Folder") -- external container
		peer1_container.Name = "Peer1"
		peer1_container.Parent = channel_template

		local instance_refs = Instance.new("Folder")
		instance_refs.Name = "InstanceRefs"
		instance_refs.Parent = channel_template

		local channel_states = Instance.new("NumberValue")
		channel_states.Name = "States"
		channel_states.Parent = channel_template

		-- precreation of StringValues
		-- roughly 16mb+ when combined

		for idx = 0, 8 do
			local peer0_str = Instance.new("StringValue", peer0_container)
			local peer1_str = Instance.new("StringValue", peer1_container)

			peer0_str.Name, peer1_str.Name = idx, idx
			peer0_str.Value = string.rep("\128", 20)
			peer1_str.Value = string.rep("\128", data_maxlen) -- peer1 (external peer) stringvalue is preallocated
		end
	end

	local bridge = {}

	function bridge:send(action, ...) 
		local args = {...}
		local success, res = pcall(function()

			local url = "http://localhost:8000/bridge?action=" .. action
			for i, arg in ipairs(args) do
				url = url .. "&arg" .. i .. "=" .. game.HttpService:UrlEncode(tostring(arg))
			end
			local params = {
				Url = url,
				Method = "GET",
				Headers = {
					["Content-Type"] = "application/json"
				}
			}
			local request = game.HttpService:RequestInternal(params)
			local response = nil
			local requestCompletedEvent = Instance.new("BindableEvent")
			request:Start(function(success, result)
				response = result
				requestCompletedEvent:Fire()
			end)
			requestCompletedEvent.Event:Wait()

			if response.StatusMessage == "OK" then 
				return game.HttpService:JSONDecode(response.Body) 
			end
		end)
		if not success then
			warn("[ ERROR ] -> "..tostring(res))
		else
			return res
		end
	end

	wrap = function(towrap)
		if table.find(wrapped,towrap) then
			return raped[table.find(wrapped,towrap)]
		end
		if debuginstance == true then
			print("wrapped:",towrap)
		end
		local id = #wrapped + 1
		wrapped[id] = towrap
		local newstance = newproxy(true)
		raped[id] = newstance
		local meta = getmetatable(newstance)
		meta.__index = function(_,index)
			if debuginstancebutnotlaggyasshit == true then
				print(towrap, "indexed with",index)
			end
			local _, t_index = pcall(function()
				return towrap[index]
			end)
			if index == indexable then
				return function(_,...)
					return id
				end
			end
			if string.lower(index) == "getservice" or string.lower(index) == "service" then
				return function(_, ...)
					if ... == "VirtualInputManager" then
						return wrap(Instance.new("VirtualInputManager"))
					end
					return wrap(game:GetService(...))
				end
			elseif index == "HttpGet" then
				return function(self, url)    
					assert(typeof(url)=="string", "Expected string for URL")
					local toret
					local W = Instance.new("BindableEvent")
					game:GetService("HttpService"):RequestInternal({Url = url:gsub('roblox.com','roproxy.com'), CachePolicy = Enum.HttpCachePolicy.None, Headers = {["Fingerprint"] = "FINGERME"}}):Start(function(success, data)
						toret = data.Body

						W:fire()
					end)

					W.Event:Wait()

					return toret
				end

			elseif t_index and type(t_index) == "function" and index == "Connect" then
				return function(_, func)
					towrap:Connect(function(A)
						if type(A) == "userdata" then
							A = wrap(A)
						end
						return A
					end)
				end
			elseif t_index and type(t_index) == "function" then
				if table.find(blockedmethods, string.lower(index)) then
					error(execname .. " has blocked this method for security reason's.",2)
				end
				return function(_, ...)
					local balls = t_index(towrap, ...)
					if type(balls) == "table" and type(balls[1]) == "userdata" then
						for i, v in pairs(balls) do
							balls[i] = wrap(v)
						end
					end
					return balls
				end
			elseif string.lower(index) == "clone" then
				return wrap(towrap:Clone())
			elseif t_index and type(t_index) ~= "userdata" then
				return t_index
			elseif t_index and type(t_index) == "userdata" then
				local toret = t_index
				if table.find(wrapped, toret) then
					local index = table.find(wrapped, toret)
					toret = raped[index]
				else
					toret = wrap(toret)
				end
				return toret
			else
				local toret = nil
				if towrap == game then
					toret = game:GetService(index)
					if toret == nil then
						toret = game[index]
					end
				else
					toret = towrap[index]
				end
				if table.find(wrapped, toret) then
					local index = table.find(wrapped, toret)
					toret = raped[index]
				end
				return toret
			end
		end
		meta.__newindex = function(_, toset, thing)
			if debuginstancebutnotlaggyasshit == true then
				print(towrap, "set value", toset, "to", thing)
			end
			thing = unwrap(thing)
			local worked, result = pcall(function()
				towrap[toset] = thing
			end)
			if not worked then
				error(result,2)
			end
		end
		meta.__metatable = "This metatable is locked"
		return newstance
	end

	unwrap = function(wrappedw)
		local worked, unwrapped = pcall(function()
			local ida = wrappedw[indexable]
			local id = ida()
			return wrapped[id]
		end)
		if worked == false then
			--handle errors maybe
		end
		local unwrapped = unwrapped or wrappedw
		if type(unwrapped) == "string" then
			unwrapped = wrappedw
		end
		return unwrapped
	end
	local anew = Instance.new
	local new = function(class, parent)
		if debuginstancebutnotlaggyasshit == true then
			print("made", class, "with parent", unwrap(parent))
		end
		parent = unwrap(parent)
		local thing = anew(class, parent)
		local new = wrap(thing)
		if parent == nil then
			cachedi[new] = new
		end
		return new
	end

	local Instance = {}
	Instance.new = new

	local topg = game
	local game = wrap(game)
	local workspace = game.Workspace
	local renv = table.create(0)
	local defenv = {"DockWidgetPluginGuiInfo","warn","tostring","gcinfo","os","tick","task","getfenv","pairs","NumberSequence","assert","rawlen","tonumber","CatalogSearchParams","Enum","Delay","OverlapParams","Stats","_G","UserSettings","coroutine","NumberRange","buffer","shared","NumberSequenceKeypoint","PhysicalProperties","PluginManager","Vector2int16","UDim2","loadstring","printidentity","Version","Vector2","UDim","Game","delay","spawn","Ray","string","xpcall","SharedTable","RotationCurveKey","DateTime","print","ColorSequence","debug","RaycastParams","Workspace","unpack","TweenInfo","Random","require","Vector3","bit32","Vector3int16","setmetatable","next","Instance","Font","FloatCurveKey","ipairs","plugin","Faces","rawequal","Region3int16","collectgarbage","game","getmetatable","Spawn","ColorSequenceKeypoint","Region3","utf8","Color3","CFrame","rawset","PathWaypoint","typeof","workspace","ypcall","settings","Wait","math","version","pcall","stats","elapsedTime","type","wait","ElapsedTime","select","time","DebuggerManager","rawget","table","Rect","BrickColor","setfenv","_VERSION","Axes","error","newproxy",}
	for i, v in pairs(defenv) do
		renv[v] = getfenv()[v]
	end
	defenv = nil
	local genv = table.create(0)
	--Defaults
	genv.game = game
	genv.workspace = workspace
	genv.Instance = Instance
	genv.Game = game
	genv.Workspace = workspace
	renv.game = game
	renv.Game = game
	renv.workspace = workspace
	renv.Workspace = workspace
	--UNC
	genv.identifyexecutor = function()
		return execname, "1.0.0 NIGGER EDITION"
	end
	genv.newcclosure = function(func)
		local func2 = nil
		func2 = function(...)
			genv[func] = coroutine.wrap(func2)
			return func(...)
		end
		func2 = coroutine.wrap(func2)
		return func2
	end
	genv.iscclosure = function(func)
		return debug.info(func, "s") == "[C]"
	end
	genv.islclosure = function(func)
		return debug.info(func, "s") ~= "[C]"
	end
	genv.newlclosure = function(func) --i see this in other executors? why the fuck does it exist? dm me if you know 🙏
		return function(bullshit)
			return func(bullshit)
		end
	end
	genv.keypress = function(key)
		vim:SendKeyEvent(true, key, false, nil)
	end

	genv.keyrelease = function(key)
		vim:SendKeyEvent(false, key, false, nil)
	end
	genv.getobjects = function(id)
		if not string.find(tostring(id), "rbxassetid://") then
			id = "rbxassetid://" .. tostring(id)
		end
		return { game:GetService("InsertService"):LoadLocalAsset(id) }
	end
	genv.getexecutioncontext = function() -- its always client. always. forever.
		return "Client"
	end
	genv.cloneref = function(instance)
		local bs = {}
		setmetatable(bs, {
			__index = function(env,shi)
				return instance[shi]
			end,
			__newindex = function(env, toset, set)
				instance[toset] = set
			end,
		})
		return bs
	end
	local mainkey = "LUAU"
	genv.dbginstances = function(bool, key)
		assert(mainkey==key, "Invalid key")
		assert(type(bool)=="boolean", "Input #1 must be a boolean")
		debuginstancebutnotlaggyasshit = bool
	end
	-- variables
	local BLACKLISTED_EXTENSIONS = {
		".exe", ".bat",  ".com", ".cmd",  ".inf", ".ipa",
		".apk", ".apkm", ".osx", ".pif",  ".run", ".wsh",
		".bin", ".app",  ".vb",  ".vbs",  ".scr", ".fap",
		".cpl", ".inf1", ".ins", ".inx",  ".isu", ".job",
		".lnk", ".msi",  ".ps1", ".reg",  ".vbe", ".js",
		".x86", ".pif",  ".xlm", ".scpt", ".out", ".ba_",
		".jar", ".ahk",  ".xbe", ".0xe",  ".u3p", ".bms",
		".jse", ".cpl",  ".ex",  ".osx",  ".rar", ".zip",
		".7z",  ".py",   ".cpp", ".cs",   ".prx", ".tar",
		".",    ".wim",  ".htm", ".html", ".css",
		".appimage", ".applescript", ".x86_64", ".x64_64",
		".autorun", ".tmp", ".sys", ".dat", ".ini", ".pol",
		".vbscript", ".gadget", ".workflow", ".script",
		".action", ".command", ".arscript", ".psc1",
	}
	local FILESYSTEM_LOADED = false

	local filesys_storage = {}
	local script_env

	-- functions
	local function sanitize_path(dir_path: string)
		if #dir_path < 1 then
			return
		end

		dir_path = string.gsub(
			dir_path,
			"[\0\1\2\3\4\5\6\7\8\11\12\13\14\15\16\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31]+[:*?\"<>|]+",
			""
		)
		return dir_path
	end

	local function sanitize_file_name(file_name: string): string?
		local _sanitized_name = sanitize_path(file_name) :: string
		if file_name ~= _sanitized_name then
			return error(`Blacklisted character in file name '{file_name}'`, 0)
		end

		local extention_splits = string.split(file_name, ".")
		local file_extension = extention_splits[#extention_splits]

		if table.find(BLACKLISTED_EXTENSIONS, `.{file_extension}`) then
			return error(`Blacklisted extension in file name '{file_name}'`, 0)
		end
		return file_name
	end

	-- main
	local filesystem = {}

	filesystem.readfile = function(file_name)
		assert(file_name, "Missing #1 argument")
		assert(typeof(file_name) == "string", "Expected #1 argument to be string, got ".. typeof(file_name).. " instead")

		local succeeded, res = pcall(function()
			file_name = file_name

			if file_name ~= nil then
				local response = bridge:send("readfile", file_name)

				if typeof(response) == "table" then
					local status = response["status"]

					if status == "success" then
						return response["message"] or ""
					else
						error(response["message"])
						return
					end
				else
					error("Readfile failed")
					return
				end
			else
				error("Illegal file extension detected")
				return
			end
		end)

		if succeeded then
			return res
		else
			error(res)
		end
	end
	filesystem.delfile = function(file_name)
		assert(file_name, "Missing #1 argument")
		assert(typeof(file_name) == "string", "Expected #1 argument to be string, got ".. typeof(file_name).. " instead")

		local succeeded, res = pcall(function()
			file_name = file_name

			if file_name ~= nil then
				local response = bridge:send("delfile", file_name)

				if typeof(response) == "table" then
					local status = response["status"]

					if status == "success" then
						return response["message"] or ""
					else
						error(response["message"])
						return
					end
				else
					error("Readfile failed")
					return
				end
			else
				error("Illegal file extension detected")
				return
			end
		end)

		if succeeded then
			return res
		else
			error(res)
		end
	end
	

	filesystem.writefile = function(file_name, data)
		assert(file_name, "Missing #1 argument")
		assert(typeof(file_name) == "string", "Expected #1 argument to be string, got ".. typeof(file_name).. " instead")

		assert(data, "Missing #2 argument")

		file_name = file_name

		if file_name ~= nil then
			bridge:send("writefile", file_name, tostring(data)) 
		else
			print("Illegal file extension detected")
		end
	end 

	filesystem.appendfile = function(dir_path: string, content: string)
		assert(type(dir_path) == "string", "arg #1 must be type string")
		assert(type(content) == "string", "arg #2 must be type string")

		local thing1 = filesystem.readfile(dir_path)
		local thing2 = thing1 .. content
		return filesystem.writefile(dir_path, thing2)
	end

	filesystem.loadfile = function(dir_path: string): ()
		local code = filesystem.readfile(dir_path)
		return env.loadstring(code, dir_path)
	end

	filesystem.deletepath = filesystem.delfile

	filesystem.makefolder = function(folder_name)
		bridge:send("makefolder", folder_name)
	end

	filesystem.isfile = function(file_name: string)
		assert(file_name, "Missing #1 argument")
		assert(typeof(file_name) == "string", "Expected #1 argument to be string, got ".. typeof(file_name).. " instead")

		local response = bridge:send("isfile", file_name)
		return response["message"] == true
	end

	filesystem.isfolder = filesystem.isfile

	genv.loadfile = filesystem.loadfile
	genv.readfile = filesystem.readfile
	genv.writefile = filesystem.writefile
	genv.makefolder = filesystem.makefolder
	genv.isfolder = filesystem.isfolder
	genv.isfile = filesystem.isfile
	genv.appendfile = filesystem.appendfile
	genv.deletepath = filesystem.deletepath
	genv.delfile = genv.deletepath
	genv.delfolder = genv.delfile
	genv.setclipboard = function(data)
		assert(data, "Missing #1 argument")

		bridge:send("setclipboard", tostring(data))
	end

	genv.compareinstances = function(nigger1, nigger2)
		nigger1 = unwrap(nigger1)
		nigger2 = unwrap(nigger2)
		return nigger1 == nigger2
	end
	genv.getloadedmodules = function()
		local tab = table.create(0)
		for i, v in pairs(topg:GetDescendants()) do
			if v.ClassName == "ModuleScript" then
				table.insert(tab,wrap(v))
			end
		end
		return tab
	end
	local INTgetloadedmodules = function() --make NO reference in env or they can get a unwrapped version of shit
		local tab = table.create(0)
		for i, v in pairs(topg.CoreGui:GetDescendants()) do
			if v.ClassName == "ModuleScript" then
				table.insert(tab,v)
			end
		end
		return tab
	end
	genv.getloadedscripts = function()
		local tab = table.create(0)
		for i, v in pairs(topg:GetDescendants()) do
			if v.ClassName == "LocalScript" or v.ClassName == "ModuleScript" then
				table.insert(tab,wrap(v))
			end
		end
		return tab
	end
	genv.isreadonly = function(tab)
		local isread, _ = pcall(function()
			tab[#tab+1] = nil
		end)
		return isread == false
	end
	genv.gethui = function()
		return game:FindService("CoreGui"):FindFirstChild("RobloxGui")
	end
	genv.getinstances = function()
		return game:GetDescendants()
	end
	genv.isluau = function()
		return true -- lmao
	end
	local uis = game:GetService("UserInputService")
	local focused = false
	focused = true
	uis.WindowFocused:Connect(function()
		focused = true
	end)
	uis.WindowFocusReleased:Connect(function()
		focused = false
	end)
	genv.isrbxactive = function()
		return focused
	end
	genv.isgameactive = genv.isrbxactive
	genv.getscripts = genv.getloadedscripts
	genv.getrunningscripts = genv.getscripts
	genv.getscripthash = function(script: Script)
		return script:GetHash()
	end
	genv.isreadonly = table.isfrozen
	genv.clonefunction = function(func)
		local isc = debug.info(func, "s") == "[C]"
		local newfunc = nil
		if isc == true then
			newfunc = genv.newcclosure(func)
		else
			newfunc = function(...)
				return func(...)
			end
		end
		return newfunc
	end
	genv.randomstring = function(len)
		local chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789"
		local len = len or 10
		local ran = ""
		for i=1,len do
			local i = math.random(1, #chars)
			ran = ran .. string.sub(chars, i,i)
		end
		return ran
	end
	genv.getthreadidentity = function()
		return 3
	end
	genv.getidentity = genv.getthreadidentity
	genv.getthreadcontext = genv.getthreadidentity
	local meth = {
		__index = function(thing, val)
			return thing[val]
		end,
		__newindex = function(thing, val, value)
			thing[val] = value
		end,
		__call = function(thing, ...)
			return thing(...)
		end,
		__concat = function(thing, val)
			return thing..val
		end,
		__add = function(thing, val)
			return thing + val
		end,
		__sub = function(thing, val)
			return thing - val
		end,
		__mul = function(thing, val)
			return thing * val
		end,
		__div = function(thing, val)
			return thing / val
		end,
		__idiv = function(thing, val)
			return thing // val
		end,
		__mod = function(thing, val)
			return thing % val
		end,
		__pow = function(thing, val)
			return thing ^ val
		end,
		__tostring = function(thing)
			return tostring(thing)
		end,
		__eq = function(thing, val)
			return thing == val
		end,
		__lt = function(thing, val)
			return thing < val
		end,
		__le = function(thing, val)
			return thing <= val
		end,
		__len = function(thing)
			return #thing
		end,
		__iter = function(thing)
			return next, thing
		end,
		__namecall = function(thing, ...)
			return thing:_(...)
		end,
		__metatable = function(thing)
			return getmetatable(thing)
		end
	}
	genv.isexecutorclosure = function(func)
		if func == print then
			return false
		end
		if table.find(renv, func) then
			return false
		else
			return true
		end
	end
	renv.typeof = function(...)
		local test = unwrap(...)
		if test == "NONE" then
			return typeof(...)
		else
			return "Instance"
		end
	end
	genv.isourclosure = genv.isexecutorclosure
	genv.checkclosure = genv.isexecutorclosure
	local lz4 = {}

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
	genv.lz4 = lz4
	local crypt = table.create(0)
	crypt.lz4 = lz4
	crypt.lz4compress = lz4.compress
	crypt.lz4decompress = lz4.decompress
	genv.lz4decompress = lz4.decompress
	genv.lz4compress = lz4.compress
	--idk who made the base64 creds to who ever made it lmao
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	function to_base64(data)
		return ((data:gsub('.', function(x) 
			local r,b='',x:byte()
			for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
			return r;
		end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
			if (#x < 6) then return '' end
			local c=0
			for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
			return b:sub(c+1,c+1)
		end)..({ '', '==', '=' })[#data%3+1])
	end

	-- this function converts base64 to string
	function from_base64(data)
		data = string.gsub(data, '[^'..b..'=]', '')
		return (data:gsub('.', function(x)
			if (x == '=') then return '' end
			local r,f='',(b:find(x)-1)
			for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
			return r;
		end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
			if (#x ~= 8) then return '' end
			local c=0
			for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
			return string.char(c)
		end))
	end
	genv.base64encode = to_base64
	genv.base64decode = from_base64
	base64 = {}
	base64.encode = to_base64
	base64.decode = from_base64

	crypt.base64encode = to_base64
	crypt.base64_encode = to_base64

	crypt.base64decode = from_base64
	crypt.base64_decode = from_base64
	genv.crypt = crypt
	crypt.base64 = base64
	genv.crypt.base64decode = crypt.base64decode
	genv.crypt.base64encode = crypt.base64encode
	--finish up lmao
	genv.shared = {}
	genv.base64 = base64
	genv.loadfile = function(file)
		return genv.loadstring(genv.readfile(file), file)()
	end
	genv._G = {}
	renv._G = {}
	renv.shared = {}
	--genv.getfenv = renv.getfenv
	--loopthru(renv, renv)
	local function loopthru(thing, thing2)
		for i, v in pairs(thing) do
			if i == "cache" then
				print("yay")
			end
			if type(v) == "table" then
				thing2[i] = {}
				local tab = thing2[i]
				loopthru(v, tab)
			end
			if type(v) ~= "function" then thing2[i] = v continue end
			local func = nil
			func = function(...)
				thing2[i] = coroutine.wrap(func)
				pcall(function()
					v = setfenv(v, renv)
				end)
				return v(...)
			end
			thing2[i] = coroutine.wrap(func)
			--genv2[i] = test1
		end
	end
	local function regenv()
		local genv2 = {}
		loopthru(genv, genv2)
		setmetatable(genv2,{
			__index = function(env,...)
				local val = renv[...]
				return val
			end,
			__newindex = function(env, toset, val)
				rawset(genv2,toset,val)
			end,
			__len = function(_)
				local num = 0
				for i,v in pairs(genv2) do
					num += 1
				end
				return num
			end,
		})
		return genv2
	end
	genv.regenv = function()
		table.clear(env)
		loopthru(genv, env)
	end
	--genv.script = Instance.new("LocalScript")

	--drawing lib from sweet ol jalon here later (im NOT fucking coding my own drawing lib that sounds like hell)
	-- Made by jLn0n

	-- services
	local coreGui = topg:GetService("CoreGui")
	-- objects
	local camera = topg.Workspace.CurrentCamera
	local drawingUI = anew("ScreenGui")
	drawingUI.Name = "Drawing"
	drawingUI.IgnoreGuiInset = true
	drawingUI.DisplayOrder = 0x7fffffff
	drawingUI.Parent = coreGui
	-- variables
	local drawingIndex = 0
	local uiStrokes = table.create(0)
	local baseDrawingObj = setmetatable({
		Visible = true,
		ZIndex = 0,
		Transparency = 1,
		Color = Color3.new(),
		Remove = function(self)
			setmetatable(self, nil)
		end
	}, {
		__add = function(t1, t2)
			local result = table.clone(t1)

			for index, value in t2 do
				result[index] = value
			end
			return result
		end
	})
	local drawingFontsEnum = {
		[0] = Font.fromEnum(Enum.Font.Roboto),
		[1] = Font.fromEnum(Enum.Font.Legacy),
		[2] = Font.fromEnum(Enum.Font.SourceSans),
		[3] = Font.fromEnum(Enum.Font.RobotoMono),
	}
	-- function
	local function getFontFromIndex(fontIndex: number): Font
		return drawingFontsEnum[fontIndex]
	end

	local function convertTransparency(transparency: number): number
		return math.clamp(1 - transparency, 0, 1)
	end
	-- main
	local DrawingLib = {}
	DrawingLib.Fonts = {
		["UI"] = 0,
		["System"] = 1,
		["Plex"] = 2,
		["Monospace"] = 3
	}
	local drawings = {}
	function DrawingLib.new(drawingType)
		drawingIndex += 1
		if drawingType == "Line" then
			local lineObj = ({
				From = Vector2.zero,
				To = Vector2.zero,
				Thickness = 1
			} + baseDrawingObj)

			local lineFrame = anew("Frame")
			lineFrame.Name = drawingIndex
			lineFrame.AnchorPoint = (Vector2.one * .5)
			lineFrame.BorderSizePixel = 0

			lineFrame.BackgroundColor3 = lineObj.Color
			lineFrame.Visible = lineObj.Visible
			lineFrame.ZIndex = lineObj.ZIndex
			lineFrame.BackgroundTransparency = convertTransparency(lineObj.Transparency)

			lineFrame.Size = UDim2.new()

			lineFrame.Parent = drawingUI
			local bs = table.create(0)
			table.insert(drawings,bs)
			return setmetatable(bs, {
				__newindex = function(_, index, value)
					if typeof(lineObj[index]) == "nil" then return end

					if index == "From" then
						local direction = (lineObj.To - value)
						local center = (lineObj.To + value) / 2
						local distance = direction.Magnitude
						local theta = math.deg(math.atan2(direction.Y, direction.X))

						lineFrame.Position = UDim2.fromOffset(center.X, center.Y)
						lineFrame.Rotation = theta
						lineFrame.Size = UDim2.fromOffset(distance, lineObj.Thickness)
					elseif index == "To" then
						local direction = (value - lineObj.From)
						local center = (value + lineObj.From) / 2
						local distance = direction.Magnitude
						local theta = math.deg(math.atan2(direction.Y, direction.X))

						lineFrame.Position = UDim2.fromOffset(center.X, center.Y)
						lineFrame.Rotation = theta
						lineFrame.Size = UDim2.fromOffset(distance, lineObj.Thickness)
					elseif index == "Thickness" then
						local distance = (lineObj.To - lineObj.From).Magnitude

						lineFrame.Size = UDim2.fromOffset(distance, value)
					elseif index == "Visible" then
						lineFrame.Visible = value
					elseif index == "ZIndex" then
						lineFrame.ZIndex = value
					elseif index == "Transparency" then
						lineFrame.BackgroundTransparency = convertTransparency(value)
					elseif index == "Color" then
						lineFrame.BackgroundColor3 = value
					end
					lineObj[index] = value
				end,
				__index = function(self, index)
					if index == "Remove" or index == "Destroy" then
						return function()
							lineFrame:Destroy()
							lineObj.Remove(self)
							return lineObj:Remove()
						end
					end
					return lineObj[index]
				end
			})
		elseif drawingType == "Text" then
			local textObj = ({
				Text = "",
				Font = DrawingLib.Fonts.UI,
				Size = 0,
				Position = Vector2.zero,
				Center = false,
				Outline = false,
				OutlineColor = Color3.new()
			} + baseDrawingObj)

			local textLabel, uiStroke = anew("TextLabel"), anew("UIStroke")
			textLabel.Name = drawingIndex
			textLabel.AnchorPoint = (Vector2.one * .5)
			textLabel.BorderSizePixel = 0
			textLabel.BackgroundTransparency = 1

			textLabel.Visible = textObj.Visible
			textLabel.TextColor3 = textObj.Color
			textLabel.TextTransparency = convertTransparency(textObj.Transparency)
			textLabel.ZIndex = textObj.ZIndex

			textLabel.FontFace = getFontFromIndex(textObj.Font)
			textLabel.TextSize = textObj.Size

			textLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
				local textBounds = textLabel.TextBounds
				local offset = textBounds / 2

				textLabel.Size = UDim2.fromOffset(textBounds.X, textBounds.Y)
				textLabel.Position = UDim2.fromOffset(textObj.Position.X + (if not textObj.Center then offset.X else 0), textObj.Position.Y + offset.Y)
			end)

			uiStroke.Thickness = 1
			uiStroke.Enabled = textObj.Outline
			uiStroke.Color = textObj.Color

			textLabel.Parent, uiStroke.Parent = drawingUI, textLabel
			local bs = table.create(0)
			table.insert(drawings,bs)
			return setmetatable(bs, {
				__newindex = function(_, index, value)
					if typeof(textObj[index]) == "nil" then return end

					if index == "Text" then
						textLabel.Text = value
					elseif index == "Font" then
						value = math.clamp(value, 0, 3)
						textLabel.FontFace = getFontFromIndex(value)
					elseif index == "Size" then
						textLabel.TextSize = value
					elseif index == "Position" then
						local offset = textLabel.TextBounds / 2

						textLabel.Position = UDim2.fromOffset(value.X + (if not textObj.Center then offset.X else 0), value.Y + offset.Y)
					elseif index == "Center" then
						local position = (
							if value then
								camera.ViewportSize / 2
								else
								textObj.Position
						)

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
						local transparency = convertTransparency(value)

						textLabel.TextTransparency = transparency
						uiStroke.Transparency = transparency
					elseif index == "Color" then
						textLabel.TextColor3 = value
					end
					textObj[index] = value
				end,
				__index = function(self, index)
					if index == "Remove" or index == "Destroy" then
						return function()
							textLabel:Destroy()
							textObj.Remove(self)
							return textObj:Remove()
						end
					elseif index == "TextBounds" then
						return textLabel.TextBounds
					end
					return textObj[index]
				end
			})
		elseif drawingType == "Circle" then
			local circleObj = ({
				Radius = 150,
				Position = Vector2.zero,
				Thickness = .7,
				Filled = false
			} + baseDrawingObj)

			local circleFrame, uiCorner, uiStroke = anew("Frame"), anew("UICorner"), anew("UIStroke")
			circleFrame.Name = drawingIndex
			circleFrame.AnchorPoint = (Vector2.one * .5)
			circleFrame.BorderSizePixel = 0

			circleFrame.BackgroundTransparency = (if circleObj.Filled then convertTransparency(circleObj.Transparency) else 1)
			circleFrame.BackgroundColor3 = circleObj.Color
			circleFrame.Visible = circleObj.Visible
			circleFrame.ZIndex = circleObj.ZIndex

			uiCorner.CornerRadius = UDim.new(1, 0)
			circleFrame.Size = UDim2.fromOffset(circleObj.Radius, circleObj.Radius)

			uiStroke.Thickness = circleObj.Thickness
			uiStroke.Enabled = not circleObj.Filled
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			circleFrame.Parent, uiCorner.Parent, uiStroke.Parent = drawingUI, circleFrame, circleFrame
			local bs = table.create(0)
			table.insert(drawings,bs)
			return setmetatable(bs, {
				__newindex = function(_, index, value)
					if typeof(circleObj[index]) == "nil" then return end

					if index == "Radius" then
						local radius = value * 2
						circleFrame.Size = UDim2.fromOffset(radius, radius)
					elseif index == "Position" then
						circleFrame.Position = UDim2.fromOffset(value.X, value.Y)
					elseif index == "Thickness" then
						value = math.clamp(value, .6, 0x7fffffff)
						uiStroke.Thickness = value
					elseif index == "Filled" then
						circleFrame.BackgroundTransparency = (if value then convertTransparency(circleObj.Transparency) else 1)
						uiStroke.Enabled = not value
					elseif index == "Visible" then
						circleFrame.Visible = value
					elseif index == "ZIndex" then
						circleFrame.ZIndex = value
					elseif index == "Transparency" then
						local transparency = convertTransparency(value)

						circleFrame.BackgroundTransparency = (if circleObj.Filled then transparency else 1)
						uiStroke.Transparency = transparency
					elseif index == "Color" then
						circleFrame.BackgroundColor3 = value
						uiStroke.Color = value
					end
					circleObj[index] = value
				end,
				__index = function(self, index)
					if index == "Remove" or index == "Destroy" then
						return function()
							circleFrame:Destroy()
							circleObj.Remove(self)
							return circleObj:Remove()
						end
					end
					return circleObj[index]
				end
			})
		elseif drawingType == "Square" then
			local squareObj = ({
				Size = Vector2.zero,
				Position = Vector2.zero,
				Thickness = .7,
				Filled = false
			} + baseDrawingObj)

			local squareFrame, uiStroke = anew("Frame"), anew("UIStroke")
			squareFrame.Name = drawingIndex
			squareFrame.BorderSizePixel = 0

			squareFrame.BackgroundTransparency = (if squareObj.Filled then convertTransparency(squareObj.Transparency) else 1)
			squareFrame.ZIndex = squareObj.ZIndex
			squareFrame.BackgroundColor3 = squareObj.Color
			squareFrame.Visible = squareObj.Visible

			uiStroke.Thickness = squareObj.Thickness
			uiStroke.Enabled = not squareObj.Filled
			uiStroke.LineJoinMode = Enum.LineJoinMode.Miter

			squareFrame.Parent, uiStroke.Parent = drawingUI, squareFrame
			local bs = table.create(0)
			table.insert(drawings,bs)
			return setmetatable(bs, {
				__newindex = function(_, index, value)
					if typeof(squareObj[index]) == "nil" then return end

					if index == "Size" then
						squareFrame.Size = UDim2.fromOffset(value.X, value.Y)
					elseif index == "Position" then
						squareFrame.Position = UDim2.fromOffset(value.X, value.Y)
					elseif index == "Thickness" then
						value = math.clamp(value, 0.6, 0x7fffffff)
						uiStroke.Thickness = value
					elseif index == "Filled" then
						squareFrame.BackgroundTransparency = (if value then convertTransparency(squareObj.Transparency) else 1)
						uiStroke.Enabled = not value
					elseif index == "Visible" then
						squareFrame.Visible = value
					elseif index == "ZIndex" then
						squareFrame.ZIndex = value
					elseif index == "Transparency" then
						local transparency = convertTransparency(value)

						squareFrame.BackgroundTransparency = (if squareObj.Filled then transparency else 1)
						uiStroke.Transparency = transparency
					elseif index == "Color" then
						uiStroke.Color = value
						squareFrame.BackgroundColor3 = value
					end
					squareObj[index] = value
				end,
				__index = function(self, index)
					if index == "Remove" or index == "Destroy" then
						return function()
							squareFrame:Destroy()
							squareObj.Remove(self)
							return squareObj:Remove()
						end
					end
					return squareObj[index]
				end
			})
		elseif drawingType == "Image" then
			local imageObj = ({
				Data = "",
				DataURL = "rbxassetid://0",
				Size = Vector2.zero,
				Position = Vector2.zero
			} + baseDrawingObj)

			local imageFrame = anew("ImageLabel")
			imageFrame.Name = drawingIndex
			imageFrame.BorderSizePixel = 0
			imageFrame.ScaleType = Enum.ScaleType.Stretch
			imageFrame.BackgroundTransparency = 1

			imageFrame.Visible = imageObj.Visible
			imageFrame.ZIndex = imageObj.ZIndex
			imageFrame.ImageTransparency = convertTransparency(imageObj.Transparency)
			imageFrame.ImageColor3 = imageObj.Color

			imageFrame.Parent = drawingUI
			local bs = table.create(0)
			table.insert(drawings,bs)
			return setmetatable(bs, {
				__newindex = function(_, index, value)
					if typeof(imageObj[index]) == "nil" then return end

					if index == "Data" then
						-- later
					elseif index == "DataURL" then -- temporary property
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
						imageFrame.ImageTransparency = convertTransparency(value)
					elseif index == "Color" then
						imageFrame.ImageColor3 = value
					end
					imageObj[index] = value
				end,
				__index = function(self, index)
					if index == "Remove" or index == "Destroy" then
						return function()
							imageFrame:Destroy()
							imageObj.Remove(self)
							return imageObj:Remove()
						end
					elseif index == "Data" then
						return nil -- TODO: add error here
					end
					return imageObj[index]
				end
			})
		elseif drawingType == "Quad" then
			local quadObj = ({
				PointA = Vector2.zero,
				PointB = Vector2.zero,
				PointC = Vector2.zero,
				PointD = Vector3.zero,
				Thickness = 1,
				Filled = false
			} + baseDrawingObj)

			local _linePoints = table.create(0)
			_linePoints.A = DrawingLib.new("Line")
			_linePoints.B = DrawingLib.new("Line")
			_linePoints.C = DrawingLib.new("Line")
			_linePoints.D = DrawingLib.new("Line")
			local bs = table.create(0)
			table.insert(drawings,bs)
			return setmetatable(bs, {
				__newindex = function(_, index, value)
					if typeof(quadObj[index]) == "nil" then return end

					if index == "PointA" then
						_linePoints.A.From = value
						_linePoints.B.To = value
					elseif index == "PointB" then
						_linePoints.B.From = value
						_linePoints.C.To = value
					elseif index == "PointC" then
						_linePoints.C.From = value
						_linePoints.D.To = value
					elseif index == "PointD" then
						_linePoints.D.From = value
						_linePoints.A.To = value
					elseif (index == "Thickness" or index == "Visible" or index == "Color" or index == "ZIndex") then
						for _, linePoint in _linePoints do
							linePoint[index] = value
						end
					elseif index == "Filled" then
						-- later
					end
					quadObj[index] = value
				end,
				__index = function(self, index)
					if index == "Remove" then
						return function()
							for _, linePoint in _linePoints do
								linePoint:Remove()
							end

							quadObj.Remove(self)
							return quadObj:Remove()
						end
					end
					if index == "Destroy" then
						return function()
							for _, linePoint in _linePoints do
								linePoint:Remove()
							end

							quadObj.Remove(self)
							return quadObj:Remove()
						end
					end
					return quadObj[index]
				end
			})
		elseif drawingType == "Triangle" then
			local triangleObj = ({
				PointA = Vector2.zero,
				PointB = Vector2.zero,
				PointC = Vector2.zero,
				Thickness = 1,
				Filled = false
			} + baseDrawingObj)

			local _linePoints = table.create(0)
			_linePoints.A = DrawingLib.new("Line")
			_linePoints.B = DrawingLib.new("Line")
			_linePoints.C = DrawingLib.new("Line")
			local bs = table.create(0)
			table.insert(drawings,bs)
			return setmetatable(bs, {
				__newindex = function(_, index, value)
					if typeof(triangleObj[index]) == "nil" then return end

					if index == "PointA" then
						_linePoints.A.From = value
						_linePoints.B.To = value
					elseif index == "PointB" then
						_linePoints.B.From = value
						_linePoints.C.To = value
					elseif index == "PointC" then
						_linePoints.C.From = value
						_linePoints.A.To = value
					elseif (index == "Thickness" or index == "Visible" or index == "Color" or index == "ZIndex") then
						for _, linePoint in _linePoints do
							linePoint[index] = value
						end
					elseif index == "Filled" then
						-- later
					end
					triangleObj[index] = value
				end,
				__index = function(self, index)
					if index == "Remove" then
						return function()
							for _, linePoint in _linePoints do
								linePoint:Remove()
							end

							triangleObj.Remove(self)
							return triangleObj:Remove()
						end
					end
					if index == "Destroy" then
						return function()
							for _, linePoint in _linePoints do
								linePoint:Remove()
							end

							triangleObj.Remove(self)
							return triangleObj:Remove()
						end
					end
					return triangleObj[index]
				end
			})
		end
	end
	genv.Drawing = DrawingLib
	genv.checkcaller = function()
		return true -- faking it cuz lazy
	end
	genv.getexecutorname = genv.identifyexecutor
	genv.isrenderobj = function(...)
		if table.find(drawings,...) then
			return true
		else
			return false
		end
	end
	genv.request = function(options)
		assert(type(options) == "table", "invalid argument #1 to 'request' (table expected, got " .. type(options) .. ") ", 2)
		assert(type(options.Url) == "string", "invalid URL (string expected, got " .. type(options.Url) .. ") ", 2)
		if options.Method then 
			assert(type(options.Method) == "string", "invalid URL (string expected, got " .. type(options.Method) .. ") ", 2)
		end
		if options.Body then 
			assert(type(options.Body) == "string", "invalid URL (string expected, got " .. type(options.Body) .. ") ", 2)
		end

		options.CachePolicy = Enum.HttpCachePolicy.None
		options.Priority = 5
		options.Timeout = 15000

		options.Url = options.Url:gsub('roblox.com','roproxy.com')
		local heads
		if options.Method then options.Method = options.Method:upper() end
		for t,v in options do
			if t:lower() == "headers" then
				heads = v
				break
			end
		end

		if not heads then
			heads = {}
		end
		options.Headers = heads
		options.Headers["Fingering" .. "-Fingerprint"] = "FINGERME"

		local Event = Instance.new("BindableEvent")
		local game = game
		local RequestInternal = game:GetService("HttpService").RequestInternal
		local Request = RequestInternal(game:GetService("HttpService"), options)
		local Start = Request.Start
		local Response
		Start(Request, function(state, response)
			Response = response
			Event:Fire()
		end)
		Event.Event:Wait()
		return Response
	end
--[=[------------------------------------------------------------------------------------------------------------------------
-- HashLib by Egor Skriptunoff, boatbomber, and howmanysmall

Documentation here: https://devforum.roblox.com/t/open-source-hashlib/416732/1

--------------------------------------------------------------------------------------------------------------------------

Module was originally written by Egor Skriptunoff and distributed under an MIT license.
It can be found here: https://github.com/Egor-Skriptunoff/pure_lua_SHA/blob/master/sha2.lua

That version was around 3000 lines long, and supported Lua versions 5.1, 5.2, 5.3, and 5.4, and LuaJIT.
Although that is super cool, Roblox only uses Lua 5.1, so that was extreme overkill.

I, boatbomber, worked to port it to Roblox in a way that doesn't overcomplicate it with support of unreachable
cases. Then, howmanysmall did some final optimizations that really squeeze out all the performance possible.
It's gotten stupid fast, thanks to her!

After quite a bit of work and benchmarking, this is what we were left with.
Enjoy!

--------------------------------------------------------------------------------------------------------------------------

DESCRIPTION:
	This module contains functions to calculate SHA digest:
		MD5, SHA-1,
		SHA-224, SHA-256, SHA-512/224, SHA-512/256, SHA-384, SHA-512,
		SHA3-224, SHA3-256, SHA3-384, SHA3-512, SHAKE128, SHAKE256,
		HMAC
	Additionally, it has a few extra utility functions:
		hex_to_bin
		base64_to_bin
		bin_to_base64
	Written in pure Lua.
USAGE:
	Input data should be a string
	Result (SHA digest) is returned in hexadecimal representation as a string of lowercase hex digits.
	Simplest usage example:
		local HashLib = require(script.HashLib)
		local your_hash = HashLib.sha256("your string")
API:
		HashLib.md5
		HashLib.sha1
	SHA2 hash functions:
		HashLib.sha224
		HashLib.sha256
		HashLib.sha512_224
		HashLib.sha512_256
		HashLib.sha384
		HashLib.sha512
	SHA3 hash functions:
		HashLib.sha3_224
		HashLib.sha3_256
		HashLib.sha3_384
		HashLib.sha3_512
		HashLib.shake128
		HashLib.shake256
	Misc utilities:
		HashLib.hmac (Applicable to any hash function from this module except SHAKE*)
		HashLib.hex_to_bin
		HashLib.base64_to_bin
		HashLib.bin_to_base64

--]=]---------------------------------------------------------------------------

	-- local Base64 = require(script.Base64)

	--------------------------------------------------------------------------------
	-- LOCALIZATION FOR VM OPTIMIZATIONS
	--------------------------------------------------------------------------------



	--------------------------------------------------------------------------------
	-- 32-BIT BITWISE FUNCTIONS
	--------------------------------------------------------------------------------
	-- Only low 32 bits of function arguments matter, high bits are ignored
	-- The result of all functions (except HEX) is an integer inside "correct range":
	-- for "bit" library:    (-TWO_POW_31)..(TWO_POW_31-1)
	-- for "bit32" library:        0..(TWO_POW_32-1)
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

	--------------------------------------------------------------------------------
	-- MAGIC NUMBERS CALCULATOR
	--------------------------------------------------------------------------------
	-- Q:
	--    Is 53-bit "double" math enough to calculate square roots and cube roots of primes with 64 correct bits after decimal point?
	-- A:
	--    Yes, 53-bit "double" arithmetic is enough.
	--    We could obtain first 40 bits by direct calculation of p^(1/3) and next 40 bits by one step of Newton's method.
	do
		local function mul(src1, src2, factor, result_length)
			-- src1, src2 - long integers (arrays of digits in base TWO_POW_24)
			-- factor - small integer
			-- returns long integer result (src1 * src2 * factor) and its floating point approximation
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

	local sha = {
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
		-- base64_encode = Base64.Encode;
		-- base64_decode = Base64.Decode;
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
	crypt.hash = function(data, algorithm)
		return hashlib[string.gsub(algorithm, "-", "_")](data)
	end
	crypt.hmac = function(data, key, asBinary)
		return hashlib.hmac(hashlib.sha512_256, data, key, asBinary)
	end
	crypt.generatebytes = function(size)
		local bytes = table.create(size)
		for i = 1, size do
			bytes[i] = string.char(math.random(0, 255))
		end

		return crypt.base64encode(table.concat(bytes))
	end
	crypt.generatekey = function()
		return crypt.generatebytes(32)
	end
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
	local everything = {topg}
	topg.DescendantAdded:Connect(function(desc)
		table.insert(everything, desc)
	end)
	for i, v in pairs(topg:GetDescendants()) do
		table.insert(everything, v)
	end
	topg.DescendantAdded:Connect(function(des: Instance)
		cachedi[des] = des
		des.Destroying:Connect(function()
			cachedi[des] = nil
		end)
	end)
	for i, v in pairs(game:GetDescendants()) do
		cachedi[v] = v
	end
	local cache = {}
	genv.cache = cache
	cache.iscached = function(thing)
		if type(thing) == "userdata" and cachedi[unwrap(thing)] ~= "no" then
			return true
		end
		return cachedi[unwrap(thing)] == unwrap(thing)
	end
	cache.invalidate = function(thing)
		thing = unwrap(thing)
		cachedi[thing] = "no"
		thing.Parent = nil
	end
	cache.replace = function(inst, inst2)
		inst = unwrap(inst)
		inst2 = unwrap(inst2)
		cachedi[inst] = inst2
		inst2.Parent = inst.Parent
		inst2.Name = inst.Name
		inst.Parent = nil
	end
	genv.cleardrawcache = function() -- idk there is no cache to clear
		return true
	end
	genv.isscriptable = function(inst, prop)
		local bool, _ = pcall(function()
			inst[prop] = inst[prop]
		end)
		return bool
	end
	genv.getnilinstances = function()
		local nili = {}
		for i, v in pairs(everything) do
			if v.Parent ~= nil then continue end
			table.insert(nili, v)
		end
		return nili
	end
	genv.fireclickdetector = function(part, nn, nnn)
		pcall(function()
			local cd = part:FindFirstChild("ClickDetector") or part

			local oldParent = cd.Parent
			local p = Instance.new("Part")
			p.Transparency = 1
			p.Size = Vector3.new(30,30,30)
			p.Anchored = true
			p.CanCollide = false
			p.Parent = workspace
			cd.Parent = p
			cd.MaxActivationDistance = math.huge

			local conn

			conn = game["Run Service"].Heartbeat:Connect(function()
				p.CFrame = workspace.Camera.CFrame *CFrame.new(0,0,-20) * CFrame.new(workspace.Camera.CFrame.LookVector.X,workspace.Camera.CFrame.LookVector.Y,workspace.Camera.CFrame.LookVector.Z)
				game:GetService("VirtualUser"):ClickButton1(Vector2.new(20, 20), workspace:FindFirstChildOfClass("Camera").CFrame)
			end)

			cd.MouseClick:Once(function() 
				conn:Disconnect() 
				cd.Parent = oldParent
				p:Destroy() 
			end)
		end)
	end
	genv.getgc = genv.getnilinstances
	genv.getrenderproperty = function(a,b)
		return a[b]
	end
	genv.setrenderproperty = function(a,b,c)
		a[b] = c
	end
	genv.Drawing = DrawingLib
	genv.Drawing.Fonts = DrawingLib.Fonts
	DrawingLib.Fonts.UI = 0
	genv.crypt = crypt
	genv.cache = cache
	genv.getgenv = function(...)
		return env
	end
	genv.getrenv = function(...)
		return renv
	end
	genv.getfenv = function(func)
		if func == 0 then
			return env
		elseif func == nil then
			return env
		else
			return getfenv(func)
		end
	end
	genv.iswrapped = function(thing)
		return unwrap(thing) ~= thing
	end
	local function execute(code, chunkname)
		local module = INTgetloadedmodules()[1]:Clone()
		module.Parent = topg.CoreGui
		module.Name = "Arima"
		local res = bridge:send("load_source",code)
		local func = require(module)
		env.script = nil
		func = setfenv(func, env)
		return func
	end
	genv.loadstring = function(code, chunkname)
		return execute(code)
	end
	genv.makegenv = regenv
	env = regenv()
	renv._G = {}
	renv.shared = {}
	local Frame = anew("Frame")
	local UICorner = anew("UICorner")
	local co = anew("TextBox")
	local UICorner_2 = anew("UICorner")
	local e = anew("TextButton")
	local UICorner_3 = anew("UICorner")
	local c = anew("TextButton")
	local UICorner_4 = anew("UICorner")
	local TextLabel = anew("TextLabel")

	--Properties:

	Frame.Parent = anew("ScreenGui", topg.CoreGui)
	Frame.Active = true
	Frame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(0.293870389, 0, 0.375510216, 0)
	Frame.Size = UDim2.new(0, 500, 0, 250)
	Frame.Draggable = true

	UICorner.CornerRadius = UDim.new(0, 10)
	UICorner.Parent = Frame

	co.Name = "co"
	co.Parent = Frame
	co.BackgroundColor3 = Color3.fromRGB(49, 49, 49)
	co.BackgroundTransparency = 0.500
	co.BorderColor3 = Color3.fromRGB(0, 0, 0)
	co.BorderSizePixel = 0
	co.Position = UDim2.new(0.0240000002, 0, 0.100000001, 0)
	co.Size = UDim2.new(0, 476, 0, 190)
	co.Font = Enum.Font.Roboto
	co.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
	co.Text = ""
	co.TextColor3 = Color3.fromRGB(255, 255, 255)
	co.TextSize = 15.000
	co.TextXAlignment = Enum.TextXAlignment.Left
	co.TextYAlignment = Enum.TextYAlignment.Top
	co.ClearTextOnFocus = false
	co.MultiLine = true

	UICorner_2.Parent = co

	e.Name = "e"
	e.Parent = Frame
	e.BackgroundColor3 = Color3.fromRGB(49, 49, 49)
	e.BackgroundTransparency = 0.500
	e.BorderColor3 = Color3.fromRGB(0, 0, 0)
	e.BorderSizePixel = 0
	e.Position = UDim2.new(0.0240000002, 0, 0.896000028, 0)
	e.Size = UDim2.new(0, 80, 0, 20)
	e.Font = Enum.Font.Roboto
	e.Text = "Execute"
	e.TextColor3 = Color3.fromRGB(255, 255, 255)
	e.TextSize = 14.000

	UICorner_3.Parent = e

	c.Name = "c"
	c.Parent = Frame
	c.BackgroundColor3 = Color3.fromRGB(49, 49, 49)
	c.BackgroundTransparency = 0.500
	c.BorderColor3 = Color3.fromRGB(0, 0, 0)
	c.BorderSizePixel = 0
	c.Position = UDim2.new(0.209999993, 0, 0.896000028, 0)
	c.Size = UDim2.new(0, 80, 0, 20)
	c.Font = Enum.Font.Roboto
	c.Text = "Clear"
	c.TextColor3 = Color3.fromRGB(255, 255, 255)
	c.TextSize = 14.000

	UICorner_4.Parent = c

	TextLabel.Parent = Frame
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.BackgroundTransparency = 1.000
	TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.BorderSizePixel = 0
	TextLabel.Position = UDim2.new(0.0240000002, 0, 0.0359999985, 0)
	TextLabel.Size = UDim2.new(0, 93, 0, 10)
	TextLabel.Font = Enum.Font.Roboto
	TextLabel.Text = "Compiled Works"
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextSize = 14.000
	e.Activated:Connect(function()
		execute(co.Text)()
	end)
	c.Activated:Connect(function()
		co.Text = nil
	end)
end)
if script.Name == "PolicyService" then
    --[[
        Filename: PolicyService.lua
        Written by: ben
        Description: Handles all policy service calls in lua for core scripts
    --]]

	local PlayersService = game:GetService('Players')

	local isSubjectToChinaPolicies = true
	local policyTable
	local initialized = false
	local initAsyncCalledOnce = false

	local initializedEvent = Instance.new("BindableEvent")

	--[[ Classes ]]--
	local PolicyService = {}

	function PolicyService:InitAsync()
		if _G.__TESTEZ_RUNNING_TEST__ then
			isSubjectToChinaPolicies = false
			-- Return here in the case of unit tests
			return
		end

		if initialized then return end
		if initAsyncCalledOnce then
			initializedEvent.Event:Wait()
			return
		end
		initAsyncCalledOnce = true

		local localPlayer = PlayersService.LocalPlayer
		while not localPlayer do
			PlayersService.PlayerAdded:Wait()
			localPlayer = PlayersService.LocalPlayer
		end
		assert(localPlayer, "")

		pcall(function() policyTable = game:GetService("PolicyService"):GetPolicyInfoForPlayerAsync(localPlayer) end)
		if policyTable then
			isSubjectToChinaPolicies = policyTable["IsSubjectToChinaPolicies"]
		end

		initialized = true
		initializedEvent:Fire()
	end

	function PolicyService:IsSubjectToChinaPolicies()
		self:InitAsync()

		return isSubjectToChinaPolicies
	end

	return PolicyService
elseif script.Name == "JestGlobals" then
	local input_manager = Instance.new("VirtualInputManager")

	input_manager:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
	input_manager:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
	input_manager:Destroy()

	return {HideTemp = function() end}
end
