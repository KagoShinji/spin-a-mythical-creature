local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Network = require(Shared:WaitForChild("Network"))
local RuneConfig = require(Shared:WaitForChild("RuneConfig"))

local BuyItemRemote = Network.getFunction("BuyItem")
local SpinRemote = Network.getFunction("Spin")
local ClaimBPRemote = Network.getFunction("ClaimBattlepassReward")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHUD = playerGui:WaitForChild("MainHUD")
local backpack = player:WaitForChild("Backpack")

pcall(function()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)

-- Wait for data to initialize
local leaderstats = player:WaitForChild("leaderstats", 10)
local coinsValue = leaderstats and leaderstats:WaitForChild("Coins", 5)

local inventoryData = player:WaitForChild("Inventory", 10)
local runesValue = inventoryData and inventoryData:WaitForChild("Runes", 5)
local mythicalsFolder = inventoryData and inventoryData:WaitForChild("Mythicals", 5)

local bpLevelValue = leaderstats and leaderstats:WaitForChild("BP_Level", 5)
local battlepassFolder = inventoryData and inventoryData:WaitForChild("Battlepass", 5)
local bpXPValue = battlepassFolder and battlepassFolder:WaitForChild("BP_XP", 5)
local bpClaimedFolder = battlepassFolder and battlepassFolder:WaitForChild("Claimed", 5)

local function formatAbbreviated(value)
    local v = tonumber(value)
    if not v then return "0" end
    if v < 1000000 then return tostring(v) end
    
    local formatted = tostring(v)
    if v >= 1e9 then
        formatted = string.format("%.2fb", v / 1e9)
    else
        formatted = string.format("%.2fm", v / 1e6)
    end
    
    formatted = formatted:gsub("%.00([mb])", "%1")
    formatted = formatted:gsub("%.0([mb])", "%1")
    formatted = formatted:gsub("(%..-)0+([mb])", "%1%2")
    formatted = formatted:gsub("%.([mb])", "%1")
    return formatted
end

-- Layout and Theme Setup
local function applyLegoTheme(element, color, cornerRadius, hasStroke)
    element.BackgroundColor3 = color
    element.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius)
    corner.Parent = element
    
    local h, s, v = color:ToHSV()
    local darkerColor = Color3.fromHSV(h, s, math.max(0, v - 0.25))
    local lighterColor = Color3.fromHSV(h, math.max(0, s - 0.15), math.min(1, v + 0.15))

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, lighterColor),
        ColorSequenceKeypoint.new(1, darkerColor)
    })
    gradient.Rotation = 90
    gradient.Parent = element
    
    if element:IsA("GuiObject") and not element:IsA("ScrollingFrame") then
        local shine = Instance.new("Frame")
        shine.Name = "PremiumShine"
        shine.Size = UDim2.new(1, -6, 0.35, 0)
        shine.Position = UDim2.new(0, 3, 0, 3)
        shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        shine.BackgroundTransparency = 0.8
        shine.BorderSizePixel = 0
        shine.ZIndex = element.ZIndex + 1
        shine.Parent = element

        local shineCorner = Instance.new("UICorner")
        shineCorner.CornerRadius = UDim.new(0, math.max(0, cornerRadius - 3))
        shineCorner.Parent = shine
    end
    
    if hasStroke then
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 3
        stroke.Color = Color3.fromRGB(20, 20, 20)
        stroke.Transparency = 0.4
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
        textStroke.Transparency = 0.3
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

local runeOddsButton = Instance.new("TextButton")
runeOddsButton.Name = "RuneOddsButton"
runeOddsButton.AnchorPoint = Vector2.new(0.5, 0.5)
runeOddsButton.Position = UDim2.new(1, -5, 0, 5)
runeOddsButton.Size = UDim2.new(0, 36, 0, 36)
runeOddsButton.Text = "?"
runeOddsButton.Visible = false
runeOddsButton.ZIndex = 10
applyLegoTheme(runeOddsButton, Color3.fromRGB(255, 210, 0), 18, true)
runeOddsButton.Parent = spinContainer

local runeOddsPanel = Instance.new("Frame")
runeOddsPanel.Name = "RuneOddsPanel"
runeOddsPanel.AnchorPoint = Vector2.new(0, 1)
runeOddsPanel.Position = UDim2.new(1, 20, 0, 20)
runeOddsPanel.Size = UDim2.new(0, 380, 0, 260)
runeOddsPanel.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
runeOddsPanel.Visible = false
runeOddsPanel.ZIndex = 90
applyLegoTheme(runeOddsPanel, Color3.fromRGB(245, 245, 245), 16, true)
runeOddsPanel.Parent = spinContainer

local runeOddsTitle = Instance.new("TextLabel")
runeOddsTitle.Name = "Title"
runeOddsTitle.Size = UDim2.new(1, -50, 0, 40)
runeOddsTitle.Position = UDim2.new(0, 10, 0, 8)
runeOddsTitle.BackgroundTransparency = 1
runeOddsTitle.Text = "Rune Odds"
runeOddsTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
runeOddsTitle.Font = Enum.Font.FredokaOne
runeOddsTitle.TextScaled = true
runeOddsTitle.ZIndex = 91
runeOddsTitle.Parent = runeOddsPanel

