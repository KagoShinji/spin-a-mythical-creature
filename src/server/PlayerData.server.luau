local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Network = require(Shared:WaitForChild("Network"))

local BuyItemRemote = Network.getFunction("BuyItem")
local SpinRemote = Network.getFunction("Spin")

local SHOP_ITEMS = {
    ["Basic Rune"] = {price = 100, currency = "Coins", itemType = "Rune", id = "Basic"},
    ["Rare Rune"] = {price = 500, currency = "Coins", itemType = "Rune", id = "Rare"},
}

local MYTHICALS = {
    "🐉 Dragon", "🦄 Unicorn", "🦅 Griffin", "🧜‍♀️ Mermaid", "🧞 Genie", "🧟 Zombie", "🦊 Kitsune", "🐺 Fenrir"
}

-- Initialize Player Data
local function onPlayerAdded(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 5000 -- Give starting money
    coins.Parent = leaderstats

    local inventory = Instance.new("Folder")
    inventory.Name = "Inventory"
    inventory.Parent = player

    local runes = Instance.new("IntValue")
    runes.Name = "Runes"
    runes.Value = 0
    runes.Parent = inventory

    local mythicals = Instance.new("Folder")
    mythicals.Name = "Mythicals"
    mythicals.Parent = inventory
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Ensure players already in game when script loads are also processed
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

-- Handle Shop Purchases
BuyItemRemote.OnServerInvoke = function(player, itemName)
    local itemData = SHOP_ITEMS[itemName]
    if not itemData then
        return false, "Item not found!"
    end

    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return false, "Data error!" end

    local coins = leaderstats:FindFirstChild("Coins")
    if not coins then return false, "Currency error!" end

    if coins.Value >= itemData.price then
        coins.Value -= itemData.price
        
        -- Add to inventory
        local inventory = player:FindFirstChild("Inventory")
        if inventory then
            if itemData.itemType == "Rune" then
                local runes = inventory:FindFirstChild("Runes")
                if runes then
                    runes.Value += 1
                end
                
                local backpack = player:FindFirstChildOfClass("Backpack")
                if backpack then
                    local storedTool = ServerStorage:FindFirstChild(itemName)
                    local tool
                    if storedTool and storedTool:IsA("Tool") then
                        print("[DEBUG] Found custom tool in ServerStorage for: " .. itemName)
                        tool = storedTool:Clone()
                    else
                        print("[DEBUG] FAILED to find custom tool in ServerStorage! Using invisible fallback for: " .. itemName)
                        -- Fallback if model not found
                        tool = Instance.new("Tool")
                        tool.Name = itemName
                        tool.RequiresHandle = false
                    end
                    tool.Parent = backpack
                    
                    -- Equip it automatically
                    local character = player.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:EquipTool(tool)
                        end
                    end
                end
            end
        end
        return true, "Successfully purchased " .. itemName
    else
        return false, "Not enough " .. itemData.currency
    end
end

-- Handle Spinning
SpinRemote.OnServerInvoke = function(player)
    local inventory = player:FindFirstChild("Inventory")
    if not inventory then return false, "No inventory found" end

    local runes = inventory:FindFirstChild("Runes")
    if not runes or runes.Value <= 0 then
        return false, "No runes to spin!"
    end

    -- Deduct 1 Rune
    runes.Value -= 1
    
    -- Try to find and remove a Rune tool from Backpack or Character
    local runeTool = nil
    local backpack = player:FindFirstChildOfClass("Backpack")
    
    local function findRuneTool(container)
        if not container then return nil end
        -- Check for custom tools or fallback to generic
        local t = container:FindFirstChild("Basic Rune")
        if not t then t = container:FindFirstChild("Rare Rune") end
        if not t then t = container:FindFirstChild("🔮 Rune") end
        return t
    end
    
    runeTool = findRuneTool(backpack)
    if not runeTool and player.Character then
        runeTool = findRuneTool(player.Character)
    end
    
    if runeTool then
        runeTool:Destroy()
    end

    -- Select random mythical
    local chosenMythical = MYTHICALS[math.random(1, #MYTHICALS)]

    -- Add to player's mythicals
    local mythicalsFolder = inventory:FindFirstChild("Mythicals")
    if mythicalsFolder then
        local newMythical = Instance.new("StringValue")
        newMythical.Name = chosenMythical
        newMythical.Value = chosenMythical
        newMythical.Parent = mythicalsFolder
    end
    
    -- Give physical tool to player
    if backpack then
        local storedTool = ServerStorage:FindFirstChild(chosenMythical)
        
        -- Fallback: try finding the tool without the emoji prefix (e.g. "Dragon" instead of "🐉 Dragon")
        if not storedTool then
            local parts = string.split(chosenMythical, " ")
            if #parts > 1 then
                local cleanName = table.concat(parts, " ", 2)
                storedTool = ServerStorage:FindFirstChild(cleanName)
            end
        end

        local tool
        if storedTool and storedTool:IsA("Tool") then
            print("[DEBUG] Found custom mythical tool in ServerStorage for: " .. chosenMythical)
            tool = storedTool:Clone()
        else
            print("[DEBUG] FAILED to find custom mythical tool in ServerStorage! Using invisible fallback for: " .. chosenMythical)
            tool = Instance.new("Tool")
            tool.Name = chosenMythical
            tool.RequiresHandle = false
        end
        tool.Parent = backpack
    end

    return true, chosenMythical
end
