local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Stepped = RunService.Stepped
local Player = Players.LocalPlayer

local Data = Player:WaitForChild("Data")
local Level = Data:WaitForChild("Level")
local Fragments = Data:WaitForChild("Fragments")

local Map = workspace:WaitForChild("Map")
local NPCs = workspace:WaitForChild("NPCs")
local Boats = workspace:WaitForChild("Boats")
local SeaBeasts = workspace:WaitForChild("SeaBeasts")
local EnemiesFolder = workspace:WaitForChild("Enemies")
local Characters = workspace:WaitForChild("Characters")
local WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local Locations = WorldOrigin:WaitForChild("Locations")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")

local _ENV = (getgenv or getrenv or getfenv)()
local HttpGet = game.HttpGet

local clonedEnabled = {}
local Functions = _ENV.rz_Functions or {}
local FarmFunctions = _ENV.rz_FarmFunctions or {}

local Settings = _ENV.rz_Settings or {
  AutoBuso = true,
  BringMobs = true,
  BringDistance = 250,
  FarmTool = "Melee",
  skillSelected = {},
  boatSelected = {},
  fishSelected = {}
}

local Enabled = _ENV.rz_EnabledOptions or setmetatable({}, {
  __newindex = function(self, index, value)
    rawset(clonedEnabled, index, value or nil)
    
    table.clear(FarmFunctions)
    for _, func in ipairs(Functions) do
      if rawget(clonedEnabled, func.Name) then
        table.insert(FarmFunctions, func.Function)
      end
    end
  end,
  __index = clonedEnabled
})

do
  local PlayerGui = Player.PlayerGui
  
  if not PlayerGui:FindFirstChild("Main") then
    while PlayerGui.ChildAdded:Wait().Name ~= "Main" do end
  end
end

_ENV.rz_Functions = Functions
_ENV.rz_Settings = Settings
_ENV.rz_EnabledOptions = Enabled
_ENV.rz_FarmFunctions = FarmFunctions

local Library = nil
local Module = nil

local PlayerTP = nil
local Tween = nil

local RedeemCodes = function()
  local success, codes = pcall(function()
    return HttpGet(game, "https://raw.githubusercontent.com/realredz/BloxFruits/refs/heads/main/Codes.txt")
  end)
  
  if success and codes then
    for _, code in ipairs(codes:gsub("\n", ""):split(" ")) do
      ReplicatedStorage.Remotes.Redeem:InvokeServer(code)
    end
  end
end

local NoFog = function()
  local LightingLayers = Lighting:FindFirstChild("LightingLayers")
  if LightingLayers then
    LightingLayers:Remove()
  end
end

local TradeBones = function()
  if Module:GetMaterial("Bones") >= 50 then
    Module:FireRemote("Bones", "Buy", 1, 1)
  end
end

local JoinTeam = {
  Marines = function() Module.FireRemote("SetTeam", "Marines") end,
  Pirates = function() Module.FireRemote("SetTeam", "Pirates") end
}

local Loader = {}