local closeOddsBtn = Instance.new("TextButton")
closeOddsBtn.Name = "CloseButton"
closeOddsBtn.AnchorPoint = Vector2.new(1, 0)
closeOddsBtn.Position = UDim2.new(1, -8, 0, 8)
closeOddsBtn.Size = UDim2.new(0, 32, 0, 32)
closeOddsBtn.Text = "X"
closeOddsBtn.ZIndex = 92
applyLegoTheme(closeOddsBtn, Color3.fromRGB(255, 60, 60), 8, true)
closeOddsBtn.Parent = runeOddsPanel

closeOddsBtn.Activated:Connect(function()
    runeOddsPanel.Visible = false
end)

local runeOddsScroll = Instance.new("ScrollingFrame")
runeOddsScroll.Name = "OddsScroll"
runeOddsScroll.Size = UDim2.new(1, -20, 1, -60)
runeOddsScroll.Position = UDim2.new(0, 10, 0, 50)
runeOddsScroll.BackgroundTransparency = 1
runeOddsScroll.BorderSizePixel = 0
runeOddsScroll.ScrollBarThickness = 6
runeOddsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
runeOddsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
runeOddsScroll.ZIndex = 91
runeOddsScroll.Parent = runeOddsPanel

local runeOddsLayout = Instance.new("UIListLayout")
runeOddsLayout.Padding = UDim.new(0, 6)
runeOddsLayout.Parent = runeOddsScroll

local function clearRuneOddsRows()
    for _, child in ipairs(runeOddsScroll:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

local function icon(codepoint)
    return utf8.char(codepoint)
end

local ICONS = {
    backpack = icon(0x1F392),
    cart = icon(0x1F6D2),
    coin = "$",
    diamond = icon(0x1F48E),
    rune = icon(0x1F52E),
}

local function addButtonLogo(button, logoText, logoColor)
    button.Text = ""
    button.ClipsDescendants = false

    local shine = Instance.new("Frame")
    shine.Name = "LogoShine"
    shine.AnchorPoint = Vector2.new(0.5, 0.5)
    shine.Position = UDim2.new(0.5, -5, 0.42, -4)
    shine.Size = UDim2.new(0.58, 0, 0.42, 0)
    shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shine.BackgroundTransparency = 0.72
    shine.BorderSizePixel = 0
    shine.ZIndex = button.ZIndex + 1
    shine.Parent = button

    local shineCorner = Instance.new("UICorner")
    shineCorner.CornerRadius = UDim.new(1, 0)
    shineCorner.Parent = shine

    local logo = Instance.new("TextLabel")
    logo.Name = "Logo"
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Position = UDim2.new(0.5, 0, 0.5, 1)
    logo.Size = UDim2.new(0.82, 0, 0.82, 0)
    logo.BackgroundTransparency = 1
    logo.Font = Enum.Font.FredokaOne
    logo.Text = logoText
    logo.TextColor3 = logoColor
    logo.TextScaled = true
    logo.ZIndex = button.ZIndex + 2
    logo.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    stroke.Parent = logo
end

local function addCurrencyLogo(label, currencyType)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Right
    label.Text = "0"
    label.ClipsDescendants = false
    label.AutomaticSize = Enum.AutomaticSize.X
    label.TextScaled = false
    label.TextSize = 26
    label.Font = Enum.Font.FredokaOne
    label.TextColor3 = Color3.fromRGB(255, 255, 255)

    local labelStroke = Instance.new("UIStroke")
    labelStroke.Thickness = 2
    labelStroke.Color = Color3.fromRGB(0, 0, 0)
    labelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    labelStroke.Parent = label

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 16)
    padding.PaddingRight = UDim.new(0, 16)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = label

    local badge = Instance.new("Frame")
    badge.Name = "CurrencyLogo"
    badge.AnchorPoint = Vector2.new(1, 0.5)
    badge.Position = UDim2.new(0, -14, 0.5, 0)
    badge.Size = UDim2.new(0, 42, 0, 42)
    badge.ZIndex = label.ZIndex + 2
    badge.Parent = label

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(1, 0)
    badgeCorner.Parent = badge
    
    local badgeStroke = Instance.new("UIStroke")
    badgeStroke.Thickness = 2
    badgeStroke.Color = Color3.fromRGB(0, 0, 0)
    badgeStroke.Parent = badge

    local iconLabel = Instance.new("TextLabel")
    iconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    iconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    iconLabel.Size = UDim2.new(0.7, 0, 0.7, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.FredokaOne
    iconLabel.TextScaled = true
    iconLabel.ZIndex = badge.ZIndex + 1
    iconLabel.Parent = badge

    if currencyType == "Coin" then
        badge.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 230, 100)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 140, 0))
        })
        gradient.Rotation = 45
        gradient.Parent = badge
        
        iconLabel.Text = ICONS.coin
        iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        local iconStroke = Instance.new("UIStroke")
        iconStroke.Thickness = 2
        iconStroke.Color = Color3.fromRGB(150, 80, 0)
        iconStroke.Parent = iconLabel
    else
        badge.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 220, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 255))
        })
        gradient.Rotation = 45
        gradient.Parent = badge
        
        iconLabel.Text = ICONS.diamond
        iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    local shine = Instance.new("Frame")
    shine.Size = UDim2.new(0.8, 0, 0.4, 0)
    shine.Position = UDim2.new(0.1, 0, 0.05, 0)
    shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shine.BackgroundTransparency = 0.6
    shine.BorderSizePixel = 0
    shine.ZIndex = badge.ZIndex + 1
    shine.Parent = badge
    
    local shineCorner = Instance.new("UICorner")
    shineCorner.CornerRadius = UDim.new(1, 0)
    shineCorner.Parent = shine
