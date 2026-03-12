-- SimpleHub | Sawah Indo
-- LoadingTitle: SimpleHub | LoadingSubtitle: Have Fun

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SimpleHub | Sawah Indo",
   LoadingTitle = "SimpleHub",
   LoadingSubtitle = "Have Fun",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Variables
local Remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TutorialRemotes")
local Player = game.Players.LocalPlayer

-- Global State
local _G = {
    AutoSell    = false,
    AutoPlant   = false,
    AutoBuy     = false,
    AutoHarvest = false,
    SelectedSeed = "Bibit Padi",
    Flying      = false,
    FlySpeed    = 60
}

-- ================================================
-- TOGGLE UI (Toggle + Lock Button)
-- ================================================
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "SimpleHubToggle"
ToggleGui.ResetOnSpawn = false
ToggleGui.DisplayOrder = 999
ToggleGui.Parent = game.CoreGui

local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 110, 0, 90)
Container.Position = UDim2.new(0, 8, 0, 120)
Container.BackgroundTransparency = 1
Container.Parent = ToggleGui

-- Draggable
local dragging, dragStart, startPos
Container.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Container.Position
    end
end)
Container.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMove) then
        local delta = input.Position - dragStart
        Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
Container.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local function makeButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.AutoButtonColor = true
    btn.Parent = Container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1
    return btn
end

local ToggleBtn = makeButton("Toggle", 0)
local LockBtn   = makeButton("Lock", 46)

local isGuiVisible = true
ToggleBtn.MouseButton1Click:Connect(function()
    isGuiVisible = not isGuiVisible
    local r = game:GetService("CoreGui"):FindFirstChild("Rayfield")
    if r then r.Enabled = isGuiVisible end
end)

local isLocked = false
LockBtn.MouseButton1Click:Connect(function()
    isLocked = not isLocked
    if isLocked then
        LockBtn.Text = "Unlock"
        LockBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        LockBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    else
        LockBtn.Text = "Lock"
        LockBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        LockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    end
end)
Container.InputBegan:Connect(function()
    if isLocked then dragging = false end
end)

-- ================================================
-- TAB: AUTOMATION
-- ================================================
local MainTab = Window:CreateTab("Automation", 4483362458)
MainTab:CreateSection("Farming System")

MainTab:CreateToggle({
    Name = "Auto Harvest",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoHarvest = Value
        task.spawn(function()
            while _G.AutoHarvest do
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and (v.ObjectText == "Panen" or v.ActionText == "Panen") then
                        fireproximityprompt(v)
                    end
                end
                task.wait(0.2)
            end
        end)
    end,
})

MainTab:CreateToggle({
    Name = "Auto Plant",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoPlant = Value
        task.spawn(function()
            while _G.AutoPlant do
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    Remotes.PlantCrop:FireServer(Player.Character.HumanoidRootPart.Position)
                end
                task.wait(0.8)
            end
        end)
    end,
})

MainTab:CreateDropdown({
    Name = "Pilih Bibit",
    Options = {"Padi", "Jagung", "Tomat", "Terong", "Strawberry", "Sawit"},
    CurrentOption = {"Padi"},
    Callback = function(Option)
        _G.SelectedSeed = "Bibit " .. Option[1]
    end,
})

MainTab:CreateToggle({
    Name = "Auto Buy Selected Seed",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoBuy = Value
        task.spawn(function()
            while _G.AutoBuy do
                Remotes.RequestShop:InvokeServer("BUY", _G.SelectedSeed, 5)
                task.wait(2)
            end
        end)
    end,
})

MainTab:CreateToggle({
    Name = "Auto Sell All Items",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoSell = Value
        task.spawn(function()
            while _G.AutoSell do
                pcall(function()
                    for _, item in pairs({"Padi","Jagung","Tomat","Terong","Strawberry","Sawit","Durian"}) do
                        Remotes.RequestSell:InvokeServer("SELL", item, 50)
                        task.wait(0.3)
                    end
                end)
                task.wait(5)
            end
        end)
    end,
})

-- ================================================
-- TAB: SHOP & LAHAN
-- ================================================
local ShopTab = Window:CreateTab("Shop & Lahan", 4483362458)

