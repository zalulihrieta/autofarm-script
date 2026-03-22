repeat task.wait() until game:IsLoaded()

local CoreGui = game:GetService("CoreGui")

pcall(function()
    CoreGui:FindFirstChild("CFrameToolUI"):Destroy()
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CFrameToolUI"
gui.Parent = CoreGui

-- MAIN
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 420, 0, 300)
main.Position = UDim2.new(0.5, -210, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.Active = true
main.Draggable = true

-- HEADER
local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1,0,0,40)
header.Text = "CFrame & TP Tools"
header.BackgroundColor3 = Color3.fromRGB(20,20,20)
header.TextColor3 = Color3.new(1,1,1)
header.TextSize = 18

-- TAB BAR
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1,0,0,35)
tabBar.Position = UDim2.new(0,0,0,40)
tabBar.BackgroundColor3 = Color3.fromRGB(25,25,25)

-- TAB CONTENT HOLDER
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,0,1,-75)
content.Position = UDim2.new(0,0,0,75)
content.BackgroundColor3 = Color3.fromRGB(35,35,35)

-- CREATE TAB FUNCTION
local tabs = {}

local function createTab(name, pos)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0.33,0,1,0)
    btn.Position = UDim2.new(pos,0,0,0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)

    local page = Instance.new("Frame", content)
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false
    page.BackgroundTransparency = 1

    tabs[name] = page

    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(tabs) do
            v.Visible = false
        end
        page.Visible = true
    end)

    return page
end

-- CREATE TABS
local cframePage = createTab("CFrame", 0)
local tpPage = createTab("Teleport", 0.33)
local settingPage = createTab("Setting", 0.66)

-- DEFAULT OPEN
tabs["CFrame"].Visible = true

-- SAMPLE TEXT BIAR KELIATAN
local function label(parent, text)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1,0,0,30)
    l.Text = text
    l.TextColor3 = Color3.new(1,1,1)
    l.BackgroundTransparency = 1
end

label(cframePage, "CFrame Menu")
label(tpPage, "Teleport Menu")
label(settingPage, "Setting Menu")

-- MINIMIZE TOGGLE (RIGHT CTRL)
local UIS = game:GetService("UserInputService")

local visible = true

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Enum.KeyCode.RightControl then
        visible = not visible
        main.Visible = visible
    end
end)

--cframe page--

--scroll list--
local scroll = Instance.new("ScrollingFrame", cframePage)
scroll.Size = UDim2.new(1,0,1,0)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,5)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

local savedCFrames = {}

local function createEntry(index, cf)
    local frame = Instance.new("Frame", scroll)
    frame.Size = UDim2.new(1,-10,0,40)
    frame.BackgroundColor3 = Color3.fromRGB(45,45,45)

    local text = Instance.new("TextLabel", frame)
    text.Size = UDim2.new(0.5,0,1,0)
    text.Text = tostring(cf)
    text.TextScaled = true
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1,1,1)

    -- COPY
    local copy = Instance.new("TextButton", frame)
    copy.Size = UDim2.new(0.15,0,1,0)
    copy.Position = UDim2.new(0.5,0,0,0)
    copy.Text = "COPY"

    copy.MouseButton1Click:Connect(function()
        setclipboard(tostring(cf))
    end)

    -- TP
    local tp = Instance.new("TextButton", frame)
    tp.Size = UDim2.new(0.15,0,1,0)
    tp.Position = UDim2.new(0.65,0,0,0)
    tp.Text = "TP"

    tp.MouseButton1Click:Connect(function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = cf
        end
    end)

    -- DELETE
    local del = Instance.new("TextButton", frame)
    del.Size = UDim2.new(0.2,0,1,0)
    del.Position = UDim2.new(0.8,0,0,0)
    del.Text = "DEL"

   del.MouseButton1Click:Connect(function()
    for i,v in ipairs(savedCFrames) do
        if v == cf then
            table.remove(savedCFrames, i)
            break
        end
    end
    frame:Destroy()
end)

local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Enum.KeyCode.K then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local cf = char.HumanoidRootPart.CFrame
            table.insert(savedCFrames, cf)

            createEntry(#savedCFrames, cf)
        end
    end
end)

