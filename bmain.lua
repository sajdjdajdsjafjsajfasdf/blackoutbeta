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
getgenv().NoStaminaLoss = false
getgenv().HasDoubleJump = false
getgenv().InfStam = false
getgenv().NoBlockCD = false
getgenv().NpcTable = {}


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
        if game:GetService("Players").LocalPlayer.PlayerGui.MainGui.PlayerStatus.Status.Combat.Visible then return end
       game.Players.LocalPlayer:Kick() 
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
    for k,j in pairs(Child:GetChildren()) do
        if j:FindFirstChild("Humanoid") then
            getgenv().NpcTable[j] = j
        end
    end
end)

workspace.NPCs.Hostile.ChildAdded:Connect(function(Child)
    getgenv().NpcTable[Child] = Child
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

local function getClosestCharacter()
    local Character = game.Players.LocalPlayer.Character
    if not Character then return end
    local ClosestTarget = nil
    local Distance
    for i,v in pairs(getgenv().NpcTable) do

        if v == Character then continue end
        if not ClosestTarget then
            if Magnitude(Character.PrimaryPart,v.PrimaryPart) > 15 then continue end
            ClosestTarget = v
            Distance = Magnitude(Character.PrimaryPart,v.PrimaryPart)
        else
            if Magnitude(Character.PrimaryPart,v.PrimaryPart)<Distance then
                warn(ClosestTarget,v)
                ClosestTarget = v
                Distance = Magnitude(Character.PrimaryPart,v.PrimaryPart)
            end
        end
    end
    return ClosestTarget
end

local function fireAllGuns()
    warn("FIRE-TEST")
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
            return
        end
        if Self.Name == "MinigameResult" and getgenv().HookLockpick then
            if not Args[2] then
                Args[2] = true
            end
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
        local Target = getClosestCharacter()
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
        local Target = getClosestCharacter()
        local Character = game.Players.LocalPlayer.Character
        if not Character:FindFirstChildWhichIsA("RayValue") then return end
        if not Target then return end
        if not Target.Humanoid then return end
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
    Title = 'Blackout GUI [Private]',
    Center = true, 
    AutoShow = true,
})

local Tabs = {
    ['Dev'] = Window:AddTab("Experimental"), 
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local ExperimentalLeftBox = Tabs.Dev:AddLeftGroupbox('Experimental')
local MA,GA,AP,AR,AF,IS,NBCD
MA = ExperimentalLeftBox:AddToggle('MeleeAura', {
    Text = 'Melee-Aura',
    Default = false,
    Tooltip = 'Melee aura for NPCs [Works only with npcs under "Hostiles"]',
})
IS = ExperimentalLeftBox:AddToggle('InfStam', {
    Text = 'Infinite-Stamina',
    Default = false,
    Tooltip = "No stamina lost while sprinting",
})
NBCD = ExperimentalLeftBox:AddToggle('BlockCD', {
    Text = 'Anti-Block Cooldown',
    Default = false,
    Tooltip = "No block cooldown",
})
GA = ExperimentalLeftBox:AddToggle('GunAura', {
    Text = 'Gun-Aura',
    Default = false,
    Tooltip = 'Gun aura for NPCs [Works only with npcs under "Hostiles"]',
})
AP = ExperimentalLeftBox:AddToggle('AutoPick', {
    Text = 'Auto-lockpick',
    Default = false,
    Tooltip = 'Automatically lockpicks containers.',
})
AR = ExperimentalLeftBox:AddToggle('AntiRagdoll', {
    Text = 'Anti-Ragdoll',
    Default = false,
    Tooltip = 'Hooks the ragdoll remote event [USEFUL FOR FLYING].',
})
AF = ExperimentalLeftBox:AddToggle('AntiFall', {
    Text = 'No fall damage',
    Default = false,
    Tooltip = 'Removes fall damage while allowing you to reset.',
})
ExperimentalLeftBox:AddDivider()

ExperimentalLeftBox:AddButton('Unnamed-Esp', function() loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua'))() end)
ExperimentalLeftBox:AddButton('Infinite-Yield', function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end)
ExperimentalLeftBox:AddButton('Gun Farm DOESNT WORK',function() fireAllGuns() end)

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
