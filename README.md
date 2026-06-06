# Spin a Mythical

This project is managed using [Rojo](https://github.com/rojo-rbx/rojo) to sync code between your local file system (VS Code) and Roblox Studio.

## 🚀 Installation & Setup (Start to End)

Follow these steps to get your environment fully set up so you can edit code and see it in Roblox Studio:

### 1. Prerequisites
- **Visual Studio Code (VS Code)** installed.
- **Roblox Studio** installed.
- **Git** installed (if you are sharing code via GitHub).

### 2. Get the Code
Clone this repository to your computer:
```bash
git clone <your-repository-url>
cd spin-a-mythical
```
*(If you are not using Git, just download the project folder and open it in VS Code).*

### 3. Install Rojo (VS Code & Studio)
Rojo requires two parts to work:
1. **VS Code Extension**: Open VS Code, go to Extensions, search for **Rojo** and install it.
2. **Roblox Studio Plugin**: Open Roblox Studio, go to the **Toolbox** > **Plugins**, search for **Rojo 7.4+**, and install it. 

### 4. Connect Rojo to Studio
To actually sync your files into the game, you must connect them:
1. In VS Code, open a new terminal (`Ctrl + \``) and run:
   ```bash
   rojo serve
   ```
   *(Keep this terminal open while you are working!)*
2. Open your Roblox Studio place file.
3. In Roblox Studio, click the **Plugins** tab at the top.
4. Click the **Rojo** icon, then click the **Connect** button in the window that pops up.
5. You should now see all your files from VS Code instantly appear in Studio!

---

## 🤝 Collaborating with Friends (Team Create)

When working with friends in a Team Create session, **only the person running `rojo serve` will have their files synced into the game.** Rojo does not automatically sync over the internet.

**How to share your code:**
1. You make a change in VS Code and save it.
2. **Commit and Push** your code to GitHub.
3. Your friend (who is running `rojo serve`) must **Pull** your changes from GitHub.
4. As soon as your friend pulls the code to their computer, their running Rojo server will instantly sync it into the shared Roblox Studio session.

**If you aren't using GitHub:**
You must manually send your updated code files to the person running Rojo, and they must place them in their project folder.