end

local function formatPercent(value)
    return string.format("%.2f%%", value)
end

local function getEquippedRuneTool()
    local character = player.Character
    if not character then
        return nil
    end

    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") and RuneConfig.isRuneName(child.Name) then
            return child
        end
    end

    return nil
end

local function updateSpinButtonVisibility()
    if runesValue and runesValue.Value > 0 and getEquippedRuneTool() then
        spinButton.Visible = true
    else
        spinButton.Visible = false
    end
end

local function refreshRuneOddsPanel()
    local runeTool = getEquippedRuneTool()
    if not runeTool then
        runeOddsButton.Visible = false
        runeOddsPanel.Visible = false
        return
    end

    local runeName = runeTool.Name
    local odds = RuneConfig.getRuneOdds(runeName)
    if not odds then
        runeOddsButton.Visible = false
        runeOddsPanel.Visible = false
        return
    end

    runeOddsButton.Visible = true
    clearRuneOddsRows()
    
    local runeData = RuneConfig.getRuneData(runeName)
    local luckText = (runeData and runeData.luckMultiplier) and (" (x" .. runeData.luckMultiplier .. " Luck)") or ""
    runeOddsTitle.Text = runeName .. luckText

    for _, rarityEntry in ipairs(odds) do
        local row = Instance.new("TextLabel")
        row.BackgroundTransparency = 1
        row.Size = UDim2.new(1, -10, 0, 0)
        row.AutomaticSize = Enum.AutomaticSize.Y
        row.TextWrapped = true
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.TextYAlignment = Enum.TextYAlignment.Top
        row.Font = Enum.Font.FredokaOne
        row.TextScaled = false
        row.TextSize = 16
        row.TextColor3 = rarityEntry.color or Color3.fromRGB(255, 255, 255)
        row.ZIndex = 91

        local creaturesText = table.concat(rarityEntry.creatures, ", ")
        row.Text = string.format("%s (%s)\n  ↳ %s Each: %s\n", 
            rarityEntry.rarity, formatPercent(rarityEntry.totalChance), 
            formatPercent(rarityEntry.perCreature), creaturesText)
        
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1.5
        stroke.Color = Color3.fromRGB(0, 0, 0)
        stroke.Parent = row

        row.Parent = runeOddsScroll
    end
end

runeOddsButton.Activated:Connect(function()
    if not runeOddsButton.Visible then
        return
    end

    runeOddsPanel.Visible = not runeOddsPanel.Visible
    if runeOddsPanel.Visible then
        refreshRuneOddsPanel()
    end
end)

local function bindRuneVisibility(character)
    if not character then
        return
    end

    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and RuneConfig.isRuneName(child.Name) then
            updateSpinButtonVisibility()
            refreshRuneOddsPanel()
        end
    end)

    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and RuneConfig.isRuneName(child.Name) then
            updateSpinButtonVisibility()
            refreshRuneOddsPanel()
        end
    end)

    updateSpinButtonVisibility()
    task.defer(refreshRuneOddsPanel)
end

if player.Character then
    bindRuneVisibility(player.Character)
end

player.CharacterAdded:Connect(bindRuneVisibility)

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
coinsLabel.Size = UDim2.new(0, 0, 0, 42)
coinsLabel.Text = coinsValue and formatAbbreviated(coinsValue.Value) or "0"
addCurrencyLogo(coinsLabel, "Coin")

if coinsValue then
    coinsValue.Changed:Connect(function(newVal)
        coinsLabel.Text = formatAbbreviated(newVal)
    end)
end

local gemsLabel = resourceContainer:WaitForChild("GemsLabel")
gemsLabel.Size = UDim2.new(0, 0, 0, 42)
gemsLabel.Text = "50"
addCurrencyLogo(gemsLabel, "Gem")

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
leftMenu.Size = UDim2.new(0, 80, 0, 300) -- Expanded to hold 3 buttons
leftMenu.BackgroundTransparency = 1

local leftListLayout = Instance.new("UIListLayout")
leftListLayout.Padding = UDim.new(0, 15)
leftListLayout.SortOrder = Enum.SortOrder.LayoutOrder
leftListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
leftListLayout.Parent = leftMenu

local storeBtn = leftMenu:WaitForChild("StoreButton")
storeBtn.Size = UDim2.new(1, 0, 0, 80)
storeBtn.LayoutOrder = 1
applyLegoTheme(storeBtn, Color3.fromRGB(200, 0, 255), 16, true)
addButtonLogo(storeBtn, ICONS.cart, Color3.fromRGB(255, 255, 255))

local bpWidget = Instance.new("TextButton")
bpWidget.Name = "GamepassWidget"
bpWidget.Size = UDim2.new(1, 0, 0, 80)
bpWidget.LayoutOrder = 2
bpWidget.Text = ""
applyLegoTheme(bpWidget, Color3.fromRGB(255, 215, 0), 12, true) -- Golden ticket background
bpWidget.Parent = leftMenu

local bpIcon = Instance.new("TextLabel")
bpIcon.Size = UDim2.new(1, 0, 0.6, 0)
bpIcon.Position = UDim2.new(0, 0, 0, 5)
bpIcon.BackgroundTransparency = 1
bpIcon.Text = "🎫"
bpIcon.TextScaled = true
bpIcon.Parent = bpWidget

