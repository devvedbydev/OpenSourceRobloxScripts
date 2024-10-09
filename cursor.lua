local UserInputService = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer

local function createCursor()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomCursor"
    screenGui.Parent = Player:WaitForChild("PlayerGui")

    local crossSize = 10
    local crossColor = Color3.fromRGB(255, 255, 255)

    local horizontal = Instance.new("Frame")
    horizontal.Size = UDim2.new(0, crossSize * 2, 0, crossSize / 5)
    horizontal.BackgroundColor3 = crossColor
    horizontal.BackgroundTransparency = 0
    horizontal.AnchorPoint = Vector2.new(0.5, 0.5)
    horizontal.Position = UDim2.new(0, 0, 0, 0)
    horizontal.Parent = screenGui

    local vertical = Instance.new("Frame")
    vertical.Size = UDim2.new(0, crossSize / 5, 0, crossSize * 2)
    vertical.BackgroundColor3 = crossColor
    vertical.BackgroundTransparency = 0
    vertical.AnchorPoint = Vector2.new(0.5, 0.5)
    vertical.Position = UDim2.new(0, 0, 0, 0)
    vertical.Parent = screenGui

    local function updateCursor()
        local mouse = Player:GetMouse()
        local cursorPosition = UDim2.new(0, mouse.X, 0, mouse.Y)
        horizontal.Position = cursorPosition
        vertical.Position = cursorPosition
    end

    game:GetService("RunService").RenderStepped:Connect(updateCursor)

    -- Fully disable default Roblox mouse icon
    UserInputService.MouseIconEnabled = false

    -- Extra safeguard to prevent any Roblox cursor from reappearing
    UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceHide
end

local function monitorCursor()
    while true do
        wait(1)
        local existingGui = Player:FindFirstChild("PlayerGui"):FindFirstChild("CustomCursor")
        if not existingGui then
            createCursor()
        end
        -- Continuously forcefully disable the default cursor
        UserInputService.MouseIconEnabled = false
        UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceHide
    end
end

createCursor()
coroutine.wrap(monitorCursor)()
