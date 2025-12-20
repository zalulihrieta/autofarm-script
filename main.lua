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

-- ====== NOCLIP (RINGAN) ======
RunService.Stepped:Connect(function()
    if not AutoFarm or not character then return end
    for _,v in ipairs(character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end)

-- ====== ANTI FLING FORCE CLEANER ======
local function clearForces(root)
    for _,v in ipairs(root:GetChildren()) do
        if v:IsA("BodyVelocity")
        or v:IsA("BodyAngularVelocity")
        or v:IsA("BodyForce")
        or v:IsA("LinearVelocity")
        or v:IsA("AngularVelocity")
        or v:IsA("VectorForce") then
            v:Destroy()
        end
    end
end

-- ====== CHARACTER HANDLER ======
local function onCharacter(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart", 5)

    if AutoFarm and hrp then
        task.wait(0.6)
        hrp.CFrame = AutoFarmCFrame
    end
end

player.CharacterAdded:Connect(onCharacter)
if player.Character then
    onCharacter(player.Character)
end

-- ====== AUTO FARM + ANTI FALL + ANTI FLING ======
RunService.Heartbeat:Connect(function()
    if not AutoFarm or not hrp then return end

    local now = tick()
    if now - lastTP >= TP_INTERVAL then
        local dist = (hrp.Position - AutoFarmCFrame.Position).Magnitude
        local fall = hrp.Position.Y < (AutoFarmCFrame.Position.Y - FALL_OFFSET)
        if dist > MAX_DISTANCE or fall then
            hrp.CFrame = AutoFarmCFrame
            lastTP = now
        end
    end

    -- ====== ANTI FLING FIX ======
    local lv = hrp.AssemblyLinearVelocity
    local av = hrp.AssemblyAngularVelocity

    if lv.Magnitude > MAX_LIN_VEL or av.Magnitude > MAX_ANG_VEL then
        clearForces(hrp)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero

        if lv.Magnitude > 200 then
            hrp.CFrame = AutoFarmCFrame
        end
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

print("Auto Farm By Zaluli_Hrieta")
