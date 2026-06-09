# Plot Ownership & Stealing System

This document outlines the mechanics and setup steps for the 6-player Plot and Stealing system that has been integrated into the project. Use this guide to continue development or configure the final pieces in Roblox Studio.

## System Overview

### 1. Plot & Avatar Spawning (`PlotSystem.server.luau`)
- **How it works:** When a player joins, the system automatically finds an available `Plot` (from `Plot1` to `Plot6` in the Workspace).
- **Spawning:** The player is immediately teleported to the `SpawnLocation` or `Base` part inside their assigned Plot.
- **Nameplate:** A custom `BillboardGui` is created dynamically above the plot base, showing the player's Roblox avatar and their name (e.g., "rocsdacrocs's Plot").
- **Cleanup:** When the player leaves, the plot ownership is cleared and the nameplate resets to "Unowned Plot".

### 2. Pedestal Ownership (`PedestalSystem.server.luau`)
- **How it works:** Pedestals are tied to plots based on their numbering (e.g., `Pedistal1` belongs to the owner of `Plot1`).
- **Placement:** Only the owner of the plot can interact with their pedestal to place a Mythical creature.
- **Coin Collection:** The ClaimPad linked to the pedestal is locked to the plot owner, preventing other players from harvesting their generated coins.

### 3. Stealing Mechanics (`MonetizationSystem.server.luau`)
- **How it works:** Players can freely walk into other players' plots to view their Mythical creatures.
- **Interaction:** 
  - If the **owner** presses 'E', they grab their creature back into their inventory.
  - If a **non-owner** presses 'E', they are prompted to **Steal** the creature for **39 Robux**.
- **Purchase Handling:** When the purchase is completed via `MarketplaceService.ProcessReceipt`:
  1. The original creature is destroyed from the victim's pedestal.
  2. A copy of the creature is placed into the stealer's `Backpack` (equipped).
  3. The creature is permanently added to the stealer's saved `Mythicals` folder.

---

## 🛠️ Action Required: Next Steps for Integration

To fully activate the stealing mechanic, you must complete the following steps in Roblox Studio / Creator Dashboard:

### Step 1: Create the Developer Product
1. Go to the **Roblox Creator Dashboard**.
2. Select your experience and navigate to **Monetization > Developer Products**.
3. Create a new product named **"Steal Creature"**.
4. Set the price to **39 Robux**.
5. Copy the generated **Product ID**.

### Step 2: Update `GameConfig.luau`
1. Open the file located at: `src/shared/GameConfig.luau`
2. Replace the placeholder `0` with the actual Product ID you copied:
```lua
local GameConfig = {
    -- Paste your Developer Product ID here:
    STEAL_CREATURE_PRODUCT_ID = 1234567890, 
    STEAL_PRICE = 39,
}
return GameConfig
```

### Step 3: Workspace Structure Verification
Make sure your Workspace hierarchy is correctly named so the scripts can link them:
- Plots must be named exactly `Plot1`, `Plot2`, `Plot3`, `Plot4`, `Plot5`, `Plot6`.
- Pedestals in the `Pedistals` folder must be numbered to match (e.g., `Pedistal1` maps to `Plot1`).
- Each Plot must contain a part named `Base` for the floating Nameplate to attach to.

## Testing Locally
To test the stealing feature without spending real Robux:
1. Open Roblox Studio and navigate to the **Test** tab.
2. Under "Clients and Servers", set the player count to **2 Players** and click **Start**.
3. Once both windows open, have Player 1 place a creature on their pedestal.
4. Have Player 2 walk to Player 1's plot and interact with the pedestal to trigger a test purchase. (Test purchases in Studio do not charge real Robux).
