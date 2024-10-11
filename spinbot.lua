local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local spinning = true -- Always on
local speed = 30 -- Adjust this for faster spinning

-- Continuous spinning loop
game:GetService("RunService").Heartbeat:Connect(function()
    if spinning then
        -- Check if the player is moving
        if humanoidRootPart.Velocity.Magnitude < 1 then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(speed), 0)
        end
    end
end)
