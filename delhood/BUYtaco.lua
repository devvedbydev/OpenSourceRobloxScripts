local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local originalPosition = character.HumanoidRootPart.Position

local tacoObject = workspace.Ignored.Shop["[Taco]"]
local tacoClickDetector = tacoObject:FindFirstChild("ClickDetector")

local crouchingAnimation = game:GetService("ReplicatedStorage").ClientAnimations.Crouching

local animation = Instance.new("Animation")
animation.AnimationId = crouchingAnimation.AnimationId

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
        warn("Position is invalid!")
    end
end

local function handleTaco()
    local tacoPosition = getModelPosition(tacoObject)

    teleportTo(tacoPosition)

    if tacoClickDetector then
        fireclickdetector(tacoClickDetector)
    else
        warn("ClickDetector not found on [Taco]")
        return 
    end

    local crouchAnimTrack = humanoid:LoadAnimation(animation)
    crouchAnimTrack:Play()

    if tacoClickDetector then
        fireclickdetector(tacoClickDetector) 
    else
        warn("ClickDetector not found on [Taco]")
    end

    wait(1)

    if tacoClickDetector then
        fireclickdetector(tacoClickDetector)
    else
        warn("ClickDetector not found on [Taco]")
    end

    crouchAnimTrack:Stop()
end

handleTaco()

wait(1)

teleportTo(originalPosition)
