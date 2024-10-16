local CONFIG = {
    PredictionTime = 0.14,
    TargetStrafe = false,
    StrafeDistance = 20,
    StrafeSpeed = 10,
    CircleColor = Color3.fromRGB(255, 255, 255),
    CircleRadius = 0, -- Circle will be used for strafe
    AimbotSmoothness = 5,
    HeadshotPredictionTime = 0,
    AimbotFOV = 300, -- Increase FOV for larger area
    StrafeRandomRange = 60,
    ShowFOVCircle = true, -- Toggle visibility of FOV circle
    FOVCircleColor = Color3.fromRGB(127, 3, 252), -- New purple color for FOV circle
    FOVCircleRadius = 300, -- Radius matching AimbotFOV
    FOVCircleTransparency = 1,
}

local StrafeGlobal = true  -- Global toggle for strafe feature

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Chat = game:GetService("Chat")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local targetPlayer = nil
local aiming = false
local strafeEnabled = false
local strafeAngle = 0
local circleIndicators = {}
local currentStrafeSpeed = CONFIG.StrafeSpeed
local directionChangeInterval = 0.143
local lastDirectionChange = tick()

local FOVCircle = nil

local function createFOVCircle()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = CONFIG.ShowFOVCircle
    FOVCircle.Color = CONFIG.FOVCircleColor
    FOVCircle.Thickness = 1
    FOVCircle.Filled = false
    FOVCircle.Transparency = CONFIG.FOVCircleTransparency
    FOVCircle.Radius = CONFIG.FOVCircleRadius
end

local function updateFOVCircle()
    if FOVCircle and CONFIG.ShowFOVCircle then
        local mouse = LocalPlayer:GetMouse()
        FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
        FOVCircle.Visible = true
    elseif FOVCircle then
        FOVCircle.Visible = false
    end
end

local function getClosestPlayerToCursor()
    local mouse = LocalPlayer:GetMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local characterPosition = character.HumanoidRootPart.Position
            local screenPosition, onScreen = Camera:WorldToScreenPoint(characterPosition)
            if onScreen then
                local mousePosition = Vector2.new(mouse.X, mouse.Y)
                local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude
                if distance < shortestDistance and distance <= CONFIG.AimbotFOV then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local function predictHeadPosition(character, predictionTime)
    local head = character:FindFirstChild("Head")
    if not head then return Vector3.new(0, 0, 0) end

    local headPosition = head.Position
    local velocity = character.HumanoidRootPart.AssemblyLinearVelocity
    return headPosition + (velocity * predictionTime)
end

local function smoothAim(currentCFrame, targetPosition, smoothness)
    local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)
    return currentCFrame:Lerp(targetCFrame, smoothness / 10)
end

local function handleAimlockAndStrafe()
    if aiming and targetPlayer and targetPlayer.Character then
        local character = targetPlayer.Character
        local predictedPosition = predictHeadPosition(character, CONFIG.PredictionTime)

        -- Smooth aiming
        Camera.CFrame = smoothAim(Camera.CFrame, predictedPosition, CONFIG.AimbotSmoothness)

        if not targetPlayer.Character:FindFirstChild("Humanoid") or targetPlayer.Character.Humanoid.Health <= 0 then
            aiming = false
            targetPlayer = nil
            print("Target killed, aimlock disabled.")
        end

        if strafeEnabled and StrafeGlobal then
            local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                if tick() - lastDirectionChange > directionChangeInterval then
                    strafeAngle = math.random(0, 360)
                    currentStrafeSpeed = math.random(1, CONFIG.StrafeSpeed * 2)
                    lastDirectionChange = tick()
                end

                local randomOffset = math.random(-CONFIG.StrafeRandomRange, CONFIG.StrafeRandomRange)
                local strafeOffset = (character.HumanoidRootPart.Position - humanoidRootPart.Position).unit * CONFIG.StrafeDistance
                local strafePosition = CFrame.new(character.HumanoidRootPart.Position) * CFrame.Angles(0, math.rad(randomOffset + strafeAngle), 0) * CFrame.new(strafeOffset)

                humanoidRootPart.CFrame = CFrame.new(strafePosition.Position, character.HumanoidRootPart.Position)

                -- Create or update circle indicator
                local circle = circleIndicators[character] or character:FindFirstChild("CircleIndicator")
                if not circle then
                    circle = Instance.new("BillboardGui")
                    circle.Name = "CircleIndicator"
                    circle.Size = UDim2.new(0, CONFIG.CircleRadius * 2, 0, CONFIG.CircleRadius * 2)
                    circle.AlwaysOnTop = true
                    circle.Adornee = character.HumanoidRootPart
                    circle.Parent = character
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundColor3 = CONFIG.CircleColor
                    frame.BackgroundTransparency = 0.5
                    frame.Parent = circle
                    circleIndicators[character] = circle
                end
                circle.Size = UDim2.new(0, CONFIG.CircleRadius * 2, 0, CONFIG.CircleRadius * 2)
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        aiming = not aiming
        if aiming then
            targetPlayer = getClosestPlayerToCursor()
            print(aiming and targetPlayer)
        else
            targetPlayer = nil
            print("Aimlock disabled.")
        end
    elseif input.KeyCode == Enum.KeyCode.Y then
        if targetPlayer then
            if StrafeGlobal then
                strafeEnabled = not strafeEnabled
                if strafeEnabled then
                    print("Strafe enabled.")
                else
                    print("Strafe disabled.")
                end
            else
                print("Strafe is globally disabled.")
            end
        else
            print("No target.")
        end
    end
end)

local function onChatMessage(message)
    if message:lower() == ".binds" then
        local bindsInfo = [[
Commands:
  Q - Toggle aimlock (lock on/off target)
  Y - Toggle strafe (spin around target)
]]
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
            Chat:Chat(LocalPlayer.Character.Head, bindsInfo, Enum.ChatColor.Blue)
        end
    end
end

LocalPlayer.Chatted:Connect(onChatMessage)

RunService.RenderStepped:Connect(function()
    handleAimlockAndStrafe()
    updateFOVCircle()
end)

-- Create the FOV circle on game start
createFOVCircle()
