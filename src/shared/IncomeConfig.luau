local IncomeConfig = {}

IncomeConfig.RANGES = {
    Common = { min = 1, max = 12 },
    Uncommon = { min = 15, max = 60 },
    Rare = { min = 75, max = 250 },
    Epic = { min = 400, max = 1000 },
    Legendary = { min = 1500, max = 4000 },
    Mythical = { min = 7500, max = 15000 },
    Ancient = { min = 30000, max = 60000 },
    Divine = { min = 150000, max = 300000 },
    Celestial = { min = 500000, max = 750000 },
}

-- Returns the average income per second for a given rarity
function IncomeConfig.getAverageRate(rarity)
    local range = IncomeConfig.RANGES[rarity]
    if range then
        return math.floor((range.min + range.max) / 2)
    end
    return 0
end

return IncomeConfig
