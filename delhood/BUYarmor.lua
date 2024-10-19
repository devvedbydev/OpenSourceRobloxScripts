local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local originalPosition = character.HumanoidRootPart.Position
local armorObject = workspace.Ignored.Shop["[High-Max Armor]"]
local clickDetector = armorObject:FindFirstChild("ClickDetector")

local function getModelPosition(model)
    if model.PrimaryPart then
        return model.PrimaryPart.Position
    else
        for _, part in ipairs(model:GetChildren()) do
            if part:IsA("BasePart") then
                return part.Position
            end
        end
    end
    return nil
end

local function teleportTo(position)
    if position then
        character:SetPrimaryPartCFrame(CFrame.new(position))
    else
        warn("invalid position")
    end
end

local armorPosition = getModelPosition(armorObject)
teleportTo(armorPosition)

if clickDetector then
    fireclickdetector(clickDetector)
else
    warn("no click detector found for armor")
end

teleportTo(originalPosition)
