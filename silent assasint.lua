-- [[ UNIVERSAL GUI EXECUTOR BY GEMINI ]] --

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("GEMINI HUB - UNIVERSAL", "DarkTheme")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Variables & Default Settings
_G.Settings = {
    Charms = false,
    KillAura = false,
    AuraRange = 15,
    ShowAuraArea = false,
    WalkSpeed = 16,
    Fly = false,
    FlySpeed = 50
}

-- [[ MAIN TABS ]]
local Main = Window:NewTab("Main")
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local SectionMain = Main:NewSection("Movement")
local SectionCombat = Combat:NewSection("Kill Aura")
local SectionVisuals = Visuals:NewSection("ESP & Effects")

-- [[ MOVEMENT CONTROLS ]]
SectionMain:NewSlider("WalkSpeed", "Atur kecepatan lari", 100, 16, function(s)
    _G.Settings.WalkSpeed = s
end)

SectionMain:NewToggle("Fly", "Terbang kayak burung", function(state)
    _G.Settings.Fly = state
end)

SectionMain:NewSlider("Fly Speed", "Kecepatan terbang", 200, 50, function(s)
    _G.Settings.FlySpeed = s
end)

-- [[ COMBAT CONTROLS ]]
SectionCombat:NewToggle("Kill Aura", "Otomatis hit musuh di sekitar", function(state)
    _G.Settings.KillAura = state
end)

SectionCombat:NewSlider("Aura Range", "Jarak jangkauan hit", 50, 5, function(s)
    _G.Settings.AuraRange = s
end)

SectionCombat:NewToggle("Show Aura Area", "Lihat lingkaran jangkauan", function(state)
    _G.Settings.ShowAuraArea = state
end)

-- [[ VISUAL CONTROLS ]]
SectionVisuals:NewToggle("Charms / ESP", "Tembus pandang liat musuh", function(state)
    _G.Settings.Charms = state
end)

-- [[ BEHIND THE SCENES LOGIC ]]

-- Visual Ring Setup
local VisualRing = Instance.new("Part")
VisualRing.Shape = Enum.PartType.Cylinder
VisualRing.Anchored = true
VisualRing.CanCollide = false
VisualRing.Transparency = 0.8
VisualRing.Color = Color3.fromRGB(255, 0, 0)

-- BodyVelocity for Fly
local BodyVel = Instance.new("BodyVelocity")

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- WalkSpeed Update
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = _G.Settings.WalkSpeed
    end

    -- Fly Logic
    if _G.Settings.Fly and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        BodyVel.Parent = LocalPlayer.Character.HumanoidRootPart
        BodyVel.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.Settings.FlySpeed
    else
        BodyVel.Parent = nil
    end

    -- Visual Aura Logic
    if _G.Settings.ShowAuraArea and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        VisualRing.Parent = workspace
        VisualRing.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, math.rad(90))
        VisualRing.Size = Vector3.new(0.1, _G.Settings.AuraRange * 2, _G.Settings.AuraRange * 2)
    else
        VisualRing.Parent = nil
    end

    -- Kill Aura Logic
    if _G.Settings.KillAura then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist <= _G.Settings.AuraRange then
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                        -- Universal Damage Trigger
                        pcall(function()
                            firetouchinterest(p.Character:FindFirstChild("Head"), tool.Handle, 0)
                            firetouchinterest(p.Character:FindFirstChild("Head"), tool.Handle, 1)
                        end)
                    end
                end
            end
        end
    end

    -- Charms Update
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if _G.Settings.Charms then
                if not p.Character:FindFirstChild("Glow") then
                    local hl = Instance.new("Highlight", p.Character)
                    hl.Name = "Glow"
                    hl.FillColor = Color3.fromRGB(255, 0, 255)
                end
            else
                if p.Character:FindFirstChild("Glow") then p.Character.Glow:Destroy() end
            end
        end
    end
end)

print("GUI Loaded! Enjoy Cheating Responsibly.")
