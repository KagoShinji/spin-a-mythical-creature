local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Network = require(Shared:WaitForChild("Network"))

local BuyItemRemote = Network.getFunction("BuyItem")
local SpinRemote = Network.getFunction("Spin")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHUD = playerGui:WaitForChild("MainHUD")

-- Wait for data to initialize
local leaderstats = player:WaitForChild("leaderstats", 10)
local coinsValue = leaderstats and leaderstats:WaitForChild("Coins", 5)

local inventoryData = player:WaitForChild("Inventory", 10)
local runesValue = inventoryData and inventoryData:WaitForChild("Runes", 5)
local mythicalsFolder = inventoryData and inventoryData:WaitForChild("Mythicals", 5)

-- Layout and Theme Setup
local function applyLegoTheme(element, color, cornerRadius, hasStroke)
    element.BackgroundColor3 = color
    element.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius)
    corner.Parent = element
    
    if hasStroke then
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 4
        stroke.Color = Color3.fromRGB(0, 0, 0)
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = element
    end
    
    if element:IsA("TextLabel") or element:IsA("TextButton") then
        element.Font = Enum.Font.FredokaOne
        element.TextColor3 = Color3.fromRGB(255, 255, 255)
        element.TextScaled = true
        
        local textStroke = Instance.new("UIStroke")
        textStroke.Thickness = 2
        textStroke.Color = Color3.fromRGB(0, 0, 0)
        textStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        textStroke.Parent = element
    end
end

-- 1. Spin Container (Bottom Center, above Hotbar)
local spinContainer = mainHUD:WaitForChild("SpinContainer")
spinContainer.AnchorPoint = Vector2.new(0.5, 1)
spinContainer.Position = UDim2.new(0.5, 0, 1, -120)
spinContainer.Size = UDim2.new(0, 200, 0, 80)
spinContainer.BackgroundTransparency = 1

local spinButton = spinContainer:WaitForChild("SpinButton")
spinButton.AnchorPoint = Vector2.new(0.5, 0.5)
spinButton.Position = UDim2.new(0.5, 0, 0.5, 0)
spinButton.Size = UDim2.new(1, 0, 1, 0)
spinButton.Text = "SPIN!"
spinButton.Visible = false -- Hidden by default until runes are obtained
applyLegoTheme(spinButton, Color3.fromRGB(0, 180, 0), 16, true)

-- 2. Resource Container (Top Right)
local resourceContainer = mainHUD:WaitForChild("ResourceContainer")
resourceContainer.AnchorPoint = Vector2.new(1, 0)
resourceContainer.Position = UDim2.new(1, -20, 0, 20)
resourceContainer.Size = UDim2.new(0, 200, 0, 100)
resourceContainer.BackgroundTransparency = 1

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
listLayout.Parent = resourceContainer

local coinsLabel = resourceContainer:WaitForChild("CoinsLabel")
coinsLabel.Size = UDim2.new(1, 0, 0, 45)
coinsLabel.Text = coinsValue and ("🪙 " .. tostring(coinsValue.Value)) or "🪙 0"
applyLegoTheme(coinsLabel, Color3.fromRGB(255, 204, 0), 12, true)

if coinsValue then
    coinsValue.Changed:Connect(function(newVal)
        coinsLabel.Text = "🪙 " .. tostring(newVal)
    end)
end

local gemsLabel = resourceContainer:WaitForChild("GemsLabel")
gemsLabel.Size = UDim2.new(1, 0, 0, 45)
gemsLabel.Text = "💎 50"
applyLegoTheme(gemsLabel, Color3.fromRGB(0, 170, 255), 12, true)

-- 3. Top Menu (Top Center)
local topMenu = mainHUD:WaitForChild("TopMenu")
topMenu.AnchorPoint = Vector2.new(0.5, 0)
topMenu.Position = UDim2.new(0.5, 0, 0, 20)
topMenu.Size = UDim2.new(0, 300, 0, 60)
topMenu.BackgroundTransparency = 1

local topListLayout = Instance.new("UIListLayout")
topListLayout.FillDirection = Enum.FillDirection.Horizontal
topListLayout.Padding = UDim.new(0, 15)
topListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topListLayout.Parent = topMenu

local shopBtn = topMenu:WaitForChild("ShopButton")
shopBtn.Size = UDim2.new(0, 80, 0, 60)
shopBtn.Text = "Shop"
applyLegoTheme(shopBtn, Color3.fromRGB(255, 60, 60), 12, true)

local homeBtn = topMenu:WaitForChild("HomeButton")
homeBtn.Size = UDim2.new(0, 80, 0, 60)
homeBtn.Text = "Home"
applyLegoTheme(homeBtn, Color3.fromRGB(50, 150, 255), 12, true)

