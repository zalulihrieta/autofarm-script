local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- KOORDINAT DEX (STRICT)
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
    Vector3.new(-3561.621, -48.363, -19198.789), Vector3.new(-3540.583, -60.502, -20055.285),
    Vector3.new(-3435.471, -80.040, -20905.476), Vector3.new(-3291.044, -35.812, -21748.630),
    Vector3.new(-3142.453, -62.217, -22593.580), Vector3.new(-3129.451, -64.569, -23452.416),
    Vector3.new(-3131.285, -64.569, -24310.808), Vector3.new(-3131.408, -64.871, -25169.212),
    Vector3.new(-3131.311, -47.549, -26026.867), Vector3.new(-3129.580, -64.569, -26883.441),
    Vector3.new(-3129.035, -64.569, -27743.273)
}

-- SETUP UI
local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "CDID_RACE_V9"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 310, 0, 260)
main.Position = UDim2.new(0.5, -155, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Active = true

local topBar = Instance.new("TextLabel", main)
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.Text = "  CDID RACE TP (DRAG HERE)"
topBar.BackgroundColor3 = Color3.fromRGB(150,0,0)
topBar.TextColor3 = Color3.new(1,1,1)
topBar.Font = Enum.Font.GothamBold
topBar.TextXAlignment = Enum.TextXAlignment.Left

local npcFrame = Instance.new("Frame", main)
npcFrame.Size = UDim2.new(0, 100, 1, -30)
npcFrame.Position = UDim2.new(0, 0, 0, 30)
npcFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)

local cpFrame = Instance.new("ScrollingFrame", main)
cpFrame.Size = UDim2.new(0, 210, 1, -30)
cpFrame.Position = UDim2.new(0, 100, 0, 30)
cpFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
cpFrame.CanvasSize = UDim2.new(0,0,0, 1400)
cpFrame.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", cpFrame)
layout.Padding = UDim.new(0, 2)

-- FUNGSI DRAG (STABLE)
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- FUNGSI TELEPORT ULTIMATE (PIVOT + VELOCITY RESET)
local function forceTP(pos)
    local char = player.Character
    if not char then return end
    
    local targetCFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    -- Cek Kendaraan
    local objToMove = char:FindFirstChild("HumanoidRootPart")
    if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        local car = hum.SeatPart.Parent
        while car and not car:IsA("Model") do car = car.Parent end
        if car then objToMove = car end
    end

    if objToMove then
        -- Matikan Kecepatan (Penting agar tidak mental)
        if objToMove:IsA("Model") then
            for _, p in pairs(objToMove:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.AssemblyLinearVelocity = Vector3.zero
                    p.AssemblyAngularVelocity = Vector3.zero
                end
            end
            objToMove:PivotTo(targetCFrame) -- Metode terbaru Roblox untuk pindah model
        else
            objToMove.AssemblyLinearVelocity = Vector3.zero
            objToMove.CFrame = targetCFrame
        end
    end
end

-- BUTTON BUILDER
local function addBtn(txt, pos, parent, color)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 32)
    b.Text = txt
    b.BackgroundColor3 = color or Color3.fromRGB(50,50,50)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    b.MouseButton1Click:Connect(function() forceTP(pos) end)
end

addBtn("START NPC", DA0ZA_POS, npcFrame, Color3.fromRGB(0, 120, 0))
for i, p in ipairs(CP_LIST) do
    local lab = (i == #CP_LIST) and "FINISH" or "CP "..i
    local col = (i == #CP_LIST) and Color3.fromRGB(0, 80, 200) or nil
    addBtn(lab, p, cpFrame, col)
end

-- MINIMIZE & TOGGLE
local isVisible = true
local function toggle()
    isVisible = not isVisible
    npcFrame.Visible = isVisible
    cpFrame.Visible = isVisible
    main.Size = isVisible and UDim2.new(0, 310, 0, 260) or UDim2.new(0, 310, 0, 30)
end

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -30, 0, 0)
minBtn.Text = "_"
minBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.MouseButton1Click:Connect(toggle)

UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.RightControl then toggle() end
end)
