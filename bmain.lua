if game.PlaceId ~= 15432890326 then return end
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

game:GetService("ProximityPromptService").PromptShown:Connect(function(Prompt)
    if Prompt.Style == Enum.ProximityPromptStyle.Custom then
        if Prompt.HoldDuration ~= 0 then
            Prompt.HoldDuration = 0
        end
    end
end)

workspace.CurrentCamera.ChildAdded:Connect(function(Child)
    if Child.Name == "ViewModel" and getgenv().VmFX then
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
end)


--//misc
local directory = workspace.Debris.Loot
local function keycardcheckInstance(Instance)
    local name = Instance.name:lower()
    if string.match(name,"keycard") and not string.match(name,"purple") then
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
                        local Highlight = Instance.new("Highlight",Child)
                        game:GetService("Debris"):AddItem(Highlight,30)
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
local function Magnitude(Part1,Part2)
    if not Part1 or not Part2 then return 0 end
    if not Part1:IsA("BasePart") or not Part2:IsA("BasePart") then return 0 end
    return (Part1.Position-Part2.Position).Magnitude
end
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
    print(b.Name)
end
for f,d in pairs(workspace.Arena:GetChildren()) do
   if d:FindFirstChild("Humanoid") then
       table.insert(getgenv().NpcTable,d)
       print(d.Name)
    end
end
for _,v in pairs(workspace.ActiveTasks:GetChildren()) do
    
    for k,j in pairs(v:GetChildren()) do
        if j:FindFirstChild("Humanoid") then
            table.insert(getgenv().NpcTable,j)   
            print(j.Name)
        end
    end
end
for i,v in pairs(workspace.NPCs.Hostile:GetChildren()) do
    table.insert(getgenv().NpcTable,v)
    print(v.Name)
end
--// end of for loops

--// child addeds
workspace.WaveSurvival.NPCs.ChildAdded:Connect(function(Child)
    getgenv().NpcTable[Child] = Child
    print(Child.Name)
end)

workspace.Arena.ChildAdded:Connect(function(Child)
    if Child:FindFirstChild("Humanoid") then
        getgenv().NpcTable[Child] = Child
        print(Child.Name)
    end
end)

workspace.ActiveTasks.ChildAdded:Connect(function(Child)
    for k,j in pairs(Child:GetChildren()) do
        if j:FindFirstChild("Humanoid") then
            getgenv().NpcTable[j] = j
            print(j.Name)
        end
    end
end)

workspace.NPCs.Hostile.ChildAdded:Connect(function(Child)
    getgenv().NpcTable[Child] = Child
    print(Child.Name)
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
        warn(Child.Name)
        getgenv().NpcTable[Child] = nil
    end
end)

workspace.Arena.ChildRemoved:Connect(function(Child)
    if Child:FindFirstChild("Humanoid") then
        if getgenv().NpcTable[Child] then
            warn(Child.Name)
            getgenv().NpcTable[Child] = nil
        end
     end
end)

workspace.ActiveTasks.ChildRemoved:Connect(function(Child)
    for k,j in pairs(Child:GetChildren()) do
        if j:FindFirstChild("Humanoid") then
            if getgenv().NpcTable[j] then
                warn(j.Name)
                getgenv().NpcTable[j] = nil
            end
        end
    end
end)

workspace.NPCs.Hostile.ChildRemoved:Connect(function(Child)
    if getgenv().NpcTable[Child] then
        warn(Child.Name)
        getgenv().NpcTable[Child] = nil
    end
end)

--// end of child removed

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

local AuraBox = Tabs.Dev:AddLeftGroupbox('Auras')
local UniversalBox = Tabs.Dev:AddLeftGroupbox('Universal')
local MiscBox = Tabs.Dev:AddLeftGroupbox('Miscellaneous')
local TeleportsBox = Tabs.Dev:AddRightGroupbox('Teleports');
local VmBox = Tabs.Dev:AddRightGroupbox('Viewmodel');
local MA,GA,AP,AR,AF,IS,NBCD,TXTBOX,VMTGL,VMSLD,PPS
VMTGL = VmBox:AddToggle('VmFX', {
    Text = 'Apply viewmodel effects',
    Default = false,
    Tooltip = 'Toggle for the effects.',
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

UniversalBox:AddButton('Unnamed-Esp', function() loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua'))() end)
UniversalBox:AddButton('Infinite-Yield', function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end)

TeleportsBox:AddButton('Teleport to closest broker', 
function() 
    local ClosestBroker = getClosestMiscNpc("Broker")
    print(ClosestBroker)
    if ClosestBroker then
        Players.LocalPlayer.Character:PivotTo(ClosestBroker:GetPivot())
    end
end)
TeleportsBox:AddButton('Teleport to closest merchant', 
function()
    local ClosestMerchant = getClosestMiscNpc("Merchant")
    print(ClosestMerchant)
    if ClosestMerchant then
        Players.LocalPlayer.Character:PivotTo(ClosestMerchant:GetPivot())
    end
end)
TeleportsBox:AddButton('Teleport to closest terminal', 
function()
    local ClosestMerchant = getClosestTerminal()
    print(ClosestMerchant)
    if ClosestMerchant then
        Players.LocalPlayer.Character:PivotTo(ClosestMerchant:GetPivot())
    end
end)

VMTGL:OnChanged(function()
    getgenv().VmFX = VMTGL.Value
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

Library:SetWatermarkVisibility(false)
Library.KeybindFrame.Visible = false;

Library:OnUnload(function()
    Library.Unloaded = true
    getgenv().aliveloaded = false
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end) 
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'Insert', NoUI = true, Text = 'Menu keybind' }) 

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings() 
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')
SaveManager:BuildConfigSection(Tabs['UI Settings']) 
ThemeManager:ApplyToTab(Tabs['UI Settings'])
