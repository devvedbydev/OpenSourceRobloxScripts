_G.Keybind = Enum.KeyCode.Z

local speedMultiplier = 1    
local active = false           
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')

UserInputService.InputBegan:Connect(function(input, isProcessed)
    if isProcessed then return end
    if input.KeyCode == _G.Keybind then
        active = not active
    end
end)

RunService.Stepped:Connect(function()
    if active and game.Players.LocalPlayer.Character then
        local character = game.Players.LocalPlayer.Character
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

        if humanoidRootPart and character:FindFirstChild("Humanoid") then
            local moveDirection = character.Humanoid.MoveDirection
            humanoidRootPart.CFrame = humanoidRootPart.CFrame + (moveDirection * speedMultiplier)
        end
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1)
    for _, v in pairs(character:GetChildren()) do
        if v:IsA("Script") and v.Name ~= "Health" and v.Name ~= "Sound" and v:FindFirstChild("LocalScript") then
            v:Destroy()
        end
    end
end)

if game.Players.LocalPlayer.Character then
    for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v:IsA("Script") and v.Name ~= "Health" and v.Name ~= "Sound" and v:FindFirstChild("LocalScript") then
            v:Destroy()
        end
    end
end
