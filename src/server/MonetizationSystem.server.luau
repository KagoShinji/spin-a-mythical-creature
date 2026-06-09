local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local function processReceipt(receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        -- Player left before processing could finish
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    if receiptInfo.ProductId == GameConfig.STEAL_CREATURE_PRODUCT_ID then
        local targetPedestalPath = player:GetAttribute("PendingStealPedestal")
        if targetPedestalPath then
            local pedestalName = targetPedestalPath
            player:SetAttribute("PendingStealPedestal", nil) -- Clear it
            
            -- Find the pedestal in workspace
            local pedistalsFolder = Workspace:FindFirstChild("Pedistals")
            if not pedistalsFolder then return Enum.ProductPurchaseDecision.NotProcessedYet end
            
            local pedestal = pedistalsFolder:FindFirstChild(pedestalName)
            if not pedestal then return Enum.ProductPurchaseDecision.NotProcessedYet end
            
            local occupiedTag = pedestal:FindFirstChild("OccupiedTag")
            if occupiedTag then
                local toolName = occupiedTag.Value
                local savedRarity = occupiedTag:GetAttribute("Rarity")
                
                -- 1. Give creature to stealer
                local pBackpack = player:FindFirstChildOfClass("Backpack")
                if pBackpack then
                    local storedTool = ServerStorage:FindFirstChild(toolName)
                    local newTool
                    if storedTool and storedTool:IsA("Tool") then
                        newTool = storedTool:Clone()
                        newTool.RequiresHandle = false
                    else
                        newTool = Instance.new("Tool")
                        newTool.Name = toolName
                        newTool.RequiresHandle = false
                    end
                    if savedRarity then
                        newTool:SetAttribute("Rarity", savedRarity)
                    end
                    newTool.Parent = pBackpack
                end
                
                -- Add to stealer's inventory mythicals folder so it saves
                local inventory = player:FindFirstChild("Inventory")
                if inventory then
                    local mythicalsFolder = inventory:FindFirstChild("Mythicals")
                    if mythicalsFolder then
                        local newMythical = Instance.new("StringValue")
                        newMythical.Name = toolName
                        newMythical.Value = toolName
                        if savedRarity then newMythical:SetAttribute("Rarity", savedRarity) end
                        newMythical.Parent = mythicalsFolder
                    end
                end
                
                -- 2. Remove creature from pedestal
                local displayModel = pedestal:FindFirstChild(toolName .. "_Display")
                if displayModel then displayModel:Destroy() end
                local billboard = pedestal:FindFirstChild("IncomeBillboard")
                if billboard then billboard:Destroy() end
                occupiedTag:Destroy()
            end
            
            return Enum.ProductPurchaseDecision.PurchaseGranted
        else
            warn("Could not find PendingStealPedestal for player", player.Name)
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
    end

    return Enum.ProductPurchaseDecision.NotProcessedYet
end

MarketplaceService.ProcessReceipt = processReceipt
