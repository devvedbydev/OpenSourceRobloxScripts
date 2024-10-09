local WAIT = task.wait
local TBINSERT = table.insert
local TBREMOVE = table.remove
local V2 = Vector2.new
local ROUND = math.round

local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local To2D = Camera.WorldToViewportPoint
local LocalPlayer = game.Players.LocalPlayer

local Library = {}
Library.__index = Library

-- Functions
function Library:NewLine(info)
	local l = Drawing.new("Line")
	l.Visible = info.Visible or true
	l.Color = info.Color or Color3.fromRGB(127, 3, 252) -- Set to purple
	l.Transparency = info.Transparency or 1
	l.Thickness = info.Thickness or 4 -- Thicker lines
	return l
end

function Library:Smoothen(v)
	return V2(ROUND(v.X), ROUND(v.Y))
end

-- Skeleton Object
local Skeleton = {
	Removed = false,
	Player = nil,
	Visible = false,
	Lines = {},
	Color = Color3.fromRGB(127, 3, 252), -- Set to purple
	Alpha = 1,
	Thickness = 4,
	DoSubsteps = true,
}
Skeleton.__index = Skeleton

function Skeleton:UpdateStructure()
	if not self.Player.Character then return end

	self:RemoveLines()

	for _, part in next, self.Player.Character:GetChildren() do		
		if not part:IsA("BasePart") then continue end

		for _, link in next, part:GetChildren() do			
			if not link:IsA("Motor6D") then continue end
			
			local line1 = Library:NewLine({
				Visible = self.Visible,
				Color = self.Color,
				Transparency = self.Alpha,
				Thickness = self.Thickness,
			})

			local line2 = Library:NewLine({
				Visible = self.Visible,
				Color = self.Color,
				Transparency = self.Alpha,
				Thickness = self.Thickness,
			})

			TBINSERT(self.Lines, { line1, line2, part.Name, link.Name })
		end
	end
end

function Skeleton:SetVisible(State)
	for _, l in pairs(self.Lines) do
		l[1].Visible = State
		l[2].Visible = State
	end
end

function Skeleton:SetColor(Color)
	self.Color = Color
	for _, l in pairs(self.Lines) do
		l[1].Color = Color
		l[2].Color = Color
	end
end

function Skeleton:SetAlpha(Alpha)
	self.Alpha = Alpha
	for _, l in pairs(self.Lines) do
		l[1].Transparency = Alpha
		l[2].Transparency = Alpha
	end
end

function Skeleton:SetThickness(Thickness)
	self.Thickness = Thickness
	for _, l in pairs(self.Lines) do
		l[1].Thickness = Thickness
		l[2].Thickness = Thickness
	end
end

function Skeleton:SetDoSubsteps(State)
	self.DoSubsteps = State
end

-- Main Update Loop
function Skeleton:Update()
	if self.Removed then return end

	local Character = self.Player.Character
	if not Character then
		self:SetVisible(false)
		if not self.Player.Parent then
			self:Remove()
		end
		return
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then
		self:SetVisible(false)
		return
	end

	self:SetColor(self.Color)
	self:SetAlpha(self.Alpha)
	self:SetThickness(self.Thickness)

	for _, l in pairs(self.Lines) do
		local part = Character:FindFirstChild(l[3])
		if not part then
			l[1].Visible = false
			l[2].Visible = false
			continue
		end

		local link = part:FindFirstChild(l[4])
		if not (link and link.Part0 and link.Part1) then
			l[1].Visible = false
			l[2].Visible = false
			continue
		end

		local part0 = link.Part0
		local part1 = link.Part1
		
		if self.DoSubsteps and link.C0 and link.C1 then
			local c0 = link.C0
			local c1 = link.C1

			local part0p, v1 = To2D(Camera, part0.CFrame.p)
			local part0cp, v2 = To2D(Camera, (part0.CFrame * c0).p)
			
			if v1 and v2 then
				l[1].From = V2(part0p.x, part0p.y)
				l[1].To = V2(part0cp.x, part0cp.y)
				l[1].Visible = true
			else 
				l[1].Visible = false
			end
			
			local part1p, v3 = To2D(Camera, part1.CFrame.p)
			local part1cp, v4 = To2D(Camera, (part1.CFrame * c1).p)
		
			if v3 and v4 then
				l[2].From = V2(part1p.x, part1p.y)
				l[2].To = V2(part1cp.x, part1cp.y)
				l[2].Visible = true
			else 
				l[2].Visible = false
			end
		else					
			local part0p, v1 = To2D(Camera, part0.CFrame.p)
			local part1p, v2 = To2D(Camera, part1.CFrame.p)
			
			if v1 and v2 then
				l[1].From = V2(part0p.x, part0p.y)
				l[1].To = V2(part1p.x, part1p.y)
				l[1].Visible = true
			else 
				l[1].Visible = false
			end
			
			l[2].Visible = false
		end
	end
end

function Skeleton:Toggle()
	self.Visible = not self.Visible

	if self.Visible then 
		self:RemoveLines()
		self:UpdateStructure()
		
		local c
		c = RS.Heartbeat:Connect(function()
			if not self.Visible then
				self:SetVisible(false)
				c:Disconnect()
				return
			end

			self:Update()
		end)
	end
end

function Skeleton:RemoveLines()
	for _, l in pairs(self.Lines) do
		l[1]:Remove()
		l[2]:Remove()
	end
	self.Lines = {}
end

function Skeleton:Remove()
	self.Removed = true
	self:RemoveLines()
end

-- Create Skeleton Function
function Library:NewSkeleton(Player, Visible)
	if not Player then error("Missing Player argument (#1)") end
	
	local s = setmetatable({}, Skeleton)
	s.Player = Player
	
	if Visible then
		s:Toggle()
	end
	
	return s
end

-- Remove existing skeletons
if _G.Skeletons then
	for _, skeleton in pairs(_G.Skeletons) do
		skeleton:Remove()
	end
end

_G.Skeletons = {}

-- Create new skeletons for all players including the local player
for _, Player in next, game.Players:GetPlayers() do
	if Player ~= LocalPlayer then
		TBINSERT(_G.Skeletons, Library:NewSkeleton(Player, true))
	end
end

-- Also include the local player
TBINSERT(_G.Skeletons, Library:NewSkeleton(LocalPlayer, true))

game.Players.PlayerAdded:Connect(function(Player)
	TBINSERT(_G.Skeletons, Library:NewSkeleton(Player, true))
end)

-- Coroutine for updating all skeletons
coroutine.wrap(function()
	while true do
		for _, skeleton in next, _G.Skeletons do
			skeleton:SetColor(Color3.fromRGB(127, 3, 252)) -- Purple
			skeleton:SetThickness(4) -- Thicker lines
		end

		WAIT(1)
	end
end)()

