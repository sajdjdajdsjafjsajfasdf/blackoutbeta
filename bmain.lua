if getgenv().aliveloaded then return end
getgenv().aliveloaded = true
--//services

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("StarterGui")

--//envs

getgenv().MeleeAura = false
getgenv().GunAura = false
getgenv().HookLockpick = false
getgenv().AntiRagdoll = false
getgenv().NoSelfDmg = false
getgenv().InfiniteStamina = false
getgenv().HasDoubleJump = false
getgenv().InfStam = false
getgenv().NoBlockCD = false
getgenv().NpcTable = {}
getgenv().VmFX = false
getgenv().VMMAT = "ForceField"
getgenv().VMTRANS = 0
getgenv().VMCP = Color3.new(0,0,0)
getgenv().IP = false
getgenv().AutofarmMedic = false
getgenv().NOSPR = false
getgenv().NOREC = false
getgenv().PESP = false
getgenv().BESP = false
getgenv().MESP = false
local function encodeNumber(number)
    local alphabet = {
        [0] = "z", [1] = "a", [2] = "b", [3] = "c", [4] = "d", [5] = "e",
        [6] = "f", [7] = "g", [8] = "h", [9] = "i"
    }
    return alphabet[number]
end
local ClassNameBlacklist = {"Shirt","Pants","BodyColors","Accessory"}

local function encodeNumberString(str)
    local encodedStr = ""
    for i = 1, #str do
        local number = tonumber(str:sub(i, i))
        if number ~= nil and number >= 0 and number <= 9 then
            local encodedLetter = encodeNumber(number)
            encodedStr = encodedStr .. encodedLetter
        else
            encodedStr = encodedStr .. str:sub(i, i)
        end
    end
    return encodedStr
end

local function encodeCharacter(char)
    local alphabet = {
        ["a"] = 1, ["b"] = 2, ["c"] = 3, ["d"] = 4, ["e"] = 5,
        ["f"] = 6, ["g"] = 7, ["h"] = 8, ["i"] = 9, ["j"] = 10,
        ["k"] = 11, ["l"] = 12, ["m"] = 13, ["n"] = 14, ["o"] = 15,
        ["p"] = 16, ["q"] = 17, ["r"] = 18, ["s"] = 19, ["t"] = 20,
        ["u"] = 21, ["v"] = 22, ["w"] = 23, ["x"] = 24, ["y"] = 25,
        ["z"] = 26,
        ["0"] = 27, ["1"] = 28, ["2"] = 29, ["3"] = 30, ["4"] = 31,
        ["5"] = 32, ["6"] = 33, ["7"] = 34, ["8"] = 35, ["9"] = 36
    }
    return alphabet[char] or 0 
end

local function encodeString(str)
    local encodedNumber = 0
    for i = 1, #str do
        local char = str:sub(i, i):lower()
        local charValue = encodeCharacter(char)
        encodedNumber = encodedNumber * 100 + charValue
    end
    return encodedNumber
end

local FlashConnection

local BrokerHighlights = {}
local MerchantHighlights = {}
local NiggaHighlights = {}

for i, connection in pairs(getconnections(game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("Flashbang").OnClientEvent)) do
    FlashConnection = connection
end

local StaticUI = game:GetService("Players").LocalPlayer.PlayerGui.MainStaticGui
local LBUI = game:GetService("Players").LocalPlayer.PlayerGui.MainStaticGui.RightTab.Leaderboard
local PlayerList = LBUI.PlayerList

local PlayerListConnections = {}

local adjectives = {"blazing","radiant","fading","vivid","silent","lunar"}
local nouns = {"hawk","marauder","tempest","veil","valley","lighthouse"}


