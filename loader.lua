-- Simple Loader by zalulihrieta

local raw = "https://raw.githubusercontent.com/zalulihrieta/autofarm-script/main/main.lua"

if not game:IsLoaded() then
    game.Loaded:Wait()
end

loadstring(game:HttpGet(raw))()
