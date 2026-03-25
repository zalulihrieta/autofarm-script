local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- === [ 1. ANTI-DOUBLE SYSTEM ] ===
-- Bagian ini bakal hapus script lama sebelum jalanin yang baru
local oldUI = player.PlayerGui:FindFirstChild("CDID_FINAL_ULTIMATE")
if oldUI then 
    oldUI:Destroy() 
    print("Script lama dihapus, menjalankan versi terbaru...")
end

-- DATA KOORDINAT
local DA0ZA_POS = Vector3.new(-7.834, 3.018, 441.855)
local CP_LIST = {
    Vector3.new(125.047, 18.23, -415.17), Vector3.new(127.56, 18.23, -1272.89),
    Vector3.new(-175.22, 9.89, -2039.38), Vector3.new(-1010.84, 10.85, -2169.61),
    Vector3.new(-1857.36, 0.70, -2229.30), Vector3.new(-2649.20, -14.20, -2553.57),
    Vector3.new(-3327.87, -23.30, -3053.10), Vector3.new(-2962.86, -17.16, -3810.04),
    Vector3.new(-2546.48, -17.12, -4562.12), Vector3.new(-2130.46, -29.62, -5311.78),
    Vector3.new(-1700.40, -25.40, -6054.65), Vector3.new(-1254.41, -61.60, -6785.94),
    Vector3.new(-940.44, -43.98, -7579.50), Vector3.new(-1479.28, -39.61, -8167.92),
    Vector3.new(-2229.66, -41.48, -8583.87), Vector3.new(-2952.90, -33.53, -9039.44),
    Vector3.new(-3522.56, -29.65, -9674.15), Vector3.new(-3933.81, -13.60, -10423.11),
    Vector3.new(-3813.76, -12.94, -11209.53), Vector3.new(-3271.03, -72.94, -11870.83),
    Vector3.new(-2767.28, -55.45, -12562.34), Vector3.new(-2530.25, -27.70, -13351.72),
    Vector3.new(-2810.24, -23.90, -14163.19), Vector3.new(-3094.18, -21.09, -14972.98),
    Vector3.new(-3364.90, -33.04, -15785.45), Vector3.new(-3503.13, -19.98, -16630.31),
    Vector3.new(-3555.15, -61.72, -17485.58), Vector3.new(-3575.71, -73.81, -18341.17),
    Vector3.new(-3561.62, -48.36, -19198.78), Vector3.new(-3540.58, -60.50, -20055.28),
    Vector3.new(-3435.47, -80.04, -20905.47), Vector3.new(-3291.04, -35.81, -21748.63),
    Vector3.new(-3142.45, -62.21, -22593.58), Vector3.new(-3129.45, -64.56, -23452.41),
    Vector3.new(-3131.28, -64.56, -24310.80), Vector3.new(-3131.40, -64.87, -25169.21),
    Vector3.new(-3131.31, -47.54, -26026.86), Vector3.new(-3129.58, -64.56, -26883.44),
    Vector3.new(-3129.03, -64.56, -27743.27)
}

local autoRacing = false
local SPAM_TIME = 5 -- [[ EDIT DI SINI: Detik tiap CP ]]

-- UI SETUP
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "CDID_FINAL_ULTIMATE"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 220, 0, 180); main.Position = UDim2.new(0.5, -110, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.Active = true; main.Draggable = true

local top = Instance.new("TextLabel", main)
top.Size = UDim2.new(1, 0, 0, 30); top.Text = "AUTO RACE V14"; top.BackgroundColor3 = Color3.fromRGB(120, 0, 0); top.TextColor3 = Color3.new(1, 1, 1)

-- FUNGSI TP
local function spamTP(pos, duration)
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local moveTarget = char:FindFirstChild("HumanoidRootPart")
    
    if hum and hum.SeatPart then 
        moveTarget = hum.SeatPart 
    end

    if moveTarget then
        local start = tick()
        -- Loop Milidetik
        while tick() - start < duration and autoRacing do
            if not char.Parent then break end -- Berhenti kalau mati
            moveTarget.CFrame = CFrame.new(pos + Vector3.new(0, 3.5, 0))
            moveTarget.AssemblyLinearVelocity = Vector3.zero
            moveTarget.AssemblyAngularVelocity = Vector3.zero
            task.wait() 
        end
    end
end

-- BUTTONS
local npcBtn = Instance.new("TextButton", main)
npcBtn.Size = UDim2.new(1, -20, 0, 35); npcBtn.Position = UDim2.new(0, 10, 0, 40)
npcBtn.Text = "NPC DA0ZA"; npcBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 0); npcBtn.TextColor3 = Color3.new(1,1,1)
npcBtn.MouseButton1Click:Connect(function() 
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(DA0ZA_POS + Vector3.new(0, 5, 0))
    end
end)

local startBtn = Instance.new("TextButton", main)
startBtn.Size = UDim2.new(1, -20, 0, 35); startBtn.Position = UDim2.new(0, 10, 0, 85)
startBtn.Text = "START AUTO"; startBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 150); startBtn.TextColor3 = Color3.new(1,1,1)

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1, 0, 0, 30); status.Position = UDim2.new(0, 0, 0, 130); status.Text = "Ready"; status.TextColor3 = Color3.new(1,1,1); status.BackgroundTransparency = 1

startBtn.MouseButton1Click:Connect(function()
    autoRacing = not autoRacing
    startBtn.Text = autoRacing and "STOP" or "START"
    startBtn.BackgroundColor3 = autoRacing and Color3.fromRGB(150,0,0) or Color3.fromRGB(0, 50, 150)
end)

-- LOOP UTAMA
task.spawn(function()
    while true do
        if autoRacing then
            for i = 1, #CP_LIST do
                if not autoRacing then break end
                status.Text = "Progress: " .. i .. "/" .. #CP_LIST
                
                -- Jalankan Spam
                spamTP(CP_LIST[i], SPAM_TIME)
                
                -- Cek apa karakter masih hidup
                if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health <= 0 then
                    autoRacing = false
                    status.Text = "DEAD - STOPPED"
                    break
                end
                
                task.wait(0.2) -- Jeda pindah
            end
            autoRacing = false
        end
        task.wait(0.5)
    end
end)

-- MINIMIZE
local vis = true
local min = Instance.new("TextButton", main)
min.Size = UDim2.new(0, 30, 0, 30); min.Position = UDim2.new(1, -30, 0, 0); min.Text = "_"; min.BackgroundColor3 = Color3.fromRGB(80,0,0); min.TextColor3 = Color3.new(1,1,1)
min.MouseButton1Click:Connect(function()
    vis = not vis
    npcBtn.Visible = vis; startBtn.Visible = vis; status.Visible = vis
    main.Size = vis and UDim2.new(0, 220, 0, 180) or UDim2.new(0, 220, 0, 30)
end)
UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.RightControl then min:Click() end end)
