local _loaded_modules = {}

local function load_module(module_name)
    local module_result = _loaded_modules[module_name]
    if module_result then
        return module_result
    end

    local path = string.split(module_name, "/")

    if #path == 2 then
        local group_name, submodule_name = unpack(path)

        local module_group = embedded_modules[group_name]
        if not group_name then
            return error(`Cannot find module group '{group_name}'.`, 2)
        end
        if not module_group[submodule_name] then
            return error(`Cannot find module '{submodule_name}' of group '{group_name}'.`, 2)
        end

        module_result = module_group[submodule_name](load_module)
    else
        module_result = embedded_modules[module_name](load_module)
    end

    _loaded_modules[module_name] = module_result
    return module_result
end

task.spawn(load_module, "init") -- loads main init script
-- loads miscellanous shenanigans based on the hooked script name
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
print("running unc")
getgenv().bit = getgenv().bit or table.clone(bit32)
local clonerefs = {}
local protecteduis = {}
local renv = {
    print, warn, error, assert, collectgarbage, load, require, select, tonumber, tostring, type, xpcall, pairs, next, ipairs,
    newproxy, rawequal, rawget, rawset, rawlen, setmetatable, PluginManager,
    coroutine.create, coroutine.resume, coroutine.running, coroutine.status, coroutine.wrap, coroutine.yield,
    bit32.arshift, bit32.band, bit32.bnot, bit32.bor, bit32.btest, bit32.extract, bit32.lshift, bit32.replace, bit32.rshift, bit32.xor,
    math.abs, math.acos, math.asin, math.atan, math.atan2, math.ceil, math.cos, math.cosh, math.deg, math.exp, math.floor, math.fmod, math.frexp, math.ldexp, math.log, math.log10, math.max, math.min, math.modf, math.pow, math.rad, math.random, math.randomseed, math.sin, math.sinh, math.sqrt, math.tan, math.tanh,
    string.byte, string.char, string.dump, string.find, string.format, string.gmatch, string.gsub, string.len, string.lower, string.match, string.pack, string.packsize, string.rep, string.reverse, string.sub, string.unpack, string.upper,
    table.concat, table.insert, table.pack, table.remove, table.sort, table.unpack,
    utf8.char, utf8.charpattern, utf8.codepoint, utf8.codes, utf8.len, utf8.nfdnormalize, utf8.nfcnormalize,
    os.clock, os.date, os.difftime, os.time,
    delay, elapsedTime, require, spawn, tick, time, typeof, UserSettings, version, wait,
    task.defer, task.delay, task.spawn, task.wait,
    debug.traceback, debug.profilebegin, debug.profileend
}


function ToEnum(a)
 for i, v in pairs(Enum.KeyCode:GetEnumItems()) do if tostring(v) == a then return v end end
end
local Instances = {}

local renderObjs={"Part","MeshPart","UnionOperation","WedgePart","CornerWedgePart","TrussPart","Model","Decal","Texture","SurfaceGui","BillboardGui","TextLabel","TextButton","ImageLabel","ImageButton","ViewportFrame","ParticleEmitter","Beam","Trail","Fire","Smoke","Sparkles","Light","SpotLight","PointLight","SurfaceLight",'Image','EditableImage', 'Text', 'Square', 'Circle', 'Triangle', 'Line'}

