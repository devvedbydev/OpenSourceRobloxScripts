local CONFIG = {
    ESPColor = Color3.fromRGB(173, 216, 230),
    TargetColor = Color3.fromRGB(255, 255, 255),
    PredictionTime = 0.067,
    ESPEnabled = true,
    TargetStrafe = false,
    StrafeDistance = 20,
    StrafeSpeed = 10,
    CircleColor = Color3.fromRGB(255, 255, 255),
    CircleRadius = 0,
    AimbotSmoothness = 5, 
    HeadshotPredictionTime = 0.079,
    AimbotFOV = 90,
    StrafeRandomRange = 60,
    HeadshotAccuracy = 0.8 -- 80% headshot accuracy
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Chat = game:GetService("Chat")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local targetPlayer = nil
local aiming = false
local strafeEnabled = CONFIG.TargetStrafe
local strafeAngle = 0
local highlights = {}
local circleIndicators = {}
local currentStrafeSpeed = CONFIG.StrafeSpeed
local directionChangeInterval = 0.143 -- Interval for changing direction
local lastDirectionChange = tick()

local function getHealthColor(humanoid)
    if humanoid.Health < 50 then
        return Color3.fromRGB(255, 0, 0) -- Red for low health
    else
        return Color3.fromRGB(0, 255, 0) -- Green for high health
    end
end

local function updateHighlight(character, color, healthColor)
    local highlight = highlights[character] or character:FindFirstChild("Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "Highlight"
        highlight.Adornee = character
        highlight.Parent = character
        highlight.FillColor = healthColor -- Set based on health
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = color
        highlight.OutlineTransparency = 0.5
        highlights[character] = highlight
    else
        highlight.OutlineColor = color
        highlight.FillColor = healthColor
    end
end

local function removeHighlight(character)
    local highlight = highlights[character]
    if highlight then
        highlight:Destroy()
        highlights[character] = nil
    end
end

local function updatePlayerESP(player)
    if CONFIG.ESPEnabled then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            local screenPosition, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
            local color
            local healthColor = getHealthColor(humanoid)

            if player == LocalPlayer then
                color = Color3.fromRGB(0, 0, 255) -- Blue for local player
            elseif onScreen then
                local ray = Ray.new(Camera.CFrame.Position, humanoidRootPart.Position - Camera.CFrame.Position)
                local hitPart = workspace:FindPartOnRay(ray)
                if hitPart and hitPart:IsDescendantOf(player.Character) then
                    color = Color3.fromRGB(255, 105, 180) -- Bright pink for visible
                else
                    color = Color3.fromRGB(128, 0, 128) -- Dark purple for invisible
                end
            else
                color = Color3.fromRGB(128, 0, 128) -- Dark purple for invisible
            end

            -- Update highlight only if in view
            if onScreen then
                if player == targetPlayer then
                    updateHighlight(player.Character, CONFIG.TargetColor, healthColor)
                else
                    updateHighlight(player.Character, color, healthColor)
                end
            else
                removeHighlight(player.Character)
            end
        else
            removeHighlight(player.Character)
        end
    else
        removeHighlight(player.Character)
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
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local function predictHeadshot(character, predictionTime)
    local head = character:FindFirstChild("Head")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not head or not humanoidRootPart then return humanoidRootPart.Position end

    local rng = math.random()
    if rng <= CONFIG.HeadshotAccuracy then
        return head.Position -- Aim for head based on accuracy percentage
    else
        return humanoidRootPart.Position -- Otherwise aim for body
    end
end

local function handleAimlockAndStrafe()
    if aiming and targetPlayer and targetPlayer.Character then
        local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health == 0 then
            aiming = false -- Unlock if the target is at 0 HP
            targetPlayer = nil
            print("Target has 0 HP. Aimlock disabled.")
            return
        end

        local character = targetPlayer.Character
        local predictedPosition = predictHeadshot(character, CONFIG.HeadshotPredictionTime)

        -- Directly set the camera CFrame to target the predicted position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)

        if strafeEnabled then
            if tick() - lastDirectionChange > directionChangeInterval then
                strafeAngle = math.random(0, 360)
                currentStrafeSpeed = math.random(1, CONFIG.StrafeSpeed * 2)
                lastDirectionChange = tick()
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.X then
        aiming = not aiming
        if aiming then
            targetPlayer = getClosestPlayerToCursor()
            print(aiming and targetPlayer)
        else
            targetPlayer = nil
            print("Aimlock disabled.")
        end
    elseif input.KeyCode == Enum.KeyCode.Y then
        print("Useless function called, strafe is patched.")
    end
end)

RunService.RenderStepped:Connect(function()
    if CONFIG.ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            updatePlayerESP(player)
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                removeHighlight(player.Character)
                local circle = circleIndicators[player.Character]
                if circle then
                    circle:Destroy()
                end
            end
        end
    end
    handleAimlockAndStrafe()
end)