local bpLabel = Instance.new("TextLabel")
bpLabel.Size = UDim2.new(1, 0, 0.3, 0)
bpLabel.Position = UDim2.new(0, 0, 0.65, 0)
bpLabel.BackgroundTransparency = 1
bpLabel.Text = "PASS"
bpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
bpLabel.Font = Enum.Font.FredokaOne
bpLabel.TextScaled = true
bpLabel.Parent = bpWidget

local inventoryBtn = leftMenu:WaitForChild("InventoryButton")
inventoryBtn.Size = UDim2.new(1, 0, 0, 80)
inventoryBtn.LayoutOrder = 3
applyLegoTheme(inventoryBtn, Color3.fromRGB(0, 200, 150), 16, true)
addButtonLogo(inventoryBtn, ICONS.backpack, Color3.fromRGB(255, 255, 255))



-- Custom Hotbar
local hotbarFrame = Instance.new("Frame")
hotbarFrame.Name = "JollyHotbar"
hotbarFrame.AnchorPoint = Vector2.new(0.5, 1)
hotbarFrame.Position = UDim2.new(0.5, 0, 1, -14)
hotbarFrame.Size = UDim2.new(0, 620, 0, 78)
hotbarFrame.BackgroundTransparency = 1
hotbarFrame.Parent = mainHUD

local hotbarLayout = Instance.new("UIListLayout")
hotbarLayout.FillDirection = Enum.FillDirection.Horizontal
hotbarLayout.Padding = UDim.new(0, 8)
hotbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
hotbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
hotbarLayout.Parent = hotbarFrame

local hotbarSlots = {}
local hotbarTools = {}
local equippedTool = nil

local function getToolIcon(tool)
    if RuneConfig.isRuneName(tool.Name) then
        local runeData = RuneConfig.getRuneData(tool.Name)
        return runeData and runeData.icon or ICONS.rune
    end

    return tool:GetAttribute("Icon") or ICONS.backpack
end

local function updateSlotColor(slot, color)
    slot.BackgroundColor3 = color
    local gradient = slot:FindFirstChild("UIGradient")
    if gradient then
        local h, s, v = color:ToHSV()
        local darkerColor = Color3.fromHSV(h, s, math.max(0, v - 0.25))
        local lighterColor = Color3.fromHSV(h, math.max(0, s - 0.15), math.min(1, v + 0.15))
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, lighterColor),
            ColorSequenceKeypoint.new(1, darkerColor)
        })
    end
end

local function styleHotbarSlot(slot)
    slot.AutoButtonColor = false
    slot.Text = ""
    slot.BackgroundColor3 = Color3.fromRGB(255, 235, 92)
    slot.BorderSizePixel = 0
    slot.ClipsDescendants = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = slot

    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Parent = slot

    local shine = Instance.new("Frame")
    shine.Name = "PremiumShine"
    shine.Size = UDim2.new(1, -6, 0.35, 0)
    shine.Position = UDim2.new(0, 3, 0, 3)
    shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shine.BackgroundTransparency = 0.8
    shine.BorderSizePixel = 0
    shine.ZIndex = slot.ZIndex + 1
    shine.Parent = slot

    local shineCorner = Instance.new("UICorner")
    shineCorner.CornerRadius = UDim.new(0, 11)
    shineCorner.Parent = shine

    updateSlotColor(slot, Color3.fromRGB(255, 235, 92))

    local stroke = Instance.new("UIStroke")
    stroke.Name = "SlotStroke"
    stroke.Thickness = 4
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Parent = slot

    local scale = Instance.new("UIScale")
    scale.Name = "SlotScale"
    scale.Scale = 1
    scale.Parent = slot

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.AnchorPoint = Vector2.new(0.5, 0)
    iconLabel.Position = UDim2.new(0.5, 0, 0, 5)
    iconLabel.Size = UDim2.new(0, 42, 0, 34)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.FredokaOne
    iconLabel.Text = "?"
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.TextScaled = true
    iconLabel.ZIndex = slot.ZIndex + 2
    iconLabel.Parent = slot

    local iconStroke = Instance.new("UIStroke")
    iconStroke.Thickness = 2
    iconStroke.Color = Color3.fromRGB(0, 0, 0)
    iconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    iconStroke.Parent = iconLabel

    local keyLabel = Instance.new("TextLabel")
    keyLabel.Name = "Key"
    keyLabel.Position = UDim2.new(0, 5, 0, 4)
    keyLabel.Size = UDim2.new(0, 18, 0, 18)
    keyLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    keyLabel.BorderSizePixel = 0
    keyLabel.Font = Enum.Font.FredokaOne
    keyLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    keyLabel.TextScaled = true
    keyLabel.ZIndex = slot.ZIndex + 3
    keyLabel.Parent = slot

    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(1, 0)
    keyCorner.Parent = keyLabel

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.AnchorPoint = Vector2.new(0.5, 1)
    nameLabel.Position = UDim2.new(0.5, 0, 1, -5)
    nameLabel.Size = UDim2.new(1, -8, 0, 24)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.FredokaOne
    nameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextScaled = true
    nameLabel.TextWrapped = true
    nameLabel.ZIndex = slot.ZIndex + 2
    nameLabel.Parent = slot
end

