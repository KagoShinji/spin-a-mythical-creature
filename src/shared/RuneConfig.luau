local RuneConfig = {}

RuneConfig.RUNE_ORDER = {
    "Basic Rune",
    "Rare Rune",
    "Epic Rune",
    "Legendary Rune",
    "Mythic Rune",
}

RuneConfig.MYTHICAL_RARITIES = {
    {
        name = "Mortal",
        creatures = {"Goblin", "Imp", "Slime"},
    },
    {
        name = "Enchanted",
        creatures = {"Fairy", "Satyr", "Sprite"},
    },
    {
        name = "Ancient",
        creatures = {"Griffin", "Minotaur", "Werewolf"},
    },
    {
        name = "Legendary",
        creatures = {"Dragon", "Phoenix", "Kraken"},
    },
    {
        name = "Divine",
        creatures = {"Hydra", "Chimera", "Kitsune"},
    },
    {
        name = "Celestial",
        creatures = {"Titan", "World Serpent", "Star Dragon"},
    },
}

RuneConfig.RUNE_DATA = {
    ["Basic Rune"] = {
        tier = "Basic",
        price = 100,
        icon = "🔮",
        weights = {
            Mortal = 45,
            Enchanted = 30,
            Ancient = 15,
            Legendary = 7,
            Divine = 2,
            Celestial = 1,
        },
    },
    ["Rare Rune"] = {
        tier = "Rare",
        price = 500,
        icon = "✨",
        weights = {
            Mortal = 38,
            Enchanted = 28,
            Ancient = 18,
            Legendary = 10,
            Divine = 4,
            Celestial = 2,
        },
    },
    ["Epic Rune"] = {
        tier = "Epic",
        price = 1500,
        icon = "💎",
        weights = {
            Mortal = 32,
            Enchanted = 27,
            Ancient = 20,
            Legendary = 12,
            Divine = 6,
            Celestial = 3,
        },
    },
    ["Legendary Rune"] = {
        tier = "Legendary",
        price = 3500,
        icon = "👑",
        weights = {
            Mortal = 26,
            Enchanted = 24,
            Ancient = 20,
            Legendary = 14,
            Divine = 10,
            Celestial = 6,
        },
    },
    ["Mythic Rune"] = {
        tier = "Mythic",
        price = 5000,
        icon = "🌟",
        weights = {
            Mortal = 20,
            Enchanted = 20,
            Ancient = 20,
            Legendary = 18,
            Divine = 14,
            Celestial = 8,
        },
    },
}

function RuneConfig.isRuneName(name: string): boolean
    return RuneConfig.RUNE_DATA[name] ~= nil
end

function RuneConfig.getRuneData(name: string)
    return RuneConfig.RUNE_DATA[name]
end

function RuneConfig.getRuneTier(name: string): string?
    local data = RuneConfig.RUNE_DATA[name]
    return data and data.tier or nil
end

function RuneConfig.getAllRuneNames()
    local names = {}
    for _, name in ipairs(RuneConfig.RUNE_ORDER) do
        if RuneConfig.RUNE_DATA[name] then
            table.insert(names, name)
        end
    end
    return names
end

function RuneConfig.getAllCreatureNames()
    local creatures = {}
    for _, rarity in ipairs(RuneConfig.MYTHICAL_RARITIES) do
        for _, creature in ipairs(rarity.creatures) do
            table.insert(creatures, creature)
        end
    end
    return creatures
end

function RuneConfig.getEquippedRuneTool(character: Instance?, backpack: Instance?)
    local function findRuneTool(container)
        if not container then return nil end

        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Tool") and RuneConfig.isRuneName(child.Name) then
                return child
            end
        end
    end

    local equipped = findRuneTool(character)
    if equipped then
        return equipped
    end

    return findRuneTool(backpack)
end

function RuneConfig.getWeightedCreature(runeName: string)
    local runeData = RuneConfig.RUNE_DATA[runeName]
    if not runeData then
        return nil, nil
    end

    local roll = math.random(1, 100)
    local cumulative = 0

    for _, rarity in ipairs(RuneConfig.MYTHICAL_RARITIES) do
        cumulative += runeData.weights[rarity.name] or 0
        if roll <= cumulative then
            local creature = rarity.creatures[math.random(1, #rarity.creatures)]
            return creature, rarity.name
        end
    end

    local fallbackRarity = RuneConfig.MYTHICAL_RARITIES[#RuneConfig.MYTHICAL_RARITIES]
    return fallbackRarity.creatures[#fallbackRarity.creatures], fallbackRarity.name
end

function RuneConfig.getRuneOdds(runeName: string)
    local runeData = RuneConfig.RUNE_DATA[runeName]
    if not runeData then
        return nil
    end

    local odds = {}
    for _, rarity in ipairs(RuneConfig.MYTHICAL_RARITIES) do
        local weight = runeData.weights[rarity.name] or 0
        local perCreature = weight / #rarity.creatures

        table.insert(odds, {
            rarity = rarity.name,
            creatures = rarity.creatures,
            weight = weight,
            perCreature = perCreature,
        })
    end

    return odds
end

return RuneConfig
