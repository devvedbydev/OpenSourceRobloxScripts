local c = workspace.CurrentCamera
local ps = game:GetService("Players")
local lp = ps.LocalPlayer
local rs = game:GetService("RunService")

local function esp(p, cr)
    local h = cr:WaitForChild("Humanoid", 5)
    local hrp = cr:WaitForChild("Head", 5)

    if not h or not hrp then return end

    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = false
    text.Font = 3
    text.Size = 16.16
    text.Color = Color3.new(1, 1, 1)

    local connectionRender, connectionAncestry, connectionHealth

    local function dc()
        text.Visible = false
        text:Remove()
        if connectionRender then connectionRender:Disconnect() end
        if connectionAncestry then connectionAncestry:Disconnect() end
        if connectionHealth then connectionHealth:Disconnect() end
    end

    connectionAncestry = cr.AncestryChanged:Connect(function(_, parent)
        if not parent then dc() end
    end)

    connectionHealth = h.HealthChanged:Connect(function(v)
        if v <= 0 or h:GetState() == Enum.HumanoidStateType.Dead then dc() end
    end)

    connectionRender = rs.RenderStepped:Connect(function()
        local hrp_pos, hrp_onscreen = c:WorldToViewportPoint(hrp.Position)
        if hrp_onscreen then
            local distance = (hrp.Position - lp.Character.HumanoidRootPart.Position).Magnitude
            text.Position = Vector2.new(hrp_pos.X, hrp_pos.Y - 50)
            text.Text = "[ " .. p.DisplayName .. " - " .. math.floor(distance) .. "M ]"
            text.Visible = true
        else
            text.Visible = false
        end
    end)
end

local function p_added(p)
    coroutine.wrap(function()
        if p.Character then esp(p, p.Character) end
        p.CharacterAdded:Connect(function(cr) esp(p, cr) end)
    end)()
end

for _, p in ipairs(ps:GetPlayers()) do 
    if p ~= lp then p_added(p) end
end

ps.PlayerAdded:Connect(p_added)
