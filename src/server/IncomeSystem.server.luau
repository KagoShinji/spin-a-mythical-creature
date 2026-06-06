local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local IncomeConfig = require(Shared:WaitForChild("IncomeConfig"))

-- Wait for the pedistals folder to exist
local pedistalsFolder = Workspace:WaitForChild("Pedistals", 10)

-- Helper to format numbers (abbreviated)
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

-- Income Loop: Every second, add coins to pedestals based on mythical creatures
while task.wait(1) do
    if not pedistalsFolder then continue end
    
    for _, pedestal in ipairs(pedistalsFolder:GetDescendants()) do
        local name = string.lower(pedestal.Name)
        if (string.match(name, "^pedistal%d*$") or string.match(name, "^pedestal%d*$")) and pedestal:IsA("Model") then
            local occupiedTag = pedestal:FindFirstChild("OccupiedTag")
            if occupiedTag then
                local rarity = occupiedTag:GetAttribute("Rarity")
                local storedCoins = occupiedTag:FindFirstChild("StoredCoins")
                
                if rarity and storedCoins and IncomeConfig.RANGES[rarity] then
                    local range = IncomeConfig.RANGES[rarity]
                    local income = math.random(range.min, range.max)
                    storedCoins.Value += income
                    
                    -- Update BillboardGui
                    local billboard = pedestal:FindFirstChild("IncomeBillboard")
                    if billboard and billboard:FindFirstChild("Frame") then
                        local producedLabel = billboard.Frame:FindFirstChild("ProducedLabel")
                        if producedLabel then
                            producedLabel.Text = "Produced: " .. formatAbbreviated(storedCoins.Value) .. " 💰"
                        end
                    end
                end
            end
        end
    end
end
