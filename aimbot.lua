local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Konfigurasi
local Settings = {
    Aimbot = false,
    Chams = false,
    InfJump = false,
    FOV = 150,
    Smoothing = 0.8,
    TargetPart = "Head"
}

-- FOV Drawing
local Circle = Drawing.new("Circle")
Circle.Color = Color3.fromRGB(0, 255, 0)
Circle.Thickness = 1
Circle.Visible = true

-- --- FUNGSI CORE ---

-- 1. FPS Booster (Texture Remover)
local function BoostFPS()
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0
    end
    settings().Rendering.QualityLevel = 1
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
end

-- 2. Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- 3. Visible Check
local function IsVisible(part)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local res = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, params)
    return res == nil or res.Instance:IsDescendantOf(part.Parent)
end

-- 4. Target Picker
local function GetTarget()
    local target, dist = nil, Settings.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.TargetPart) then
            local part = p.Character[Settings.TargetPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if mag < dist and IsVisible(part) then
                    target = part
                    dist = mag
                end
            end
        end
    end
    return target
end

-- --- MAIN LOOP (Render Priority) ---
RunService:BindToRenderStep("MainLoop", Enum.RenderPriority.Camera.Value + 1, function()
    Circle.Position = UserInputService:GetMouseLocation()
    Circle.Radius = Settings.FOV
    
    if Settings.Aimbot then
        local t = GetTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), Settings.Smoothing)
        end
    end

    if Settings.Chams then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("Highlight") then
                local h = Instance.new("Highlight", p.Character)
                h.FillColor = Color3.fromRGB(255, 0, 0)
            elseif p.Character and p.Character:FindFirstChild("Highlight") then
                p.Character.Highlight.Enabled = Settings.Chams
            end
        end
    end
end)

-- --- GUI ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 260)
Main.Position = UDim2.new(0.1, 0, 0.1, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "GEMINI HUB | R-CTRL"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1

local function CreateBtn(name, y, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.Text = name
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
end

-- Buttons
CreateBtn("AIMBOT: OFF", 40, function(b)
    Settings.Aimbot = not Settings.Aimbot
    b.Text = "AIMBOT: " .. (Settings.Aimbot and "ON" or "OFF")
    b.BackgroundColor3 = Settings.Aimbot and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(45, 45, 45)
end)

CreateBtn("CHAMS: OFF", 85, function(b)
    Settings.Chams = not Settings.Chams
    b.Text = "CHAMS: " .. (Settings.Chams and "ON" or "OFF")
    b.BackgroundColor3 = Settings.Chams and Color3.fromRGB(100, 0, 0) or Color3.fromRGB(45, 45, 45)
end)

CreateBtn("INF JUMP: OFF", 130, function(b)
    Settings.InfJump = not Settings.InfJump
    b.Text = "INF JUMP: " .. (Settings.InfJump and "ON" or "OFF")
end)

CreateBtn("FPS BOOST (ONCE)", 175, function(b)
    BoostFPS()
    b.Text = "FPS BOOSTED!"
    b.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
end)

CreateBtn("ADJUST FOV: " .. Settings.FOV, 220, function(b)
    Settings.FOV = Settings.FOV + 50
    if Settings.FOV > 300 then Settings.FOV = 50 end
    b.Text = "ADJUST FOV: " .. Settings.FOV
end)

-- Minimize Logic
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)
