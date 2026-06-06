# Spin-a-Mythical Game Mechanics

This document serves as the official design and logic reference for the core systems in the game.

## 1. Economy & Currency System
The game uses a dual-currency system tracked inside the player's data.
- **Coins (🪙):** The primary currency used for purchasing Runes from the Shop. Players are granted `5,000` Coins immediately upon joining to allow for instant gameplay testing.
- **Gems (💎):** A premium or secondary currency meant for special items (e.g., Speed Potions, Mythic Eggs).

## 2. The Shop
The shop acts as the gateway for converting Coins into playable items.
- Players purchase items by clicking the price button in the Shop UI.
- The client sends a `BuyItem` request to the server.
- The server verifies the player has sufficient Coins before proceeding.

### Tool Integration (Crucial)
When a Rune is purchased:
1. The server deducts the cost.
2. The server searches `ServerStorage` for a `Tool` whose name exactly matches the purchased item (e.g., `"Basic Rune"` or `"Rare Rune"`).
3. If found, the server clones this 3D Tool into the player's `Backpack` and automatically equips it.
4. If not found, a fallback mechanism creates an empty, invisible tool to prevent errors.

> [!IMPORTANT]
> All custom 3D models (Runes, Mythicals, etc.) **must** be stored as `Tool` objects inside `ServerStorage`. The part the player holds must be named exactly `Handle` with `RequiresHandle` checked to `true`.

## 3. The Custom Inventory
Because standard Roblox hotbars only track physical `Tool` objects in the Backpack, we have implemented a **Custom Inventory System**.
- This UI explicitly tracks numerical variables stored in the player's `Inventory` folder (e.g., `Runes` count).
- It dynamically updates to display the total number of un-spun Runes owned and a visual list of all hatched Mythical creatures.

## 4. The Spin System (Roulette)
The core progression mechanic of the game revolves around "spinning" Runes to obtain Mythical creatures.

### Requirements to Spin
- The `SPIN!` button dynamically appears on the player's HUD only if their internal `Runes` value is `> 0`.
- The spin action consumes one Rune (both the logical `Runes` value and the physical `Tool` item in the character's possession).

### The Animation Overlay
1. Clicking `SPIN!` locks the button and summons a dark screen overlay.
2. A Roulette text label rapidly cycles through all possible Mythical creatures (`🐉 Dragon`, `🦄 Unicorn`, etc.).
3. Under the hood, the client invokes the server to permanently deduct a Rune and select the final prize.
4. Once the server confirms the prize, the UI animation slows down mimicking a slot machine, eventually landing on the exact creature won.
5. The result glows gold, and the character receives a physical `Tool` of the Mythical creature in their hotbar.
