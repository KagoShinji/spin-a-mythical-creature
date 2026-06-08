local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Network = require(Shared:WaitForChild("Network"))
local EggConfig = require(Shared:WaitForChild("EggConfig"))

local EquipPetRemote = Network.getFunction("EquipPet")
local UnequipPetRemote = Network.getFunction("UnequipPet")
local EquipBestPetsRemote = Network.getFunction("EquipBestPets")

local PetSystem = {}
local MAX_PETS = 5

-- Calculate and return total multipliers for a player
function PetSystem.GetActiveMultipliers(player)
    local coinMult = 1
    local luckMult = 1
    
    local inventory = player:FindFirstChild("Inventory")
    if inventory then
        local petsFolder = inventory:FindFirstChild("Pets")
        if petsFolder then
            for _, petVal in ipairs(petsFolder:GetChildren()) do
                if petVal:GetAttribute("Equipped") then
                    coinMult = coinMult + (petVal:GetAttribute("CoinMultiplier") or 0)
                    luckMult = luckMult + (petVal:GetAttribute("LuckMultiplier") or 0)
                end
            end
        end
    end
    
    return coinMult, luckMult
end

-- Helper to visually attach a pet
local function attachPetVisual(player, petName)
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local petsVisualFolder = character:FindFirstChild("EquippedPets")
    if not petsVisualFolder then
        petsVisualFolder = Instance.new("Folder")
        petsVisualFolder.Name = "EquippedPets"
        petsVisualFolder.Parent = character
    end
    
    local storedPet = ServerStorage:FindFirstChild(petName)
    if not storedPet then
        warn("No 3D model found for pet: " .. petName)
        return
    end
    
    local petModel = storedPet:Clone()
    petModel.Name = petName
    
    -- Ensure all parts are massless and uncollidable
    for _, part in ipairs(petModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Massless = true
            part.CanCollide = false
            part.Anchored = false
        end
    end
    
    local primaryPart = petModel.PrimaryPart
    if not primaryPart then
        primaryPart = petModel:FindFirstChildOfClass("BasePart")
        if primaryPart then
            petModel.PrimaryPart = primaryPart
        end
    end
    
    if not primaryPart then return end
    
    -- We'll attach it via AlignPosition/AlignOrientation
    local attachment0 = Instance.new("Attachment")
    attachment0.Name = "PetAttachment"
    attachment0.Parent = primaryPart
    
    local index = #petsVisualFolder:GetChildren() + 1
    local radius = 4
    local angle = (math.pi * 2 / MAX_PETS) * index
    
    local attachment1 = Instance.new("Attachment")
    attachment1.Name = "TargetAttachment_" .. petName
    attachment1.Position = Vector3.new(math.cos(angle) * radius, 1, math.sin(angle) * radius)
    attachment1.Parent = rootPart
    
    local alignPos = Instance.new("AlignPosition")
    alignPos.Attachment0 = attachment0
    alignPos.Attachment1 = attachment1
    alignPos.Responsiveness = 10
    alignPos.Parent = primaryPart
    
    local alignOri = Instance.new("AlignOrientation")
    alignOri.Attachment0 = attachment0
    alignOri.Attachment1 = attachment1
    alignOri.Responsiveness = 10
    alignOri.Parent = primaryPart
    
    petModel.Parent = petsVisualFolder
end

local function detachPetVisual(player, petName)
    local character = player.Character
    if not character then return end
    
    local petsVisualFolder = character:FindFirstChild("EquippedPets")
    if petsVisualFolder then
        local petModel = petsVisualFolder:FindFirstChild(petName)
        if petModel then
            petModel:Destroy()
        end
    end
end

local function reloadPetVisuals(player)
    local character = player.Character
    if not character then return end
    
    local petsVisualFolder = character:FindFirstChild("EquippedPets")
    if petsVisualFolder then
        petsVisualFolder:ClearAllChildren()
    end
    
    local inventory = player:FindFirstChild("Inventory")
    if inventory then
        local petsFolder = inventory:FindFirstChild("Pets")
        if petsFolder then
            for _, petVal in ipairs(petsFolder:GetChildren()) do
                if petVal:GetAttribute("Equipped") then
                    attachPetVisual(player, petVal.Name)
                end
            end
        end
    end
end

EquipPetRemote.OnServerInvoke = function(player, petId)
    -- petId is the unique identifier (we'll just use the object reference or its name if names aren't duplicate, but StringValue might share names. Let's pass the instance itself)
    if typeof(petId) ~= "Instance" or petId.Parent.Name ~= "Pets" or petId.Parent.Parent.Parent ~= player then
        return false, "Invalid pet!"
    end
    
    if petId:GetAttribute("Equipped") then
        return false, "Already equipped!"
    end
    
    local petsFolder = petId.Parent
    local equippedCount = 0
    for _, p in ipairs(petsFolder:GetChildren()) do
        if p:GetAttribute("Equipped") then
            equippedCount += 1
        end
    end
    
    if equippedCount >= MAX_PETS then
        return false, "You can only equip up to " .. MAX_PETS .. " pets!"
    end
    
    petId:SetAttribute("Equipped", true)
    reloadPetVisuals(player)
    
    return true, "Equipped!"
end

UnequipPetRemote.OnServerInvoke = function(player, petId)
    if typeof(petId) ~= "Instance" or petId.Parent.Name ~= "Pets" or petId.Parent.Parent.Parent ~= player then
        return false, "Invalid pet!"
    end
    
    if not petId:GetAttribute("Equipped") then
        return false, "Not equipped!"
    end
    
    petId:SetAttribute("Equipped", false)
    reloadPetVisuals(player)
    
    return true, "Unequipped!"
end

EquipBestPetsRemote.OnServerInvoke = function(player)
    local inventory = player:FindFirstChild("Inventory")
    if not inventory then return false, "No inventory!" end
    
    local petsFolder = inventory:FindFirstChild("Pets")
    if not petsFolder then return false, "No pets!" end
    
    local allPets = petsFolder:GetChildren()
    if #allPets == 0 then return false, "No pets to equip!" end
    
    -- Unequip all first
    for _, p in ipairs(allPets) do
        p:SetAttribute("Equipped", false)
    end
    
    -- Sort by combined multipliers
    table.sort(allPets, function(a, b)
        local aVal = (a:GetAttribute("CoinMultiplier") or 0) + (a:GetAttribute("LuckMultiplier") or 0) * 2 -- Weight luck a bit more if needed, or 1:1
        local bVal = (b:GetAttribute("CoinMultiplier") or 0) + (b:GetAttribute("LuckMultiplier") or 0) * 2
        return aVal > bVal
    end)
    
    local equippedCount = 0
    for i = 1, math.min(#allPets, MAX_PETS) do
        allPets[i]:SetAttribute("Equipped", true)
        equippedCount += 1
    end
    
    reloadPetVisuals(player)
    
    return true, "Equipped best " .. equippedCount .. " pets!"
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Reload visuals on respawn
        task.wait(0.5)
        reloadPetVisuals(player)
    end)
end)

return PetSystem
