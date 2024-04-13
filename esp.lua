    --// as of 4/13/24 this will no longer be used and will be integrated into main hub
    local Players = game:GetService("Players") -- // bypass renaming
    local Player = game.Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local ESP_Data = {} --[[
    format:

    ESP_Data[Player] = {["RS"] = connection;["DRAWINGINSTANCES"] = {}}

    ]]

    local function cleanUpCheck(index) --// i love bieng abloe t oclean uyp
        if ESP_Data[index] then

            ESP_Data[index]["RS"]:Disconnect()
            
            for i, DrawnInstance in pairs(ESP_Data[index]["DRAWINGINSTANCES"]) do
                DrawnInstance:Destroy()
            end

            ESP_Data[index] = nil

        end
    end
    --// fancy schmancy function above

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

        table.insert(Data["DRAWINGINSTANCES"],BoxEsp)
        table.insert(Data["DRAWINGINSTANCES"],Text)

        local RunServiceConnection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        
            if Plr.Character then
                
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
                        Text.Position = Vector2.new(HeadPos.X,RootPos.Y-20) --// note to self: vector2 is measured in PIXELS, adding 0.5 pixels won't change much
                                                                            --// UPDATE TO NOTE: why the fuck do i have to subtract to increase y?
                        Text.Visible = true                                 --// reference for later: vectorToWorldSpace(self._cameraCFrame, vector3New(...)),
                    else

                        BoxEsp.Visible = false
                        Text.Visible = false

                    end
                else
                    Text.Visible = false
                    BoxEsp.Visible = false
                end
            else

                Text.Visible = false
                BoxEsp.Visible = false

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
--// i do NOT remember making these
