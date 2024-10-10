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
    -- Ensure the player has a character
    if not player.Character then return end

    -- Create BillboardGui and Frame
    local billboard = Instance.new("BillboardGui")
    billboard.Size = calculateWidth(player.DisplayName or "Player")
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

    -- Create Display Name Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName or "Player"
    nameLabel.TextColor3 = Color3.fromRGB(199, 127, 235)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Parent = frame

    -- Update name and size dynamically
    local function updateName()
        local displayName = player.DisplayName
        if type(displayName) == "string" and displayName ~= "" then
            nameLabel.Text = displayName
            billboard.Size = calculateWidth(displayName)
        end
    end

    player:GetPropertyChangedSignal("DisplayName"):Connect(updateName)

    -- Attach BillboardGui to player's head when they spawn
    local function onCharacterAdded(character)
        if not character:IsA("Model") then return end -- Ensure it's a valid character

        local head = character:WaitForChild("Head", 5) -- Get head part with timeout
        if head then
            billboard.Adornee = head
            billboard.Parent = game.Workspace -- Attach BillboardGui to the world
            updateName() -- Update name display

            -- Cleanup billboard when player dies or character is removed
            local humanoid = character:WaitForChild("Humanoid", 5)
            if humanoid then
                humanoid.Died:Connect(function()
                    billboard.Parent = nil -- Temporarily remove on death
                end)
            end

            -- Reattach BillboardGui if the character is removed from the hierarchy
            character.AncestryChanged:Connect(function(_, parent)
                if not parent then
                    billboard.Parent = nil -- Remove the BillboardGui if the character is gone
                end
            end)
        end
    end

    -- Set up character added/respawn handling
    player.CharacterAdded:Connect(onCharacterAdded)

    -- If the player already has a character, set up the BillboardGui immediately
    if player.Character then
        onCharacterAdded(player.Character)
    end

    -- Cleanup billboard when player leaves
    Players.PlayerRemoving:Connect(function(p)
        if p == player and billboard then
            billboard:Destroy()
        end
    end)
end

-- Create BillboardGui for all players
local function setupPlayer(player)
    createBillboard(player)
end

-- Setup existing players
for _, player in pairs(Players:GetPlayers()) do
    setupPlayer(player)
end

-- Setup new players joining the game
Players.PlayerAdded:Connect(setupPlayer)
