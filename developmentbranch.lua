
--//services

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("StarterGui")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if not Player.Character then return end

--// quick loaded check

if getgenv().aliveloaded then return end
getgenv().aliveloaded = true
local loadtick = tick()

local audioTable = {"17174178755","17174179860","17174181687","17174183278","17174184602","17174187473"}

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
getgenv().PTAG = nil
getgenv().PESPTOG = false
getgenv().BulletProperties = {
    ["Brightness"] = 3;
    ["LightEmission"] = 1;
    ["LightInfluence"] = 0;
    ["Texture"] = "rbxassetid://8923063235";
    ["TextureLength"] = 1;
    ["TextureMode"]  = Enum.TextureMode.Stretch;
    ["TextureSpeed"] = 0;
    ["Color"] = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 0)),
        ColorSequenceKeypoint.new(1, Color3.new(0, 0, 1))
    }); --// workspace.Debris.Guns.Default.Beam.Color;
    ["Transparency"] = workspace.Debris.Guns.Default.Beam.Transparency;
    ["ZOffset"] = 0;
    ["CurveSize0"] = 0;
    ["CurveSize1"] = 0;
    ["FaceCamera"] = true;
    ["Segments"] = 1;
    ["Width0"] = 0.75;
    ["Width1"] = 0.75
    
}
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
local Prompt_Data = {} --// we store connections for the prompttriggered events here
    local ESP_Data = {} --[[
    format:

    ESP_Data[Player] = {["RS"] = connection;["DRAWINGINSTANCES"] = {}}

    ]]

    local function cleanUpCheck(index)
        if ESP_Data[index] then

            ESP_Data[index]["RS"]:Disconnect()
            
            for i, DrawnInstance in pairs(ESP_Data[index]["DRAWINGINSTANCES"]) do
                DrawnInstance:Destroy()
            end

            ESP_Data[index] = nil

        end
    end

    local function createNewEsp(Plr)
        if Plr == Player then return end

        cleanUpCheck(Plr)

        ESP_Data[Plr] = {}
        local Data = ESP_Data[Plr]
        Data["DRAWINGINSTANCES"] = {}

        local BoxEsp = Drawing.new("Square")
        BoxEsp.Visible = false
        BoxEsp.Color = Color3.fromRGB(255,255,255)
        BoxEsp.Thickness = 1
        BoxEsp.Filled = false
        local Text = Drawing.new("Text")
        Text.Text = Plr.Name
        Text.Size = 12.5
        Text.Color = Color3.fromRGB(255,255,255)
        Text.Visible = false
        Text.Center = true
        local TextWeapon = Drawing.new("Text")
        TextWeapon.Text = ""
        TextWeapon.Size = 12.5
        TextWeapon.Color = Color3.fromRGB(255,255,255)
        TextWeapon.Visible = false
        TextWeapon.Center = true

        table.insert(Data["DRAWINGINSTANCES"],BoxEsp)
        table.insert(Data["DRAWINGINSTANCES"],Text)
        table.insert(Data["DRAWINGINSTANCES"],TextWeapon)

        local RunServiceConnection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        
            if Plr.Character then
                if not Plr.Character:FindFirstChild("Humanoid") then BoxEsp.Visible = false return end
                if not Plr.Character:FindFirstChild("Head") then BoxEsp.Visible = false return end
                if not Plr.Character:FindFirstChild("HumanoidRootPart") then BoxEsp.Visible = false return end
                if getgenv().ESPEnabled then
                    local Vector,IsOnScreen = Camera:WorldToViewportPoint(Plr.Character:GetPivot().Position)
                    local Root = Plr.Character:WaitForChild("HumanoidRootPart")
                    local Head = Plr.Character:WaitForChild("Head")
                    local RootPos,RootVis = Camera:WorldToViewportPoint(Root.Position)
                    local HeadPos = Camera:WorldToViewportPoint(Head.Position+Vector3.new(0,0.5,0))
                    local LegPos = Camera:WorldToViewportPoint(Root.Position-Vector3.new(0,3,0))

                    if IsOnScreen then

                        BoxEsp.Size = Vector2.new(500/RootPos.Z,HeadPos.Y-LegPos.Y) --// math , math and math! credits to 0x83
                        BoxEsp.Position = Vector2.new(RootPos.X-BoxEsp.Size.X/2,RootPos.Y-BoxEsp.Size.Y/2)
                        BoxEsp.Visible = true
                        local Health = Plr.Character:FindFirstChild("Humanoid").Health
                        local MaxHealth = Plr.Character:FindFirstChild("Humanoid").MaxHealth

                        Health = tostring(Health)

                        if string.match(Health,".") then
                            Health = string.split(Health,".")[1]
                        end

                        Text.Text = Plr.Name .. " | " .. tostring(Health).. "/".. tostring(MaxHealth)
                        Text.Position = Vector2.new(HeadPos.X,RootPos.Y-20) --// note to self: vector2 is measured in PIXELS, adding 0.5 pixels won't change much
                                                                            --// UPDATE TO NOTE: why the fuck do i have to subtract to increase y?
                        Text.Visible = true                                 --// reference for later: vectorToWorldSpace(self._cameraCFrame, vector3New(...)),
                        if Plr.Character:FindFirstChildWhichIsA("RayValue") then
                            local Magazine,Max = nil,nil
                            --// something equipped
                            local RayValue = Plr.Character:FindFirstChildWhichIsA("RayValue")
                            if RayValue:FindFirstChild("GunStatus") then
                                Magazine = RayValue:FindFirstChild("GunStatus"):GetAttribute("Magazine")
                                Max = RayValue:FindFirstChild("GunStatus"):GetAttribute("MagazineCapacity")
                            end


                            if Magazine and Max then
                                TextWeapon.Text = RayValue.Name .. "[" .. tostring(Magazine) .. "/" .. tostring(Max) .. "]"
                            else
                                TextWeapon.Text = RayValue.Name
                            end
                            TextWeapon.Visible = true
                            TextWeapon.Position = Vector2.new(HeadPos.X,RootPos.Y+20)
                        else
                            if TextWeapon.Visible then
                                TextWeapon.Visible = false
                            end
                        end
                    else

                        BoxEsp.Visible = false
                        Text.Visible = false
                        TextWeapon.Visible = false
                    end
                else
                    Text.Visible = false
                    BoxEsp.Visible = false
                    TextWeapon.Visible = false
                end
            else

                Text.Visible = false
                BoxEsp.Visible = false
                TextWeapon.Visible = false
            end
        end)

        Data["RS"] = RunServiceConnection
    end

