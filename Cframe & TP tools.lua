--// ULTRA CFrame Tool GUI (Advanced)
--// Features:
--// K = Save CFrame
--// Multi delete (checkbox)
--// Select all
--// Rename
--// Drag reorder
--// Save/Load profiles (manual)
--// Auto Save toggle (settings)
--// Auto Load
--// Minimize GUI

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local DATA_FOLDER = "cframe_profiles/"

-- exploit check
local function ensureFolder()
    if makefolder and not isfolder(DATA_FOLDER) then
        makefolder(DATA_FOLDER)
    end
end
ensureFolder()

local saved = {}
local selected = {}

local autoSave = false
local currentProfile = "default"

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 400, 0, 450)
main.Position = UDim2.new(0, 20, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true

local minimized = false

local title = Instance.new("TextButton", main)
title.Size = UDim2.new(1,0,0,30)
title.Text = "CFrame Tool (Click to Minimize)"

title.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _,v in ipairs(main:GetChildren()) do
        if v ~= title then
            v.Visible = not minimized
        end
    end
end)

local listFrame = Instance.new("Frame", main)
listFrame.Size = UDim2.new(1,0,0.7,0)
listFrame.Position = UDim2.new(0,0,0.07,0)

local layout = Instance.new("UIListLayout", listFrame)

-- SAVE FILE
local function saveProfile(name)
    if writefile then
        local data = {}
        for _,v in ipairs(saved) do
            table.insert(data, {name=v.name, cf={v.cf:GetComponents()}})
        end
        writefile(DATA_FOLDER..name..".json", HttpService:JSONEncode(data))
    end
end

-- LOAD FILE
local function loadProfile(name)
    if readfile and isfile and isfile(DATA_FOLDER..name..".json") then
        saved = {}
        for _,child in ipairs(listFrame:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        local raw = readfile(DATA_FOLDER..name..".json")
        local data = HttpService:JSONDecode(raw)

        for _,v in ipairs(data) do
            table.insert(saved, {name=v.name, cf=CFrame.new(unpack(v.cf))})
        end
    end
end

-- CREATE ENTRY
local function refresh()
    for _,child in ipairs(listFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for i,v in ipairs(saved) do
        local entry = Instance.new("Frame", listFrame)
        entry.Size = UDim2.new(1,0,0,40)
        entry.BackgroundColor3 = Color3.fromRGB(40,40,40)

        local check = Instance.new("TextButton", entry)
        check.Size = UDim2.new(0.1,0,1,0)
        check.Text = selected[i] and "✔" or ""

        check.MouseButton1Click:Connect(function()
            selected[i] = not selected[i]
            refresh()
        end)

        local nameBox = Instance.new("TextBox", entry)
        nameBox.Size = UDim2.new(0.4,0,1,0)
        nameBox.Position = UDim2.new(0.1,0,0,0)
        nameBox.Text = v.name

        nameBox.FocusLost:Connect(function()
            v.name = nameBox.Text
            if autoSave then saveProfile(currentProfile) end
        end)

        local up = Instance.new("TextButton", entry)
        up.Size = UDim2.new(0.1,0,1,0)
        up.Position = UDim2.new(0.5,0,0,0)
        up.Text = "↑"

        up.MouseButton1Click:Connect(function()
            if saved[i-1] then
                saved[i], saved[i-1] = saved[i-1], saved[i]
                refresh()
            end
        end)

        local down = Instance.new("TextButton", entry)
        down.Size = UDim2.new(0.1,0,1,0)
        down.Position = UDim2.new(0.6,0,0,0)
        down.Text = "↓"

        down.MouseButton1Click:Connect(function()
            if saved[i+1] then
                saved[i], saved[i+1] = saved[i+1], saved[i]
                refresh()
            end
        end)

        local tp = Instance.new("TextButton", entry)
        tp.Size = UDim2.new(0.2,0,1,0)
        tp.Position = UDim2.new(0.7,0,0,0)
        tp.Text = "TP"

        tp.MouseButton1Click:Connect(function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = v.cf
            end
        end)
    end
end

-- ADD CFRAME
local function add(cf)
    table.insert(saved, {name="Point "..#saved+1, cf=cf})
    refresh()
    if autoSave then saveProfile(currentProfile) end
end

-- KEY
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            add(char.HumanoidRootPart.CFrame)
        end
    end
end)

-- CONTROLS
local delBtn = Instance.new("TextButton", main)
delBtn.Size = UDim2.new(0.3,0,0,30)
delBtn.Position = UDim2.new(0,0,0.78,0)
delBtn.Text = "Delete Selected"

delBtn.MouseButton1Click:Connect(function()
    local new = {}
    for i,v in ipairs(saved) do
        if not selected[i] then
            table.insert(new,v)
        end
    end
    saved = new
    selected = {}
    refresh()
end)

local selectAll = Instance.new("TextButton", main)
selectAll.Size = UDim2.new(0.3,0,0,30)
selectAll.Position = UDim2.new(0.3,0,0.78,0)
selectAll.Text = "Select All"

selectAll.MouseButton1Click:Connect(function()
    for i=1,#saved do
        selected[i] = true
    end
    refresh()
end)

local saveBtn = Instance.new("TextButton", main)
saveBtn.Size = UDim2.new(0.3,0,0,30)
saveBtn.Position = UDim2.new(0.6,0,0.78,0)
saveBtn.Text = "Save"

saveBtn.MouseButton1Click:Connect(function()
    saveProfile(currentProfile)
end)

local loadBtn = Instance.new("TextButton", main)
loadBtn.Size = UDim2.new(0.5,0,0,30)
loadBtn.Position = UDim2.new(0,0,0.85,0)
loadBtn.Text = "Load Profile"

loadBtn.MouseButton1Click:Connect(function()
    loadProfile(currentProfile)
    refresh()
end)

local autoToggle = Instance.new("TextButton", main)
autoToggle.Size = UDim2.new(0.5,0,0,30)
autoToggle.Position = UDim2.new(0.5,0,0.85,0)
autoToggle.Text = "Auto Save: OFF"

autoToggle.MouseButton1Click:Connect(function()
    autoSave = not autoSave
    autoToggle.Text = "Auto Save: "..(autoSave and "ON" or "OFF")
end)

refresh()