ShopTab:CreateSection("Beli Bibit Spesial")

ShopTab:CreateButton({
    Name = "Beli Bibit Strawberry",
    Callback = function()
        pcall(function() Remotes.RequestShop:InvokeServer("BUY", "Bibit Strawberry", 1) end)
        Rayfield:Notify({Title = "SimpleHub", Content = "Beli Bibit Strawberry!", Duration = 3})
    end,
})

ShopTab:CreateButton({
    Name = "Beli Bibit Sawit",
    Callback = function()
        pcall(function() Remotes.RequestShop:InvokeServer("BUY", "Bibit Sawit", 1) end)
        Rayfield:Notify({Title = "SimpleHub", Content = "Beli Bibit Sawit!", Duration = 3})
    end,
})

ShopTab:CreateSection("Beli Alat")

ShopTab:CreateButton({
    Name = "Beli Layang-Layang",
    Callback = function()
        pcall(function() Remotes.RequestToolShop:InvokeServer("BUY", "Layang-Layang") end)
        Rayfield:Notify({Title = "SimpleHub", Content = "Beli Layang-Layang!", Duration = 3})
    end,
})

ShopTab:CreateSection("Jual Buah")

ShopTab:CreateButton({
    Name = "Jual Buah Sawit",
    Callback = function()
        pcall(function() Remotes.RequestSell:InvokeServer("GET_FRUIT_LIST", "Sawit") end)
        Rayfield:Notify({Title = "SimpleHub", Content = "Jual Sawit!", Duration = 3})
    end,
})

ShopTab:CreateButton({
    Name = "Jual Buah Durian",
    Callback = function()
        pcall(function() Remotes.RequestSell:InvokeServer("GET_FRUIT_LIST", "Durian") end)
        Rayfield:Notify({Title = "SimpleHub", Content = "Jual Durian!", Duration = 3})
    end,
})

-- ================================================
-- TAB: PLAYER
-- ================================================
local PlayerTab = Window:CreateTab("Player", 4483362458)
PlayerTab:CreateSection("Movement")

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Callback = function(Value)
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Value end
        Player.CharacterAdded:Connect(function(newChar)
            newChar:WaitForChild("Humanoid").WalkSpeed = Value
        end)
    end,
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 5,
    Suffix = "Power",
    CurrentValue = 50,
    Callback = function(Value)
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = Value
        end
        Player.CharacterAdded:Connect(function(newChar)
            local h = newChar:WaitForChild("Humanoid")
            h.UseJumpPower = true
            h.JumpPower = Value
        end)
    end,
})

PlayerTab:CreateSection("Fly")

local flyConnection = nil

local FlyGui = Instance.new("ScreenGui")
FlyGui.Name = "FlyControlGui"
FlyGui.ResetOnSpawn = false
FlyGui.Enabled = false
FlyGui.Parent = game.CoreGui

local function makeFlyBtn(text, posX, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(1, posX, 1, -160)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Active = true
    btn.Parent = FlyGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    return btn
end

local UpButton   = makeFlyBtn("▲ UP", -170, Color3.fromRGB(66, 133, 244))
local DownButton = makeFlyBtn("▼ DN", -85,  Color3.fromRGB(167, 107, 255))

local isPressingUp   = false
local isPressingDown = false

local function bindFlyBtn(btn, stateUp)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            if stateUp then isPressingUp = true else isPressingDown = true end
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            if stateUp then isPressingUp = false else isPressingDown = false end
        end
    end)
end