for i, Plrs in pairs(Players:GetChildren()) do 
    createNewEsp(Plrs)
end
Players.PlayerAdded:Connect(function(Player)
    createNewEsp(Player)
end)

Players.PlayerRemoving:Connect(function(player)
    cleanUpCheck(player)
end)

for i, connection in pairs(getconnections(game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("Flashbang").OnClientEvent)) do
    FlashConnection = connection
end
local StaticUI = game:GetService("Players").LocalPlayer.PlayerGui.MainStaticGui
local LBUI = game:GetService("Players").LocalPlayer.PlayerGui.MainStaticGui.RightTab.Leaderboard
local PlayerList = LBUI.PlayerList
local function hidePlayerLB()
    if PlayerList:FindFirstChild(Player.Name) then
        PlayerList:FindFirstChild(Player.Name).Parent = StaticUI:FindFirstChild("StaticCore")
    end
end
local function unHidePlayerLB()
    if StaticUI:FindFirstChild("StaticCore"):FindFirstChild(Player.Name) then
        StaticUI:FindFirstChild("StaticCore"):FindFirstChild(Player.Name).Parent = PlayerList
    end
end

local PlayerListConnections = {}
--[[
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
]]

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
    if Prompt.Style == Enum.ProximityPromptStyle.Custom then
        if getgenv().IP then
            if Prompt.HoldDuration ~= 0 then
            Prompt:SetAttribute("Original",Prompt.HoldDuration)
                Prompt.HoldDuration = 0
            end
        end
        if Prompt.Parent.Name == "LootBase" and Prompt.Name == "OpenLootTable" then
            
            --[[if Prompt_Data[Prompt] then
                Prompt_Data[Prompt]:Disconnect()
                Prompt_Data[Prompt] = nil
            end
            Prompt_Data[Prompt] = Prompt.Triggered:Connect(function()
                if getgenv().AutoLockpick then
                    local args = {
                        [1] = Prompt.Parent.Parent
                        [2] = true
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Loot"):WaitForChild("MinigameResult"):FireServer(unpack(args))
                end
            end)]]
        end
    end
end)
game:GetService("ProximityPromptService").PromptHidden:Connect(function(Prompt)
    if Prompt.Style == Enum.ProximityPromptStyle.Custom and getgenv().IP then
        if Prompt.HoldDuration == 0 then
	    if not Prompt:GetAttribute("Original") then return end
            Prompt.HoldDuration = Prompt:GetAttribute("Original")
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
        if typeof(data) == "table" and (rawget(data, "Shell") or rawget(data, "Projectile")) then
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
            if Child:FindFirstChild("Attachments") then
                for i, Parts in pairs(Child:FindFirstChild("Attachments"):GetChildren()) do
                    if Parts:IsA("Folder") then
                        for i, Folder in pairs(Parts:GetChildren()) do
                            for i, Children in pairs(Folder:GetChildren()) do
                                if Children:FindFirstChild("SurfaceAppearance") then
                                    Children:FindFirstChild("SurfaceAppearance"):Destroy()
                                end
                                Children.Transparency = getgenv().VMTRANS
                                Children.Material = Material
                            end
                        end
                    end
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
    if Child.Name == "DeathBag" or Child.Name == "DuffelBag" then
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
        game:GetService("Debris"):AddItem(soundy, soundy.TimeLength*2)
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
        if v == Character then continue end
        pcall(function()
            if not v.PrimaryPart or not Character.PrimaryPart then return end
            if Magnitude(v.PrimaryPart,Character.PrimaryPart) < MaxDistance then
                CoreGui:SetCore("SendNotification", {
	            Title = getnearestdb[v].Name;
                Text =  " is nearby";
	            Duration = 3;})
                getnearestdb[v] = v
            else
                if getnearestdb[v] then
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

local HeartbeatDebounce

getgenv().Heartbeat = RunService.Heartbeat:Connect(function()
    --// cleaner func    because the one below is so ASS
    if getgenv().PESPTOG and not HeartbeatDebounce then
        if not getgenv().PTAG then return end
        if not getgenv().PTAG.Character then return end
        HeartbeatDebounce = true
        local CharacterPosition = getgenv().PTAG.Character:GetPivot().Position
        local args = {
            [1] = CharacterPosition
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Party"):WaitForChild("Ping"):FireServer(unpack(args)) 
        task.wait(1)
        HeartbeatDebounce = false       
    end
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
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Revived Hub [Private]',
    Center = true, 
    AutoShow = true,
})

local Tabs = {
    ['Dev'] = Window:AddTab("Experimental"), 
    ['ESP'] = Window:AddTab("ESP"), 
    ['SPOOF'] = Window:AddTab("Spoofer"),
    ['STREAM'] = Window:AddTab("Streamer"),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local AuraBox = Tabs.Dev:AddLeftGroupbox('NPC-Auras')
local UniversalBox = Tabs.Dev:AddLeftGroupbox('Universal')
local MiscBox = Tabs.Dev:AddLeftGroupbox('Miscellaneous')
local AutoBox = Tabs.Dev:AddLeftGroupbox('Automation')
local TeleportsBox = Tabs.Dev:AddRightGroupbox('Teleports');
local BulletSpoofer = Tabs.SPOOF:AddRightGroupbox('Bullet tracers');
local VmBox = Tabs.Dev:AddRightGroupbox('Viewmodel');
local AFarmBox = Tabs.Dev:AddRightGroupbox('Auto-farm');
local ESPBox = Tabs.ESP:AddLeftGroupbox("ESP")
local SpoofBox = Tabs.STREAM:AddLeftGroupbox("Spoofers [STREAMER ONES]")
local MA,GA,AP,AR,AF,IS,NBCD,TXTBOX,VMTGL,VMSLD,PPS,AFM,NORECOI,ESPBUTTON,MERCESP,PLAYERESP,NOSPREAD,NOFLAS,SMMODE,AUBOX,GPEBOX,GPETOG,SPB
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
AutoBox:AddButton('Broker quick start', function()
    if getgenv().AUTOMISSION then
        local ClosestBroker = getClosestMiscNpc("Broker")

        local args = {
            [1] = ClosestBroker:WaitForChild("HumanoidRootPart"),
            [2] = tostring(getgenv().AUTOMISSION)
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Stations"):WaitForChild("StartTask"):FireServer(unpack(args))
    end
end)
AUBOX = AutoBox:AddInput('BBBOX', {
    Default = 'StealCargo',
    Numeric = false,
    Finished = true,

    Text = 'Mission to start',
    Tooltip = '',

    Placeholder = '',
})
GPETOG = ESPBox:AddToggle('GPETOGGLE', {
    Text = 'Global player ESP',
    Default = false,
    Tooltip = 'Global player esp',
})
GPEBOX = ESPBox:AddInput('PlayerToGlobalESP', {
    Default = Player.Name,
    Numeric = false,
    Finished = true,

    Text = 'Global player ESP [works through party]',
    Tooltip = 'Global player ESP [works through party]',

    Placeholder = '',
})
PLAYERESP = ESPBox:AddToggle('PESP', {
    Text = 'Player-ESP',
    Default = false,
    Tooltip = 'Player ESP',
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
TXTBOX:OnChanged(function()
    getgenv().VMMAT = TXTBOX.Value
end)
AUBOX:OnChanged(function()
    getgenv().AUTOMISSION = AUBOX.Value
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


AFM = AFarmBox:AddToggle('AUTOMEDIC', {
    Text = 'Auto-farm',
    Default = false,
    Tooltip = 'Automatically farms broker quests.',
})
SPB = SpoofBox:AddToggle('HIDEPLAYEER', {
    Text = 'Hide player on leaderboard',
    Default = false,
    Tooltip = 'Hides local players ui button.',
})


--//UniversalBox:AddButton('Unnamed-Esp', function() loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua'))() end)
UniversalBox:AddButton('IY', function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end)
BulletSpoofer:AddButton('Apply effects.', function()

    for i, Bullet in pairs(workspace.Debris.Guns:GetChildren()) do
        if Bullet.Name == "Default" then


            for i, BulletProperty in pairs(getgenv().BulletProperties) do
                Bullet:FindFirstChild("Beam")[i] = BulletProperty
            end
        end
    end

end)

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

--// procedural attribute changer
local Directories = {game.ReplicatedStorage,game.Players.LocalPlayer.PlayerGui}
for _,Directory in pairs(Directories) do
    local UISpoofBox = Tabs.SPOOF:AddLeftGroupbox(Directory.Name)
    for i, Attribute in pairs(Directory:GetAttributes()) do
        if typeof(Attribute) == "number" then
            local NewButton = UISpoofBox:AddInput(tostring(i), {
                Default = Attribute,
                Numeric = true,
                Finished = true,
            
                Text = tostring(i),
                Tooltip = '',
            
                Placeholder = '',
            })
            NewButton:OnChanged(function()
                Directory:SetAttribute(i,tonumber(NewButton.Value))
            end)
        elseif typeof(Attribute) == "string" then
            local NewButton = UISpoofBox:AddInput(tostring(i), {
                Default = Attribute,
                Numeric = false,
                Finished = true,
            
                Text = tostring(i),
                Tooltip = '',
            
                Placeholder = '',
            })
            NewButton:OnChanged(function()
                Directory:SetAttribute(i,tostring(NewButton.Value))
            end)
        end
    end
    
end

--// procedural bullet mods
for i, Property in pairs(getgenv().BulletProperties) do 
    if typeof(Property) == "boolean" then
        local Toggle = BulletSpoofer:AddToggle(i,{
            Text = i,
            Default = Property,
            ToolTip = i,
        })
        Toggle:OnChanged(function()
            getgenv().BulletProperties[i] = Toggle.Value
        end)

    elseif typeof(Property) == "number" then
        local Toggle = BulletSpoofer:AddInput(i,{
            Default = tostring(Property),
            Numeric = true;
            Finished = true;
            Text = i,
            ToolTip = i,
            Placeholder = '',
        })
        Toggle:OnChanged(function()
            getgenv().BulletProperties[i] = Toggle.Value
        end)
    elseif typeof(Property) == "string" then -- Added missing "then" here
        local Toggle = BulletSpoofer:AddInput(i,{
            Default = tostring(Property),
            Numeric = false;
            Finished = true;
            Text = i,
            ToolTip = i,
            Placeholder = '',
        })
        Toggle:OnChanged(function()
            getgenv().BulletProperties[i] = Toggle.Value
        end)
    end
end

SPB:OnChanged(function()
    if SPB.Value == true then
        hidePlayerLB()
    else
        unHidePlayerLB()
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
GPETOG:OnChanged(function()
    getgenv().PESPTOG = GPETOG.Value
end)
GPEBOX:OnChanged(function()
    if not game.Players[GPEBOX.Value] then return end
    getgenv().PTAG = game.Players[GPEBOX.Value]
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
PLAYERESP:OnChanged(function()
    getgenv().ESPEnabled = PLAYERESP.Value
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
local soundy = Instance.new("Sound", game:GetService("CoreGui"))
soundy.SoundId = "rbxassetid://" .. tostring(audioTable[math.random(1,#audioTable)])
soundy.PlaybackSpeed = 1
soundy.Volume = 5
soundy.Playing = true
soundy:Play()
game:GetService("Debris"):AddItem(soundy, soundy.TimeLength*2)
Library:Notify("Loaded! Took: " .. tostring(tick()-loadtick))