local keys={[0x08]=Enum.KeyCode.Backspace,[0x09]=Enum.KeyCode.Tab,[0x0C]=Enum.KeyCode.Clear,[0x0D]=Enum.KeyCode.Return,[0x10]=Enum.KeyCode.LeftShift,[0x11]=Enum.KeyCode.LeftControl,[0x12]=Enum.KeyCode.LeftAlt,[0x13]=Enum.KeyCode.Pause,[0x14]=Enum.KeyCode.CapsLock,[0x1B]=Enum.KeyCode.Escape,[0x20]=Enum.KeyCode.Space,[0x21]=Enum.KeyCode.PageUp,[0x22]=Enum.KeyCode.PageDown,[0x23]=Enum.KeyCode.End,[0x24]=Enum.KeyCode.Home,[0x2D]=Enum.KeyCode.Insert,[0x2E]=Enum.KeyCode.Delete,[0x30]=Enum.KeyCode.Zero,[0x31]=Enum.KeyCode.One,[0x32]=Enum.KeyCode.Two,[0x33]=Enum.KeyCode.Three,[0x34]=Enum.KeyCode.Four,[0x35]=Enum.KeyCode.Five,[0x36]=Enum.KeyCode.Six,[0x37]=Enum.KeyCode.Seven,[0x38]=Enum.KeyCode.Eight,[0x39]=Enum.KeyCode.Nine,[0x41]=Enum.KeyCode.A,[0x42]=Enum.KeyCode.B,[0x43]=Enum.KeyCode.C,[0x44]=Enum.KeyCode.D,[0x45]=Enum.KeyCode.E,[0x46]=Enum.KeyCode.F,[0x47]=Enum.KeyCode.G,[0x48]=Enum.KeyCode.H,[0x49]=Enum.KeyCode.I,[0x4A]=Enum.KeyCode.J,[0x4B]=Enum.KeyCode.K,[0x4C]=Enum.KeyCode.L,[0x4D]=Enum.KeyCode.M,[0x4E]=Enum.KeyCode.N,[0x4F]=Enum.KeyCode.O,[0x50]=Enum.KeyCode.P,[0x51]=Enum.KeyCode.Q,[0x52]=Enum.KeyCode.R,[0x53]=Enum.KeyCode.S,[0x54]=Enum.KeyCode.T,[0x55]=Enum.KeyCode.U,[0x56]=Enum.KeyCode.V,[0x57]=Enum.KeyCode.W,[0x58]=Enum.KeyCode.X,[0x59]=Enum.KeyCode.Y,[0x5A]=Enum.KeyCode.Z,[0x5D]=Enum.KeyCode.Menu,[0x60]=Enum.KeyCode.KeypadZero,[0x61]=Enum.KeyCode.KeypadOne,[0x62]=Enum.KeyCode.KeypadTwo,[0x63]=Enum.KeyCode.KeypadThree,[0x64]=Enum.KeyCode.KeypadFour,[0x65]=Enum.KeyCode.KeypadFive,[0x66]=Enum.KeyCode.KeypadSix,[0x67]=Enum.KeyCode.KeypadSeven,[0x68]=Enum.KeyCode.KeypadEight,[0x69]=Enum.KeyCode.KeypadNine,[0x6A]=Enum.KeyCode.KeypadMultiply,[0x6B]=Enum.KeyCode.KeypadPlus,[0x6D]=Enum.KeyCode.KeypadMinus,[0x6E]=Enum.KeyCode.KeypadPeriod,[0x6F]=Enum.KeyCode.KeypadDivide,[0x70]=Enum.KeyCode.F1,[0x71]=Enum.KeyCode.F2,[0x72]=Enum.KeyCode.F3,[0x73]=Enum.KeyCode.F4,[0x74]=Enum.KeyCode.F5,[0x75]=Enum.KeyCode.F6,[0x76]=Enum.KeyCode.F7,[0x77]=Enum.KeyCode.F8,[0x78]=Enum.KeyCode.F9,[0x79]=Enum.KeyCode.F10,[0x7A]=Enum.KeyCode.F11,[0x7B]=Enum.KeyCode.F12,[0x90]=Enum.KeyCode.NumLock,[0x91]=Enum.KeyCode.ScrollLock,[0xBA]=Enum.KeyCode.Semicolon,[0xBB]=Enum.KeyCode.Equals,[0xBC]=Enum.KeyCode.Comma,[0xBD]=Enum.KeyCode.Minus,[0xBE]=Enum.KeyCode.Period,[0xBF]=Enum.KeyCode.Slash,[0xC0]=Enum.KeyCode.Backquote,[0xDB]=Enum.KeyCode.LeftBracket,[0xDD]=Enum.KeyCode.RightBracket,[0xDE]=Enum.KeyCode.Quote}

local funcs = {}
local names = {}
local cache = {}
local blockCache = {}

local vim = Instance.new("VirtualInputManager");
local HttpService = game:GetService('HttpService');

function DescendantCount(tbl)
    local count = 0
    if type(tbl) ~= 'table' then 
        return 1 
    end
    for _, v in pairs(tbl) do
        count = count + 1
        if type(v) == 'table' then
            count = count + DescendantCount(v)
        end
    end
    return count
end


function Descendants(tbl)
    local descendants = {}
    
    local function process_table(subtbl, prefix)
        for k, v in pairs(subtbl) do
            local index = prefix and (prefix .. "." .. tostring(k)) or tostring(k)
            descendants[index] = v  -- Include the table itself
            if type(v) == 'table' then
                process_table(v, index)
            else
                descendants[index] = v
            end
        end
    end

    if type(tbl) ~= 'table' then
        descendants[tostring(1)] = tbl
    else
        process_table(tbl, nil)
    end
    
    return descendants
end

game.DescendantRemoving:Connect(function(des)
 table.insert(Instances, des)
 blockCache[des] = true
end)
game.DescendantAdded:Connect(function(des)
 cache[des] = true
end)


local Debug = loadstring(game:HttpGet('https://rawscripts.net/raw/Universal-Script-Basic-Functions-12707'))()

--[[ Libraries ]]


funcs.base64 = {}
funcs.crypt = {hex={},url={}}
funcs.syn = {}
funcs.syn_backup = {}
funcs.http = {}
funcs.Drawing = {}
funcs.cache = {}

funcs.Drawing.Fonts = {
  ['UI'] = 0,
  ['System'] = 1,
  ['Plex'] = 2,
  ['Monospace'] = 3
}
local Fonts = {
 [0] = Enum.Font.Arial,
 [1] = Enum.Font.BuilderSans,
 [2] = Enum.Font.Gotham,
 [3] = Enum.Font.RobotoMono
}

local DrawingDict = Instance.new("ScreenGui")
local ClipboardUI = Instance.new("ScreenGui")

local ClipboardBox = Instance.new('TextBox', ClipboardUI)
ClipboardBox.PlaceholderText = ''
ClipboardBox.Text = ''
ClipboardBox.ClearTextOnFocus = false
ClipboardBox.Size = UDim2.new(.1, 0, .15, 0)
ClipboardBox.Position = UDim2.new(10, 0, 10, 0)
local Queue = {}
Queue.__index = Queue

function Queue.new()
    local self = setmetatable({}, Queue)
    self.elements = {}
    return self
end
function Queue:Queue(element)
    table.insert(self.elements, element)
end

