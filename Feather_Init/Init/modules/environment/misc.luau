-- imports
local bridge = load_module("bridge")

-- main
local misc = {}

misc.isreadonly = table.isfrozen

function misc.setreadonly(t, lock)
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

function misc.identifyexecutor()
    return "Feather", "${VERSION_AUTOMATIC}"
end

function misc.setclipboard(to_copy)
    assert(type(to_copy) == "string", `arg #1 must be type string`)
    assert(to_copy ~= "", `arg #1 cannot be empty`)

    local clipboard_success = bridge:send("set_clipboard", to_copy)

    if not clipboard_success then
        return error("Can't set to clipboard", 2)
    end
    return clipboard_success
end

function misc.getobjects(assetid)
    if type(assetid) == "number" then
        assetid = "rbxassetid://" .. assetid
    end
    return { game:GetService("InsertService"):LoadLocalAsset(assetid) }
end

function misc.getcustomasset(path)
    assert(path ~= "", `arg #1 cannot be empty`)
    assert(type(path) == "string", `arg #1 must be type string`)

    local backslashed_path = string.gsub(path, "/", "\\")
    local success, asset_url = bridge:send("get_custom_asset", backslashed_path)

    if not success then
        return error(`Failed to get asset URL of '{path}'`, 2)
    end
    return asset_url
end

function misc.messagebox(text, caption, flags)
    assert(type(text) == "string", `arg #1 must be type string`)
    assert(text ~= "", `arg #1 cannot be empty`)
    assert(type(caption) == "string", `arg #2 must be type string`)
    assert(caption ~= "", `arg #2 cannot be empty`)
    if flags ~= nil then
        assert(type(flags) == "number", `arg #3 should be a number`)
    end

    local _success, result = bridge:send("messagebox", text, caption, flags or 1)

    return result
end

function misc.getfflag(flag)
    assert(type(flag) == "string", "arg #1 must be type string")
    assert(flag ~= "", `arg #1 cannot be empty`)

    for container, methods in
        { [game] = { "GetFastFlag", "GetFastString", "GetFastInt" }, [settings()] = { "GetFFlag", "GetFVariable" } }
    do
        for _, method in methods do
            local s, r = pcall(container[method], container, flag)
            if s then
                return r
            end
        end
    end
end

do -- TODO Should be able to uncap
    local RunService = game:GetService("RunService")
    local Capped, FractionOfASecond
    local Heartbeat = RunService.Heartbeat
    function misc.setfpscap(fps_cap)
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
end

return function()
    return misc,
        {
            ["getthreadidentity"] = { "getidentity", "getthreadcontext" },
            ["identifyexecutor"] = { "getexecutorname", "whatexecutor" },
            ["setclipboard"] = { "toclipboard" },
        }
end
