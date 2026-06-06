local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

print("[LoadingScreen] Script Started")

-- Remove the default loading screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

local player = Players.LocalPlayer
print("[LoadingScreen] Waiting for PlayerGui...")
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
    print("[LoadingScreen] ERROR: PlayerGui did not load in time!")
    return
end
print("[LoadingScreen] PlayerGui found!")

-- Create the custom loading screen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomLoadingScreen"
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 9999 -- Maximum display order
screenGui.ResetOnSpawn = false -- Prevent it from disappearing when character spawns!
screenGui.Enabled = true
screenGui.Parent = playerGui

local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(50, 150, 255) -- Bright cartoony blue
background.BorderSizePixel = 0
background.ZIndex = 100
background.Visible = true
background.Parent = screenGui

local title = Instance.new("TextLabel")
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.new(0.5, 0, 0.4, 0)
title.Size = UDim2.new(0.8, 0, 0.2, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.FredokaOne
title.Text = "SPIN A MYTHICAL!"
title.TextColor3 = Color3.fromRGB(255, 204, 0)
title.TextScaled = true
title.Parent = background

local titleStroke = Instance.new("UIStroke")
titleStroke.Thickness = 6
titleStroke.Color = Color3.fromRGB(0, 0, 0)
titleStroke.Parent = title

local loadingText = Instance.new("TextLabel")
loadingText.AnchorPoint = Vector2.new(0.5, 0.5)
loadingText.Position = UDim2.new(0.5, 0, 0.6, 0)
loadingText.Size = UDim2.new(0.5, 0, 0.1, 0)
loadingText.BackgroundTransparency = 1
loadingText.Font = Enum.Font.FredokaOne
loadingText.Text = "Loading Awesomeness..."
loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingText.TextScaled = true
loadingText.Parent = background

local textStroke = Instance.new("UIStroke")
textStroke.Thickness = 3
textStroke.Color = Color3.fromRGB(0, 0, 0)
textStroke.Parent = loadingText

-- Animate the loading text while waiting
local isLoaded = false
task.spawn(function()
    local dots = 0
    while not isLoaded do
        dots = (dots + 1) % 4
        loadingText.Text = "Loading Awesomeness" .. string.rep(".", dots)
        task.wait(0.5)
    end
end)

-- Wait for the game to fully load
if not game:IsLoaded() then
    game.Loaded:Wait()
end
isLoaded = true

-- Additional artificial wait to ensure UI is ready and feels like a real simulator
task.wait(4)

loadingText.Text = "Done!"

-- Fade out animation
local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bgTween = TweenService:Create(background, fadeInfo, {BackgroundTransparency = 1})
local titleTween = TweenService:Create(title, fadeInfo, {TextTransparency = 1})
local titleStrokeTween = TweenService:Create(titleStroke, fadeInfo, {Transparency = 1})
local loadingTween = TweenService:Create(loadingText, fadeInfo, {TextTransparency = 1})
local loadingStrokeTween = TweenService:Create(textStroke, fadeInfo, {Transparency = 1})

bgTween:Play()
titleTween:Play()
titleStrokeTween:Play()
loadingTween:Play()
loadingStrokeTween:Play()

bgTween.Completed:Wait()
screenGui:Destroy()
