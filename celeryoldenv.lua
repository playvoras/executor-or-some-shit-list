celeryexec = Instance.new("StringValue", game:GetService("CoreGui"))
celeryexec.Value = celerytoken
for i = 1, 10 do
local s = Instance.new("StringValue", celeryexec)
s.Name = "s"..tostring(i)
end
local out = Instance.new("StringValue", celeryexec)
out.Name = "out"
local objout = Instance.new("ObjectValue", celeryexec)
objout.Name = "objout"
for i = 1, 10 do
local sout = Instance.new("StringValue", out)
sout.Name = "sout"..tostring(i)
end
for i = 1, 10 do
local s = Instance.new("StringValue", out)
s.Name = "sin"..tostring(i)
end


local env = { renv = getfenv(), _G = _G or {}, shared = shared or {}, error = warn }
env.senv = env
local blockedThings = {}
local function InList(list, val)
for i=1, #list do
if list[i] == val then
return true
end
end
end
local envMT = {}
local blockedStorageOverride = {}
envMT.__index = function(tab, key)
if InList(blockedThings, key) then return blockedStorageOverride[key] end
return rawget(tab, key) or getfenv(0)[key]
end
envMT.__newindex = function(tab, key, val)
if InList(blockedThings, key) then
blockedStorageOverride[key] = val
else
rawset(tab, key, val)
end
end
setmetatable(env, envMT)

local function init()
function celerycmd(name, ...)
print("Function is not implemented in this version")
return nil
end

celerytoken = "

senv = env

function load_string(user_src)
for i = 1, 10 do out["sin"..tostring(i)].Value = "" end
for i = 1, 10 do
out["sout"..tostring(i)].Value = ""
end
local last, n = 1, 1
local s = 0
for i = 1, #user_src do
if s > 0x30000 then
out["sout" .. tostring(n)].Value = user_src:sub(last, i)
last = i + 1
n = n + 1
s = 0
else
s = s + 1
end
end
if s then
out["sout" .. tostring(n)].Value = user_src:sub(last, #user_src)
end
out.Value = "ls"
while out.Value == "ls" do task.wait() end
local src, rawsrc = "", "";
for i = 1, 10 do rawsrc = rawsrc .. out["sin" .. tostring(i)].Value end
src = rawsrc
local w,func = pcall(function() return luau_load(src, senv) end)
--[[if type(func) == "function" then
setfenv(func, senv)
end]]
return func
end

function getscriptbytecode(ls)
objout.Value = ls
out.Value = "gsb"
while out.Value == "ls" do task.wait() end
local src, rawsrc = "", "";
for i = 1,10 do rawsrc = rawsrc .. out["sin" .. tostring(i)].Value end
src = rawsrc
return src
end

function decompile(x)
local disassemble = loadstring(httpget("https://raw.githubusercontent.com/TheSeaweedMonster/Lua-Scripts/main/decompile.lua"))()
return disassemble(x)
end

function httpget(url)
local d,ise,Body = false,false,""
game:GetService("HttpService"):RequestInternal({Url = url,Method = "GET"}):Start(function(suc, res) if not suc then Body = res.StatusCode ise = true d=true return end Body=res.Body d=true end)
repeat task.wait() until d
if ise then error(Body, 0) end
return Body
--[[for i = 1, 10 do out["sin" .. tostring(i)].Value = "" end
out["sout1"].Value = url
out.Value = "httpget"
while out.Value == "httpget" do task.wait() end
local src, rawsrc = "", "";
for i = 1, 10 do rawsrc = rawsrc .. out["sin" .. tostring(i)].Value end
src = rawsrc
return src]]
end

function newcclosure(f)
return coroutine.wrap(f)
end

function readfile(fpath)
for i = 1, 10 do out["sin" .. tostring(i)].Value = "" end
out["sout1"].Value = fpath
out.Value = "fread"
while out.Value == "fread" do task.wait() end
local src, rawsrc = "", "";
for i = 1, 10 do rawsrc = rawsrc .. out["sin" .. tostring(i)].Value end
src = rawsrc
return src
end

function writefile(fpath, data)
for i = 1, 10 do
out["sout"..tostring(i)].Value = ""
end
local last, n = 1, 1
local s = 0
for i = 1, #data do
if s > 0x30000 then
out["sout" .. tostring(n)].Value = data:sub(last, i)
last = i + 1
n = n + 1
s = 0
else
s = s + 1
end
end
if s then
out["sout" .. tostring(n)].Value = data:sub(last, #data)
end
out["sout1"].Value = fpath
out.Value = "fwrite"
while out.Value == "fwrite" do task.wait() end
end

rawset(senv, "script", Instance.new("LocalScript"))
rawset(senv, "loadstring", load_string)
rawset(senv, "shared", shared)
rawset(senv, "_G", _G)
rawset(senv, "getsenv", function() return senv end)
rawset(senv, "getgenv", function() return getfenv(2) end)
rawset(senv, "getrenv", function() return renv end)
rawset(senv, "getscriptbytecode", getscriptbytecode)
rawset(senv, "decompile", decompile)
rawset(senv, "httpget", httpget)
rawset(senv, "newcclosure", newcclosure)
rawset(senv, "isluau", function() return false end)
rawset(senv, "readfile", readfile)
rawset(senv, "writefile", writefile)
rawset(senv, "getreg", function() return celerycmd("getreg") end)
rawset(senv, "hookfunction", function(a1, a2) return celerycmd("hookfunction", a1, a2) end)

setfenv(1, senv);

while task.wait(.1) do
if celeryexec.Value ~= celerytoken then
local src, rawsrc = "", "";
for i=1,10 do rawsrc=rawsrc..celeryexec["s"..tostring(i)].Value end
src = rawsrc
--[[for i=1,string.len(rawsrc),2 do
src=src..string.char(tonumber('0x'..rawsrc:sub(i,i+1)))
end]]
--[[local sdbg = "";
for i = 1,string.len(src) do
sdbg = sdbg .. string.format("%02X ", src:byte(i, i))
end
print(sdbg)]]
task.spawn(function()
local w,func = pcall(function() return luau_load(src, senv) end)
if type(func) == "function" then
setfenv(func, senv)
func()
elseif type(func) == "string" then
warn(func)
end
end)
celeryexec.Value = celerytoken
end
end
end

setfenv(init, env)
init()
