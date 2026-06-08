local EggConfig = {}

EggConfig.EGG_DATA = {
    ["Forest Egg"] = { price = 250, currency = "Coins" },
    ["Lava Egg"] = { price = 1000, currency = "Coins" },
    ["Mythic Egg"] = { price = 500, currency = "Gems" }
}

EggConfig.PET_BUFFS = {
    ["Dog"] = { CoinMultiplier = 0.5, LuckMultiplier = 0 },
    ["Cat"] = { CoinMultiplier = 0.5, LuckMultiplier = 0 },
    ["Bunny"] = { CoinMultiplier = 1, LuckMultiplier = 0 },
    ["Lava Slime"] = { CoinMultiplier = 1.5, LuckMultiplier = 0.5 },
    ["Fire Bat"] = { CoinMultiplier = 2, LuckMultiplier = 0.5 },
    ["Dragon"] = { CoinMultiplier = 3, LuckMultiplier = 1 },
    ["Phoenix"] = { CoinMultiplier = 5, LuckMultiplier = 2 },
    ["Kitsune"] = { CoinMultiplier = 10, LuckMultiplier = 5 }
}

EggConfig.EGG_ODDS = {
    ["Forest Egg"] = {
        {
            rarity = "Common",
            totalChance = 70,
            creatures = {"Dog", "Cat"},
            perCreature = 35,
            color = Color3.fromRGB(180, 180, 180)
        },
        {
            rarity = "Uncommon",
            totalChance = 30,
            creatures = {"Bunny"},
            perCreature = 30,
            color = Color3.fromRGB(120, 255, 120)
        }
    },
    ["Lava Egg"] = {
        {
            rarity = "Rare",
            totalChance = 75,
            creatures = {"Lava Slime", "Fire Bat"},
            perCreature = 37.5,
            color = Color3.fromRGB(100, 150, 255)
        },
        {
            rarity = "Epic",
            totalChance = 25,
            creatures = {"Dragon"},
            perCreature = 25,
            color = Color3.fromRGB(200, 100, 255)
        }
    },
    ["Mythic Egg"] = {
        {
            rarity = "Legendary",
            totalChance = 80,
            creatures = {"Phoenix"},
            perCreature = 80,
            color = Color3.fromRGB(255, 180, 50)
        },
        {
            rarity = "Mythical",
            totalChance = 20,
            creatures = {"Kitsune"},
            perCreature = 20,
            color = Color3.fromRGB(255, 80, 80)
        }
    }
}

function EggConfig.isEggName(name)
    return EggConfig.EGG_DATA[name] ~= nil
end

function EggConfig.getEggData(name)
    return EggConfig.EGG_DATA[name]
end

function EggConfig.getEggOdds(name)
    return EggConfig.EGG_ODDS[name]
end

function EggConfig.getWeightedPet(eggName)
    local odds = EggConfig.EGG_ODDS[eggName]
    if not odds then return nil, nil end

    local totalWeight = 0
    for _, rarityGroup in ipairs(odds) do
        totalWeight = totalWeight + rarityGroup.totalChance
    end

    local randomVal = math.random() * totalWeight
    local currentWeight = 0

    for _, rarityGroup in ipairs(odds) do
        currentWeight = currentWeight + rarityGroup.totalChance
        if randomVal <= currentWeight then
            local pets = rarityGroup.creatures
            local chosenPet = pets[math.random(1, #pets)]
            return chosenPet, rarityGroup.rarity
        end
    end

    return odds[1].creatures[1], odds[1].rarity
end

return EggConfig