Loader.Modules = {} do
  local Modules = Loader.Modules
  
  local Tween = loadstring([[
    local module = {}
    module.__index = module
    
    local TweenService = game:GetService("TweenService")
    
    local tweens = {}
    local EasingStyle = Enum.EasingStyle.Linear
    
    function module.new(obj, time, prop, value)
      local self = setmetatable({}, module)
      
      self.tween = TweenService:Create(obj, TweenInfo.new(time, EasingStyle), { [prop] = value })
      self.tween:Play()
      self.value = value
      self.object = obj
      
      if tweens[obj] then
        tweens[obj]:destroy()
      end
      
      tweens[obj] = self
      return self
    end
    
    function module:destroy()
      self.tween:Pause()
      self.tween:Destroy()
      
      tweens[self.object] = nil
      setmetatable(self, nil)
    end
    
    function module:stop(obj)
      if tweens[obj] then
        tweens[obj]:destroy()
      end
    end
    
    return module
  ]])()
  
  Modules.PlayerTeleport = function()
    local module = {
      lastCF = nil,
      lastTP = 0,
      nextNum = 1,
      BypassCooldown = 0,
      islands = ({
        {
          ["Sky Island 1"] = Vector3.new(-4652, 873, -1754),
          ["Sky Island 2"] = Vector3.new(-7895, 5547, -380),
          ["Under Water Island"] = Vector3.new(61164, 15, 1820),
          ["Under Water Island Entrace"] = Vector3.new(3865, 20, -1926)
        },
        {
          ["Flamingo Mansion"] = Vector3.new(-317, 331, 597),
          ["Flamingo Room"] = Vector3.new(2283, 15, 867),
          ["Cursed Ship"] = Vector3.new(923, 125, 32853),
          ["Zombie Island"] = Vector3.new(-6509, 83, -133)
        },
        {
          ["Mansion"] = Vector3.new(-12464, 376, -7566),
          ["Hydra Island"] = Vector3.new(5651, 1015, -350),
          -- ["Beautiful Pirate"] = Vector3.new(5369, 25, -497),
          ["Temple of Time"] = Vector3.new(28286, 14897, 103),
          -- ["Floating Turtle"] = Vector3.new(-11994, 332, -9027),
          ["Castle on the Sea"] = Vector3.new(-5090, 319, -3146),
          ["Great Tree"] = Vector3.new(2953, 2282, -7217)
        }
      })[Module.Sea]
    }
    
    local setDebounce = function(value)
      module.NpcDebounce = value
    end
    
    local IsAlive = Module.IsAlive
    local FireRemote = Module.FireRemote
    
    function module:talkNpc(cframe, action, ...)
      if Player:DistanceFromCharacter(cframe.Position) < 5 then
        if type(action) == "function" then
          action()
        else
          FireRemote(action, ...)
        end
      end
    end
    
    function module:GetNearestPortal(pos1)
      local distance, topos, iName = math.huge
      for name, pos2 in pairs(self.islands) do
        local Mag = (pos1 - pos2).Magnitude
        if Mag < distance then
          distance, topos, iName = Mag, pos2, name
        end
      end
      return topos, iName
    end
    
    function module:TeleportToGreatTree()
      self.new(CFrame.new(28610, 14897, 105), nil, true)
      self:talkNpc(CFrame.new(28610, 14897, 105), "RaceV4Progress", "TeleportBack")
    end
    
    function module:NPCs(locations, speed)
      if self.NpcDebounce or not IsAlive(Player.Character) then return end
      
      local PrimaryPart = Player.Character.PrimaryPart
      
      if #locations == 1 then
        self.new(locations[1], speed)
      elseif #locations > 1 then
        if self.nextNum > #locations then
          self.nextNum = 1
        end
        
        local cframe = locations[self.nextNum]
        
        if (PrimaryPart.Position - cframe.Position).Magnitude < 5 then
          self.nextNum = self.nextNum + 1
          self.NpcDebounce = true
          task.delay(1, setDebounce, false)
        else
          self.new(cframe, speed)
        end
      end
    end
    
    function module.new(cframe, speed, noLog)
      local self = module
      
      if (tick() - self.lastTP) < 1 and cframe == self.lastCF then
        return nil
      end
      
      self.lastTP = tick()
      self.lastCF = cframe
      
      if not IsAlive(Player.Character) then return end
      if not noLog then self.lastPosition = cframe.Position end
      
      local PrimaryPart = Player.Character.PrimaryPart
      local tSpeed = Settings.TweenSpeed or 180
      local tPosition = cframe.Position
      
      local Distance = (PrimaryPart.Position - tPosition).Magnitude
      local Portal, pName = self:GetNearestPortal(tPosition)
      local PortalMag = Portal and ((tPosition - Portal).Magnitude + 300)
      
      if Portal and (tick() - self.BypassCooldown) >= 10 and Distance > PortalMag then
        if pName == "Great Tree" then
          self:TeleportToGreatTree()
        else
          Tween:stop(PrimaryPart)task.wait(0.2)
          
          if (tPosition - Portal).Magnitude < 50 then
            Portal = tPosition
          else
            Portal = Portal + ((tPosition - PrimaryPart.Position).Unit) * 40
          end
          
          local oldPosition = PrimaryPart.Position
          PrimaryPart.CFrame = CFrame.new(Portal)
        
          if task.wait(0.8) and (PrimaryPart.Position - oldPosition).Magnitude < 15 then
            self.BypassCooldown = tick()
          end
        end
      else
        if Distance < 150 then
          Tween:stop(PrimaryPart)
          PrimaryPart.CFrame = cframe
        elseif speed then
          Tween.new(PrimaryPart, Distance / speed, "CFrame", cframe)
        else
          local blockPos = PrimaryPart.Position
          local yPos = CFrame.new(blockPos.X, tPosition.Y, blockPos.Z)
          
          if (blockPos - yPos.Position).Magnitude > 75 then
            Tween:stop(PrimaryPart)task.wait(0.1)
            PrimaryPart.CFrame = yPos
            task.wait(0.5)
          end
          if Distance < 450 then
            Tween.new(PrimaryPart, Distance / tSpeed * 1.8, "CFrame", cframe)
          else
            Tween.new(PrimaryPart, Distance / tSpeed, "CFrame", cframe)
          end
        end
      end
    end
    
    Module.Tween:GetPropertyChangedSignal("Parent"):Connect(function()
      if not Module.Tween.Parent and IsAlive(Player.Character) then
        Tween:stop(Player.Character.PrimaryPart)
      end
    end)
    
    PlayerTP = module.new
    return module
  end
  
  Modules.QuestManager = function()
    local module = {
      QuestList = {},
      EnemyList = {},
      QuestPos = {},
      
      Sea = Module.Sea,
      takeQuestDebounce = false,
      _Position = CFrame.new(0, 0, 1)
    }
    
    local QuestFrame = Player.PlayerGui.Main.Quest
    local QuestTitle = QuestFrame.Container.QuestTitle.Title
    
    local GuideModule = require(ReplicatedStorage:WaitForChild("GuideModule"))
    local QuestModule = require(ReplicatedStorage:WaitForChild("Quests"))
    
    local EnemyPos = Module.EnemyLocations
    local Enemies = Module.EnemySpawned
    local IsBoss = Module.IsBoss
    
    local getTasks = function(Mission)
      local Enemies, Position = {}, nil
      for Enemie,_ in next, Mission.Task do
        table.insert(Enemies, Enemie)
        if not Position then
          Position = EnemyPos[Enemie]
        end
      end
      return Enemies, Position
    end
    
    task.spawn(function()
      for _,Npc in next, GuideModule.Data.NPCList do
        module.QuestPos[Npc.NPCName] = CFrame.new(Npc.Position)
      end
    end)
    
    task.spawn(loadstring([[
      local self, QuestsModule, getTasks = ...
      
      local MaxLvl = ({ {0, 700}, {700, 1500}, {1500, math.huge} })[self.Sea]
      local bl_Quests = {"BartiloQuest", "MarineQuest", "CitizenQuest"}
      
      for name, task in QuestsModule do
        if table.find(bl_Quests, name) then continue end
        
        for num, mission in task do
          local Level = mission.LevelReq
          if Level >= MaxLvl[1] and Level < MaxLvl[2] then
            local target, positions = getTasks(mission)
            table.insert(self.QuestList, {
              Name = name,
              Count = num,
              Enemy = { Name = target, Level = Level, Position = positions }
            })
          end
        end
      end
      
      table.sort(self.QuestList, function(v1, v2) return v1.Enemy.Level < v2.Enemy.Level end)
    ]]), module, QuestModule, getTasks)
    
    function module:GetQuest()
      if self.oldLevel == Level.Value and self.CurrentQuest and (not self.oldBoss or Module.IsSpawned(self.oldBoss)) then
        return self.CurrentQuest
      end
      
      local oldBoss = nil;
      local oldQuest = nil;
      
      self.oldLevel = Level.Value
      
      for _,Quest in ipairs(self.QuestList) do
        local level = Quest.Enemy.Level
        local name = Quest.Enemy.Name
        
        if level > Level.Value then
          self.oldBoss, self.CurrentQuest = oldBoss, oldQuest
          return oldQuest
        end
        
        if IsBoss(name[1]) then
          if Module.IsSpawned(name[1]) then
            oldBoss, oldQuest = name[1], Quest
          end
        else
          oldQuest = Quest
        end
      end
      
      self.oldBoss, self.CurrentQuest = oldBoss, oldQuest
      return oldQuest
    end
    
    function module:GetQuestPosition()
      return self.QuestPos[GuideModule.Data.LastClosestNPC]
    end
    
    function module:VerifyQuest(query)
      if not QuestFrame.Visible then
        return false
      end
      
      local Title = string.gsub(QuestTitle.Text, "-", ""):lower()
      
      if type(query) == "string" then
        return string.find(Title, string.gsub(query, "-", ""):lower())
      end
      
      for _,Enemy in ipairs(query) do
        if string.find(Title, string.gsub(Enemy, "-", ""):lower()) then
          return Enemy
        end
      end
    end
    
    function module:StartQuest(quest, index, cframe)
      if cframe and Player:DistanceFromCharacter(cframe.Position) >= 5 then
        return PlayerTP(cframe * self._Position)
      end
      
      if self.takeQuestDebounce then
        if self.Debounce and (tick() - self.Debounce) >= 60 then
          return nil
        end
        self.Debounce = tick()
      end
      
      task.wait(0.5) Module.FireRemote("StartQuest", quest, index) task.wait(0.5)
    end
    
    return module
  end
  
  Modules.FarmManager = function()
    local module = {
      canFarm = {},
      EnemyLocation = {},
      
      Position = Vector3.new(0, 15, 0),
      -- Distance = 15
    }
    
    module.Materials = ({
      {"Leather + Scrap Metal", "Magma Ore", "Fish Tail", "Angel Wings"},
      {"Leather + Scrap Metal", "Magma Ore", "Mystic Droplet", "Radiactive Material", "Vampire Fang"},
      {"Leather + Scrap Metal", "Fish Tail", "Gunpowder", "Mini Tusk", "Conjured Cocoa", "Dragon Scale"}
    })[Module.Sea]
    
    module.Enemies = {
      Elites = {"Deandre", "Diablo", "Urban"},
      Bones = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"},
      Katakuri = {"Head Baker", "Baking Staff", "Cake Guard", "Cookie Crafter"},
      Ectoplasm = {"Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer"}
    }
    
    local Enemies = Module.EnemySpawned
    
    local MaterialDetails = {
      ["Leather + Scrap Metal"] = {{"Pirate", "Brute", "Scrap Metal", "Pirate Millionaire"}, {true, true, true}},
      ["Angel Wings"] = {{"Royal Soldier", "Royal Squad"}, {true}},
      ["Magma Ore"] = {{"Military Soldier", "Lava Pirate"}, {true, true}},
      ["Fish Tail"] = {{"Fishman Warrior", "Fishman Captain", "Fishman Raider"}, {true, false, true}},
      ["Conjured Cocoa"] = {{"Cocoa Warrior", "Chocolate Bar Battler"}, {false, false, true}},
      ["Mystic Droplet"] = {{"Water Fighter"}, {false, true}},
      ["Radiactive Material"] = {{"Factory Staff"}, {false, true}},
      ["Vampire Fang"] = {{"Vampire"}, {false, true}},
      ["Gunpowder"] = {{"Pistol Billionaire"}, {false, false, true}},
      ["Mini Tusk"] = {{"Mythological Pirate"}, {false, false, true}},
      ["Dragon Scale"] = {{"Dragon Crew Archer"}, {false, false, true}}
    }
    
    local EnemyPos = Module.EnemyLocations
    local EquipTool = Module.EquipTool
    
    local sTool = nil;
    local sToolDb = tick()
    
    function module.sToolTip(tool)
      sToolDb, sTool = tick(), tool
    end
    
    function module.attack(Enemy, bring, multBring)
      local Humanoid = Enemy:FindFirstChild("Humanoid")
      local PrimaryPart = Enemy.PrimaryPart
      
      if Enabled.Mastery and Humanoid then
        Module.AttackCooldown = tick()
        
        if Humanoid.Health / Humanoid.MaxHealth * 100 > Settings.mHealth then
          EquipTool("Melee", true)
        else
          EquipTool(Settings.mTool, true)
        end
        
        local Equipped = EquipTool.Equipped
        
        if Equipped and Equipped.ToolTip ~= "Blox Fruit" then
          Equipped:Activate()
        end
        
        Module.Hooking:SetTarget(PrimaryPart)
        PlayerTP(PrimaryPart.CFrame + module.Position)
        if bring then Module:BringEnemies(Enemy, multBring) end
        
        EnableBuso()
        
        return nil
      end
      
      PlayerTP(PrimaryPart.CFrame + module.Position)
      if bring then Module:BringEnemies(Enemy, multBring) end
      
      EnableBuso()
      
      if (tick() - sToolDb) < 1 and sTool then
        EquipTool(sTool, true)
      else
        EquipTool()
      end
    end
    
    function module.attackByName(Name, ...)
      local Enemy = Enemies(Name)
      if Enemy and Enemy.PrimaryPart then
        module.attack(Enemy, true)
        return true
      end
    end
    
    function module.attackPosition(cframe)
      PlayerTP(cframe)EnableBuso()EquipTool()
    end
    
    function module.Material(Name)
      local self = module
      
      local details = MaterialDetails[Name]
      
      if self.canFarm[Name] == nil then
        if details[2][Module.Sea] then
          self.canFarm[Name] = true
        else
          self.canFarm[Name] = false
        end
      end
      
      if not self.canFarm[Name] then
        return nil
      end
      
      if not self.EnemyLocation[Name] then
        for _,Enemy in next, details[1] do
          local Locations = EnemyPos[Enemy] 
          if Locations and #Locations > 0 then
            self.EnemyLocation[Name] = Locations
            break
          end
        end
      end
      
      local Enemy = Enemies(details[1])
      if Enemy then
        self.attack(Enemy, true)
      elseif self.EnemyLocation[Name] then
        Modules.PlayerTeleport:NPCs(self.EnemyLocation[Name])
      end
    end
    
    return module
  end
  
  Modules.RaidManager = function()
    if Module.Sea ~= 2 and Module.Sea ~= 3 then
      return nil
    end
    
    local module = {
      RaidPosition = Module.Sea == 2 and nil or CFrame.new(-5033, 315, -2950),
      requests = {},
      Require = 0,
      Timer = Player.PlayerGui.Main.Timer,
      Button = (
        (Module.Sea == 2 and Map.CircleIsland.RaidSummon2.Button) or
        (Module.Sea == 3 and Map["Boat Castle"].RaidSummon2.Button)
      )
    }
    
    function module:IsRaiding()
      return Enabled.Raid and Player:GetAttribute("IslandRaiding")
    end
    
    function module:GetRaidIsland()
      return Module:GetRaidIsland()
    end
    
    function module:CanStartRaid()
      return Level.Value >= 1200 and VerifyTool("Special Microchip")
    end
    
    function module:start()
      if not self:IsRaiding() and self:CanStartRaid() then
        if not self.Button:FindFirstChild("Main") then
          return PlayerTP(self.RaidPosition)
        end
        
        fireclickdetector(self.Button.Main.ClickDetector)
        task.wait(1)
      end
    end
    
    function module:requestFragment(tag, amount)
      if self.requests[tag] then
        return nil
      end
      
      self.Require = self.Require + (amount or 0)
    end
    
    return module
  end
  
  Modules.IslandManager = function()
    local module = {}
    
    function module:GetMirageFruitDealer()
      if self.MirageFruitDealer then
        return self.MirageFruitDealer
      end
      
      local FruitDealer = NPCs:FindFirstChild("Advanced Fruit Dealer")
        or ReplicatedStorage.NPCs:FindFirstChild("Advanced Fruit Dealer")
      
      if FruitDealer then
        self.MirageFruitDealer = FruitDealer
        return FruitDealer
      end
    end
    
    function module:GetMirageGear(Mirage)
      if self.MirageGear and self.MirageGear.Parent then
        return self.MirageGear
      end
      
      for _, Gear in ipairs(Mirage:GetChildren()) do
        if Gear:IsA("MeshPart") and Gear.MeshId == "rbxassetid://10153114969" then
          self.MirageGear = Gear
          return Gear
        end
      end
    end
    
    function module:GetMirageTop(Mirage)
      if self.MirageTop and self.MirageTop.Parent then
        return self.MirageTop
      end
      
      for _,part in ipairs(Mirage:GetChildren()) do
        local top = part:FindFirstChild("dbz_map1_Cube.012")
        if top then
          self.MirageTop = top
          return top
        end
      end
    end
    
    return module
  end
  
  Modules.EspManager = function()
    local module = {}
    module.__index = module
    module.__newindex = function(self, index, value)
      if index == "Enabled" then
        return task.spawn(self.toggle, self, value)
      end
      return rawset(self, index, value)
    end
    
    local GetBasePart = function(Obj)
      if Obj:FindFirstChild("Humanoid") then
        return Obj.PrimaryPart or Obj
      elseif Obj:FindFirstChild("Handle") then
        return Obj.Handle
      end
      return Obj
    end
    
    local remove = function(self)
      if self.Object and self.Section.List[self.Object] then
        self.Section.List[self.Object] = nil
      end
      if self.EspHandle then
        self.EspHandle:Destroy()
      end
    end
    
    local FruitsName = Module.FruitsName
    local HumHealth = "%s<font color='rgb(160, 160, 160)'> [ %im ]</font>\n<font color='rgb(25, 240, 25)'>[%i/%i]</font>"
    
    local EspFolder = Instance.new("Folder", CoreGui)
    EspFolder.Name = "rz_EspFolder"
    
    local folderFind = CoreGui:FindFirstChild(EspFolder.Name)
    if folderFind and folderFind ~= EspFolder then
      folderFind:Destroy()
    end
    
    function module.new(name, instance, func2)
      local self = setmetatable({}, module)
      
      local Folder = Instance.new("Folder", EspFolder)
      Folder.Name = name
      
      self.List = {}
      self.Name = name
      self.Folder = Folder
      self.Instance = instance
      self.IsEspObject = func2
      
      return self
    end
    
    function module:clear()
      self.Folder:ClearAllChildren()
      table.clear(self.List)
    end
    
    function module:add(obj, color, name)
      if self.List[obj] then
        return nil
      end
      
      local Esp = {
        Section = self,
        Color = color or Color3.fromRGB(255, 255, 255),
        Name = name or obj.Name,
        Object = obj,
        EspHandle = nil
      }
      
      self.List[obj] = Esp
      
      local BHA = Instance.new("BoxHandleAdornment")
      BHA.Size = Vector3.new(1, 0, 1, 0)
      BHA.AlwaysOnTop = true
      BHA.ZIndex = 10
      BHA.Transparency = 0
      
      local BBG = Instance.new("BillboardGui")
      BBG.Adornee = obj
      BBG.Size = UDim2.new(0, 100, 0, 150)
      BBG.StudsOffset = Vector3.new(0, 2, 0)
      BBG.AlwaysOnTop = true
      
      local TL = Instance.new("TextLabel")
      TL.BackgroundTransparency = 1
      TL.Position = UDim2.new(0, 0, 0, -50)
      TL.Size = UDim2.new(0, 100, 0, 100)
      TL.TextSize = 10
      TL.TextColor3 = Esp.Color
      TL.TextStrokeTransparency = 0
      TL.TextYAlignment = Enum.TextYAlignment.Bottom
      TL.Text = "..."
      TL.ZIndex = 15
      TL.RichText = true
      
      TL.Parent = BBG
      BBG.Parent = BHA
      BHA.Parent = self.Folder
      Esp.EspHandle = BHA
      
      local stepped
      stepped = Stepped:Connect(function()
        if not obj or not BHA then
          stepped:Disconnect()
          return remove(Esp)
        end
        
        local BasePart = GetBasePart(obj)
        
        if not BasePart or not BasePart:IsA("BasePart") then
          stepped:Disconnect()
          return remove(Esp)
        end
        
        local Distance = math.floor((Player:DistanceFromCharacter(BasePart.Position)) / 5)
        
        local Humanoid = obj:FindFirstChild("Humanoid")
        if Humanoid then
          TL.Text = HumHealth:format(name or obj.Name, Distance, math.floor(Humanoid.Health), math.floor(Humanoid.MaxHealth))
        elseif obj:FindFirstChild("Handle") then
          TL.Text = ("%s < %i >"):format(FruitsName[obj], Distance)
        else
          TL.Text = ("%s < %i >"):format(name or obj.Name, Distance)
        end
      end)
    end
    
    function module:toggle(value)
      local name = "Esp" .. self.Name
      _ENV[name] = value
      
      local instance = self.Instance
      local isEspObject = self.IsEspObject
      
      while _ENV[name] do
        for _,child in next, instance:GetChildren() do
          local isObj, Color, Name = isEspObject(child)
          if isObj then
            self:add(child, Color, Name)
          end
        end
        task.wait(0.25)
      end
      
      self:clear()
    end
    
    return module
  end
  
  Modules.SeaManager = function()
    local module = {
      nextNum = 1,
      oldTool = "Melee",
      randomNumber = 1,
      toolDebounce = 0,
      rdDebounce = 0,
      SeaEvents = {}
    }
    
    module.nextTool = {
      ["Melee"] = "Blox Fruit",
      ["Blox Fruit"] = "Sword",
      ["Sword"] = "Gun",
      ["Gun"] = "Melee"
    }
    
    module.BuyBoat = {
      Position = (Module.Sea == 2 and CFrame.new(94, 10, 2951)) or CFrame.new(-6123, 16, -2247),
      BoatName = "Guardian"
    }
    
    module.RandomPosition = ({
      false,
      {
        CFrame.new(-43, 21, 5054),
        CFrame.new(1744, 21, 4393),
        CFrame.new(1003, 21, 3598),
        CFrame.new(-935, 21, 3813)
      },
      {
        ["inf"] = -100000000,
        ["6"] = -42700,
        ["5"] = -38000,
        ["4"] = -34000,
        ["3"] = -30000,
        ["2"] = -26000,
        ["1"] = -22000
      }
    })[Module.Sea]
    
    module.Directions = {
      Vector3.new(60, 0, 0),
      Vector3.new(0, 0, 60),
      Vector3.new(-60, 0, 0),
      Vector3.new(0, 0, -60),
      Vector3.new(0, 0, 0)
    }
    
    module.SeaEventsName = {
      Terrorshark = true,
      Piranha = true,
      Shark = true,
      ["Fish Crew Member"] = true
    }
    
    module.SeaBoatsName = {
      PirateGrandBrigade = true,
      PirateBrigade = true,
      FishBoat = true
    }
    
    local UseSkills = Module.UseSkills
    local EquipTool = Module.EquipTool
    local FireRemote = Module.FireRemote
    local Humanoid = nil;
    
    if Module.Sea == 3 then
      local Random = module.RandomPosition
      
      for Level, Distance in pairs(Random) do
        Random[Level] = {
          CFrame.new(Distance, 21, 500),
          CFrame.new(Distance - 3000, 21, 500),
          CFrame.new(Distance - 3000, 21, 2000),
          CFrame.new(Distance, 21, -1000)
        }
      end
    end
    
    function module.IsOwner(Boat)
      return Boat:FindFirstChild("Owner") and Boat.Owner.Value.Name == Player.Name
    end
    
    function module.SeaAlive(Enemy)
      local Humanoid = Enemy:FindFirstChild("Humanoid")
      local Class = Humanoid and Humanoid.ClassName
      
      if Class == "Humanoid" then
        return Humanoid.Health > 0
      elseif Class == "IntValue" or Class == "NumberValue" then
        return Humanoid.Value > 0
      end
    end
    
    function module:GetPlayerBoat()
      if self.PlayerBoat and self.SeaAlive(self.PlayerBoat) then
        return self.PlayerBoat
      end
      
      for _,Boat in next, Boats:GetChildren() do
        if self.SeaAlive(Boat) and self.IsOwner(Boat) then
          if Boat.Name ~= self.BuyBoat.BoatName then
            self.BuyBoat.BoatName = Boat.Name
          end
          
          self.PlayerBoat = Boat
          return Boat
        end
      end
    end
    
    function module:BuyNewBoat()
      local CFrame = self.BuyBoat.Position
      
      if Player:DistanceFromCharacter(CFrame.Position) < 10 then
        FireRemote("BuyBoat", self.BuyBoat.BoatName)
      else
        PlayerTP(CFrame)
      end
    end
    
    function module:teleportBoat(cframe, speed)
      local Boat = self:GetPlayerBoat()
      local BodyVelocity = Module.Tween
      local direction = (cframe.Position - Boat.PrimaryPart.Position).Unit
      BodyVelocity.Velocity = direction * (speed or Settings.BoatSpeed)
    end
    
    function module:stopBoat()
      Module.Tween.Velocity = Vector3.zero
    end
    
    function module:GetSelectedLevel(SeaLevel)
      return self.RandomPosition[SeaLevel or Settings.SeaLevel]
    end
    
    function module:RandomTeleport(SeaLevel)
      if not Humanoid or not Humanoid.SeatPart then
        return self:TeleportToBoat()
      end
      
      local Boat = self:GetPlayerBoat()
      
      local Position = Boat.PrimaryPart.Position
      local locations = Module.Sea == 3 and self:GetSelectedLevel(SeaLevel) or self.RandomPosition
      
      if #locations == 1 then
        self:teleportBoat(locations[1])
      elseif #locations > 1 then
        if self.nextNum > #locations then
          self.nextNum = 1
        end
        
        local nextPos = locations[self.nextNum]
        
        if (Position - nextPos.Position).Magnitude < 100 then
          self.nextNum = self.nextNum + 1
        else
          self:teleportBoat(nextPos)
        end
      end
    end
    
    function module:RandomTool()
      if (tick() - self.toolDebounce) < 3 then
        return self.oldTool
      end
      
      self.toolDebounce = tick()
      
      local NextTool = self.nextTool[self.oldTool]
      
      local Count = 0
      while not VerifyToolTip(NextTool) do
        NextTool, Count = self.nextTool[self.oldTool], Count + 1
        if Count >= 3 then
          break
        end
      end
      
      self.oldTool = NextTool
      return NextTool
    end
    
    function module:GetSeaEvent(Name)
      local nBoats = self.SeaBoatsName
      local nEnemies = self.SeaEventsName
      
      for _, Enemy in ipairs(EnemiesFolder:GetChildren()) do
        local EnName = Enemy.Name
        if (nEnemies[EnName] or nBoats[EnName]) and self.SeaAlive(Enemy) then
          if not Name or EnName == Name then
            return Enemy
          end
        end
      end
      
      return nil
    end
    
    function module:attackBoat(Enemy)
      local randomTool = self:RandomTool()
      local PrimaryPart = Enemy.PrimaryPart
      
      if not PrimaryPart then
        return nil
      end
      
      local Target = PrimaryPart.CFrame + Vector3.new(0, 20, 0)
      
      if Player:DistanceFromCharacter(Target.Position) < 50 then
        UseSkills(PrimaryPart, Settings.skillSelected)
        EquipTool(randomTool, true)
      end
      
      PlayerTP(Target)
      EnableBuso()noSit()
      self:stopBoat()
    end
    
    function module:attackFish(Enemy)
      if Enemy and Enemy.PrimaryPart then
        PlayerTP(Enemy.PrimaryPart.CFrame + Vector3.new(0, 20, 0))
      end
      
      EquipTool()
      EnableBuso()noSit()
      self:stopBoat()
    end
    
    function module:attackSeaEvent(Enemy)
      if self.SeaEventsName[Enemy.Name] then
        self:attackFish(Enemy)
      elseif self.SeaBoatsName[Enemy.Name] then
        self:attackBoat(Enemy)
      end
    end
    
    function module:RandomDirection()
      if (tick() - self.rdDebounce) < 1.5 then
        return self.Directions[self.randomNumber]
      end
      
      self.rdDebounce = tick()
      self.randomNumber = math.random(#self.Directions)
      return self.Directions[self.randomNumber]
    end
    
    function module:attackSeaBeast(SeaBeast)
      local randomTool = self:RandomTool()
      local randomPosition = self:RandomDirection()
      
      local PrimaryPart = SeaBeast:FindFirstChild("HumanoidRootPart")
      
      if not PrimaryPart then
        return nil
      end
      
      local Position = PrimaryPart.Position
      local seaCFrame = CFrame.new(Position.X, 25, Position.Z) + randomPosition
      
      PlayerTP(seaCFrame)
      EquipTool(randomTool, true)
      UseSkills(PrimaryPart, Settings.skillSelected)
      EnableBuso()noSit()
      self:stopBoat()
    end
    
    function module:GetSeaBeast()
      if self.SeaBeast and self.SeaAlive(self.SeaBeast) then
        return self.SeaBeast
      end
      
      local Distance, Nearest = math.huge
      
      for _, SeaBeast in ipairs(SeaBeasts:GetChildren()) do
        local Magnitude = Player:DistanceFromCharacter(SeaBeast:GetPivot().Position)
        if Magnitude < Distance then
          Distance, Nearest = Magnitude, SeaBeast
        end
      end
      
      self.SeaBeast = Nearest
      return Nearest
    end
    
    function module:TeleportToBoat()
      if not Humanoid then
        Humanoid = (Player.Character or Player.CharacterAdded:Wait()):WaitForChild("Humanoid")
      end
      
      local Boat = self.PlayerBoat
      local BoatSit = Boat:WaitForChild("VehicleSeat")
      
      if Humanoid.SeatPart and Humanoid.SeatPart ~= BoatSit then
        Humanoid.Sit = false
      end
      
      PlayerTP(BoatSit.CFrame)
    end
    
    return module
  end
  
  Modules.CDKPuzzle = function()
    if Module.Sea ~= 3 then
      return nil
    end
    
    if Module.Unlocked["Cursed Dual Katana"] then
      return nil
    end
    
    local module = {}
    
    local InvokeCursedSkeleton = {}
    local DoorNpc = CFrame.new(-12131, 578, -6707)
    local ForestPirateSpawn = CFrame.new(-13350, 332, -7645)
    
    local Cursed = Map.Turtle:WaitForChild("Cursed")
    
    local FireRemote = Module.FireRemote
    local Enemies = Module.EnemySpawned
    local Unlocked = Module.Unlocked
    local EquipTool = Module.EquipTool
    
    local EnemyList = {
      Heaven = {"Heaven's Guardian", "Cursed Skeleton"},
      Hell = {"Hell's Messenger", "Cursed Skeleton"}
    }
    
    local hasMastery = function()
      return Module:ItemMastery("Tushita") < 350 or Module:ItemMastery("Yama") < 350
    end
    
    local GetTorch = function(Dimension)
      for i = 1, 3 do
        local torch = Dimension["Torch" .. tostring(i)]
        if torch.ProximityPrompt.Enabled then
          return torch
        end
      end
    end
    
    local GetTask = function()
      if Unlocked["Cursed Dual Katana"] then
        return nil
      end
      
      if not hasMastery() then
        return "MasterySwords"
      elseif Cursed:FindFirstChild("Breakable") then
        return "OpenDoor"
      elseif Player:FindFirstChild("QuestHaze") then
        return "Yama", 2
      elseif Map:FindFirstChild("HellDimension") then
        return "Yama", 3
      elseif Map:FindFirstChild("HeavenlyDimension") then
        return "Tushita", 3
      end
      
      local Count = Module:GetMaterial("Alucard Fragment")
      
      if Count == 6 then
        return "FinalQuest"
      elseif Count == 0 then
        FireRemote("CDKQuest", "Progress", "Evil")
        FireRemote("CDKQuest", "StartTrial", "Evil")
        return "Yama", 1
      end
      
      local Progress = FireRemote("CDKQuest", "Progress")
      local Good = Progress.Good
      local Evil = Progress.Evil
      
      if Evil and Evil >= 0 and Evil < 3 then
        FireRemote("CDKQuest", "Progress", "Evil")
        FireRemote("CDKQuest", "StartTrial", "Evil")
        if Evil == 0 then
          return "Yama", 1
        elseif Evil == 1 then
          return "Yama", 2
        elseif Evil == 2 then
          return "Yama", 3
        end
      elseif Good and Good >= 0 and Good < 3 then
        FireRemote("CDKQuest", "Progress", "Good")
        FireRemote("CDKQuest", "StartTrial", "Good")
        if Good == 0 then
          return "Tushita", 1
        elseif Good == 1 then
          return "Tushita", 2
        elseif Good == 2 then
          return "Tushita", 3
        end
      end
    end
    
    local GetPedestal = function()
      for i = 3, 1, -1 do
        local pedestal = Cursed["Pedestal" .. tostring(i)]
        if pedestal.ProximityPrompt.Enabled then
          return pedestal
        end
      end
    end
    
    local closestHaze = nil;
    local GetClosestHazeEnemy = function()
      if closestHaze and closestHaze.Value > 0 then
        return closestHaze
      end
      
      local dist, near = math.huge
      
      for _,Enemy in ipairs(Player.QuestHaze:GetChildren()) do
        if Enemy.Value > 0 then
          local Position = Enemy:GetAttribute("Position")
          local Mag = typeof(Position) == "Vector3" and Player:DistanceFromCharacter(Position)
          
          if Mag and Mag <= dist then
            dist, near = Mag, Enemy
          end
        end
      end
      
      closestHaze = near
      return near
    end
    
    local Boats = {
      CFrame.new(-9550, 21, 4638),
      CFrame.new(-9531, 7, -8376),
      CFrame.new(-4602, 16, -2880)
    }
    
    module.Tasks = {
      Yama = {
        function()
          if not VerifyTool("Yama") then
            FireRemote("LoadItem", "Yama")
            return true
          end
          
          local Enemy = Enemies["Forest Pirate"]
          
          if Enemy and Enemy.PrimaryPart then
            PlayerTP(Enemy.PrimaryPart.CFrame * CFrame.new(0, 0, -2))
          else
            PlayerTP(ForestPirateSpawn)
          end
          
          return true
        end,
        function()
          local QuestHaze = Player:FindFirstChild("QuestHaze")
          
          if not QuestHaze then
            return nil
          end
          
          local HazeEnemy = GetClosestHazeEnemy()
          
          if HazeEnemy then
            local Name = HazeEnemy.Name
            local Enemy = Enemies[Name]
            
            if Enemy and Enemy.PrimaryPart then
              Modules.FarmManager.attack(Enemy, true)
            else
              if EnemyPositions[Name] then
                Modules.PlayerTeleport:NPCs(EnemyPositions[Name])
              else
                PlayerTP(HazeEnemy:GetAttribute("Position"))
              end
            end
            return true
          end
        end,
        function()
          local Dimension = Map:FindFirstChild("HellDimension")
          
          if Dimension then
            local Enemy = Enemies(EnemyList.Hell)
            
            if Enemy and Enemy.PrimaryPart then
              Modules.FarmManager.attack(Enemy, true, true)
              return true
            end
            
            local Torch = GetTorch(Dimension)
            
            if Torch then
              if Player:DistanceFromCharacter(Torch.Position) < 5 then
                fireproximityprompt(Torch.ProximityPrompt)
              else
                PlayerTP(Torch.CFrame)
              end
            else
              PlayerTP(Dimension.Exit.CFrame)
            end
            
            return true
          end
          
          if Enemies("Soul Reaper") then
            Enemy = Enemies["Soul Reaper"]
            if Enemy and Enemy.PrimaryPart then
              if Player:DistanceFromCharacter(Enemy.PrimaryPart.Position) > 6 then
                PlayerTP(Enemy.PrimaryPart.CFrame * CFrame.new(0, 0, -2))
              end
            end
            return true
          end
          
          if VerifyTool("Hallow Essence") then
            EquipTool("Hallow Essence")
            PlayerTP(Map["Haunted Castle"].Summoner.Detection.CFrame)
            return true
          end
          
          local Enemy = Enemies(Modules.FarmManager.Enemies.Elites)
          
          if Enemy and Enemy.PrimaryPart then
            Modules.FarmManager.attack(Enemy, true, true)
          else
            PlayerTP(CFrame.new(-9513, 164, 5786))
          end
          
          task.spawn(TradeBones)
          return true
        end
      },
      Tushita = {
        function()
          if (tick() - Module.PirateRaid) >= 10 then
            return nil
          end
          
          local Target = Module:GetPirateRaidEnemy()
          
          if Target and Target.PrimaryPart then
            Modules.FarmManager.attack(Target, true, true)
          else
            PlayerTP(CFrame.new(-5556, 314, -2988))
          end
          
          return true
        end,
        function()
          for index, cframe in ipairs(Boats) do
            if Player:DistanceFromCharacter(cframe.Position) < 5 then
              local Target = NPCs:FindFirstChild("Luxury Boat Dealer")
              if Target then
                FireRemote("CDKQuest", "BoatQuest", Target)
                FireRemote("CDKQuest", "BoatQuest", Target, "Check")
                task.wait(1)
                Boats[index] = nil
              end
            else
              PlayerTP(cframe)
            end
            
            return true
          end
        end,
        function()
          local Dimension = Map:FindFirstChild("HeavenlyDimension")
          
          if Dimension then
            local Enemy = Enemies(EnemyList.Heaven)
            
            if Enemy and Enemy.PrimaryPart then
              Modules.FarmManager.attack(Enemy, true, true)
              return true
            end
            
            local Torch = GetTorch(Dimension)
            
            if Torch then
              if Player:DistanceFromCharacter(Torch.Position) < 5 then
                fireproximityprompt(Torch.ProximityPrompt)
              else
                PlayerTP(Torch.CFrame)
              end
            else
              PlayerTP(Dimension.Exit.CFrame)
            end
            
            return true
          end
          
          if Module.IsSpawned("Cake Queen") then
            local Enemy = Enemies("Cake Queen")
            
            if Enemy and Enemy.PrimaryPart then
              Modules.FarmManager.attack(Enemy)
            else
              PlayerTP(CFrame.new(-710, 382, -11150))
            end
            
            return true
          end
        end
      },
      OpenDoor = function()
        if Player:DistanceFromCharacter(DoorNpc.Position) < 5 then
          FireRemote("CDKQuest", "DoorNpc")
          FireRemote("CDKQuest", "OpenDoor", true)
          if Cursed:FindFirstChild("Breakable") then
            Cursed.Breakable:Destroy()
          end
        else
          PlayerTP(DoorNpc)
        end
        return true
      end,
      FinalQuest = function()
        if not VerifyTool("Tushita") and not VerifyTool("Yama") then
          FireRemote("LoadItem", "Tushita")
          return true
        end
        
        if Enemies("Cursed Skeleton Boss") then
          local Enemy = Enemies["Cursed Skeleton Boss"]
          
          if Enemy and Enemy.PrimaryPart then
            Modules.FarmManager.attack(Enemy)
            return true
          end
          
          return nil
        end
        
        if Player.PlayerGui.Main.Dialogue.Visible then
          VirtualUser:ClickButton1(Vector2.new(1e4, 1e4))
        end
        
        local Pedestal = GetPedestal()
        
        if Pedestal then
          if Player:DistanceFromCharacter(Pedestal.Position) < 5 then
            fireproximityprompt(Pedestal.ProximityPrompt)
          else
            PlayerTP(Pedestal.CFrame)
          end
          return true
        else
          if Player:DistanceFromCharacter(InvokeCursedSkeleton[1].Position) > 500 then
            PlayerTP(InvokeCursedSkeleton[1])
            return true
          end
          
          Modules.PlayerTeleport:NPCs(InvokeCursedSkeleton, 50)
          return true
        end
      end,
      MasterySwords = function()
        local Sword = (Module:ItemMastery("Tushita") < 350) and "Tushita" or "Yama"
        
        if not VerifyTool(Sword) then
          FireRemote("LoadItem", Sword)
          return true
        end
        
        EquipTool("Sword", true)
        
        local Enemy = Enemies(Modules.FarmManager.Enemies.Elites)
        if Enemy and Enemy.PrimaryPart then
          Modules.FarmManager.sToolTip("Sword")
          Modules.FarmManager.attack(Enemy, true, true)
        else
          PlayerTP(CFrame.new(-9513, 164, 5786))
        end
        return true
      end
    }
    
    function module:CursedDualKatana()
      local Task, Num = GetTask()
      local Tasks = self.Tasks
      
      if Task and Tasks[Task] then
        return (not Num and Tasks[Task]()) or Tasks[Task][Num]()
      end
      
      return nil
    end
    
    return module
  end
end

function Loader:RunModules()
  for name, module in next, self.Modules do
    local success, result = pcall(module)
    
    if success then
      self.Modules[name] = result
      _ENV[name] = result
    else
      _ENV[name] = nil
      warn("falha ao carregar Module [ redz hub ]: " .. name .. " : " .. result)
    end
  end
end

function Loader:Initialize()
  local owner = "realredz";
  local raw = "https://raw.githubusercontent.com/";
  local url = (raw .. owner .. "/");
  
  Library = loadstring(HttpGet(game, url .. "RedzLibV5/refs/heads/main/Source.lua"))()
  Module = loadstring(HttpGet(game, url .. "BloxFruits/refs/heads/main/testando.lua") .. " return Module")(Settings)
  
  Loader:RunModules()
end

function Loader:LoadTabs(Window)
  return {
    Discord = Window:MakeTab({"Discord", "Info"}),
    MainFarm = Window:MakeTab({"Farm", "Home"}),
    Sea = Window:MakeTab({"Sea", "Waves"}),
    RaceV4 = Window:MakeTab({"Race-V4", ""}),
    Items = Window:MakeTab({"Quests/Items", "Swords"}),
    FruitRaid = Window:MakeTab({"Fruit/Raid", "Cherry"}),
    Stats = Window:MakeTab({"Stats", "Signal"}),
    Teleport = Window:MakeTab({"Teleport", "Locate"}),
    Visual = Window:MakeTab({"Visual", "User"}),
    Shop = Window:MakeTab({"Shop", "ShoppingCart"}),
    Misc = Window:MakeTab({"Misc", "Settings"})
  }
end

function Loader:InstallPlugin()
  return {
    Toggle = loadstring([[
      local Tab, Settings, Flag = ...
      Tab:AddToggle({Settings[1], (type(Settings[2]) ~= "string" and Settings[2]), function(Value)
        getgenv().rz_EnabledOptions[Flag] = Value
      end, Flag, Desc = (type(Settings[2]) == "string" and Settings[2]) or Settings[3]})
    ]])
  }
end

function Loader:LoadLibrary()
  local Logo1 = "rbxassetid://15298567397";
  local Logo2 = "rbxassetid://17382040552";
  
  local Name = "redz Hub : Blox Fruits";
  local Folder = "redzHub-BloxFruits.json";
  local Credits = "by redz9999";
  local Discord = "https://discord.gg/7aR7kNVt4g";
  
  local Window = Library:MakeWindow({Name, Credits, Folder})
  
  -- local Translator = self:LoadTranslator(Window)
  local Plugin = self:InstallPlugin(Library)
  local Tabs = self:LoadTabs(Window)
  
  local FarmManager = self.Modules.FarmManager
  local FireRemote = Module.FireRemote
  
  local AddToggle = Plugin.Toggle
  
  Window:SelectTab(Tabs.MainFarm)
  
  Window:AddMinimizeButton({
    Button = { Image = Logo1, BackgroundTransparency = 0 },
    Corner = { CornerRadius = UDim.new(0, 6) }
  })
  Tabs.Discord:AddDiscordInvite({
    Name = "redz Hub | Community",
    Description = "Join our discord community to receive information about the next update",
    Logo = Logo2,
    Invite = Discord
  })
  
  local Main = Tabs.MainFarm do
    local UIScales = { Large = 450, Medium = 620, Small = 760 }
    
    local SetScale = function(Value)
      Library:SetScale(UIScales[Value] or 450)
    end
    
    local TradeBones = function(Value)
      _ENV.TradeBones = Value
      while _ENV.TradeBones do task.wait()
        if Module:GetMaterial("Bones") >= 50 then
          FireRemote("Bones", "Buy", 1, 1)
          --[[if Module:GetMaterial("Bones") >= 100 then
            task.wait(5)
          end]]
        else
          task.wait(1)
        end
      end
    end
    
    local BossDropdown;
    local UpdateBosses = function()
      local List = {}
      for Boss,_ in pairs(Module.Bosses) do
        if Module.IsSpawned(Boss) then
          table.insert(List, Boss)
        end
      end
      BossDropdown:Set(List)
    end
    
    local AddChristmasTimer = function()
      local str = "Time for next gift : %i"
      local Paragraph = Main:AddParagraph({str})
      
      local TextLabel = workspace.Countdown.SurfaceGui.TextLabel
      
      TextLabel:GetPropertyChangedSignal("Text"):Connect(function()
        local Text = TextLabel.Text
        Paragraph:SetTitle(Text)
        
        if Text ~= "STARTING!" then
          local split = Text:split(":")
          local time = 0
          
          for i = 1, #split do
            split[i] = tonumber(split[i])
          end
          
          time = time + (split[2] >= 1 and (split[2] * 60) or 0) + split[3]
          
          _ENV.StartingChristmasEvent = time <= 100
        else
          _ENV.StartingChristmasEvent = true
        end
      end)
    end
    
    Main:AddDropdown({"Select Tool", {"Melee", "Sword", "Blox Fruit"}, "Melee", {Settings, "FarmTool"}, "FarmTool"})
    Main:AddDropdown({"UI Scale", {"Small", "Medium", "Large"}, "Large", SetScale, "UIScale"})
    Main:AddSection("Farm")
    AddToggle(Main, {"Auto Farm Level", "Level Farm"}, "Level")
    AddToggle(Main, {"Auto Farm Nearest", "Farm Nearest Mobs"}, "Nearest")
    if Module.Sea == 1 then
      -- Main:AddSection("Farm-Level")
      -- AddToggle(Main, {"Sky Piea Farm"}, "SkyFarm")
      -- AddToggle(Main, {"Player Hunter Quest"}, "PlayerHunter")
    elseif Module.Sea == 2 then
      AddToggle(Main, {"Auto Factory", "Spawns Every 1:30 [hours, minutes]"}, "Factory")
      Main:AddSection("Ectoplasm")
      AddToggle(Main, {"Auto Farm Ectoplasm"}, "Ectoplasm")
    elseif Module.Sea == 3 then
      AddToggle(Main, {"Auto Pirates Sea", "Auto Finish Pirate Raid in Sea Castle"}, "PirateRaid")
      Main:AddSection("Bones")
      AddToggle(Main, {"Auto Farm Bones"}, "Bones")
      AddToggle(Main, {"Auto Kill Soul Reaper"}, "SoulReaper")
      Main:AddToggle({"Auto Trade Bones", false, TradeBones})
    end
    if Module.Christmas and workspace:FindFirstChild("Countdown") then
      Main:AddSection("Christmas")
      pcall(AddChristmasTimer)
      if Level.Value >= Module.MaxLevel then
        AddToggle(Main, {"Auto Farm Candy"}, "FarmCandy")
      end
      AddToggle(Main, {"Auto Christmas Gift"}, "ChristmasGift")
    end
    Main:AddSection("Chest")
    AddToggle(Main, {"Auto Chest [ Tween ]"}, "ChestTween")
    Main:AddSection("Bosses")
    Main:AddButton({"Update Boss List", UpdateBosses})
    BossDropdown = Main:AddDropdown({"Boss List", {}, false, {Settings, "BossSelected"}, "B-Selected"})UpdateBosses()
    AddToggle(Main, {"Auto Kill Boss Selected", "Kill boss Selected"}, "BossSelected")
    AddToggle(Main, {"Auto Farm All Bosses", "Kill all bosses Spawned"}, "AllBosses")
    Main:AddToggle({"Take Boss Quest", true, {Settings, "BossQuest"}, "B-Quest"})
    Main:AddSection("Material")
    Main:AddDropdown({"Material List", FarmManager.Materials, false, {Settings, "fMaterial"}, "S-Material"})
    AddToggle(Main, {"Auto Farm Material", "Farm material Selected"}, "Material")
    Main:AddSection("Mastery")
    Main:AddSlider({"Select Enemy Health [ % ]", 10, 60, 1, 25, {Settings, "mHealth"}, "M-Health"})
    Main:AddDropdown({"Select Tool", {"Blox Fruit", "Gun"}, {"Blox Fruit"}, {Settings, "mTool"}, "M-Tool"})
    AddToggle(Main, {"Auto Farm Mastery"}, "Mastery")
    Main:AddSection("Mastery Skill")
    Main:AddToggle({"Skill Z", false, {Settings, "SkillZ"}, "SkillZ"})
    Main:AddToggle({"Skill X", false, {Settings, "SkillX"}, "SkillX"})
    Main:AddToggle({"Skill C", false, {Settings, "SkillC"}, "SkillC"})
    Main:AddToggle({"Skill V", false, {Settings, "SkillV"}, "SkillV"})
    Main:AddToggle({"Skill F", false, {Settings, "SkillF"}, "SkillF"})
    -- Main:AddToggle({"Quest Debounce", false, {self.Modules.QuestManager, "takeQuestDebounce"}, "S-QuestDebounce"})
  end
  
  local Sea = Tabs.Sea do
    if Module.Sea == 1 then
      Sea:Destroy()
    elseif Module.Sea == 2 then
      local enemyList = {"Sea Beast", "Pirate Brigade"}
      local listSkills = {"Z", "X", "C", "V", "F"}
      local defSkills = {"Z", "X", "C", "V"}
      
      Sea:AddSection({"Farm"})
      AddToggle(Sea, {"Auto Farm Sea"}, "Sea")
      -- Sea:AddButton({"Buy New Boat", BuyNewBoat})
      Sea:AddSection({"Select Farm"})
      Sea:AddDropdown({"Fish", enemyList, enemyList, {Settings, "seaEnemy"}, "S-Enemies", MultiSelect = true})
      Sea:AddDropdown({"Select Skills", listSkills, defSkills, {Settings, "skillSelected"}, "S-Skills", MultiSelect = true})
      Sea:AddSection("Configs")
      Sea:AddSlider({"Boat Tween Speed", 100, 300, 10, 250, {Settings, "BoatSpeed"}, "S-BoatSpeed"})
    elseif Module.Sea == 3 then
      local FishList = {"Sea Beast", "Terrorshark", "Fish Crew Member", "Piranha", "Shark"}
      local npcList = {"Shipwright Teacher", "Shark Hunter", "Beast Hunter", "Spy"}
      local BoatList = {"Pirate Brigade", "Pirate Grand Brigade", "Fish Boat"}
      local seaLevels = {"1", "2", "3", "4", "5", "6", "inf"}
      local listSkills = {"Z", "X", "C", "V", "F"}
      local defSkills = {"Z", "X", "C", "V"}
      
      local npcsLocations = {
        ["Shipwright Teacher"] = CFrame.new(-16526, 76, 309),
        ["Shark Hunter"] = CFrame.new(-16526, 108, 752),
        ["Beast Hunter"] = CFrame.new(-16281, 73, 263),
        ["Spy"] = CFrame.new(-16471, 528, 539)
      }
      
      local AddKistuneStats = function()
        local Paragraph = Sea:AddParagraph({"Kitsune Island : not spawn"})
        task.spawn(function()
          while task.wait() do
            if Map:FindFirstChild("KitsuneIsland") then
              local Distance = math.floor(Player:DistanceFromCharacter(Map.KitsuneIsland.WorldPivot.Position) / 5)
              Paragraph:SetTitle("Kitsune Island : Spawned | Distance : " .. Distance)
            else
              Paragraph:SetTitle("Kitsune Island : not Spawn")
              Map.ChildAdded:Wait()
            end
          end
        end)
      end
      
      local TradeAzure = function(Value)
        _ENV.TradeAzure = Value
        while _ENV.TradeAzure do task.wait(1)
          if Module:GetMaterial("Azure Ember") >= Settings.Azure then
            ReplicatedStorage.Modules.Net["RF/KitsuneStatuePray"]:InvokeServer()
          end
        end
      end
      
      local teleportNpc = function(Value)
        _ENV.teleporting = Value
        
        while _ENV.teleporting do task.wait()
          if Settings.selectedNpc then
            PlayerTP(npcsLocations[Settings.selectedNpc])
          end
        end
      end
      
      local stopNpcTeleport = function(Value)
        if Value then
          local self, Magnitude = self.Modules.PlayerTeleport, math.huge
          repeat task.wait()
            if self.lastPosition then
              Magnitude = Player:DistanceFromCharacter(self.lastPosition)
            end
          until not _ENV.teleporting or (Magnitude < 15)
          _ENV.teleporting = false
        end
      end
      
      Sea:AddSection("Kitsune")
      AddKistuneStats()
      Sea:AddSlider({"Trade Azure Ember Amount", 10, 25, 5, 20, {Settings, "Azure"}, "A-Amount"})
      Sea:AddToggle({"Auto Trade Azure Ember", false, TradeAzure})
      AddToggle(Sea, {"Auto Kitsune Island"}, "Kitsune")
      Sea:AddSection("Sea")
      AddToggle(Sea, {"Auto Farm Sea"}, "Sea")
      -- Sea:AddButton({"Buy New Boat", BuyNewBoat})
      -- Sea:AddSection({"Material"})
      -- AddToggle(Sea, {"Auto Wood Planks"}, "WoodPlanks")
      Sea:AddSection("Farm Select")
      Sea:AddDropdown({"Fish", FishList, FishList, {Settings, "fishSelected"}, "S-Fish", MultiSelect = true})
      Sea:AddDropdown({"Boats", BoatList, BoatList, {Settings, "boatSelected"}, "S-Boat", MultiSelect = true})
      Sea:AddDropdown({"Select Skills", listSkills, defSkills, {Settings, "skillSelected"}, "S-Skills", MultiSelect = true})
      Sea:AddSection("Configs")
      Sea:AddDropdown({"Sea Level", seaLevels, "6", {Settings, "SeaLevel"}, "S-SeaLevel"})
      Sea:AddSlider({"Boat Tween Speed", 100, 300, 10, 250, {Settings, "BoatSpeed"}, "S-BoatSpeed"})
      Sea:AddSection("NPCs")
      Sea:AddDropdown({"Select NPC", npcList, "Spy", {Settings, "selectedNpc"}})
      Sea:AddToggle({"Teleport to NPC", false, teleportNpc}):Callback(stopNpcTeleport)
    end
  end
  
  local Race = Tabs.RaceV4 do
    if Module.Sea == 3 then
      Race:AddSection("Mirage")
      AddToggle(Race, {"Teleport To Gear"}, "MirageGear")
      AddToggle(Race, {"Teleport To Mirage"}, "TeleportMirage")
      AddToggle(Race, {"Teleport To Fruit Dealer"}, "MirageFruitDealer")
    else
      Race:Destroy()
    end
  end
  
  local Stats = Tabs.Stats do
    if Level.Value < Module.MaxLevel then
      local Selected, StatsName = {}, {"Melee", "Defense", "Gun", "Sword", "Demon Fruit"}
      
      local Points = Data:WaitForChild("Points")
      local StatsFolder = Data:WaitForChild("Stats")
      
      local AutoStats = function(Value)
        _ENV.AutoStats = Value
        
        while task.wait() and _ENV.AutoStats do
          local Points = Points.Value
          
          if Points > 0 then
            for Tag, Enabled in pairs(Selected) do
              if Enabled and StatsFolder[Tag].Level.Value < Module.MaxLevel then
                local Amount = math.clamp(math.clamp(Settings.StatsPoints or 3, 0, Points), 0, Module.MaxLevel)
                FireRemote("AddPoint", Tag, Amount)
              end
            end
          end
        end
      end
      
      local AddStatsToggle = function(_, Name)
        Stats:AddToggle({Name, false, {Selected, Name}, "Stats-" .. Name})
      end
      
      Stats:AddSlider({"Points Amount", 1, 100, 1, 3, {Settings, "StatsPoints"}, "P-Stats"})
      Stats:AddToggle({"Auto Stats", false, AutoStats, "A-Stats"})
      Stats:AddSection("Select Stats")
      table.foreach(StatsName, AddStatsToggle)
    else
      Stats:Destroy()
    end
  end
  
  local Items = Tabs.Items do
    if Module.Sea == 3 then
      Items:AddSection("Dragon Update [ BETA ]")
      AddToggle(Items, {"Auto Dojo Trainer Quest", "Automatically completes Dojo Trainer quests"}, "DojoTrainer")
      AddToggle(Items, {"Auto Dragon Hunter Quest", "Automatically completes Dragon Hunter quests"}, "DragonHunter")
      
      Items:AddSection("Farm")
      AddToggle(Items, {"Auto Elite Hunter", "Automatically completes Elite Hunter quests"}, "EliteHunter")
      AddToggle(Items, {"Auto Rip Indra", "Activates the plates and summons Rip Indra"}, "RipIndra")
      AddToggle(Items, {"Auto Cake Prince", "Automatically summons the Cake Prince"}, "CakePrince")
      AddToggle(Items, {"Auto Dough King", "Automatically summons the Dough King"}, "DoughKing")
      
      Items:AddSection("Sword")
      AddToggle(Items, {"Auto Collect Yama", "Automatically collects the Yama sword after defeating 30 Elite Hunters"}, "Yama")
      AddToggle(Items, {"Auto Tushita", "Solves the Tushita puzzle and defeats Longma"}, "Tushita")
      
      Items:AddSection("Gun")
      AddToggle(Items, {"Auto Soul Guitar", "Completes the Soul Guitar puzzle and acquires the weapon"}, "SoulGuitar")
    elseif Module.Sea == 2 then
      local LegendarySword = function(Value)
        _ENV.LegendSword = Value
        
        while task.wait() and _ENV.LegendSword do
          local Sword = FireRemote("LegendarySwordDealer", "1")
          
          if type(Sword) == "string" then
            if Module.Unlocked[Sword] then
              task.wait(60*230)
            else
              FireRemote("LegendarySwordDealer", "2")
              FireRemote("LegendarySwordDealer", "3")
            end
          else
            task.wait(5)
          end
        end
      end
      
      Items:AddSection("Third Sea")
      AddToggle(Items, {"Auto Third Sea", "Automatically unlocks access to the Third Sea"}, "ThirdSea")
      AddToggle(Items, {"Auto Kill Don Swan", "Automatically defeats Don Swan"}, "DonSwan")
      
      Items:AddSection("Bosses")
      AddToggle(Items, {"Auto Darkbeard", "Automatically spawns and defeats Darkbeard"}, "Darkbeard")
      AddToggle(Items, {"Auto Cursed Captain", "Automatically summons and defeats the Cursed Captain"}, "CursedCaptain")
      
      Items:AddSection("Law")
      AddToggle(Items, {"Auto Kill Law", "Automatically spawns and defeats Law (Order)"}, "Order")
      Items:AddToggle({"Auto Buy Microchip", false, {Settings, "FullyLawRaid"}, "S-FullyLaw";
        Desc = "Buy the raid law Microchip"
      })
      
      Items:AddSection("Legendary Sword")
      Items:AddToggle({"Auto Buy Legendary Sword", false, LegendarySword, "LegendSword";
        Desc = "Automatically purchases Legendary Swords when available"
      })
      
      Items:AddSection("Race")
      AddToggle(Items, {"Auto Race V2", "Automatically evolves the Race to V2"}, "RaceV2")
      AddToggle(Items, {"Auto Race V3", "Mink, Human & Shark"}, "RaceV3")
    elseif Module.Sea == 1 then
      Items:AddSection("Second Sea")
      AddToggle(Items, {"Auto Second Sea", "Automatically unlocks access to the Second Sea"}, "SecondSea")
      
      Items:AddSection("Swords")
      AddToggle(Items, {"Auto Unlock Saber", "Automatically unlocks the Saber Sword"}, "Saber")
      AddToggle(Items, {"Auto Pole V1", "Kill Thunder God"}, "PoleV1")
      AddToggle(Items, {"Auto Saw Sword", "Kill The Saw"}, "TheSaw")
    end
  end
  
  local Fruits = Tabs.FruitRaid do
    local CanStore = function(FruitName)
      local Item = Module.Inventory[FruitName]
      if Item then
        return Item.details.Count < Data.FruitCap.Value
      end
      return true
    end
    
    local IsFruit = function(child)
      return child:FindFirstChild("Fruit")
    end
    
    local store = function(Fruit)
      local FruitName = (Fruit.Name:gsub(" Fruit", ""))
      FruitName = (FruitName .. "-" .. FruitName)
      
      if CanStore(FruitName) then
        Module.FireRemote("StoreFruit", FruitName, Fruit)
        return true
      end
      return false
    end
    
    local AutoStore = function(Value)
      _ENV.AutoStore = Value
      
      while _ENV.AutoStore do task.wait(0.25)
        local Character = Player.Character
        
        if Module.IsAlive(Character) then
          for _,child in ipairs(Player.Backpack:GetChildren()) do
            if child:IsA("Tool") and IsFruit(child) then
              store(child)
            end
          end
          for _,child in ipairs(Character:GetChildren()) do
            if child:IsA("Tool") and IsFruit(child) then
              store(child)
            end
          end
        else
          -- Player.CharacterAdded:Wait()
        end
      end
    end
    
    local RandomFruit = function(Value)
      _ENV.AutoRandomFruit = Value
      
      while _ENV.AutoRandomFruit do task.wait(1)
        if Level.Value >= 50 then
          Module.FireRemote("Cousin", "Buy")
        else
          Level.Changed:Wait()
        end
      end
    end
    
    Fruits:AddSection("Fruits")
    Fruits:AddToggle({"Auto Store Fruits", false, AutoStore, "F-AutoStore"})
    AddToggle(Fruits, {"Teleport To Fruits"}, "Fruits")
    Fruits:AddToggle({"Auto Random Fruit", false, RandomFruit, "F-RandomFruit"})
    Fruits:AddSection("Raid")
    
    if Module.Sea ~= 2 and Module.Sea ~= 3 then
      Fruits:AddParagraph({"Only on Sea 2 and 3"})
    else
      local RaidChip = function(Value)
        _ENV.BuyRaidChip = Value
        
        while _ENV.BuyRaidChip do task.wait()
          if not VerifyTool("Special Microchip") then
            if not _ENV.AutoStore and Settings.SelectedChip then
              Module.FireRemote("RaidsNpc", "Select", Settings.SelectedChip)
              task.wait(1)
            end
          else
            task.wait(1)
          end
        end
      end
      
      Fruits:AddDropdown({"Select Chip", Module.RaidList, "", {Settings, "SelectedChip"}, "R-RaidChip"})
      AddToggle(Fruits, {"Auto Farm Raid", "Kill Aura, Start & Awaken"}, "Raid")
      Fruits:AddToggle({"Auto Buy Chip", false, RaidChip, "R-BuyChip"})
    end
  end
  
  local Teleport = Tabs.Teleport do
    local Toggle = nil;
    local Islands = ({
      {
        "WindMill", "Marine", "Middle Town",
        "Jungle", "Pirate Village", "Desert",
        "Snow Island", "MarineFord", "Colosseum",
        "Sky Island 1", "Sky Island 2", "Sky Island 3",
        "Prison", "Magma Village", "Under Water Island",
        "Fountain City"
      },
      {
        "The Cafe", "Frist Spot", "Dark Area",
        "Flamingo Mansion", "Flamingo Room", "Green Zone",
        "Zombie Island", "Two Snow Mountain", "Punk Hazard",
        "Cursed Ship", "Ice Castle", "Forgotten Island",
        "Ussop Island"
      },
      {
        "Mansion", "Port Town", "Great Tree",
        "Castle On The Sea", "Hydra Island", "Floating Turtle",
        "Haunted Castle", "Ice Cream Island", "Peanut Island",
        "Cake Island", "Candy Cane Island", "Tiki Outpost"
      }
    })[Module.Sea]
    
    local IslandsPos = {
      ["Middle Town"] = CFrame.new(-688, 15, 1585),
      ["MarineFord"] = CFrame.new(-4810, 21, 4359),
      ["Marine"] = CFrame.new(-2728, 25, 2056),
      ["WindMill"] = CFrame.new(889, 17, 1434),
      ["Desert"] = CFrame.new(1054, 53, 4490),
      ["Snow Island"] = CFrame.new(1298, 87, -1344),
      ["Pirate Village"] = CFrame.new(-1173, 45, 3837),
      ["Jungle"] = CFrame.new(-1614, 37, 146),
      ["Prison"] = CFrame.new(4870, 6, 736),
      ["Under Water Island"] = CFrame.new(61164, 5, 1820),
      ["Colosseum"] = CFrame.new(-1535, 7, -3014),
      ["Magma Village"] = CFrame.new(-5290, 9, 8349),
      ["Sky Island 1"] = CFrame.new(-4814, 718, -2551),
      ["Sky Island 2"] = CFrame.new(-4652, 873, -1754),
      ["Sky Island 3"] = CFrame.new(-7895, 5547, -380),
      ["Fountain City"] = CFrame.new(5041, 1, 4101),
      ["The Cafe"] = CFrame.new(-382, 73, 290),
      ["Frist Spot"] = CFrame.new(-11, 29, 2771),
      ["Dark Area"] = CFrame.new(3494, 13, -3259),
      ["Flamingo Mansion"] = CFrame.new(-317, 331, 597),
      ["Flamingo Room"] = CFrame.new(2285, 15, 905),
      ["Green Zone"] = CFrame.new(-2258, 73, -2696),
      ["Zombie Island"] = CFrame.new(-5552, 194, -776),
      ["Two Snow Mountain"] = CFrame.new(752, 408, -5277),
      ["Punk Hazard"] = CFrame.new(-5897, 18, -5096),
      ["Cursed Ship"] = CFrame.new(919, 125, 32869),
      ["Ice Castle"] = CFrame.new(5505, 40, -6178),
      ["Forgotten Island"] = CFrame.new(-3050, 240, -10178),
      ["Ussop Island"] = CFrame.new(4816, 8, 2863),
      ["Mansion"] = CFrame.new(-12471, 374, -7551),
      ["Port Town"] = CFrame.new(-334, 7, 5300),
      ["Castle On The Sea"] = CFrame.new(-5073, 315, -3153),
      ["Hydra Island"] = CFrame.new(5666, 1013, -310),
      ["Great Tree"] = CFrame.new(2683, 275, -7008),
      ["Floating Turtle"] = CFrame.new(-12528, 332, -8658),
      ["Haunted Castle"] = CFrame.new(-9517, 142, 5528),
      ["Ice Cream Island"] = CFrame.new(-902, 79, -10988),
      ["Peanut Island"] = CFrame.new(-2062, 50, -10232),
      ["Cake Island"] = CFrame.new(-1897, 14, -11576),
      ["Candy Cane Island"] = CFrame.new(-1038, 10, -14076),
      ["Tiki Outpost"] = CFrame.new(-16224, 9, 439)
    }
    
    local GoToIsland = function(Value)
      _ENV.teleporting = Value
      while _ENV.teleporting do task.wait()
        if _ENV.SelectedIsland then
          PlayerTP(IslandsPos[_ENV.SelectedIsland])
        end
      end
      if Value and Toggle then
        Toggle:Set(false, true)
      end
    end
    
    local StopTween = function(Value)
      if Value then
        local self, Magnitude = self.Modules.PlayerTeleport, math.huge
        repeat task.wait()
          if self.lastPosition then
            Magnitude = Player:DistanceFromCharacter(self.lastPosition)
          end
        until not _ENV.teleporting or (Magnitude < 15)
        _ENV.teleporting = false
      end
    end
    
    Teleport:AddSection("Travel")
    Teleport:AddButton({"Teleport to Sea 1", function() Module.TravelTo(1) end, Desc = "Main"})
    Teleport:AddButton({"Teleport to Sea 2", function() Module.TravelTo(2) end, Desc = "Dressrosa"})
    Teleport:AddButton({"Teleport to Sea 3", function() Module.TravelTo(3) end, Desc = "Zou"})
    Teleport:AddSection("Islands")
    Teleport:AddDropdown({"Select Island", Islands, "", {_ENV, "SelectedIsland"}})
    Toggle = Teleport:AddToggle({"Teleport To Island", false, GoToIsland}):Callback(StopTween)
  end
  
  local Visual = Tabs.Visual do
    local EspManager = self.Modules.EspManager
    
    local EspColors = {
      Players = Color3.fromRGB(220, 220, 220),
      Fruits = Color3.fromRGB(255, 0, 0),
      Islands = Color3.fromRGB(0, 255, 255),
      Chests = {
        Chest1 = Color3.fromRGB(150, 150, 150),
        Chest2 = Color3.fromRGB(255, 255, 0),
        Chest3 = Color3.fromRGB(0, 255, 255),
        Null = Color3.fromRGB(150, 0, 255)
      }
    }
    
    local Esps = {
      Players = EspManager.new("Player", Characters, function(Obj)
        if Obj ~= Player.Character then
          return true, EspColors.Players
        end
      end),
      Chests = EspManager.new("Chest", workspace, function(Obj)
        if Obj.Name:find("Chest") then
          return true, EspColors.Chests[Obj.Name] or EspColors.Chests.Null
        end
      end),
      Islands = EspManager.new("Island", Locations, function(Obj)
        if Obj.Name ~= "Sea" then
          return true, EspColors.Islands
        end
      end),
      Fruits = EspManager.new("Fruit", workspace, function(Obj)
        if Obj.Name:find("Fruit") and Obj:FindFirstChild("Handle") then
          return true, EspColors.Fruits
        end
      end),
      Flowers = EspManager.new("Flower", workspace, function(Obj)
        if Obj:IsA("BasePart") and Obj.Name:find("Flower") then
          return true, Obj.Color
        end
      end)
    }
    
    --[[Visual:AddSection("Aimbot Nearest")
    Visual:AddToggle({"Aimbot Gun", false, {_ENV, "AimBot_Gun"}})
    Visual:AddToggle({"Aimbot Tap", false, {_ENV, "AimBot_Tap"}})
    Visual:AddToggle({"Aimbot Skills", false, {_ENV, "AimBot_Skills"}})
    Visual:AddToggle({"Ignore Mobs", true, {Settings, "NoAimMobs"}})]]
    Visual:AddSection("ESP")
    if Module.Sea == 2 then Visual:AddToggle({"ESP Flowers", false, {Esps.Flowers, "Enabled"}}) end
    Visual:AddToggle({"ESP Players", false, {Esps.Players, "Enabled"}})
    Visual:AddToggle({"ESP Fruits", false, {Esps.Fruits, "Enabled"}})
    Visual:AddToggle({"ESP Chests", false, {Esps.Chests, "Enabled"}})
    Visual:AddToggle({"ESP Islands", false, {Esps.Islands, "Enabled"}})
  end
  
  local Shop = Tabs.Shop do
    for _, Option in ipairs(Module.Shop) do
      Shop:AddSection(Option[1])
      
      for _, item in ipairs(Option[2]) do
        local buyfunc = item[2]
        
        if type(item[2]) == "table" then
          buyfunc = function() FireRemote(unpack(item[2])) end
        end
        
        Shop:AddButton({item[1], buyfunc})
      end
    end
  end
  
  local Misc = Tabs.Misc do
    local ExecClipboard = function()
      loadstring((getclipboard or fromclipboard)())()
    end
    
    local JobIdFilter = function(JobId)
      return string.gsub(JobId:gsub("`", ""), "\n", "")
    end
    
    local JoinJobId = function(JobId)
      TeleportService:TeleportToPlaceInstance(game.PlaceId, JobId, Player)
    end
    
    local JoinClipboard = function()
      JoinJobId((getclipboard or fromclipboard)())
    end
    
    local WS_Toggle, WS_Slider
    local ToggleWalkSpeed = function(Value)
      if Value then Module.Hooking:SpeedBypass() end
      _ENV.WalkSpeedBypass, WS_Toggle = (Value and WS_Slider) or false, Value
    end
    
    local ChangeWalkSpeed = function(Value)
      _ENV.WalkSpeedBypass, WS_Slider = (WS_Toggle and Value) or false, Value
    end
    
    local WalkWater = function(Value)
      _ENV.WalkOnWater = Value
      local BasePlate = Map:WaitForChild("WaterBase-Plane", 9e9)
      
      while _ENV.WalkOnWater do task.wait(0.1)
        BasePlate.Size = Vector3.new(1000, 113, 1000)
      end
      BasePlate.Size = Vector3.new(1000, 80, 1000)
    end
    
    local AntiAfk = function(Value)
      _ENV.AntiAFK = Value
      while _ENV.AntiAFK do
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(math.huge, math.huge))task.wait(600)
      end
    end
    
    if IsOwner then
      Misc:AddSection("Executor")
      Misc:AddButton({"Execute Clipboard", ExecClipboard})
    end
    if Module.JobIds then
      Misc:AddSection("Join Server")
      Misc:AddTextBox({"Input Job Id", "1", false, JoinJobId, "JobId"}).OnChanging = JobIdFilter
      Misc:AddButton({"Join Clipboard", JoinClipboard})
    end
    Misc:AddSection("Settings")
    Misc:AddSlider({"Farm Distance", 5, 30, 1, 15, function(Value)
      Settings.FarmPos = Vector3.new(0, Value, 0)
      Settings.FarmDistance = Value
    end, "S-Distance"})
    Misc:AddSlider({"Tween Speed", 50, 300, 5, 200, {Settings, "TweenSpeed"}, "S-TweenSpeed"})
    Misc:AddSlider({"Bring Mobs Distance", 50, 400, 10, 250, {Settings, "BringDistance"}, "S-BringDistance"})
    Misc:AddSlider({"Auto Attack Delay", 0, 1, 0.01, 0.201, {Settings, "ClickDelay"}, "S-ClickDelay"})
    Misc:AddToggle({"Bring Mobs", true, {Settings, "BringMobs"}, "S-BringMobs"})
    Misc:AddToggle({"Auto Haki", true, {Settings, "AutoBuso"}, "S-AutoBuso"})
    Misc:AddToggle({"Auto Attack", true, {Settings, "AutoClick"}, "S-AutoClick"})
    -- Misc:AddToggle({"Fast Attack", true, {Settings, "FastAttack"}, "S-FastAttack"})
    Misc:AddSection("Codes")
    Misc:AddButton({"Redeem all Codes", RedeemCodes})
    Misc:AddSection("Team")
    Misc:AddButton({"Join Pirates Team", JoinTeam.Pirates})
    Misc:AddButton({"Join Marines Team", JoinTeam.Marines})
    Misc:AddSection("Menu")
    Misc:AddButton({"Devil Fruit Shop", function()
      FireRemote("GetFruits")
      Player.PlayerGui.Main.FruitShop.Visible = true
    end})
    Misc:AddButton({"Titles", function()
      FireRemote("getTitles")
      Player.PlayerGui.Main.Titles.Visible = true
    end})
    Misc:AddButton({"Haki Color", function()
      Player.PlayerGui.Main.Colors.Visible = true
    end})
    Misc:AddSection("Local-Player")
    Misc:AddToggle({"Walk Speed", false, ToggleWalkSpeed, "M-WalkSpeed:A"})
    Misc:AddSlider({"Walk Speed", 10, 300, 5, 150, ChangeWalkSpeed, "M-WalkSpeed:B"})
    Misc:AddSection("Visual")
    Misc:AddButton({"Remove Fog", NoFog})
    Misc:AddSection("More FPS")
    Misc:AddToggle({"Remove Damage", false, function(Value)
      ReplicatedStorage.Assets.GUI.DamageCounter.Enabled = not Value
    end, "M-DamageCounter"})
    Misc:AddToggle({"Remove Notifications", false, function(Value)
      Player.PlayerGui.Notifications.Enabled = not Value
    end, "M-Notifications"})
    Misc:AddSection("Others")
    Misc:AddToggle({"Walk On Water", true, WalkWater, "M-WalkOnWater"})
    Misc:AddToggle({"Anti AFK", true, AntiAfk, "M-AntiAFK"})
  end
