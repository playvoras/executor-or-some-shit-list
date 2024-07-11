-- services
local http_service = game:GetService("HttpService")

-- imports
local bridge = load_module("bridge")

-- variables
local script_env

-- functions
local httpContentTypeToHeader do
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

-- main
local http_lib = {}

function http_lib.request(options)
    assert(type(options) == "table", "arg #1 must be type table")
    local Url = options.Url
    assert(type(Url) == "string", "Url must be type string")

    local http_method = options.Method
    if http_method then
        http_method = string.upper(http_method)
        if
            not (
                { --https://github.com/MaximumADHD/Roblox-Client-Tracker/blob/04ab62513d220b3074c6433941864a705e0833f5/LuaPackages/Packages/_Index/RobloxRequests/RobloxRequests/src/session.lua#L160
                    -- Others are: TRACE, CONNECT (need testing)
                    GET = true,
                    POST = true,
                    HEAD = true,
                    OPTIONS = true,
                    PUT = true,
                    DELETE = true,
                    PATCH = true,
                }
            )[http_method]
        then
            error("Invalid Method", 2)
        end
    else
        http_method = "GET"
    end

    local http_headers = options.Headers
    -- if Headers then -- ? Should it really be our problem if someone uses a different case on the header (e.g. all lowercase)
    -- local function normalizeHeaderName(header: string): string
    --     return string.lower(header)
    -- end
    -- local function normalizeHeaders(headers)
    --     local newHeaders = {}
    --     for name, value in headers do
    --         local lowercaseName = normalizeHeaderName(name)
    --         newHeaders[lowercaseName] = value
    --     end
    --     return newHeaders
    -- end
    -- else
    if not http_headers then
        http_headers = {}
    end

    local req_body = options.Body
    if http_method == "GET" then -- ! Important for Luarmor support
        -- Headers.Playercount = tostring(#game:GetService("Players"):GetPlayers())
        -- Headers.Requester = script_env.getexecutioncontext()
        local PlaceId = game.PlaceId
        local GameId = game.JobId -- ! Not sure, things that this could be are: (RbxAnalyticsService/game).GetPlaySessionId or RbxAnalyticsService.GetSessionId

        http_headers["Roblox-Place-Id"] = tostring(PlaceId)
        http_headers["Roblox-Game-Id"] = GameId
        http_headers["Roblox-Session-Id"] = http_service:JSONEncode({
            -- Age = workspace.DistributedGameTime,
            -- BlockedPlayerIds = {},
            -- BrowserTrackerId = 0,
            -- ClientIpAddress = "1.1.1.1",
            -- CountryId = 0,
            GameId = GameId,
            -- GameJoinMetadata = { JoinSource = 0, RequestType = 0 },
            -- IsUserVoiceChatEnabled = game:GetService("VoiceChatService"):IsVoiceEnabledForUserIdAsync(game:GetService("Players").LocalPlayer.UserId),
            -- JoinType = "Specific",
            -- LanguageId = 0,
            -- Latitude = 0,
            -- Longitude = 0,
            -- MatchmakingDecisionId=null,
            PlaceId = PlaceId,
            -- PlatformTypeId = 0,
            -- PlaySessionFlags = 0,
            -- PlayerSignals = {},
            -- PolicyCountryId=null,
            -- RandomSeed2 = "",
            -- SessionId = "",
            -- SessionStarted = DateTime.fromUnixTimestamp(os.time() - workspace.DistributedGameTime):ToIsoDate(), --"1994-01-18T17: 11: 44.3095184Z",
            -- SourcePlaceId=null,
            -- SupportedLanguageId = 0,
            -- UserScoreObfuscated = 0,
            -- UserScorePublicKey = 0,
        })
    elseif http_method == "POST" or http_method == "PATCH" then -- https://github.com/MaximumADHD/Roblox-Client-Tracker/blob/master/LuaPackages/Packages/_Index/roblox_http-request/http-request/RequestFunctions/Util/getHeaders.lua
        if not http_headers["Content-Type"] then
            http_headers["Content-Type"] = "application/json"
        end

        if req_body and type(req_body) == "table" then
            req_body = http_service:JSONEncode(req_body)
        end
    end

    local client_id = game:GetService("RbxAnalyticsService"):GetClientId() -- TODO Find something better

    http_headers["User-Agent"] = table.concat({ script_env.identifyexecutor() }, "/")

    http_headers["Feather-Fingerprint"] = client_id
    http_headers["Feather-User-Identifier"] = client_id

    local params =
        { -- https://github.com/MaximumADHD/Roblox-Client-Tracker/blob/master/LuaPackages/Packages/_Index/HttpRequest/HttpRequest/RequestFunctions/RequestInternal.lua#L6
            Url = Url,
            Method = http_method, -- GET, POST, PATCH, PUT (DEFAULT: GET)

            Body = req_body,
            Headers = http_headers,
            Cookies = options.Cookies, -- Does this even work
        }
    local success, response = bridge:send("http_request", params)

    if not success then
        return error(`Failed to fetch URL '{Url}'`, 2)
    end
    return response
end

function http_lib.get(url, arg2, arg3) -- Must be compatible with params from HttpGet, HttpGetAsync, HttpService.GetAsync
    assert(type(url) == "string", `arg #1 must be type string`)
    assert(url ~= "", `arg #1 cannot be empty`)

    local args = {
        Method = "GET", -- Unneccessary, GET is DEFAULT
        Url = url,
    }

    local arg3_type = typeof(arg3)

    if arg3_type == "table" then -- HttpService.GetAsync
        args.Headers = arg3 --? In docs they are Variant though what other types does that imply ?
    elseif arg3_type == "EnumItem" and arg3.EnumType == Enum.HttpRequestType then -- HttpGet
        arg2 = arg3 -- because arg2 likely means 'synchronous' in this case and we don't need it
    end

    local arg2_type = typeof(arg2)

    if arg2_type == "boolean" then
        if arg2 then
            local Headers = args.Headers
            if not Headers then
                Headers = {}
                args.Headers = Headers
            end

            -- ! Roblox forces this anyway (regardless of this); So CachePolicy might be a good alternative if we figure out how it works
            Headers["Cache-Control"] = "no-cache" -- https://github.com/MaximumADHD/Roblox-Client-Tracker/blob/2719f6e1b2efba579994c0c5d762c6eed2cd5db0/LuaPackages/Packages/_Index/HttpServiceMock/HttpServiceMock/HttpServiceMock.lua#L97
        end
    end

    return http_lib.request(args).Body
end

function http_lib.post(url, data, arg3, arg4, arg5) -- Must be compatible with params from HttpPost, HttpPostAsync, HttpService.PostAsync
    assert(type(url) == "string", `arg #1 must be type string`)
    assert(url ~= "", `arg #1 cannot be empty`)

    local args = {
        Method = "POST",
        Url = url,
        Body = data,
    }

    if type(arg3) == "boolean" then -- HttpGet
        arg3, arg4, arg5 = arg4, arg5, nil -- because arg3 likely means 'synchronous' in this case and we don't need it
    end

    if arg5 then -- HttpService.PostAsync
        args.Headers = arg3 --? In docs they are Variant though what other types does that imply ?
    end

    if arg3 then
        local Headers = args.Headers
        if not Headers then
            Headers = {}
            args.Headers = Headers
        end

        Headers["Content-Type"] = if type(arg3) == "string" then arg3 else httpContentTypeToHeader(arg3) -- https://github.com/MaximumADHD/Roblox-Client-Tracker/blob/2719f6e1b2efba579994c0c5d762c6eed2cd5db0/LuaPackages/Packages/_Index/HttpServiceMock/HttpServiceMock/HttpServiceMock.lua#L151
    end

    local arg4_type = typeof(arg4)

    if arg4_type == "boolean" then -- HttpService.PostAsync
        if arg4 then -- compress
            local Headers = args.Headers
            if not Headers then
                Headers = {}
                args.Headers = Headers
            end

            Headers["Content-Encoding"] = "gzip" -- https://github.com/MaximumADHD/Roblox-Client-Tracker/blob/2719f6e1b2efba579994c0c5d762c6eed2cd5db0/LuaPackages/Packages/_Index/HttpServiceMock/HttpServiceMock/HttpServiceMock.lua#L147
        end
    end

    return http_lib.request(args).Body
end

return function(_script_env)
    script_env = _script_env

    return {
        ["http"] = http_lib,
        ["request"] = http_lib.request,
        ["httpget"] = http_lib.get,
        ["httppost"] = http_lib.post
    }, {
        ["request"] = {"http_request"}
    }
end