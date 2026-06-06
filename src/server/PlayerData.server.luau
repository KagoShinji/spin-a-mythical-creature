local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Network = require(Shared:WaitForChild("Network"))
local RuneConfig = require(Shared:WaitForChild("RuneConfig"))

local BuyItemRemote = Network.getFunction("BuyItem")
local SpinRemote = Network.getFunction("Spin")

local SHOP_ITEMS = {}
for itemName, itemData in pairs(RuneConfig.RUNE_DATA) do
    SHOP_ITEMS[itemName] = {
        price = itemData.price,
        currency = "Coins",
        itemType = "Rune",
        id = itemData.tier,
        runeTier = itemData.tier,
    }
end

-- Initialize Player Data
local function onPlayerAdded(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 5000
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

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

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

        local inventory = player:FindFirstChild("Inventory")
        if inventory and itemData.itemType == "Rune" then
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
                    tool = Instance.new("Tool")
                    tool.Name = itemName
                    tool.RequiresHandle = false
                end
                tool:SetAttribute("RuneTier", itemData.runeTier)
                tool.Parent = backpack

                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:EquipTool(tool)
                    end
                end
            end
        end
        return true, "Successfully purchased " .. itemName
    else
        return false, "Not enough " .. itemData.currency
    end
end

SpinRemote.OnServerInvoke = function(player)
    local inventory = player:FindFirstChild("Inventory")
    if not inventory then return false, "No inventory found" end

    local runes = inventory:FindFirstChild("Runes")
    if not runes or runes.Value <= 0 then
        return false, "No runes to spin!"
    end

    local backpack = player:FindFirstChildOfClass("Backpack")
    local runeTool = RuneConfig.getEquippedRuneTool(player.Character, nil)

    if runeTool then
        local runeName = runeTool.Name
        local equippedRuneTier = runeTool:GetAttribute("RuneTier") or RuneConfig.getRuneTier(runeName)
        if not equippedRuneTier then
            return false, "Equip a Rune to spin!"
        end

        local chosenMythical, chosenRarity = RuneConfig.getWeightedCreature(runeName)
        if not chosenMythical then
            return false, "Rune data missing!"
        end

        runes.Value -= 1
        runeTool:Destroy()

        local mythicalsFolder = inventory:FindFirstChild("Mythicals")
        if mythicalsFolder then
            local newMythical = Instance.new("StringValue")
            newMythical.Name = chosenMythical
            newMythical.Value = chosenMythical
            newMythical:SetAttribute("Rarity", chosenRarity)
            newMythical:SetAttribute("RuneTier", equippedRuneTier)
            newMythical.Parent = mythicalsFolder
        end

        if backpack then
        local storedTool = ServerStorage:FindFirstChild(chosenMythical)

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

        tool:SetAttribute("Rarity", chosenRarity)
        tool:SetAttribute("RuneTier", equippedRuneTier)
        tool.Parent = backpack
        end

        return true, chosenMythical, equippedRuneTier
    end

    return false, "Equip a Rune to spin!"
end