local eggsBtn = topMenu:WaitForChild("EggsButton")
eggsBtn.Size = UDim2.new(0, 80, 0, 60)
eggsBtn.Text = "Eggs"
applyLegoTheme(eggsBtn, Color3.fromRGB(255, 150, 0), 12, true)

-- 4. Left Menu
local leftMenu = mainHUD:WaitForChild("LeftMenu")
leftMenu.AnchorPoint = Vector2.new(0, 0.5)
leftMenu.Position = UDim2.new(0, 20, 0.5, 0)
leftMenu.Size = UDim2.new(0, 80, 0, 200)
leftMenu.BackgroundTransparency = 1

local leftListLayout = Instance.new("UIListLayout")
leftListLayout.Padding = UDim.new(0, 15)
leftListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
leftListLayout.Parent = leftMenu

local storeBtn = leftMenu:WaitForChild("StoreButton")
storeBtn.Size = UDim2.new(1, 0, 0, 80)
storeBtn.Text = "Store"
applyLegoTheme(storeBtn, Color3.fromRGB(200, 0, 255), 16, true)

local inventoryBtn = leftMenu:WaitForChild("InventoryButton")
inventoryBtn.Size = UDim2.new(1, 0, 0, 80)
inventoryBtn.Text = "Inv"
applyLegoTheme(inventoryBtn, Color3.fromRGB(0, 200, 150), 16, true)

-- 5. Panels (Shop, Eggs, Store, Inventory)
local panelsFolder = mainHUD:WaitForChild("Panels")