bindFlyBtn(UpButton, true)
bindFlyBtn(DownButton, false)

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(Value)
        _G.Flying = Value
        local char = Player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if Value then
            FlyGui.Enabled = true
            isPressingUp = false
            isPressingDown = false
            hum.PlatformStand = true

            local BV = Instance.new("BodyVelocity")
            BV.Name = "FlyVelocity"
            BV.Velocity = Vector3.new(0,0,0)
            BV.MaxForce = Vector3.new(1e5,1e5,1e5)
            BV.Parent = hrp

            local BG = Instance.new("BodyGyro")
            BG.Name = "FlyGyro"
            BG.MaxTorque = Vector3.new(1e5,1e5,1e5)
            BG.D = 100
            BG.Parent = hrp

            flyConnection = RunService.Heartbeat:Connect(function()
                if not _G.Flying then return end
                local cam = workspace.CurrentCamera
                local spd = _G.FlySpeed or 60
                local dir = Vector3.new(0,0,0)

                -- PC WASD
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

                -- Android Analog
                if hum.MoveDirection.Magnitude > 0 then
                    local md = hum.MoveDirection
                    local cL = Vector3.new(cam.CFrame.LookVector.X,  0, cam.CFrame.LookVector.Z)
                    local cR = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
                    if cL.Magnitude > 0 and cR.Magnitude > 0 then
                        dir += (cL.Unit * -md.Z) + (cR.Unit * md.X)
                    end
                end

                -- Android UP/DN Button
                if isPressingUp   then dir += Vector3.new(0,1,0) end
                if isPressingDown  then dir -= Vector3.new(0,1,0) end

                BV.Velocity = dir.Magnitude > 0 and dir.Unit * spd or BV.Velocity * 0.8
                BG.CFrame = cam.CFrame
            end)
        else
            FlyGui.Enabled = false
            isPressingUp = false
            isPressingDown = false
            if flyConnection then flyConnection:Disconnect() flyConnection = nil end
            hum.PlatformStand = false
            if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
            if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 300},
    Increment = 10,
    Suffix = "Speed",
    CurrentValue = 60,
    Callback = function(Value)
        _G.FlySpeed = Value
    end,
})

-- ================================================
-- TAB: SERVER
-- ================================================
local ServerTab = Window:CreateTab("Server", 4483362458)
ServerTab:CreateSection("Server Management")

ServerTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
    end,
})

ServerTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        Rayfield:Notify({Title = "SimpleHub", Content = "Mencari server lain...", Duration = 3})
        task.spawn(function()
            local id = game.PlaceId
            local cur = game.JobId
            local ok, res = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/"..id.."/servers/Public?sortOrder=Asc&limit=100"
                ))
            end)
            if ok and res and res.data then
                for _, s in pairs(res.data) do
                    if s.id ~= cur and s.playing < s.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(id, s.id, Player)
                        return
                    end
                end
            end
            Rayfield:Notify({Title = "SimpleHub", Content = "Server lain tidak ditemukan!", Duration = 3})
        end)
    end,
})

ServerTab:CreateButton({
    Name = "Join Server Paling Sepi",
    Callback = function()
        Rayfield:Notify({Title = "SimpleHub", Content = "Mencari server paling sepi...", Duration = 3})
        task.spawn(function()
            local id = game.PlaceId
            local cur = game.JobId
            local lowest, lowestId = math.huge, nil
            local ok, res = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/"..id.."/servers/Public?sortOrder=Asc&limit=100"
                ))
            end)
            if ok and res and res.data then
                for _, s in pairs(res.data) do
                    if s.id ~= cur and s.playing < lowest then
                        lowest = s.playing
                        lowestId = s.id
                    end
                end
            end
            if lowestId then
                Rayfield:Notify({Title = "SimpleHub", Content = "Ditemukan! ("..lowest.." players)", Duration = 3})
                task.wait(1.5)
                TeleportService:TeleportToPlaceInstance(id, lowestId, Player)
            else
                Rayfield:Notify({Title = "SimpleHub", Content = "Gagal menemukan server!", Duration = 3})
            end
        end)
    end,
})

-- ================================================
-- TAB: MISC
-- ================================================
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateSlider({
    Name = "FPS Cap (Save Battery)",
    Range = {10, 60},
    Increment = 5,
    Suffix = "FPS",
    CurrentValue = 60,
    Callback = function(Value)
        setfpscap(Value)
    end,
})

MiscTab:CreateButton({
    Name = "Anti-AFK",
    Callback = function()
        Player.Idled:Connect(function()
            game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        Rayfield:Notify({Title = "SimpleHub", Content = "Anti-AFK Aktif!", Duration = 3})
    end,
})

MiscTab:CreateButton({
    Name = "Reduce Lag",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                v.Material = Enum.Material.SmoothPlastic
            end
            if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
        Rayfield:Notify({Title = "SimpleHub", Content = "Lag dikurangi!", Duration = 3})
    end,
})