local nextSortId = 1
local function getOrderedTools()
    local tools = {}

    local function addToolsFrom(container)
        if not container then return end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Tool") then
                if not child:GetAttribute("HotbarSortId") then
                    child:SetAttribute("HotbarSortId", nextSortId)
                    nextSortId = nextSortId + 1
                end
                table.insert(tools, child)
            end
        end
    end

    addToolsFrom(player.Character)
    addToolsFrom(backpack)

    table.sort(tools, function(a, b)
        if a.Name == b.Name then
            return (a:GetAttribute("HotbarSortId") or 0) < (b:GetAttribute("HotbarSortId") or 0)
        end
        return a.Name < b.Name
    end)

    return tools
end

local function updateHotbarSelection()
    local character = player.Character
    equippedTool = character and character:FindFirstChildOfClass("Tool") or nil

    for index, slot in ipairs(hotbarSlots) do
        local tool = hotbarTools[index]
        local stroke = slot:FindFirstChild("SlotStroke")
        local selected = tool and tool == equippedTool
        
        local targetColor = selected and Color3.fromRGB(255, 148, 58) or Color3.fromRGB(255, 235, 92)
        updateSlotColor(slot, targetColor)
        
        if stroke then
            stroke.Thickness = selected and 6 or 4
        end
    end
end

local function equipHotbarTool(index)
    local tool = hotbarTools[index]
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not tool or not humanoid then
        return
    end

    if tool == equippedTool then
        humanoid:UnequipTools()
    else
        humanoid:EquipTool(tool)
    end

    task.defer(updateHotbarSelection)
end

local function refreshHotbar()
    hotbarTools = getOrderedTools()

    for index, slot in ipairs(hotbarSlots) do
        local tool = hotbarTools[index]
        local iconLabel = slot:FindFirstChild("Icon")
        local keyLabel = slot:FindFirstChild("Key")
        local nameLabel = slot:FindFirstChild("Name")

        slot.Visible = tool ~= nil
        if keyLabel then
            keyLabel.Text = tostring(index)
        end
        if tool then
            if iconLabel then
                iconLabel.Text = getToolIcon(tool)
            end
            if nameLabel then
                nameLabel.Text = tool.Name
            end
        end
    end

    updateHotbarSelection()
end

for index = 1, 8 do
    local slot = Instance.new("TextButton")
    slot.Name = "Slot" .. index
    slot.Size = UDim2.new(0, 70, 0, 66)
    slot.Visible = false
    styleHotbarSlot(slot)
    slot.Parent = hotbarFrame
    hotbarSlots[index] = slot

    slot.Activated:Connect(function()
        equipHotbarTool(index)
    end)

    slot.MouseEnter:Connect(function()
        local scale = slot:FindFirstChild("SlotScale")
        if scale then
            TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Scale = 1.1,
            }):Play()
        end
        TweenService:Create(slot, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Rotation = index % 2 == 0 and 3 or -3,
        }):Play()
    end)

    slot.MouseLeave:Connect(function()
        local scale = slot:FindFirstChild("SlotScale")
        if scale then
            TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Scale = 1,
            }):Play()
        end
        TweenService:Create(slot, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Rotation = 0,
        }):Play()
    end)
end

backpack.ChildAdded:Connect(refreshHotbar)
backpack.ChildRemoved:Connect(refreshHotbar)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    local keyValue = input.KeyCode.Value - Enum.KeyCode.One.Value + 1
    if keyValue >= 1 and keyValue <= #hotbarSlots then
        equipHotbarTool(keyValue)
    end
end)

local function bindHotbarCharacter(character)
    if not character then
        return
    end

    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            refreshHotbar()
        end
    end)

    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            refreshHotbar()
        end
    end)

    refreshHotbar()
end

if player.Character then
    bindHotbarCharacter(player.Character)
end

player.CharacterAdded:Connect(bindHotbarCharacter)
task.defer(refreshHotbar)

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

