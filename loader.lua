local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get UserId safely
local userId
pcall(function()
    userId = Players:GetUserIdFromNameAsync("zaluli_hrieta")
end)

-- Thumbnail
local content = ""
if userId then
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    content = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
end

-- Notifications
local function Notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Icon = content,
        Duration = 5
    })
end

Notify("AUTO FARM", "Loaded Successfully")
task.wait(0.3)
Notify("Credits", "Original by zaluli Scriptblox")

-- Chat Message
local function SendChatMessage(msg)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            channel:SendAsync(msg)
        end
    else
        ReplicatedStorage
            :WaitForChild("DefaultChatSystemChatEvents")
            :WaitForChild("SayMessageRequest")
            :FireServer(msg, "All")
    end
end

SendChatMessage("Halah Nyocot")


local raw = "https://raw.githubusercontent.com/zalulihrieta/autofarm-script/main/main.lua"

if not game:IsLoaded() then
    game.Loaded:Wait()
end

loadstring(game:HttpGet(raw))()
