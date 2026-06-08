local ServerStorage = game:GetService("ServerStorage")

-- Helper to create a dummy Tool for Eggs
local function createDummyEgg(name, color)
    if ServerStorage:FindFirstChild(name) then return end
    
    local tool = Instance.new("Tool")
    tool.Name = name
    tool.RequiresHandle = true
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1.5, 1)
    handle.Shape = Enum.PartType.Ball -- Close enough to an egg for now
    handle.Color = color
    handle.Material = Enum.Material.SmoothPlastic
    handle.Parent = tool
    
    tool.Parent = ServerStorage
end

-- Helper to create a dummy Model for Pets
local function createDummyPet(name, color, size)
    if ServerStorage:FindFirstChild(name) then return end
    
    local model = Instance.new("Model")
    model.Name = name
    
    local part = Instance.new("Part")
    part.Name = "MainPart"
    part.Size = size or Vector3.new(1.5, 1.5, 1.5)
    part.Color = color
    part.Material = Enum.Material.Neon
    part.Parent = model
    
    model.PrimaryPart = part
    model.Parent = ServerStorage
end

-- Eggs
createDummyEgg("Forest Egg", Color3.fromRGB(100, 200, 100))
createDummyEgg("Lava Egg", Color3.fromRGB(255, 80, 0))
createDummyEgg("Mythic Egg", Color3.fromRGB(150, 50, 255))

-- Pets
createDummyPet("Dog", Color3.fromRGB(180, 130, 80), Vector3.new(1, 1, 1))
createDummyPet("Cat", Color3.fromRGB(200, 200, 200), Vector3.new(1, 1, 1))
createDummyPet("Bunny", Color3.fromRGB(255, 255, 255), Vector3.new(0.8, 1, 0.8))
createDummyPet("Lava Slime", Color3.fromRGB(255, 50, 0), Vector3.new(1.2, 1, 1.2))
createDummyPet("Fire Bat", Color3.fromRGB(200, 30, 30), Vector3.new(1.5, 0.5, 1.5))
createDummyPet("Dragon", Color3.fromRGB(50, 200, 50), Vector3.new(2, 2, 2))
createDummyPet("Phoenix", Color3.fromRGB(255, 200, 50), Vector3.new(2, 2, 2.5))
createDummyPet("Kitsune", Color3.fromRGB(255, 100, 100), Vector3.new(1.5, 1.5, 2))

print("Temporary Egg and Pet models generated in ServerStorage.")
