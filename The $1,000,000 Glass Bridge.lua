local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Ultimate Glass Bridge",
    SubTitle = "by Flames/Aura",
    TabWidth = 100,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

Tabs.Main:AddButton({
    Title = "Infinite Money",
    Description = "Gain infinite in-game money instantly!",
    Callback = function()
        Window:Dialog({
            Title = "Confirm Infinite Money",
            Content = "Are you sure you want to receive infinite money?",
            Buttons = {
                {
                    Title = "YES!",
                    Callback = function()
                        local args = {
                            [1] = "99999999999999"
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("CratesUtilities"):WaitForChild("Remotes"):WaitForChild("GiveReward"):FireServer(unpack(args))
                        Fluent:Notify({ Title = "Success!", Content = "Infinite money granted!", Duration = 5 })
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        Fluent:Notify({ Title = "Cancelled", Content = "Infinite money action cancelled.", Duration = 5 })
                    end
                }
            }
        })
    end
})

local HighlightGlassToggle = Tabs.Main:AddToggle("HighlightGlass", {
    Title = "Highlight Correct Glasses",
    Default = false
})

HighlightGlassToggle:OnChanged(function()
    local GlassFolder = workspace:WaitForChild("Glasses")
    if Options.HighlightGlass.Value then
        for _, glass in ipairs(GlassFolder.Wrong:GetChildren()) do
            glass.BrickColor = BrickColor.Red()
        end
        for _, glass in ipairs(GlassFolder.Correct:GetChildren()) do
            glass.BrickColor = BrickColor.Green()
        end
    else
        for _, glass in ipairs(GlassFolder.Wrong:GetChildren()) do
            glass.BrickColor = BrickColor.White()
        end
        for _, glass in ipairs(GlassFolder.Correct:GetChildren()) do
            glass.BrickColor = BrickColor.White()
        end
    end
end)

local AutoBreakGlassToggle = Tabs.Main:AddToggle("AutoBreakGlass", {
    Title = "Auto Break Glasses",
    Default = false
})

AutoBreakGlassToggle:OnChanged(function()
    if Options.AutoBreakGlass.Value then
        task.spawn(function()
            local CollectionService = game:GetService("CollectionService")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local remoteEvent = ReplicatedStorage:WaitForChild("BrokeGlassEvent_O")
            local Players = game:GetService("Players")
            local localPlayer = Players.LocalPlayer

            while Options.AutoBreakGlass.Value do
                for _, glass in pairs(CollectionService:GetTagged("wrongglass")) do
                    remoteEvent:FireServer(localPlayer, glass)
                end
                task.wait(1)
            end
        end)
    end
end)


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FeatherScriptHub")
SaveManager:SetFolder("FeatherScriptHub/Ultimate Glass Bridge")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Script Loaded",
    Content = "All features and settings loaded successfully!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