local function generatePhrase()
    local adjective = adjectives[math.random(#adjectives)]
    local noun = nouns[math.random(#nouns)]
    return adjective .. " " .. noun
end

local function spoofServerInfo(bool)
    if bool then
        getgenv().originalServerInfo = {}
        originalServerInfo["ST"] = game:GetService("ReplicatedStorage"):GetAttribute("ServerStartTime")
        originalServerInfo["SN"] = game:GetService("ReplicatedStorage"):GetAttribute("ServerName")
        game:GetService("ReplicatedStorage"):SetAttribute("ServerStartTime",tick()+math.random(10000,100000))
        game:GetService("ReplicatedStorage"):SetAttribute("ServerName",generatePhrase():upper())
    else
        if not originalServerInfo then return end
        game:GetService("ReplicatedStorage"):SetAttribute("ServerStartTime",originalServerInfo["ST"])
        game:GetService("ReplicatedStorage"):SetAttribute("ServerName",originalServerInfo["SN"])
    end
end


local function spoofLevel()
    local LevelLabel = game:GetService("Players").LocalPlayer.PlayerGui.MainGui.LevelFrame.Level.LevelBox.LevelText
    local XPBar = game:GetService("Players").LocalPlayer.PlayerGui.MainGui.LevelFrame.Level.XpBar.XpText
    if LevelLabel:GetAttribute("SMMODE") == true then return end
    LevelLabel:SetAttribute("SMMODE",true)
    local Experience = string.split(XPBar.Text,"/")
    local CurrentExp = Experience[1]
    local MaxExp = Experience[2]
    encoded = tostring(math.random(10,45))
    LevelLabel.Text = encoded
    LevelLabel:GetPropertyChangedSignal("Text"):Connect(function()
        LevelLabel.Text = encodeNumberString(LevelLabel.Text)
    end)
    local CurExp = encodeNumberString(CurrentExp)
    local MaxExper = encodeNumberString(MaxExp)
    XPBar.Text = CurExp.."/"..MaxExper
    XPBar:GetPropertyChangedSignal("Text"):Connect(function()
        local Experience1 = string.split(XPBar.Text,"/")
        local CurrentExp1 = Experience1[1]
        local MaxExp1 = Experience1[2]
        local CurExpr = encodeNumberString(CurrentExp1)
        local MaxExperr = encodeNumberString(MaxExp1)
        XPBar.Text = CurExpr.."/"..MaxExperr
    end)
end



game:GetService("ProximityPromptService").PromptShown:Connect(function(Prompt)
    if Prompt.Style == Enum.ProximityPromptStyle.Custom and getgenv().IP then
        if Prompt.HoldDuration ~= 0 then
            Prompt.HoldDuration = 0
        end
    end
end)
local function Magnitude(Part1,Part2)
    if not Part1 or not Part2 then return 0 end
    if not Part1:IsA("BasePart") or not Part2:IsA("BasePart") then return 0 end
    return (Part1.Position-Part2.Position).Magnitude
end
local function applyNoRecoil(Viewmodel: Model)
    for i, data in pairs(getgc(true)) do
        if typeof(data) == "table" and rawget(data, "Shell") or rawget(data, "Projectile") then
            if getgenv().NOREC then
		        data.Kickback = 0
            	data.AimedKickback = 0
            	data.Recoil = NumberRange.new(0,1)
		        data.Shake = 0
	        end
            if getgenv().NOSPR then
		        data.Spread = 0
	        end
        end
    end
end
workspace.CurrentCamera.ChildAdded:Connect(function(Child)
    if Child.Name == "ViewModel" then
        if getgenv().VmFX then
            local Material = Enum.Material[getgenv().VMMAT]
            if not Material then return end
            for i, Parts in pairs(Child:GetChildren()) do
                if Parts:FindFirstChild("SurfaceAppearance") then
                    Parts:FindFirstChild("SurfaceAppearance"):Destroy()
                    Parts.Transparency = getgenv().VMTRANS
                    Parts.Material = Material
                end
            end
        end
        if getgenv().NOSPR or getgenv().NOREC then applyNoRecoil() end
    end
end)

game:GetService("Players").LocalPlayer.PlayerGui.ChildAdded:Connect(function(Child)
    if Child.Name == "MainGui" and getgenv().streamermode then
        spoofLevel()
    end
end)
--//misc

for _, miscNpc in pairs(workspace.NPCs.Other:GetChildren()) do
    local Highlight = Instance.new("Highlight")
    Highlight.FillTransparency = 1
    Highlight.Parent = miscNpc
    Highlight.Enabled = false
    if miscNpc.Name == "Broker" then
        Highlight.Enabled = getgenv().BESP
        Highlight.OutlineColor = Color3.fromRGB(0,0,255)
        BrokerHighlights[Highlight] = Highlight
    else
        Highlight.OutlineColor = Color3.fromRGB(0,255,0)
        Highlight.Enabled = getgenv().MESP
        MerchantHighlights[Highlight] = Highlight
    end
end

workspace.NPCs.Other.ChildAdded:Connect(function(miscNpc)
    local Highlight = Instance.new("Highlight")
    Highlight.FillTransparency = 1
    Highlight.Parent = miscNpc
    Highlight.Enabled = false
    if miscNpc.Name == "Broker" then
        Highlight.OutlineColor = Color3.fromRGB(0,255,0)
        Highlight.Enabled = getgenv().BESP
        BrokerHighlights[Highlight] = Highlight
    else
        Highlight.OutlineColor = Color3.fromRGB(0,255,0)
        Highlight.Enabled = getgenv().MESP
        MerchantHighlights[Highlight] = Highlight
    end
end)
workspace.NPCs.Other.ChildRemoved:Connect(function(miscNpc)
    if miscNpc:FindFirstChildWhichIsA("Highlight") then
        if string.match(miscNpc.Name,"Merchant") then
            local hl = MerchantHighlights[miscNpc:FindFirstChildWhichIsA("Highlight")]
            hl:Destroy()
            hl = nil
        else
            local hl = BrokerHighlights[miscNpc:FindFirstChildWhichIsA("Highlight")]
            hl:Destroy()
            hl = nil
        end
    end
end)

local directory = workspace.Debris.Loot
local function keycardcheckInstance(Instance)
    local name = Instance.name:lower()
    if string.match(name,"keycard") or string.match(name,"operator") then -- and not string.match(name,"purple")
        return true
    else
        return false
    end
end

workspace.Debris.Loot.ChildAdded:Connect(function(Child)
    if Child.Name == "DeathBag" then
        coroutine.wrap(function()
            repeat task.wait() until Child:FindFirstChild("LootTable")
            if (#Child.LootTable:GetChildren()) > 0 then
                for i,loot in pairs(Child.LootTable:GetChildren()) do
                    local iskey = keycardcheckInstance(loot)
                    if iskey then
                        if getgenv().linolib then
                            getgenv().linolib:Notify("Item dropped: " .. loot.Name)
			end
                    end
                end
            end
        end)()
    end
end)

local function checkPlayer(Player)
    if Player:GetRankInGroup(6568965) > 1 then
        local soundy = Instance.new("Sound", game:GetService("CoreGui"))
		soundy.SoundId = "rbxassetid://247824088"
		soundy.PlaybackSpeed = 1
		soundy.Volume = 5
		soundy.Playing = true
		soundy:Play()
        game:GetService("Debris"):AddItem(soundy*2)
        if game:GetService("Players").LocalPlayer.PlayerGui.MainGui.PlayerStatus.Status.Combat.Visible then return end
       game.Players.LocalPlayer:Kick(Player.Name) 
    end 
end

for i,v in pairs(game.Players:GetPlayers()) do
    checkPlayer(v) 
end

Players.PlayerAdded:Connect(function(p)
    checkPlayer(p)
end)

if getgenv().RSConnection then getgenv().RSConnection:Disconnect() getgenv().RSConnection = nil end
if getgenv().Heartbeat then getgenv().Heartbeat:Disconnect() getgenv().Heartbeat = nil end
local getnearestdb = {}
local function getnearestplayer()
    --[[local Characters = workspace.Chars
    local Character = game.Players.LocalPlayer.Character
    if not Character then return end
    local MaxDistance = 250
    for i,v in pairs(Characters:GetChildren()) do
        print(v.Name)
        if v == Character then continue end
        pcall(function()
            if not v.PrimaryPart or not Character.PrimaryPart then return end
            if Magnitude(v.PrimaryPart,Character.PrimaryPart) < MaxDistance then
                print("h")
                CoreGui:SetCore("SendNotification", {
	            Title = getnearestdb[v].Name;
                Text =  " is nearby";
	            Duration = 3;})
                getnearestdb[v] = v
            else
                print("h3")
                if getnearestdb[v] then
                    print("h2")
                    CoreGui:SetCore("SendNotification", {
	                Title = getnearestdb[v].Name;
                    Text =  " is no longer nearby";
	                Duration = 3;})
                    getnearestdb[v] = nil
                end
            end
        end)
    end]]
end

--// for loops
for a,b in pairs(workspace.WaveSurvival.NPCs:GetChildren()) do
    table.insert(getgenv().NpcTable,b) 
end
for f,d in pairs(workspace.Arena:GetChildren()) do
   if d:FindFirstChild("Humanoid") then
       table.insert(getgenv().NpcTable,d)
    end
end
for _,v in pairs(workspace.ActiveTasks:GetChildren()) do
    
    for k,j in pairs(v:GetChildren()) do
        if j:FindFirstChild("Humanoid") then
            table.insert(getgenv().NpcTable,j)   
        end
    end
end
for i,v in pairs(workspace.NPCs.Hostile:GetChildren()) do
    table.insert(getgenv().NpcTable,v)
end
--// end of for loops

--// child addeds
workspace.WaveSurvival.NPCs.ChildAdded:Connect(function(Child)
    getgenv().NpcTable[Child] = Child
end)

workspace.Arena.ChildAdded:Connect(function(Child)
    if Child:FindFirstChild("Humanoid") then
        getgenv().NpcTable[Child] = Child
    end
end)

workspace.ActiveTasks.ChildAdded:Connect(function(Child)
    task.wait(1)
    for k,j in pairs(Child:GetChildren()) do
        if j:FindFirstChild("Humanoid") then
            getgenv().NpcTable[j] = j
        end
    end
end)

workspace.NPCs.Hostile.ChildAdded:Connect(function(Child)
    getgenv().NpcTable[Child] = Child
end)

workspace.Chars.ChildAdded:Connect(function(Child)
    task.wait(2)
    if Child:GetAttribute("DoubleJump") == true then
        --//detect
        local soundy = Instance.new("Sound", game:GetService("CoreGui"))
		soundy.SoundId = "rbxassetid://17043176239"
		soundy.PlaybackSpeed = 1
		soundy.Volume = 5
		soundy.Playing = true
		soundy:Play()
        game:GetService("Debris"):AddItem(soundy,soundy.TimeLength)
    end
end)

--// end of child added

--// child removed


workspace.WaveSurvival.NPCs.ChildRemoved:Connect(function(Child)
    if getgenv().NpcTable[Child] then
        getgenv().NpcTable[Child] = nil
    end
end)

workspace.Arena.ChildRemoved:Connect(function(Child)
    if Child:FindFirstChild("Humanoid") then
        if getgenv().NpcTable[Child] then
            getgenv().NpcTable[Child] = nil
        end
     end
end)

workspace.ActiveTasks.ChildRemoved:Connect(function(Child)
    for k,j in pairs(Child:GetChildren()) do
        if j:FindFirstChild("Humanoid") then
            if getgenv().NpcTable[j] then
                getgenv().NpcTable[j] = nil
            end
        end
    end
end)

workspace.NPCs.Hostile.ChildRemoved:Connect(function(Child)
    if getgenv().NpcTable[Child] then
        getgenv().NpcTable[Child] = nil
    end
end)

--// end of child removed

local function getclosestbrokerfarm() --// merchant, or broker
    local Character = game.Players.LocalPlayer.Character
    local MiscNpcPath = workspace.NPCs.Other
    local Closest,Distance

    for i,v in pairs(MiscNpcPath:GetChildren()) do

        if v.Name == "Broker" then
            if not Closest then
                Closest = v
                Distance = Magnitude(Character.PrimaryPart,v.PrimaryPart)
            else
                if Magnitude(Character.PrimaryPart,v.PrimaryPart)<Distance then
                    Closest = v
                    Distance = Magnitude(Character.PrimaryPart,v.PrimaryPart)
                end
            end
        end
    end
    return Closest
end

local function fireGetTask(Broker: Model)
    local args = {
        [1] = Broker:WaitForChild("HumanoidRootPart"),
        [2] = "MedicalAid"
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Stations"):WaitForChild("StartTask"):FireServer(unpack(args))    
end

workspace.ActiveTasks.ChildAdded:Connect(function(Child)
    if not getgenv().AutofarmMedic then return end

    local Pivot = game.Players.LocalPlayer.Character:GetPivot()

    task.wait(1)
    if not Child:FindFirstChild("Civilian") then return end
    local Civ = Child:FindFirstChild("Civilian")

    if Civ:GetAttribute("TargetPlayer") == game.Players.LocalPlayer.Name then
        game.Players.LocalPlayer.Character:PivotTo(Civ:GetPivot()*CFrame.new(0,-4.8,0))
        task.wait(1)
        local PP = Civ.HumanoidRootPart:WaitForChild("TalkWithNPC")
        fireproximityprompt(PP)
        task.wait(.5)
        local args = {
            [1] = "1: Rebels sent me, here to deliver some medical supplies."
        } 
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Dialogue"):WaitForChild("Event"):FireServer(unpack(args))
        local args = {
            [1] = "1: Glad I could help."
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Dialogue"):WaitForChild("Event"):FireServer(unpack(args))
        task.wait(.5)
        game.Players.LocalPlayer.Character:PivotTo(Pivot)
        task.wait(.2)
        local broker = getclosestbrokerfarm()
        fireGetTask(broker)
    end
end)


local function getClosestMiscNpc(Name: string) --// merchant, or broker
    local Character = game.Players.LocalPlayer.Character
    local MiscNpcPath = workspace.NPCs.Other
    local Closest,Distance

    for i,v in pairs(MiscNpcPath:GetChildren()) do

        if v.Name == Name then
            if not Closest then
                Closest = v
                Distance = Magnitude(Character.PrimaryPart,v.PrimaryPart)
            else
                if Magnitude(Character.PrimaryPart,v.PrimaryPart)<Distance then
                    Closest = v
                    Distance = Magnitude(Character.PrimaryPart,v.PrimaryPart)
                end
            end
        end
    end
    return Closest
end

local function getClosestTerminal()
    local Character = game.Players.LocalPlayer.Character
    local MiscNpcPath = workspace.Terminals
    local Closest,Distance

    for i,v in pairs(MiscNpcPath:GetChildren()) do

            if not Closest then
                Closest = v
                Distance = Magnitude(Character.PrimaryPart,v)
            else
                if Magnitude(Character.PrimaryPart,v)<Distance then
                    Closest = v
                    Distance = Magnitude(Character.PrimaryPart,v)
                end
            end
    end
    return Closest
end

local function getClosestNPC()
    local Character = game.Players.LocalPlayer.Character
    local ClosestNPC = nil
    local MaxDistance = 15

    for i, NPC in pairs(getgenv().NpcTable) do
        if not NPC.PrimaryPart then continue end
        local Mag = Magnitude(NPC.PrimaryPart,Character.PrimaryPart)
        if not ClosestNPC and Mag < MaxDistance then
            MaxDistance = Mag
            ClosestNPC = NPC
        elseif ClosestNPC and Mag < MaxDistance then
            MaxDistance = Mag
            ClosestNPC = NPC
        end
    end
    return ClosestNPC
end


local OldNameCall

--// here we hook the events..

OldNameCall = hookfunction(getrawmetatable(game).__namecall, function(Self, ...)
    local Args = { ... }
    if not checkcaller() then
        if Self.Name == "Ragdoll" and getgenv().AntiRagdoll then
            return
        end
        if Self.Name == "Damage" and getgenv().NoSelfDmg then
            if Args[1] ~= 1000 then
                return
            end
        end
        if Self.Name == "MinigameResult" and getgenv().HookLockpick then
            if not Args[2] then
                Args[2] = true
            end
        end
        if Self.Name == "Stamina" and getgenv().InfiniteStamina then
            return
        end
    end

    return OldNameCall(Self, unpack(Args))
end)

--// function for auras

getgenv().Heartbeat = RunService.Heartbeat:Connect(function()
    --// cleaner func   
    
end)

getgenv().RSConnection = RunService.RenderStepped:Connect(function(dt)
    local Character = game.Players.LocalPlayer.Character
    if not Character then return end
    if Character:GetAttribute("Sprinting") == true and getgenv().InfStam == true then
        Character:SetAttribute("Sprinting",false)
    end
    if Character:GetAttribute("BlockingCooldown") ~= false and getgenv().NoBlockCD == true then
        Character:SetAttribute("BlockingCooldown",false)
    end
    if getgenv().MeleeAura then
        local Target = getClosestNPC()
        if not Character:FindFirstChildWhichIsA("RayValue") then return end
        if not Target then return end
        if not Target.Humanoid then return end
        if Target.Humanoid.Health <= 0 then return end
        local Head = Target:WaitForChild("Head")
        game:GetService("ReplicatedStorage"):WaitForChild("MeleeStorage"):WaitForChild("Events"):WaitForChild("Swing"):InvokeServer()
        local args = {
            [1] = Head,
            [2] = Head:GetPivot().Position
        }

        game:GetService("ReplicatedStorage"):WaitForChild("MeleeStorage"):WaitForChild("Events"):WaitForChild("Hit"):FireServer(unpack(args))
    elseif getgenv().GunAura then
        local Target = getClosestNPC()
        local Character = game.Players.LocalPlayer.Character
        if not Character:FindFirstChildWhichIsA("RayValue") then return end
        if not Target then return end
        if not Target:FindFirstChild("Humanoid") then return end
        if Target.Humanoid.Health <= 0 then return end
        local Head = Target:WaitForChild("Head")
        local args = {
        [1] = Head.Position,
        [2] = Head:GetPivot(),
        [3] = 1,
        [4] = 1,
        [5] = 9027,
        [6] = 6964
        }

        game:GetService("ReplicatedStorage"):WaitForChild("GunStorage"):WaitForChild("Events"):WaitForChild("Shoot"):FireServer(unpack(args))

        local args = {
            [1] = Head,
            [2] = 6964
        }

        game:GetService("ReplicatedStorage"):WaitForChild("GunStorage"):WaitForChild("Events"):WaitForChild("Hit"):FireServer(unpack(args))
    end
end)

--// ui lib
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
getgenv().linolib = Library
Library:Notify("Loading...")
local loadtick = tick()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Blackout GUI [Private] | ' .. Players.LocalPlayer.UserId,
    Center = true, 
    AutoShow = true,
})

local Tabs = {
    ['Dev'] = Window:AddTab("Experimental"), 
    ['ESP'] = Window:AddTab("ESP [W.I.P]"), 
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local AuraBox = Tabs.Dev:AddLeftGroupbox('NPC-Auras')
local UniversalBox = Tabs.Dev:AddLeftGroupbox('Universal')
local MiscBox = Tabs.Dev:AddLeftGroupbox('Miscellaneous')
local TeleportsBox = Tabs.Dev:AddRightGroupbox('Teleports');
local VmBox = Tabs.Dev:AddRightGroupbox('Viewmodel');
local AFarmBox = Tabs.Dev:AddRightGroupbox('Auto-farm');
local ESPBox = Tabs.ESP:AddLeftGroupbox("ESP")
local MA,GA,AP,AR,AF,IS,NBCD,TXTBOX,VMTGL,VMSLD,PPS,AFM,NORECOI,ESPBUTTON,MERCESP,PLAYERESP,NOSPREAD,NOFLAS,SMMODE
VMTGL = VmBox:AddToggle('VmFX', {
    Text = 'Apply viewmodel effects',
    Default = false,
    Tooltip = 'Toggle for the effects.',
})
NORECOI = VmBox:AddToggle('NORECOIL', {
    Text = 'No recoil',
    Default = false,
    Tooltip = 'What the fuck do you think it does',
})
NOSPREAD = VmBox:AddToggle('NOSPREED', {
    Text = 'No spread.',
    Default = false,
    Tooltip = 'What the fuck do you think it does',
})
VMSLD = VmBox:AddSlider('VMTRANSSLID', {
    Text = 'Viewmodel gun transparency',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 1,

    Compact = false, 
})
TXTBOX = VmBox:AddInput('VMBOX', {
    Default = 'ForceField',
    Numeric = false,
    Finished = true,

    Text = 'Material for custom viewmodel.',
    Tooltip = '',

    Placeholder = '',
})
ESPBUTTON = ESPBox:AddToggle('BrokESP', {
    Text = 'Broker-ESP',
    Default = false,
    Tooltip = 'Broker ESP',
})
MERCESP = ESPBox:AddToggle('CockESP', {
    Text = 'Merchant-ESP',
    Default = false,
    Tooltip = 'Merchant ESP',
})
PLAYERESP = ESPBox:AddToggle('PESP', {
    Text = 'Player-ESP',
    Default = false,
    Tooltip = 'Player ESP',
})
TXTBOX:OnChanged(function()
    getgenv().VMMAT = TXTBOX.Value
end)
VMSLD:OnChanged(function()
    getgenv().VMTRANS = VMSLD.Value
end)
MA = AuraBox:AddToggle('MeleeAura', {
    Text = 'Melee-Aura',
    Default = false,
    Tooltip = 'Melee aura for NPCs',
})
PPS = MiscBox:AddToggle('InstantPrompt', {
    Text = 'Instant-Prompt',
    Default = false,
    Tooltip = 'Instant proximity prompt use.',
})
IS = MiscBox:AddToggle('InfStam', {
    Text = 'Infinite-Stamina',
    Default = false,
    Tooltip = "No stamina lost while sprinting",
})
NOFLAS = MiscBox:AddToggle('NOFLASH', {
    Text = 'Anti-Flash',
    Default = false,
    Tooltip = "No flash effect.",
})
NBCD = MiscBox:AddToggle('BlockCD', {
    Text = 'Anti-Block Cooldown',
    Default = false,
    Tooltip = "No block cooldown",
})
GA = AuraBox:AddToggle('GunAura', {
    Text = 'Gun-Aura',
    Default = false,
    Tooltip = 'Gun aura for NPCs',
})
AP = MiscBox:AddToggle('AutoPick', {
    Text = 'Auto-lockpick',
    Default = false,
    Tooltip = 'Automatically lockpicks containers.',
})
AR = MiscBox:AddToggle('AntiRagdoll', {
    Text = 'Anti-Ragdoll',
    Default = false,
    Tooltip = 'Hooks the ragdoll remote event [USEFUL FOR FLYING].',
})
AF = MiscBox:AddToggle('AntiFall', {
    Text = 'No environment damage',
    Default = false,
    Tooltip = 'Removes fall damage, and other types of self damage\n while allowing you to reset.',
})
SMMODE = MiscBox:AddToggle('StreamerMode', {
    Text = 'Streamer-mode',
    Default = false,
    Tooltip = 'Hides info.',
})

AFM = AFarmBox:AddToggle('AUTOMEDIC', {
    Text = 'Auto-farm',
    Default = false,
    Tooltip = 'Automatically farms broker quests.',
})

UniversalBox:AddButton('Unnamed-Esp', function() loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua'))() end)
UniversalBox:AddButton('IY', function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end)

TeleportsBox:AddButton('Teleport to closest broker', 
function() 
    local ClosestBroker = getClosestMiscNpc("Broker")
    if ClosestBroker then
        Players.LocalPlayer.Character:PivotTo(ClosestBroker:GetPivot())
    end
end)
TeleportsBox:AddButton('Teleport to closest merchant', 
function()
    local ClosestMerchant = getClosestMiscNpc("Merchant")
    if ClosestMerchant then
        Players.LocalPlayer.Character:PivotTo(ClosestMerchant:GetPivot())
    end
end)
TeleportsBox:AddButton('Teleport to closest terminal', 
function()
    local ClosestMerchant = getClosestTerminal()
    if ClosestMerchant then
        Players.LocalPlayer.Character:PivotTo(ClosestMerchant:GetPivot())
    end
end)
SMMODE:OnChanged(function()
    getgenv().streamermode = SMMODE.Value
    spoofServerInfo(SMMODE.Value)
    if SMMODE.Value == true then
        spoofLevel()
    else
        --// here we disconnect the connections.. get it ? 
        
    end


end)
VMTGL:OnChanged(function()
    getgenv().VmFX = VMTGL.Value
end)
NORECOI:OnChanged(function()
    getgenv().NOREC = NORECOI.Value
end)
NOSPREAD:OnChanged(function()
    getgenv().NOSPR = NOSPREAD.Value
end)
PPS:OnChanged(function()
    getgenv().IP = PPS.Value
end)
MA:OnChanged(function()
    getgenv().MeleeAura = MA.Value
end)
NBCD:OnChanged(function()
    getgenv().NoBlockCD = NBCD.Value
end)
IS:OnChanged(function()
    getgenv().InfStam = IS.Value
end)
GA:OnChanged(function()
    getgenv().GunAura = GA.Value
end)
AP:OnChanged(function()
    getgenv().HookLockpick = AP.Value
end)
AR:OnChanged(function()
    getgenv().AntiRagdoll = AR.Value
end)
AF:OnChanged(function()
    getgenv().NoSelfDmg = AF.Value
end)
AFM:OnChanged(function()
    getgenv().AutofarmMedic = AFM.Value
end)
ESPBUTTON:OnChanged(function()
    getgenv().BESP = ESPBUTTON.Value
    for i, highlight in pairs(BrokerHighlights) do
        highlight.Enabled = ESPBUTTON.Value
    end
end)
NOFLAS:OnChanged(function()
    if NOFLAS.Value then
        FlashConnection:Disable()
    else
        FlashConnection:Enable()
    end
end)

MERCESP:OnChanged(function()
    getgenv().MESP = MERCESP.Value
    for i, highlight in pairs(MerchantHighlights) do
        highlight.Enabled = MERCESP.Value
    end
end)


Library:SetWatermarkVisibility(false)
Library.KeybindFrame.Visible = false;

Library:OnUnload(function()
    Library.Unloaded = true
    getgenv().aliveloaded = false
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end) 
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightAlt', NoUI = true, Text = 'Menu keybind' }) 

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings() 
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')
SaveManager:BuildConfigSection(Tabs['UI Settings']) 
ThemeManager:ApplyToTab(Tabs['UI Settings'])

Library:Notify("Loaded! Took: " .. tostring(tick()-loadtick))
