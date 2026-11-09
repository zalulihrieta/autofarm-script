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

-- VISUALS TAB

local VisualsTab = Window:Tab({
    Title = "Visuals",
    Icon = "eye"
})

VisualsTab:Toggle({
    Title = "Bug ESP",
    Desc = "Show bug highlights",
    Value = false,

    Callback = function(value)

        ESPConfig.Enabled = value

        if not value then
            for bug in pairs(ESPObjects) do
                RemoveESP(bug)
            end
        end

    end
})

VisualsTab:Dropdown({
    Title = "ESP Size Filter",

    Values = {
        "All Sizes",
        "Normal",
        "Small+",
        "Large+",
        "Huge+",
        "Giant+",
        "Massive"
    },

    Value = "Normal",

    Callback = function(value)
        ESPConfig.SizeFilter = value
    end
})

VisualsTab:Toggle({
    Title = "Show Bug Name",
    Value = true,

    Callback = function(value)
        ESPConfig.ShowName = value
    end
})

VisualsTab:Toggle({
    Title = "Show Distance",
    Value = true,

    Callback = function(value)
        ESPConfig.ShowDistance = value
    end
})

VisualsTab:Slider({
    Title = "ESP Max Distance",

    Value = {
        Min = 50,
        Max = 2000,
        Default = 1000
    },

    Step = 50,

    Callback = function(value)
        ESPConfig.MaxDistance = value
    end
})

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

-- =====================================
-- BUG ESP SYSTEM
-- =====================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local BugsFolder = workspace:WaitForChild("Bugs")

local ESPConfig = {
    Enabled = false,

    SizeFilter = "Normal",

    ShowName = true,
    ShowDistance = true,

    MaxDistance = 1000,

    UpdateInterval = 0.3
}

local ESPObjects = {}

local ESPColors = {
    Tiny = Color3.fromRGB(150,150,150),
    Small = Color3.fromRGB(100,200,255),
    Normal = Color3.fromRGB(255,255,255),
    Large = Color3.fromRGB(100,255,100),
    Huge = Color3.fromRGB(255,190,50),
    Giant = Color3.fromRGB(255,100,50),
    Massive = Color3.fromRGB(255,50,100)
}

local SizeRanks = {
    Tiny = 1,
    Small = 2,
    Normal = 3,
    Large = 4,
    Huge = 5,
    Giant = 6,
    Massive = 7
}

-- SIZE DETECTION

local function GetBugSize(name)

    for size, rank in pairs(SizeRanks) do

        if name:lower():find(size:lower(), 1, true) then
            return size, rank
        end

    end

    return "Normal", 3
end

-- FILTER

local function PassSizeFilter(size, rank)

    if ESPConfig.SizeFilter == "Normal" then
        return true
    end

    if ESPConfig.SizeFilter == "All Sizes" then
        return true
    end

    local minimum = SizeRanks[
        ESPConfig.SizeFilter:gsub("%+", "")
    ]

    if not minimum then
        return false
    end

    return rank >= minimum

end

-- CREATE ESP

local function CreateESP(bug)

    if ESPObjects[bug] then
        return
    end

    local highlight = Instance.new("Highlight")

    highlight.Name = "BugESP_Highlight"
    highlight.Adornee = bug
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.85
    highlight.OutlineTransparency = 0

    local billboard = Instance.new("BillboardGui")

    billboard.Name = "BugESP_Label"
    billboard.Size = UDim2.fromOffset(150, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")

    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextStrokeTransparency = 0
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold

    label.Parent = billboard

    local root = bug:FindFirstChild("HumanoidRootPart")

    if root then
        billboard.Adornee = root
    end

    ESPObjects[bug] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label
    }

end

-- REMOVE ESP

local function RemoveESP(bug)

    local data = ESPObjects[bug]

    if not data then
        return
    end

    data.Highlight:Destroy()
    data.Billboard:Destroy()

    ESPObjects[bug] = nil

end

-- UPDATE ESP

local function UpdateESP()

    local character = Player.Character
    local hrp = character and
        character:FindFirstChild("HumanoidRootPart")

    if not hrp then
        return
    end

    for _, bug in ipairs(BugsFolder:GetChildren()) do

        if not bug:IsA("Model") then
            continue
        end

        local root = bug:FindFirstChild("HumanoidRootPart")

        if not root then
            RemoveESP(bug)
            continue
        end

        local size, rank = GetBugSize(bug.Name)

        local distance =
            (root.Position - hrp.Position).Magnitude

        local allowed =
            ESPConfig.Enabled
            and distance <= ESPConfig.MaxDistance
            and PassSizeFilter(size, rank)

        if allowed then

            CreateESP(bug)

            local data = ESPObjects[bug]

            local color = ESPColors[size]

            data.Highlight.FillColor = color
            data.Highlight.OutlineColor = color

            local text = ""

            if ESPConfig.ShowName then
                text = bug.Name
            end

            if ESPConfig.ShowDistance then

                if text ~= "" then
                    text ..= "\n"
                end

                text ..= math.floor(distance) .. " studs"

            end

            data.Label.Text = text

            data.Highlight.Enabled = true
            data.Billboard.Enabled = true

        else

            RemoveESP(bug)

        end

    end

    -- CLEANUP

    for bug in pairs(ESPObjects) do

        if not bug.Parent then
            RemoveESP(bug)
        end

    end

end

-- ESP LOOP

task.spawn(function()

    while task.wait(ESPConfig.UpdateInterval) do

        UpdateESP()

    end

end)

-- CLEANUP WHEN DISABLED

local function DisableESP()

    ESPConfig.Enabled = false

    for bug in pairs(ESPObjects) do
        RemoveESP(bug)
    end

end

print("Bug Farm V2 Loaded")