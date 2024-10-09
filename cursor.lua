local UserInputService = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer

-- Function to create the custom cursor
local function createCursor()
    -- Create a new ScreenGui for the cursor
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomCursor"
    screenGui.Parent = Player:WaitForChild("PlayerGui")

    -- Create the cross cursor using two Frame objects
    local crossSize = 10 -- Size of the cross
    local crossColor = Color3.fromRGB(255, 255, 255) -- Set color to white

    -- Horizontal part of the cross
    local horizontal = Instance.new("Frame")
    horizontal.Size = UDim2.new(0, crossSize * 2, 0, crossSize / 5) -- Width and height
    horizontal.BackgroundColor3 = crossColor
    horizontal.BackgroundTransparency = 0 -- Fully opaque
    horizontal.AnchorPoint = Vector2.new(0.5, 0.5)
    horizontal.Position = UDim2.new(0, 0, 0, 0) -- Centered
    horizontal.Parent = screenGui

    -- Vertical part of the cross
    local vertical = Instance.new("Frame")
    vertical.Size = UDim2.new(0, crossSize / 5, 0, crossSize * 2) -- Width and height
    vertical.BackgroundColor3 = crossColor
    vertical.BackgroundTransparency = 0 -- Fully opaque
    vertical.AnchorPoint = Vector2.new(0.5, 0.5)
    vertical.Position = UDim2.new(0, 0, 0, 0) -- Centered
    vertical.Parent = screenGui

    -- Function to update the cursor position
    local function updateCursor()
        local mouse = Player:GetMouse()
        local cursorPosition = UDim2.new(0, mouse.X, 0, mouse.Y)
        horizontal.Position = cursorPosition
        vertical.Position = cursorPosition
    end

    -- Update the cursor position every frame
    game:GetService("RunService").RenderStepped:Connect(updateCursor)

    -- Hide the default mouse cursor
    UserInputService.MouseIconEnabled = false
end

-- Function to monitor and recreate the cursor if it disappears
local function monitorCursor()
    while true do
        wait(1) -- Check every second
        local existingGui = Player:FindFirstChild("PlayerGui"):FindFirstChild("CustomCursor")
        if not existingGui then
            createCursor() -- Recreate the cursor if it's not found
        end
    end
end

-- Initial creation of the cursor
createCursor()

-- Start monitoring the cursor
monitorCursor()