local function setupGamepassPanel()
    local panel = Instance.new("Frame")
    panel.Name = "GamepassPanel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    panel.Size = UDim2.new(0, 0, 0, 0)
    panel.Visible = false
    applyLegoTheme(panel, Color3.fromRGB(123, 44, 191), 16, true) -- Bright Purple background
    panel.Parent = panelsFolder
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.Position = UDim2.new(1, -10, 0, 10)
    closeBtn.Size = UDim2.new(0, 50, 0, 50)
    closeBtn.Text = "X"
    closeBtn.ZIndex = 50
    applyLegoTheme(closeBtn, Color3.fromRGB(255, 50, 50), 12, true)
    closeBtn.Parent = panel

    -- Left Static Header Column
    local headerColumn = Instance.new("Frame")
    headerColumn.Size = UDim2.new(0, 200, 1, 0)
    headerColumn.BackgroundColor3 = Color3.fromRGB(90, 24, 154)
    headerColumn.BorderSizePixel = 0
    headerColumn.ZIndex = 10
    headerColumn.Parent = panel
    
    local goldTitle = Instance.new("TextLabel")
    goldTitle.Size = UDim2.new(0.9, 0, 0, 60)
    goldTitle.Position = UDim2.new(0.05, 0, 0.1, 0)
    goldTitle.BackgroundTransparency = 1
    goldTitle.Text = "GOLDEN\nPASS"
    goldTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    goldTitle.Font = Enum.Font.FredokaOne
    goldTitle.TextScaled = true
    goldTitle.ZIndex = 11
    goldTitle.Parent = headerColumn

    local freeTitle = Instance.new("TextLabel")
    freeTitle.Size = UDim2.new(0.9, 0, 0, 60)
    freeTitle.Position = UDim2.new(0.05, 0, 0.75, 0)
    freeTitle.BackgroundTransparency = 1
    freeTitle.Text = "FREE\nPASS"
    freeTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
    freeTitle.Font = Enum.Font.FredokaOne
    freeTitle.TextScaled = true
    freeTitle.ZIndex = 11
    freeTitle.Parent = headerColumn

    local bpLevelText = Instance.new("TextLabel")
    bpLevelText.Size = UDim2.new(0.9, 0, 0, 40)
    bpLevelText.Position = UDim2.new(0.05, 0, 0.4, 0)
    bpLevelText.BackgroundTransparency = 1
    bpLevelText.Text = "Level 1"
    bpLevelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    bpLevelText.Font = Enum.Font.FredokaOne
    bpLevelText.TextScaled = true
    bpLevelText.ZIndex = 11
    bpLevelText.Parent = headerColumn

    local xpBarBg = Instance.new("Frame")
    xpBarBg.Size = UDim2.new(0.8, 0, 0, 20)
    xpBarBg.Position = UDim2.new(0.1, 0, 0.5, 0)
    xpBarBg.BackgroundColor3 = Color3.fromRGB(40, 10, 80)
    xpBarBg.ZIndex = 11
    xpBarBg.Parent = headerColumn
    local xpBarBgCorner = Instance.new("UICorner")
    xpBarBgCorner.CornerRadius = UDim.new(1, 0)
    xpBarBgCorner.Parent = xpBarBg

    local xpBarFill = Instance.new("Frame")
    xpBarFill.Size = UDim2.new(0, 0, 1, 0)
    xpBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    xpBarFill.ZIndex = 12
    xpBarFill.Parent = xpBarBg
    local xpBarFillCorner = Instance.new("UICorner")
    xpBarFillCorner.CornerRadius = UDim.new(1, 0)
    xpBarFillCorner.Parent = xpBarFill

    if bpLevelValue and bpXPValue then
        local function updateXP()
            bpLevelText.Text = "Level " .. bpLevelValue.Value
            local reqXP = bpLevelValue.Value * 100
            if bpLevelValue.Value >= 60 then
                xpBarFill.Size = UDim2.new(1, 0, 1, 0)
                bpLevelText.Text = "MAX LEVEL"
            else
                local percent = math.clamp(bpXPValue.Value / reqXP, 0, 1)
                xpBarFill.Size = UDim2.new(percent, 0, 1, 0)
            end
        end
        bpLevelValue.Changed:Connect(updateXP)
        bpXPValue.Changed:Connect(updateXP)
        updateXP()
    end

    return panel, closeBtn, headerColumn
end

local bpPanel, bpClose, bpHeaderColumn = setupGamepassPanel()

