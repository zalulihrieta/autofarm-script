-- AUTO FARM SAFE FINAL++ (ANTI FLING FIX + RIGHT CTRL HIDE)
-- Anti Fall + Noclip + Anti AFK + Anti Fling FIX + Infinite Yield GUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ====== CFRAME ======
local AutoFarmCFrame = CFrame.new(-280, 167, 341)
local LobbyCFrame    = CFrame.new(-226, 180, 327)
local GameAreaCFrame = CFrame.new(-104, 48, 11)

-- ====== CONFIG ======
local TP_INTERVAL  = 0.6
local MAX_DISTANCE = 10
local FALL_OFFSET  = 12

-- ====== ANTI FLING CONFIG ======
local MAX_LIN_VEL = 80
local MAX_ANG_VEL = 40

-- ====== STATE ======
local AutoFarm = false
local lastTP = 0
local hrp, character

-- ====== ANTI AFK ======
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- ====== NOCLIP ALWAYS ON ======
RunService.Stepped:Connect(function()
    if not character then return end
    for _,v in ipairs(character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end)

-- ====== ANTI FLING + NOCLIP (IY STYLE FINAL) ======
local AntiFling = true

-- disable collision antar player (inti Infinite Yield)
local function disableCollision(char)
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end

-- bersihin force berbahaya
local function cleanForces(root)
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("BodyVelocity")
        or v:IsA("BodyAngularVelocity")
        or v:IsA("LinearVelocity")
        or v:IsA("AngularVelocity")
        or v:IsA("VectorForce") then
            v:Destroy()
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not AntiFling or not character or not hrp then return end

    -- 1️⃣ noclip / no player collision
    disableCollision(character)

    local lv = hrp.AssemblyLinearVelocity
    local av = hrp.AssemblyAngularVelocity

    -- 2️⃣ clamp velocity (HALUS, BUKAN FREEZE)
    if lv.Magnitude > 90 then
        hrp.AssemblyLinearVelocity = lv.Unit * 25
    end

    if av.Magnitude > 60 then
        hrp.AssemblyAngularVelocity = Vector3.zero
    end

    -- 3️⃣ emergency (kalau fling brutal)
    if lv.Magnitude > 150 or av.Magnitude > 120 then
        cleanForces(hrp)
    end
end)


-- ====== GUI ======
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AutoFarmGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 245)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "AUTO FARM"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)

local function makeBtn(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -20, 0, 35)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(55,55,55)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local autoBtn  = makeBtn("AUTO FARM : OFF", 40)
local lobbyBtn = makeBtn("TP LOBBY", 85)
local gameBtn  = makeBtn("TP GAME AREA", 130)
local iyBtn    = makeBtn("INFINITE YIELD", 175)

-- ====== BUTTON LOGIC ======
autoBtn.MouseButton1Click:Connect(function()
    AutoFarm = not AutoFarm
    autoBtn.Text = AutoFarm and "AUTO FARM : ON" or "AUTO FARM : OFF"
    if AutoFarm and hrp then
        hrp.CFrame = AutoFarmCFrame
    end
end)

lobbyBtn.MouseButton1Click:Connect(function()
    AutoFarm = false
    autoBtn.Text = "AUTO FARM : OFF"
    if hrp then hrp.CFrame = LobbyCFrame end
end)

gameBtn.MouseButton1Click:Connect(function()
    AutoFarm = false
    autoBtn.Text = "AUTO FARM : OFF"
    if hrp then hrp.CFrame = GameAreaCFrame end
end)

iyBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
    ))()
end)

-- ====== RIGHT CTRL HIDE GUI ======
local guiVisible = true
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        guiVisible = not guiVisible
        frame.Visible = guiVisible
    end
end)

-- ====== MOBILE TOGGLE BUTTON ======
local mobileBtn = Instance.new("TextButton", gui)
mobileBtn.Size = UDim2.new(0, 50, 0, 50)
mobileBtn.Position = UDim2.new(0, 10, 0.6, 0)
mobileBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
mobileBtn.Text = "≡"
mobileBtn.TextSize = 24
mobileBtn.Font = Enum.Font.GothamBold
mobileBtn.TextColor3 = Color3.new(1,1,1)
mobileBtn.BorderSizePixel = 0
mobileBtn.Active = true
mobileBtn.Draggable = true
Instance.new("UICorner", mobileBtn).CornerRadius = UDim.new(1, 0)

mobileBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    frame.Visible = guiVisible
end)

print("Auto Farm By Zaluli_Hrieta")
