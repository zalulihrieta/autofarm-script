--[[
    BUG FARM SYSTEM V2
    Dynamic Species Detection
    TP / Tween Movement
    Automatic Game Attack
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local BugsFolder = workspace:WaitForChild("Bugs")

-- SETTINGS

local Config = {
    Enabled = false,

    Species = "All Bugs",
    Priority = "Largest First",

    Movement = "Teleport",

    AttackDistance = 5,
    TweenSpeed = 60,

    ScanInterval = 0.5,
    RecheckInterval = 1
}

local Character
local HRP

local CurrentTarget
local BugCount = 0

local ActiveTween

-- SIZE RANK

local SizeRanks = {
    Tiny = 1,
    Small = 2,
    Normal = 3,
    Large = 4,
    Huge = 5,
    Giant = 6,
    Massive = 7
}

local function GetSize(name)

    local lower = name:lower()

    for size, rank in pairs(SizeRanks) do

        if lower:find(size:lower(), 1, true) then
            return rank
        end

    end

    return 3
end

-- SPECIES DETECTION

local function GetSpecies(name)

    local result = {}

    for word in name:gmatch("%S+") do

        local isSize = false

        for size in pairs(SizeRanks) do

            if word:lower() == size:lower() then
                isSize = true
                break
            end

        end

        if not isSize then
            table.insert(result, word)
        end

    end

    return table.concat(result, " ")

end

-- CHARACTER

local function UpdateCharacter()

    Character = Player.Character

    HRP = Character and
        Character:FindFirstChild("HumanoidRootPart")

end

Player.CharacterAdded:Connect(function()

    task.wait(1)
    UpdateCharacter()

end)

UpdateCharacter()

-- SPECIES LIST

local SpeciesList = {"All Bugs"}

local function ScanSpecies()

    local detected = {}

    BugCount = 0

    for _, bug in ipairs(BugsFolder:GetChildren()) do

        if bug:IsA("Model") then

            BugCount += 1

            local species = GetSpecies(bug.Name)

            if species ~= "" then
                detected[species] = true
            end

        end

    end

    local list = {"All Bugs"}

    for species in pairs(detected) do
        table.insert(list, species)
    end

    table.sort(list)

    SpeciesList = list

end

-- VALIDATE BUG

local function GetBugData(bug)

    if not bug or not bug.Parent then
        return nil
    end

    local root = bug:FindFirstChild("HumanoidRootPart")

    if not root then
        return nil
    end

    local humanoid = bug:FindFirstChildOfClass("Humanoid")

    if humanoid and humanoid.Health <= 0 then
        return nil
    end

    local distance =
        (root.Position - HRP.Position).Magnitude

    return {
        Model = bug,
        Root = root,
        Species = GetSpecies(bug.Name),
        Size = GetSize(bug.Name),
        Distance = distance
    }

end

-- GET TARGETS

local function GetTargets()

    local targets = {}

    for _, bug in ipairs(BugsFolder:GetChildren()) do

        if bug:IsA("Model") then

            local data = GetBugData(bug)

            if data then

                if Config.Species == "All Bugs"
                or data.Species:lower() ==
                   Config.Species:lower() then

                    table.insert(targets, data)

                end

            end

        end

    end

    return targets

end

-- PRIORITY

local function SortTargets(targets)

    if Config.Priority == "Largest First" then

        table.sort(targets, function(a, b)

            if a.Size == b.Size then
                return a.Distance < b.Distance
            end

            return a.Size > b.Size

        end)

    elseif Config.Priority == "Smallest First" then

        table.sort(targets, function(a, b)

            if a.Size == b.Size then
                return a.Distance < b.Distance
            end

            return a.Size < b.Size

        end)

    elseif Config.Priority == "Nearest First" then

        table.sort(targets, function(a, b)
            return a.Distance < b.Distance
        end)

    elseif Config.Priority == "Random Size (Nearest)" then

        table.sort(targets, function(a, b)

            if math.abs(a.Distance - b.Distance) < 3 then
                return math.random(1, 2) == 1
            end

            return a.Distance < b.Distance

        end)

    end

    return targets

end

-- STOP MOVEMENT

local function StopMovement()

    if ActiveTween then
        ActiveTween:Cancel()
        ActiveTween = nil
    end

end

-- MOVE TO TARGET

local function MoveTo(target)

    if not target or not target.Parent then
        return
    end

    UpdateCharacter()

    if not HRP then
        return
    end

    local root = target:FindFirstChild("HumanoidRootPart")

    if not root then
        return
    end

    local direction = (HRP.Position - root.Position)

    if direction.Magnitude < 0.1 then
        direction = Vector3.new(0, 0, 1)
    else
        direction = direction.Unit
    end

    local destination =
        root.Position + direction * Config.AttackDistance

    if Config.Movement == "Teleport" then

        StopMovement()

        HRP.CFrame = CFrame.lookAt(
            destination,
            root.Position
        )

    elseif Config.Movement == "Tween" then

        local distance =
            (HRP.Position - destination).Magnitude

        local duration =
            distance / math.max(Config.TweenSpeed, 1)

        if duration < 0.05 then
            return
        end

        StopMovement()

        ActiveTween = TweenService:Create(
            HRP,
            TweenInfo.new(
                duration,
                Enum.EasingStyle.Linear
            ),
            {
                CFrame = CFrame.lookAt(
                    destination,
                    root.Position
                )
            }
        )

        ActiveTween:Play()

    end

end

-- FARM ENGINE

task.spawn(function()

    while task.wait(Config.ScanInterval) do

        UpdateCharacter()
        ScanSpecies()

        if not Config.Enabled or not HRP then
            CurrentTarget = nil
            StopMovement()
            continue
        end

        local targets = GetTargets()

        SortTargets(targets)

        local selected = targets[1]

        if not selected then
            CurrentTarget = nil
            StopMovement()
            continue
        end

        CurrentTarget = selected.Model

        local distance = selected.Distance

        if distance > Config.AttackDistance then

            MoveTo(selected.Model)

        else

            StopMovement()

        end

    end

end)

-- GUI

local GUI = Instance.new("ScreenGui")
GUI.Name = "BugFarmV2"
GUI.ResetOnSpawn = false
GUI.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(260, 390)
Main.Position = UDim2.new(0.5, -130, 0.5, -195)
Main.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius =
    UDim.new(0, 12)

local function CreateButton(text, y, height)

    local button = Instance.new("TextButton")

    button.Size = UDim2.new(1, -20, 0, height or 34)
    button.Position = UDim2.fromOffset(10, y)

    button.BackgroundColor3 =
        Color3.fromRGB(43, 45, 56)

    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 12
    button.Font = Enum.Font.GothamMedium
    button.Text = text

    button.Parent = Main

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 7)

    return button

end

local Title = CreateButton("BUG FARM SYSTEM V2", 8, 32)

local Toggle = CreateButton("FARM : OFF", 48)
local SpeciesBtn = CreateButton("SPECIES : All Bugs", 88)
local PriorityBtn = CreateButton("SIZE : Largest First", 128)
local MovementBtn = CreateButton("MOVEMENT : Teleport", 168)
local SpeedBtn = CreateButton("TWEEN SPEED : 60", 208)
local DistanceBtn = CreateButton("ATTACK DISTANCE : 5", 248)

local TargetLabel = CreateButton("TARGET : None", 288)
local CountLabel = CreateButton("BUGS DETECTED : 0", 328)
local Minimize = CreateButton("MINIMIZE", 368, 28)

-- FARM TOGGLE

Toggle.MouseButton1Click:Connect(function()

    Config.Enabled = not Config.Enabled

    Toggle.Text = Config.Enabled
        and "FARM : ON"
        or "FARM : OFF"

    Toggle.BackgroundColor3 = Config.Enabled
        and Color3.fromRGB(30, 125, 75)
        or Color3.fromRGB(43, 45, 56)

    if not Config.Enabled then
        StopMovement()
        CurrentTarget = nil
    end

end)

-- SPECIES

local SpeciesIndex = 1

SpeciesBtn.MouseButton1Click:Connect(function()

    SpeciesIndex += 1

    if SpeciesIndex > #SpeciesList then
        SpeciesIndex = 1
    end

    Config.Species = SpeciesList[SpeciesIndex]

    SpeciesBtn.Text =
        "SPECIES : " .. Config.Species

end)

-- PRIORITY

local Priorities = {
    "Largest First",
    "Smallest First",
    "Nearest First",
    "Random Size (Nearest)"
}

local PriorityIndex = 1

PriorityBtn.MouseButton1Click:Connect(function()

    PriorityIndex = PriorityIndex % #Priorities + 1

    Config.Priority = Priorities[PriorityIndex]

    PriorityBtn.Text =
        "SIZE : " .. Config.Priority

end)

-- MOVEMENT

MovementBtn.MouseButton1Click:Connect(function()

    Config.Movement =
        Config.Movement == "Teleport"
        and "Tween"
        or "Teleport"

    StopMovement()

    MovementBtn.Text =
        "MOVEMENT : " .. Config.Movement

end)

-- TWEEN SPEED

SpeedBtn.MouseButton1Click:Connect(function()

    local speeds = {30, 60, 100, 150, 250}

    local index = table.find(speeds, Config.TweenSpeed) or 2

    index = index % #speeds + 1

    Config.TweenSpeed = speeds[index]

    SpeedBtn.Text =
        "TWEEN SPEED : " .. Config.TweenSpeed

end)

-- DISTANCE

DistanceBtn.MouseButton1Click:Connect(function()

    local distances = {3, 5, 7, 10, 15}

    local index = table.find(
        distances,
        Config.AttackDistance
    ) or 2

    index = index % #distances + 1

    Config.AttackDistance = distances[index]

    DistanceBtn.Text =
        "ATTACK DISTANCE : " .. Config.AttackDistance

end)

-- STATUS

task.spawn(function()

    while task.wait(0.5) do

        CountLabel.Text =
            "BUGS DETECTED : " .. BugCount

        TargetLabel.Text =
            CurrentTarget and CurrentTarget.Parent
            and "TARGET : " .. CurrentTarget.Name
            or "TARGET : None"

    end

end)

-- MINIMIZE

local minimized = false

Minimize.MouseButton1Click:Connect(function()

    minimized = not minimized

    for _, child in ipairs(Main:GetChildren()) do

        if child:IsA("TextButton") and child ~= Title
        and child ~= Minimize then

            child.Visible = not minimized

        end

    end

    Main.Size = minimized
        and UDim2.fromOffset(260, 80)
        or UDim2.fromOffset(260, 390)

    Minimize.Text = minimized and
        "EXPAND" or "MINIMIZE"

end)

-- DRAGGABLE

local dragging = false
local dragStart
local startPos

Title.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position

    end

end)

UIS.InputChanged:Connect(function(input)

    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

    end

end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false

    end

end)

print("Bug Farm V2 Loaded")