function Queue:Update()
    if #self.elements == 0 then
        return nil
    end
    return table.remove(self.elements, 1)
end

function Queue:IsEmpty()
    return #self.elements == 0
end
function Queue:Current()
    return self.elements
end
local ClipboardQueue = Queue.new()

-- [[ Functions ]]

funcs.clonefunction = function(a)
 local proxy = newproxy(true)
 local meta = getmetatable(proxy)
 meta.__call = function(_, args)
  return a(args)
 end

 meta.__tostring = function(self)
  return tostring(meta):gsub("table: ", "function: ")
 end

 meta.__len = function(self)
  return error('attempt to get length of a function value')
 end

 meta.__type = 'function'

 return setmetatable({}, meta)
end
funcs.cloneref = function(a)
    if not clonerefs[a] then clonerefs[a] = {} end
    local Clone = {}

    local mt = {__type='Instance'} -- idk if this works ;(

    mt.__tostring = function()
        return a.Name
    end

    mt.__index = function(_, key)
        local thing = a[key]
        if type(thing) == 'function' then
            return function(...)
                return thing(a, ...)
            end
        else
            return thing
        end
    end
    mt.__newindex = function(_, key, value)
     a[key] = value
    end
    mt.__metatable = 'The metatable is locked'
    mt.__len = function(self)
     return error('attempt to get length of a userdata value')
    end

    setmetatable(Clone, mt)

    table.insert(clonerefs[a], Clone)

    return Clone
end
funcs.compareinstances = function(a, b)
 if not clonerefs[a] then
  return a == b
 else
  if table.find(clonerefs[a], b) then return true end
 end
 return false
end
funcs.cache.iscached = function(thing)
 if thing:IsDescendantOf(game) and not blockCache[thing] then return true else return false end
end
funcs.cache.invalidate = function(thing)
 cache[thing] = nil
 blockCache[thing] = true
 thing.Parent = nil
end
funcs.cache.replace = function(a, b)
 cache[a] = b
 local n, p = a.Name, a.Parent
 local np = b:Clone()
 np.Parent = p np.Name = n
 a.Parent = nil
end

funcs.deepclone = function(a)
 local Result = {}
 for i, v in pairs(a) do
  if type(v) == 'table' then
    Result[i] = funcs.deepclone(v)
  end
  Result[i] = v
 end
 return Result
end
getgenv = getgenv or getfenv(2)
if getgenv().MoreUNC then return end
getgenv().MoreUNC = true
function SafeOverride(a, b, c) --[[ Index, Data, Should override ]]
 if getgenv()[a] and not c then return 1 end
 getgenv()[a] = b
 return 2
end
--[[ The base64 functions were made by https://scriptblox.com/u/yofriendfromschool1 , Credits to him.]]
funcs.base64.encode = function(data)
    local letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return letters:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
funcs.base64.decode = function(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do
            r = r .. (f % 2^i - f % 2^(i - 1) > 0 and '1' or '0')
        end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i = 1, 8 do
            c = c + (x:sub(i, i) == '1' and 2^(8 - i) or 0)
        end
        return string.char(c)
    end))
end

funcs.loadstring = loadstring
funcs.getgenv = getgenv
funcs.crypt.base64 = funcs.base64
funcs.crypt.base64encode = funcs.base64.encode
funcs.crypt.base64decode = funcs.base64.decode
funcs.crypt.base64_encode = funcs.base64.encode
funcs.crypt.base64_decode = funcs.base64.decode
funcs.base64_encode = funcs.base64.encode
funcs.base64_decode = funcs.base64.decode

funcs.crypt.hex.encode = function(txt)
 txt = tostring(txt)
 local hex = ''
 for i = 1, #txt do
    hex = hex .. string.format("%02x", string.byte(txt, i))
 end
 return hex
end
funcs.crypt.hex.decode = function(hex)
    hex = tostring(hex)
    local text = ""
    for i = 1, #hex, 2 do
        local byte_str = string.sub(hex, i, i+1)
        local byte = tonumber(byte_str, 16)
        text = text .. string.char(byte)
    end
    return text
end
funcs.crypt.url.encode = function(a)
 return game:GetService("HttpService"):UrlEncode(a)
end
funcs.crypt.url.decode = function(a)
    a = tostring(a)
    a = string.gsub(a, "+", " ")
    a = string.gsub(a, "%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
    a = string.gsub(a, "\r\n", "\n")
    return a
end
funcs.crypt.generatekey = function(optionalSize)
 local key = ''
 local a = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
 for i = 1, optionalSize or 32 do local n = math.random(1, #a) key = key .. a:sub(n, n) end
 return funcs.base64.encode(key)
end
funcs.crypt.generatebytes = function(size)
 if type(size) ~= 'number' then return error('missing arguement #1 to \'generatebytes\' (number expected)') end
 return funcs.crypt.generatekey(size)
end
--[[ Basic XOR encryption because i don't know wtf synapse uses for crypt.encrypt ]]
funcs.crypt.encrypt = function(a, b)
 local result = {}
 a = tostring(a) b = tostring(b)
 for i = 1, #a do
    local byte = string.byte(a, i)
    local keyByte = string.byte(b, (i - 1) % #b + 1)
    table.insert(result, string.char(bit32.bxor(byte, keyByte)))
 end
 return table.concat(result)
end
funcs.crypt.decrypt = funcs.crypt.encrypt
funcs.crypt.random = function(len)
 return funcs.crypt.generatekey(len)
end

local active = true
game:GetService("UserInputService").WindowFocused:Connect(function()
 active = true
end)

game:GetService("UserInputService").WindowFocusReleased:Connect(function()
 active = false
end)

funcs.isrbxactive = function()
 return active
end
funcs.isgameactive = funcs.isrbxactive
funcs.gethui = function()
 local s, H = pcall(function()
  return game:GetService("CoreGui")
 end)
 return s and H or game:GetService("Players").LocalPlayer.PlayerGui
end
if getgenv().getrenv and #getgenv().getrenv() == 0 or not getgenv().getrenv then
 getrenv = nil
 getgenv().getrenv = function() -- Override incognito's getrenv
  return renv -- couldn't think of a better way to implement it
 end
end
funcs.setclipboard = function(data)
    repeat task.wait() until ClipboardQueue:Current()[1] == data or ClipboardQueue:IsEmpty()
    ClipboardQueue:Queue(data)
    local old = game:GetService("UserInputService"):GetFocusedTextBox()
    local copy = ClipboardQueue:Current()[1]
    ClipboardBox:CaptureFocus()
    ClipboardBox.Text = copy
    
    local KeyCode = Enum.KeyCode
    local Keys = {KeyCode.RightControl, KeyCode.A}
    local Keys2 = {KeyCode.RightControl, KeyCode.C, KeyCode.V}
    
    for _, v in ipairs(Keys) do
        vim:SendKeyEvent(true, v, false, game)
        task.wait()
    end
    for _, v in ipairs(Keys) do
        vim:SendKeyEvent(false, v, false, game)
        task.wait()
    end
    for _, v in ipairs(Keys2) do
        vim:SendKeyEvent(true, v, false, game)
        task.wait()
    end
    for _, v in ipairs(Keys2) do
        vim:SendKeyEvent(false, v, false, game)
        task.wait()
    end
    ClipboardBox.Text = ''
    if old then old:CaptureFocus() end
    task.wait(.18)
    ClipboardQueue:Update()
end
funcs.syn.write_clipboard = funcs.setclipboard
funcs.toclipboard = funcs.setclipboard
funcs.writeclipboard = funcs.setclipboard
funcs.setrbxclipboard = funcs.setclipboard

funcs.isrenderobj = function(thing)
 if typeof(thing) == 'Instance' then
  return table.find(renderObjs, thing.ClassName) ~= nil
 else
  return table.find(renderObjs, thing) ~= nil
 end
end
funcs.getrenderproperty = function(thing, prop)
 local success, p = pcall(function()
  return thing[prop]
 end)
 return success and p or nil
end
funcs.setrenderproperty = function(thing, prop, val)
 local success, err = pcall(function()
  thing[prop] = val
 end)
 if not success and err then warn(err) end
end

funcs.syn.protect_gui = function(gui)
 names[gui] = {name=gui.Name,parent=gui.Parent}
 protecteduis[gui] = gui
 gui.Name = funcs.crypt.hash(funcs.crypt.random(64)) -- Hashed 64 byte string
 gui.Parent = getgenv().gethui()
end
funcs.syn.unprotect_gui = function(gui)
 if names[gui] then gui.Name = names[gui].name gui.Parent = names[gui].parent end protecteduis[gui] = nil
end
funcs.syn.protectgui = funcs.syn.protect_gui
funcs.syn.unprotectgui = funcs.syn.unprotect_gui
funcs.syn.secure_call = function(func) -- Does not do a secure call, just pcalls it.
 return pcall(func)
end


funcs.isreadonly = function(tbl)
 if type(tbl) ~= 'table' then return false end
 return table.isfrozen(tbl)
end
funcs.setreadonly = function(tbl, cond)
 if cond then
  table.freeze(tbl)
 else
  return funcs.deepclone(tbl)
 end
end
funcs.httpget = function(url)
 return game:HttpGet(url)
end
funcs.httppost = function(url, body, contenttype)
 return game:HttpPostAsync(url, body, contenttype)
end
funcs.request = function(args)
 local Body = nil
 local Timeout = 0
 local function callback(success, body)
  Body = body
  Body['Success'] = success
 end
 HttpService:RequestInternal(args):Start(callback)
 while not Body and Timeout < 10 do
  task.wait(.1)
  Timeout = Timeout + .1
 end
 return Body
end
funcs.mouse1click = function(x, y)
 x = x or 0
 y = y or 0
 vim:SendMouseButtonEvent(x, y, 0, true, game, false)
 task.wait()
 vim:SendMouseButtonEvent(x, y, 0, false, game, false)
end
funcs.mouse2click = function(x, y)
 x = x or 0
 y = y or 0
 vim:SendMouseButtonEvent(x, y, 1, true, game, false)
 task.wait()
 vim:SendMouseButtonEvent(x, y, 1, false, game, false)
end
funcs.mouse1press = function(x, y)
 x = x or 0
 y = y or 0
 vim:SendMouseButtonEvent(x, y, 0, true, game, false)
end
funcs.mouse1release = function(x, y)
 x = x or 0
 y = y or 0
 vim:SendMouseButtonEvent(x, y, 0, false, game, false)
end
funcs.mouse2press = function(x, y)
 x = x or 0
 y = y or 0
 vim:SendMouseButtonEvent(x, y, 1, true, game, false)
end
funcs.mouse2release = function(x, y)
 x = x or 0
 y = y or 0
 vim:SendMouseButtonEvent(x, y, 1, false, game, false)
end
funcs.mousescroll = function(x, y, a)
 x = x or 0
 y = y or 0
 a = a and true or false
 vim:SendMouseWheelEvent(x, y, a, game)
end
funcs.keyclick = function(key)
 if typeof(key) == 'number' then
 if not keys[key] then return error("Key "..tostring(key) .. ' not found!') end
 vim:SendKeyEvent(true, keys[key], false, game)
 task.wait()
 vim:SendKeyEvent(false, keys[key], false, game)
 elseif typeof(Key) == 'EnumItem' then
  vim:SendKeyEvent(true, key, false, game)
  task.wait()
  vim:SendKeyEvent(false, key, false, game)
 end
end
funcs.keypress = function(key)
 if typeof(key) == 'number' then
 if not keys[key] then return error("Key "..tostring(key) .. ' not found!') end
 vim:SendKeyEvent(true, keys[key], false, game)
 elseif typeof(Key) == 'EnumItem' then
  vim:SendKeyEvent(true, key, false, game)
 end
end
funcs.keyrelease = function(key)
 if typeof(key) == 'number' then
 if not keys[key] then return error("Key "..tostring(key) .. ' not found!') end
 vim:SendKeyEvent(false, keys[key], false, game)
 elseif typeof(Key) == 'EnumItem' then
  vim:SendKeyEvent(false, key, false, game)
 end
end
funcs.mousemoverel = function(relx, rely)
 local Pos = workspace.CurrentCamera.ViewportSize
 relx = relx or 0
 rely = rely or 0
 local x = Pos.X * relx
 local y = Pos.Y * rely
 vim:SendMouseMoveEvent(x, y, game)
end
funcs.mousemoveabs = function(x, y)
 x = x or 0 y = y or 0
 vim:SendMouseMoveEvent(x, y, game)
end

funcs.isexecutorclosure = function(fnc)
    for _, func2 in pairs(funcs) do if func2 == fnc then return true end end
    for _, func2 in pairs(getgenv()) do if func2 == fnc then return true end end
    for i = 1, 99 do
        local s, environment = pcall(getfenv, i)
        if not s or type(environment) ~= 'table' then
            return false
        end
        for _, val in pairs(environment) do
            if fnc == val then
                return true
            end
        end
    end
    return false
end

funcs.iscclosure = function(fnc) return debug.info(fnc, 's') == '[C]' end
funcs.islclosure = function(func) return not funcs.iscclosure(func) end
funcs.is_l_closure = funcs.islclosure
funcs.is_executor_closure = funcs.isexecutorclosure
funcs.isourclosure = funcs.isexecutorclosure
funcs.isexecclosure = funcs.isexecutorclosure

--[[ File system is something i do not know how to implement in roblox lua.
UPDATE AT 18/5/2024:
I figured out i can use temp file system with tables.
]]
local files = {}

local function startswith(a, b)
 return a:sub(1, #b) == b
end
local function endswith(hello, lo) 
    return hello:sub(#hello - #lo + 1, #hello) == lo
end

funcs.writefile = function(path, content)
 local Path = path:split('/')
 local CurrentPath = {}
 for i = 1, #Path do
  local a = Path[i]
  CurrentPath[i] = a
  if not files[a] and i ~= #Path then
   files[table.concat(CurrentPath, '/')] = {}
   files[table.concat(CurrentPath, '/') .. '/'] = files[table.concat(CurrentPath, '/')]
  elseif i == #Path then
   files[table.concat(CurrentPath, '/')] = tostring(content)
  end
 end
end
funcs.makefolder = function(path)
 files[path] = {}
 files[path .. '/'] = files[path]
end
funcs.isfolder = function(path)
 return type(files[path]) == 'table'
end
funcs.isfile = function(path)
 return type(files[path]) == 'string'
end
funcs.readfile = function(path)
 return files[path]
end
funcs.appendfile = function(path, text2)
 funcs.writefile(path, funcs.readfile(path) .. text2)
end
funcs.loadfile = function(path)
 local content = getgenv().readfile(path)
 if not content then return error('no file called ' .. tostring(path) .. ' exists.') end
 local _, func = pcall(loadstring, content)
 return func
end
funcs.delfolder = function(path)
 local f = files[path]
 if type(f) == 'table' then files[path] = nil end
end
funcs.delfile = function(path)
 local f = files[path]
 if type(f) == 'string' then files[path] = nil end
end
funcs.listfiles = function(path)
    if not path or path == '' then
     local Files = {}
     for i, v in pairs(files) do
      if #i:split('/') == 1 then table.insert(Files, i) end
     end
     return Files
    end
    if type(files[path]) ~= 'table' then return error(path .. ' is not a folder.') end
    local Files = {}
    for i, v in pairs(files) do
      if startswith(i, path .. '/') and not endswith(i, '/') and i ~= path and #i:split('/') == (#path:split('/') + 1) then table.insert(Files, i) end
    end
    return Files
end

funcs.http.request = funcs.request
funcs.syn.crypt = funcs.crypt
funcs.syn.crypto = funcs.crypt
funcs.syn_backup = funcs.syn


funcs.getexecutorname = function()
 return 'MoreUNC', '1'
end
funcs.identifyexecutor = funcs.getexecutorname
funcs.http_request = getgenv().request or funcs.request
funcs.getscripts = function()
 local a = {};for i, v in pairs(game:GetDescendants()) do if v:IsA("LocalScript") or v:IsA("ModuleScript") then table.insert(a, v) end end return a
end
funcs.get_scripts = function()
 local a = {};for i, v in pairs(game:GetDescendants()) do if v:IsA("LocalScript") or v:IsA("ModuleScript") then table.insert(a, v) end end return a
end
funcs.getmodules = function()
 local a = {};for i, v in pairs(game:GetDescendants()) do if v:IsA("ModuleScript") then table.insert(a, v) end end return a
end
funcs.getloadedmodules = funcs.getmodules
funcs.make_readonly = funcs.setreadonly
funcs.makereadonly = funcs.setreadonly
funcs.base64encode = funcs.crypt.base64encode
funcs.base64decode = funcs.crypt.base64decode
funcs.clonefunc = funcs.clonefunction
funcs.getinstances = function()
 return game:GetDescendants()
end
funcs.getnilinstances = function()
 return Instances
end
funcs.iswriteable = function(tbl)
 return not table.isfrozen(tbl)
end
funcs.makewriteable = function(tbl)
 return funcs.setreadonly(tbl, false)
end
funcs.isscriptable = function(self, prop)
 local s = pcall(function()
  self[prop] = self[prop]
 end)
 return s
end
funcs.getrunningscripts = function()
 local scripts = {}
 for _, v in pairs(funcs.getinstances()) do
  if v:IsA("LocalScript") and v.Enabled then table.insert(scripts, v) end
 end
 return scripts
end

-- SHA256 Hashing
local function str2hexa(a)return string.gsub(a,".",function(b)return string.format("%02x",string.byte(b))end)end;local function num2s(c,d)local a=""for e=1,d do local f=c%256;a=string.char(f)..a;c=(c-f)/256 end;return a end;local function s232num(a,e)local d=0;for g=e,e+3 do d=d*256+string.byte(a,g)end;return d end;local function preproc(h,i)local j=64-(i+9)%64;i=num2s(8*i,8)h=h.."\128"..string.rep("\0",j)..i;assert(#h%64==0)return h end;local function k(h,e,l)local m={}local n={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}for g=1,16 do m[g]=s232num(h,e+(g-1)*4)end;for g=17,64 do local o=m[g-15]local p=bit.bxor(bit.rrotate(o,7),bit.rrotate(o,18),bit.rshift(o,3))o=m[g-2]local q=bit.bxor(bit.rrotate(o,17),bit.rrotate(o,19),bit.rshift(o,10))m[g]=(m[g-16]+p+m[g-7]+q)%2^32 end;local r,s,b,t,u,v,w,x=l[1],l[2],l[3],l[4],l[5],l[6],l[7],l[8]for e=1,64 do local p=bit.bxor(bit.rrotate(r,2),bit.rrotate(r,13),bit.rrotate(r,22))local y=bit.bxor(bit.band(r,s),bit.band(r,b),bit.band(s,b))local z=(p+y)%2^32;local q=bit.bxor(bit.rrotate(u,6),bit.rrotate(u,11),bit.rrotate(u,25))local A=bit.bxor(bit.band(u,v),bit.band(bit.bnot(u),w))local B=(x+q+A+n[e]+m[e])%2^32;x=w;w=v;v=u;u=(t+B)%2^32;t=b;b=s;s=r;r=(B+z)%2^32 end;l[1]=(l[1]+r)%2^32;l[2]=(l[2]+s)%2^32;l[3]=(l[3]+b)%2^32;l[4]=(l[4]+t)%2^32;l[5]=(l[5]+u)%2^32;l[6]=(l[6]+v)%2^32;l[7]=(l[7]+w)%2^32;l[8]=(l[8]+x)%2^32 end;funcs.crypt.hash=function(h)h=preproc(h,#h)local l={0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19}for e=1,#h,64 do k(h,e,l)end;return str2hexa(num2s(l[1],4)..num2s(l[2],4)..num2s(l[3],4)..num2s(l[4],4)..num2s(l[5],4)..num2s(l[6],4)..num2s(l[7],4)..num2s(l[8],4))end

funcs.Drawing.new = function(Type) -- Drawing.new
    local baseProps = {
     Visible = false,
     Color = Color3.new(0,0,0),
     ClassName = nil
    }
    if Type == 'Line' then
        local a = Instance.new("Frame", Instance.new("ScreenGui", DrawingDict))
        a.Visible = false
        a.Size = UDim2.new(0, 0, 0, 0)
        a.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        a.BackgroundTransparency = 1
        a.BorderSizePixel = 0

        local meta = baseProps
        meta.ClassName = Type
        meta.__index = {
            Thickness = 1,
            From = Vector2.new(0, 0),
            To = Vector2.new(0, 0),
            Transparency = 0,
            Remove = function(a)
                a:Destroy()
            end,
            Destroy = function()
                a:Destroy()
            end,
            updateLine = function(self)
             local from = self.From
             local to = self.To
             local distance = (to - from).Magnitude
             local angle = math.deg(math.atan2(to.Y - from.Y, to.X - from.X))

             a.Size = UDim2.new(0, distance, 0, self.Thickness)
             a.Position = UDim2.new(0, from.X, 0, from.Y)
             a.Rotation = angle
            end
        }

        meta.__newindex = function(self, key, value)
            if key == 'Thickness' and typeof(value) == 'number' then
                rawset(self, key, value)
                a.Size = UDim2.new(0, (self.To - self.From).Magnitude, 0, value)
            elseif key == 'Visible' and typeof(value) == 'boolean' then
                rawset(self, key, value)
                a.Visible = value
            elseif key == 'Color' and typeof(value) == 'Color3' then
                rawset(self, key, value)
                a.BackgroundColor3 = value
            elseif key == 'Transparency' and typeof(value) == 'number' and value <= 1 then
                rawset(self, key, value)
                a.BackgroundTransparency = 1 - value
            elseif key == 'From' and typeof(value) == 'Vector2' then
                rawset(self, key, value)
                self:updateLine()
            elseif key == 'To' and typeof(value) == 'Vector2' then
                rawset(self, key, value)
                self:updateLine()
            end
        end

        return setmetatable({}, meta)
    elseif Type == 'Square' then
        local a = Instance.new("Frame", DrawingDict)
        a.Visible = false
        a.Size = UDim2.new(0, 0, 0, 0)
        a.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        a.BackgroundTransparency = 1
        a.BorderSizePixel = 0
        local b = Instance.new("UIStroke", a)
        b.Color = Color3.fromRGB(255, 255, 255)
        b.Enabled = true

        local meta = baseProps
        meta.ClassName = Type
        meta.__index = {
            Size = Vector2.new(0,0),
            Position = Vector2.new(0, 0),
            Remove = function()
                a:Destroy()
            end,
            Destroy = function()
                a:Destroy()
            end,
            updateSquare = function(self)
             a.Size = UDim2.new(0, self.Size.X, 0, self.Size.Y)
             a.Position = UDim2.new(0, self.Position.X, 0, self.Position.Y)
            end
        }

        meta.__newindex = function(self, key, value)
            if key == 'Filled' and typeof(value) == 'boolean' then
                rawset(self, key, value)
                b.Enabled = not value
                a.BackgroundTransparency = value and 0 or 1
            elseif key == 'Visible' and typeof(value) == 'boolean' then
                rawset(self, key, value)
                a.Visible = value
            elseif key == 'Color' and typeof(value) == 'Color3' then
                rawset(self, key, value)
                a.BackgroundColor3 = value
                b.Color = value
            elseif key == 'Position' and typeof(value) == 'Vector2' then
                rawset(self, key, value)
                self:updateSquare()
            elseif key == 'Size' and typeof(value) == 'Vector2' then
                rawset(self, key, value)
                self:updateSquare()
            end
        end

        return setmetatable({}, meta)
    elseif Type == 'Circle' then
        local a = Instance.new("Frame", Instance.new("ScreenGui", DrawingDict))
        a.Visible = false
        a.Size = UDim2.new(0, 0, 0, 0)
        a.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        a.BackgroundTransparency = 1
        a.BorderSizePixel = 0
        local b = Instance.new("UIStroke", a)
        b.Color = Color3.fromRGB(255, 255, 255)
        b.Enabled = false
        b.Thickness = 1
        local c = Instance.new("UICorner", a)
        c.CornerRadius = UDim.new(1, 0)

        local meta = baseProps
        meta.ClassName = Type
        meta.__index = {
            Thickness = 1,
            Filled = false,
            NumSides = 0,
            Radius = 1,
            Position = Vector2.new(0, 0),
            Transparency = 0,
            Remove = function()
                a:Destroy()
            end,
            Destroy = function()
                a:Destroy()
            end,
            updateCircle = function(self)
             a.Size = UDim2.new(0, self.Radius, 0, self.Radius)
             a.Position = UDim2.new(0, self.Position.X, 0, self.Position.Y)
             b.Enabled = not self
             b.Color = self.Color
            end
        }

        meta.__newindex = function(self, key, value)
            if key == 'Thickness' and typeof(value) == 'number' then
                rawset(self, key, value)
                b.Thickness = value
            elseif key == 'Visible' and typeof(value) == 'boolean' then
                rawset(self, key, value)
                a.Visible = value
            elseif key == 'Color' and typeof(value) == 'Color3' then
                rawset(self, key, value)
                a.BackgroundColor3 = value
                a.Color = value
            elseif key == 'Transparency' and typeof(value) == 'number' then
                rawset(self, key, value)
                a.BackgroundTransparency = 1 - value
            elseif key == 'Position' and typeof(value) == 'Vector2' then
                rawset(self, key, value)
                self:updateCircle()
            elseif key == 'Radius' and typeof(value) == 'number' then
                rawset(self, key, value)
                self:updateCircle()
            elseif key == 'NumSides' and typeof(value) == 'number' then
                rawset(self, key, value)
            elseif key == 'Filled' and typeof(value) == 'boolean' then
                rawset(self, key, value)
                self:updateCircle()
            end
        end

        return setmetatable({}, meta)
    elseif Type == 'Text' then
        local a = Instance.new("TextLabel", DrawingDict)
        a.Visible = false
        a.Size = UDim2.new(0, 0, 0, 0)
        a.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        a.BackgroundTransparency = 1
        a.BorderSizePixel = 0
        a.TextStrokeColor3 = Color3.new(0,0,0)
        a.TextStrokeTransparency = 1

        local meta = baseProps
        meta.ClassName = Type
        meta.__index = {
            Text = '',
            Transparency = 0,
            Size = 0,
            Center = false,
            Outline = false,
            OutlineColor = Color3.new(0,0,0),
            Position = Vector2.new(0,0),
            Font = 3,
            Remove = function()
                a:Destroy()
            end,
            Destroy = function()
                a:Destroy()
            end,
            updateText = function(self)
             a.TextScaled = true
             a.Size = UDim2.new(0, self.Size * 3, 0, self.Size / 2)
             a.Position = UDim2.new(0, self.Position.X, 0, self.Position.Y)
             a.Text = self.Text
             a.Font = Fonts[self.Font]
             a.Visible = self.Visible
             a.TextColor3 = self.Color
             a.TextTransparency = 1 - self.Transparency
             a.BorderSizePixel = self.Outline and 1 or 0
             if self.Center then
              a.TextXAlignment = Enum.TextXAlignment.Center
              a.TextYAlignment = Enum.TextYAlignment.Center
             else
              a.TextXAlignment = Enum.TextXAlignment.Left
              a.TextYAlignment = Enum.TextYAlignment.Top
             end
             a.TextStrokeTransparency = self.Outline and 0 or 1
             a.TextStrokeColor3 = self.OutlineColor
            end
        }

        meta.__newindex = function(self, key, value)
            if key == 'Text' and typeof(value) == 'string' then
                rawset(self, key, value)
            elseif key == 'Visible' and typeof(value) == 'boolean' then
                rawset(self, key, value)
                a.Visible = value
            elseif key == 'Color' and typeof(value) == 'Color3' then
                rawset(self, key, value)
            elseif key == 'Transparency' and typeof(value) == 'number' then
                rawset(self, key, value)
            elseif key == 'Position' and typeof(value) == 'Vector2' then
                rawset(self, key, value)
            elseif key == 'Size' and typeof(value) == 'number' then
                rawset(self, key, value)
            elseif key == 'Outline' and typeof(value) == 'boolean' then
                rawset(self, key, value)
            elseif key == 'Center' and typeof(value) == 'boolean' then
                rawset(self, key, value)
            elseif key == 'OutlineColor' and typeof(value) == 'Color3' then
                rawset(self, key, value)
            elseif key == 'Font' and typeof(value) == 'number' then
                rawset(self, key, value)
            end
            self:updateText()
        end

        return setmetatable({}, meta)
    elseif Type == 'Image' then
        local a = Instance.new("ImageLabel", DrawingDict)
        a.Visible = false
        a.Size = UDim2.new(0, 0, 0, 0)
        a.ImageColor3 = Color3.fromRGB(255,255,255)
        a.BackgroundTransparency = 1
        a.BorderSizePixel = 0

        local meta = baseProps
        meta.ClassName = 'Image'
        meta.__index = {
            Text = '',
            Transparency = 0,
            Size = Vector2.new(0, 0),
            Position = Vector2.new(0,0),
            Color = Color3.fromRGB(255, 255, 255),
            Image = '',
            Remove = function()
                a:Destroy()
            end,
            Destroy = function()
                a:Destroy()
            end,
            updateImage = function(self)
             a.Size = UDim2.new(0, self.Size.X, 0, self.Size.Y)
             a.Position = UDim2.new(0, self.Position.X, 0, self.Position.Y)
             a.Visible = self.Visible
             a.ImageColor3 = self.Color
             a.ImageTransparency = 1 - self.Transparency
             a.BorderSizePixel = self.Outline and 1 or 0
             a.Image = self.Image
            end
        }

        meta.__newindex = function(self, key, value)
            if key == 'Visible' and typeof(value) == 'boolean' then
                rawset(self, key, value)
            elseif key == 'Color' and typeof(value) == 'Color3' then
                rawset(self, key, value)
            elseif key == 'Transparency' and typeof(value) == 'number' then
                rawset(self, key, value)
            elseif key == 'Position' and typeof(value) == 'Vector2' then
                rawset(self, key, value)
            elseif key == 'Size' and typeof(value) == 'number' then
                rawset(self, key, value)
            elseif key == 'Image' and typeof(value) == 'string' then
                rawset(self, key, value)
            else
             return
            end
            self:updateImage()
        end

        return setmetatable({}, meta)
    end
end

funcs.randomstring = funcs.crypt.random
funcs.getprotecteduis = function()
 return protecteduis
end
funcs.getprotectedguis = funcs.getprotecteduis


local Count = 0
local Total = 0
for index, _ in pairs(Descendants(funcs)) do
 if not getgenv()[index] then
  Total = Total + 1
 end
end
for i, v in pairs(Descendants(funcs)) do
 if not getgenv()[i] then Count = Count + 1 end
 local Result = SafeOverride(i, v)
--  local str = Result == 1 and ('%s %s already exists.'):format(type(v), i) or Result == 2 and ("Added %s %s to the global environment. (%d/%d)"):format(type(v), i, Count, Total) or Result ~= 1 and Result ~= 2 and ("Unknown result for function %s."):format(type(v), i)
--  print(str)
end
funcs.syn.protect_gui(DrawingDict)
funcs.syn.protect_gui(ClipboardUI)