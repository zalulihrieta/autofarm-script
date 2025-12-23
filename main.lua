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

-- ====== STATE ======
local AutoFarm = false
local lastTP = 0
local character, hrp

-- ====== ANTI AFK ======
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- ====== CHARACTER HANDLER ======
local function onCharacter(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart", 5)
    task.wait()
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then onCharacter(player.Character) end

-- GHOST MODE + ANTI SUPER RING + ANTI ADMIN FLING
local function clearForces(char)
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BodyVelocity")
        or v:IsA("BodyAngularVelocity")
        or v:IsA("BodyForce")
        or v:IsA("BodyGyro")
        or v:IsA("BodyPosition")
        or v:IsA("LinearVelocity")
        or v:IsA("AngularVelocity")
        or v:IsA("VectorForce")
        or v:IsA("AlignPosition")
        or v:IsA("AlignOrientation") then
            v:Destroy()
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not character or not hrp then return end

    -- GHOST MODE TOTAL
    for _,v in ipairs(character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
            v.Massless = true
        end
    end
    
    -- admin / ring force cleaner
    clearForces(character)

-- AUTO FARM + ANTI FALL
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
end)

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,240,0,245)
frame.Position = UDim2.new(0.05,0,0.35,0)
frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "AUTO FARM"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)

local function btn(txt,y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-20,0,35)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BackgroundColor3 = Color3.fromRGB(55,55,55)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local autoBtn = btn("AUTO FARM : OFF",40)
local lobbyBtn = btn("TP LOBBY",85)
local gameBtn = btn("TP GAME AREA",130)
local iyBtn = btn("INFINITE YIELD",175)

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

-- MOBILE + PC TOGGLE
local guiVisible = true

local mobileBtn = Instance.new("TextButton", gui)
mobileBtn.Size = UDim2.new(0,50,0,50)
mobileBtn.Position = UDim2.new(0,10,0.6,0)
mobileBtn.Text = "≡"
mobileBtn.TextSize = 24
mobileBtn.Font = Enum.Font.GothamBold
mobileBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
mobileBtn.TextColor3 = Color3.new(1,1,1)
mobileBtn.Active = true
mobileBtn.Draggable = true
Instance.new("UICorner", mobileBtn).CornerRadius = UDim.new(1,0)

mobileBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    frame.Visible = guiVisible
end)

UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightControl then
        guiVisible = not guiVisible
        frame.Visible = guiVisible
    end
end)

-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get UserId safely
local userId
pcall(function()
    userId = Players:GetUserIdFromNameAsync("zaluli_hrieta")
end)

-- Thumbnail
local content = ""
if userId then
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    content = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
end

-- Notifications
local function Notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Icon = content,
        Duration = 5
    })
end

Notify("AUTO FARM", "Loaded Successfully")
task.wait(0.3)
Notify("Credits", "Original by zaluli Scriptblox")

-- Chat Message
local function SendChatMessage(msg)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            channel:SendAsync(msg)
        end
    else
        ReplicatedStorage
            :WaitForChild("DefaultChatSystemChatEvents")
            :WaitForChild("SayMessageRequest")
            :FireServer(msg, "All")
    end
end

SendChatMessage("Halah Nyocot")


print("AUTO FARM GOD MODE | Anti Admin Fling | By Zaluli_Hrieta")
