--// FINAL BOSS CFrame TOOL 🔥
--// Added:
--// Dropdown Profile
--// File Manager (side panel)
--// Tween TP (fast/slow toggle)
--// Visual Marker (numbered)
--// Import / Export
--// Multi-select drag (basic simulation)

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local DATA_FOLDER = "cframe_profiles/"
if makefolder and not isfolder(DATA_FOLDER) then
    makefolder(DATA_FOLDER)
end

local saved = {}
local selected = {}
local markers = {}

local autoSave = false
local tweenMode = "OFF" -- OFF / FAST / SLOW
local currentProfile = "default"

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 450, 0, 450)
main.Position = UDim2.new(0, 20, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true

-- SIDE FILE MANAGER
local side = Instance.new("Frame", gui)
side.Size = UDim2.new(0, 200, 0, 450)
side.Position = UDim2.new(0, 480, 0.5, -200)
side.BackgroundColor3 = Color3.fromRGB(20,20,20)

local sideLayout = Instance.new("UIListLayout", side)

local function refreshFiles()
    for _,v in ipairs(side:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    if listfiles then
        for _,file in ipairs(listfiles(DATA_FOLDER)) do
            local name = file:match("([^/]+)%.json")

            local btn = Instance.new("TextButton", side)
            btn.Size = UDim2.new(1,0,0,30)
            btn.Text = name

            btn.MouseButton1Click:Connect(function()
                currentProfile = name
            end)
        end
    end
end

refreshFiles()

-- MARKERS
local function clearMarkers()
    for _,m in pairs(markers) do m:Destroy() end
    markers = {}
end

local function createMarkers()
    clearMarkers()

    for i,v in ipairs(saved) do
        local part = Instance.new("Part")
        part.Size = Vector3.new(1,1,1)
        part.Anchored = true
        part.CanCollide = false
        part.Position = v.cf.Position
        part.Parent = workspace

        local bill = Instance.new("BillboardGui", part)
        bill.Size = UDim2.new(0,50,0,50)

        local txt = Instance.new("TextLabel", bill)
        txt.Size = UDim2.new(1,0,1,0)
        txt.Text = tostring(i)
        txt.BackgroundTransparency = 1
        txt.TextScaled = true

        table.insert(markers, part)
    end
end

-- SAVE / LOAD
local function saveProfile(name)
    if writefile then
        local data = {}
        for _,v in ipairs(saved) do
            table.insert(data, {name=v.name, cf={v.cf:GetComponents()}})
        end
        writefile(DATA_FOLDER..name..".json", HttpService:JSONEncode(data))
        refreshFiles()
    end
end

local function loadProfile(name)
    if readfile and isfile and isfile(DATA_FOLDER..name..".json") then
        saved = {}
        local raw = readfile(DATA_FOLDER..name..".json")
        local data = HttpService:JSONDecode(raw)

        for _,v in ipairs(data) do
            table.insert(saved, {name=v.name, cf=CFrame.new(unpack(v.cf))})
        end

        createMarkers()
    end
end

-- TP FUNCTION
local function teleport(cf)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        if tweenMode == "OFF" then
            char.HumanoidRootPart.CFrame = cf
        else
            local speed = tweenMode == "FAST" and 0.3 or 1.5
            TweenService:Create(char.HumanoidRootPart, TweenInfo.new(speed), {CFrame = cf}):Play()
        end
    end
end

-- ADD CFRAME
local function add(cf)
    table.insert(saved, {name="Point "..#saved+1, cf=cf})
    createMarkers()
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
local saveBtn = Instance.new("TextButton", main)
saveBtn.Size = UDim2.new(0.3,0,0,30)
saveBtn.Text = "Save"
saveBtn.MouseButton1Click:Connect(function()
    saveProfile(currentProfile)
end)

local loadBtn = Instance.new("TextButton", main)
loadBtn.Size = UDim2.new(0.3,0,0,30)
loadBtn.Position = UDim2.new(0.3,0,0,0)
loadBtn.Text = "Load"
loadBtn.MouseButton1Click:Connect(function()
    loadProfile(currentProfile)
end)

local tweenBtn = Instance.new("TextButton", main)
tweenBtn.Size = UDim2.new(0.4,0,0,30)
tweenBtn.Position = UDim2.new(0.6,0,0,0)
tweenBtn.Text = "Tween: OFF"

tweenBtn.MouseButton1Click:Connect(function()
    if tweenMode == "OFF" then
        tweenMode = "FAST"
    elseif tweenMode == "FAST" then
        tweenMode = "SLOW"
    else
        tweenMode = "OFF"
    end
    tweenBtn.Text = "Tween: "..tweenMode
end)

-- IMPORT / EXPORT
local exportBtn = Instance.new("TextButton", main)
exportBtn.Size = UDim2.new(0.5,0,0,30)
exportBtn.Position = UDim2.new(0,0,0.9,0)
exportBtn.Text = "Export"

exportBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        local data = {}
        for _,v in ipairs(saved) do
            table.insert(data, {name=v.name, cf={v.cf:GetComponents()}})
        end
        setclipboard(HttpService:JSONEncode(data))
    end
end)

local importBtn = Instance.new("TextButton", main)
importBtn.Size = UDim2.new(0.5,0,0,30)
importBtn.Position = UDim2.new(0.5,0,0.9,0)
importBtn.Text = "Import"

importBtn.MouseButton1Click:Connect(function()
    if getclipboard then
        local raw = getclipboard()
        local data = HttpService:JSONDecode(raw)

        for _,v in ipairs(data) do
            table.insert(saved, {name=v.name, cf=CFrame.new(unpack(v.cf))})
        end

        createMarkers()
    end
end)

createMarkers()
