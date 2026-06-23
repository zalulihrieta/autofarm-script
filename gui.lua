-- ====================================================================
-- Script Name: Hrieta Hub (Sidebar Edition)
-- Author: Gemini (Optimized by Zaluli_Hrieta for Mobile)
-- Version: 2.6.0
-- Focus: Compact Sidebar Navigation for Android (Mayfield Style)
-- ====================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- 1. CLEAN UP PREVIOUS INSTANCES
local existingGui = CoreGui:FindFirstChild("HrietaHubMobile")
if existingGui then
    existingGui:Destroy()
end

-- 2. CREATE THE MAIN INTERFACE
local HrietaHub = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local MinimizeButton = Instance.new("TextButton")

-- Sidebar & Content Panels
local Sidebar = Instance.new("Frame")
local SidebarList = Instance.new("UIListLayout")
local ContentArea = Instance.new("Frame")

HrietaHub.Name = "HrietaHubMobile"
HrietaHub.Parent = CoreGui
HrietaHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 3. MAIN UTILITY FRAME (Ukuran tetap 300x250)
MainFrame.Name = "MainFrame"
MainFrame.Parent = HrietaHub
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.35 -- Semi-transparan tetap dipertahankan
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.Size = UDim2.new(0, 300, 0, 250) -- UKURAN TIDAK DIUBAH
MainFrame.ClipsDescendants = true
MainFrame.Active = true

-- TITLE BAR / DRAG HANDLE
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 35)

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Hrieta Hub" -- NAMA DIUBAH MENJADI HRIETA HUB
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14

MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TitleBar
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18

-- 4. SIDEBAR SETUP (Menu Sebelah Kiri)
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Sidebar.BackgroundTransparency = 0.5
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.Size = UDim2.new(0, 75, 1, -35)

SidebarList.Parent = Sidebar
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Padding = UDim.new(0, 4)

-- CONTENT AREA (Sisi Kanan untuk menampung halaman)
ContentArea.Name = "ContentArea"
ContentArea.Parent = MainFrame
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 80, 0, 40)
ContentArea.Size = UDim2.new(1, -85, 1, -45)

-- 5. MULTI-TAB ENGINE (FARM & SETTING PAGES)
local pages = {}
local tabButtons = {}

local function CreateTab(tabName, order)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName .. "TabBtn"
    TabButton.Parent = Sidebar
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TabButton.BackgroundTransparency = 0.2
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.Font = Enum.Font.GothamMedium
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabButton.TextSize = 12
    TabButton.LayoutOrder = order
    
    local Page = Instance.new("ScrollingFrame")
    Page.Name = tabName .. "Page"
    Page.Parent = ContentArea
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.CanvasSize = UDim2.new(0, 0, 0, 300)
    Page.ScrollBarThickness = 2
    Page.Visible = false
    
    local PageList = Instance.new("UIListLayout")
    PageList.Parent = Page
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Padding = UDim.new(0, 6)
    
    pages[tabName] = Page
    tabButtons[tabName] = TabButton
    
    TabButton.MouseButton1Click:Connect(function()
        for name, instance in pairs(pages) do
            instance.Visible = (name == tabName)
            if name == tabName then
                tabButtons[name].TextColor3 = Color3.fromRGB(255, 255, 255)
                tabButtons[name].BackgroundColor3 = Color3.fromRGB(35, 100, 250)
            else
                tabButtons[name].TextColor3 = Color3.fromRGB(180, 180, 180)
                tabButtons[name].BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            end
        end
    end)
    
    return Page
end

local FarmPage = CreateTab("Farm", 1)
local SettingPage = CreateTab("Setting", 2)

pages["Farm"].Visible = true
tabButtons["Farm"].TextColor3 = Color3.fromRGB(255, 255, 255)
tabButtons["Farm"].BackgroundColor3 = Color3.fromRGB(35, 100, 250)


-- 6. DRAG FUNCTIONALITY (Mobile & PC Touch Responsive)
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)


-- 7. MINIMIZE SYSTEM TO "AUTO FARM"
local minimized = false
local originalSize = MainFrame.Size

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 150, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        task.wait(0.1)
        Sidebar.Visible = false
        ContentArea.Visible = false
        TitleLabel.Text = "Auto Farm" -- Tetap menjadi "Auto Farm" saat dikecilkan
        MinimizeButton.Text = "+"
    else
        MainFrame:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        Sidebar.Visible = true
        ContentArea.Visible = true
        TitleLabel.Text = "Hrieta Hub" -- Kembali ke nama utama saat dibuka
        MinimizeButton.Text = "-"
    end
end)


-- 8. COMPONENT CREATION HELPER
local function AddButtonToPage(page, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -5, 0, 30)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Button.BorderSizePixel = 0
    Button.Font = Enum.Font.GothamMedium
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(240, 240, 240)
    Button.TextSize = 12
    Button.MouseButton1Click:Connect(callback)
    Button.Parent = page
    return Button
end


-- 9. MENGISI FITUR TIAP MENU

-- === ISI TAB FARM ===
local autoFarmActive = false
local FarmBtn = AddButtonToPage(FarmPage, "Auto Farm: OFF", function()
    autoFarmActive = not autoFarmActive
    if autoFarmActive then
        FarmBtn.Text = "Auto Farm: ON"
        FarmBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        
        task.spawn(function()
            while autoFarmActive and HrietaHub.Parent do
                print("[Hrieta Hub] Auto farming cycle running...")
                task.wait(1)
            end
        end)
    else
        FarmBtn.Text = "Auto Farm: OFF"
        FarmBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    end
end)

AddButtonToPage(FarmPage, "Teleport to Checkpoint", function()
    print("[Hrieta Hub] Teleporting player...")
end)


-- === ISI TAB SETTING ===
AddButtonToPage(SettingPage, "Reset Speed (16)", function()
    local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = 16 end
end)

AddButtonToPage(SettingPage, "Set Custom Speed (50)", function()
    local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = 50 end
end)

AddButtonToPage(SettingPage, "Destroy Interface", function()
    HrietaHub:Destroy()
end)

print("Hrieta Hub (Sidebar Layout) loaded successfully.")