--// FINAL BOSS CFrame TOOL (Rayfield UI Version)
--// Require Rayfield

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local DATA_FOLDER = "cframe_profiles/"
if makefolder and not isfolder(DATA_FOLDER) then
    makefolder(DATA_FOLDER)
end

local saved = {}
local currentProfile = "default"
local tweenMode = "OFF"
local autoSave = false

-- WINDOW
local Window = Rayfield:CreateWindow({
    Name = "CFrame Tool",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by bro",
    ConfigurationSaving = {
        Enabled = false
    }
})

-- TABS
local MainTab = Window:CreateTab("Main")
local FileTab = Window:CreateTab("Profiles")
local SettingsTab = Window:CreateTab("Settings")

-- FUNCTIONS
local function saveProfile(name)
    if writefile then
        local data = {}
        for _,v in ipairs(saved) do
            table.insert(data, {name=v.name, cf={v.cf:GetComponents()}})
        end
        writefile(DATA_FOLDER..name..".json", HttpService:JSONEncode(data))
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
    end
end

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
    if autoSave then saveProfile(currentProfile) end
end

-- KEY BIND
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            add(char.HumanoidRootPart.CFrame)
        end
    end
end)

-- MAIN TAB
MainTab:CreateButton({
    Name = "Add CFrame (Press K)",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            add(char.HumanoidRootPart.CFrame)
        end
    end
})

MainTab:CreateButton({
    Name = "Teleport to Last",
    Callback = function()
        if saved[#saved] then
            teleport(saved[#saved].cf)
        end
    end
})

-- DROPDOWN PROFILE
local profiles = {}
if listfiles then
    for _,file in ipairs(listfiles(DATA_FOLDER)) do
        table.insert(profiles, file:match("([^/]+)%.json"))
    end
end

FileTab:CreateDropdown({
    Name = "Select Profile",
    Options = profiles,
    Callback = function(opt)
        currentProfile = opt
    end
})

FileTab:CreateInput({
    Name = "Profile Name",
    PlaceholderText = "Enter name",
    Callback = function(txt)
        currentProfile = txt
    end
})

FileTab:CreateButton({
    Name = "Save",
    Callback = function()
        saveProfile(currentProfile)
    end
})

FileTab:CreateButton({
    Name = "Load",
    Callback = function()
        loadProfile(currentProfile)
    end
})

-- SETTINGS
SettingsTab:CreateToggle({
    Name = "Auto Save",
    CurrentValue = false,
    Callback = function(val)
        autoSave = val
    end
})

SettingsTab:CreateDropdown({
    Name = "Tween Mode",
    Options = {"OFF","FAST","SLOW"},
    Callback = function(val)
        tweenMode = val
    end
})

-- EXPORT / IMPORT
MainTab:CreateButton({
    Name = "Export",
    Callback = function()
        if setclipboard then
            local data = {}
            for _,v in ipairs(saved) do
                table.insert(data, {name=v.name, cf={v.cf:GetComponents()}})
            end
            setclipboard(HttpService:JSONEncode(data))
        end
    end
})

MainTab:CreateButton({
    Name = "Import",
    Callback = function()
        if getclipboard then
            local raw = getclipboard()
            local data = HttpService:JSONDecode(raw)

            for _,v in ipairs(data) do
                table.insert(saved, {name=v.name, cf=CFrame.new(unpack(v.cf))})
            end
        end
    end
})
