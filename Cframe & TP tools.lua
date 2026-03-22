-- Tunggu sampai game load
repeat task.wait() until game:IsLoaded()

local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- KONFIGURASI
local offsetY = 10 
local tpSpeed = 2 -- Sesuai permintaanmu (2 detik)
local cframeCount = 0

-- Hapus GUI lama
pcall(function()
    if CoreGui:FindFirstChild("CFrameToolUI") then
        CoreGui.CFrameToolUI:Destroy()
    end
end)

-- GUI ROOT
local gui = Instance.new("ScreenGui")
gui.Name = "CFrameToolUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

-- MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 450, 0, 350)
main.Position = UDim2.new(0.5, -225, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.Active = true
main.Draggable = true

-- HEADER
local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.Text = "Vehicle TP Fixed | [K] Save | [R-Ctrl] Hide"
header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
header.TextColor3 = Color3.new(1, 1, 1)
header.TextSize = 16

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(1, -10, 1, -10)
scroll.Position = UDim2.new(0, 5, 0, 5)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

-- LOGIC TP KENDARAAN / KARAKTER (FIXED)
local function smoothTeleport(targetCF)
    local char = lp.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local finalCF = targetCF * CFrame.new(0, offsetY, 0)
    local targetObject = hrp

    -- Deteksi Kendaraan yang lebih akurat
    if hum and hum.SeatPart then
        -- GetRootPart akan mengambil part utama yang menggerakkan seluruh mobil
        targetObject = hum.SeatPart:GetRootPart() or hum.SeatPart
    end
    
    -- Eksekusi Tween
    local tweenInfo = TweenInfo.new(tpSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(targetObject, tweenInfo, {CFrame = finalCF})
    
    tween:Play()
end

-- FUNCTION CREATE ENTRY
local function createEntry(cf)
    cframeCount = cframeCount + 1
    local frame = Instance.new("Frame", scroll)
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.BorderSizePixel = 0

    local numLabel = Instance.new("TextLabel", frame)
    numLabel.Size = UDim2.new(0.1, 0, 1, 0)
    numLabel.Text = "[" .. cframeCount .. "]"
    numLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    numLabel.BackgroundTransparency = 1

    local text = Instance.new("TextLabel", frame)
    text.Size = UDim2.new(0.4, -5, 1, 0)
    text.Position = UDim2.new(0.1, 5, 0, 0)
    text.Text = string.format("X:%.1f Y:%.1f Z:%.1f", cf.X, cf.Y, cf.Z)
    text.TextScaled = true
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1, 1, 1)

    local tp = Instance.new("TextButton", frame)
    tp.Size = UDim2.new(0.2, 0, 0.7, 0)
    tp.Position = UDim2.new(0.55, 0, 0.15, 0)
    tp.Text = "SMOOTH TP"
    tp.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    tp.TextColor3 = Color3.new(1, 1, 1)
    tp.MouseButton1Click:Connect(function() smoothTeleport(cf) end)

    local del = Instance.new("TextButton", frame)
    del.Size = UDim2.new(0.2, 0, 0.7, 0)
    del.Position = UDim2.new(0.77, 0, 0.15, 0)
    del.Text = "DELETE"
    del.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    del.TextColor3 = Color3.new(1, 1, 1)
    del.MouseButton1Click:Connect(function() frame:Destroy() end)
end

-- KEYBINDS
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        local char = lp.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            createEntry(char.HumanoidRootPart.CFrame)
        end
    elseif input.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
    end
end)
