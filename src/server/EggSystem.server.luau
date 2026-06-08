local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Network = require(Shared:WaitForChild("Network"))
local EggConfig = require(Shared:WaitForChild("EggConfig"))

local BuyEggRemote = Network.getFunction("BuyEgg")
local SpinEggRemote = Network.getFunction("SpinEgg")

BuyEggRemote.OnServerInvoke = function(player, eggName)
    local eggData = EggConfig.getEggData(eggName)
    if not eggData then
        return false, "Egg not found!"
    end

    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return false, "Data error!" end

    local currencyObj = leaderstats:FindFirstChild(eggData.currency)
    if not currencyObj then return false, "Currency error!" end

    if currencyObj.Value >= eggData.price then
        currencyObj.Value -= eggData.price

        local inventory = player:FindFirstChild("Inventory")
        if inventory then
            local eggsFolder = inventory:FindFirstChild("Eggs")
            if not eggsFolder then
                eggsFolder = Instance.new("Folder")
                eggsFolder.Name = "Eggs"
                eggsFolder.Parent = inventory
            end
            
            -- Keep track of eggs using IntValues
            local eggCount = eggsFolder:FindFirstChild(eggName)
            if not eggCount then
                eggCount = Instance.new("IntValue")
                eggCount.Name = eggName
                eggCount.Value = 0
                eggCount.Parent = eggsFolder
            end
            eggCount.Value += 1

            local backpack = player:FindFirstChildOfClass("Backpack")
            if backpack then
                local storedTool = ServerStorage:FindFirstChild(eggName)
                local tool
                if storedTool and storedTool:IsA("Tool") then
                    tool = storedTool:Clone()
                else
                    tool = Instance.new("Tool")
                    tool.Name = eggName
                    tool.RequiresHandle = false
                end
                tool:SetAttribute("IsEgg", true)
                tool.Parent = backpack
                
                -- Auto equip logic
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:EquipTool(tool)
                    end
                end
            end
        end
        return true, "Successfully purchased " .. eggName
    else
        return false, "Not enough " .. eggData.currency
    end
end

SpinEggRemote.OnServerInvoke = function(player)
    local inventory = player:FindFirstChild("Inventory")
    if not inventory then return false, "No inventory found" end

    local eggsFolder = inventory:FindFirstChild("Eggs")
    if not eggsFolder then return false, "No eggs folder!" end

    local character = player.Character
    if not character then return false, "No character!" end

    local equippedTool = character:FindFirstChildOfClass("Tool")
    if not equippedTool or not EggConfig.isEggName(equippedTool.Name) then
        return false, "Equip an Egg to spin!"
    end

    local eggName = equippedTool.Name
    local eggCount = eggsFolder:FindFirstChild(eggName)
    
    if not eggCount or eggCount.Value <= 0 then
        return false, "You don't own this egg!"
    end

    local chosenPet, chosenRarity = EggConfig.getWeightedPet(eggName)
    if not chosenPet then
        return false, "Egg data missing!"
    end

    -- Consume the egg
    eggCount.Value -= 1
    equippedTool:Destroy()

    -- Add Pet to Inventory
    local petsFolder = inventory:FindFirstChild("Pets")
    if not petsFolder then
        petsFolder = Instance.new("Folder")
        petsFolder.Name = "Pets"
        petsFolder.Parent = inventory
    end

    local newPet = Instance.new("StringValue")
    newPet.Name = chosenPet
    newPet.Value = chosenPet
    newPet:SetAttribute("Rarity", chosenRarity)
    newPet:SetAttribute("Equipped", false)
    
    -- Cache buffs on the value for easy reading
    local buffs = EggConfig.PET_BUFFS[chosenPet]
    if buffs then
        newPet:SetAttribute("CoinMultiplier", buffs.CoinMultiplier or 0)
        newPet:SetAttribute("LuckMultiplier", buffs.LuckMultiplier or 0)
    end
    
    newPet.Parent = petsFolder

    return true, chosenPet, chosenRarity
end
