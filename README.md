# VEXHUB - Blox Fruits Hub

A fully-featured script hub for Blox Fruits using Ray Field UI.

## 📁 File Structure

```
VexExternal/
├── BloxFruitsHub.lua              # Main script (upload this to GitHub)
├── execute.lua                    # One-line loadstring executor
├── loader.lua                     # Alternative loader
├── BloxFruitsHub_Loadstring.lua   # Loadstring wrapper
└── README.md                      # This file
```

## 🚀 Quick Start

### Execution Loadstring

Copy and paste this into your executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/itsraindev-source/VEXHUB/main/BloxFruitsHub.lua"))()
```

### Option 2: Local File (Testing Only)

If you have the file locally in your executor's workspace:
```lua
loadstring(readfile("BloxFruitsHub.lua"))()
```

## ✨ Features

### Main Tab
- ✅ Auto Farm - Automatically farms enemies
- ✅ Auto Raid - Completes raids automatically
- ✅ Auto Stats - Auto-distributes stats
- ✅ Auto Quest - Accepts and completes quests
- ✅ Auto Buy Fruits - Buys fruits from dealers

### Stats Tab
- ✅ Max Melee
- ✅ Max Defense
- ✅ Max Sword
- ✅ Max Gun
- ✅ Max Fruit

### Combat Tab
- ✅ Auto Attack
- ✅ Bring Enemies
- ✅ No Cooldown
- ✅ Infinite Range
- ✅ Auto Dodge

### Teleport Tab
- ✅ Fly (WASD + Space)
- ✅ Infinite Jump
- ✅ Speed Boost
- ✅ Teleport to Player
- ✅ No Clip

## 🎮 How to Use

1. **Copy the loadstring** above
2. **Open Roblox** and join Blox Fruits
3. **Open your executor** (Opiumware, Synapse X, KRNL, etc.)
4. **Paste and execute** the loadstring
5. **Use the UI** to enable features

## 📝 Notes

- Uses Ray Field UI library (auto-loaded from GitHub)
- All features have error handling
- Configuration is saved between sessions
- Compatible with most executors
- Repository: https://github.com/itsraindev-source/VEXHUB

## ⚠️ Troubleshooting

**UI not showing?**
- Make sure Ray Field UI can load from GitHub
- Check console for error messages

**Features not working?**
- Some features require specific game states (e.g., be near NPCs for quests)
- Check that you have the necessary tools equipped

**Loadstring failing?**
- Verify the GitHub URL is correct
- Make sure the repository is public
- Check that `BloxFruitsHub.lua` is uploaded correctly

## 📄 License

This script is for educational purposes only.