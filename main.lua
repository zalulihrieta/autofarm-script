-- AUTO FARM HUB FINAL (SOLAR SAFE)
-- GUI + LOGIC DISATUIN
-- InputBegan + CoreGui (ANTI BUG SOLAR)

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ================= CFRAME =================
local AutoFarmCFrame = CFrame.new(-280,167,341)
local LobbyCFrame    = CFrame.new(-226,180,327)
local GameAreaCFrame = CFrame.new(-104,48,11)

-- ================= STATE =================
local AutoFarm = false
local hrp

-- ================= ANTI AFK =================
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- ================= CHARACTER =================
local function onChar(char)
    hrp = char:WaitForChild("HumanoidRootPart",5)
    if AutoFarm and hrp then
        task.wait(0.4)
        hrp.CFrame = AutoFarmCFrame
    end
end
player.CharacterAdded:Connect(onChar)
if player.Character then onChar(player.Character) end

-- ================= AUTOFARM LOOP =================
RunService.Heartbeat:Connect(function()
    if not AutoFarm or not hrp then return end
    if (hrp.Position - AutoFarmCFrame.Position).Magnitude > 10 then
        hrp.CFrame = AutoFarmCFrame
    end
end)

-- ================= GUI ROOT =================
pcall(function()
    if CoreGui:FindFirstChild("AutoFarmHub_SOLAR") then
        CoreGui.AutoFarmHub_SOLAR:Destroy()
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmHub_SOLAR"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

-- ================= FLOAT BUTTON =================
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0,60,0,60)
openBtn.Position = UDim2.new(0,20,0.5,-30)
openBtn.Text = "≡"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 26
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
openBtn.ZIndex = 100
openBtn.Active = true
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1,0)

-- ================= MAIN FRAME =================
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,280,0,260)
frame.Position = UDim2.new(0.5,-140,0.5,-130)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Visible = false
frame.ZIndex = 90
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,18)

-- ================= TOP BAR =================
local top = Instance.new("Frame", frame)
top.Size = UDim2.new(1,0,0,44)
top.BackgroundTransparency = 1
top.ZIndex = 91

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,-50,1,0)
title.Position = UDim2.new(0,16,0,0)
title.Text = "AUTO FARM HUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 92

local closeBtn = Instance.new("TextButton", top)
closeBtn.Size = UDim2.new(0,36,0,36)
closeBtn.Position = UDim2.new(1,-44,0,4)
closeBtn.Text = "–"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BackgroundColor3 = Color3.fromRGB(55,55,55)
closeBtn.ZIndex = 92
closeBtn.Active = true
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1,0)

-- ================= CONTENT =================
local content = Instance.new("Frame", frame)
content.Position = UDim2.new(0,0,0,44)
content.Size = UDim2.new(1,0,1,-44)
content.BackgroundTransparency = 1
content.ZIndex = 91

local function makeBtn(text,y)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(1,-32,0,48)
    b.Position = UDim2.new(0,16,0,y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(55,55,55)
    b.ZIndex = 92
    b.Active = true
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,14)
    return b
end

local farmBtn  = makeBtn("AUTO FARM : OFF",10)
local lobbyBtn = makeBtn("TP LOBBY",70)
local gameBtn  = makeBtn("TP GAME AREA",130)

-- ================= INPUT (SOLAR SAFE) =================
openBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        frame.Visible = true
        frame.Position = UDim2.new(0.5,-140,0.5,-130)
    end
end)

closeBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        frame.Visible = false
    end
end)

farmBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        AutoFarm = not AutoFarm
        farmBtn.Text = AutoFarm and "AUTO FARM : ON" or "AUTO FARM : OFF"
        if AutoFarm and hrp then
            hrp.CFrame = AutoFarmCFrame
        end
    end
end)

lobbyBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        AutoFarm = false
        farmBtn.Text = "AUTO FARM : OFF"
        if hrp then hrp.CFrame = LobbyCFrame end
    end
end)

gameBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        AutoFarm = false
        farmBtn.Text = "AUTO FARM : OFF"
        if hrp then hrp.CFrame = GameAreaCFrame end
    end
end)

print("AUTO FARM HUB SOLAR FINAL LOADED")
