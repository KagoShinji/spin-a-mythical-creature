local RuneConfig = {}

RuneConfig.RUNE_ORDER = {
    "Wild Rune",
    "Enchanted Rune",
    "Mystic Rune",
    "Arcane Rune",
    "Mythical Rune",
    "Divine Rune",
    "Celestial Rune",
    "Ancient Rune",
    "Primordial Rune",
    "Extinct King Rune",
}

RuneConfig.MYTHICAL_RARITIES = {
    {
        name = "Celestial",
        baseChance = 0.0001,
        color = Color3.fromHex("#FF2E6D"),
        creatures = {"Celestial Dragon"}
    },
    {
        name = "Divine",
        baseChance = 0.0009,
        color = Color3.fromHex("#B8E63A"),
        creatures = {"Divine Dragon", "Divine Phoenix"}
    },
    {
        name = "Ancient",
        baseChance = 0.009,
        color = Color3.fromHex("#D94841"),
        creatures = {"Ancient Leviathan", "Ancient Hydra"}
    },
    {
        name = "Mythical",
        baseChance = 0.09,
        color = Color3.fromHex("#FF7A21"),
        creatures = {"Ancient Dragon", "World Serpent", "Elder Phoenix"}
    },
    {
        name = "Legendary",
        baseChance = 0.9,
        color = Color3.fromHex("#D9A441"),
        creatures = {"Dragon", "Hydra", "Leviathan", "Behemoth", "Thunder Dragon"}
    },
    {
        name = "Epic",
        baseChance = 4,
        color = Color3.fromHex("#A05BEA"),
        creatures = {"Minotaur", "Chimera", "Manticore", "Kraken", "Cerberus", "Frost Giant"}
    },
    {
        name = "Rare",
        baseChance = 10,
        color = Color3.fromHex("#3E8DD8"),
        creatures = {"Griffin", "Phoenix", "Werewolf", "Basilisk", "Sea Serpent", "Thunder Roc", "Kitsune", "Yeti"}
    },
    {
        name = "Uncommon",
        baseChance = 25,
        color = Color3.fromHex("#5FAE6D"),
        creatures = {"Unicorn", "Pegasus", "Mermaid", "Centaur", "Dryad", "Nymph", "Satyr", "Griffin Cub", "Thunder Bird", "Moon Fox"}
    },
    {
        name = "Common",
        baseChance = 60,
        color = Color3.fromHex("#F4E9D8"),
        creatures = {"Slime", "Pixie", "Fairy", "Sprite", "Imp", "Goblin", "Kobold", "Will-o'-Wisp", "Baby Griffin", "Baby Unicorn", "Forest Spirit", "Mushroom Sprite"}
    }
}

RuneConfig.RUNE_DATA = {
    ["Wild Rune"] = { tier = "Wild", price = 500, icon = "🌿", luckMultiplier = 1.5 },
    ["Enchanted Rune"] = { tier = "Enchanted", price = 2500, icon = "✨", luckMultiplier = 3 },
    ["Mystic Rune"] = { tier = "Mystic", price = 10000, icon = "🔮", luckMultiplier = 5 },
    ["Arcane Rune"] = { tier = "Arcane", price = 50000, icon = "⚡", luckMultiplier = 10 },
    ["Mythical Rune"] = { tier = "Mythical", price = 250000, icon = "🌟", luckMultiplier = 20 },
    ["Divine Rune"] = { tier = "Divine", price = 1000000, icon = "👼", luckMultiplier = 50 },
    ["Celestial Rune"] = { tier = "Celestial", price = 5000000, icon = "🌌", luckMultiplier = 100 },
    ["Ancient Rune"] = { tier = "Ancient", price = 25000000, icon = "📜", luckMultiplier = 200 },
    ["Primordial Rune"] = { tier = "Primordial", price = 100000000, icon = "🌋", luckMultiplier = 500 },
    ["Extinct King Rune"] = { tier = "Extinct King", price = 500000000, icon = "👑", luckMultiplier = 1000 },
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
        -- Default to common if no rune
        local common = RuneConfig.MYTHICAL_RARITIES[#RuneConfig.MYTHICAL_RARITIES]
        return common.creatures[math.random(1, #common.creatures)], common.name
    end

    local luck = runeData.luckMultiplier or 1
    local roll = math.random() * 100

    for i = 1, #RuneConfig.MYTHICAL_RARITIES do
        local rarity = RuneConfig.MYTHICAL_RARITIES[i]
        
        if rarity.name == "Common" then
            -- Common is the fallback
            return rarity.creatures[math.random(1, #rarity.creatures)], rarity.name
        end
        
        local adjustedChance = rarity.baseChance * luck
        if roll <= adjustedChance then
            return rarity.creatures[math.random(1, #rarity.creatures)], rarity.name
        end
    end
    
    -- Safety fallback
    local fallback = RuneConfig.MYTHICAL_RARITIES[#RuneConfig.MYTHICAL_RARITIES]
    return fallback.creatures[math.random(1, #fallback.creatures)], fallback.name
end

function RuneConfig.getRuneOdds(runeName: string)
    local runeData = RuneConfig.RUNE_DATA[runeName]
    if not runeData then
        return nil
    end

    local luck = runeData.luckMultiplier or 1
    local odds = {}
    local remainingChance = 100

    -- Calculate true probabilities top-down
    for i = 1, #RuneConfig.MYTHICAL_RARITIES do
        local rarity = RuneConfig.MYTHICAL_RARITIES[i]
        local actualChance = 0
        
        if rarity.name == "Common" then
            actualChance = math.max(0, remainingChance)
        else
            -- The chance to hit this rarity is (baseChance * luck)
            -- But we can't exceed the remaining available percentage
            actualChance = math.min(remainingChance, rarity.baseChance * luck)
            remainingChance = remainingChance - actualChance
        end
        
        local perCreature = actualChance / #rarity.creatures

        table.insert(odds, {
            rarity = rarity.name,
            creatures = rarity.creatures,
            color = rarity.color,
            totalChance = actualChance,
            perCreature = perCreature,
        })
    end

    return odds
end

return RuneConfig
