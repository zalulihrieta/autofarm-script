--================ SERVICES ================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local character, hrp, humanoid

--================ CONFIG =================
local AutoFarmCFrame = CFrame.new(-280, 167, 341)
local LobbyCFrame    = CFrame.new(-226, 180, 327)
local GameAreaCFrame = CFrame.new(-104, 48, 11)

local TP_INTERVAL  = 0.6
local MAX_DISTANCE = 10
local FALL_OFFSET  = 12

--================ STATE ==================
local AutoFarm = false
local lastTP = 0

--================ ANTI AFK ===============
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

--================ CHARACTER ==============
local function onCharacter(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")

    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then onCharacter(player.Character) end

--================ PROTECTION MODE =========
RunService.Heartbeat:Connect(function()
    if not character or not hrp then return end

    -- noclip (always)
    for _,v in ipairs(character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end

    -- anti fling / super ring
    for _,v in ipairs(character:GetDescendants()) do
        if v:IsA("BodyMover")
        or v:IsA("LinearVelocity")
        or v:IsA("AngularVelocity")
        or v:IsA("VectorForce")
        or v:IsA("AlignPosition")
        or v:IsA("AlignOrientation") then
            v:Destroy()
        end
    end
end)

--================ MOVEMENT CONTROL ========
RunService.Heartbeat:Connect(function()
    if not hrp or not humanoid then return end

    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Jumping
    or state == Enum.HumanoidStateType.Freefall then
        return
    end

    if hrp.AssemblyLinearVelocity.Magnitude > 65 then
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end)

--================ AUTO FARM ===============
RunService.Heartbeat:Connect(function()
    if not AutoFarm or not hrp or not humanoid then return end

    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Jumping
    or state == Enum.HumanoidStateType.Freefall then
        return
    end

    local now = tick()
    if now - lastTP >= TP_INTERVAL then
        local dist = (hrp.Position - AutoFarmCFrame.Position).Magnitude
        local fall = hrp.Position.Y < (AutoFarmCFrame.Position.Y - FALL_OFFSET)

        if dist > MAX_DISTANCE or fall then
            hrp.CFrame = AutoFarmCFrame
            lastTP = now
        end
    end
end)

--================ GUI =====================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,260,0,290)
main.Position = UDim2.new(0.05,0,0.35,0)
main.BackgroundColor3 = Color3.fromRGB(22,22,22)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(80,80,80)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,38)
title.BackgroundTransparency = 1
title.Text = "AUTO FARM"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.fromRGB(255,170,0)

local function makeButton(text,y)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(1,-24,0,38)
    b.Position = UDim2.new(0,12,0,y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    return b
end

local autoBtn  = makeButton("AUTO FARM : OFF",50)
local lobbyBtn = makeButton("TP LOBBY",100)
local gameBtn  = makeButton("TP GAME AREA",150)
local iyBtn    = makeButton("INFINITE YIELD",200)

autoBtn.MouseButton1Click:Connect(function()
    AutoFarm = not AutoFarm
    autoBtn.Text = AutoFarm and "AUTO FARM : ON" or "AUTO FARM : OFF"
    if AutoFarm and hrp then hrp.CFrame = AutoFarmCFrame end
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

--================ TOGGLE ==================
local visible = true
UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightControl then
        visible = not visible
        main.Visible = visible
    end
end)

--=========== NOTIFICATION ===========
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local lp = Players.LocalPlayer

-- ambil avatar local player (lebih aman)
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content = Players:GetUserThumbnailAsync(
    lp.UserId,
    thumbType,
    thumbSize
)

local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Icon = content,
            Duration = 5
        })
    end)
end

-- delay dikit biar ga error
task.wait(1)

Notify("AUTO FARM GOD MODE", "Loaded Successfully")
task.wait(0.3)
Notify("Credits", "Original Scriptblox")
task.wait(0.3)
Notify("Credits", "Edited by Zaluli")


print("AUTO FARM GOD MODE FINAL | Smooth Jump | Safe AFK")
