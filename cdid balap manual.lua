--[[
    Simple GUI for CDID Event Tools
    Features: TP NPC & Map Optimization
    Toggle/Minimize: PC (RightControl) & Android (Button)
]]

local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- UI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Zaluli_Hrieta_Tools"
ScreenGui.Parent = game:CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "CDID EVENT TOOLS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
ScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollingFrame

-- Android Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 50, 0, 50)
MinBtn.Position = UDim2.new(0, 10, 0, 10)
MinBtn.Text = "Toggle"
MinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
MinBtn.TextColor3 = Color3.white
MinBtn.Visible = (UserInputService.TouchEnabled)
MinBtn.Parent = ScreenGui

local UICornerMin = Instance.new("UICorner")
UICornerMin.CornerRadius = UDim.new(1, 0)
UICornerMin.Parent = MinBtn

-- Functions
local function teleport(cframe)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        -- Menggunakan TweenService agar lebih smooth (mencegah deteksi instan)
        local tween = TweenService:Create(char.HumanoidRootPart, TweenInfo.new(1), {CFrame = cframe})
        tween:Play()
    end
end

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.white
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = ScrollingFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
end

-- SECTION: TELEPORT NPC
createButton("TP DA0ZA", function()
    teleport(CFrame.new(-7.834, 13.018, 441.855)) -- Offset Y +10 untuk mencegah clipping
end)

createButton("TP PengemudiIndonesia", function()
    teleport(CFrame.new(12.829, 13.233, 305.551))
end)

createButton("TP KeyMaster", function()
    teleport(CFrame.new(-3218.911, -69.969, -25389.085))
end)

-- SECTION: DELETE / OPTIMIZATION
createButton("Delete Traffic", function()
    if workspace:FindFirstChild("NPCVehicle") then workspace.NPCVehicle:Destroy() end
end)

createButton("Delete Mobil Bahu Jalan", function()
    if workspace.Map:FindFirstChild("Vehicles") then
        workspace.Map.Vehicles:Destroy()
    end
end)

createButton("Delete Hewan", function()
    local targets = {"Cat", "Domba", "Gajah", "gajaah"}
    for _, name in pairs(targets) do
        if workspace:FindFirstChild(name) then workspace[name]:Destroy() end
    end
    -- Menghapus objek berdasarkan index spesifik yang diminta
    local children = workspace:GetChildren()
    local indices = {34, 35, 36, 37}
    for _, idx in pairs(indices) do
        if children[idx] then children[idx]:Destroy() end
    end
end)

createButton("Delete Tree & Grass", function()
    if workspace:FindFirstChild("Tree") then
        if workspace.Tree:FindFirstChild("Asset Pohon") then workspace.Tree["Asset Pohon"]:Destroy() end
        if workspace.Tree:FindFirstChild("GrassPlants") then workspace.Tree.GrassPlants:Destroy() end
        workspace.Tree:Destroy()
    end
end)

createButton("Clean Props & Buildings", function()
    -- Menghapus folder props utama
    pcall(function()
        workspace.Map.Props:Destroy()
        workspace.Map.Buildings["Kota Tua"]:Destroy()
        workspace.Map.Buildings["Kota tua semarang"]:Destroy()
        workspace.Map.Buildings["Marba Semarang"]:Destroy()
    end)
end)

createButton("Delete Offroad (Heavy)", function()
    -- Melakukan iterasi pada model yang disebutkan untuk menghapus 'Offroad'
    local sumatra = workspace.Map:FindFirstChild("map liintas sumatra")
    if sumatra and sumatra:FindFirstChild("Model") then
        local models = sumatra.Model:GetChildren()
        for _, m in pairs(models) do
            if m:FindFirstChild("Offroad") then
                m.Offroad:Destroy()
            end
        end
    end
end)

-- Toggle Logic
local visible = true
local function toggleUI()
    visible = not visible
    MainFrame.Visible = visible
end

MinBtn.MouseButton1Click:Connect(toggleUI)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        toggleUI()
    end
end)

print("Script Loaded - Use RightControl (PC) or Toggle Button (Android)")