local function setupPanel(panelName, titleText, color)
    local panel = panelsFolder:WaitForChild(panelName)
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    -- Start closed (size 0)
    panel.Size = UDim2.new(0, 0, 0, 0)
    panel.Visible = false
    applyLegoTheme(panel, Color3.fromRGB(240, 240, 240), 20, true)
    
    local title = panel:WaitForChild("Title")
    title.AnchorPoint = Vector2.new(0.5, 0)
    title.Position = UDim2.new(0.5, 0, 0, 10)
    title.Size = UDim2.new(0.8, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = titleText
    applyLegoTheme(title, color, 0, false)
    
    local closeBtn = panel:WaitForChild("CloseButton")
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.Position = UDim2.new(1, -10, 0, 10)
    closeBtn.Size = UDim2.new(0, 50, 0, 50)
    closeBtn.Text = "X"
    applyLegoTheme(closeBtn, Color3.fromRGB(255, 50, 50), 12, true)
    
    return panel, closeBtn
end

local shopPanel, shopClose = setupPanel("ShopPanel", "SHOP", Color3.fromRGB(255, 60, 60))
local eggsPanel, eggsClose = setupPanel("EggsPanel", "EGGS", Color3.fromRGB(255, 150, 0))
local storePanel, storeClose = setupPanel("StorePanel", "STORE", Color3.fromRGB(200, 0, 255))
local invPanel, invClose = setupPanel("InventoryPanel", "INVENTORY", Color3.fromRGB(0, 200, 150))

-- Content Generation Helpers
local function createGridContent(panel, items, isStore)
    local container = Instance.new("ScrollingFrame")
    container.Name = "ContentContainer"
    container.AnchorPoint = Vector2.new(0.5, 0)
    container.Position = UDim2.new(0.5, 0, 0, 80)
    container.Size = UDim2.new(0.9, 0, 1, -100)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 8
    container.Parent = panel

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 150, 0, 150)
    gridLayout.CellPadding = UDim2.new(0, 20, 0, 20)
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    gridLayout.Parent = container

    for _, item in ipairs(items) do
        local frame = Instance.new("Frame")
        applyLegoTheme(frame, Color3.fromRGB(255, 255, 255), 12, true)
        frame.Parent = container

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(1, 0, 0.6, 0)
        icon.BackgroundTransparency = 1
        icon.Text = item.icon
        icon.TextScaled = true
        icon.Parent = frame

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Position = UDim2.new(0, 0, 0.6, 0)
        nameLabel.Size = UDim2.new(1, 0, 0.2, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = item.name
        nameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.FredokaOne
        nameLabel.TextScaled = true
        nameLabel.Parent = frame

        local buyBtn = Instance.new("TextButton")
        buyBtn.Position = UDim2.new(0.1, 0, 0.8, 0)
        buyBtn.Size = UDim2.new(0.8, 0, 0.2, 0)
        buyBtn.Text = item.price
        
        -- Store items use Robux color (greenish) or premium color
        local btnColor = isStore and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(50, 150, 255)
        applyLegoTheme(buyBtn, btnColor, 8, true)
        buyBtn.Parent = frame

        if item.isBuyable then
            buyBtn.Activated:Connect(function()
                buyBtn.Text = "..."
                local success, msg = BuyItemRemote:InvokeServer(item.name)
                if success then
                    buyBtn.Text = "Bought!"
                    buyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
                else
                    buyBtn.Text = "Failed"
                    buyBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
                task.delay(1, function()
                    buyBtn.Text = item.price
                    buyBtn.BackgroundColor3 = btnColor
                end)
            end)
        end
    end
end

-- 1. Shop Contents (In-game currency)
createGridContent(shopPanel, {
    {name = "Basic Rune", icon = "🔮", price = "🪙 100", isBuyable = true},
    {name = "Rare Rune", icon = "✨", price = "🪙 500", isBuyable = true},
    {name = "Speed Potion", icon = "🧪", price = "💎 50"}
}, false)

-- 2. Eggs Contents (Hatching mythicals)
createGridContent(eggsPanel, {
    {name = "Forest Egg", icon = "🥚", price = "🪙 250"},
    {name = "Lava Egg", icon = "🌋", price = "🪙 1000"},
    {name = "Mythic Egg", icon = "🌌", price = "💎 500"}
}, false)

-- 3. Store Contents (Robux/Gamepass items)
createGridContent(storePanel, {
    {name = "VIP Pass", icon = "👑", price = "R$ 399"},
    {name = "2x Luck", icon = "🍀", price = "R$ 150"},
    {name = "10,000 Coins", icon = "💰", price = "R$ 50"},
    {name = "Infinite Runes", icon = "♾️", price = "R$ 999"}
}, true)

-- 4. Inventory Contents (Just showing owned items, no buy button needed)
local invContainer = nil

local function updateInventoryContent()
    if invContainer then
        invContainer:Destroy()
    end

    invContainer = Instance.new("ScrollingFrame")
    invContainer.AnchorPoint = Vector2.new(0.5, 0)
    invContainer.Position = UDim2.new(0.5, 0, 0, 80)
    invContainer.Size = UDim2.new(0.9, 0, 1, -100)
    invContainer.BackgroundTransparency = 1
    invContainer.ScrollBarThickness = 8
    invContainer.Parent = invPanel

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 120, 0, 120)
    gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    gridLayout.Parent = invContainer

    if not mythicalsFolder then return end

    -- Draw Runes first if any
    if runesValue and runesValue.Value > 0 then
        local frame = Instance.new("Frame")
        applyLegoTheme(frame, Color3.fromRGB(240, 240, 240), 12, true)
        frame.Parent = invContainer

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(1, 0, 0.7, 0)
        icon.BackgroundTransparency = 1
        icon.Text = "🔮"
        icon.TextScaled = true
        icon.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0.3, 0)
        label.Position = UDim2.new(0, 0, 0.7, 0)
        label.BackgroundTransparency = 1
        label.Text = "Runes: " .. tostring(runesValue.Value)
        label.Font = Enum.Font.FredokaOne
        label.TextColor3 = Color3.fromRGB(0,0,0)
        label.TextScaled = true
        label.Parent = frame
    end

    -- Draw Mythicals
    for _, child in ipairs(mythicalsFolder:GetChildren()) do
        local frame = Instance.new("Frame")
        applyLegoTheme(frame, Color3.fromRGB(240, 240, 240), 12, true)
        frame.Parent = invContainer

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(1, 0, 1, 0)
        icon.BackgroundTransparency = 1
        icon.Text = child.Value
        icon.TextScaled = true
        icon.Parent = frame
    end
end
updateInventoryContent()

-- Panel Animation Logic
local activePanel = nil

local function closePanel(panel)
    if not panel then return end
    TweenService:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.delay(0.2, function()
        panel.Visible = false
    end)
    activePanel = nil
end

local function openPanel(panel)
    if activePanel == panel then return end
    if activePanel then closePanel(activePanel) end
    
    activePanel = panel
    panel.Visible = true
    TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 600, 0, 450)
    }):Play()
end

-- Close Button Events
shopClose.Activated:Connect(function() closePanel(shopPanel) end)
eggsClose.Activated:Connect(function() closePanel(eggsPanel) end)
storeClose.Activated:Connect(function() closePanel(storePanel) end)
invClose.Activated:Connect(function() closePanel(invPanel) end)

-- Hover Animations
local function applyBounceAnimation(button)
    local defaultSize = button.Size
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(defaultSize.X.Scale, defaultSize.X.Offset + 8, defaultSize.Y.Scale, defaultSize.Y.Offset + 8)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = defaultSize
        }):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.05), {
            Size = UDim2.new(defaultSize.X.Scale, defaultSize.X.Offset - 5, defaultSize.Y.Scale, defaultSize.Y.Offset - 5)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(defaultSize.X.Scale, defaultSize.X.Offset + 8, defaultSize.Y.Scale, defaultSize.Y.Offset + 8)
        }):Play()
    end)
