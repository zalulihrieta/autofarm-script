local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- KOORDINAT DARI DEX
local DA0ZA_POS = Vector3.new(-7.834, 3.018, 441.855)
local CP_LIST = {
	Vector3.new(125.047, 18.230, -415.173), Vector3.new(127.560, 18.230, -1272.893),
	Vector3.new(-175.222, 9.898, -2039.384), Vector3.new(-1010.847, 10.851, -2169.610),
	Vector3.new(-1857.361, 0.708, -2229.303), Vector3.new(-2649.200, -14.205, -2553.579),
	Vector3.new(-3327.876, -23.301, -3053.103), Vector3.new(-2962.862, -17.169, -3810.042),
	Vector3.new(-2546.484, -17.120, -4562.124), Vector3.new(-2130.460, -29.626, -5311.785),
	Vector3.new(-1700.404, -25.409, -6054.656), Vector3.new(-1254.418, -61.608, -6785.946),
	Vector3.new(-940.448, -43.987, -7579.504), Vector3.new(-1479.288, -39.616, -8167.926),
	Vector3.new(-2229.668, -41.489, -8583.870), Vector3.new(-2952.909, -33.532, -9039.446),
	Vector3.new(-3522.562, -29.659, -9674.159), Vector3.new(-3933.819, -13.608, -10423.113),
	Vector3.new(-3813.763, -12.947, -11209.539), Vector3.new(-3271.031, -72.941, -11870.837),
	Vector3.new(-2767.282, -55.455, -12562.348), Vector3.new(-2530.257, -27.704, -13351.724),
	Vector3.new(-2810.242, -23.909, -14163.191), Vector3.new(-3094.182, -21.090, -14972.988),
	Vector3.new(-3364.902, -33.049, -15785.451), Vector3.new(-3503.131, -19.988, -16630.316),
	Vector3.new(-3555.158, -61.729, -17485.587), Vector3.new(-3575.711, -73.812, -18341.179),
	Vector3.new(-3561.621, -48.363, -19198.789), Vector3.new(3540.583, -60.502, -20055.285),
	Vector3.new(-3435.471, -80.040, -20905.476), Vector3.new(-3291.044, -35.812, -21748.630),
	Vector3.new(-3142.453, -62.217, -22593.580), Vector3.new(-3129.451, -64.569, -23452.416),
	Vector3.new(-3131.285, -64.569, -24310.808), Vector3.new(-3131.408, -64.871, -25169.212),
	Vector3.new(-3131.311, -47.549, -26026.867), Vector3.new(-3129.580, -64.569, -26883.441),
	Vector3.new(-3129.035, -64.569, -27743.273) -- Finish
}

-- 1. SETUP UI
local sg = Instance.new("ScreenGui")
sg.Name = "CDID_Race_Draggable"
sg.ResetOnSpawn = false
sg.Parent = pGui

-- Frame Utama (Yang bisa ditarik)
local masterFrame = Instance.new("Frame")
masterFrame.Size = UDim2.new(0, 320, 0, 260)
masterFrame.Position = UDim2.new(0.5, -160, 0.4, 0)
masterFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
masterFrame.BackgroundTransparency = 0.8
masterFrame.BorderSizePixel = 0
masterFrame.Parent = sg

-- Layer Kiri (NPC Section)
local leftFrame = Instance.new("Frame")
leftFrame.Size = UDim2.new(0, 100, 0, 100)
leftFrame.Position = UDim2.new(0, 0, 0, 30)
leftFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
leftFrame.Parent = masterFrame

-- Layer Kanan (Checkpoint Section)
local rightFrame = Instance.new("ScrollingFrame")
rightFrame.Size = UDim2.new(0, 210, 1, -30)
rightFrame.Position = UDim2.new(0, 110, 0, 30)
rightFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
rightFrame.CanvasSize = UDim2.new(0, 0, 0, 1350)
rightFrame.ScrollBarThickness = 6
rightFrame.Parent = masterFrame

local layout = Instance.new("UIListLayout")
layout.Parent = rightFrame
layout.Padding = UDim.new(0, 3)

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.Text = " DRAG ME TO MOVE MENU"
titleBar.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 14
titleBar.Parent = masterFrame

-- 2. LOGIKA DRAG (PC & MOBILE)
local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end
makeDraggable(masterFrame)

-- 3. FUNGSI TP (ANTI-MENTAL & VEHICLE SUPPORT)
local function teleport(pos)
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local targetPos = pos + Vector3.new(0, 4, 0)

	-- Cek apakah player di dalam mobil
	if hum and hum.SeatPart then
		local car = hum.SeatPart:FindFirstAncestorOfClass("Model")
		if car then
			-- Reset Momentum Mobil supaya tidak mental/terbang
			for _, p in pairs(car:GetDescendants()) do
				if p:IsA("BasePart") then
					p.Velocity = Vector3.new(0,0,0)
					p.RotVelocity = Vector3.new(0,0,0)
				end
			end
			car:MoveTo(targetPos)
			return
		end
	end
	-- Jika jalan kaki
	char:MoveTo(targetPos)
end

-- 4. BUTTON GENERATOR
local function createBtn(name, pos, parent, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -10, 0, 32)
	b.Text = name
	b.BackgroundColor3 = color or Color3.fromRGB(50, 50, 50)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 14
	b.Parent = parent
	b.MouseButton1Click:Connect(function() teleport(pos) end)
end

-- Masukkan Tombol NPC
createBtn("DA0ZA (START)", DA0ZA_POS, leftFrame, Color3.fromRGB(0, 130, 0))

-- Masukkan List CP secara urut
for i, pos in ipairs(CP_LIST) do
	local label = (i == #CP_LIST) and "FINISH" or "CHECKPOINT "..i
	local col = (i == #CP_LIST) and Color3.fromRGB(0, 80, 200) or nil
	createBtn(label, pos, rightFrame, col)
end

-- 5. MINIMIZE (Right Control & Tombol Mobile)
local visible = true
local function toggleUI()
	visible = not visible
	leftFrame.Visible = visible
	rightFrame.Visible = visible
	titleBar.Text = visible and " DRAG ME TO MOVE MENU" or " MENU HIDDEN"
	masterFrame.Size = visible and UDim2.new(0, 320, 0, 260) or UDim2.new(0, 320, 0, 30)
end

UserInputService.InputBegan:Connect(function(i, g)
	if not g and i.KeyCode == Enum.KeyCode.RightControl then toggleUI() end
end)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 25)
minBtn.Position = UDim2.new(1, -30, 0, 0)
minBtn.Text = "_"
minBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.Parent = masterFrame
minBtn.MouseButton1Click:Connect(toggleUI)