local function buildBattlepassContent()
    local container = Instance.new("ScrollingFrame")
    container.Name = "ContentContainer"
    container.Position = UDim2.new(0, 200, 0, 0)
    container.Size = UDim2.new(1, -200, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 10
    container.CanvasSize = UDim2.new(0, 60 * 160, 0, 0)
    container.ScrollingDirection = Enum.ScrollingDirection.X
    container.Parent = bpPanel

    local centerLine = Instance.new("Frame")
    centerLine.Size = UDim2.new(1, 0, 0, 10)
    centerLine.Position = UDim2.new(0, 0, 0.5, -5)
    centerLine.BackgroundColor3 = Color3.fromRGB(60, 9, 108)
    centerLine.BorderSizePixel = 0
    centerLine.ZIndex = 0
    centerLine.Parent = container

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 150, 1, 0)
    gridLayout.CellPadding = UDim2.new(0, 10, 0, 0)
    gridLayout.FillDirection = Enum.FillDirection.Horizontal
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    gridLayout.Parent = container

    for level = 1, 60 do
        local colFrame = Instance.new("Frame")
        colFrame.BackgroundTransparency = 1
        colFrame.Parent = container

        local premBox = Instance.new("Frame")
        premBox.Size = UDim2.new(1, 0, 0.35, 0)
        premBox.Position = UDim2.new(0, 0, 0.1, 0)
        applyLegoTheme(premBox, Color3.fromRGB(180, 100, 255), 12, true)
        premBox.Parent = colFrame
        
        local premStroke = Instance.new("UIStroke")
        premStroke.Color = Color3.fromRGB(100, 40, 180)
        premStroke.Thickness = 4
        premStroke.Parent = premBox

        local premIcon = Instance.new("TextLabel")
        premIcon.Size = UDim2.new(1, 0, 0.5, 0)
        premIcon.Position = UDim2.new(0, 0, 0.05, 0)
        premIcon.BackgroundTransparency = 1
        premIcon.Text = (level % 5 == 0) and "🔮" or "💎"
        premIcon.TextScaled = true
        premIcon.Parent = premBox
        
        local premText = Instance.new("TextLabel")
        premText.Size = UDim2.new(0.9, 0, 0.4, 0)
        premText.Position = UDim2.new(0.05, 0, 0.55, 0)
        premText.BackgroundTransparency = 1
        premText.Text = (level % 5 == 0) and "1x Rune" or formatAbbreviated(level * 50).." Gems"
        premText.TextColor3 = Color3.fromRGB(255, 255, 255)
        premText.Font = Enum.Font.FredokaOne
        premText.TextScaled = true
        premText.TextWrapped = true
        premText.Parent = premBox

        local levelNode = Instance.new("Frame")
        levelNode.Size = UDim2.new(0, 40, 0, 40)
        levelNode.AnchorPoint = Vector2.new(0.5, 0.5)
        levelNode.Position = UDim2.new(0.5, 0, 0.5, 0)
        levelNode.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        levelNode.ZIndex = 2
        levelNode.Parent = colFrame
        local nodeCorner = Instance.new("UICorner")
        nodeCorner.CornerRadius = UDim.new(1, 0)
        nodeCorner.Parent = levelNode
        
        local lvlText = Instance.new("TextLabel")
        lvlText.Size = UDim2.new(1, 0, 1, 0)
        lvlText.BackgroundTransparency = 1
        lvlText.Text = tostring(level)
        lvlText.TextColor3 = Color3.fromRGB(255, 255, 255)
        lvlText.Font = Enum.Font.FredokaOne
        lvlText.TextScaled = true
        lvlText.Parent = levelNode

        local freeBox = Instance.new("Frame")
        freeBox.Size = UDim2.new(1, 0, 0.35, 0)
        freeBox.Position = UDim2.new(0, 0, 0.55, 0)
        applyLegoTheme(freeBox, Color3.fromRGB(0, 150, 200), 12, true)
        freeBox.Parent = colFrame
        
        local freeStroke = Instance.new("UIStroke")
        freeStroke.Color = Color3.fromRGB(0, 80, 150)
        freeStroke.Thickness = 4
        freeStroke.Parent = freeBox

        local freeIcon = Instance.new("TextLabel")
        freeIcon.Size = UDim2.new(1, 0, 0.5, 0)
        freeIcon.Position = UDim2.new(0, 0, 0.05, 0)
        freeIcon.BackgroundTransparency = 1
        freeIcon.Text = "🪙"
        freeIcon.TextScaled = true
        freeIcon.Parent = freeBox

        local freeText = Instance.new("TextLabel")
        freeText.Size = UDim2.new(0.9, 0, 0.4, 0)
        freeText.Position = UDim2.new(0.05, 0, 0.55, 0)
        freeText.BackgroundTransparency = 1
        freeText.Text = formatAbbreviated(level * 1000) .. " Coins"
        freeText.TextColor3 = Color3.fromRGB(255, 255, 255)
        freeText.Font = Enum.Font.FredokaOne
        freeText.TextScaled = true
        freeText.TextWrapped = true
        freeText.Parent = freeBox

        local lockIcon = Instance.new("TextLabel")
        lockIcon.Size = UDim2.new(0, 40, 0, 40)
        lockIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        lockIcon.Position = UDim2.new(0.5, 0, 0.5, -25) -- Sit nicely above the node
        lockIcon.BackgroundTransparency = 1
        lockIcon.Text = "🔒"
        lockIcon.TextScaled = true
        lockIcon.ZIndex = 5
        lockIcon.Visible = true
        lockIcon.Parent = colFrame

        local function updateClaimBtn()
            if not bpLevelValue or not bpClaimedFolder then return end
            if bpClaimedFolder:FindFirstChild(tostring(level)) then
                levelNode.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                lockIcon.Text = "✅"
                lockIcon.Visible = true
            elseif bpLevelValue.Value >= level then
                levelNode.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
                lockIcon.Visible = false
            else
                levelNode.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
                lockIcon.Text = "🔒"
                lockIcon.Visible = true
            end
        end
        updateClaimBtn()
        if bpLevelValue then bpLevelValue.Changed:Connect(updateClaimBtn) end
        if bpClaimedFolder then bpClaimedFolder.ChildAdded:Connect(updateClaimBtn) end
        
        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.ZIndex = 10
        clickBtn.Parent = colFrame
        
        clickBtn.Activated:Connect(function()
            if bpLevelValue and bpLevelValue.Value >= level then
                if not (bpClaimedFolder and bpClaimedFolder:FindFirstChild(tostring(level))) then
                    ClaimBPRemote:InvokeServer(level)
                end
            end
        end)
    end