end

-- Apply bouncy anims to buttons
local buttons = {spinButton, shopBtn, homeBtn, eggsBtn, storeBtn, inventoryBtn, shopClose, eggsClose, storeClose, invClose}

for _, btn in pairs(buttons) do
    applyBounceAnimation(btn)
end

-- Button click logic
shopBtn.Activated:Connect(function() openPanel(shopPanel) end)
eggsBtn.Activated:Connect(function() openPanel(eggsPanel) end)
storeBtn.Activated:Connect(function() openPanel(storePanel) end)
inventoryBtn.Activated:Connect(function() 
    updateInventoryContent()
    openPanel(invPanel) 
end)

homeBtn.Activated:Connect(function()
    print("Teleporting Player to their Base...")
    -- Close any open panels
    if activePanel then closePanel(activePanel) end
end)

local function updateSpinButtonVisibility()
    if runesValue and runesValue.Value > 0 then
        spinButton.Visible = true
    else
        spinButton.Visible = false
    end
end

if runesValue then
    updateSpinButtonVisibility()
    runesValue.Changed:Connect(updateSpinButtonVisibility)
end

local MYTHICALS = {
    "🐉 Dragon", "🦄 Unicorn", "🦅 Griffin", "🧜‍♀️ Mermaid", "🧞 Genie", "🧟 Zombie", "🦊 Kitsune", "🐺 Fenrir"
}

local rouletteOverlay = Instance.new("Frame")
rouletteOverlay.Name = "RouletteOverlay"
rouletteOverlay.Size = UDim2.new(1, 0, 1, 0)
rouletteOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
rouletteOverlay.BackgroundTransparency = 0.5
rouletteOverlay.Visible = false
rouletteOverlay.ZIndex = 100
rouletteOverlay.Parent = mainHUD

local rouletteText = Instance.new("TextLabel")
rouletteText.Size = UDim2.new(0, 400, 0, 200)
rouletteText.AnchorPoint = Vector2.new(0.5, 0.5)
rouletteText.Position = UDim2.new(0.5, 0, 0.5, 0)
rouletteText.BackgroundTransparency = 1
rouletteText.Text = "SPINNING..."
rouletteText.TextColor3 = Color3.fromRGB(255, 255, 255)
rouletteText.Font = Enum.Font.FredokaOne
rouletteText.TextScaled = true
rouletteText.ZIndex = 101
rouletteText.Parent = rouletteOverlay

local overlayStroke = Instance.new("UIStroke")
overlayStroke.Thickness = 4
overlayStroke.Color = Color3.fromRGB(0, 0, 0)
overlayStroke.Parent = rouletteText

local isSpinning = false
spinButton.Activated:Connect(function()
    if isSpinning then return end
    isSpinning = true
    
    rouletteOverlay.Visible = true
    rouletteText.Text = "SPINNING..."
    rouletteText.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local success, result = nil, nil
    task.spawn(function()
        success, result = SpinRemote:InvokeServer()
    end)
    
    -- Visual roulette cycling
    local ticks = 0
    while result == nil do
        rouletteText.Text = MYTHICALS[math.random(1, #MYTHICALS)]
        task.wait(0.05)
        ticks += 1
        if ticks > 100 then break end -- failsafe
    end
    
    if success then
        -- Slow down effect
        for i = 1, 10 do
            rouletteText.Text = MYTHICALS[math.random(1, #MYTHICALS)]
            task.wait(0.05 + (i * 0.02))
        end
        
        -- Land on result
        rouletteText.Text = result .. "!"
        rouletteText.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold color
        
        -- Pop animation
        TweenService:Create(rouletteText, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 600, 0, 300)
        }):Play()
        
        updateInventoryContent()
    else
        rouletteText.Text = "Failed!"
        rouletteText.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
    
    task.wait(3)
    
    -- Reset
    TweenService:Create(rouletteText, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 400, 0, 200)
    }):Play()
    rouletteOverlay.Visible = false
    isSpinning = false
end)

-- 6. Background Music (Simulator Style)
local SoundService = game:GetService("SoundService")

local bgm = Instance.new("Sound")
bgm.Name = "SimulatorBGM"
bgm.SoundId = "rbxassetid://14145627474" -- Valid Phonk Audio ID
bgm.Looped = true
bgm.Volume = 0.5
bgm.Parent = SoundService

-- Wait a brief moment to ensure loading screen covers any pop-ins, then play
task.spawn(function()
    task.wait(1)
    bgm:Play()
end)
