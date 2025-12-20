-- AUTO FARM HUB (STEP 2)
-- GUI Hybrid (PC + HP) + Clean Design
-- Logic & GUI dipisah section

-- ================= CORE =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- CFRAME
local AutoFarmCFrame = CFrame.new(-280,167,341)
local LobbyCFrame    = CFrame.new(-226,180,327)
local GameAreaCFrame = CFrame.new(-104,48,11)

-- STATE
local Core = {}
Core.AutoFarm = false

local hrp, character

-- Anti AFK
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Character
local function onChar(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart",5)
    if Core.AutoFarm and hrp then
        task.wait(0.4)
        hrp.CFrame = AutoFarmCFrame
    end
end
player.CharacterAdded:Connect(onChar)
if player.Character then onChar(player.Character) end

-- AutoFarm loop (simple & safe)
RunService.Heartbeat:Connect(function()
    if not Core.AutoFarm or not hrp then return end
    if (hrp.Position - AutoFarmCFrame.Position).Magnitude > 10 then
        hrp.CFrame = AutoFarmCFrame
    end
end)

-- CORE API
function Core.ToggleFarm()
    Core.AutoFarm = not Core.AutoFarm
    if Core.AutoFarm and hrp then
        hrp.CFrame = AutoFarmCFrame
    end
    return Core.AutoFarm
end

function Core.TPLobby()
    Core.AutoFarm = false
    if hrp then hrp.CFrame = LobbyCFrame end
end

function Core.TPGame()
    Core.AutoFarm = false
    if hrp then hrp.CFrame = GameAreaCFrame end
end

-- ================= GUI =================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false
gui.Name = "AutoFarmHub"

-- Floating Button (HYBRID)
local floatBtn = Instance.new("TextButton", gui)
floatBtn.Size = UDim2.new(0,56,0,56)
floatBtn.Position = UDim2.new(0,20,0.5,-28)
floatBtn.Text = "≡"
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 24
floatBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
floatBtn.TextColor3 = Color3.new(1,1,1)
floatBtn.Active = true
floatBtn.Draggable = true
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1,0)

-- Main Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,280,0,260)
frame.Position = UDim2.new(0.5,-140,0.5,-130)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Visible = false
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,18)

-- TopBar
local top = Instance.new("Frame", frame)
top.Size = UDim2.new(1,0,0,44)
top.BackgroundTransparency = 1

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,-50,1,0)
title.Position = UDim2.new(0,16,0,0)
title.Text = "AUTO FARM HUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Left

local close = Instance.new("TextButton", top)
close.Size = UDim2.new(0,36,0,36)
close.Position = UDim2.new(1,-44,0,4)
close.Text = "–"
close.Font = Enum.Font.GothamBold
close.TextSize = 22
close.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", close).CornerRadius = UDim.new(1,0)

-- Content
local content = Instance.new("Frame", frame)
content.Position = UDim2.new(0,0,0,44)
content.Size = UDim2.new(1,0,1,-44)
content.BackgroundTransparency = 1

local function makeBtn(text,y)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(1,-32,0,48)
    b.Position = UDim2.new(0,16,0,y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(55,55,55)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,14)
    return b
end

local farmBtn  = makeBtn("AUTO FARM : OFF",10)
local lobbyBtn = makeBtn("TP LOBBY",70)
local gameBtn  = makeBtn("TP GAME AREA",130)

-- ================= GUI ↔ CORE =================
floatBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

close.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

farmBtn.MouseButton1Click:Connect(function()
    local state = Core.ToggleFarm()
    farmBtn.Text = state and "AUTO FARM : ON" or "AUTO FARM : OFF"
end)

lobbyBtn.MouseButton1Click:Connect(function()
    Core.TPLobby()
    farmBtn.Text = "AUTO FARM : OFF"
end)

gameBtn.MouseButton1Click:Connect(function()
    Core.TPGame()
    farmBtn.Text = "AUTO FARM : OFF"
end)

print("STEP 2 LOADED — GUI HYBRID CONNECTED")