end

function Loader:StartFarm()
  if not _ENV.loadedFarm then
    _ENV.loadedFarm = true
    
    loadstring([[local w,e,f=task.wait,(getgenv or getrenv or getfenv)(),...;task.spawn(function()while w() do local b=false;for i,v in f do if v() then b=true;break end;end;e.OnFarm=(e.teleporting or b);end;end)]])(FarmFunctions)
  end
end

function Loader:StartFunctions()
  table.clear(Functions)
  
  local index = {}
  
  local newFunc = function(Name, Function, cancel)
    if cancel == false then
      return nil
    end
    
    index[Name] = Function
    table.insert(Functions, { Name = Name, Function = Function })
  end
  
  local IslandManager = self.Modules.IslandManager
  local QuestManager = self.Modules.QuestManager
  local FarmManager = self.Modules.FarmManager
  local RaidManager = self.Modules.RaidManager
  local SeaManager = self.Modules.SeaManager
  local CDKPuzzle = self.Modules.CDKPuzzle
  local Tween = self.Modules.PlayerTeleport
  
  local Sea = Module.Sea
  local IsAlive = Module.IsAlive
  local Inventory = Module.Inventory
  local Unlocked = Module.Unlocked
  local EquipTool = Module.EquipTool
  local FireRemote = Module.FireRemote
  
  local IsSpawned = Module.IsSpawned
  local Enemies = Module.EnemySpawned
  local EnemyLocations = Module.EnemyLocations
  
  local Elites = FarmManager.Enemies.Elites
  local Bones = FarmManager.Enemies.Bones
  local Katakuri = FarmManager.Enemies.Katakuri
  local Ectoplasm = FarmManager.Enemies.Ectoplasm
  
  local Attack = FarmManager.attack
  
  local PirateRaidSpawn = CFrame.new(-5556, 300, -2988)
  local EctoplasmSpawn = CFrame.new(914, 126, 33100)
  local RipIndraSpawn = CFrame.new(-5561, 314, -2663)
  local KatakuriSpawn = CFrame.new(-2103, 70, -12165)
  local SweetChalice = CFrame.new(224, 25, -12771)
  local DarkbeardSpawn = CFrame.new(3779, 16, -3500)
  local EliteQuest = CFrame.new(-5417, 313, -2822)
  local BonesSpawn = CFrame.new(-9513, 164, 5786)
  local ShanksSpawn = CFrame.new(-1461, 30, -51)
  local DojoTrainer = CFrame.new(5867, 1208, 872)
  local HunterLocation = CFrame.new(5864, 1209, 810)
  local YamaSword = CFrame.new(5251, 20, 454)
  local ThunderGod = CFrame.new(-7739, 5657, -2289)
  local TheSaw = CFrame.new(-690, 15, 1583)
  local ThirdSea = CFrame.new(-26952, 21, 329)
  local Bartilo = CFrame.new(-462, 73, 300)
  local DonSwan = CFrame.new(2289, 15, 808)
  local Alchemist = CFrame.new(-2777, 73, -3570)
  local Wenlocktoad = CFrame.new(-1988, 124, -70)
  
  local RF_InteractDragonQuest = Net:WaitForChild("RF/InteractDragonQuest")
  local RE_DragonDojoEmber = Net:WaitForChild("RE/DragonDojoEmber")
  local RF_DragonHunter = Net:WaitForChild("RF/DragonHunter")
  local QuestUpdate = Remotes:WaitForChild("QuestUpdate")
  
  local cachedBoss = nil;
  local DangerCooldown = 0;
  local DragonHunterProgress = nil;
  local DojoTrainerProgress = nil;
  local CachedNearest = nil;
  local CachedTree = nil;
  
  local Completed = {}
  
  local Dragon = {
    DojoClaim = { NPC = "Dojo Trainer", Command = "ClaimQuest" },
    DojoProgress = { NPC = "Dojo Trainer", Command = "RequestQuest" },
    RequestQuest = { Context = "RequestQuest" },
    Check = { Context = "Check" },
    
    TresSkills = {Z=true,X=true,C=true,V=true}
  }
  
  local RaceV3 = {
    Human = {"Fajita", "Diamond", "Jeremy"}
  }
  
  local PlacesColors = {
    ["Really red"] = "Pure Red",
    ["Oyster"] = "Snow White",
    ["Hot pink"] = "Winter Sky"
  }
  
  local ChristmasIslands = {
    CFrame.new(-1076, 14, -14437),
    CFrame.new(-5219, 15, 1532),
    CFrame.new(1007, 15, -3805)
  }
  
  local GetChristmasGift = function()
    for _,Gift in ipairs(WorldOrigin:GetChildren()) do
      if Gift.Name == "Present" then
        if Gift:FindFirstChild("Box") and Gift.Box:FindFirstChild("ProximityPrompt") then
          return Gift
        end
      end
    end
  end
  
  local GetNextBoss = function()
    if cachedBoss and IsSpawned(cachedBoss) then
      return cachedBoss
    end
    
    for _, Name in ipairs(Module.BossesName) do
      if IsSpawned(Name) then
        cachedBoss = Name
        return Name
      end
    end
  end
  
  local PlacesActivated = function()
    local Places = workspace.Map["Boat Castle"].Summoner.Circle
    
    for _, Place in ipairs(Places:GetChildren()) do
      if Place:IsA("BasePart") and Place.Part.BrickColor ~= BrickColor.new("Lime green") then
        local HakiColor = PlacesColors[Place.BrickColor.Name]
        local Position = Place.Position
        
        if HakiColor then
          PlayerTP(Place.CFrame)
          if Player:DistanceFromCharacter(Position) < 10 then
            ReplicatedStorage.Modules.Net:FindFirstChild("RF/FruitCustomizerRF"):InvokeServer({
              StorageName = HakiColor,
              Type = "AuraSkin",
              Context = "Equip"
            })
          end
        end
        
        return false
      end
    end
    
    return true
  end
  
  local CollectYama = function()
    fireclickdetector(Map.Waterfall.SealedKatana.Hitbox.ClickDetector)
  end
  
  local KillBossByInfo = function(Information, Name)
    local Quest = Information.Quest
    
    if Settings.BossQuest and Quest then
      if Level.Value >= Information.Level and not QuestManager:VerifyQuest(Name) then
        QuestManager:StartQuest(Quest[1], Quest[3] or 3, Quest[2])
        return true
      end
    end
    
    local Enemy = Enemies(Name)
    
    if Enemy and Enemy.PrimaryPart then
      Attack(Enemy)
      return true
    elseif Information.Position then
      PlayerTP(Information.Position)
      return true
    end
  end
  
  local GetEmberTemplate = function()
    local Distance, Nearest = math.huge
    
    for _, Fire in ipairs(workspace:GetChildren()) do
      if Fire.Name == "EmberTemplate" and Fire:FindFirstChild("Part") then
        if Fire.Part.Position.Y > 0 then
          local Magnitude = Player:DistanceFromCharacter(Fire.Part.Position)
          
          if Magnitude < Distance then
            Distance, Nearest = Magnitude, Fire.Part
          end
        end
      end
    end
    
    return Nearest
  end
  
  local BuyMicrochip = function()
    if Fragments.Value >= 1000 and not VerifyTool("Microchip") then
      FireRemote("BlackbeardReward", "Microchip", "2")
      
      local time = tick()
      repeat task.wait() until VerifyTool("Microchip") or (tick() - time) > 5
    end
  end
  
  local GetHydraTree = function()
    if CachedTree and CachedTree.Parent then
      return CachedTree
    end
    
    local Trees = Map.Waterfall.IslandModel:GetChildren()
    
    for _, Tree in ipairs(Trees) do
      if Tree:IsA("Model") and Tree.Name == "Tree" then
        local Group = Tree:FindFirstChild("Group")
        local Mesh = Group:FindFirstChild("Meshes/bambootree")
        
        if Mesh and Mesh.Anchored then
          CachedTree = Mesh
          return Mesh
        end
      end
    end
  end
  
  local BreakHydraTrees = function()
    local Tree = GetHydraTree()
    
    PlayerTP(Tree.CFrame)
    return true
  end
  
  newFunc("Tushita", function()
    if Unlocked.Tushita then
      local Enemy = Enemies("rip_indra True Form")
      if Enemy and Enemy.PrimaryPart then
        Attack(Enemy)
        return true
      end
      return nil
    end
    
    local Progress = Data:GetProgress("Tushita", "TushitaProgress")
    
    if Progress.OpenedDoor then
      local Enemy = Enemies("Longma")
      if Enemy and Enemy.PrimaryPart then
        Attack(Enemy)
        return true
      end
    end
    
    if VerifyTool("Holy Torch") then
      for i = 1, 5 do FireRemote("TushitaProgress", "Torch", i) end
      return true
    end
    
    if IsSpawned("rip_indra True Form") then
      PlayerTP(CFrame.new(5152, 142, 912))
      return true
    end
  end, (Sea == 3))
  
  newFunc("Darkbeard", function()
    local Enemy = Enemies("Darkbeard")
    
    if Enemy and Enemy.PrimaryPart then
      if Enabled.Sea then noSit() end
      Attack(Enemy)
      return true
    elseif VerifyTool("Fist of Darkness") then
      if Enabled.Sea then noSit() end
      EquipTool("Fist of Darkness")
      PlayerTP(DarkbeardSpawn)
      return true
    end
  end, (Sea == 2))
  
  newFunc("CursedCaptain", function()
    local Enemy = Enemies("Cursed Captain")
    
    if Enemy and Enemy.PrimaryPart then
      if Enabled.Sea then noSit() end
      Attack(Enemy)
      return true
    end
  end, (Sea == 2))
  
  newFunc("Factory", function()
    local Enemy = Enemies("Core")
    
    if Enemy and Enemy.PrimaryPart then
      if Enabled.Sea then noSit() end
      FarmManager.attackPosition(Enemy.PrimaryPart.CFrame)
      return true
    end
  end, (Sea == 2))
  
  newFunc("CursedDualKatana", function()
    CDKPuzzle:UpdateProgress()
    CDKPuzzle:CursedDualKatana()
  end, (Sea == 3))
  
  newFunc("ChristmasGift", function()
    if not _ENV.StartingChristmasEvent then
      return nil
    end
    
    local Gift = GetChristmasGift()
    
    if Gift and Gift.PrimaryPart then
      if Player:DistanceFromCharacter(Gift.PrimaryPart.Position) < 5 then
        fireproximityprompt(Gift.Box.ProximityPrompt)
      else
        PlayerTP(Gift.PrimaryPart.CFrame)
      end
    else
      PlayerTP(ChristmasIslands[Sea])
    end
    
    return true
  end)
  
  newFunc("Raid", function()
    if RaidManager:IsRaiding() then
      local NextIsland = Module:GetRaidIsland()
      
      if NextIsland then
        PlayerTP(NextIsland.CFrame + Vector3.new(0, 70, 0))
        Module.KillAura()
      end
      
      return true
    end
    
    if VerifyTool("Special Microchip") then
      RaidManager:start()
      return true
    end
  end, (Sea == 2 or Sea == 3))
  
  newFunc("PirateRaid", function()
    if (tick() - Module.PirateRaid) <= 10 then
      for _, Enemy in ipairs(Module.PirateRaidEnemies) do
        if IsAlive(Enemy) and Enemy.PrimaryPart then
          Attack(Enemy)
          return true
        end
      end
      
      PlayerTP(PirateRaidSpawn)
      return true
    end
  end, (Sea == 3))
  
  newFunc("Fruits", function()
    local Fruit = workspace:FindFirstChild("Fruit ")
    
    if Fruit and Fruit:FindFirstChild("Handle") then
      PlayerTP(Fruit.Handle.CFrame)
      return true
    else
      local Tool = workspace:FindFirstChildOfClass("Tool")
      
      if Tool and Tool:FindFirstChild("Handle") then
        PlayerTP(Tool.Handle.CFrame)
        return true
      end
    end
  end)
  
  newFunc("DojoTrainer", function()
    local Progress = DojoTrainerProgress
    local Quest = Progress and Progress.Quest
    
    if Quest and Quest.Progress >= Quest.Goal then
      if Player:DistanceFromCharacter(DojoTrainer.Position) <= 5 then
        RF_InteractDragonQuest:InvokeServer(Dragon.DojoProgress)
        RF_InteractDragonQuest:InvokeServer(Dragon.DojoClaim)
      else
        PlayerTP(DojoTrainer)
      end
    end
    
    if not Progress then
      if Player:DistanceFromCharacter(DojoTrainer.Position) <= 5 then
        DojoTrainerProgress = RF_InteractDragonQuest:InvokeServer(Dragon.DojoProgress)
      else
        PlayerTP(DojoTrainer)
      end
      
      return true
    end
    
    if Quest then
      local QuestName = Quest.BeltName
      
      if QuestName == "Admittance" then
        return index.Level()
      elseif QuestName == "Yellow" then
        return index.Sea()
      elseif QuestName == "Purple" then
        return index.EliteHunter()
      elseif QuestName == "Blue" then
        return index.Fruits()
      elseif QuestName == "Green" then
        if Player:GetAttribute("DangerLevel") >= 500 and (tick() - DangerCooldown) >= 1 then
          Quest.Progress = Quest.Progress + 1
          DangerCooldown = tick()
        end
        
        local Boat = SeaManager:GetPlayerBoat()
        
        if Boat then
          SeaManager:RandomTeleport("inf")
        else
          SeaManager:BuyNewBoat()
        end
        
        return true
      elseif QuestName == "Orange" then
        return false
      end
    end
  end, (Sea == 3))
  
  newFunc("DragonHunter", function()
    if DragonHunterProgress == "Locked" then
      return nil
    end
    
    local Ember = GetEmberTemplate()
    
    if Ember then
      PlayerTP(Ember.CFrame)
      return true
    end
    
    if not DragonHunterProgress or not DragonHunterProgress.Text then
      if Player:DistanceFromCharacter(HunterLocation.Position) < 5 then
        DragonHunterProgress = RF_DragonHunter:InvokeServer(Dragon.Check)
        
        if DragonHunterProgress and not DragonHunterProgress.Text then
          RF_DragonHunter:InvokeServer(Dragon.RequestQuest)
        end
      else
        PlayerTP(HunterLocation)
      end
      return true
    end
    
    local Text = DragonHunterProgress.Text
    
    if Text:find("Defeat") then
      local Name = Text:find("Venomous") and "Venomous Assailant" or "Hydra Enforcer"
      local Enemy = Enemies(Name)
      local Position = EnemyLocations[Name]
      
      if Enemy and Enemy.PrimaryPart then
        Attack(Enemy, true)
      elseif Position then
        Tween:NPCs(Position)
      end
      return true
    elseif Text:find("Destroy") then
      return BreakHydraTrees()
    end
  end, (Sea == 3))
  
  newFunc("MirageFruitDealer", function()
    if Map:FindFirstChild("MysticIsland") then
      local FruitDealer = IslandManager:GetMirageFruitDealer()
      
      if FruitDealer and FruitDealer.PrimaryPart then
        PlayerTP(FruitDealer.PrimaryPart.CFrame)
        return true
      end
    end
  end, (Sea == 3))
  
  newFunc("MirageGear", function()
    local Mirage = Map:FindFirstChild("MysticIsland")
    
    if Mirage then
      local MirageGear = IslandManager:GetMirageGear(Mirage)
      
      if MirageGear and MirageGear.Transparency < 1 then
        PlayerTP(MirageGear.CFrame)
        return true
      end
    end
  end, (Sea == 3))
  
  newFunc("TeleportMirage", function()
    local Mirage = Map:FindFirstChild("MysticIsland")
    
    if Mirage then
      local MirageTop = IslandManager:GetMirageTop(Mirage)
      
      if MirageTop then
        PlayerTP(MirageTop.CFrame * CFrame.new(0, 211.8, 0))
      end
    end
  end, (Sea == 3))
  
  newFunc("KitsuneIsland", function()
    local Island = Map:FindFirstChild("KitsuneIsland")
    
    if Island then
      noSit()
      local Ember = GetEmberTemplate()
      
      if Ember then
        PlayerTP(Ember.CFrame)
        return true
      end
      
      local Stone = Island:FindFirstChild("ShrineDialogPart")
      
      if Stone then
        PlayerTP(Stone.CFrame)
      else
        PlayerTP(Island.WorldPivot)
      end
    end
    
    local Boat = SeaManager:GetPlayerBoat()
    
    if not Boat then
      SeaManager:BuyNewBoat()
      return true
    else
      SeaManager:RandomTeleport("6")
      return true
    end
  end)
  
  newFunc("Bartilo", function()
    if Level.Value < 850 or Unlocked["Warrior Helmet"] then
      return nil
    end
    
    local Progress = Module:GetProgress("Bartilo", "BartiloQuestProgress")
    
    if Progress.KilledSpring then
      FireRemote("BartiloQuestProgress", "DidPlates")
    elseif Progress.KilledBandits then
      if Module.IsAlive("Jeremy") then
        local Enemy = Enemies("Jeremy")
        
        if Enemy and Enemy.PrimaryPart then
          Attack(Enemy)
        else
          PlayerTP(CFrame.new(2316, 449, 787))
        end
        
        return true
      end
    elseif not Progress.KilledBandits then
      local HasQuest = (Quest:VerifyQuest("Swan Pirate") and Quest:VerifyQuest("50"))
      
      if HasQuest then
        local Enemy = Enemies("Swan Pirate")
        
        if Enemy and Enemy.PrimaryPart then
          Attack(Enemy)
        elseif EnemyLocations["Swan Pirate"] then
          Tween:NPCs(EnemyLocations["Swan Pirate"])
        end
      else
        QuestManager:StartQuest("BartiloQuest", 1, Bartilo)
      end
      
      return true
    end
  end, (Sea == 2))
  
  newFunc("RaceV2", function()
    if Level.Value < 850 or Unlocked["Warrior Helmet"] or Data.Race:FindFirstChild("Evolved") then
      return nil
    end
    
    local Progress = Module:GetData("RaceV2", "Alchemist", "1")
    
    if Progress == 0 or Progress == 2 then
      if Player:DistanceFromCharacter(Alchemist.Position) < 5 then
        FireRemote("Alchemist", Progress == 0 and "2" or "3")
      else
        PlayerTP(Alchemist)
      end
      return true
    elseif Progress == 1 then
      for i = 1, 2 do
        local Flower = workspace:FindFirstChild("Flower" .. i)
        
        if Flower and Flower.Transparency ~= 1 and not VerifyTool("Flower " .. i) then
          PlayerTP(Flower.CFrame)
          return true
        end
      end
      
      if not VerifyTool("Flower 3") then
        local Enemy = Enemies("Swan Pirate")
        
        if Enemy and Enemy.PrimaryPart then
          Attack(Enemy)
        elseif EnemyLocations["Swan Pirate"] then
          Tween:NPCs(EnemyLocations["Swan Pirate"])
        end
      end
    end
  end, (Sea == 2))
  
  newFunc("RaceV3", function()
    if Completed.RaceV3 or not Data.Race:FindFirstChild("Evolved") then
      return nil
    end
    
    local Progress = Module:GetProgress("RaceV3", "Wenlocktoad", "1")
    
    if Progress == 3 then
      Completed.RaceV3 = true
      return nil
    end
    
    if Progress == 0 or Progress == 2 then
      if Player:DistanceFromCharacter(Wenlocktoad.Position) < 5 then
        FireRemote("Wenlocktoad", Progress == 0 and "2" or "3")
      else
        PlayerTP(Wenlocktoad)
      end
      return true
    elseif Progress == 1 then
      local Race = Data.Race.Value
      
      if Race == "Shark" then
        return index.Sea()
      elseif Race == "Human" then
        for _, Name in ipairs(RaceV3.Human) do
          if IsSpawned(Name) then
            return KillBossByInfo(Module.Bosses[Name], Name)
          end
        end
      elseif Race == "Mink" then
        return index.ChestTween()
      end
    end
  end, (Sea == 2))
  
  newFunc("Sea", function()
    local Boat = SeaManager:GetPlayerBoat()
    
    if not Boat then
      SeaManager:BuyNewBoat()
      return true
    end
    
    local EnabledOptions = Settings.seaEnemy
    
    if not EnabledOptions then
      return nil
    end
    
    if EnabledOptions["Pirate Brigade"] then
      local PirateBrigade = SeaManager:GetSeaEvent("Pirate Brigade")
      
      if PirateBrigade then
        SeaManager:attackSeaEvent(PirateBrigade)
        return true
      end
    end
    
    if EnabledOptions["Sea Beast"] then
      local SeaBeast = SeaManager:GetSeaBeast()
      
      if SeaBeast then
        SeaManager:attackSeaBeast(SeaBeast)
        return true
      end
    end
    
    if Boat then
      SeaManager:RandomTeleport()
      return true
    end
  end, (Sea == 2))
  
  newFunc("Sea", function()
    local Boat = SeaManager:GetPlayerBoat()
    
    if not Boat then
      SeaManager:BuyNewBoat()
      return true
    end
    
    local EnabledBoats = Settings.boatSelected
    local EnabledFishs = Settings.fishSelected
    
    if EnabledFishs["Sea Beast"] then
      local SeaBeast = SeaManager:GetSeaBeast()
      
      if SeaBeast then
        SeaManager:attackSeaBeast(SeaBeast)
        return true
      end
    end
    
    for Name, Enabled in pairs(EnabledFishs) do
      if Enabled and Name ~= "Sea Beast" then
        local Enemy = SeaManager:GetSeaEvent(Name)
        
        if Enemy then
          SeaManager:attackSeaEvent(Enemy)
          return true
        end
      end
    end
    
    for Name, Enabled in pairs(EnabledBoats) do
      if Enabled then
        local Enemy = SeaManager:GetSeaEvent(Name)
        
        if Enemy then
          SeaManager:attackSeaEvent(Enemy)
          return true
        end
      end
    end
    
    if Boat then
      SeaManager:RandomTeleport()
      return true
    end
  end, (Sea == 3))
  
  newFunc("Yama", function()
    if Unlocked.Yama then
      return nil
    end
    
    if Module.Progress.EliteHunter >= 30 then
      if Player:DistanceFromCharacter(YamaSword) < 5 then
        pcall(CollectYama)
        task.wait(1)
      else
        PlayerTP(YamaSword)
      end
      return true
    end
  end, (Sea == 3))
  
  newFunc("EliteHunter", function()
    local Quest = QuestManager:VerifyQuest(Elites)
    
    if (Enabled.DoughKing or Enabled.CakePrince or Enabled.RipIndra) and ((
        IsSpawned("rip_indra True Form") or IsSpawned("Dough King") or IsSpawned("Cake Prince")
      ) or (
        VerifyTool("God's Chalice") or VerifyTool("Sweet Chalice")
      )) then
      return nil
    end
    
    if Quest then
      local Elite = Enemies(Quest)
      if Elite and Elite.PrimaryPart then
        Attack(Elite)
        return true
      end
    else
      for i = 1, #Elites do
        if IsSpawned(Elites[i]) then
          PlayerTP(EliteQuest)
          Tween:talkNpc(EliteQuest, "EliteHunter")
          return true
        end
      end
    end
  end, (Sea == 3))
  
  newFunc("ThirdSea", function()
    if Level.Value < 1500 or Level.Value >= 1850 then
      return nil
    end
    
    local Progress = Module:GetProgress("Zou1", "ZQuestProgress")
    local Check = Completed.Zou2 or Module:GetProgress("Zou2", "ZQuestProgress", "Check")
    
    if not Check then
      local Unlocked = Module:GetProgress("Unlockables", "GetUnlockables").FlamingoAccess
      
      if Unlocked then
        return index.DonSwan()
      end
      
      return nil
    elseif not Completed.Zou2 then
      Completed.Zou2 = true
    end
    
    if Player:DistanceFromCharacter(ThirdSea) < 1200 then
      local Enemy = EnemiesFolder:FindFirstChild("rip_indra")
      
      if Enemy and Enemy.PrimaryPart then
        Attack(Enemy)
      end
      return true
    end
    
    if Progress.KilledIndraBoss then
      return Module.TravelTo(3)
    else
      local NPC = CFrame.new(-1926, 13, 1738)
      
      if Player:DistanceFromCharacter(NPC.Position).Magnitude < 5 then
        FireRemote("ZQuestProgress", "Begin")
        _ENV.OnFarm = false
        repeat task.wait() until Player:DistanceFromCharacter(ThirdSea) < 250
        return true
      else
        PlayerTP(NPC)
      end
    end
  end, (Sea == 2))
  
  newFunc("DonSwan", function()
    if not Unlocked["Warrior Helmet"] then
      return nil
    end
    
    if IsSpawned("Don Swan") then
      local Enemy = Enemies("Don Swan")
      if Enemy and Enemy.PrimaryPart then
        Attack(Enemy)
      else
        PlayerTP(DonSwan)
      end
      return true
    end
  end, (Sea == 2))
  
  newFunc("SecondSea", function()
    if Level.Value < 700 then
      return nil
    end
    
    local Progress = Module:GetProgress("Dressrosa", "DressrosaQuestProgress")
    
    if Progress.KilledIceBoss then
      return Module.TravelTo(2)
    end
    
    if not Progress.TalkedDetective then
      FireRemote("DressrosaQuestProgress","Detective")
    elseif not Progress.UsedKey then
      if not VerifyTool("Key") then FireRemote("DressrosaQuestProgress", "Detective") end
      EquipTool("Key")
      FireRemote("DressrosaQuestProgress", "UseKey")
    elseif not Progress.KilledIceBoss then
      local Enemy = Enemies("Ice Admiral")
      
      if Enemy and Enemy.PrimaryPart then
        Attack(Enemy)
      end
    end
    
    return true
  end, (Sea == 1))
  
  newFunc("Order", function()
    local Enemy = EnemiesFolder:FindFirstChild("Order")
    
    if Enemy and Enemy.PrimaryPart then
      Attack(Enemy)
      return true
    end
    
    if VerifyTool("Microchip") then
      return fireclickdetector(Map.CircleIsland.RaidSummon.Button.Main.ClickDetector)
    end
    
    if Settings.FullyLawRaid then
      return BuyMicrochip()
    end
  end, (Sea == 2))
  
  newFunc("Saber", function()
    if Level.Value < 200 or Unlocked.Saber then
      return nil
    end
    
    local Data = Module:GetProgress("Shanks", "ProQuestProgress")
    
    if Data.UsedRelic then
      if Module.IsSpawned("Saber Expert") then
        local Enemy = Enemies("Saber Expert")
        
        if Enemy and Enemy.PrimaryPart then
          Attack(Enemy)
        else
          PlayerTP(ShanksSpawn)
        end
        return true
      end
    elseif Data.KilledMob then
      if VerifyTool("Relic") then
        FireRemote("ProQuestProgress", "PlaceRelic")
      else
        FireRemote("ProQuestProgress", "RichSon")
      end
      return true
    elseif Data.UsedCup then
      if not Data.TalkedSon then
        return FireRemote("ProQuestProgress", "RichSon")
      end
      
      if Module.IsSpawned("Mob Leader") then
        local Enemy = Enemies("Mob Leader")
        
        if Enemy and Enemy.PrimaryPart then
          Attack(Enemy)
        else
          PlayerTP(CFrame.new(-2880, 9, 5430))
        end
        return true
      end
    elseif Data.UsedTorch then
      if VerifyTool("Cup") then
        FireRemote("ProQuestProgress", "FillCup",
          Player.Character and Player.Character:FindFirstChild("Cup") or Player.Backpack:FindFirstChild("Cup")
        )
      else
        FireRemote("ProQuestProgress", "GetCup")
      end
      FireRemote("ProQuestProgress", "SickMan")
      return true
    else
      for i, v in next, Data.Plates do
        if not v then
          FireRemote("ProQuestProgress", "Plate", i)
          return true
        end
      end
      
      if VerifyTool("Torch") then
        FireRemote("ProQuestProgress", "DestroyTorch")
      else
        FireRemote("ProQuestProgress", "GetTorch")
      end
      
      return true
    end
  end, (Sea == 1))
  
  newFunc("PoleV1", function()
    if Level.Value < 450 or Unlocked["Pole (1st Form)"] then
      return nil
    end
    
    if Module.IsSpawned("Thunder God") then
      local Enemy = Enemies("Thunder God")
      
      if Enemy and Enemy.PrimaryPart then
        Attack(Enemy)
      else
        PlayerTP(ThunderGod)
      end
      
      return true
    end
  end, (Sea == 1))
  
  newFunc("TheSaw", function()
    if Level.Value < 100 or Unlocked["Shark Saw"] then
      return nil
    end
    
    if Module.IsSpawned("The Saw") then
      local Enemy = Enemies("The Saw")
      
      if Enemy and Enemy.PrimaryPart then
        Attack(Enemy)
      else
        PlayerTP(TheSaw)
      end
      
      return true
    end
  end, (Sea == 1))
  
  newFunc("SoulReaper", function()
    local Enemy = Enemies("Soul Reaper")
    
    if Enemy and Enemy.PrimaryPart then
      Attack(Enemy)
      return true
    elseif VerifyTool("Hallow Essence") then
      EquipTool("Hallow Essence")
      PlayerTP(Map["Haunted Castle"].Summoner.Detection.CFrame)
      return true
    end
  end, (Sea == 3))
  
  newFunc("RipIndra", function()
    local Enemy = Enemies("rip_indra True Form")
    
    if Enemy and Enemy.PrimaryPart then
      Attack(Enemy)
      return true
    end
    
    if VerifyTool("God's Chalice") then
      if PlacesActivated() then
        PlayerTP(RipIndraSpawn)
      end
      
      return true
    end
  end, (Sea == 3))
  
  newFunc("BossSelected", function()
    local Name = Settings.BossSelected
    local Enemy = Name and IsSpawned(Name)
    
    if Enemy then
      return KillBossByInfo(Module.Bosses[Name], Name)
    end
  end)
  
  newFunc("AllBosses", function()
    local Name = GetNextBoss()
    
    if Name then
      return KillBossByInfo(Module.Bosses[Name], Name)
    end
  end)
  
  newFunc("DoughKing", function()
    local Enemy = Enemies("Dough King") or Enemies("Cake Prince")
    
    if VerifyTool("Red Key") then
      FireRemote("CakeScientist", "Check")
      return true
    end
    
    if Enemy and Enemy.PrimaryPart then
      Attack(Enemy)
    else
      if not VerifyTool("Sweet Chalice") and VerifyTool("God's Chalice") then
        if Module:GetMaterial("Conjured Cocoa") < 10 then
          FarmManager.Material("Conjured Cocoa")
        else
          PlayerTP(SweetChalice)
          Tween:talkNpc(SweetChalice, "SweetChaliceNpc")
        end
        return true
      end
      
      local Target = Enemies(Katakuri)
      if Target and Target.PrimaryPart then
        Attack(Target, true, true)
      else
        PlayerTP(KatakuriSpawn)
      end
    end
    
    return true
  end, (Sea == 3))
  
  newFunc("CakePrince", function()
    if Enabled.DoughKing then
      return nil
    end
    
    local Enemy = Enemies("Dough King") or Enemies("Cake Prince")
    
    if Enemy and Enemy.PrimaryPart then
      Attack(Enemy)
    else
      local Target = Enemies(Katakuri)
      if Target and Target.PrimaryPart then
        Attack(Target, true, true)
      else
        PlayerTP(KatakuriSpawn)
      end
    end
    
    return true
  end, (Sea == 3))
  
  newFunc("ChestTween", function()
    local Chest = Module.Chests()
    
    if Chest then
      PlayerTP(Chest:GetPivot())
      return true
    end
  end)
  
  newFunc("Ectoplasm", function()
    local Enemy = Enemies(Ectoplasm)
    
    if Enemy and Enemy.PrimaryPart then
      Attack(Enemy, true, true)
    else
      PlayerTP(EctoplasmSpawn)
    end
    
    return true
  end, (Sea == 2))
  
  newFunc("Bones", function()
    if Enabled.Level and Level.Value < Module.MaxLevel then
      return nil
    end
    
    local Enemy = Enemies(Bones)
    
    if Enemy and Enemy.PrimaryPart then
      Attack(Enemy, true, true)
    else
      PlayerTP(BonesSpawn)
    end
    
    return true
  end, (Sea == 3))
  
  newFunc("Level", function()
    -- if Enabled.SkyFarm then return nil end
    
    local Quest = QuestManager:GetQuest()
    
    if not Quest then
      return nil
    end
    
    local Target = Quest.Enemy.Name
    local Position = Quest.Enemy.Position
    
    local Enemy = QuestManager:VerifyQuest(Target)
    
    if Enemy then
      Enemy = Enemies[Enemy]
      
      if Enemy and Enemy.PrimaryPart then
        Attack(Enemy, true)
      else
        if #Position > 0 then
          Tween:NPCs(Position)
        else
          PlayerTP(QuestManager:GetQuestPosition())
        end
      end
    else
      QuestManager:StartQuest(Quest.Name, Quest.Count, QuestManager:GetQuestPosition())
    end
    
    return true
  end)
  
  newFunc("Material", function()
    if Settings.fMaterial then
      FarmManager.Material(Settings.fMaterial)
      return true
    end
  end)
  
  newFunc("Nearest", function()
    if CachedNearest and IsAlive(CachedNearest) then
      Attack(CachedNearest, true, true)
      return true
    end
    
    local Distance, Nearest = math.huge
    
    for _, Enemy in ipairs(EnemiesFolder:GetChildren()) do
      local PrimaryPart = Enemy.PrimaryPart
      
      if IsAlive(Enemy) and PrimaryPart then
        local Magnitude = Player:DistanceFromCharacter(PrimaryPart.Position)
        
        if Magnitude < Distance then
          Distance, Nearest = Magnitude, Enemy
        end
      end
    end
    
    if Nearest then
      CachedNearest = Nearest
      Attack(Nearest, true, true)
      return true
    end
  end)
  
  if Sea == 3 then
    RE_DragonDojoEmber.OnClientEvent:Connect(function()
      DragonHunterProgress = nil
    end)
    
    QuestUpdate.OnClientEvent:Connect(function(...)
      local Quest = DojoTrainerProgress and DojoTrainerProgress.Quest
      
      if Quest and (Quest.BeltName == "Admittance" or Quest.BeltName == "Yellow") then
        Quest.Progress = Quest.Progress + 1
      end
    end)
  end
  
  local function NewCharacter(Character)
    local Humanoid = Character:WaitForChild("Humanoid")
    
    Humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
      local SeatPart = Humanoid.SeatPart
      if _ENV.OnFarm and SeatPart and SeatPart.Name ~= "VehicleSeat" then
        Humanoid.Sit = false
      end
    end)
  end
  
  if Player.Character then NewCharacter(Player.Character) end
  Player.CharacterAdded:Connect(NewCharacter)
end

Loader:Initialize()

Loader:StartFarm()
Loader:StartFunctions()

Loader:LoadLibrary()
