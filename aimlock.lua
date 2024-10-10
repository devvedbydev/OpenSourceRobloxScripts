local CONFIG = {
    PredictionTime = 0.114,
    TargetStrafe = false,
    StrafeDistance = 20,
    StrafeSpeed = 10,
    CircleColor = Color3.fromRGB(255, 255, 255),
    CircleRadius = 0,
    AimbotSmoothness = 5,
    HeadshotPredictionTime = PredictionTime,
    AimbotFOV = 90,
    StrafeRandomRange = 60,
}

local StrafeGlobal = false  -- Global toggle for strafe feature

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

local mousePositionLocked = nil

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
                if distance < shortestDistance then
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

local function handleAimlockAndStrafe()
    if aiming and targetPlayer and targetPlayer.Character then
        local character = targetPlayer.Character
        local predictedPosition = predictHeadPosition(character, CONFIG.PredictionTime)

        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)

        if not targetPlayer.Character:FindFirstChild("Humanoid") or targetPlayer.Character.Humanoid.Health <= 0 then
            aiming = false
            targetPlayer = nil
            print("Target killed, aimlock disabled.")
        end

        if strafeEnabled and StrafeGlobal then  -- Check if strafe is enabled and globally usable
            -- Make the character spin around the target
            local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local spinSpeed = 5 -- Adjust this value for faster/slower spinning
                humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
            end

            if tick() - lastDirectionChange > directionChangeInterval then
                strafeAngle = math.random(0, 360)
                currentStrafeSpeed = math.random(1, CONFIG.StrafeSpeed * 2)
                lastDirectionChange = tick()
            end

            local randomOffset = math.random(-CONFIG.StrafeRandomRange, CONFIG.StrafeRandomRange)
            local strafeOffset = (character.HumanoidRootPart.Position - humanoidRootPart.Position).unit * CONFIG.StrafeDistance
            local strafePosition = CFrame.new(character.HumanoidRootPart.Position) * CFrame.Angles(0, math.rad(randomOffset + strafeAngle), 0) * CFrame.new(strafeOffset)

            humanoidRootPart.CFrame = CFrame.new(strafePosition.Position, character.HumanoidRootPart.Position)

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

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        aiming = not aiming
        if aiming then
            targetPlayer = getClosestPlayerToCursor()
            mousePositionLocked = Vector2.new(LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y) 
            print(aiming and targetPlayer)
        else
            targetPlayer = nil
            mousePositionLocked = nil 
            print("Aimlock disabled.")
        end
    elseif input.KeyCode == Enum.KeyCode.Y then
        if targetPlayer then
            -- Toggle strafe only if it's globally usable
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
end)
