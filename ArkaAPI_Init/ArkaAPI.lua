local hookedMetaMethods = {}

function hookmetamethod(object, methodName, callback)
    local originalMeta = getmetatable(object)
    
    if originalMeta and not hookedMetaMethods[originalMeta] and originalMeta[methodName] then
        local originalMethod = originalMeta[methodName]
        
        originalMeta[methodName] = function(...)
            return callback(originalMethod, ...)
        end
        
        hookedMetaMethods[originalMeta] = true
    end
    
    return function()
        return originalMeta[methodName]
    end
end

function getnamecallmethod()
    local info = debug.getinfo(3, "nS")
    if info and info.what == "C" then
        return info.name or "unknown"
    else
        return "unknown"
    end
end

local cacheData = {}

function cache.invalidate(obj)
    if typeof(obj) == "Instance" then
        obj:Destroy()
        cacheData[obj] = nil
    else
    end
end

function cache.iscached(obj)
    if typeof(obj) == "Instance" then
        return cacheData[obj] ~= nil
    else
        return false
    end
end

function cache.replace(oldObj, newObj)
    if typeof(oldObj) == "Instance" and typeof(newObj) == "Instance" then
        if cacheData[oldObj] then
            cacheData[oldObj] = nil
            cacheData[newObj] = true
        end
    end
end

function consoleclear()
    for i = 1, 100 do
        print("\n")
    end
end

function consoledestroy()
end

function consolecreate()
end

function consoleprint(...)
    local args = {...}
    local output = ""
    for i, v in ipairs(args) do
        output = output .. tostring(v)
        if i < #args then
            output = output .. " "
        end
    end
    print("[Console]", output)
end

function consoleinput(prompt)
    prompt = prompt or "Enter input: "
    print(prompt)
    local consoleInput = io.read()
    return consoleInput
end

function getnilinstances()
    local nilInstances = {}

    local function findNilInstances(instance)
        if instance.Parent == nil then
            table.insert(nilInstances, instance)
        end

        for _, child in ipairs(instance:GetChildren()) do
            findNilInstances(child)
        end
    end

    findNilInstances(game)

    return nilInstances
end

local scriptableProperties = {}

function setscriptable(instance, property, scriptable)
    if not scriptableProperties[instance] then
        scriptableProperties[instance] = {}
    end
    
    local wasScriptable = scriptableProperties[instance][property] or false
    
    scriptableProperties[instance][property] = scriptable
    
    return wasScriptable
end

function isscriptable(instance, property)
    return scriptableProperties[instance] and scriptableProperties[instance][property] or false
end

local callbackValues = {}

function getcallbackvalue(instance, propertyName)
    if callbackValues[instance] and callbackValues[instance][propertyName] then
        return callbackValues[instance][propertyName]
    end
    return nil
end

local hookedFunctions = {}

function hookfunction(originalFunc, newFunc)
    if hookedFunctions[originalFunc] then
        return nil, "Function is already hooked"
    end
    
    local hookedFunc = function(...)
        return newFunc(...)
    end
    
    hookedFunctions[originalFunc] = hookedFunc
    
    return function()
        return originalFunc()
    end
end

function debug.getconstant(func, idx)
    if type(func) ~= "function" then
        error("Argument #1 must be a function", 2)
    end
    if type(idx) ~= "number" then
        error("Argument #2 must be a number", 2)
    end
    
    local constants = {}
    local info = debug.getinfo(func, "uS")
    
    if not info or not info.nups then
        return nil, "Function does not have constants"
    end

    local success, err = pcall(function()
        for i = 1, info.nups do
            local name, value = debug.getupvalue(func, i)
            table.insert(constants, value)
        end
    end)
    
    if not success then
        return nil, "Failed to retrieve constants: " .. err
    end

    return constants[idx] or nil
end

function debug.getconstants(func)

    if type(func) ~= "function" then
        error("Argument #1 must be a function", 2)
    end
    
    local constants = {}
    local info = debug.getinfo(func, "uS")
    
    if not info or not info.nups then
        return nil, "Function does not have constants"
    end

    local success, err = pcall(function()
        for i = 1, info.nups do
            local name, value = debug.getupvalue(func, i)
            table.insert(constants, value)
        end
    end)
    
    if not success then
        return nil, "Failed to retrieve constants: " .. err
    end

    return constants
end

function debug.getupvalue(func, index)

    if type(func) ~= "function" then
        error("Argument #1 must be a function", 2)
    end
    if type(index) ~= "number" then
        error("Argument #2 must be a number", 2)
    end

    local info = debug.getinfo(func, "u")

    if not info or index < 1 or index > info.nups then
        return nil, "Invalid index"
    end
    
    local success, name, value = pcall(function()
        return debug.getlocal(func, -index)
    end)
    
    if not success then
        return nil, "Failed to retrieve upvalue: " .. name
    end
    
    return name, value
end

function debug.getupvalues(func)
    if type(func) ~= "function" then
        error("Argument #1 must be a function", 2)
    end

    local upvalues = {}

    local index = 1
    while true do
        local name, value = debug.getupvalue(func, index)
        if not name then
            break
        end
        upvalues[name] = value
        index = index + 1
    end

    return upvalues
end

function debug.getstack(level)

    if type(level) ~= "number" then
        error("Argument #1 must be a number", 2)
    end

    local success, info = pcall(function()
        return debug.getinfo(level, "nSluf")
    end)
    
    if not success then
        return nil, "Failed to retrieve stack information: " .. info
    end

    return info
end

function replaceclosure(func, newClosure)
    local oldClosure = debug.getinfo(func, "f").func
    if type(oldClosure) ~= "function" then
        error("Cannot replace closure: provided argument is not a function")
    end
    
    debug.setupvalue(func, 1, newClosure)
    
    return oldClosure
end

function rconsolename(newName)
    if newName then
        os.execute(string.format('title %s', newName))
    else
        local handle = io.popen('title')
        local title = handle:read('*a')
        handle:close()
        return title:match("^%s*(.-)%s*$")
    end
end

function gethiddenproperty(instance, propertyName)
    if typeof(instance) ~= "Instance" then
        error("Invalid instance provided")
    end
    if type(propertyName) ~= "string" then
        error("Property name must be a string")
    end
    
    return instance:GetAttribute(propertyName)
end

function sethiddenproperty(instance, propertyName, value)
    if typeof(instance) ~= "Instance" then
        error("Invalid instance provided")
    end
    if type(propertyName) ~= "string" then
        error("Property name must be a string")
    end
    
    instance:SetAttribute(propertyName, value)
end
