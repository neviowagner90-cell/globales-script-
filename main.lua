-- Fly and Noclip Script with GUI for Roblox (Überarbeitet)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

-- Flugvariablen
local flying = false
local flySpeed = 50
local noclip = false
local flyConnection = nil
local bodyVelocity = nil
local bodyGyro = nil

-- Flugsteuerung
local flyControls = {
    Forward = false,
    Backward = false,
    Left = false,
    Right = false,
    Up = false,
    Down = false
}

-- GUI Erstellung
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.BorderSizePixel = 0
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Fly & Noclip"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16

local FlyButton = Instance.new("TextButton")
FlyButton.Parent = MainFrame
FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FlyButton.BorderSizePixel = 0
FlyButton.Position = UDim2.new(0, 20, 0, 50)
FlyButton.Size = UDim2.new(0, 120, 0, 40)
FlyButton.Font = Enum.Font.SourceSans
FlyButton.Text = "Fliegen: AUS"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.TextSize = 14

local NoclipButton = Instance.new("TextButton")
NoclipButton.Parent = MainFrame
NoclipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
NoclipButton.BorderSizePixel = 0
NoclipButton.Position = UDim2.new(0, 160, 0, 50)
NoclipButton.Size = UDim2.new(0, 120, 0, 40)
NoclipButton.Font = Enum.Font.SourceSans
NoclipButton.Text = "Noclip: AUS"
NoclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NoclipButton.TextSize = 14

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = MainFrame
SpeedLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedLabel.BorderSizePixel = 0
SpeedLabel.Position = UDim2.new(0, 20, 0, 110)
SpeedLabel.Size = UDim2.new(0, 120, 0, 30)
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.Text = "Geschwindigkeit: 50"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 14

local SpeedSlider = Instance.new("TextButton")
SpeedSlider.Parent = MainFrame
SpeedSlider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
SpeedSlider.BorderSizePixel = 0
SpeedSlider.Position = UDim2.new(0, 160, 0, 110)
SpeedSlider.Size = UDim2.new(0, 120, 0, 30)
SpeedSlider.Font = Enum.Font.SourceSans
SpeedSlider.Text = ""
SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedSlider.TextSize = 14

local SliderButton = Instance.new("Frame")
SliderButton.Parent = SpeedSlider
SliderButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
SliderButton.BorderSizePixel = 0
SliderButton.Position = UDim2.new(0.5, -5, 0, 5)
SliderButton.Size = UDim2.new(0, 10, 0, 20)

local Instructions = Instance.new("TextLabel")
Instructions.Parent = MainFrame
Instructions.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Instructions.BorderSizePixel = 0
Instructions.Position = UDim2.new(0, 20, 0, 150)
Instructions.Size = UDim2.new(1, -40, 0, 40)
Instructions.Font = Enum.Font.SourceSans
Instructions.Text = "WASD zum Bewegen, Leertaste hoch, Strg runter"
Instructions.TextColor3 = Color3.fromRGB(200, 200, 200)
Instructions.TextSize = 12

-- GUI Animation
local open = true
CloseButton.MouseButton1Click:Connect(function()
    open = not open
    if open then
        MainFrame:TweenSize(UDim2.new(0, 300, 0, 200), "Out", "Quad", 0.3, true)
    else
        MainFrame:TweenSize(UDim2.new(0, 300, 0, 30), "Out", "Quad", 0.3, true)
    end
end)

