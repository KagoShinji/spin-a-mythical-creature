local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

print("[LoadingScreen] Script Started")

-- Remove the default loading screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
    print("[LoadingScreen] ERROR: PlayerGui did not load in time!")
    return
end

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
background.BackgroundColor3 = Color3.fromRGB(30, 30, 40) -- Sleek dark background
background.BorderSizePixel = 0
background.ZIndex = 100
background.Visible = true
background.Parent = screenGui

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 125, 230)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 30, 60))
})
gradient.Rotation = 45
gradient.Parent = background

-- Decorative geometric shapes for modern look
local function createDecal(pos, size, rotation, opacity)
    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = pos
    frame.Size = size
    frame.Rotation = rotation
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = opacity
    frame.BorderSizePixel = 0
    frame.ZIndex = 101
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = frame
    
    frame.Parent = background
    
    -- Slowly rotate in background
    task.spawn(function()
        while frame.Parent do
            frame.Rotation = frame.Rotation + 0.1
            task.wait(0.03)
        end
    end)
end

createDecal(UDim2.new(0.1, 0, 0.8, 0), UDim2.new(0, 300, 0, 300), 15, 0.95)
createDecal(UDim2.new(0.9, 0, 0.1, 0), UDim2.new(0, 200, 0, 200), -20, 0.92)

local title = Instance.new("TextLabel")
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.new(0.5, 0, 0.35, 0)
title.Size = UDim2.new(0.8, 0, 0.2, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.FredokaOne
title.Text = "SPIN A MYTHICAL!"
title.TextColor3 = Color3.fromRGB(255, 220, 50)
title.TextScaled = true
title.ZIndex = 105
title.Parent = background

local titleStroke = Instance.new("UIStroke")
titleStroke.Thickness = 6
titleStroke.Color = Color3.fromRGB(20, 10, 0)
titleStroke.Parent = title

local titleShadow = Instance.new("TextLabel")
titleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
titleShadow.Position = UDim2.new(0.5, 0, 0.5, 8)
titleShadow.Size = UDim2.new(1, 0, 1, 0)
titleShadow.BackgroundTransparency = 1
titleShadow.Font = Enum.Font.FredokaOne
titleShadow.Text = "SPIN A MYTHICAL!"
titleShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
titleShadow.TextTransparency = 0.5
titleShadow.TextScaled = true
titleShadow.ZIndex = 104
titleShadow.Parent = title

local loadingContainer = Instance.new("Frame")
loadingContainer.AnchorPoint = Vector2.new(0.5, 0.5)
loadingContainer.Position = UDim2.new(0.5, 0, 0.6, 0)
loadingContainer.Size = UDim2.new(0, 400, 0, 20)
loadingContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
loadingContainer.BackgroundTransparency = 0.6
loadingContainer.BorderSizePixel = 0
loadingContainer.ZIndex = 105
loadingContainer.Parent = background

local loadingCorner = Instance.new("UICorner")
loadingCorner.CornerRadius = UDim.new(1, 0)
loadingCorner.Parent = loadingContainer

local loadingFill = Instance.new("Frame")
loadingFill.Position = UDim2.new(0, 0, 0, 0)
loadingFill.Size = UDim2.new(0, 0, 1, 0)
loadingFill.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
loadingFill.BorderSizePixel = 0
loadingFill.ZIndex = 106
loadingFill.Parent = loadingContainer

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = loadingFill

local loadingText = Instance.new("TextLabel")
loadingText.AnchorPoint = Vector2.new(0.5, 1)
loadingText.Position = UDim2.new(0.5, 0, 0, -10)
loadingText.Size = UDim2.new(1, 0, 0, 30)
loadingText.BackgroundTransparency = 1
loadingText.Font = Enum.Font.FredokaOne
loadingText.Text = "Loading Awesomeness..."
loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingText.TextScaled = true
loadingText.ZIndex = 105
loadingText.Parent = loadingContainer

local textStroke = Instance.new("UIStroke")
textStroke.Thickness = 2
textStroke.Color = Color3.fromRGB(0, 0, 0)
textStroke.Parent = loadingText

local playButton = Instance.new("TextButton")
playButton.AnchorPoint = Vector2.new(0.5, 0.5)
playButton.Position = UDim2.new(0.5, 0, 0.6, 0)
playButton.Size = UDim2.new(0, 250, 0, 70)
playButton.BackgroundColor3 = Color3.fromRGB(50, 220, 80)
playButton.BorderSizePixel = 0
playButton.Font = Enum.Font.FredokaOne
playButton.Text = "PLAY!"
playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playButton.TextScaled = true
playButton.ZIndex = 110
playButton.Visible = false
playButton.Parent = background

local playCorner = Instance.new("UICorner")
playCorner.CornerRadius = UDim.new(0, 16)
playCorner.Parent = playButton

local playStroke = Instance.new("UIStroke")
playStroke.Thickness = 4
playStroke.Color = Color3.fromRGB(20, 80, 20)
playStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
playStroke.Parent = playButton

local playTextStroke = Instance.new("UIStroke")
playTextStroke.Thickness = 2
playTextStroke.Color = Color3.fromRGB(0, 0, 0)
playTextStroke.Parent = playButton

-- Add hover effect
playButton.MouseEnter:Connect(function()
    TweenService:Create(playButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 270, 0, 76)
    }):Play()
end)

playButton.MouseLeave:Connect(function()
    TweenService:Create(playButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 250, 0, 70)
    }):Play()
end)

-- Simulated Loading Process
local isLoaded = false
task.spawn(function()
    local dots = 0
    while not isLoaded do
        dots = (dots + 1) % 4
        loadingText.Text = "Loading Game Assets" .. string.rep(".", dots)
        task.wait(0.4)
    end
end)

-- Smoothly animate the loading bar
TweenService:Create(loadingFill, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {
    Size = UDim2.new(0.8, 0, 1, 0)
}):Play()

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Finish loading bar quickly once loaded
local finalLoadTween = TweenService:Create(loadingFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.new(1, 0, 1, 0)
})
finalLoadTween:Play()
finalLoadTween.Completed:Wait()

isLoaded = true
loadingContainer.Visible = false

-- Show Play Button
playButton.Visible = true

-- Bouncy pop-in for Play Button
playButton.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(playButton, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 250, 0, 70)
}):Play()

-- Pulse animation for play button
task.spawn(function()
    while playButton.Parent and playButton.Visible do
        task.wait(2)
        TweenService:Create(playButton, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Rotation = 3
        }):Play()
        task.wait(0.5)
        TweenService:Create(playButton, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Rotation = -3
        }):Play()
        task.wait(0.5)
        TweenService:Create(playButton, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Rotation = 0
        }):Play()
    end
end)

playButton.Activated:Connect(function()
    playButton.Visible = false
    
    -- Fade out animation
    local fadeInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    for _, obj in ipairs(background:GetDescendants()) do
        if obj:IsA("GuiObject") then
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                TweenService:Create(obj, fadeInfo, {TextTransparency = 1}):Play()
            end
            if obj:IsA("Frame") or obj:IsA("ImageLabel") then
                TweenService:Create(obj, fadeInfo, {BackgroundTransparency = 1}):Play()
            end
            if obj:IsA("UIStroke") then
                TweenService:Create(obj, fadeInfo, {Transparency = 1}):Play()
            end
        end
    end
    
    local bgTween = TweenService:Create(background, fadeInfo, {BackgroundTransparency = 1})
    bgTween:Play()
    bgTween.Completed:Wait()
    
    screenGui:Destroy()
end)
