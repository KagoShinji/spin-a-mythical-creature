# Spin-a-Mythical Game Mechanics

This document serves as the official design and logic reference for the core systems in the game.

## 1. Economy & Currency System
The game uses a dual-currency system tracked inside the player's data.
- **Coins:** The primary currency used for purchasing Runes from the Shop. Players are granted `5,000` Coins immediately upon joining to allow for instant gameplay testing.
- **Gems:** A premium or secondary currency meant for special items (e.g., Speed Potions, Mythic Eggs).

## 2. The Shop
The shop acts as the gateway for converting Coins into playable items.
- Players purchase items by clicking the price button in the Shop UI.
- The client sends a `BuyItem` request to the server.
- The server verifies the player has sufficient Coins before proceeding.

### Tool Integration
When a Rune is purchased:
1. The server deducts the cost.
2. The server searches `ServerStorage` for a `Tool` whose name exactly matches the purchased item, such as `"Basic Rune"` or `"Rare Rune"`.
3. If found, the server clones this 3D tool into the player's `Backpack` and automatically equips it.
4. If not found, a fallback mechanism creates an empty, invisible tool to prevent errors.

All custom 3D models, including Runes and Mythicals, should be stored as `Tool` objects inside `ServerStorage`. The part the player holds must be named `Handle` and `RequiresHandle` should be `true`.

## 3. The Custom Inventory
Because the standard Roblox hotbar only tracks physical `Tool` objects in the Backpack, the game uses a custom inventory system.
- The UI tracks numerical variables stored in the player's `Inventory` folder, such as the `Runes` count.
- The UI also displays the player's hatched Mythical creatures.

## 4. The Spin System
The core progression mechanic revolves around spinning Runes to obtain Mythical creatures.

### Requirements to Spin
- The `SPIN!` button appears on the HUD only if the player's internal `Runes` value is greater than `0`.
- The spin action consumes one Rune from both the logical inventory count and the physical tool, when present.

### The Animation Overlay
1. Clicking `SPIN!` locks the button and summons a dark screen overlay.
2. A roulette text label rapidly cycles through the current creature pool, including creatures like `Goblin`, `Dragon`, and `Star Dragon`.
3. Under the hood, the client invokes the server to permanently deduct a Rune and select the final prize.
4. Once the server confirms the prize, the UI animation slows down like a slot machine and lands on the exact creature won.
5. The result glows gold, and the character receives a physical `Tool` of the Mythical creature in their hotbar.
