local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local IncomeConfig = require(Shared:WaitForChild("IncomeConfig"))

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

local pedistalsFolder = Workspace:WaitForChild("Pedistals", 10)
if not pedistalsFolder then
    warn("Pedistals folder not found in Workspace.")
    return
end

-- We will search for claimpads dynamically instead of relying on a folder


local function findClaimpad(index)
    local namePatterns = {
        "^claimpad" .. index .. "$",
        "^claim pad" .. index .. "$",
        "^claimpad " .. index .. "$",
        "^" .. index .. "$" -- just the number, in case it's inside a claimpad folder
    }
    
    local bestMatch = nil
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        local lowerName = string.lower(descendant.Name)
        for _, pattern in ipairs(namePatterns) do
            if string.match(lowerName, pattern) then
                -- Prefer the one actually called claimpad over just the number
                if string.match(lowerName, "claim") then
                    return descendant
                else
                    -- If we found just the number, make sure its parent is a claimpad folder
                    if descendant.Parent and string.match(string.lower(descendant.Parent.Name), "claimpad") then
                        bestMatch = descendant
                    end
                end
            end
        end
    end
    return bestMatch
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
        occupiedTag:SetAttribute("OwnerUserId", player.UserId)
        local toolRarity = equippedTool:GetAttribute("Rarity")
        if toolRarity then
            occupiedTag:SetAttribute("Rarity", toolRarity)
        end
        occupiedTag.Parent = pedestal
        
        local storedCoins = Instance.new("NumberValue")
        storedCoins.Name = "StoredCoins"
        storedCoins.Value = 0
        storedCoins.Parent = occupiedTag
        
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
        local displaySize
        if storedTool and storedTool:IsA("Tool") and storedTool:FindFirstChild("Handle") then
            displayModel = storedTool.Handle:Clone()
            displayModel.Name = toolName .. "_Display"
            
            if displayModel:IsA("Model") then
                local cframe, size = displayModel:GetBoundingBox()
                displaySize = size
                -- Anchor parts within the model
                for _, part in ipairs(displayModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = true
                        part.CanCollide = false
                    end
                end
            elseif displayModel:IsA("BasePart") then
                displaySize = displayModel.Size
                displayModel.Anchored = true
                displayModel.CanCollide = false
            end
        else
            -- Fallback display
            displayModel = Instance.new("Part")
            displayModel.Name = toolName .. "_Display"
            displayModel.Size = Vector3.new(2, 2, 2)
            displayModel.Color = Color3.new(1, 0.8, 0)
            displayModel.Material = Enum.Material.Neon
            displayModel.Anchored = true
            displayModel.CanCollide = false
            displaySize = displayModel.Size
        end
        
        local pedestalTop = basePart.Position + Vector3.new(0, basePart.Size.Y / 2 + displaySize.Y / 2 + 1, 0)
        if displayModel:IsA("Model") then
            if displayModel.PrimaryPart then
                displayModel:SetPrimaryPartCFrame(CFrame.new(pedestalTop))
            else
                displayModel:MoveTo(pedestalTop)
            end
        else
            displayModel.CFrame = CFrame.new(pedestalTop)
        end
        displayModel.Parent = pedestal
        
        -- Create BillboardGui
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "IncomeBillboard"
        billboard.Size = UDim2.new(0, 200, 0, 100)
        billboard.StudsOffset = Vector3.new(0, displaySize.Y / 2 + 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = pedestal
        billboard.Adornee = displayModel
        
        local rate = toolRarity and IncomeConfig.getAverageRate(toolRarity) or 0
        local frame = Instance.new("Frame")
        frame.Name = "Frame"
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "TitleLabel"
        titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
        titleLabel.Text = (toolRarity or "Unknown") .. " " .. toolName
        titleLabel.TextColor3 = Color3.new(1, 1, 1)
        titleLabel.Font = Enum.Font.FredokaOne
        titleLabel.TextScaled = true
        titleLabel.BackgroundTransparency = 1
        titleLabel.Parent = frame

        local producedLabel = Instance.new("TextLabel")
        producedLabel.Name = "ProducedLabel"
        producedLabel.Position = UDim2.new(0, 0, 0.4, 0)
        producedLabel.Size = UDim2.new(1, 0, 0.3, 0)
        producedLabel.Text = "Produced: 0 💰"
        producedLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        producedLabel.Font = Enum.Font.FredokaOne
        producedLabel.TextScaled = true
        producedLabel.BackgroundTransparency = 1
        producedLabel.Parent = frame

        local rateLabel = Instance.new("TextLabel")
        rateLabel.Name = "RateLabel"
        rateLabel.Position = UDim2.new(0, 0, 0.7, 0)
        rateLabel.Size = UDim2.new(1, 0, 0.3, 0)
        rateLabel.Text = "Rate: " .. rate .. " 💰/sec"
        rateLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
        rateLabel.Font = Enum.Font.FredokaOne
        rateLabel.TextScaled = true
        rateLabel.BackgroundTransparency = 1
        rateLabel.Parent = frame

        Instance.new("UIStroke", titleLabel)
        Instance.new("UIStroke", producedLabel)
        Instance.new("UIStroke", rateLabel)
        
        -- Setup Claimpad Touched Event
        local pedestalName = pedestal.Name
        local index = string.match(pedestalName, "%d+")
        local claimpad
        if index then
            claimpad = findClaimpad(index)
        end   
        
        if claimpad then
            print("Successfully linked " .. pedestalName .. " to " .. claimpad.Name)
            local claimDebounce = false
            local claimConnections = {}
            
            local function onClaimpadTouched(hit)
                if claimDebounce then return end
                local hitCharacter = hit.Parent
                if not hitCharacter then return end
                
                local hitPlayer = Players:GetPlayerFromCharacter(hitCharacter)
                if not hitPlayer then return end
                
                if hitPlayer.UserId == player.UserId then
                    if storedCoins.Value > 0 then
                        claimDebounce = true
                        local pLeaderstats = hitPlayer:FindFirstChild("leaderstats")
                        if pLeaderstats then
                            local coins = pLeaderstats:FindFirstChild("Coins")
                            if coins then
                                coins.Value += storedCoins.Value
                                storedCoins.Value = 0
                                producedLabel.Text = "Produced: 0 💰"
                            end
                        end
                        task.wait(0.5)
                        claimDebounce = false
                    end
                end
            end
            
            if claimpad:IsA("BasePart") then
                table.insert(claimConnections, claimpad.Touched:Connect(onClaimpadTouched))
            else
                for _, part in ipairs(claimpad:GetDescendants()) do
                    if part:IsA("BasePart") then
                        table.insert(claimConnections, part.Touched:Connect(onClaimpadTouched))
                    end
                end
            end
            
            -- Store connections to disconnect later
            occupiedTag.AncestryChanged:Connect(function()
                if not occupiedTag:IsDescendantOf(game) then
                    for _, conn in ipairs(claimConnections) do
                        conn:Disconnect()
                    end
                end
            end)
        end
        
        -- Create ProximityPrompt for grabbing
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Grab"
        prompt.ObjectText = toolName
        prompt.HoldDuration = 1
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.RequiresLineOfSight = false
        prompt.Parent = displayModel
        
        prompt.Triggered:Connect(function(triggerPlayer)
            -- Anyone can grab it, give it to them
            local pBackpack = triggerPlayer:FindFirstChildOfClass("Backpack")
            if pBackpack then
                local newTool
                if storedTool then
                    newTool = storedTool:Clone()
                else
                    newTool = Instance.new("Tool")
                    newTool.Name = toolName
                    newTool.RequiresHandle = false
                end
                
                local savedRarity = occupiedTag:GetAttribute("Rarity")
                if savedRarity then
                    newTool:SetAttribute("Rarity", savedRarity)
                end
                
                newTool.Parent = pBackpack
                
                -- Equip it
                if triggerPlayer.Character then
                    local humanoid = triggerPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:EquipTool(newTool)
                    end
                end
            end
            
            -- Automatically claim coins
            if triggerPlayer.UserId == player.UserId and storedCoins.Value > 0 then
                local pLeaderstats = triggerPlayer:FindFirstChild("leaderstats")
                if pLeaderstats then
                    local coins = pLeaderstats:FindFirstChild("Coins")
                    if coins then
                        coins.Value += storedCoins.Value
                    end
                end
            end
            
            -- Cleanup pedestal
            displayModel:Destroy()
            occupiedTag:Destroy()
            billboard:Destroy()
            if claimConnection then claimConnection:Disconnect() end
            
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
    local name = string.lower(descendant.Name)
    if (string.match(name, "^pedistal%d*$") or string.match(name, "^pedestal%d*$")) and descendant:IsA("Model") then
        setupPedestal(descendant)
    end
end

pedistalsFolder.DescendantAdded:Connect(function(descendant)
    local name = string.lower(descendant.Name)
    if (string.match(name, "^pedistal%d*$") or string.match(name, "^pedestal%d*$")) and descendant:IsA("Model") then
        setupPedestal(descendant)
    end
end)
