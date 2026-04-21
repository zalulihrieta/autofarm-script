local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Zaluli Multi-Hack (Chams + Aimbot)", "DarkScene")

-- Tab Utama
local MainTab = Window:NewTab("Combat & Visuals")
local VisualSection = MainTab:NewSection("ESP Settings")
local CombatSection = MainTab:NewSection("Aimbot Settings")

-- [ LOGIC ESP CHAMS ]
_G.ChamsEnabled = false
local chamsColor = Color3.fromRGB(0, 255, 150) -- Warna Hijau Cyan
local outlineColor = Color3.fromRGB(255, 255, 255)

local function applyChams(player)
    if player == game.Players.LocalPlayer then return end
    
    local function characterAdded(char)
        char:WaitForChild("HumanoidRootPart", 5)
        if _G.ChamsEnabled then
            if char:FindFirstChild("MyChams") then char.MyChams:Destroy() end
            local highlight = Instance.new("Highlight")
            highlight.Name = "MyChams"
            highlight.FillColor = chamsColor
            highlight.OutlineColor = outlineColor
            highlight.FillTransparency = 0.5
            highlight.Parent = char
        end
    end

    player.CharacterAdded:Connect(characterAdded)
    if player.Character then characterAdded(player.Character) end
end

-- Toggle ESP (Switch Kiri/Kanan)
VisualSection:NewToggle("Enable ESP Chams", "Lihat pemain tembus dinding", function(state)
    _G.ChamsEnabled = state
    if state then
        for _, p in pairs(game.Players:GetPlayers()) do applyChams(p) end
    else
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("MyChams") then
                p.Character.MyChams:Destroy()
            end
        end
    end
end)

-- Auto-apply untuk pemain baru
game.Players.PlayerAdded:Connect(applyChams)

-- [ LOGIC AIMBOT ]
CombatSection:NewButton("Load Equinox Aimbot", "Menjalankan script Aimbot eksternal", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Xxtan31/Equinox-Hub/main/aimbot.lua", true))()
end)

-- Setting Tambahan
local SettingTab = Window:NewTab("Settings")
local ConfigSection = SettingTab:NewSection("Menu Config")

ConfigSection:NewKeybind("Toggle Menu UI", "Tombol untuk buka/tutup menu", Enum.KeyCode.RightControl, function()
    Library:ToggleUI()
end)

ConfigSection:NewButton("Destroy UI", "Menghapus menu dari layar", function()
    game:GetService("CoreGui"):FindFirstChild("ESP Chams Auto-Update"):Destroy()
end)
