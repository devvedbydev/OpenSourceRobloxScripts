local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StatsService = game:GetService("Stats")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local fpsValues = {}
local maxFpsSamples = 30
local uiName = "InfoOverlay"

local function removePreviousUI()
    local existingUi = playerGui:FindFirstChild(uiName)
    if existingUi then
        existingUi:Destroy()
    end
end

local function createOverlay()
    removePreviousUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = playerGui
    screenGui.Name = uiName
    screenGui.IgnoreGuiInset = true

    local frame = Instance.new("Frame")
    frame.Parent = screenGui
    frame.Size = UDim2.new(0, 200, 0, 120)
    frame.Position = UDim2.new(1, -210, 1, -130)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(1, 1)

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Parent = frame
    uiStroke.Thickness = 2
    uiStroke.Color = Color3.fromRGB(127, 3, 252)

    local uiCorner = Instance.new("UICorner")
    uiCorner.Parent = frame
    uiCorner.CornerRadius = UDim.new(0, 8)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = frame
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    listLayout.Padding = UDim.new(0, 4)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = frame
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Name: " .. LocalPlayer.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.TextYAlignment = Enum.TextYAlignment.Center

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Parent = frame
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.BackgroundTransparency = 1
    if LocalPlayer.Name == "hitbydev" then
        statusLabel.Text = "Status: Developer"
    else
        statusLabel.Text = "Status: Member"
    end
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.TextYAlignment = Enum.TextYAlignment.Center

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Parent = frame
    fpsLabel.Size = UDim2.new(1, 0, 0, 20)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: Calculating..."
    fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 14
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
    fpsLabel.TextYAlignment = Enum.TextYAlignment.Center

    local timeLabel = Instance.new("TextLabel")
    timeLabel.Parent = frame
    timeLabel.Size = UDim2.new(1, 0, 0, 20)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "Time: " .. os.date("%X")
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextSize = 14
    timeLabel.TextXAlignment = Enum.TextXAlignment.Center
    timeLabel.TextYAlignment = Enum.TextYAlignment.Center

    local pingLabel = Instance.new("TextLabel")
    pingLabel.Parent = frame
    pingLabel.Size = UDim2.new(1, 0, 0, 20)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "Ping: 0 ms"
    pingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    pingLabel.Font = Enum.Font.GothamBold
    pingLabel.TextSize = 14
    pingLabel.TextXAlignment = Enum.TextXAlignment.Center
    pingLabel.TextYAlignment = Enum.TextYAlignment.Center

    local function getRealPing()
        local networkStats = StatsService:FindFirstChild("PerformanceStats")
        if networkStats then
            local pingStat = networkStats:FindFirstChild("Ping")
            if pingStat then
                return math.floor(pingStat:GetValue()) .. " ms"
            end
        end
        return "N/A ms"
    end

    local dragging = false
    local dragInput, dragStart, startPos

    local function updateInput(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)

    local function calculateAverageFPS()
        table.insert(fpsValues, 1 / RunService.RenderStepped:Wait())
        if #fpsValues > maxFpsSamples then
            table.remove(fpsValues, 1)
        end

        local sum = 0
        for _, fps in ipairs(fpsValues) do
            sum = sum + fps
        end
        return math.floor(sum / #fpsValues)
    end

    RunService.RenderStepped:Connect(function()
        local avgFps = calculateAverageFPS()
        fpsLabel.Text = "FPS: " .. avgFps
        timeLabel.Text = "Time: " .. os.date("%X")
        pingLabel.Text = "Ping: " .. getRealPing()
    end)
end

createOverlay()

local function monitorOverlay()
    while true do
        wait(3)
        if not playerGui:FindFirstChild(uiName) then
            createOverlay()
        end
    end
end

monitorOverlay()
