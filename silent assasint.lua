local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("ESP Chams Auto-Update", "DarkScene")

local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("Visuals")

-- State Global
_G.ChamsEnabled = false
local chamsColor = Color3.fromRGB(255, 0, 100) -- Warna Pink/Merah Terang
local outlineColor = Color3.fromRGB(255, 255, 255) -- Outline Putih

-- Fungsi Utama Create Chams
local function createChams(player)
    if player == game.Players.LocalPlayer then return end
    
    local function apply(character)
        if not character then return end
        -- Tunggu sebentar agar model karakter terload sempurna
        character:WaitForChild("HumanoidRootPart", 5)
        
        -- Hapus chams lama jika ada agar tidak double
        if character:FindFirstChild("MyChams") then
            character.MyChams:Destroy()
        end

        if _G.ChamsEnabled then
            local highlight = Instance.new("Highlight")
            highlight.Name = "MyChams"
            highlight.FillColor = chamsColor
            highlight.OutlineColor = outlineColor
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Adornee = character
            highlight.Parent = character
        end
    end

    -- Jalankan saat karakter muncul
    player.CharacterAdded:Connect(apply)
    
    -- Jalankan jika karakter sudah ada di game
    if player.Character then
        apply(player.Character)
    end
end

-- Toggle UI (Kiri/Kanan)
Section:NewToggle("ESP Chams", "Otomatis apply ke pemain baru & respawn", function(state)
    _G.ChamsEnabled = state
    
    if _G.ChamsEnabled then
        -- Berikan chams ke semua orang yang sudah ada di server
        for _, player in pairs(game.Players:GetPlayers()) do
            createChams(player)
        end
    else
        -- Hapus semua chams saat toggle dimatikan
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("MyChams") then
                player.Character.MyChams:Destroy()
            end
        end
    end
end)

-- AUTO APPLY: Deteksi Pemain Baru Join
game.Players.PlayerAdded:Connect(function(newPlayer)
    -- Jika toggle sedang ON, langsung pasang fungsi chams ke player baru
    createChams(newPlayer)
end)

Section:NewKeybind("Minimize UI", "Tombol Right Control", Enum.KeyCode.RightControl, function()
	Library:ToggleUI()
end)
