local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

-- Function to calculate the width based on the name length
local function calculateWidth(name)
    if type(name) ~= "string" then
        return UDim2.new(0, 0, 0, 20) -- Return a default size if name is not a string
    end
    
    local textSize = TextService:GetTextSize(name, 14, Enum.Font.GothamBold, Vector2.new(1000, 1000))
    return UDim2.new(0, textSize.X + 10, 0, 20) -- Add padding for the frame
end

-- Function to create a BillboardGui for the player
local function createBillboard(player)
    -- Ensure the player has a character
    if not player.Character then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Size = calculateWidth(player.DisplayName or "Player")
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    -- Create Frame for background
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

    -- Update name and size if necessary
    local function updateName()
        local displayName = player.DisplayName
        if type(displayName) == "string" and displayName ~= "" then
            nameLabel.Text = displayName
            billboard.Size = calculateWidth(displayName)
        end
    end

    player:GetPropertyChangedSignal("DisplayName"):Connect(updateName)

    -- Update the billboard position and size when the character is added or respawned
    local function onCharacterAdded(character)
        if not character:IsA("Model") then return end -- Check if the character is a valid model

        local head = character:WaitForChild("Head", 5) -- Ensure head is available with a timeout
        if head then
            billboard.Adornee = head

            -- Attempt to parent the billboard and handle errors
            local success, err = pcall(function()
                billboard.Parent = game.Workspace -- Parent the billboard
            end)

            if not success then
                warn("Failed to parent BillboardGui: " .. tostring(err))
                return -- Exit if we can't parent the BillboardGui
            end

            -- Update size initially
            updateName()

            -- Cleanup the billboard when the character dies
            local humanoid = character:WaitForChild("Humanoid", 5)
            if humanoid then
                humanoid.Died:Connect(function()
                    if billboard and billboard.Parent then
                        billboard:Destroy() -- Destroy billboard on death
                    end
                end)
            end

            -- Additional check for character destruction
            character.AncestryChanged:Connect(function(_, parent)
                if not parent then
                    billboard:Destroy() -- Destroy the billboard if the character is removed from the hierarchy
                end
            end)
        else
            warn("Head not found for player: " .. player.Name)
        end
    end

    player.CharacterAdded:Connect(onCharacterAdded)

    -- If player is already in the game, set up their character
    if player.Character then
        onCharacterAdded(player.Character)
    end

    -- Cleanup when player leaves
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

-- Regularly update all billboards
while true do
    wait(1) -- Update every second
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local billboard = player.Character:FindFirstChildOfClass("BillboardGui")
                if billboard then
                    billboard.Adornee = head -- Ensure the adornee is correct
                    billboard.Size = calculateWidth(player.DisplayName or "Player") -- Update size if needed
                else
                    setupPlayer(player) -- If the billboard doesn't exist, create it
                end
            else
                warn("Head not found for player: " .. player.Name)
            end
        end
    end
end
