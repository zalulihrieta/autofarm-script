-- TRUE NORRENDER + BLACK SCREEN

-- black screen
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.IgnoreGuiInset = true

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(1,0,1,0)
frame.BackgroundColor3 = Color3.new(0,0,0)
frame.BorderSizePixel = 0

-- disable 3D rendering objects
for _,v in pairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") then
        v.LocalTransparencyModifier = 1
    end
    
    if v:IsA("Decal") or v:IsA("Texture") then
        v:Destroy()
    end
    
    if v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Enabled = false
    end
end

-- lighting optimization
local lighting = game:GetService("Lighting")
lighting.GlobalShadows = false
lighting.FogEnd = 9e9
lighting.Brightness = 0

-- disable terrain decoration
if workspace:FindFirstChildOfClass("Terrain") then
    workspace.Terrain.Decoration = false
end

print("Norender mode aktif - FPS harusnya naik")
