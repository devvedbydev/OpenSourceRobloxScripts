local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

-- Function to calculate the width based on the name length
local function calculateWidth(name)
    if type(name) ~= "string" then
        return UDim2.new(0, 0, 0, 20) -- Default size if the name is invalid
    end

    local textSize = TextService:GetTextSize(name, 14, Enum.Font.GothamBold, Vector2.new(1000, 1000))
    return UDim2.new(0, textSize.X + 10, 0, 20) -- Add padding for the frame
end

-- Function to create a BillboardGui for the player
local function createBillboard(player)
    local billboard = Instance.new("BillboardGui")
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.3
    frame.Parent = billboard

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Parent = frame
    uiStroke.Thickness = 1
    uiStroke.Color = Color3.fromRGB(127, 3, 252)

    local uiCorner = Instance.new("UICorner")
    uiCorner.Parent = frame
    uiCorner.CornerRadius = UDim.new(0, 4)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.TextColor3 = Color3.fromRGB(199, 127, 235)
    nameLabel.Parent = frame

    -- Function to update name and size dynamically
    local function updateName()
        local displayName = player.DisplayName or "Player"
        nameLabel.Text = displayName
        billboard.Size = calculateWidth(displayName)
    end

    -- Ensure player character is set up properly
    local function onCharacterAdded(character)
        local head = character:WaitForChild("Head", 10)
        if head then
            billboard.Adornee = head
            billboard.Parent = game.Workspace
            updateName()

            local humanoid = character:WaitForChild("Humanoid", 10)
            if humanoid then
                humanoid.Died:Connect(function()
                    billboard.Parent = nil
                end)
            end

            character.AncestryChanged:Connect(function(_, parent)
                if not parent then
                    billboard.Parent = nil
                end
            end)
        end
    end

    -- Handle respawn and character removal
    player.CharacterAdded:Connect(onCharacterAdded)

    if player.Character then
        onCharacterAdded(player.Character)
    end

    player:GetPropertyChangedSignal("DisplayName"):Connect(updateName)
end

-- Create BillboardGui for existing players
for _, player in pairs(Players:GetPlayers()) do
    createBillboard(player)
end

-- Create BillboardGui for new players
Players.PlayerAdded:Connect(createBillboard)
