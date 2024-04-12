    --// beta build for esp for blackout gui
    local Players = game:GetService("Players") -- // bypass renaming
    local Player = game.Players.LocalPlayer
    local Camera = workspace.CurrentCamera

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
        Text.Size = 25
        Text.Color = Color3.fromRGB(255,255,255)
        Text.Visible = false
        Text.Center = true

        table.insert(Data["DRAWINGINSTANCES"],BoxEsp)
        table.insert(Data["DRAWINGINSTANCES"],Text)

        local RunServiceConnection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        
            if Plr.Character then
                
                local Vector,IsOnScreen = Camera:WorldToViewportPoint(Plr.Character:GetPivot().Position)

                if IsOnScreen then --// mfw the script doesnt work because i named this is on screen and not on screen (i fuck up variables)

                    BoxEsp.Size = Vector2.new(10,25)
                    BoxEsp.Position = Vector2.new(Vector.X-4,Vector.Y+2)
                    BoxEsp.Visible = true
                    Text.Position = Vector2.new(Vector.X,Vector.Y-25)
                    Text.Visible = true
                else

                    BoxEsp.Visible = false
                    Text.Visible = false

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
