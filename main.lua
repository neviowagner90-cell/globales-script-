-- Fly and Noclip Script for Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

-- Flugvariablen
local flying = false
local flySpeed = 50
local noclip = false

-- Funktion zum Aktivieren/Deaktivieren von Noclip
local function toggleNoclip()
    noclip = not noclip
    
    if noclip then
        -- Noclip aktivieren
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    else
        -- Noclip deaktivieren
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == false then
                part.CanCollide = true
            end
        end
    end
end

-- Flugsteuerung
local flyControls = {
    Forward = false,
    Backward = false,
    Left = false,
    Right = false,
    Up = false,
    Down = false
}

local function updateFlyControls(input, gameProcessed)
    if gameProcessed then return end
    
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
    if not flying then return end
    
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
    
    humanoid:Move(direction * flySpeed)
end

-- Toggle-Funktionen
local function toggleFly()
    flying = not flying
    
    if flying then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        toggleNoclip() -- Noclip automatisch beim Fliegen aktivieren
        RunService.Heartbeat:Connect(fly)
    else
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
        toggleNoclip() -- Noclip deaktivieren wenn nicht mehr fliegt
    end
end

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
    Text = "[FLY & NOCLIP] Aktiviert! Drücke F zum Fliegen, N für Noclip";
    Color = Color3.new(0, 1, 0);
    Font = Enum.Font.SourceSansBold;
    Size = 18;
})