end
buildBattlepassContent()

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
        buyBtn.Text = ""
        
        local btnColor = isStore and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(50, 150, 255)
        if item.currency == "Coins" then
            btnColor = Color3.fromRGB(255, 190, 0)
        end
        applyLegoTheme(buyBtn, btnColor, 8, true)
        
        local contentFrame = Instance.new("Frame")
        contentFrame.BackgroundTransparency = 1
        contentFrame.Size = UDim2.new(1, 0, 1, 0)
        contentFrame.ZIndex = buyBtn.ZIndex + 1
        contentFrame.Parent = buyBtn
        
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 5)
        layout.Parent = contentFrame
        
        local iconText = nil
        if item.currency == "Coins" then iconText = ICONS.coin
        elseif item.currency == "Gems" then iconText = ICONS.diamond
        elseif isStore then iconText = "R$" end
        
        local iconLabel = nil
        if iconText then
            iconLabel = Instance.new("TextLabel")
            iconLabel.BackgroundTransparency = 1
            iconLabel.Size = UDim2.new(0, 0, 1, 0)
            iconLabel.AutomaticSize = Enum.AutomaticSize.X
            iconLabel.Font = Enum.Font.FredokaOne
            iconLabel.TextSize = 18
            iconLabel.Text = iconText
            iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            iconLabel.ZIndex = contentFrame.ZIndex + 1
            
            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 2
            stroke.Color = item.currency == "Coins" and Color3.fromRGB(150, 80, 0) or Color3.fromRGB(0, 0, 0)
            stroke.Parent = iconLabel
            iconLabel.Parent = contentFrame
        end
        
        local priceLabel = Instance.new("TextLabel")
        priceLabel.BackgroundTransparency = 1
        priceLabel.Size = UDim2.new(0, 0, 1, 0)
        priceLabel.AutomaticSize = Enum.AutomaticSize.X
        priceLabel.Font = Enum.Font.FredokaOne
        priceLabel.TextSize = 18
        priceLabel.Text = item.price
        priceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        priceLabel.ZIndex = contentFrame.ZIndex + 1
        
        local priceStroke = Instance.new("UIStroke")
        priceStroke.Thickness = 2
        priceStroke.Color = Color3.fromRGB(0, 0, 0)
        priceStroke.Parent = priceLabel
        priceLabel.Parent = contentFrame
        buyBtn.Parent = frame

        if item.isBuyable then
            local isProcessing = false
            buyBtn.Activated:Connect(function()
                if isProcessing then return end
                isProcessing = true
                
                priceLabel.Text = "..."
                if iconLabel then iconLabel.Visible = false end
                
                local success, msg = BuyItemRemote:InvokeServer(item.name)
                if success then
                    priceLabel.Text = "Bought!"
                    buyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
                else
                    priceLabel.Text = "Failed"
                    buyBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
                task.delay(1, function()
                    priceLabel.Text = item.price
                    if iconLabel then iconLabel.Visible = true end
                    buyBtn.BackgroundColor3 = btnColor
                    isProcessing = false
                end)
            end)
        end
    end
end

local function buildRuneShopItems()
    local items = {}
    for _, runeName in ipairs(RuneConfig.getAllRuneNames()) do
        local runeData = RuneConfig.getRuneData(runeName)
        if runeData then
            table.insert(items, {
                name = runeName,
                icon = runeData.icon,
                price = formatAbbreviated(runeData.price),
                currency = "Coins",
                isBuyable = true,
            })
        end
    end

    return items
end

-- 1. Shop Contents (In-game currency)
local runeShopItems = buildRuneShopItems()
table.insert(runeShopItems, {name = "Speed Potion", icon = "🧪", price = "50", currency = "Gems"})
createGridContent(shopPanel, runeShopItems, false)

-- 2. Eggs Contents (Hatching mythicals)
createGridContent(eggsPanel, {
    {name = "Forest Egg", icon = "🥚", price = "250", currency = "Coins"},
    {name = "Lava Egg", icon = "🌋", price = "1000", currency = "Coins"},
    {name = "Mythic Egg", icon = "🌌", price = "500", currency = "Gems"}
}, false)

-- 3. Store Contents (Robux/Gamepass items)
createGridContent(storePanel, {
    {name = "VIP Pass", icon = "👑", price = "399"},
    {name = "2x Luck", icon = "🍀", price = "150"},
    {name = "10,000 Coins", icon = "💰", price = "50"},
    {name = "Infinite Runes", icon = "♾️", price = "999"}
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
    if activePanel == panel then
        closePanel(panel)
        return
    end

    if activePanel then closePanel(activePanel) end
    
    activePanel = panel
    panel.Visible = true
    
    local targetWidth = panel.Name == "GamepassPanel" and 900 or 600
    local targetHeight = panel.Name == "GamepassPanel" and 500 or 450
    
    TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, targetWidth, 0, targetHeight)
    }):Play()
end

-- Close Button Events
shopClose.Activated:Connect(function() closePanel(shopPanel) end)
eggsClose.Activated:Connect(function() closePanel(eggsPanel) end)
storeClose.Activated:Connect(function() closePanel(storePanel) end)
invClose.Activated:Connect(function() closePanel(invPanel) end)
bpClose.Activated:Connect(function() closePanel(bpPanel) end)

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
local buttons = {spinButton, runeOddsButton, shopBtn, homeBtn, eggsBtn, storeBtn, inventoryBtn, shopClose, eggsClose, storeClose, invClose, bpWidget, bpClose}

for _, btn in pairs(buttons) do
    applyBounceAnimation(btn)
end

-- Button click logic
bpWidget.Activated:Connect(function() openPanel(bpPanel) end)
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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Backquote then
        if activePanel == invPanel then
            closePanel(invPanel)
        else
            updateInventoryContent()
            openPanel(invPanel)
        end
    end
end)

if runesValue then
    updateSpinButtonVisibility()
    runesValue.Changed:Connect(updateSpinButtonVisibility)
end

local ROULETTE_MYTHICALS = RuneConfig.getAllCreatureNames()

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
        rouletteText.Text = ROULETTE_MYTHICALS[math.random(1, #ROULETTE_MYTHICALS)]
        task.wait(0.05)
        ticks += 1
        if ticks > 100 then break end -- failsafe
    end
    
    if success then
        -- Slow down effect
        for i = 1, 10 do
            rouletteText.Text = ROULETTE_MYTHICALS[math.random(1, #ROULETTE_MYTHICALS)]
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
        rouletteText.Text = tostring(result or "Failed!")
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
