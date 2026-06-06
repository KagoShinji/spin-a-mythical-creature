local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Helper to check if a tool is a Mythical creature
local function isMythicalTool(toolName)
    local storedTool = ServerStorage:FindFirstChild(toolName)
    if storedTool then return true end
    
    local parts = string.split(toolName, " ")
    if #parts > 1 then
        local cleanName = table.concat(parts, " ", 2)
        return ServerStorage:FindFirstChild(cleanName) ~= nil
    end
    return false
end

-- Wait for the pedistals folder to exist
local pedistalsFolder = Workspace:WaitForChild("Pedistals", 10)
if not pedistalsFolder then
    warn("Pedistals folder not found in Workspace.")
    return
end

local function setupPedestal(pedestal)
    -- Debounce to prevent multiple fires
    local debounce = false
    
    local function onTouch(hit, basePart)
        if debounce then return end
        
        -- Check if it's already occupied
        if pedestal:FindFirstChild("OccupiedTag") then return end
        
        local character = hit.Parent
        if not character then return end
        
        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end
        
        -- Find if the player is holding a Tool
        local equippedTool = character:FindFirstChildOfClass("Tool")
        if not equippedTool then return end
        
        -- Don't place runes
        if equippedTool.Name:find("Rune") then return end
        
        -- Assume it's a mythical tool
        debounce = true
        
        local toolName = equippedTool.Name
        
        -- Remove the tool from the player
        equippedTool:Destroy()
        
        -- Mark pedestal as occupied
        local occupiedTag = Instance.new("StringValue")
        occupiedTag.Name = "OccupiedTag"
        occupiedTag.Value = toolName
        occupiedTag.Parent = pedestal
        
        -- Find the 3D model to display
        local storedTool = ServerStorage:FindFirstChild(toolName)
        if not storedTool then
            local parts = string.split(toolName, " ")
            if #parts > 1 then
                local cleanName = table.concat(parts, " ", 2)
                storedTool = ServerStorage:FindFirstChild(cleanName)
            end
        end
        
        local displayModel
        if storedTool and storedTool:IsA("Tool") and storedTool:FindFirstChild("Handle") then
            displayModel = storedTool.Handle:Clone()
            displayModel.Name = toolName .. "_Display"
            displayModel.Anchored = true
            displayModel.CanCollide = false
        else
            -- Fallback display
            displayModel = Instance.new("Part")
            displayModel.Name = toolName .. "_Display"
            displayModel.Size = Vector3.new(2, 2, 2)
            displayModel.Color = Color3.new(1, 0.8, 0)
            displayModel.Material = Enum.Material.Neon
            displayModel.Anchored = true
            displayModel.CanCollide = false
        end
        
        local pedestalTop = basePart.Position + Vector3.new(0, basePart.Size.Y / 2 + displayModel.Size.Y / 2 + 1, 0)
        displayModel.CFrame = CFrame.new(pedestalTop)
        displayModel.Parent = pedestal
        
        -- Create ProximityPrompt
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Grab"
        prompt.ObjectText = toolName
        prompt.HoldDuration = 1
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.RequiresLineOfSight = false
        prompt.Parent = displayModel
        
        prompt.Triggered:Connect(function(triggerPlayer)
            -- Anyone can grab it, give it to them
            local backpack = triggerPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                local newTool
                if storedTool then
                    newTool = storedTool:Clone()
                else
                    newTool = Instance.new("Tool")
                    newTool.Name = toolName
                    newTool.RequiresHandle = false
                end
                newTool.Parent = backpack
                
                -- Equip it
                if triggerPlayer.Character then
                    local humanoid = triggerPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:EquipTool(newTool)
                    end
                end
            end
            
            -- Cleanup pedestal
            displayModel:Destroy()
            occupiedTag:Destroy()
            
            task.wait(1)
            debounce = false
        end)
    end
    
    -- Attach Touched event to all BaseParts in the pedestal
    if pedestal:IsA("BasePart") then
        pedestal.Touched:Connect(function(hit) onTouch(hit, pedestal) end)
    else
        for _, descendant in ipairs(pedestal:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.Touched:Connect(function(hit) onTouch(hit, descendant) end)
            end
        end
    end
end

for _, descendant in ipairs(pedistalsFolder:GetDescendants()) do
    if descendant.Name == "Pedistal" and descendant:IsA("Model") then
        setupPedestal(descendant)
    end
end

pedistalsFolder.DescendantAdded:Connect(function(descendant)
    if descendant.Name == "Pedistal" and descendant:IsA("Model") then
        setupPedestal(descendant)
    end
end)
