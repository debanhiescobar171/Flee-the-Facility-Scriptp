
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local Config = {
    ESP = {
        Players = false,
        Computers = false,
        Exits = false
    },
    Speed = 16,
    InfiniteJump = false,
    AutoHack = false,
    Noclip = false,
    Invisible = false,
    AutoEscape = false,
    Teleport = false
}

local function createESP(part, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Parent = part

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = color
    frame.Parent = billboard

    return billboard
end

local function toggleESP(type)
    Config.ESP[type] = not Config.ESP[type]
    if type == "Players" then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    if Config.ESP.Players then
                        createESP(char.HumanoidRootPart, Color3.new(1, 0, 0))
                    else
                        local esp = char.HumanoidRootPart:FindFirstChild("BillboardGui")
                        if esp then esp:Destroy() end
                    end
                end
            end
        end
    elseif type == "Computers" then
        for _, computer in pairs(workspace:GetDescendants()) do
            if computer.Name == "ComputerTable" then
                if Config.ESP.Computers then
                    createESP(computer, Color3.new(0, 1, 0))
                else
                    local esp = computer:FindFirstChild("BillboardGui")
                    if esp then esp:Destroy() end
                end
            end
        end
    elseif type == "Exits" then
        for _, exit in pairs(workspace:GetDescendants()) do
            if exit.Name == "ExitDoor" then
                if Config.ESP.Exits then
                    createESP(exit, Color3.new(0, 0, 1))
                else
                    local esp = exit:FindFirstChild("BillboardGui")
                    if esp then esp:Destroy() end
                end
            end
        end
    end
end

local function setSpeed(speed)
    Config.Speed = speed
    Humanoid.WalkSpeed = speed
end

local function toggleInfiniteJump()
    Config.InfiniteJump = not Config.InfiniteJump
end

local function toggleAutoHack()
    Config.AutoHack = not Config.AutoHack
end

local function toggleNoclip()
    Config.Noclip = not Config.Noclip
end

local function toggleInvisible()
    Config.Invisible = not Config.Invisible
    if Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = Config.Invisible and 1 or 0
            end
        end
    end
end

local function toggleAutoEscape()
    Config.AutoEscape = not Config.AutoEscape
end

local teleportTarget = "Computer"
local function toggleTeleport()
    Config.Teleport = not Config.Teleport
    if Config.Teleport then
        teleportTarget = teleportTarget == "Computer" and "Exit" or "Computer"
    end
end

local function createButton(parent, text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, 30)
    button.Position = position
    button.Text = text
    button.Parent = parent
    button.MouseButton1Click:Connect(callback)
    return button
end

local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Position = UDim2.new(0.8, 0, 0.5, -150)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Flee the Facility Script"
title.Parent = frame

local minimizeButton = createButton(frame, "Minimize", UDim2.new(1, -30, 0, 0), function()
    frame.Size = frame.Size == UDim2.new(0, 200, 0, 30) and UDim2.new(0, 200, 0, 300) or UDim2.new(0, 200, 0, 30)
end)
minimizeButton.Size = UDim2.new(0, 30, 0, 30)

createButton(frame, "ESP Players", UDim2.new(0, 0, 0, 40), function() toggleESP("Players") end)
createButton(frame, "ESP Computers", UDim2.new(0, 0, 0, 80), function() toggleESP("Computers") end)
createButton(frame, "ESP Exits", UDim2.new(0, 0, 0, 120), function() toggleESP("Exits") end)
createButton(frame, "Speed Boost", UDim2.new(0, 0, 0, 160), function() setSpeed(32) end)
createButton(frame, "Infinite Jump", UDim2.new(0, 0, 0, 200), toggleInfiniteJump)
createButton(frame, "Auto Hack", UDim2.new(1, -100, 0, 40), toggleAutoHack)
createButton(frame, "Noclip", UDim2.new(1, -100, 0, 80), toggleNoclip)
createButton(frame, "Invisible", UDim2.new(1, -100, 0, 120), toggleInvisible)
createButton(frame, "Auto Escape", UDim2.new(1, -100, 0, 160), toggleAutoEscape)
createButton(frame, "Teleport", UDim2.new(1, -100, 0, 200), toggleTeleport)

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

RunService.Stepped:Connect(function()
    if Config.Noclip and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local function findNearestComputer()
    local nearestComputer = nil
    local minDistance = math.huge
    for _, computer in pairs(workspace:GetDescendants()) do
        if computer.Name == "ComputerTable" then
            local distance = (Root.Position - computer.Position).Magnitude
            if distance < minDistance then
                nearestComputer = computer
                minDistance = distance
            end
        end
    end
    return nearestComputer
end

local function findNearestExit()
    local nearestExit = nil
    local minDistance = math.huge
    for _, exit in pairs(workspace:GetDescendants()) do
        if exit.Name == "ExitDoor" then
            local distance = (Root.Position - exit.Position).Magnitude
            if distance < minDistance then
                nearestExit = exit
                minDistance = distance
            end
        end
    end
    return nearestExit
end

RunService.Heartbeat:Connect(function()
    if Config.AutoHack then
        local nearestComputer = findNearestComputer()
        if nearestComputer and (Root.Position - nearestComputer.Position).Magnitude < 10 then
            local args = {
                [1] = "BeginHacking",
                [2] = nearestComputer
            }
            game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
        end
    end
    
    if Config.AutoEscape then
        local beast = workspace:FindFirstChild("Beast")
        if beast and beast:FindFirstChild("HumanoidRootPart") then
            local distance = (Root.Position - beast.HumanoidRootPart.Position).Magnitude
            if distance < 20 then
                local exit = findNearestExit()
                if exit then
                    Root.CFrame = exit.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end
    
    if Config.Teleport then
        local target
        if teleportTarget == "Computer" then
            target = findNearestComputer()
        else
            target = findNearestExit()
        end
        
        if target then
            Root.CFrame = target.CFrame + Vector3.new(0, 5, 0)
            Config.Teleport = false
        end
    end
end)
```
