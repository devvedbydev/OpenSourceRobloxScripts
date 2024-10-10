local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

-- Function to calculate the width based on the name length
local function calculateWidth(name)
    local textSize = TextService:GetTextSize(name, 14, Enum.Font.GothamBold, Vector2.new(1000, 1000)) -- Calculate size based on text properties
    return UDim2.new(0, textSize.X + 10, 0, 20) -- Add padding for the frame
end

-- Create BillboardGui for the player
local function createBillboard(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = player.Character:WaitForChild("Head")
    billboard.StudsOffset = Vector3.new(0, 2, 0) -- Offset above the head
    billboard.AlwaysOnTop = true
    billboard.Size = calculateWidth(player.DisplayName) -- Set initial size based on the name
    billboard.Parent = game.Workspace

    -- Create Frame for background
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0) -- Full size of the BillboardGui
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

    -- Create Display Name Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName
    nameLabel.TextColor3 = Color3.fromRGB(199, 127, 235)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14 -- Adjust text size for clarity
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Parent = frame

    -- Update name and size if necessary
    local function updateName()
        nameLabel.Text = player.DisplayName
        billboard.Size = calculateWidth(player.DisplayName) -- Adjust size based on new name
    end

    player:GetPropertyChangedSignal("DisplayName"):Connect(updateName)

    -- Ensure the billboard is updated when the character respawns
    player.CharacterRemoving:Connect(function()
        billboard:Destroy()
    end)

    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Head") -- Ensure head is available
        billboard.Adornee = character.Head -- Update the adornee to the new character head
        billboard.Parent = game.Workspace -- Reparent the billboard
        updateName() -- Update name on respawn
    end)

    -- Cleanup when player leaves
    Players.PlayerRemoving:Connect(function(p)
        if p == player then
            billboard:Destroy()
        end
    end)
end

-- Create BillboardGui for all players
local function setupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart") -- Wait for character to load
        createBillboard(player)
    end)

    -- If player is already in the game
    if player.Character then
        createBillboard(player)
    end
end

-- Setup existing players
for _, player in pairs(Players:GetPlayers()) do
    setupPlayer(player)
end

-- Setup new players joining the game
Players.PlayerAdded:Connect(setupPlayer)
