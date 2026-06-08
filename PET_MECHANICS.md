# Pet & Egg Mechanics

This document serves as the official design and logic reference for the new Egg and Pet systems in the game.

## 1. Egg System
Eggs are treated similarly to Runes but have their own distinct shop and inventory representation.

### Purchasing
- **Forest Egg**: Costs 250 Coins.
- **Lava Egg**: Costs 1,000 Coins.
- **Mythic Egg**: Costs 500 Gems.
- Players purchase eggs from the Eggs Panel in the UI.

### Equipping & Spinning
- When a player clicks an egg in their inventory, it equips as a physical `Tool` in their character.
- While the player is holding an Egg, the `SPIN!` button on the HUD becomes visible.
- Clicking `SPIN!` consumes the Egg, plays a roulette animation, and rewards the player with a Pet based on weighted chances defined in `EggConfig.luau`.

## 2. Pet System
Pets are equippable companions that provide multipliers to the player.

### Inventory & Equipping
- Players have a "Pets" inventory tab.
- A player can equip up to **5 pets** at the same time.
- Equipped pets will physically float around the player using `AlignPosition` and `AlignOrientation` to smoothly follow the character's movement.

### Equip Best Feature
- The inventory includes an "Equip Best" button.
- Clicking this button automatically equips the 5 pets with the highest combined multipliers, ensuring the player always has the optimal loadout.

### Multipliers
Each Pet type grants specific buffs:
- **Coin Multiplier**: Increases the number of coins received when claiming from Pedestals.
- **Luck Multiplier**: Temporarily unused, but will apply to Rune and Egg spinning odds in the future.
- The server provides a function `PetSystem.GetActiveMultipliers(player)` to fetch the summed multipliers of all currently equipped pets.