-- Geschwindigkeitsregler
local dragging = false
SpeedSlider.MouseButton1Down:Connect(function()
    dragging = true
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = math.clamp((input.Position.X - SpeedSlider.AbsolutePosition.X) / SpeedSlider.AbsoluteSize.X, 0, 1)
        SliderButton.Position = UDim2.new(pos, -5, 0, 5)
        flySpeed = math.floor(pos * 150 + 10)
        SpeedLabel.Text = "Geschwindigkeit: " .. flySpeed
        
        -- Geschwindigkeit während des Fluges aktualisieren
        if flying and bodyVelocity then
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Funktion zum Aktivieren/Deaktivieren von Noclip
local function toggleNoclip()
    noclip = not noclip
    
    if noclip then
        NoclipButton.Text = "Noclip: AN"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        -- Noclip aktivieren
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    else
        NoclipButton.Text = "Noclip: AUS"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        -- Noclip deaktivieren
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == false then
                part.CanCollide = true
            end
        end
    end
end

local function updateFlyControls(input, gameProcessed)
    if gameProcessed or not flying then return end

    if input.KeyCode == Enum.KeyCode.W then
        flyControls.Forward = input.UserInputState == Enum.UserInputState.Begin
    elseif input.KeyCode == Enum.KeyCode.S then
        flyControls.Backward = input.UserInputState == Enum.UserInputState.Begin
    elseif input.KeyCode == Enum.KeyCode.A then
        flyControls.Left = input.UserInputState == Enum.UserInputState.Begin
    elseif input.KeyCode == Enum.KeyCode.D then
        flyControls.Right = input.UserInputState == Enum.UserInputState.Begin
    elseif input.KeyCode == Enum.KeyCode.Space then
        flyControls.Up = input.UserInputState == Enum.UserInputState.Begin
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        flyControls.Down = input.UserInputState == Enum.UserInputState.Begin
    end
end

local function fly()
    if not flying or not bodyVelocity then return end
    
    local direction = Vector3.new()
    
    if flyControls.Forward then
        direction = direction + camera.CFrame.LookVector
    end
    if flyControls.Backward then
        direction = direction - camera.CFrame.LookVector
    end
    if flyControls.Left then
        direction = direction - camera.CFrame.RightVector
    end
    if flyControls.Right then
        direction = direction + camera.CFrame.RightVector
    end
    if flyControls.Up then
        direction = direction + Vector3.new(0, 1, 0)
    end
    if flyControls.Down then
        direction = direction - Vector3.new(0, 1, 0)
    end
    
    if direction.Magnitude > 0 then
        direction = direction.Unit
    end
    
    -- BodyVelocity verwenden statt humanoid:Move für bessere Kontrolle
    bodyVelocity.Velocity = direction * flySpeed
    bodyGyro.CFrame = camera.CFrame
end

-- Toggle-Funktionen
local function toggleFly()
    flying = not flying
    
    if flying then
        -- BodyVelocity und BodyGyro erstellen
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.P = 10000
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = character:WaitForChild("HumanoidRootPart")
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 10000
        bodyGyro.CFrame = camera.CFrame
        bodyGyro.Parent = character:WaitForChild("HumanoidRootPart")
        
        -- Schwerkraft deaktivieren
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        
        -- Noclip automatisch aktivieren
        if not noclip then
            toggleNoclip()
        end
        
        FlyButton.Text = "Fliegen: AN"
        FlyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        
        -- Flugverbindung herstellen
        flyConnection = RunService.Heartbeat:Connect(fly)
    else
        -- Flugverbindung trennen
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        -- BodyVelocity und BodyGyro entfernen
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        if bodyGyro then
            bodyGyro:Destroy()
            bodyGyro = nil
        end
        
        -- Normalen Zustand wiederherstellen
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
        
        FlyButton.Text = "Fliegen: AUS"
        FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end

-- Button-Funktionen
FlyButton.MouseButton1Click:Connect(toggleFly)
NoclipButton.MouseButton1Click:Connect(toggleNoclip)

-- Tastenbelegung
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    elseif input.KeyCode == Enum.KeyCode.N then
        toggleNoclip()
    end
end)

UserInputService.InputChanged:Connect(updateFlyControls)
UserInputService.InputEnded:Connect(updateFlyControls)

-- Benachrichtigung
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("ChatMakeSystemMessage", {
    Text = "[FLY & NOCLIP] Überarbeitete Version geladen! Verwende die Schaltflächen oder Tasten F/N";
    Color = Color3.new(0, 1, 0);
    Font = Enum.Font.SourceSansBold;
    Size = 18;
})
